//
//  SOSSocialRecoverViewController.m
//  Onstar
//
//  Created by onstar on 2019/4/24.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSSocialRecoverViewController.h"
#import "SOSSocialService.h"
#import "SOSSocialContactViewController.h"
#import "BaseSearchOBJ.h"
#import "SOSSocialBeginGPSViewController.h"
#import "SOSSocialGPSViewController.h"
#import "SOSNavigateTool.h"
#import "SOSSocialCarGPSFinishViewController.h"

@interface SOSSocialRecoverViewController ()
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIButton *recorverButton;
@property (weak, nonatomic) IBOutlet UIButton *changeWayButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (nonatomic, strong) BaseSearchOBJ *searchOBJ;

@property (assign, nonatomic) NSInteger geoStatus;// 0:开始导航  1:恢复导航 发送到车:2
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;



@end

@implementation SOSSocialRecoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title= @"我来接";
//    if (self.mobileType) {
//        
//    }else {
//        if ([self.orderInfo.statusName isEqualToString:@"DRIVERCONFIRM"]) {
//            self.mobileType = YES;
//        }else {
//            self.mobileType = NO;
//        }
//    }
    if (self.orderInfo) {
        [self geoLocation];
    }else if (self.currentPOI) {
        [self configUI];
    }
    
    //车机距离<500m
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOSNotificationCarGPSFinish object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        SOSSocialCarGPSFinishViewController *vc = [[SOSSocialCarGPSFinishViewController alloc] initWithNibName:@"SOSSocialCarGPSFinishViewController" bundle:nil];
        vc.currentPOI = self.currentPOI;
        [self.navigationController pushViewController:vc wantToRemoveViewController:self animated:YES];
    }];
    
    //** 监测指令下发状态 使用范例
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOS_VEHICLE_OPERATE_NOTIFICATION object:nil] subscribeNext:^(NSNotification *x) {
        NSDictionary *userInfo = x.userInfo;
        //    @{@"state":@(RemoteControlStatus), @"OperationType" : @(SOSRemoteOperationType) , @"message": message}
        SOSRemoteOperationType operationType = [userInfo[@"OperationType"] intValue];
        if (operationType == SOSRemoteOperationType_SendPOI_ODD) {
            [Util showHUDWithStatus:@"路线正在下发,请耐心等待1-3分钟"];
            RemoteControlStatus state = [userInfo[@"state"] intValue];
            switch (state) {
                case RemoteControlStatus_InitSuccess:
                    NSLog(@"init成功");
                    
                    break;
                case RemoteControlStatus_OperateSuccess:
                {
                    NSLog(@"下发成功");
                    [Util dismissHUD];
                    @weakify(self)
                    [self changeStatus:@"DRIVERCONFIRMFORVEHICLE" success:^{
                        @strongify(self)
                        self.mobileType = NO;
                        [self configUI];
                        //开启server
                        [[SOSSocialService shareInstance] startUploadLocationServiceWithPoi:self.currentPOI];
                    }];
                }
                    break;
                case RemoteControlStatus_OperateTimeout:
                case RemoteControlStatus_OperateFail:
                    NSLog(@"下发失败");
                    [Util showAlertWithTitle:@"路线下发失败,请重试" message:nil confirmBtn:@"知道了" completeBlock:nil];
                    [Util dismissHUD];
                    break;
                default:
                    break;
            }
        }
    }];
    
}

- (void)configUI {
    if (self.mobileType) {
        [self.recorverButton setTitle:@"恢复导航" forState:UIControlStateNormal];
        [self.changeWayButton setTitle:@"发送地点到车" forState:UIControlStateNormal];
    }else {
        [self.recorverButton setTitle:@"再次发送地点到车" forState:UIControlStateNormal];
        [self.changeWayButton setTitle:@"使用手机导航" forState:UIControlStateNormal];
    }
    self.addressLabel.text = self.currentPOI.name;
}
- (IBAction)recorverTap:(id)sender {
    if (self.mobileType) {
        //恢复导航
        [self recoverGPS];
        [SOSDaapManager sendActionInfo:Pipup_DRIVERCONMA_renewNAV];
    }else {
        //再次发送地点到车
        [self sendToCar];
        [SOSDaapManager sendActionInfo:Pipup_DRIVERCONCAR_resendtocar];
    }
}

- (IBAction)changeWayTap:(id)sender {
    if (self.mobileType) {
        //发送地点到车
        [self sendToCar];
        [SOSDaapManager sendActionInfo:Pipup_DRIVERCONMA_sendtocar];
        

    }else {
//        //手机导航
//        if (self.orderInfo) {
//            [self startGPS];
//        }else if (self.currentPOI){
            //开始导航页面
        [SOSDaapManager sendActionInfo:Pipup_DRIVERCONCAR_Nav];
        CustomerInfo *customerInfo = [CustomerInfo sharedInstance];
        SOSSocialBeginGPSViewController *vc = [[SOSSocialBeginGPSViewController alloc] initWithRouteBeginPOI:customerInfo.currentPositionPoi AndEndPOI:self.currentPOI];
        [self.navigationController pushViewController:vc wantToRemoveViewController:self animated:NO];
//        }
    }
}

- (IBAction)cancelTap:(id)sender {
    if (self.mobileType) {
        [SOSDaapManager sendActionInfo:Pipup_DRIVERCONMA_cancel];
    }else {
        [SOSDaapManager sendActionInfo:Pipup_DRIVERCONCAR_cancel];

    }
    
    [Util showAlertWithTitle:@"是否终止本次接送" message:@"终止接送后，已发出的确认函将失效" completeBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            //终止
            [self changeStatus:@"CANCEL" success:^{
                SOSSocialContactViewController *vc = [[SOSSocialContactViewController alloc] initWithNibName:@"SOSSocialContactViewController" bundle:nil];
                [self.navigationController pushViewController:vc wantToRemoveViewController:self animated:NO];
                [[SOSSocialService shareInstance] endUploadLocationService];
            }];
        }
    } cancleButtonTitle:@"取消" otherButtonTitles:@"终止", nil];
}


- (void)sendToCar {
    [SOSNavigateTool sendToCarAutoWithPOI:self.currentPOI];
}

- (void)recoverGPS {
    [[SOSSocialService shareInstance] startUploadLocationService];
    id vc = [[SOSSocialGPSViewController alloc] initWithStartPoint:[CustomerInfo sharedInstance].currentPositionPoi endPoint:self.currentPOI drivingStrategy:0];
    [self.navigationController pushViewController:vc wantToRemoveViewController:self animated:NO];
}

//- (void)startGPS {
//    @weakify(self)
//    [self changeStatus:@"DRIVERCONFIRM" success:^{
//        @strongify(self)
//        CustomerInfo *customerInfo = [CustomerInfo sharedInstance];
//        SOSSocialBeginGPSViewController *vc = [[SOSSocialBeginGPSViewController alloc] initWithRouteBeginPOI:customerInfo.currentPositionPoi AndEndPOI:self.currentPOI];
//        [self.navigationController pushViewController:vc wantToRemoveViewController:self animated:NO];
//    }];
//
//
//}

- (void)geoLocation {
    [Util showLoadingView];
    self.searchOBJ = [BaseSearchOBJ new];
    self.searchOBJ.geoDelegate = self;
    /// 逆地理编码请求
    NSArray *locationAry = [self.orderInfo.destinationLocation componentsSeparatedByString:@","];
    NSString *longitude = locationAry.firstObject;
    NSString *latitude = locationAry.lastObject;
    [self.searchOBJ reGeoCodeSearchWithLocation:[AMapGeoPoint locationWithLatitude:latitude.floatValue longitude:longitude.floatValue]];
}

- (void)reverseGeocodingResults:(NSArray *)results  {
    [Util hideLoadView];
    if (results == nil || results.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Util toastWithMessage:@"地图服务失败,请稍后再试"];
            [self.navigationController popViewControllerAnimated:YES];
        });
        
        return;
    }
    dispatch_async_on_main_queue(^{
        
        SOSPOI *resultPOI = results[0];
        
//        resultPOI.longitude = @"121.511594";
//        resultPOI.latitude = @"31.143172";
//        resultPOI.name = @"三林(地铁站)";
        
        self.currentPOI = resultPOI;
        
        [self configUI];
    });
}

- (void)changeStatus:(NSString *)statusName success:(void(^)(void))success {
    [Util showHUD];
    [SOSSocialService changeStatusWithParams:@{@"statusName":statusName} success:^{
        [Util dismissHUD];
        !success?:success();
    } Failed:^(NSString * _Nonnull responseStr, NSError * _Nonnull error) {
        [Util showErrorHUDWithStatus:[Util visibleErrorMessage:responseStr]];
        id errorr = [responseStr toBasicObject];
        if ([errorr isKindOfClass:[NSDictionary class]]) {
            
            if ([errorr[@"code"] isEqualToString:@"PICK1001"]||
                [errorr[@"code"] isEqualToString:@"PICK1002"]||
                [errorr[@"code"] isEqualToString:@"PICK1003"]) {
                SOSSocialContactViewController *vc = [[SOSSocialContactViewController alloc] initWithNibName:@"SOSSocialContactViewController" bundle:nil];
                [self.navigationController pushViewController:vc wantToPopRootAnimated:YES];
            }
        }
    }];
}


@end
