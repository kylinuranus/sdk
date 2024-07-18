//
//  AlipayClient.h
//  Onstar
//
//  Created by Joshua on 5/27/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PurchaseProxy.h"
#import "SOSPay.h"
typedef enum {
    AlipaySuccess                   = 9000,
    AlipayProcessing                = 8000,
    AlipayFail                      = 4000,
    AlipayCancel                    = 6001,
    AlipayConnectError              = 6002,
} AlipayStatusCode;


@interface AlipayClient : NSObject
@property (nonatomic, strong) NSString *errorMsg;
+ (id)sharedInstance;
+ (void)purgeInstance;
//- (void)pay;
//支付宝sdk使用msp产生的订单信息做为支付参数
- (void)payWithOrderString:(NSString*)orderStr;

- (void)handleAlipayDictResult:(NSDictionary *)resultDict;
@end
