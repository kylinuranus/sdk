//
//  NSString+JWT.h
//  Onstar
//
//  Created by Joshua on 15/10/8.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JWT)

+ (NSString *)jwtDecode :(NSString *)response;
+ (NSString *)jwtEncode:(NSString *)inputString;

- (BOOL)myContainsString:(NSString*)other;

//对用户敏感信息进行截断处理: 规则---前3****后4
- (NSString *)stringInterceptionHide;
- (NSString *)stringInterceptionHideSix;//前三后4中间6棵*
- (NSString *)govidStringInterceptionHide;

/**
 地址隐藏规则
 @return
 */
- (NSString *)addressStringInterceptionHide;
//若邮箱中“@”之前的字符数大于3位，则隐藏“@”的前3位。如Aa***@126.com
//若邮箱中“@”之前的字符数小于等于3位，则隐藏“@”的前1位。如 *@126.com / A*@126.com / Aa*@126.com
- (NSString *)stringEmailInterceptionHide;

/**
 字符串分割出姓
 @return
 */
- (NSString *)stringSepFirstName;

/**
 字符串分割出名
 @return
 */
- (NSString *)stringSepLastName;

/**
 是否是用于注册的合法证件号
 @return
 */
- (BOOL)isValidateRegisterIdentification;

/**
 是否是用于注册的vin或govid
 @return
 */
- (BOOL)isValidateRegisterVINOrIDCard;

/**
 是否是用于注册的govid
 @return
 */
- (BOOL)isValidateIDCard ;

/**
是否用于注册的vin
 @return
 */
- (BOOL)isValidateVIN;
@end
