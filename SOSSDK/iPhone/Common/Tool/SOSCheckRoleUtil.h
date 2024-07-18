//
//  SOSCheckRoleUtil.h
//  Onstar
//
//  Created by shoujun xue on 2/11/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOSCheckRoleUtil : NSObject

//车主
+ (BOOL)isOwner;
//访客
+ (BOOL)isVisitor;
//司机或代理
+ (BOOL)isDriverOrProxy;

//单独判断司机或者代理，预防以后司机和代理功能分开
+ (BOOL)isDriver;
+ (BOOL)isProxy;

///  unlogin(未登录)、visitor（访客）、owner（车主）、proxy（代理）、driver(司机)。
+ (NSString *)getCurrentRole;

+ (BOOL)checkVisitorInPage:(UIViewController *)page;
+ (BOOL)checkDriverProxyInPage:(UIViewController *)page;
// P&P service
+ (BOOL)checkPackageServiceAvailable:(NSString *)serviceIndicator;

+ (BOOL)checkPackageServiceAvailable:(NSString *)serviceIndicator andNeedPopError:(BOOL)needPop;
+ (BOOL)checkPackageExpired:(UIViewController *)controller;
@end
