//
//  SOSkeyChain.h
//  keyChain
//
//  Created by Gennie Sun on 15/6/30.
//  Copyright (c) 2015年 Gennie Sun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOSkeyChain : NSObject

//+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service;

+ (void)save:(NSString *)service data:(id)data;

//返回最初解析的值 用于aes加密过的数据
+ (id)loadOriginalObject:(NSString *)service;

+ (id)load:(NSString *)service;

+ (void)delete:(NSString *)service;
@end
