//
//  SOSAYChargeManager.h
//  Onstar
//
//  Created by Coir on 2018/10/25.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSReachability.h"

NS_ASSUME_NONNULL_BEGIN

@interface SOSAYChargeManager : NSObject

/// 进入安悦充电页面(服务授权/扫码充电)
+ (void)enterAYChargeVCIsFromCarLife:(BOOL)isFromCarLife;

/**
 进入安悦充电页面

 @param isFromCarLife 是否需要中间loading
 @param code 外部传入的扫码结果
 */
+ (void)enterAYChargeVCIsFromCarLife:(BOOL)isFromCarLife code:(nullable NSString *)code;
/// 根据服务状态进入安悦充电下一级页面
+ (void)enterAYChargeVCWithServiceStatus:(BOOL)status IsFromCarLife:(BOOL)isFromCarLife;
+ (void)enterAYChargeVCWithServiceStatus:(BOOL)status IsFromCarLife:(BOOL)isFromCarLife code:(nullable NSString *)code;
/// 根据用户信息,确定进入扫码充电页面或填充手机号页面
+ (void)enterAYChargeVCUseUserInfo;

/// 安悦 用户登录/注册
+ (void)loginAYSystemSuccess:(SOSSuccessBlock)successBlock failure:(SOSFailureBlock)failureBlock;

/// 查询当前用户是否存在在途订单
+ (void)checkAYUserOrderWithSessionID:(NSString *)sessionID Success:(SOSSuccessBlock)successBlock failure:(SOSFailureBlock)failureBlock;

+ (BOOL)checkUserPhoneNum;

/// 检查网络状态
+ (void)checkNetworkSuccess:(statusBlock)complete;

/// 获取验证码
+ (void)getAYUserVerifyCodeWithMobileNum:(NSString *)mobileNum Success:(SOSSuccessBlock)successBlock failure:(SOSFailureBlock)failureBlock;

@end

NS_ASSUME_NONNULL_END
