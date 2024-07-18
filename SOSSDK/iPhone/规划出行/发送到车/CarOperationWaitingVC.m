//
//  CarOperationWaitingVC.m
//  Onstar
//
//  Created by Coir on 16/3/21.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "SOSLBSPOISendSuccessVC.h"
#import "CarOperationWaitingVC.h"
#import "SOSCarOpeWaitingView.h"
#import "ServiceController.h"
#import "SOSCheckRoleUtil.h"
#import "SOSSearchResult.h"
#import "AppPreferences.h"
#import "SOSRemoteTool.h"
#import "CustomerInfo.h"

@interface CarOperationWaitingVC () {
    
    BOOL sendToTBT;
    BOOL needNotice;
    
}

@property (nonatomic, weak) UIViewController *fromVC;
@property (nonatomic, strong) SOSPOI *poi;


@property (strong, nonatomic) SOSCarOpeWaitingView *waitingView;


@end

@implementation CarOperationWaitingVC

+ (CarOperationWaitingVC *)initWithPoi:(SOSPOI *)poi Type:(OrderType)type FromVC:(UIViewController *)vc    {
    CarOperationWaitingVC *waitVC = [[CarOperationWaitingVC alloc] init];
    waitVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    if (type == OrderTypeAuto) {
        if ([Util vehicleIsIcm]) {
            waitVC.orderType = OrderTypeODD;
        }   else    {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:IS_SENDING_ODD_First_REQUEST]) waitVC.orderType = OrderTypeODD;
            else        waitVC.orderType = OrderTypeTBT;
        }
    }   else        waitVC.orderType = type;
    waitVC.fromVC = vc;
    waitVC.poi = poi;
    return waitVC;
}

+ (instancetype)sharedInstance  {
    static CarOperationWaitingVC *vc = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        vc = [[CarOperationWaitingVC alloc] init];
    });
    return vc;
}

- (void)checkAndShowFromVC:(UIViewController *)vc    {
    [self checkAndShowFromVC:vc needToastMessage:NO needShowWaitingVC:YES completion:^{ }];
}

- (void)checkAndShowFromVC:(UIViewController *)vc needToastMessage:(BOOL)needToast needShowWaitingVC:(BOOL)needShowVC completion:(void (^)(void))completion    {
    //检测登录状态
    [[LoginManage sharedInstance] setIllegalWarningBackHomePage:YES];
    [[LoginManage sharedInstance] checkAndShowRefreshWarningAlertFromViewCtr:vc withLoginDependence:[[LoginManage sharedInstance] isLoadingMainInterfaceReadyOrUnlogin]  showConnectVehicleAlertDependence:[[LoginManage sharedInstance] isInLoadingMainInterface] completion:^(BOOL finished) {
        {
            if (finished) {
                //检查角色
                if (![SOSCheckRoleUtil checkVisitorInPage:vc])                           return;
                //检测包是否过期
                if([SOSCheckRoleUtil checkPackageExpired:vc])                           return;
                //检测包是否有效
                NSString * command ;
                if (self.orderType == OrderTypeTBT) {
                    command = PP_Tbt;
                }else{
                    command = PP_Odd;
                }
                if (![SOSCheckRoleUtil checkPackageServiceAvailable:command])     return;

                
                needNotice = needToast;
                //检测车辆是否可以执行操作
                if (self.orderType == OrderTypeTBT) {
                    if (![[ServiceController sharedInstance] canPerformRequest:SEND_TO_TBT_REQUEST])    return;
                }   else if (self.orderType == OrderTypeODD)   {
                    if (![[ServiceController sharedInstance] canPerformRequest:SEND_TO_NAV_REQUEST])    return;
                }
                if (completion) completion();
                if (needShowVC) {
                    [vc presentViewController:self animated:YES completion:nil];
                }   else    {
                    //发送指令
                    if (self.orderType == OrderTypeTBT) {
                        [self sendToTBT];
                    }   else if (self.orderType == OrderTypeODD)   {
                        [self sendToODD];
                    }
                }
            }
        }
    }];
    
}

- (void)viewDidLoad     {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [self configSelf];
    _waitingView.status = StatusLoading;
    if (self.orderType == OrderTypeVehicleLocation) {
        _waitingView.prompt = @"正在获取车辆位置，请稍候";
        return;
    }   else if (self.orderType == OrderTypeTBT) {
        _waitingView.prompt = @"路线正在下发\n请耐心等待1-3分钟";
    }   else if (self.orderType == OrderTypeODD)   {
        _waitingView.prompt = @"目的地正在下发\n请耐心等待1-3分钟";
    }
    [[LoginManage sharedInstance] checkAndShowLoginViewWithFromViewCtr:self andTobePushViewCtr:nil completion:^(BOOL finished) {
        if (finished) {
            if (self.orderType == OrderTypeTBT) 		[self sendToTBT];
            else if (self.orderType == OrderTypeODD)  	[self sendToODD];
        }
    }];
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOS_VEHICLE_OPERATE_NOTIFICATION object:nil] subscribeNext:^(NSNotification *x) {
        NSDictionary *userInfo = x.userInfo;
        //        @{@"state":@(RemoteControlStatus_InitSuccess), @"OperationType" : @(type) , @"message": message}
        SOSRemoteOperationType operationType = [userInfo[@"OperationType"] intValue];
        if ([SOSRemoteTool isSendPOIOperation:operationType]) {
            RemoteControlStatus state = [userInfo[@"state"] intValue];
            switch (state) {
                case RemoteControlStatus_InitSuccess:
                    break;
                case RemoteControlStatus_OperateSuccess:
                    [self buttonKnownTapped];
                    break;
                case RemoteControlStatus_OperateTimeout:
                case RemoteControlStatus_OperateFail:
                    [self buttonKnownTapped];
                    break;
                default:
                    break;
            }
        }
    }];
}

- (void)configSelf  {
    _waitingView = [SOSCarOpeWaitingView new];
    [self.view addSubview:_waitingView];
    [_waitingView mas_makeConstraints:^(MASConstraintMaker *make){
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(270, 340));
    }];
    __weak __typeof(self)weakSelf = self;
    _waitingView.doneBtnClicked = ^{
        [weakSelf buttonKnownTapped];
    };

}

- (IBAction)buttonKnownTapped    {
    if (self.orderType == OrderTypeODD || self.orderType == OrderTypeTBT) {
        if (self.poi.sosPoiType == POI_TYPE_LBS) {
            [SOSDaapManager sendActionInfo:LBS_list_deviceinfo_sendwait_iknow];
        } else {
            [SOSDaapManager sendActionInfo:Map_sendtocarsuccess_iknow];
        }
    }
    if (self.fromVC) {
        [self.fromVC.navigationController popToViewController:self.fromVC animated:NO];
        [self dismissViewControllerAnimated:YES completion:nil];
    }   else    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark 发送到车
- (void)sendToTBT      {
    [[SOSRemoteTool sharedInstance] sendToCarWithOperationType:SOSRemoteOperationType_SendPOI_TBT AndPOI:self.poi];
}

- (void)sendToODD     {
    [[SOSRemoteTool sharedInstance] sendToCarWithOperationType:SOSRemoteOperationType_SendPOI_ODD AndPOI:self.poi];
}

- (void)dealloc		{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
