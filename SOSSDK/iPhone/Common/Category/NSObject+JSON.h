//
//  NSObject+JSON.h
//  Onstar
//
//  Created by Joshua on 15/9/9.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JSON)

- (NSString *)toJson;

/// 清除单例对象持有的对象,属性
- (void)clearSharedInstancePropertys;

@end
