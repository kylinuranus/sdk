//
//  SOSBiometricsManager.h
//  Onstar
//
//  Created by TaoLiang on 2017/11/9.
//  Copyright © 2017年 onStar. All rights reserved.
//

#import <Foundation/Foundation.h>
//只对外暴露错误枚举，减少编译量
#import <LocalAuthentication/LAError.h>


typedef void(^BiometricsSuccessBlock)(void);
typedef void(^BiometricsErrorBlock)(NSError *error);

@interface SOSBiometricsManager : NSObject

/**
 是否支持生物密码(touch id \ face id)

 @return Bool
 */
+ (BOOL)isSupportBiometrics;

/**
 是否支持touch id

 @return bool
 */
+ (BOOL)isSupportTouchId;

/**
 是否支持face id

 @return bool
 */
+ (BOOL)isSupportFaceId;

/**
 用户是否在安吉星启用生物密码,会和系统中的设置同步一次
 
 @return bool
 */
+ (BOOL)isUserOpenBiometriesAuthentication;


/**
 更新生物密码是否打开的状态

 @param isOpen 是否打开
 */
+ (void)updateBiometricsState:(BOOL)isOpen;


/**
 判断是否需要提醒用户开启生物认证，需要的情况下，弹出alert，使用block回调

 @param chooseToOpen 用户选择前往个人中心设置
 @param inputPinCode 用户选择输入pin码
 @return 是否需要提醒用户开启生物认证
 */
+ (BOOL)shouldRemindUserOpenBiometricsAlert:(void (^)(void))chooseToOpen inputPinCode:(void (^)(void))inputPinCode;

/**
 开始生物认证

 @param successBlock 成功回调
 @param errorBlock 失败回调
 */
+ (void)showBiometricsWithSuccessBlock:(BiometricsSuccessBlock)successBlock errorBlock:(BiometricsErrorBlock)errorBlock;
+ (void)showBiometricsWithLocalizedReason:(NSString *)reason SuccessBlock:(BiometricsSuccessBlock)successBlock errorBlock:(BiometricsErrorBlock)errorBlock;




@end
