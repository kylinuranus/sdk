//
//  NSString+Category.m
//  LBSTest
//
//  Created by jieke on 2019/6/18.
//  Copyright © 2019 jieke. All rights reserved.
//

#import "NSString+Category.h"

@implementation NSString (Category)

#pragma mark 字符串相关判断
+ (NSString *)appendCdSuff:(NSString *)orgString{
    if (SOS_CD_PRODUCT) {
        return [orgString stringByAppendingString:@"_sdkcd"];
    }
    return orgString;
}

// 判断字符串为空
+ (BOOL)isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        return YES;
    }
    if ([string isEqualToString:@"(null)"] || [string isEqualToString:@"null"]) {
        return YES;
    }    
    return NO;
}
+ (NSString *)getBirthday:(NSString *)idNum {
    NSRange range = NSMakeRange(6, 8);
    NSString *s1 = [idNum substringWithRange:range];
    NSString *year = [s1 substringToIndex:4];
    NSRange range01 = NSMakeRange(4, 2);
    NSString *month = [s1 substringWithRange:range01];
    NSRange range02 = NSMakeRange(6, 2);
    NSString *day = [s1 substringWithRange:range02];
    NSString *birthday = [NSString stringWithFormat:@"%@-%@-%@",year,month,day];
    return birthday;
}
#pragma mark 替换为斜线
+ (NSString *)replaceDiagonalLine:(NSString *)string {
    NSString *str = [string stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    return str;
}
#pragma mark 替换斜线为中华线
+ (NSString *)replaceObliqueLine:(NSString *)string {
    NSString *str = [string stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    return str;
}
#pragma mark 去掉GB单位
+ (CGFloat)removeGB:(NSString *)string {
    NSRange range = [string rangeOfString:@"GB"];//匹配得到的下标
    NSString *str = [string substringToIndex:range.location];//截取范围内的字符串
    return [str floatValue];
}

/**
 *  @brief  判断是否手机号码格式
 *  @return YES,NO
 */
+ (BOOL)isPhoneNumber:(NSString *)string {
    NSLog(@"---isPhoneNumber:%@", string);
    NSString *phoneNumRegExp = @"^(13|14|15|16|17|18|19)\\d{9}$";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneNumRegExp];
    return [test evaluateWithObject:string];
}
#pragma mark 车牌号5位验证
/** 车牌号5位验证 */
+ (BOOL)validateCarNo:(NSString *)carNo {
    NSString *carRegex = @"^[\u4e00-\u9fa5]{1}[a-zA-Z]{1}[a-zA-Z_0-9]{4}[a-zA-Z_0-9_\u4e00-\u9fa5]$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    NSLog(@"carTest is %@",carTest);
    return [carTest evaluateWithObject:carNo];
}
#pragma mark 车牌号6位验证
/** 车牌号6位验证 */
+ (BOOL)validateCarNoSixCount:(NSString *)carNo {
    NSString *carRegex = @"^[\u4e00-\u9fa5]{1}[a-zA-Z]{1}[a-zA-Z_0-9]{5}[a-zA-Z_0-9_\u4e00-\u9fa5]$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    NSLog(@"carTest is %@",carTest);
    return [carTest evaluateWithObject:carNo];
}
@end
