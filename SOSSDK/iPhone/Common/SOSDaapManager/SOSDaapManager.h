//
//  SOSDaapManager.h
//  Onstar
//
//  Created by TaoLiang on 2018/2/5.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSDaapFuncID.h"
#import "SOSMA8FuncID.h"
#import "SOSDaapFuncID83.h"
#import "SOSDaapFuncID84.h"
#import "SOSDaapFuncID85.h"
#import "SOSDaapFuncID90.h"
#import "SOSDaapFuncID91.h"
#import "SOSDaapFuncID92.h"
#import "SOSDaapFuncID93.h"

@interface SOSDaapManager : NSObject


/**
 记录用户设备信息(只会调用一次)
 */
+ (void)sendClientInfo;

/**
 记录用户行为()

 @param triggerPointId 触发点(类似原来的functionId)
 */
+ (void)sendActionInfo:(NSString *)triggerPointId;
+ (void)sendActionInfo:(NSString *)triggerPointId responseSuccess:(void(^)(void))success_ responseFail:(void(^)(void))fail_ ;


/**
 记录系统操作日志(暂时实现banner和layout(页面记时))
 */
+ (void)sendSysBanner:(NSString *)bannerId funcId:(NSString *)funcId;
//根据需求不同传对应的type
+ (void)sendSysBanner:(NSString *)bannerId type:(NSString *)type funcId:(NSString *)funcId;
+ (void)sendSysLayout:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime funcId:(NSString *)funcId;
+ (void)sendSysLayout:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime loadStatus:(BOOL)status funcId:(NSString *)funcId;

+ (void)sendSysLayout:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime interfaceStatusCode:(NSString *)code funcId:(NSString *)funcId;
/**
 
 @param startTime
 @param endTime
 @param interv 最大时长
 @param status
 @param funcId
 */
+ (void)sendSysLayout:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime maxUploadTime:(NSTimeInterval)interv loadStatus:(BOOL)status funcId:(NSString *)funcId;
/**
 获取保存的uuid
 
 @return uudi
 */
+ (NSString *)getUUID;

+ (NSString *)getScrrenResolution;

@end
