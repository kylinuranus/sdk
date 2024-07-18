//
//  SOSLoginRequest.m
//  Onstar
//
//  Created by onstar on 2018/1/30.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSPOPUtil.h"
#import "SOSCardUtil.h"

@implementation SOSPOPUtil
///msp/api/v3/commonPrompt,GET false|0|mag_subscriber
+ (void)getInsurancePromptSuccess:(void (^)(SOSInsuranceModel *insuranceModel))completion
                           Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion{
    
    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_URL, URL_InsurancePrompt];
    //url = [SOSCardUtil getUrlStringWithUrl:url dic:@{@"vin":[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin?:@""}];
    NSString *vin = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin?:@"";
    NSDictionary *d = @{@"vin":vin};
    NSString *s = [Util jsonFromDict:d];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:s successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        SOSInsuranceModel *response = [SOSInsuranceModel mj_objectWithKeyValues:dic];
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

@end
