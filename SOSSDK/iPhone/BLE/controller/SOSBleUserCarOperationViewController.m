//
//  SOSBleUserCarOperationViewController.m
//  Onstar
//
//  Created by onstar on 2018/7/30.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSBleUserCarOperationViewController.h"
#import "SOSBleUserReceiveShareViewController.h"
#import <BlePatacSDK/BlueToothManager.h>
#import "UIView+Toast.h"
#import "BlueToothManager+SOSBleExtention.h"
#import "UIView+SOSBleToast.h"
#import "SOSBleReconnectStatusView.h"
#import "SOSStatusLoadingView.h"
#import <CMPopTipView/CMPopTipView.h>
#import "SOSBleUtil.h"

@interface SOSBleUserCarOperationViewController ()<CMPopTipViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *operationContentView;
@property (weak, nonatomic) IBOutlet UILabel *vinLabel;
@property (weak, nonatomic) IBOutlet UIView *tipPointView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (nonatomic, strong) CMPopTipView *tipView;
@end

@implementation SOSBleUserCarOperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"蓝牙钥匙";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"收到的共享" style:UIBarButtonItemStylePlain target:self action:@selector(gotoUserReceivePage)];
    
    
    if (self.reConnectBleModel) {
        
        //需先恢复连接
        SOSBleReconnectStatusView *statusView = [SOSBleReconnectStatusView viewFromXib];
        statusView.tag = 888;
        statusView.retryBlock = ^(SOSBleReconnectStatusView *statusView) {
            [self reConnect:statusView];
        };
        [self reConnect:statusView];
    }else {
        
    }
    
    NSString *vin = UserDefaults_Get_Object(bleConnectdbkey);
    
    self.vinLabel.text = [SOSBleUtil recodesign:vin];    
    if ([BlueToothManager sharedInstance].bleOperationVar -> _timer) {
        [self changeStartStatus];
    }
    
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    [notiCenter addObserver:self selector:@selector(receiveBLEMessageNotification:) name:Notification_FUN_RES object:nil];
    [notiCenter addObserver:self selector:@selector(receiveBLEMessageNotification:) name:Notification_FUN_RES_NO object:nil];//Notification_FUN_RES
    
    [notiCenter addObserver:self selector:@selector(changeStartStatus) name:SOSBleTimerNotificationName object:nil];
    [notiCenter addObserver:self selector:@selector(receiveBLEMessageNotification:) name:BLE_CONNECT_Result_Notification object:nil];
}

- (void)lostConnectViewShow:(BOOL)show {
    UIView *statusView = [self.operationContentView viewWithTag:888];
    if (statusView) {
        [self.view hideBleAlert:statusView];
    }
    if (show) {
        SOSBleReconnectStatusView *statusView = [SOSBleReconnectStatusView viewFromXib];
        statusView.tag = 888;
        statusView.retryBlock = ^(SOSBleReconnectStatusView *statusView) {
            [self reConnect:statusView];
        };
        [self.operationContentView showBleAlertView:statusView];
    }
    
}


- (void)reConnect:(SOSBleReconnectStatusView *)statusView {
    statusView.status = RemoteControlStatus_InitSuccess;
    UIView *alertView = [self.operationContentView showBleAlertView:statusView];
    BlueToothManager *manager = [BlueToothManager sharedInstance];
    if (!self.reConnectBleModel) {
        self.reConnectBleModel = manager.bleOperationVar.connectingBleModel;
    }
    [manager connectedWith:self.reConnectBleModel result:^(BlueToothConnState result, CBPeripheral *peripheral, NSError *error) {
        switch (result) {
            case BlueToothConnStateDisconnect:
            case BlueToothConnStateLostconnect:
                self.reConnectBleModel.bConnectStatus = NO;
                statusView.status = RemoteControlStatus_OperateFail;
                break;
            case BlueToothConnAuthenticationOK:
                
                self.reConnectBleModel.bConnectStatus = YES;
                [self.view hideBleAlert:alertView];
                break;
                
    
            default:
                break;
        }
    }];
}


- (void)gotoUserReceivePage {
    [SOSDaapManager sendActionInfo:SmartVehicle_Controlboard_ReceivedCarsharing];
    
    for (id vc  in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[SOSBleUserReceiveShareViewController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            return;
        }
    }
    
    SOSBleUserReceiveShareViewController *vc = [SOSBleUserReceiveShareViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)startButtonTaped:(UIButton *)sender {
    if (self.tipView) {
        [self.tipView dismissAnimated:YES];
        self.tipView = nil;
    }
    sender.selected = !sender.selected;
    UILabel *operationLabel = [sender.superview viewWithTag:11];
    int funcid = 0x13;
    if (sender.selected) {
        funcid = 0x0D;
        operationLabel.text = @"允许启动";
        [[BlueToothManager sharedInstance].bleOperationVar startTimer];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadBleCard" object:@NO];
  
    }else {
        operationLabel.text = @"允许启动";
        [[BlueToothManager sharedInstance].bleOperationVar stopTiming];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadBleCard" object:@YES];
    }
     [self operationWithFunc:funcid operationName:operationLabel.text];
    

}

- (IBAction)operation:(UIButton *)sender {
   

    if (self.tipView) {
        [self.tipView dismissAnimated:YES];
        self.tipView = nil;
    }
    if (sender.tag == 3) {
        [self showTipViewAtView:sender.superview];
    }
    UILabel *operationLabel = [sender.superview viewWithTag:11];
    [self operationWithFunc:(int)sender.tag operationName:operationLabel.text];
    [BlueToothManager sharedInstance].bleOperationVar.operating = YES;
}

- (void)operationWithFunc:(int)func operationName:(NSString *)operationName{
    
    [BlueToothManager bleSendOperation:func];
    BlueToothManager *manager = [BlueToothManager sharedInstance];
        if (![manager isConnected]) {
            [self.view makeToast:@"未连接,点击蓝牙名称连接蓝牙"];
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
    if ([BlueToothManager sharedInstance].bleOperationVar.operating) {
        [Util toastWithMessage:@"您的操作太频繁"];
        return;
    }
    [SOSConvenientStatusLoadingView showStatusLoadingViewInController:self.view
                                                               status:DATA_REFRESH
                                                              message:[NSString stringWithFormat:@"正在为您执行%@操作...",operationName]];
    [manager SendCommand:func result:^(SendState state) {
        if (state ==SendSucessful ) {

            
        }else {
            NSString *operationName = [self operationNameWithCode:func];
            [SOSConvenientStatusLoadingView showStatusLoadingViewInController:self.view
                                                                       status:USER_UPDATE_FAIL
                                                                      message:[NSString stringWithFormat:@"%@操作失败,请稍后重试",operationName]
                                                            dismissAfterDelay:3];
            [BlueToothManager sharedInstance].bleOperationVar.operating = NO;
        }
    }];
}


- (void)receiveBLEMessageNotification:(NSNotification *)noti
{
     [BlueToothManager sharedInstance].bleOperationVar.operating = NO;
    if ([noti.name isEqualToString:Notification_FUN_RES])  //手机测量的RSSI
    {
        NSDictionary *dic = noti.userInfo;
        NSNumber  *data = [dic objectForKey:KEY_FUN_RES_DATA_WORK];
        int code  =  [data intValue];
        [BlueToothManager bleOperationSuccess:code];
        NSString *operationName = [self operationNameWithCode:code];
        [SOSConvenientStatusLoadingView showStatusLoadingViewInController:self.view
                                                                   status:DATA_REFRESH_END
                                                                  message:[NSString stringWithFormat:@"%@操作成功",operationName]
                                                        dismissAfterDelay:3];
        
    }
    else  if ([noti.name isEqualToString:Notification_FUN_RES_NO]) //BLE 发送的RSSI
    {
        NSDictionary *dic = noti.userInfo;
        NSNumber  *data = [dic objectForKey:KEY_FUN_RES_DATA_NOWORK];
        int code  =  [data intValue];
        [BlueToothManager bleOperationFailure:code];
        NSString *operationName = [self operationNameWithCode:code];
        [SOSConvenientStatusLoadingView showStatusLoadingViewInController:self.view
                                                                   status:USER_UPDATE_FAIL
                                                                  message:[NSString stringWithFormat:@"%@操作失败,请稍后重试",operationName]
                                                        dismissAfterDelay:3];
        
    }
    else  if ([noti.name isEqualToString:BLE_CONNECT_Result_Notification])
    {
        NSDictionary *dic = noti.userInfo;
        NSNumber  *data = [dic objectForKey:BLE_CONNECT_Result_KEY];

        if ([data integerValue] == BlueToothConnStateConnected )
        {
            [self lostConnectViewShow:NO];
        }
        else if([data integerValue] == BlueToothConnStateDisconnect)
        {
            [self lostConnectViewShow:YES];
        }
        else if([data integerValue] == BlueToothConnStateLostconnect)
        {
            [self lostConnectViewShow:YES];
        }

    }
}

- (NSString *)operationNameWithCode:(int)code {
    NSString *operationName = @"";
    if(code == 3 )
    {
        operationName = @"车门解锁";
        
        
    }else if(code == 0x0D)
    {
        
        operationName = @"允许启动";
    }
    
    else if(code == 4)
    {
        operationName = @"打开后备箱";
    }
    
    if(code == 1 )
    {
        operationName = @"车门上锁";
    }
    
    
    if(code == 0x13 )
    {
        operationName = @"关闭允许启动";
    }
    return operationName;
}


- (void)changeStartStatus {
    int time = [BlueToothManager sharedInstance].bleOperationVar.seconds;
    NSLog(@"time == %d",time);
    NSString *timeText = @"10:00";
    if (time>0 && [BlueToothManager sharedInstance].bleOperationVar -> _timer) {
        timeText = [NSString stringWithFormat:@"%02d:%02d",time/60,time%60];
    }else if (time <= 0) {
        self.startLabel.text = @"允许启动";
        self.startButton.selected = NO;
        return;
    }
    self.startButton.selected = YES;
    self.startLabel.text = [NSString stringWithFormat:@"允许启动\n%@",timeText];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 显示tipView
 */
- (void)showTipViewAtView:(UIView *)view {
    BOOL hadShowTip = UserDefaults_Get_Bool(@"SOSBleTipKey");
    if (!hadShowTip) {
        UserDefaults_Set_Bool(YES, @"SOSBleTipKey");
        if (nil == self.tipView) {
            self.tipView = [[CMPopTipView alloc] initWithMessage:@"打开开关才能启动车辆哦"];
            self.tipView.delegate = self;
            self.tipView.dismissTapAnywhere = YES;
            self.tipView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
            self.tipView.textColor = [UIColor whiteColor];
            [self.tipView presentPointingAtView:view
                                         inView:self.tipPointView
                                       animated:YES];
        }
    }
}

#pragma mark CMPopTipViewDelegate methods
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    // User can tap CMPopTipView to dismiss it
    self.tipView = nil;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.tipView dismissAnimated:YES];
    self.tipView = nil;
}

@end
