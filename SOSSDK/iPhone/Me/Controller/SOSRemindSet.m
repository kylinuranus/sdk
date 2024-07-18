//
//  SOSRemindSet.m
//  Onstar
//
//  Created by Genie Sun on 2017/3/15.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSRemindSet.h"
#import "SOSNetworkOperation.h"
#import "CustomerInfo.h"
#import "DataObject.h"

@implementation SOSRemindSet
///通知设置信息
+ (void) notigyConfigInformation:(NSString *)requestType body:(NSString *)body btype:(NSString *)btype Success:(void (^)(NNNotifyConfig *notify))completion Failed:(void (^)(void))failCompletion{
    
//    NSString *url = [NSString stringWithFormat:(@"%@" ChangeNotifyConfig), BASE_URL, [CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    NSString *url = [BASE_URL stringByAppendingString:ChangeNotifyConfig];

    if ([requestType isEqualToString:@"GET"]) {
//        url = [NSString stringWithFormat:(@"%@" GetNotifyConfig), BASE_URL, [CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin,btype];
        url = [BASE_URL stringByAppendingFormat:GetNotifyConfig,[CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin,btype];
    }
    
    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:body successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        [Util hideLoadView];
        @try {
            NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
            if (operation.statusCode == 200) {
                NNNotifyConfig *configInfo = [NNNotifyConfig mj_objectWithKeyValues:dic];
                if (configInfo) {
                    completion(configInfo);
                }
            }else{
                !failCompletion ? : failCompletion();
            }
        }@catch (NSException *exception) {
            NSLog(@"exception jsonFormatError");
        }
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util hideLoadView];
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
    }];
    [sosOperation setHttpMethod:requestType];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}


///用户是否绑定过微信
+ (void) validatenotifyConfigWithVinSuccess:(void (^)(BOOL flag))completion Failed:(void (^)(void))failCompletion
{
//    NSString *url = [NSString stringWithFormat:(@"%@" ValidatenotifyConfig), BASE_URL, [CustomerInfo sharedInstance].userBasicInfo.idpUserId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    NSString *url = [BASE_URL stringByAppendingString:ValidatenotifyConfig];
    NSDictionary *d = @{@"idpUserId":[CustomerInfo sharedInstance].userBasicInfo.idpUserId};
    NSString *s = [Util jsonFromDict:d];
    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:s successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        [Util hideLoadView];
        @try {
            NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
            if (operation.statusCode == 200) {
                NNwechainLogin *info = [NNwechainLogin mj_objectWithKeyValues:dic];
//                if ([info.wechatLogin isEqualToString:@"true"]) {
                if (info.wechatLogin) {
                    completion(YES);
                }else{
                    completion(NO);
                }
            }else{
                !failCompletion ? : failCompletion();
            }
        }@catch (NSException *exception) {
            NSLog(@"exception jsonFormatError");
        }
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        !failCompletion ? : failCompletion();
        [Util hideLoadView];
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
    }];
    [sosOperation setHttpMethod:@"POST"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}

///发送验证码
+ (void)sendNOtifyCodewithSubscriberId:(NSString *)subscriberID userTf:(NSString *)newUserTf pageNumber:(pageType)pageType secCode:(NSString *)secCode Success:(void (^)(NNErrorDetail *error))completion Failed:(void (^)(void))failCompletion
{
    
    NNSendNotify *noti = [[NNSendNotify alloc] init];
    
    if (pageType == changephoneNb) {
        [noti setMobilePhoneNumber:newUserTf];
        [noti setDestType:@"S"];
        if (secCode) {
            [noti setSecCode:secCode];
        }
    } else if (pageType == changemailNb){
        [noti setEmailAddress:newUserTf];
        [noti setDestType:@"E"];
        if (secCode) {
            [noti setSecCode:secCode];
        }
    }else{
        return;
    }
    [noti setSubscriberID:subscriberID];
    NSString *url = [NSString stringWithFormat:(@"%@" Sendnotifypreference), BASE_URL];
    if (secCode) {
        url = [NSString stringWithFormat:(@"%@" ValidatenotifyCode), BASE_URL];
    }
    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:[noti mj_JSONString] successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        
        @try {
            NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
            if (operation.statusCode == 200) {
                NNErrorDetail *info = [NNErrorDetail mj_objectWithKeyValues:dic];
                completion(info);
            }else{
                !failCompletion ? : failCompletion();
            }
        }@catch (NSException *exception) {
            NSLog(@"exception jsonFormatError");
        }
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util hideLoadView];
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
        !failCompletion ? : failCompletion();
       
    }];
    [sosOperation setHttpMethod:@"PUT"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}

@end
