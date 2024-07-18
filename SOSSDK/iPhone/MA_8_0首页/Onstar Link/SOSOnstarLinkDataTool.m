//
//  SOSOnstarLinkDataTool.m
//  Onstar
//
//  Created by Coir on 2018/7/31.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "LoadingView.h"
#import "SOSAgreement.h"
#import "SOSCustomAlertView.h"
#import "SOSOnstarLinkGuideVC.h"
#import "SOSOnstarLinkSDKTool.h"
#import "SOSOnstarLinkagreementVC.h"
#import "SOSOnstarLinkDataTool.h"


@implementation SOSOnstarLinkDataModel
@end

@implementation SOSOnstarLinkDataTool

+ (SOSOnstarLinkDataTool *)sharedInstance {
    static SOSOnstarLinkDataTool *sharedOBJ = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedOBJ = [[self alloc] init];
        [sharedOBJ configSelf];
        
    });
    return sharedOBJ;
}

- (void)configSelf		{
    [[[LoginManage sharedInstance] rac_valuesAndChangesForKeyPath:@"loginState" options:NSKeyValueObservingOptionNew observer:[SOSOnstarLinkSDKTool sharedInstance]] subscribeNext:^(RACTwoTuple<id,NSDictionary *> *x) {
        id newValue = x.first;
        // 用户退出登录
        if ([newValue isKindOfClass:[NSNumber class]] && [newValue intValue] == LOGIN_STATE_NON) {
            [SOSOnstarLinkDataTool sharedInstance].dataModel = nil;
        }
    }];
}

/// 获取绑定信息
+ (void)getOnstarLinkInfoSuccess:(void (^)(NSDictionary *result))success Failure:(void(^)(NSString *responseStr, NSError *error))failure		{
    NSString *url = [BASE_URL stringByAppendingFormat:SOSOnstasrLinkGetBindInfoURL, [CustomerInfo sharedInstance].userBasicInfo.idpUserId];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        if (responseStr) {
            NSDictionary *responseDic = [responseStr mj_JSONObject];
            if ([responseDic[@"success"] boolValue]) {
                NSDictionary *dataDic = responseDic[@"data"];
                if (success)    success(dataDic);
            }
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (failure)		failure(responseStr, error);
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];
}

/// 绑定用户信息
+ (void)bindOnstarInfoWithPhoneNum:(NSString *)phoneNum IsModify:(BOOL)isModifyMode Success:(void (^)(NSDictionary *result))success Failure:(void(^)(NSString *responseStr, NSError *error))failure		{
    NSString *url = [BASE_URL stringByAppendingFormat:SOSOnstasrLinkBindURL, [CustomerInfo sharedInstance].userBasicInfo.idpUserId];
    NSDictionary *parameters = @{@"mobile": phoneNum};
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:[parameters toJson] successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *resultDic = [responseStr mj_JSONObject];
        SOSOnstarLinkDataModel *dataModel = [SOSOnstarLinkDataModel new];
        dataModel.mobile = phoneNum;
        [SOSOnstarLinkDataTool sharedInstance].dataModel = dataModel;
        if (success)    success(resultDic);
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        NSDictionary *errorDic = [responseStr mj_JSONObject];
        // 重复绑定
        if ([errorDic isKindOfClass:[NSDictionary class]] && errorDic.count) {
            NSString *errorCode = errorDic[@"errorCode"];
            if ([errorCode isEqualToString:@"E9003"] || [errorCode isEqualToString:@"E9001"]) {
                SOSCustomAlertView *alertView = [[SOSCustomAlertView alloc] initWithTitle:@"已被使用" detailText:@"该手机号已被绑定为服务手机号，\n请使用其它号码" cancelButtonTitle:@"知道了" otherButtonTitles:nil];
                [alertView show];
            }
        }
        if (failure)        failure(responseStr, error);
        
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:(isModifyMode ? @"PUT" : @"POST")];
    [operation start];
}

/// 发送验证码
+ (void)sendVerificationCodeWithPhoneNum:(NSString *)phoneNum Success:(void (^)(NSDictionary *result))success Failure:(void(^)(NSString *responseStr, NSError *error))failure        {
    NSString *url = [BASE_URL stringByAppendingFormat:SOSOnstasrLinkSendVerificationCodeURL, phoneNum];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *resultDic = [responseStr mj_JSONObject];
        if (success)    success(resultDic);
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
//        NSDictionary *errorDic = [responseStr mj_JSONObject];
        if (failure)        failure(responseStr, error);
        
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"POST"];
    [operation start];
}

/// 校验验证码
+ (void)checkVerificationCodeWithPhoneNum:(NSString *)phoneNum AndVerificationCode:(NSString *)code Success:(void (^)(NSDictionary *result))success Failure:(void(^)(NSString *responseStr, NSError *error))failure        {
    NSString *url = [BASE_URL stringByAppendingFormat:SOSOnstasrLinkCheckVerificationCodeURL, phoneNum, code];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *resultDic = [responseStr mj_JSONObject];
        if (success)    success(resultDic);
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
//        NSDictionary *errorDic = [responseStr mj_JSONObject];
        if (failure)        failure(responseStr, error);
        
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"POST"];
    [operation start];
}

/// 根据数据进行OnstarLink下一步操作
- (void)enterOnstarLink		{
    [[LoadingView sharedInstance] startIn:[SOS_APP_DELEGATE fetchMainNavigationController].topViewController.view];
    // 获取协议状态
    [SOSAgreement requestAgreementsWhichNeedSignWithTypes:@[agreementName(ONSTAR_LINK_TC)] success:^(NSDictionary *response) {
        [[LoadingView sharedInstance] stop];
        NSDictionary *dataDic = response[agreementName(ONSTAR_LINK_TC)];
        if ([dataDic isKindOfClass:[NSDictionary class]] && dataDic.count) {
            SOSAgreement *agreement = [SOSAgreement mj_objectWithKeyValues:dataDic];
            [SOSOnstarLinkDataTool showagreementVCWithAgreeMent:agreement];
        }	else	{
            if (self.dataModel) {
                [SOSOnstarLinkSDKTool configOnstarLinkSDK];
                [SOSOnstarLinkSDKTool enterOnstarLink];
            }    else    {
                SOSOnstarLinkGuideVC *guideVC = [SOSOnstarLinkGuideVC new];
                guideVC.isFirstEnter = YES;
                [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:guideVC animated:YES];
            }
        }
    } fail:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [[LoadingView sharedInstance] stop];
        [Util toastWithMessage:@"获取智联映射协议状态失败"];
        if (self.dataModel) {
            [SOSOnstarLinkSDKTool configOnstarLinkSDK];
            [SOSOnstarLinkSDKTool enterOnstarLink];
        }    else    {
            SOSOnstarLinkGuideVC *guideVC = [SOSOnstarLinkGuideVC new];
            guideVC.isFirstEnter = YES;
            [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:guideVC animated:YES];
        }
    }];
    
}

/// 弹出协议弹框
+ (void)showagreementVCWithAgreeMent:(SOSAgreement *)agreement        {
    SOSOnstarLinkAgreementVC *vc = [SOSOnstarLinkAgreementVC new];
    vc.agreement = agreement;
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    navVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [[SOS_APP_DELEGATE fetchMainNavigationController].topViewController presentViewController:navVC animated:YES completion:nil];
}

@end
