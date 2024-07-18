//
//  Order.m
//  AlixPayDemo
//
//  Created by 方彬 on 11/2/13.
//
//

#import "Order.h"
#ifdef SOSSDK_SDK
#import <SOSSDK/SOSPay.h>
#endif
@implementation Order

@synthesize dict;
- (id)init     {
    self = [super init];
    dict = [[NSMutableDictionary alloc] init];
    return self;
}

- (NSString *)description {
	NSMutableString * discription = [NSMutableString string];
    if (self.partner) {
        [discription appendFormat:@"partner=\"%@\"", self.partner];
    }
	
    if (self.seller) {
        [discription appendFormat:@"&seller_id=\"%@\"", self.seller];
    }
	if (self.tradeNO) {
        [discription appendFormat:@"&out_trade_no=\"%@\"", self.tradeNO];
    }
	if (self.productName) {
        [discription appendFormat:@"&subject=\"%@\"", self.productName];
    }
	
	if (self.productDescription) {
        [discription appendFormat:@"&body=\"%@\"", self.productDescription];
    }
	if (self.amount) {
        [discription appendFormat:@"&total_fee=\"%@\"", self.amount];
    }
    if (self.notifyURL) {
        [discription appendFormat:@"&notify_url=\"%@\"", self.notifyURL];
    }
	
    if (self.service) {
        [discription appendFormat:@"&service=\"%@\"",self.service];//mobile.securitypay.pay
    }
    if (self.paymentType) {
        [discription appendFormat:@"&payment_type=\"%@\"",self.paymentType];//1
    }
    
    if (self.inputCharset) {
        [discription appendFormat:@"&_input_charset=\"%@\"",self.inputCharset];//utf-8
    }
    if (self.itBPay) {
        [discription appendFormat:@"&it_b_pay=\"%@\"",self.itBPay];//30m
    }
    if (self.showUrl) {
        [discription appendFormat:@"&show_url=\"%@\"",self.showUrl];
    }
    if (self.rsaDate) {
        [discription appendFormat:@"&sign_date=\"%@\"",self.rsaDate];
    }
    if (self.appID) {
        [discription appendFormat:@"&app_id=\"%@\"",self.appID];
    }
	for (NSString * key in [self.extraParams allKeys]) {
		[discription appendFormat:@"&%@=\"%@\"", key, [self.extraParams objectForKey:key]];
	}
	return discription;
}

- (NSString *)toSignStr     {
    NSMutableString * description = [NSMutableString string];

    if (/* DISABLES CODE */ (0)) {
        [description appendFormat:@"_input_charset=%@",self.inputCharset];//utf-8
        [dict setObject:self.inputCharset forKey:@"_input_charset"];
    }
    if (self.wapFormat) {
        [description appendFormat:@"format=%@",self.wapFormat];
        [dict setObject:self.wapFormat forKey:@"format"];
    }

    if (self.partner) {
        [description appendFormat:@"&partner=%@", self.partner];
        [dict setObject:self.partner forKey:@"partner"];
    }
    
    NSString *reqData = [NSString stringWithFormat:@"<auth_and_execute_req><request_token>2014062788ee33d50bdea592f229430d043dce84</request_token></auth_and_execute_req>"];
    [description appendFormat:@"&req_data=%@", reqData];
    [dict setObject:reqData forKey:@"req_data"];
	
    NSString *reqId = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
    [description appendFormat:@"&req_id=%@", reqId];
    [dict setObject:reqId forKey:@"req_id"];
    
    [description appendFormat:@"&sec_id=0001"];
    [dict setObject:@"0001" forKey:@"sec_id"];
#ifdef SOSSDK_SDK
    [description appendFormat:SOSPayServicePamara];
    [dict setObject:SOSPayAuthPamara forKey:@"service"];
#endif
    [description appendFormat:@"&v=2.0"];
    [dict setObject:@"2.0" forKey:@"v"];
    
	return description;
}
@end
