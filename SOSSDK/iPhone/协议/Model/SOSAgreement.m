 //
//  SOSAgreement.m
//  Onstar
//
//  Created by TaoLiang on 19/04/2018.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSAgreement.h"

#define SOSAgreementKey @"kSOSAgreementKey"

@implementation SOSAgreement

+ (BOOL)didLocalSignedAgreement:(SOSAgreementType)agreementType {
    NSString *userId = [CustomerInfo sharedInstance].userBasicInfo.idpUserId ? : @"";
    NSString *key = [SOSAgreementKey stringByAppendingFormat:@"_%lu_%@",agreementType, userId];
    BOOL isSigned = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    return isSigned;
}

+ (void)localSignAgreement:(SOSAgreementType)agreementType {
    NSString *userId = [CustomerInfo sharedInstance].userBasicInfo.idpUserId ? : @"";
    NSString *key = [SOSAgreementKey stringByAppendingFormat:@"_%lu_%@", agreementType,userId];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)requestAgreementsWithTypes:(NSArray<NSString *> *)types success:(SOSAgreementSuccessBlock)successBlock fail:(SOSAgreementFailBlock)failBlock {
    NSString *param = [self cookTypes:types];
    NSString *url = [BASE_URL stringByAppendingFormat:MA8_3_TCPS];
    NSString *para = [NSString stringWithFormat:@"&type=%@", param];
    url = [url stringByAppendingString:para];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        if (!dic) {
            dic = @{};
        }
        dispatch_async_on_main_queue(^{
            if (successBlock) {
                successBlock(dic);
            }
        });
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async_on_main_queue(^{
            if (failBlock) {
                failBlock(statusCode, responseStr, error);
            }
        });
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];

}

+ (void)requestAgreementsWhichNeedSignWithTypes:(NSArray<NSString *> *)types success:(SOSAgreementSuccessBlock)successBlock fail:(SOSAgreementFailBlock)failBlock{
    NSString *idpUserId = [CustomerInfo sharedInstance].tokenBasicInfo.idpUserId;
    NSString *param = [self cookTypes:types];
    NSString *url = [BASE_URL stringByAppendingFormat:MA8_3_TCPS_NEED_SIGN];
    NSString *para = [NSString stringWithFormat:@"&idpUserId=%@&type=%@", idpUserId, param];
    url = [url stringByAppendingString:para];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        if (!dic) {
            dic = @{};
        }
        dispatch_async_on_main_queue(^{
            if (successBlock) {
                successBlock(dic);
            }
        });

    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async_on_main_queue(^{
            if (failBlock) {
                failBlock(statusCode, responseStr, error);
            }
        });
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];
}

+ (void)requestSignAgreements:(NSArray<SOSAgreement *> *)agreements success:(SOSAgreementSuccessBlock)successBlock fail:(SOSAgreementFailBlock)failBlock {
    NSString *url = [BASE_URL stringByAppendingFormat:MA8_3_TCPS_SIGN];
    NSMutableDictionary *para = @{}.mutableCopy;
    [agreements enumerateObjectsUsingBlock:^(SOSAgreement * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = obj.type ? : @"";
        NSDictionary *value = obj.mj_keyValues;
        para[key] = value;
    }];
    
    NSString *urlPara = [NSString stringWithFormat:@"&idpUserId=%@", [CustomerInfo sharedInstance].userBasicInfo.idpUserId];
    url = [url stringByAppendingString:urlPara];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:[para toJson] successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        if (!dic) {
            dic = @{};
        }
        dispatch_async_on_main_queue(^{
            if (successBlock) {
                successBlock(dic);
            }
        });
        
        [LoginManage sharedInstance].isSignAgreementState=true;
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [LoginManage sharedInstance].isSignAgreementState=false;
        dispatch_async_on_main_queue(^{
            if (failBlock) {
                failBlock(statusCode, responseStr, error);
            }
        });
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"POST"];
    [operation start];
}

+ (NSString *)cookTypes:(NSArray<NSString *> *)types {
    NSMutableString *param = @"".mutableCopy;
    [types enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [param appendString:obj];
        if (idx != types.count - 1) {
            [param appendString:@","];
        }
    }];
    return param;
}

@end
