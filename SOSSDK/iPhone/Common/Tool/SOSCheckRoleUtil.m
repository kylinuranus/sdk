//
//  SOSCheckRoleUtil.m
//  Onstar
//
//  Created by shoujun xue on 2/11/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import "SOSCardUtil.h"
#import "CustomerInfo.h"
#import "PurchaseModel.h"
#import "AppPreferences.h"
#import "SOSCheckRoleUtil.h"
#import "SOSNetworkOperation.h"
#import "OwnerViewController.h"

@interface SOSCheckRoleUtil()
@end

@implementation SOSCheckRoleUtil

+ (BOOL)isOwner {
    return [[self lowercaseRoleString] isEqualToString:ROLE_OWNER];
}

+ (BOOL)isVisitor {
    return [[self lowercaseRoleString] isEqualToString:ROLE_VISITOR];
}

+ (BOOL)isDriverOrProxy {
    NSString *role = [self lowercaseRoleString];
    return [role isEqualToString:ROLE_DRIVER] || [role isEqualToString:ROLE_PROXY];
}

+ (BOOL)isDriver {
    return [[self lowercaseRoleString] isEqualToString:ROLE_DRIVER];

}

+ (BOOL)isProxy {
    return [[self lowercaseRoleString] isEqualToString:ROLE_PROXY];
}

+ (BOOL)checkVisitorInPage:(UIViewController *)page     {
    if([SOSCheckRoleUtil isVisitor]) {

        [Util showAlertWithTitle:@"请升级为车主" message:nil completeBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [SOSCardUtil routerToUpgradeSubscriber];
            }
        } cancleButtonTitle:@"取消" otherButtonTitles:@"立即绑定车辆", nil];
        return NO;
        
    }
    return YES;
}

///  unlogin(未登录)、visitor（访客）、owner（车主）、proxy（代理）、driver(司机)。
+ (NSString *)getCurrentRole	{
    if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
        return [self lowercaseRoleString];
    }	else	{
        return @"unlogin";
    }
}

+ (BOOL)checkDriverProxyInPage:(UIViewController *)page     {
    if([SOSCheckRoleUtil isDriverOrProxy]) {
        [Util showAlertWithTitle:@"无使用权限" message:@"您不是车主，暂无法使用该功能" completeBlock:nil cancleButtonTitle:nil otherButtonTitles:@"知道了", nil];
        return NO;
    }
    return YES;
}

+ (BOOL)checkPackageExpired:(UIViewController *)controller{
    
    if( [Util show23gPackageDialog]){//是2g3g用户弹完提示框,流程就结束了
        return YES;
    }

    if ([CustomerInfo sharedInstance].isExpired) {
        [Util showAlertWithTitle:nil message:NSLocalizedString(@"SB001_MSG005", @"您的安吉星服务套餐已过期，是否现在续约？若您已续约安吉星服务套餐，请尝试重新登录或联系安吉星客服。") completeBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1){
                [PurchaseModel sharedInstance].purchaseType = PurchaseTypePackage;
                [SOSCardUtil routerToBuyOnstarPackage:PackageType_Core];
            }
        } cancleButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Purchase", nil), nil];
        return YES;
    }
    return NO;

}

+ (BOOL)checkPackageServiceAvailable:(NSString *)serviceIndicator     {
    return [self checkPackageServiceAvailable:serviceIndicator andNeedPopError:YES];
}


+ (BOOL)checkPackageServiceAvailable:(NSString *)serviceIndicator andNeedPopError:(BOOL)needPop     {
    SOSVehiclePrivilege * pri = [CustomerInfo sharedInstance].vehicleServicePrivilege;
    if (!serviceIndicator.isNotBlank) {
        return NO;
    }
    NSNumber * avi = ([pri valueForKey:serviceIndicator]);
    if (avi.boolValue){
      return YES;
    }else{
        // 除非CDM返回该服务不可用，否则都可用
        if (needPop) {
            [Util showAlertWithTitle:nil message:@"您的当前套餐不含此功能，如需升级请拨打400-820-1188。" completeBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 1){
                    NSString * url = [NSString stringWithFormat:@"tel:%@,2", CONTACT_ONSTART_NUMBER];
                    BOOL supportCall = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                    if (!supportCall) {
                        [Util showAlertWithTitle:NSLocalizedString(@"ContactNotSupport", nil) message:nil completeBlock:nil];
                    }
                }
            } cancleButtonTitle:NSLocalizedString(@"CancelTitle", nil) otherButtonTitles:NSLocalizedString(@"callOnstar", nil),nil];
        }
        return NO;
    }
   
}

#pragma mark - Private

+ (NSString *)lowercaseRoleString {
    return [CustomerInfo sharedInstance].userBasicInfo.currentSuite.role.lowercaseString;
}



@end
