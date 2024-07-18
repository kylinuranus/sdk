//
//  SOSNetworkOperation.h
//  OnStarAFNetWork
//
//  Created by Gennie Sun on 15/8/20.
//  Modified by Joshua Xu on 15/8/31.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSNetWorkCacheConfig.h"
#import "AFNetworking.h"



#define HTTP_TIME_OUT_NORMAL    60

@class SOSNetworkOperation;
/**
 *  请求成功回调
 *
 *  @param statusCode , operation 回调block
 */
typedef void (^SOSSuccessBlock)(SOSNetworkOperation *operation, id responseStr);

/**
 *  请求失败回调
 *
 *  @param statusCode , error 回调block
 */
typedef void (^SOSFailureBlock)(NSInteger statusCode, NSString *responseStr, NSError *error);


/**
 *  网络请求子项
 */
@interface SOSNetworkOperation : NSObject


/**
 状态码 兼容之前的版本
 */
@property (nonatomic, assign) NSInteger statusCode;

/**
 callback中从self中获取
 是否是从缓存中取的数据
 */
@property (nonatomic, assign) BOOL isFromCache;

@property (nonatomic, strong) SOSNetWorkCacheConfig *cacheConfig;

@property (nonatomic ,strong) NSURLSessionDataTask *afOperation;

@property (nonatomic ,strong) NSURLSessionUploadTask *uploadTask;

// 是否允许打印 Log , 用于屏蔽某些无意义高频请求的 Log
@property (nonatomic, assign) BOOL enableLog;



/// 设置Http Get/Post方法。默认Post
- (void)setHttpMethod:(NSString *)httpMethod;

/// 设置Http headers
- (void)setHttpHeaders:(NSDictionary *)headerDict;

/// 设置Http超时时间，默认为60秒。车辆操作为180秒
- (void)setHttpTimeOutInterval:(NSInteger)timeOutInterval;



///推荐
+ (SOSNetworkOperation *)requestWithURL:(NSString *)url
                                 params:(NSString *)params
                           successBlock:(SOSSuccessBlock)successBlock
                           failureBlock:(SOSFailureBlock)failureBlock;

+ (SOSNetworkOperation *)requestWithURL:(NSString *)url
                                 params:(NSString *)params
                           successBlock:(SOSSuccessBlock)successBlock
                           failureBlock:(SOSFailureBlock)failureBlock
                   needReturnSourceData:(BOOL)needReturnSourceData;

- (SOSNetworkOperation *)initWithNOSSLURL:(NSString *)url
                              params:(NSString *)params
                needReturnSourceData:(BOOL)needReturnSourceData
                        successBlock:(SOSSuccessBlock)successBlock
                             failureBlock:(SOSFailureBlock)failureBlock;



/**
 接口带缓存
目前支持读写  只读
 */
+ (SOSNetworkOperation *)requestWithURL:(NSString *)url
                                 params:(NSString *)params
                            cacheConfig:(SOSNetWorkCacheConfig *)cacheConfig
                           successBlock:(SOSSuccessBlock)successBlock
                           failureBlock:(SOSFailureBlock)failureBlock;

/// 异步请求
- (void)start;

/// 同步请求
- (void)startSync;

- (void)pause;

- (void)resume;

- (void)cancel;

//上传文件
+ (SOSNetworkOperation *)requestWithURL:(NSString *)url
                                 params:(NSString *)params
                           constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                           successBlock:(SOSSuccessBlock)successBlock
                           failureBlock:(SOSFailureBlock)failureBlock;
- (void)startUploadTask;

//开启网络状态监听
+(void)netWorkStatusStart;

@end




@interface SOSNetworkOperation ()
///不推荐使用的方法
- (SOSNetworkOperation *)initWithURL:(NSString *)url
                              params:(NSString *)params
                        successBlock:(SOSSuccessBlock)successBlock
                        failureBlock:(SOSFailureBlock)failureBlock;// MJExtensionDeprecated("不推荐使用");


- (SOSNetworkOperation *)initWithURL:(NSString *)url
                              params:(NSString *)params
                needReturnSourceData:(BOOL)needReturnSourceData
                        successBlock:(SOSSuccessBlock)successBlock
                        failureBlock:(SOSFailureBlock)failureBlock;// MJExtensionDeprecated("不推荐使用");


- (SOSNetworkOperation *)initWithURL:(NSString *)url
                              params:(NSString *)params
                           enableLog:(BOOL)enableLog
                needReturnSourceData:(BOOL)needReturnSourceData
                needSSLPolicyWithCer:(BOOL)needSSLPolicyWithCer
                         cacheConfig:(SOSNetWorkCacheConfig *)cacheConfig
                        successBlock:(SOSSuccessBlock)successBlock
                        failureBlock:(SOSFailureBlock)failureBlock;

- (void)cancelAllRequest;

+ (NSString *)getFlutterCerString ;


- (void)setHttpbody2:(NSData *)bodyData ;
@end
