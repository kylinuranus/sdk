//
//  ThreeDToucManager.m
//  Onstar
//
//  Created by Apple on 16/12/13.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "ThreeDToucManager.h"
#import "SOSCardUtil.h"
#import "SOSCheckRoleUtil.h"
#import "SOSHomeAndCompanyTool.h"
#import "ServiceController.h"
#import "SOSRemoteTool.h"
#if __has_include("SOSSDK.h")
#import "SOSSDK.h"
#endif

@implementation ThreeDToucManager

+ (void)config3DTouch   {
    
    float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (sysVer < 9.0) {
        return;
    }
    UIApplicationShortcutIcon *iconEasyBackHome = [UIApplicationShortcutIcon iconWithTemplateImageName:@"3D_Touch_一键到家"];
    UIApplicationShortcutIcon *iconEasyBackCompany = [UIApplicationShortcutIcon iconWithTemplateImageName:@"3D_Touch_一键到公司"];
    UIApplicationShortcutIcon *iconLockCar = [UIApplicationShortcutIcon iconWithTemplateImageName:@"3D_Touch_车门上锁"];
    UIApplicationShortcutIcon *iconUnLockCar = [UIApplicationShortcutIcon iconWithTemplateImageName:@"3D_Touch_车门解锁"];
    
    // create 4 (dynamic) shortcut items
    
    UIMutableApplicationShortcutItem *itemEasyBackHome = [[UIMutableApplicationShortcutItem alloc] initWithType:ShortCutTypeEasyBackHome localizedTitle:NSLocalizedString(@"Quick_go_home", nil) localizedSubtitle:nil icon:iconEasyBackHome userInfo:nil];
    UIMutableApplicationShortcutItem *itemEasyBackCompany = [[UIMutableApplicationShortcutItem alloc] initWithType:ShortCutTypeEasyBackCompany localizedTitle:NSLocalizedString(@"Quick_go_to_office", nil) localizedSubtitle:nil icon:iconEasyBackCompany userInfo:nil];
    UIMutableApplicationShortcutItem *itemLockCar = [[UIMutableApplicationShortcutItem alloc] initWithType:ShortCutTypeLockDoor localizedTitle:NSLocalizedString(@"remoteLockButtonTitle", nil) localizedSubtitle:nil icon:iconLockCar userInfo:nil];
    UIMutableApplicationShortcutItem *itemUnLockCar = [[UIMutableApplicationShortcutItem alloc] initWithType:ShortCutTypeUnlockDoor localizedTitle:NSLocalizedString(@"remoteUnlockButtonTitle", nil) localizedSubtitle:nil icon:iconUnLockCar userInfo:nil];
    
    [UIApplication sharedApplication].shortcutItems = @[itemUnLockCar, itemLockCar, itemEasyBackCompany, itemEasyBackHome];
}

+ (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
#if __has_include("SOSSDK.h")
     [SOSSDK sos_showOnstarModuleWithDismissBlock:nil];
#endif
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
    
    if ([[LoginManage sharedInstance] isLoadingMainInterfaceReady]) {
        if ([shortcutItem.type isEqualToString:ShortCutTypeEasyBackHome]) {
            [[SOSHomeAndCompanyTool sharedInstance] EasyGoHomeFromVC:[Util currentNavigationController].topViewController WithType:pageTypeEasyBackHome];
            
        }   else if ([shortcutItem.type isEqualToString:ShortCutTypeEasyBackCompany])    {
            [[SOSHomeAndCompanyTool sharedInstance] EasyGoHomeFromVC:[Util currentNavigationController].topViewController WithType:pageTypeEasyBackCompany];
            
        }   else if ([shortcutItem.type isEqualToString:ShortCutTypeLockDoor])    {
//            if ([SOSCheckRoleUtil isDriverOrProxy] && ![ThreeDToucManager isAuthorizedByOwner]) {
//                return;
//            }
            [SOSCardUtil routerToRemoteControl];
            [[SOSRemoteTool sharedInstance] startOperationWithOperationType:SOSRemoteOperationType_LockCar];
            
        }   else if ([shortcutItem.type isEqualToString:ShortCutTypeUnlockDoor])    {
//            if (![ThreeDToucManager isAuthorizedByOwner]) {
//                return;
//            }
            [SOSCardUtil routerToRemoteControl];
            [[SOSRemoteTool sharedInstance] startOperationWithOperationType:SOSRemoteOperationType_UnLockCar];
        
        }
    }else{
        if ([LoginManage sharedInstance].loginState == LOGIN_STATE_NON) {
            //[[SOSReportService shareInstance] recordActionWithFunctionID:Home_LoginRegister];
            [[LoginManage sharedInstance] presentLoginNavgationController:[Util currentNavigationController].topViewController];
        }else{
            if ([[LoginManage sharedInstance] isInLoadingMainInterface]) {
                [Util toastWithMessage:NSLocalizedString(@"ConnectingVehicle", nil)];
            }else{
                [Util toastWithMessage:@"数据异常"];
            }
        }
    }
    });
}

//+ (BOOL)isAuthorizedByOwner{
//    if ([CustomerInfo sharedInstance].carSharingFlag) {
//        return YES;
//    }else{
//        //未被授权
//        [Util showToastViewTitle:NSLocalizedString(@"carSharingUnAuthorized", nil) detailTitle:nil backgroundColor:[UIColor colorWithHexString:@"fc7a7a"] showTime:3.0];
//        return NO;
//    }
//}

@end
