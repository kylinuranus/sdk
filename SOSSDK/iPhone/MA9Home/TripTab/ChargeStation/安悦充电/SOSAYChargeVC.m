//
//  SOSAYChargeVC.m
//  Onstar
//
//  Created by Coir on 2018/10/24.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "LoadingView.h"
#import "SOSAYChargeVC.h"
#import "SOSScanChargeVC.h"
#import "SOSAYChargeManager.h"
#import "SOSCustomAlertView.h"
#import "SOSAYChargeInstrustionVC.h"

@interface SOSAYChargeVC ()

@property (nonatomic, copy) NSString *sessionID;
@property (weak, nonatomic) IBOutlet UIButton *chargeButton;
@property (weak, nonatomic) IBOutlet UIButton *instructionButton;

@end

@implementation SOSAYChargeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = NO;
    self.backDaapFunctionID = JoyLife_anyocharging_Back;
    [self.chargeButton setImage:[UIImage imageNamed:@"btn_icon_chongdian _100x100"] forState:UIControlStateSelected | UIControlStateHighlighted];
    self.title = @"扫码充电";
    // 充电使用说明增加下划线
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:self.instructionButton.currentTitle];
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [str length])];
    [self.instructionButton setAttributedTitle:str forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated	{
    [super viewWillAppear:animated];
    if ([SOSAYChargeManager checkUserPhoneNum]) {
        [self userLoginAYSys];
    }
}


- (void)userLoginAYSys		{
    [[LoadingView sharedInstance] startIn:self.view];
    if ([CustomerInfo sharedInstance].aySessionID.length) {
        self.sessionID = [CustomerInfo sharedInstance].aySessionID;
        [self checkAYUserState];
    }	else	{
        [SOSAYChargeManager loginAYSystemSuccess:^(SOSNetworkOperation *operation, NSString *sessionID) {
            self.sessionID = sessionID;
            [CustomerInfo sharedInstance].aySessionID = sessionID;
            [self checkAYUserState];
        } failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            [[LoadingView sharedInstance] stop];
            dispatch_async_on_main_queue(^{
                SOSCustomAlertView *view = [[SOSCustomAlertView alloc] initWithTitle:@"加载失败" detailText:@"读取数据失败，请稍后重试" cancelButtonTitle:@"知道了" otherButtonTitles:nil canTapBackgroundHide:YES];
                view.buttonMode = SOSAlertButtonModelVertical;
                view.tapGesDismissHandle = ^{
                    [self.navigationController popViewControllerAnimated:YES];
                };
                view.buttonClickHandle = ^(NSInteger clickIndex) {
                    [self.navigationController popViewControllerAnimated:YES];
                };
                [view show];
            });
        }];
    }
}

- (void)checkAYUserState	{
    [SOSAYChargeManager checkAYUserOrderWithSessionID:[CustomerInfo sharedInstance].aySessionID Success:^(SOSNetworkOperation *operation, NSString *existFlag) {
        [[LoadingView sharedInstance] stop];
        dispatch_async_on_main_queue(^{
            // 不在充电状态
            if (existFlag.intValue == 1)  {
                self.chargeButton.selected = NO;
                //如果有外部传入的二维码，在这里跳转
                if (_code.length > 0) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self jumpToThirdAYUnlockChargeStationPage:_code];
                        _code = nil;
                    });
                    return;
                }
            }    else if (existFlag.intValue == 2)    {
                self.chargeButton.selected = YES;
            }
        });
    } failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [[LoadingView sharedInstance] stop];
        [Util toastWithMessage:@"responseStr"];
    }];
}


/// 扫码充电
- (IBAction)scanButtonTapped {
    if (self.chargeButton.isSelected) {
        [SOSAYChargeManager checkNetworkSuccess:^(NSInteger status)    {
            if (status) {
                NSString *url = [SOSAYChargeH5HeaderURL stringByAppendingFormat:SOSAYChargeURL_Order_Detail, self.sessionID];
                SOSWebViewController *webVC = [[SOSWebViewController alloc] initWithUrl:url];
                
                [self.navigationController pushViewController:webVC animated:YES];
            }
        }];
    }	else	{
        [SOSDaapManager sendActionInfo:JoyLife_anyocharging_Scan];
        SOSScanChargeVC *vc = [SOSScanChargeVC new];
//        vc.sessionID = self.sessionID;
        vc.scanCompleteBlock = ^(NSString * _Nonnull str) {
            [self jumpToThirdAYUnlockChargeStationPage:str];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
}

/// 用户余额
- (IBAction)userBalanceButtonTapped		{
    [SOSDaapManager sendActionInfo:JoyLife_anyocharging_AccountBalance];
    [SOSAYChargeManager checkNetworkSuccess:^(NSInteger status)    {
        if (status) {
            NSString *url = [SOSAYChargeH5HeaderURL stringByAppendingFormat:SOSAYChargeURL_Wallte, self.sessionID];
            SOSWebViewController *webVC = [[SOSWebViewController alloc] initWithUrl:url];
            webVC.shouldShowCloseButton = YES;
            [self.navigationController pushViewController:webVC animated:YES];
        }
    }];
}

/// 历史订单
- (IBAction)historyOrderButtonTapped {
    [SOSDaapManager sendActionInfo:JoyLife_anyocharging_OrderHistory];
    [SOSAYChargeManager checkNetworkSuccess:^(NSInteger status)    {
        if (status) {
            NSString *url = [SOSAYChargeH5HeaderURL stringByAppendingFormat:SOSAYChargeURL_Order_History, self.sessionID];
            SOSWebViewController *webVC = [[SOSWebViewController alloc] initWithUrl:url];
            webVC.shouldShowCloseButton = YES;
            [self.navigationController pushViewController:webVC animated:YES];
        }
    }];
}

/// 充电使用说明
- (IBAction)chargeInstrustionButtonTapped {
    [SOSDaapManager sendActionInfo:JoyLife_anyocharging_OperatingManual];
    SOSAYChargeInstrustionVC *vc = [SOSAYChargeInstrustionVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToThirdAYUnlockChargeStationPage:(NSString *)code {
    
    NSString *url = [SOSAYChargeH5HeaderURL stringByAppendingFormat:SOSAYChargeURL_UNLOCK, self.sessionID, code];
    SOSWebViewController *webVC = [[SOSWebViewController alloc] initWithUrl:url];
    webVC.shouldShowCloseButton = YES;
    [self.navigationController pushViewController:webVC animated:YES];
    [self clearNavVCWithClassNameArray:@[@"SOSScanChargeVC"]];

}

@end
