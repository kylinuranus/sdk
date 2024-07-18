//
//  PackageUtil.m
//  Onstar
//
//  Created by Vicky on 16/6/30.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "PackageUtil.h"
#import "SOSCardUtil.h"
@implementation PackageUtil

//+ (void)loadChannel:(NSString *)params_ successHandler:(void(^)(NSArray *chList))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_
//{
//    NSString *url = [BASE_URL stringByAppendingString:PAYMENT_CHANNEL];
//    SOSNetworkOperation * sosOperation = [SOSNetworkOperation requestWithURL:url params:params_ successBlock:^(SOSNetworkOperation *operation, id returnData) {
//        NSDictionary *dic = [Util dictionaryWithJsonString:returnData];
//        NSArray * channelList = [channelDTO mj_objectArrayWithKeyValuesArray:[dic objectForKey:@"channels"]];
//        if (success_) {
//            success_ (channelList);
//        }
//        
//    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
//        
//        if (failure_) {
//            failure_(responseStr,error);
//        }
//        
//    }];
//    [sosOperation setHttpMethod:@"PUT"];
//    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
//    [sosOperation start];
//}

+ (void)payParams:(NSDictionary *)dic successHandler:(void(^)(id dic))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_ {
//        NSString *url = [BASE_URL stringByAppendingString:PAYMENT_IAPSERVICE];
    
    NSString *url = [BASE_URL stringByAppendingString:PAYMENT_IAPSERVICE];
    NSMutableDictionary *prams = dic.mutableCopy?:@{}.mutableCopy;
    [prams setValue:gen_safe_sign(dic) forKey:@"sign"];
    
    SOSNetworkOperation * sosOperation = [SOSNetworkOperation requestWithURL:url params:[prams.copy mj_JSONString] successBlock:^(SOSNetworkOperation *operation, id returnData) {
        NSDictionary *response = [Util dictionaryWithJsonString:returnData];
        NSString *errorCode = [response valueForKey:@"errorCode"];
        if ([errorCode isEqualToString:@"0"]) {
            if (success_) {
                success_ (response);
            }
        }else {
            if (failure_) {
                NSString *errorMsg = [response valueForKey:@"errorMessage"]?:@"接口请求失败";
                NSError *error = [NSError errorWithDomain:@"com.onstar" code:200 userInfo:@{NSLocalizedDescriptionKey:errorMsg}];
                failure_(errorMsg,error);
            }
        }
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        //        NSString *errMsg = @"";
        //        NSDictionary *response = [Util dictionaryWithJsonString:responseStr];
        //        if (response) {
        //            errMsg = [response valueForKey:@"errorMessage"];
        //        }
        if (statusCode == 500) {//网络错误，请稍后重试。
            error = [NSError errorWithDomain:error.domain code:statusCode userInfo:@{NSLocalizedDescriptionKey: @"网络错误，请稍后重试。"}];
        }
        if (failure_) {
            failure_(responseStr,error);
        }
        
    }];
    [sosOperation setHttpMethod:@"POST"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
    
}
#pragma mark 后视镜iap支付成功后调用服务器
+ (void)payRearviewMirrorServiceParams:(NSDictionary *)dic successHandler:(void(^)(id code))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure {    
    NSString *url = [BASE_URL stringByAppendingString:Payment_IAPRearviewMirrorService];
    NSMutableDictionary *prams = dic.mutableCopy?:@{}.mutableCopy;
    [prams setValue:gen_safe_sign(dic) forKey:@"sign"];
    SOSNetworkOperation * sosOperation = [SOSNetworkOperation requestWithURL:url params:[prams.copy mj_JSONString] successBlock:^(SOSNetworkOperation *operation, id returnData) {
        NSDictionary *response = [Util dictionaryWithJsonString:returnData];
        NSString *errorCode = [response valueForKey:@"errorCode"];
        if ([errorCode isEqualToString:@"0"]) {
            if (success_) {
                success_ (response);
            }
        }else {
            if (failure) {
                NSString *errorMsg = [response valueForKey:@"errorMessage"]?:@"接口请求失败";
                NSError *error = [NSError errorWithDomain:@"com.onstar" code:200 userInfo:@{NSLocalizedDescriptionKey:errorMsg}];
                failure(errorMsg,error);
            }
        }
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        //        NSString *errMsg = @"";
        //        NSDictionary *response = [Util dictionaryWithJsonString:responseStr];
        //        if (response) {
        //            errMsg = [response valueForKey:@"errorMessage"];
        //        }
        if (statusCode == 500) {//网络错误，请稍后重试。
            error = [NSError errorWithDomain:error.domain code:statusCode userInfo:@{NSLocalizedDescriptionKey: @"网络错误，请稍后重试。"}];
        }
        if (failure) {
            failure(responseStr,error);
        }
        
    }];
    [sosOperation setHttpMethod:@"POST"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}

static inline NSString * gen_safe_sign(NSDictionary *params)
{
    NSMutableArray *pairs = [NSMutableArray new];
    NSArray *keys = [[params allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    for (NSString *key in keys) {
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, params[key]]];
    }
    NSString *query = [pairs componentsJoinedByString:@"&"];
    
    
    NSString *sign = [Util md5:query].uppercaseString;
    
    return sign;
}

+ (void)getPackageServiceSuccess:(void (^)(SOSGetPackageServiceResponse * userfulDic))completion failed:(void(^)(NSString *responseStr, NSError *error))failCompletion{
    if ([SOSCardUtil shareInstance].packageResp) {
        if (completion)     completion([SOSCardUtil shareInstance].packageResp);
    }else{
        NSString *url = [BASE_URL stringByAppendingFormat:SOSPackageServiceURL,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin,[Util vehicleIsG9]?@"true":@"false"];
        SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id returnData) {
            NSDictionary *dic = [Util dictionaryWithJsonString:returnData];
            SOSMSRespModel *accountInfo = [SOSMSRespModel mj_objectWithKeyValues:dic];
            SOSGetPackageServiceResponse *packageArray = [SOSGetPackageServiceResponse mj_objectWithKeyValues:accountInfo.data];
            [SOSCardUtil shareInstance].packageResp = packageArray;
            if (completion)     completion(packageArray);
        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            [SOSCardUtil shareInstance].packageResp = nil;
            if (failCompletion)        failCompletion(responseStr, error);
        }];
        [sosOperation setHttpMethod:@"GET"];
        [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
        [sosOperation start];
    }
    
}

@end
