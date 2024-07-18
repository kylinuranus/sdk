//
//  PreferDealerRequestClient.m
//  Onstar
//
//  Created by Joshua on 6/25/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import "PreferDealerRequestClient.h"
#import "CustomerInfo.h"
#import "AppPreferences.h"
#import "RequestDataObject.h"
#import "ResponseDataObject.h"

@implementation PreferDealerRequestClient

- (void)getPreferredDealer     {
    [self getPreferredDealer:nil];
}


- (void)getPreferredDealer:(id)httpDelegate     {
    [self getPreferredDealer:httpDelegate sospoi:nil];
}

- (void)getPreferredDealer:(id)httpDelegate sospoi:(SOSPOI *)poi {
    // 没有vin号的Visitor
    if ([[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin length] == 0) {
        [Util hideLoadView];
        return;
    }
    
//    NSString *url = [NSString stringWithFormat:(@"%@" NEW_GET_PREFERRED_DEALER_DEALER), BASE_URL, [CustomerInfo sharedInstance].userBasicInfo.idpUserId, [CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId, [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    NSString *url = [BASE_URL stringByAppendingString:NEW_GET_PREFERRED_DEALER_DEALER];

    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"vin"] = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin;
    dic[@"longitude"] = [poi.longitude isKindOfClass:[NSString class]] ? poi.longitude:@"";
    dic[@"latitude"] = [poi.latitude isKindOfClass:[NSString class]] ? poi.latitude:@"";
    NSDictionary *d = [NSMutableDictionary dictionaryWithDictionary:dic];
//    if (poi) {
//        url = [NSString stringWithFormat:@"%@?longitude=%@&latitude=%@", url, poi.longitude, poi.latitude];
//    }
    NSString *s = [Util jsonFromDict:d];

    
    if (httpDelegate)   {
        SOSNetworkOperation* sosOperation = [SOSNetworkOperation requestWithURL:url params:s successBlock:^(SOSNetworkOperation *operation, id responseStr) {
            [Util hideLoadView];
            [_delegate requestDataFinished:responseStr];
            
        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            [Util hideLoadView];
            [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
        }];
        [sosOperation setHttpMethod:@"POST"];
        [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
        [sosOperation start];
    }   else    {
        SOSNetworkOperation* sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
            [Util hideLoadView];
            //            [[MyPreferDealerViewController sharedInstance] requestDataFinished:responseStr];
            
        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            [Util hideLoadView];
        }];
        [sosOperation setHttpMethod:@"POST"];
        [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
        [sosOperation start];
    }
}


@end
