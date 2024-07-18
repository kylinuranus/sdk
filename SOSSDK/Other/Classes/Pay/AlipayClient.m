//
//  AlipayClient.m
//  Onstar
//
//  Created by Joshua on 5/27/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import "AlipayClient.h"
#import "Order.h"
#ifdef SOSSDK_SDK
#import <AlipaySDK/AlipaySDK.h>
#endif
#import "PurchaseModel.h"
#import "PurchaseProxy.h"
#import "AlipayRiskDetectRequest.h"

#define ORDER_VALIDATION_TIME   @"30m"

@implementation AlipayClient

+ (id)sharedInstance     {
    static AlipayClient *sharedOBJ = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedOBJ = [[self alloc] init];
    });
    return sharedOBJ;
}

+ (void)purgeInstance     {
}


- (void)payWithOrderString:(NSString*)orderStr
{
  
//#ifdef SOSSDK_SDK
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = [SOSSDKKeyUtils paySchemeUrl];
    __weak AlipayClient *weakClient = self;
    [[AlipaySDK defaultService] payOrder:orderStr fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"Alipay pay result = %@",resultDic);
            [weakClient handleAlipayDictResult:resultDic];
        }];
//#endif

}


- (void)handleAlipayDictResult:(NSDictionary *)resultDict     {
    NSDictionary *alipayResultDict = resultDict;
    
    
    // isProcessUrlPay 代表 支付宝已经处理该URL
    if ([alipayResultDict[@"isProcessUrlPay"] boolValue]) {
        // returnUrl 代表 第三方App需要跳转的成功页URL
        NSString *resultCode = alipayResultDict[@"resultCode"];
        if (!IsStrEmpty(resultCode)) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SOSpayH5SuccessNotification object:nil userInfo:alipayResultDict];
            return;
        }
    }

    NSLog(@"%@", alipayResultDict);
    AlipayStatusCode statusCode = [(NSNumber *)[alipayResultDict objectForKey:@"resultStatus"] intValue];
    switch (statusCode) {
        case AlipaySuccess:
        {
            self.errorMsg = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:SOSpaySuccessNotification object:nil];
        }
            break;
        case AlipayFail:
        {
            self.errorMsg = [alipayResultDict objectForKey:@"memo"];
            if (self.errorMsg.length == 0) {
                self.errorMsg = MSGAlipayError;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:SOSpayFailNotification object:nil];
            break;
        }
        case AlipayCancel:
        {
            self.errorMsg = [alipayResultDict objectForKey:@"memo"];
            if (self.errorMsg.length == 0) {
                self.errorMsg = MSGAlipayCancel;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:SOSpayFailNotification object:nil];
            break;
        }
        case AlipayConnectError:
        {
            self.errorMsg = [alipayResultDict objectForKey:@"memo"];
            if (self.errorMsg.length == 0) {
                self.errorMsg = MSGAlipayConnectError;
            }
//            支付宝失败
            [[NSNotificationCenter defaultCenter] postNotificationName:SOSpayFailNotification object:nil];
        }
            break;
        default:
            break;
    }
}

- (void)handleAlipayResult:(NSString *)result     {
    NSDictionary *alipayResultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"%@", alipayResultDict);
    AlipayStatusCode statusCode = [(NSNumber *)[alipayResultDict objectForKey:@"ResultStatus"] intValue];
    switch (statusCode) {
        case AlipaySuccess:
        {
            self.errorMsg = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:SOSpaySuccessNotification object:nil];
        }
            break;
        case AlipayFail:
        case AlipayCancel:
        case AlipayConnectError:
        {
            self.errorMsg = [alipayResultDict objectForKey:@"memo"];
            [[NSNotificationCenter defaultCenter] postNotificationName:SOSpayFailNotification object:nil];
        }
            break;
        default:
            break;
    }
}
@end
