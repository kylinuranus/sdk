//
//  NSObject+JSON.m
//  Onstar
//
//  Created by Joshua on 15/9/9.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import "NSObject+JSON.h"

@implementation NSObject (JSON)

- (id)copyWithZone:(NSZone *)zone    {
    
    if([[self className] isEqualToString:@"__NSCFType"]){//视频播放崩溃问题,特殊处理
          return nil;
          
      }else{
          
          id copy = [[self class] new];
          [copy mj_setKeyValues:self.mj_keyValues];
          return copy;
      }
}

- (NSString *)toJson     {
    NSError *error = nil;
    NSString *jsonString = nil;
    if ([self isKindOfClass:[NSDictionary class]] ||
        [self isKindOfClass:[NSArray class]]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:self
                                                    options:kNilOptions error:&error];
        if (error) {
            jsonString = @"";
        }else {
            jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }   else if ([self isKindOfClass:[NSData class]])   {
        jsonString = [[NSString alloc] initWithData:(NSData *)self encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

/// 清除单例对象持有的对象,属性
- (void)clearSharedInstancePropertys	{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[self class] mj_enumerateProperties:^(MJProperty *property, BOOL *stop) {
            if (property.type.isNumberType) {
                [self setValue:@0 forKey:property.name];
            }	else	{
                [self setValue:nil forKey:property.name];
            }
        }];
    });
}

@end
