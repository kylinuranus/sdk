//
//  ViewControllerFingerprintpw.m
//  Onstar
//
//  Created by Genie Sun on 16/1/21.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "ViewControllerFingerprintpw.h"
#import "FingerprintDealViewController.h"
#import "InputPinCodeView.h"
#import "SOSCustomAlertView.h"
#import "SOSPinAlertView.h"
#import "SOSBiometricsManager.h"
#import "LoadingView.h"

@interface ViewControllerFingerprintpw ()

@end

@implementation ViewControllerFingerprintpw

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [SOSBiometricsManager isSupportFaceId] ? @"面容 ID 解锁" : @"指纹 ID 解锁";
    
    //判断当前用户是否在此设备开通指纹,如果开通,指纹密码开关打开
    [self updateBiometryAuth];
    
    [_fingerSwitch addTarget:self action:@selector(fingerprintSwitchClick:) forControlEvents:UIControlEventValueChanged];

    self.view.backgroundColor = [UIColor colorWithHexString:@"f5f5f9"];

    self.onstarLb.text = @"启用安吉星指纹密码服务";
    self.onstarLb.adjustsFontSizeToFitWidth = YES;
    self.openFingerLb.text = @"可用于登录及代替服务密码执行车辆服务";
    self.openFingerLb.adjustsFontSizeToFitWidth = YES;
//    self.fingerUnlock.text = @"指纹密码";
    self.fingerprintIcon.centerX = self.view.centerX;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enterDeal)];
    self.agreementLabel.userInteractionEnabled = YES;
    [self.agreementLabel addGestureRecognizer:tap];
    
    if ([SOSBiometricsManager isSupportFaceId]) {
        _fingerprintIcon.image = [UIImage imageNamed:@"faceid1"];
        _onstarLb.text = @"启用安吉星面容密码服务";
//        _fingerUnlock.text = @"面容 ID 解锁";
//        _cellIcon.image = [UIImage imageNamed:@"faceID"];
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:@"面容 ID 仅对本机有效\n开通即视为同意" attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor], NSFontAttributeName:[UIFont systemFontOfSize:13]}];
        NSAttributedString *attr2 = [[NSAttributedString alloc] initWithString:@"《面容 ID 服务协议》" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithHexString:@"468DDD"], NSFontAttributeName:[UIFont systemFontOfSize:13]}];
        [attr appendAttributedString:attr2];
        _agreementLabel.attributedText = attr;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBiometryAuth) name:UIApplicationWillEnterForegroundNotification object:nil];

}


#pragma mark - 指纹密码开关点击
- (void)fingerprintSwitchClick:(UISwitch *)sw     {
    // Switch保留原来的状态
    dispatch_async(dispatch_get_main_queue(), ^{
        sw.on = !sw.on;
    });
    [SOSBiometricsManager showBiometricsWithSuccessBlock:^{
        
        if ([[LoginManage sharedInstance] needVerifyPin]) {
            // 未输入过pinCode 直接跳转到输入PIN码界面
            dispatch_async_on_main_queue(^{
                [self createPinCodeController:FINGERPRINT_PIN_REQUEST isHornFlash:NO];
            });
        } else {
            [self switchSuccess];
            [SOSDaapManager sendActionInfo:Fingerprint_open];
        }
    } errorBlock:^(NSError *error) {
        switch (error.code) {
            case LAErrorUserCancel:
            case LAErrorUserFallback:
                [SOSDaapManager sendActionInfo:Fingerprint_close];
                break;
            case LAErrorAuthenticationFailed:
                [Util showAlertWithTitle:NSLocalizedString(@"FingerprintVerifyFailed", @"") message:nil completeBlock:nil];
                
                break;
        }
    }];
}


- (void)createPinCodeController:(NSString *)type isHornFlash:(BOOL)isHornFlashSelected     {
    @weakify(self);
    SOSPinAlertView *alertView = [SOSPinAlertView pinAlertView];
    alertView.phoneFuncId = register_notification_servicepin_call;
    [alertView show];
    alertView.confirm = ^(NSString *inputPwd, BOOL flashSelected, BOOL hornSelected) {
        @strongify(self);
        NSLog(@"密码是%@,%d,%d",inputPwd,flashSelected, hornSelected);
        if (![inputPwd isLegalPinCode]) {
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"pinCodeIsNull", @"") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ac0 = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK",@"") style:UIAlertActionStyleCancel handler:nil];
            [ac addAction:ac0];
            [ac show];
            return;
        }
        
        [[LoadingView sharedInstance] startIn:self.view];
        __block NSString *verifyPinResult;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            verifyPinResult = [[LoginManage sharedInstance] upgradeToken:inputPwd];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[LoadingView sharedInstance] stop];
                if ([verifyPinResult isEqualToString:@"0"])	 		{
                    [self switchSuccess];
                } else if([verifyPinResult isEqualToString:@"1"])	{
                    [Util showAlertWithTitle:nil message:NSLocalizedString(@"L7_304", @"") completeBlock:nil];
                } else if([verifyPinResult isEqualToString:@"2"]) 	{
                    [Util showAlertWithTitle:nil message:NSLocalizedString(@"L7_305", @"") completeBlock:nil];
                }	else											{
                    [Util showAlertWithTitle:nil message:verifyPinResult completeBlock:nil];
                }
            });
        });
        
    };    
}


- (void)switchSuccess {
    BOOL switchStatusValue = !_fingerSwitch.isOn;
    [SOSBiometricsManager updateBiometricsState:switchStatusValue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _fingerSwitch.on = switchStatusValue;
        [self.navigationController popToViewController:self animated:YES];
        [self toastSuccess];
    });
}

- (void)updateBiometryAuth {
    BOOL isOpen = [SOSBiometricsManager isUserOpenBiometriesAuthentication];
    _fingerSwitch.on = isOpen;
}

- (void)enterDeal{
    FingerprintDealViewController *pincode = [[FingerprintDealViewController alloc] init];
    [self.navigationController pushViewController:pincode animated:YES];
}


- (void)toastSuccess    {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 155, 155)];
        bgView.centerX = SCREEN_WIDTH / 2;
        bgView.centerY = SCREEN_HEIGHT /2;
        bgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"finger_success"]];
        bgView.userInteractionEnabled = NO;
        bgView.layer.masksToBounds = YES;
        bgView.layer.cornerRadius = 4;
        
        UIWindow *window = SOS_ONSTAR_WINDOW;
        dispatch_async(dispatch_get_main_queue(), ^{
            [window addSubview:bgView];
            [UIView animateWithDuration:1 animations:^{
                bgView.alpha = 0;
            } completion:^(BOOL finished) {
                [bgView removeFromSuperview];
            }];
        });
    });
}

- (void)dealloc{
    [SOSDaapManager sendActionInfo:Fingerprint_back];
    [[LoginManage sharedInstance] nextPopViewAction];
}

@end
