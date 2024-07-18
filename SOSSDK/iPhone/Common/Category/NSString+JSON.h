//
//  NSString+JSON.h
//  Onstar
//
//  Created by Joshua on 15/9/9.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JSON)

/// 字符串对应 C String 长度,(汉字 * 2, 数字/字母 * 1)
@property (nonatomic, assign, readonly) NSUInteger cStringLength;

- (id)toBasicObject;

- (NSString *)getDescriptionString;

@end
