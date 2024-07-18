//
//  SOSBiometricsManager.m
//  Onstar
//
//  Created by TaoLiang on 2017/11/9.
//  Copyright © 2017年 onStar. All rights reserved.
//

#import "SOSBiometricsManager.h"
#import "SOSKeyChainManager.h"
#import "ChooseFingerView.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface SOSBiometricsManager()

@end

@implementation SOSBiometricsManager

+ (BOOL)isSupportBiometrics {
//    if (!SOS_ONSTAR_PRODUCT) {
//        return NO;
//    }
    BOOL isSupport = NO;
    LAContext *context = [self buildContext];
    isSupport = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
    return isSupport;
}

+ (BOOL)isSupportTouchId {
    if (@available(iOS 11.0, *)) {
        LAContext *context = [self buildContext];
        if (context.biometryType == LABiometryNone) {
            [self isSupportBiometrics];
        }
        return context.biometryType == LABiometryTypeTouchID;
    } else {
        // Fallback on earlier versions
        return [self isSupportBiometrics];
    }
}

+ (BOOL)isSupportFaceId {
    if (@available(iOS 11.0, *)) {
        LAContext *context = [self buildContext];
        if (context.biometryType == LABiometryNone) {
            [self isSupportBiometrics];
        }
        return context.biometryType == LABiometryTypeFaceID;
    } else {
        // Fallback on earlier versions
        return NO;
    }
}

+ (BOOL)isUserOpenBiometriesAuthentication {
    BOOL isOpen = [[SOSKeyChainManager readFingerPrint:[CustomerInfo sharedInstance].userBasicInfo.idpUserId] boolValue];
    if (isOpen) {
        LAContext *context = [self buildContext];
        //判断一次用户是否在设置中关闭了生物密码，和App内保持同步
        if (![context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
            //关闭用户的指纹密码开关
            [SOSKeyChainManager saveFingerprintOpenByidpid:[CustomerInfo sharedInstance].userBasicInfo.idpUserId withSwitch:NO];
            return NO;
        }else {
            return YES;
        }
    }else {
        return NO;
    }
}

+ (void)updateBiometricsState:(BOOL)isOpen {
    [SOSKeyChainManager saveFingerprintOpenByidpid:[CustomerInfo sharedInstance].userBasicInfo.idpUserId withSwitch:isOpen];
}

+ (BOOL)shouldRemindUserOpenBiometricsAlert:(void (^)(void))chooseToOpen inputPinCode:(void (^)(void))inputPinCode {
//    9.0改版暂时去掉
//    !inputPinCode ? : inputPinCode();
//    return NO;
    //1.判断设备是否支持生物认证
    BOOL isSupportBiometrics = [SOSBiometricsManager isSupportBiometrics];
    if (!isSupportBiometrics) {
        !inputPinCode ? : inputPinCode();
        return NO;
    }
    //2.判断用户是否在app中打开了生物认证
    BOOL isUserOpenBiometriesAuthentication = [SOSBiometricsManager isUserOpenBiometriesAuthentication];
    if (isUserOpenBiometriesAuthentication) {
        !inputPinCode ? : inputPinCode();
        return NO;
    }
    //3.判断是否已提醒过用户打开生物认证功能
    BOOL shouldReminded = [[NSUserDefaults standardUserDefaults] boolForKey:TIP_OPEN_FINGER];
    if (!shouldReminded) {
        !inputPinCode ? : inputPinCode();
        return NO;
    }
    //4.同步提醒标记信息
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:TIP_OPEN_FINGER];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //5.显示提醒alert
//    ChooseFingerView *chooseFinger = [[ChooseFingerView alloc]init];
//    chooseFinger.openFingerView = ^(BOOL flag) {
        //选择了未设置，去个人中心开通
        chooseToOpen();
//    };
//    chooseFinger.openPINCodeView = ^(BOOL flag) {
//        //选择进入PIN页面
//        inputPinCode();
//    };
//    [chooseFinger show];
    return YES;
}

+ (void)showBiometricsWithSuccessBlock:(BiometricsSuccessBlock)successBlock errorBlock:(BiometricsErrorBlock)errorBlock {
    NSString *localizedReason = NSLocalizedString(@"FingerprintPasswordVerifyTouchIDMsg", nil);
    [SOSBiometricsManager showBiometricsWithLocalizedReason:localizedReason SuccessBlock:successBlock errorBlock:errorBlock];
}

+ (void)showBiometricsWithLocalizedReason:(NSString *)reason SuccessBlock:(BiometricsSuccessBlock)successBlock errorBlock:(BiometricsErrorBlock)errorBlock {
    if (reason.length <= 0) {
        reason = NSLocalizedString(@"FingerprintPasswordVerifyTouchIDMsg", nil);
    }
    LAContext *context = [self buildContext];
    context.localizedFallbackTitle = @"";
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:reason reply:^(BOOL success, NSError * _Nullable error) {
        if (error.code == LAErrorBiometryLockout || error.code == LAErrorTouchIDLockout) {
            BOOL can = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error];
            if (can) {
                [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:reason reply:^(BOOL success, NSError * _Nullable error) {        }];
            }
        }
        dispatch_async_on_main_queue(^{
            if (success) {
                NSLog(@"生物识别通过");
                if (successBlock)    successBlock();
            }    else {
                if (errorBlock)     errorBlock(error);
            }
            
        });
    }];
    
}

#pragma mark - private
/**
 LAContext的biometryType必须先调用canEvaluatePolicy才可以获得正确的值
 @return LAContext instance
 */
+ (LAContext *)buildContext {
    LAContext *context = [LAContext new];
    [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
    return context;
}

@end
