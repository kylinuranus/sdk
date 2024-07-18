//
//  SOSReachability.h
//  Onstar
//
//  Created by Gennie Sun on 15/11/24.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import "AFNetworkReachabilityManager.h"
#import "AFNetworking.h"

typedef void (^successBlock)(NSString *status);
typedef void (^statusBlock)(NSInteger status);

@interface SOSReachability : AFNetworkReachabilityManager

/**
 *  根据AFNetworking检测网络状态
 *
 *  @param success 返回的回调结果
 	AFNetworkReachabilityStatusUnknown          = -1,
 	AFNetworkReachabilityStatusNotReachable     = 0,
    AFNetworkReachabilityStatusReachableViaWWAN = 1,
 	AFNetworkReachabilityStatusReachableViaWiFi = 2,
 */
+ (void)SOSNetworkStatuswithSuccessBlock:(statusBlock)success;

+ (void)networkStatusReachabilityBlock:(successBlock)success;


@end
