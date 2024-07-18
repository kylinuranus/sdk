//
//  SOSInfoFlowNetworkEngine.h
//  Onstar
//
//  Created by TaoLiang on 2018/12/19.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^SOSIFCompletionBlock)(id data);
typedef void (^SOSIFErrorBlock)(NSInteger statusCode, NSString *responseStr, NSError *error);

NS_ASSUME_NONNULL_BEGIN

@interface SOSInfoFlowNetworkEngine : NSObject



/**
 请求信息流数据

 @param completionBlock 成功回调
 @param errorBlock 失败回调
 @return 该请求
 */
+ (SOSNetworkOperation *)requestInfoFlowsWithLat:(double)lat
                                             lon:(double)lon
                                 completionBlock:(SOSIFCompletionBlock)completionBlock
                                      errorBlock:(SOSIFErrorBlock)errorBlock;


/**
 删除某条信息流

 @param bid bid
 @param idt idt
 @param completionBlock 成功回调
 @param errorBlock 失败回调
 @return 该请求
 */
+ (SOSNetworkOperation *)deleteInfoFlow:(NSString *)bid
                                    idt:(NSString *)idt
                        completionBlock:(nullable SOSIFCompletionBlock)completionBlock
                             errorBlock:(nullable SOSIFErrorBlock)errorBlock;


/// NUMB架构订的方案，论坛的删除走social不走大数据
/// @param bid bid
/// @param completionBlock 成功回调
/// @param errorBlock 失败回调
+ (SOSNetworkOperation *)deleteForumHotInfoFlow:(NSString *)bid
                                completionBlock:(nullable SOSIFCompletionBlock)completionBlock
                                     errorBlock:(nullable SOSIFErrorBlock)errorBlock;


/// 删除广告信息流
/// @param bannerId bannerId
/// @param completionBlock 成功回调
/// @param errorBlock 失败回调
+ (SOSNetworkOperation *)deleteAdvertisementInfoFlow:(NSString *)bannerId
                                    completionBlock:(nullable SOSIFCompletionBlock)completionBlock
                                         errorBlock:(nullable SOSIFErrorBlock)errorBlock;



/**
 获取信息流设置列表

 @param completionBlock 成功回调
 @param errorBlock 失败回调
 @return 该请求
 */
+ (SOSNetworkOperation *)requestInfoFlowSettingsWithCompletionBlock:(SOSIFCompletionBlock)completionBlock
                                                         errorBlock:(SOSIFErrorBlock)errorBlock;


/**
 开关信息流

 @param setting 信息流对象
 @param completionBlock 成功回调
 @param errorBlock 失败回调
 @return 该请求
 */
+ (SOSNetworkOperation *)triggerInfoFlowSetting:(SOSInfoFlowSetting *)setting
                                completionBlock:(nullable SOSIFCompletionBlock)completionBlock
                                     errorBlock:(nullable SOSIFErrorBlock)errorBlock;


@end

NS_ASSUME_NONNULL_END
