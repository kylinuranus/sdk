//
//  SOSBlePinUtil.m
//  Onstar
//
//  Created by onstar on 2018/11/11.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSBlePinUtil.h"
#import "SOSPinAlertView.h"
#import "SOSPinContentView.h"

@implementation SOSBlePinUtil

//弹出PIN验证页面(登录后)，验证pin码但不做车辆操作，比如enroll验证pin
+ (void)checkPINCodeSuccess:(void (^)(void))success {
    if ([[LoginManage sharedInstance] needVerifyPin]) {
        [self pinAlertViewWithErrorMsg:nil comPleteBlock:^(NSString *inputPwd, BOOL flashSelected, BOOL hornSelected) {
            if (success)     success();
        }];
    }    else    {
        if (success)     success();
    }
    
}


+ (void)pinAlertViewWithErrorMsg:(NSString *)errorMsg comPleteBlock:(void(^)(NSString *inputPwd, BOOL flashSelected, BOOL hornSelected))confirm {
    SOSPinContentView *testView = [SOSPinContentView viewFromXib];
    
    testView.pinType = SOSPinTypePassword;
    testView.errorMsg = errorMsg;
    
    SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:nil title:@"服务密码" message:nil customView:testView preferredStyle:SOSAlertControllerStyleAlert];
    
    SOSAlertAction *action = [SOSAlertAction actionWithTitle:@"取消" style:SOSAlertActionStyleDefault handler:nil];
    [vc addActions:@[action]];
    @weakify(vc)
    testView.didCompleteInputBlock = ^(NSString * _Nonnull pinCode, SOSPinContentView * _Nonnull pinView) {
        @strongify(vc)
        [vc dismissViewControllerAnimated:YES completion:^{
            [self upgradeTokenWithInputPwd:pinCode Success:^{
                !confirm?:confirm(pinCode,NO,NO);
            } Failure:^(NSString *err) {
                [self pinAlertViewWithErrorMsg:err comPleteBlock:confirm];
            }];
        }];
    };
    [vc show];
}

#pragma mark - 更新 Token, PIN 网络校验

+ (void)upgradeTokenWithInputPwd:(NSString *)pwd Success:(void (^)(void))success Failure:(void (^)(NSString *))failure    {
    dispatch_async_on_main_queue(^{
        [Util showHUDWithStatus:nil];
    });
    
    NSString *inputPwd = pwd.length ? pwd : [LoginManage sharedInstance].pinCode;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSString *verifyPinResult = [[LoginManage sharedInstance] upgradeToken:inputPwd];
        dispatch_async_on_main_queue(^(){
            [Util dismissHUD];
            NSString *alertMessage = nil;
            if (verifyPinResult.length != 1)    {
                alertMessage = [Util visibleErrorMessage:verifyPinResult];
                verifyPinResult = @"9";
            }
            switch (verifyPinResult.intValue) {
                case SOSVerifyPinResultCode_Success:
                    if (success)    success();
                    return;
                case SOSVerifyPinResultCode_Fail:
                    alertMessage = NSLocalizedString(@"L7_304", @"");
                    break;
                case SOSVerifyPinResultCode_Lock:
//                    alertMessage = NSLocalizedString(@"L7_305", @"");
                    alertMessage = @"安吉星密码已输错10次，你的车辆分享功能将被锁定10分钟，请稍后再试";
                    break;
                default:
                    break;
            }
            if (alertMessage) {
                if (verifyPinResult.intValue == SOSVerifyPinResultCode_Lock) {
//                    [Util showAlertWithTitle:nil message:alertMessage completeBlock:nil];
                    [Util showAlertWithTitle:nil message:alertMessage confirmBtn:@"知道了" completeBlock:nil];
                }else {
                    if (failure)    failure(alertMessage);
                }
            }
        });
        
    });
}




@end
