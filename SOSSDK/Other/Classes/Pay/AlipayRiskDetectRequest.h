//
//  AlipayRiskDetectRequest.h
//  Onstar
//
//  Created by Joshua on 14-12-2.
//  Copyright (c) 2014年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlipayRiskDetectRequest : NSObject

@property(nonatomic, copy) NSString * sign;
@property(nonatomic, copy) NSString * sign_type;

@property(nonatomic, copy) NSString * service;
@property(nonatomic, copy) NSString * partner;
@property(nonatomic, copy) NSString * _input_charset;
@property(nonatomic, copy) NSString * timestamp;
@property(nonatomic, copy) NSString * terminal_type;

@property(nonatomic, copy) NSString * order_no;
@property(nonatomic, copy) NSString * order_credate_time;
@property(nonatomic, copy) NSString * order_category;
@property(nonatomic, copy) NSString * order_item_name;
@property(nonatomic, copy) NSString * order_amount;


@property(nonatomic, copy) NSString * scene_code;
@property(nonatomic, copy) NSString * buyer_account_no;

@property(nonatomic, copy) NSString *buyer_reg_date;
@property(nonatomic, copy) NSString *seller_account_no;
@property(nonatomic, copy) NSString *seller_reg_date;

- (NSString *)sortedDescription;
@end
