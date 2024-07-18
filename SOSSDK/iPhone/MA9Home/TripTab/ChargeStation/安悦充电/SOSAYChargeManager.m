//
//  SOSAYChargeManager.m
//  Onstar
//
//  Created by Coir on 2018/10/25.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//
#import "SOSOnstarLinkBindPhoneVC.h"
#import "SOSCustomAlertView.h"
#import "SOSAYChargeManager.h"
#import "SOSAYAgreementVC.h"
#import "SOSAYLoadingVC.h"
#import "SOSAYChargeVC.h"

@implementation SOSAYChargeManager

/// 进入安悦充电模块
+ (void)enterAYChargeVCIsFromCarLife:(BOOL)isFromCarLife {
    [self enterAYChargeVCIsFromCarLife:isFromCarLife code:nil];
}

+ (void)enterAYChargeVCIsFromCarLife:(BOOL)isFromCarLife code:(nullable NSString *)code {
    NNserviceObject *chargeServiceOBJ = [CustomerInfo sharedInstance].servicesInfo.ChargeStation;
    if (chargeServiceOBJ) {
        [self enterAYChargeVCWithServiceStatus:chargeServiceOBJ.optStatus IsFromCarLife:isFromCarLife code:code];
    }    else if (isFromCarLife)        {
        SOSAYLoadingVC *vc = [SOSAYLoadingVC new];
        [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:vc animated:YES];
    }    else    {
        [[CustomerInfo sharedInstance].servicesInfo getServiceStatus:@"ChargeStation" callback:^(NSDictionary *result) {
            [self enterAYChargeVCWithServiceStatus:[CustomerInfo sharedInstance].servicesInfo.ChargeStation.optStatus];
        }];
    }

}

/// 根据服务状态进入安悦充电下一级页面
+ (void)enterAYChargeVCWithServiceStatus:(BOOL)status	{
    [self enterAYChargeVCWithServiceStatus:status IsFromCarLife:NO];
}

+ (void)enterAYChargeVCWithServiceStatus:(BOOL)status IsFromCarLife:(BOOL)isFromCarLife    {
    [self enterAYChargeVCWithServiceStatus:status IsFromCarLife:isFromCarLife code:nil];
}


+ (void)enterAYChargeVCWithServiceStatus:(BOOL)status IsFromCarLife:(BOOL)isFromCarLife code:(nullable NSString *)code {
    if (status) {
        [self enterAYChargeVCUseUserInfoIsFromCarLife:isFromCarLife code:code];
    }    else    {
        dispatch_async_on_main_queue(^{
            SOSAYAgreementVC *vc = [SOSAYAgreementVC new];
            [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:vc animated:YES];
        });
    }

}

/// 根据服务状态进入安悦充电下一级页面
/// 根据用户信息(Mobile)进入安悦充电下一级页面
+ (void)enterAYChargeVCUseUserInfo		{
    [self enterAYChargeVCUseUserInfoIsFromCarLife:NO];
}

/// 根据用户信息(Mobile)进入安悦充电下一级页面
+ (void)enterAYChargeVCUseUserInfoIsFromCarLife:(BOOL)isFromCarLife	{
    [self enterAYChargeVCUseUserInfoIsFromCarLife:isFromCarLife code:nil];
}

+ (void)enterAYChargeVCUseUserInfoIsFromCarLife:(BOOL)isFromCarLife code:(nullable NSString *)code {
    dispatch_async_on_main_queue(^{
        NSString *userMobile = [CustomerInfo sharedInstance].userBasicInfo.idmUser.mobilePhoneNumber;
        if (userMobile.length || isFromCarLife) {
            SOSAYChargeVC *vc = [SOSAYChargeVC new];
            if (code.length > 0) {
                vc.code = code;
            }
            [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:vc animated:YES];
        }    else    {
            [self checkUserPhoneNum];
        }
    });

}

+ (void)checkNetworkSuccess:(statusBlock)complete		{
    [SOSReachability SOSNetworkStatuswithSuccessBlock:^(NSInteger status) {
        if (status == 0) {
            SOSCustomAlertView *alertView = [[SOSCustomAlertView alloc] initWithTitle:@"加载失败" detailText:@"网络连接失败，请稍后重试" cancelButtonTitle:@"知道了" otherButtonTitles:nil canTapBackgroundHide:YES];
            [alertView show];
            complete(0);
        }	else	complete(status);
    }];
}

+ (BOOL)checkUserPhoneNum	{
    NSString *userMobile = [CustomerInfo sharedInstance].userBasicInfo.idmUser.mobilePhoneNumber;
    if (userMobile.length)		return YES;
    SOSCustomAlertView *view = [[SOSCustomAlertView alloc] initWithTitle:@"绑定手机号" detailText:@"检测到您尚未绑定手机号\n若使用该服务需要绑定手机号" cancelButtonTitle:@"再想想" otherButtonTitles:@[@"立即绑定"] canTapBackgroundHide:YES];
    view.buttonMode = SOSAlertButtonModelHorizontal;
    [view setButtonClickHandle:^(NSInteger clickIndex) {
        if (clickIndex) {
            [SOSDaapManager sendActionInfo:Map_POIdetail_anyocharging_Authorization_Agree_BindPhoneNum_OK];
            SOSOnstarLinkBindPhoneVC *vc = [SOSOnstarLinkBindPhoneVC new];
            [vc setOperationSuccessBlock:^(NSString *mobilePhoneNum) {
                [CustomerInfo sharedInstance].userBasicInfo.idmUser.mobilePhoneNumber = mobilePhoneNum;
                dispatch_async_on_main_queue(^{
                    [[SOS_APP_DELEGATE fetchMainNavigationController] popViewControllerAnimated:YES];
                });
            }];
            vc.pageType = SOSAYBindPhone;
            [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:vc animated:YES];
            return;
        }	else if ([[SOS_APP_DELEGATE fetchMainNavigationController].topViewController isKindOfClass:[SOSAYChargeVC class]])	{
            [[SOS_APP_DELEGATE fetchMainNavigationController] popViewControllerAnimated:YES];
        }
        [SOSDaapManager sendActionInfo:Map_POIdetail_anyocharging_Authorization_Agree_BindPhoneNum_Cancel];
    }];
    view.tapGesDismissHandle = ^{
        if ([[SOS_APP_DELEGATE fetchMainNavigationController].topViewController isKindOfClass:[SOSAYChargeVC class]])    {
            [[SOS_APP_DELEGATE fetchMainNavigationController] popViewControllerAnimated:YES];
        }
    };
    [view show];
    return NO;
}

/// 安悦 用户登录/注册
+ (void)loginAYSystemSuccess:(SOSSuccessBlock)successBlock failure:(SOSFailureBlock)failureBlock	{
    NSString *url = [BASE_URL stringByAppendingString:SOSAYChargeLoginURL];
    SOSLoginUserDefaultVehicleVO *userInfo = [CustomerInfo sharedInstance].userBasicInfo;
    NSDictionary *parameterDic = @{@"idpUserId": userInfo.idpUserId, @"phone": userInfo.idmUser.mobilePhoneNumber};
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:parameterDic.mj_JSONString successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *resDic = [responseStr mj_JSONObject];
        if (resDic.count) {
            if ([resDic[@"code"] isEqualToString:@"E0000"]) {
                NSDictionary *dataDic = resDic[@"data"];
                if (dataDic.count) {
                    NSString *sessionId = dataDic[@"sessionId"];
                    if (sessionId.length && successBlock)     successBlock(operation, sessionId);
                    return ;
                }
            }
        }
        if (failureBlock)    failureBlock(0, responseStr, nil);
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        NSLog(@"error: %@", error);
        if (failureBlock)	failureBlock(statusCode, responseStr, error);
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"POST"];
    [operation start];
}

/// 查询当前用户是否存在在途订单
+ (void)checkAYUserOrderWithSessionID:(NSString *)sessionID Success:(SOSSuccessBlock)successBlock failure:(SOSFailureBlock)failureBlock		{
    NSString *url = [BASE_URL stringByAppendingString:SOSAYChargecheckUserOrderURL];
    SOSLoginUserDefaultVehicleVO *userInfo = [CustomerInfo sharedInstance].userBasicInfo;
    NSDictionary *parameterDic = @{@"idpUserId": userInfo.idpUserId, @"sessionID": sessionID, @"phone": userInfo.idmUser.mobilePhoneNumber};
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:parameterDic.mj_JSONString successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *resDic = [responseStr mj_JSONObject];
        if (resDic.count) {
            if ([resDic[@"code"] isEqualToString:@"E0000"]) {
                NSDictionary *dataDic = resDic[@"data"];
                if (dataDic.count) {
                    NSNumber *existFlag = dataDic[@"existFlag"];
                    if (existFlag && successBlock)     successBlock(operation, existFlag);
                    return ;
                }
            }
        }
        if (failureBlock)    failureBlock(0, responseStr, nil);
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        NSLog(@"error: %@", error);
        if (failureBlock)    failureBlock(statusCode, responseStr, error);
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"POST"];
    [operation start];
}

/// 获取验证码
+ (void)getAYUserVerifyCodeWithMobileNum:(NSString *)mobileNum Success:(SOSSuccessBlock)successBlock failure:(SOSFailureBlock)failureBlock        {
    NSString *url = [BASE_URL stringByAppendingFormat:SOSAYVerifyCodeURL, mobileNum];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        if (successBlock)    successBlock(operation, responseStr);
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        NSLog(@"error: %@", error);
        if (failureBlock)    failureBlock(statusCode, responseStr, error);
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"POST"];
    [operation start];
}

@end
