//
//  SOSSettingViewController.m
//  Onstar
//
//  Created by lizhipan on 2017/8/2.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSSettingViewController.h"
#import "SOSServiceSettingViewController.h"
#import "SOSRemindsetVc.h"

@interface SOSSettingViewController ()<LLSegmentBarVCDelegate>

@property (nonatomic,assign) BOOL bleWitchStatusOn;

@end

@implementation SOSSettingViewController

- (instancetype)init	{
    self = [super init];
    if (self) {
//        if ([LoginManage sharedInstance].loginState == LOGIN_STATE_NON) {
//            
//        }
//        else
//        {}
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"设置";
    self.backRecordFunctionID = Setting_back;
    SOSServiceSettingViewController *serviceSetting = [[SOSServiceSettingViewController alloc] init];
    serviceSetting.goBack = [self.fromVC isEqualToString:@"smartDrive"] ? YES : NO;   //驾驶评为界面进入设置后如果开通后需要自动返回
    serviceSetting.refreshH5Block = self.refreshH5Block;
    @weakify(self)
    serviceSetting.bleSwitchBlock = ^(BOOL swithStatusOn) {
        @strongify(self)
        self.bleWitchStatusOn = swithStatusOn;
    };
    [serviceSetting initTableDelegate:serviceSetting scrollPara:nil style:UITableViewStyleGrouped];
    
    SOSRemindsetVc *remindsetVc = [[SOSRemindsetVc alloc] initWithNibName:@"SOSRemindsetVc" bundle:nil];
    [self setUpWithItems:@[@"服务设置",@"提醒设置"] childVCs:@[serviceSetting, remindsetVc]];
    self.segmentVC.delegate = self;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"common_Nav_Back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
}

- (void)segmentBar:(LLSegmentBar *)segmentBar didSelectIndex:(NSInteger)toIndex fromIndex:(NSInteger)fromIndex  {
    if (toIndex == 1) {
        [SOSDaapManager sendActionInfo:NotificationSetting];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dismiss {
    UIViewController *vc = [self.navigationController.viewControllers lastObject];
    if (!IsStrEmpty(vc.backRecordFunctionID)) {
        NSString *title = !IsStrEmpty(vc.title)?[NSString stringWithFormat:@"[%@]",vc.title]:@"";
        NSLog(@"%@%@ backRecordFunctionID: %@",[vc class],title, vc.backRecordFunctionID);
        [SOSDaapManager sendActionInfo:vc.backRecordFunctionID];
    }
    //daap
    if (vc.backDaapFunctionID.isNotBlank) {
        NSString *title = !IsStrEmpty(vc.title)?[NSString stringWithFormat:@"[%@]",vc.title]:@"";
        NSLog(@"%@%@ backRecordFunctionID: %@",[vc class],title, vc.backDaapFunctionID);
        [SOSDaapManager sendActionInfo:vc.backDaapFunctionID];
    }
    
    [self checkDaap:vc];
    [self.navigationController popViewControllerAnimated:YES];
    if (self.bleWitchStatusOn) {
        !self.popBlock?:self.popBlock();
    }
}

- (void)checkDaap:(UIViewController *)vc
{
    NSDictionary *dic = @{My_massage_activity_back:@"MY0108",My_massage_notificition_back:@"MY0109"};
    [SOSDaapManager sendActionInfo:dic[vc.backDaapFunctionID]];
}


@end
