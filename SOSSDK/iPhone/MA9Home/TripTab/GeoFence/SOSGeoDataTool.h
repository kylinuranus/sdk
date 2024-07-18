//
//  SOSGeoDataTool.h
//  Onstar
//
//  Created by Coir on 21/10/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

//#import "SOSGeofecingRemindViewController.h"
#import <Foundation/Foundation.h>
#import "SOSTripNoGeoView.h"
#import "SOSGeoMapVC.h"
NS_ASSUME_NONNULL_BEGIN
/// 更新围栏通知的类型
typedef enum {
    /// 更新围栏整体
    SOSChangeGeoType_Update_Geo = 1,
    /// 更新围栏开关
    SOSChangeGeoType_Update_Switch,
    /// 更新围栏中心/半径
    SOSChangeGeoType_Update_CenterAndRadius,
    /// 更新围栏提醒方式, 提醒设置页面点击保存
    SOSChangeGeoType_Update_AlertAndMobile,
    /// 更新围栏提醒手机号, 修改手机号页面点击确认
    SOSChangeGeoType_Update_Mobile,
    /// 更新围栏名称
    SOSChangeGeoType_Update_Name,
    SOSChangeGeoType_Update_Fix
}	SOSChangeGeoType;

@interface SOSGeoDataTool : NSObject

/// 校验围栏信息是否完整
+ (BOOL)checkGeoInfoWithGeofence:(NNGeoFence *)geofence;

/** 获取用户当前 电子围栏 */
+ (void)getGeoFencingSuccessHandler:(void(^)(NSArray * fences))success failureHandler:(void(^)( NSString *responseStr, NSError *error))failure;

/** 更新/删除 电子围栏 */
+ (void)updateGeoFencingWithGeo:(NNGeoFence *)geo Success:(SOSSuccessBlock)successBlock Failure:(SOSFailureBlock)failureBlock;

+ (void)backToAddGeoMapVCWithFromVC:(UIViewController *)fromVC AndGeoFence:(NNGeoFence *)geoFence;

/** 获取用户当前 LBS 电子围栏 */
+ (void)getLBSGeoFencingWithLBSDeviceID:(NSString *)LBSDeviceID SuccessHandler:(void(^)(NSArray * fences))success failureHandler:(void(^)( NSString *responseStr, NSError *error))failure;

/** 添加/更新/删除 LBS 电子围栏 */
+ (void)updateLBSGeoFencingWithGeo:(NNGeoFence *)geo Success:(SOSSuccessBlock)successBlock Failure:(SOSFailureBlock)failureBlock;

/// 增加/更新/删除 电子围栏
+ (void)updateGeoFencingWithGeo:(NNGeoFence *)geo isLBSMode:(BOOL)isLBSMode  Success:(SOSSuccessBlock)successBlock Failure:(SOSFailureBlock)failureBlock;


+ (void)setGeoCenterWithPOI:(SOSPOI *)poi FromVC:(UIViewController *)fromVC;

+ (NNGeoFence *)getGeoFenceWithPOI:(SOSPOI *)resultPOI;


/**
 绑定手机号, 获取图片验证码
 @param imgUrl 图片验证码地址
 */
+ (void)getImgCodeForUrl:(nonnull NSString*)imgUrl responseSuccess:(void (^)(UIImage *img, NSString *imgToken))successBlock responseFailure:(SOSFailureBlock)failureBlock;

/// 绑定手机号, 获取短信验证码
+ (void)getSMSCodeForUrl:(nonnull NSString *)smsUrl withImgCode:(NSString *)imgCode imgToken:(NSString *)imgToken andPhoneNum:(NSString *)phone responseSuccess:(void (^)(NSString *SMSCode, NSString *SMSToken))successBlock responseFailure:(SOSFailureBlock)failureBlock ;

/// 绑定手机号, 校验短信验证码
+ (void)verifySMSCodeWithSMSCode:(NSString *)smsCode SMSToken:(NSString *)smsToken Success:(void (^)(NSString *authToken))successBlock Failure:(SOSFailureBlock)failureBlock;

+ (void)replenishVerifySMSCodeWithMobile:(NSString *)mobile SMSCode:(NSString *)smsCode Success:(void (^)(NSString *authToken))successBlock Failure:(SOSFailureBlock)failureBlock       ;

@end
NS_ASSUME_NONNULL_END
