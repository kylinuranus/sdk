//
//  NSString+JSON.m
//  Onstar
//
//  Created by Joshua on 15/9/9.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import "NSString+JSON.h"

@implementation NSString (JSON)

- (id)toBasicObject     {
    NSError *error;
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
}

- (NSString *)getDescriptionString    {
    NSString *errStr = self;
    NSDictionary *dic = [self toBasicObject];
    if ([dic isKindOfClass:[NSDictionary class]] && dic.allKeys.count) {
        NSString *tempStr = dic[@"description"];
        if (tempStr.length) {
            errStr = tempStr;
        }
    }
    return errStr;
}

/// 字符串对应 C String 长度,(汉字 * 2, 数字/字母 * 1)
-  (NSUInteger)cStringLength    {
    NSUInteger asciiLength = 0;
    for (NSUInteger i = 0; i < self.length; i++) {
        unichar uc = [self characterAtIndex: i];
        asciiLength += isascii(uc) ? 1 : 2;
    }
    return asciiLength;
}

@end
