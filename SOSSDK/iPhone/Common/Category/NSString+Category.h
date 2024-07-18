//
//  NSString+Category.h
//  LBSTest
//
//  Created by jieke on 2019/6/18.
//  Copyright © 2019 jieke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Category)

/** 判断字符串为空 */
+ (BOOL)isBlankString:(NSString *)string;
+ (NSString *)getBirthday:(NSString *)idNum;
/** 替换为斜线 */
+ (NSString *)replaceDiagonalLine:(NSString *)string;
/** 替换斜线为中华线 */
+ (NSString *)replaceObliqueLine:(NSString *)string;
/** 去掉GB单位 */
+ (CGFloat)removeGB:(NSString *)string;

/** 判断是否手机号 */
+ (BOOL)isPhoneNumber:(NSString *)string;

/** 车牌号5位验证 */
+ (BOOL)validateCarNo:(NSString *)carNo;
/** 车牌号6位验证 */
+ (BOOL)validateCarNoSixCount:(NSString *)carNo;

+ (NSString *)appendCdSuff:(NSString *)orgString;


@end

