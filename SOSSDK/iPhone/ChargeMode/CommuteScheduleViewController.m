//
//  CommuteScheduleViewController.m
//  Onstar
//
//  Created by Vicky on 15/12/2.
//  Copyright © 2015年 Shanghai Onstar. All rights reserved.
//

#import "CommuteScheduleViewController.h"
#import "ResponseDataObject.h"
#import "CustomerInfo.h"
#import "SetDepartTimeTableView.h"
#import "ServiceController.h"
#import "LoadingView.h"


@interface CommuteScheduleViewController (){
    NSMutableArray *timeArray;
    NNWeeklyCommuteSchedule *weeklySchedule;
    NSDictionary *timeDic;
}

@end

@implementation CommuteScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   UIView *saveview = [[UIView alloc] init];
    saveview.layer.backgroundColor = [UIColor colorWithHexString:@"#F3F5FE"].CGColor;
    [self.view addSubview:saveview];
   
    UIButton * saveButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton setNSButtonStyle];
    [saveview addSubview:saveButton];
    [saveButton addTarget:self action:@selector(buttonSaveTapped) forControlEvents:UIControlEventTouchUpInside];
    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(93);
        make.trailing.mas_equalTo(-93);
        make.bottom.mas_equalTo(saveview).mas_offset(-16);
        make.height.mas_equalTo(37);
    }];
    
    self.timeTable = [[SetDepartTimeTableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 426) style:UITableViewStylePlain];
    [self.view addSubview:self.timeTable];
    [self.timeTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view);
        make.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).mas_offset(10);
        make.height.mas_equalTo(426);
        make.bottom.mas_equalTo(saveview.mas_top);
    }];
    
    [saveview mas_makeConstraints:^(MASConstraintMaker *make) {
           make.leading.mas_equalTo(self.view);
           make.trailing.mas_equalTo(self.view);
           make.bottom.mas_equalTo(self.view);
       }];
    
    self.title = NSLocalizedString(@"CM_DepatureTimeTitle", nil);
  
}

- (void)buttonSaveTapped {
    NSMutableArray *SelectedtimeArray = [NSMutableArray array];
    for(int i=0 ;i< self.timeTable.selectionDataArray.count; i++){
        SelectionData *data = (SelectionData *)[self.timeTable.selectionDataArray objectAtIndex:i];
        NSString *time = [NSString stringWithFormat:@"%@:%@:00",NOTime(data.selectHour) ,NOTime(data.selectMin) ];
        
        [SelectedtimeArray addObject:time];
    }
    NSArray *dayArray = [NSArray arrayWithObjects:WEEK_DAY0, WEEK_DAY1,WEEK_DAY2,WEEK_DAY3,WEEK_DAY4,WEEK_DAY5,WEEK_DAY6,nil ];
    timeDic = [NSDictionary dictionaryWithObjects:SelectedtimeArray forKeys:[dayArray copy]];
    
    weeklySchedule = [[NNWeeklyCommuteSchedule alloc]init];
    
    weeklySchedule.dailyCommuteSchedule = (NSArray *)timeDic;
    
    [[LoadingView sharedInstance] startIn:self.view];
    
    [self startService:SET_SCHEDULE_REQUEST];
    
}


- (void)startService:(NSString *) requestName     {
    if (![[ServiceController sharedInstance] tryPerformRequest:requestName StartTime:[NSDate date]]) {
        return;
    }
    ServiceController * service = [ServiceController sharedInstance];
    service.vin = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin;
    service.migSessionKey = [CustomerInfo sharedInstance].mig_appSessionKey;
    service.scheduleDic = timeDic;
    [[ServiceController sharedInstance] updatePerformVehicleService];
    [service startFunctionWithName:requestName startSuccess:^(id result) {
        NSString *resultStr = (NSString *)result;
        if ([resultStr isEqualToString:@"polling success"]) {
            NSLog(@"start success*\n*");
        }
        
    } startFail:^(id result) {
        NSString *errorCode = (NSString *)result;
        if ([errorCode isEqualToString:NETWORK_TIMEOUT]) {
            [self getAlertInfoFromCurrentRequest:requestName andStaus:RemoteControlStatus_OperateTimeout andCode:errorCode];
        }else if([errorCode isEqualToString:BACKEND_ERROR]){
            [self getAlertInfoFromCurrentRequest:nil andStaus:RemoteControlStatus_Void andCode:errorCode];
        }else{
            [self getAlertInfoFromCurrentRequest:requestName andStaus:RemoteControlStatus_OperateFail andCode:errorCode];
        }
        NSLog(@"start failed*\n*");
    } askSuccess:^(id result) {
        [Util alertUserEvluateApp];
        if ([requestName isEqualToString:SET_SCHEDULE_REQUEST]) {
            [self getAlertInfoFromCurrentRequest:requestName andStaus:RemoteControlStatus_OperateSuccess andCode:nil];
        }
        
    } askFail:^(id result) {
        NSString *errorCode = (NSString *)result;
        if ([errorCode isEqualToString:NETWORK_TIMEOUT]) {
            [self getAlertInfoFromCurrentRequest:requestName andStaus:RemoteControlStatus_OperateTimeout andCode:errorCode];
        }else if([errorCode isEqualToString:BACKEND_ERROR]){
            [self getAlertInfoFromCurrentRequest:nil andStaus:RemoteControlStatus_Void andCode:errorCode];
        }else{
            [self getAlertInfoFromCurrentRequest:requestName andStaus:RemoteControlStatus_OperateFail andCode:errorCode];
        }
        
        NSLog(@"polling failed*\n*");
    }];
}



- (void)getAlertInfoFromCurrentRequest:(NSString *) requestName andStaus:(RemoteControlStatus) status andCode:(NSString *) code{
    NSString *alertInfos = @"";
    int i = 0;
    if ([requestName isEqualToString:SET_SCHEDULE_REQUEST])
    {
        if (status == RemoteControlStatus_OperateSuccess){
            alertInfos = NSLocalizedString(@"phev_setSchedule_success", @"");
            i = 1;
        }else if(status == RemoteControlStatus_OperateFail){
            alertInfos = NSLocalizedString(@"phev_setSchedule_fail", @"");
            i = 0;
        }else{
            alertInfos = NSLocalizedString(@"phev_setSchedule_timeout", @"");
            i = 0;
        }
    }
    else{
        alertInfos = NSLocalizedString(BACKEND_ERROR, @"");
    }
    
    [Util hideLoadView];
    [Util showAlertWithTitle:nil message:alertInfos completeBlock:nil];
}


@end
