//
//  PackageUtil.h
//  Onstar
//
//  Created by Vicky on 16/6/30.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PackageUtil : NSObject

//Sum:3
//流量规则

//获取流量包列表

//加包
//获取支付列表
//+ (void)loadChannel:(NSString *)params_ successHandler:(void(^)(NSArray *chList))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;

/**
 iap支付成功后调用服务器
 */
+ (void)payParams:(NSDictionary *)dic successHandler:(void(^)(id code))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_ ;

/** 后视镜iap支付成功后调用服务器 */
+ (void)payRearviewMirrorServiceParams:(NSDictionary *)dic successHandler:(void(^)(id code))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure;


+ (void)getPackageServiceSuccess:(void (^)(SOSGetPackageServiceResponse*userfulDic))completion failed:(void(^)(NSString *responseStr, NSError *error))failCompletion;

@end
