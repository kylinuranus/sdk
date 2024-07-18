//
//  SOSBleNetwork.m
//  Onstar
//
//  Created by onstar on 2018/7/20.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSBleNetwork.h"
#import "SOSAuthorInfo.h"
#import "SOSCardUtil.h"
#import "SOSAgreement.h"
#import "SOSAgreementAlertView.h"

//新增授权  //批准或关闭授权
#define URL_BLE_OWNER_AUTHORIZATIONS            @"/sos/privilegemgr/v1/owner/authorizations"
//获取授权列表
#define URL_BLE_OWNER_AUTHORIZATIONS_LIST       @"/sos/privilegemgr/v1/owner/authorizations/list"
//用户车辆绑定
#define URL_BLE_OWNER_BIND                      @"/sos/mobileuser/v1/owner/bind"
//查询BLE开关状态  //变更BLE开关
#define URL_BLE_OWNER_BLESWITCH                 @"/sos/privilegemgr/v1/owner/bleswitch"
//用户车辆解绑
#define URL_BLE_OWNER_UNBIND                    @"/sos/mobileuser/v1/owner/unbind"
//查询被授权列表  //接受或放弃授权
#define URL_BLE_USER_AUTHORIZATIONS             @"/sos/privilegemgr/v1/user/authorizations"
//下载钥匙
#define URL_BLE_VKEYS                           @"/sos/privilegemgr/v1/vkeys"

@implementation SOSBleNetwork

+ (void)loadBLENeedConfirmTypes:(NSArray *)types
                        success:(void(^)(NSArray <SOSAgreement *>*agreements))complete
                         failed:(void(^)(NSString *responseStr, NSError *error))failCompletion
{
    
    [SOSAgreement requestAgreementsWhichNeedSignWithTypes:types success:^(NSDictionary *response) {

        NSMutableArray<SOSAgreement *> *agreements = @[].mutableCopy;
        [types enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([response.allKeys containsObject:obj]) {
                SOSAgreement *model = [SOSAgreement mj_objectWithKeyValues:response[obj]];
                [agreements addObject:model];
            }
        }];
        if (complete) {
            complete(agreements);
        }
        
    } fail:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        failCompletion(responseStr,error);
    }];
}

+ (void)requestSignAgreements:(NSArray<SOSAgreement *> *)agreements
                      success:(void(^)(NSDictionary *dic))success
                         fail:(SOSAgreementFailBlock)failBlock
{
    [SOSAgreement requestSignAgreements:agreements success:^(NSDictionary *response) {
        if (success) {
            success(response);
        }
    } fail:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        
        if (failBlock) {
            failBlock(statusCode,responseStr,error);
        }
    }];
}

+ (void)requestBleBindOwnerSuccess:(void (^)(NSDictionary *urlRequest))completion
                            Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion
{
    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_URL, URL_BLE_OWNER_BIND];
    NSDictionary *params = @{@"idpUserId":[CustomerInfo sharedInstance].userBasicInfo.idpUserId?:@"",
                             @"vin":[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin
                             };
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:params.mj_JSONString successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        
        dispatch_async_on_main_queue(^{
            if (completion && operation.statusCode == 200) {
                completion(dic);
            }
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async_on_main_queue(^{
            if (failCompletion) {
                failCompletion(responseStr,error);
            }
        });
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"POST"];
    [operation start];
}


//获取授权列表
+ (void)getOwnerAuthorizationsListSuccess:(void (^)(SOSAuthorInfo *urlRequest))completion
                                   Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion
{
    
    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_URL, URL_BLE_OWNER_AUTHORIZATIONS_LIST];
    NSDictionary *params = @{@"idpUserId":[CustomerInfo sharedInstance].userBasicInfo.idpUserId?:@""};
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:params.mj_JSONString successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        SOSAuthorInfo *response = [SOSAuthorInfo mj_objectWithKeyValues:dic];
        dispatch_async_on_main_queue(^{
            if (completion && operation.statusCode == 200) {
                completion(response);
            }
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async_on_main_queue(^{
            if (failCompletion) {
                failCompletion(responseStr,error);
            }
        });
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"POST"];
    [operation start];
}

//新增授权
+ (void)bleShareOwnerAuthorizationsParams:(NSDictionary *)params
                                  success:(void (^)(SOSAuthorInfo *urlRequest))completion
                                   Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion
{
    
    [self bleShareOwnerAuthorizationsParams:params
                                     method:@"POST"
                                    success:completion
                                     Failed:failCompletion];
}

//批准或关闭授权
+ (void)bleOwnerOperateAuthorizationsParams:(NSDictionary *)params
                                    success:(void (^)(SOSAuthorInfo *urlRequest))completion
                                     Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion
{
    
    [self bleShareOwnerAuthorizationsParams:params
                                     method:@"PUT"
                                    success:completion
                                     Failed:failCompletion];
}

+ (void)bleShareOwnerAuthorizationsParams:(NSDictionary *)params
                                   method:(NSString *)method
                                  success:(void (^)(SOSAuthorInfo *urlRequest))completion
                                   Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion
{
    
    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_URL, URL_BLE_OWNER_AUTHORIZATIONS];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:params.mj_JSONString successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        SOSAuthorInfo *response = [SOSAuthorInfo mj_objectWithKeyValues:dic];
        dispatch_async_on_main_queue(^{
            if (completion && operation.statusCode == 200) {
                completion(response);
            }
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async_on_main_queue(^{
            if (failCompletion) {
                failCompletion(responseStr,error);
            }
        });
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:method];
    [operation start];
}



//接受授权 被授权列表
+ (void)bleUserAuthorizationsParams:(NSDictionary *)params
                                   method:(NSString *)method
                                  success:(void (^)(SOSAuthorInfo *urlRequest))completion
                                   Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion
{
    
    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_URL, URL_BLE_USER_AUTHORIZATIONS];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:params.mj_JSONString successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        SOSAuthorInfo *response = [SOSAuthorInfo mj_objectWithKeyValues:dic];
        dispatch_async_on_main_queue(^{
            if (completion && operation.statusCode == 200) {
                completion(response);
            }
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async_on_main_queue(^{
            if (failCompletion) {
                failCompletion(responseStr,error);
            }
        });
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:method];
    [operation start];
}

//下载钥匙
+ (void)bleUserDownloadKeysWithParams:(NSDictionary *)params
                            success:(void (^)(id JSONDict))completion
                             Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion
{
    
    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_URL, URL_BLE_VKEYS];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:params.mj_JSONString successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
//        SOSVKeys *response = [SOSVKeys mj_objectWithKeyValues:dic];
        dispatch_async_on_main_queue(^{
            if (completion && operation.statusCode == 200) {
                completion(dic);
            }
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async_on_main_queue(^{
            if (failCompletion) {
                failCompletion(responseStr,error);
            }
        });
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"POST"];
    [operation start];
}


//查询BLE开关状态
+ (void)bleSwitchStatusSuccess:(void (^)(id JSONDict))completion
                        Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion
{
    
    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_URL, URL_BLE_OWNER_BLESWITCH];
    NSDictionary *dic = @{@"idpUserId":[CustomerInfo sharedInstance].userBasicInfo.idpUserId?:@"",
                          @"vin":[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin?:@""
                        };
    url = [SOSCardUtil getUrlStringWithUrl:url dic:dic];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        dispatch_async_on_main_queue(^{
            if (completion && operation.statusCode == 200) {
                completion(dic);
            }
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async_on_main_queue(^{
            if (failCompletion) {
                failCompletion(responseStr,error);
            }
        });
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];
}

//变更BLE开关状态
+ (void)bleSwitchStatusWithBleStatus:(NSString *)status
                          Success:(void (^)(id JSONDict))completion
                           Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion
{
    
    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_URL, URL_BLE_OWNER_BLESWITCH];
    NSMutableDictionary *dic = @{@"idpUserId":[CustomerInfo sharedInstance].userBasicInfo.idpUserId?:@"",
                          @"vin":[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin?:@""
                          }.mutableCopy;
    [dic setObject:status forKey:@"ble"];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:dic.mj_JSONString successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        dispatch_async_on_main_queue(^{
            if (completion && operation.statusCode == 200) {
                completion(dic);
            }
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async_on_main_queue(^{
            if (failCompletion) {
                failCompletion(responseStr,error);
            }
        });
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"PUT"];
    [operation start];
}

@end
