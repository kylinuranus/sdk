//
//  SOSLifeThirdFuncsHelper.h
//  Onstar
//
//  Created by TaoLiang on 2019/1/7.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSQSModelProtol.h"

NS_ASSUME_NONNULL_BEGIN

//该类用来过滤哪些第三方快捷键是可见的，thirdFuncsVisible根据BA提供的权限表生成
@interface SOSLifeThirdFuncsHelper : NSObject
+ (instancetype)sharedInstance;

/**
 根据权限过滤后的当前用户可见的按钮
 */
@property (copy, nonatomic) NSArray<id<SOSQSModelProtol>> *filterdTotalFuncs;

- (NSArray<id<SOSQSModelProtol>> *)filterWithServerResponse:(NSArray <id<SOSQSModelProtol>>*)serverThirdFuncs;

- (BOOL)saveThirdFuncs:(NSArray<id<SOSQSModelProtol>> *)funcs;

@end

NS_ASSUME_NONNULL_END
