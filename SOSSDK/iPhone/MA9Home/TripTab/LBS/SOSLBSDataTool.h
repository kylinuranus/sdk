//
//  SOSLBSDataTool.h
//  Onstar
//
//  Created by Coir on 23/10/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AMapGeoPoint;
@class SOSLBSPOI;

typedef enum {
    SOSLBSProtocolSavedStatus_Unknnow = 1,
    SOSLBSProtocolSavedStatus_Accepted,
    SOSLBSProtocolSavedStatus_Rejected
}	SOSLBSProtocolSavedStatus;

@interface SOSLBSDataTool : NSObject

- (void)getLBSPOIWithLBSDadaInfo:(NNLBSDadaInfo *)lbsInfo Success:(void (^)(SOSLBSPOI *lbsPOI))success Failure:(SOSFailureBlock)failure;

/// 两次加盐Md5
+ (NSString *)md5withDoubleSalt:(NSString *)inputStr;

/// 存储 md5 之后的密码
+ (void)savePassword:(NSString *)password WithDeviceID:(NSString *)deviceID;

/// 获取存储的密码 (md5 之后的密码)
+ (NSString *)getSavedPasswordWithDeviceID:(NSString *)deviceID;

/// 校验密码是否正确,密码为 md5 之前的 原生 String
+ (BOOL)checkPassword:(NSString *)password WithDeviceID:(NSString *)deviceID;

/// 存储 设备登录状态,用于判定设备是否需要输入密码
+ (void)saveDeviceLoginFlag:(BOOL)login WithDeviceID:(NSString *)deviceID;

/// 获取 设备登录状态,用于判定设备是否需要输入密码
+ (NSNumber *)getSavedLoginFlagWithDeviceID:(NSString *)deviceID;

/// 获取 LBS 协议状态,优先获取 UserDefaults 存储状态
+ (void)getUserProtocolSavedStatusSuccess:(void (^)(BOOL protocolStatus))success Failure:(SOSFailureBlock)failure;

/// 获取 LBS 协议状态,仅获取 UserDefaults 存储状态
+ (SOSLBSProtocolSavedStatus)getSavedUserProtocolSavedStatus;

/// 获取 LBS 协议状态,仅网络请求
+ (void)getLBSProtocolStatusSuccess:(void (^)(NSString *statusString))success Failure:(SOSFailureBlock)failure;

/// 更新 LBS 协议状态
+ (void)setLBSProtocolStatusSuccess:(SOSSuccessBlock)success Failure:(SOSFailureBlock)failure;

/// 添加/更新/删除 LBS 设备
+ (void)updateDeviceWithLBSDadaInfo:(NNLBSDadaInfo *)lbsInfo Success:(void (^)(NNLBSDadaInfo * lbsInfo, NSString *responseStr))success Failure:(SOSFailureBlock)failure;

/// 登录 LBS 设备
+ (void)loginWithDeviceID:(NSString *)deviceID AndPassword:(NSString *)passWord Success:(void (^)(NSDictionary *resultFlagDic))success Failure:(SOSFailureBlock)failure;

///获取当前用户的 LBS 设备列表
+ (void)getUserLBSListSuccess:(void (^)(NSString *description, NSArray *resultArray))success Failure:(SOSFailureBlock)failure;

///获取 LBS 设备当前定位
+ (void)getDeviceLocationWithLBSTrackingID:(NSString *)deviceID Success:(void (^)(NNLBSLocationPOI *lbsPOI))success Failure:(SOSFailureBlock)failure;

///获取 LBS 设备历史定位 (轨迹)     startTime/endTime 格式 yyyy-MM-dd HH:mm:ss
+ (void)getHistoryDeviceLocationWithLBSTrackingID:(NSString *)deviceID StartTime:(NSString *)startTime AndEndTime:(NSString *)endTime Success:(void (^)(NSArray <NNLBSLocationPOI *> * deviceLocationArray))success Failure:(SOSFailureBlock)failure;

/// 显示 LBS 协议
+ (void)showLBSProtocolViewWithCompleteHanlder:(void (^)(BOOL agreeStatus))completion;

@end
