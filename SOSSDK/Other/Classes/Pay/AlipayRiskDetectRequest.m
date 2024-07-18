//
//  AlipayRiskDetectRequest.m
//  Onstar
//
//  Created by Joshua on 14-12-2.
//  Copyright (c) 2014年 Shanghai Onstar. All rights reserved.
//

#import "AlipayRiskDetectRequest.h"

@implementation AlipayRiskDetectRequest

- (NSString *)sortedDescription     {
    NSMutableString *discription = [[NSMutableString alloc] init];
    
    if (self._input_charset) {
        [discription appendFormat:@"_input_charset=%@", self._input_charset];
    }
    
    if (self.buyer_account_no) {
        [discription appendFormat:@"&buyer_account_no=%@", self.buyer_account_no];
    }
    
    if (self.buyer_reg_date) {
        [discription appendFormat:@"&buyer_reg_date=%@", self.buyer_reg_date];
    }
    
    if (self.order_amount) {
        [discription appendFormat:@"&order_amount=%@", self.order_amount];
    }
    
    if (self.order_category) {
        [discription appendFormat:@"&order_category=%@", self.order_category];
    }
    
    if (self.order_credate_time) {
        [discription appendFormat:@"&order_credate_time=%@", self.order_credate_time];
    }
    
    if (self.order_item_name) {
        [discription appendFormat:@"&order_item_name=%@", self.order_item_name];
    }
    
    if (self.order_no) {
        [discription appendFormat:@"&order_no=%@", self.order_no];
    }
    
    if (self.partner) {
        [discription appendFormat:@"&partner=%@", self.partner];
    }
    
    if (self.scene_code) {
        [discription appendFormat:@"&scene_code=%@", self.scene_code];
    }
    
    if (self.seller_account_no) {
        [discription appendFormat:@"&seller_account_no=%@", self.seller_account_no];
    }
    
    if (self.seller_reg_date) {
        [discription appendFormat:@"&seller_reg_date=%@", self.seller_reg_date];
    }
    
    if (self.service) {
        [discription appendFormat:@"&service=%@", self.service];
    }
    
    if (self.terminal_type) {
        [discription appendFormat:@"&terminal_type=%@", self.terminal_type];
    }
    
    if (self.timestamp) {
        [discription appendFormat:@"&timestamp=%@", self.timestamp];
    }
    
    return discription;
}
@end
