//
//  SOSRemoteTool.h
//  Onstar
//
//  Created by Coir on 2018/4/16.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface SOSRemoteTool : NSObject
@property (nonatomic, assign, readonly) SOSRemoteOperationType lastOperationType;
@property (nonatomic, assign, readonly) RemoteControlStatus operationStastus;


///apple watch需要调用设置参数
@property (nonatomic, copy) NSString *parameter;

+ (instancetype)sharedInstance;

/// 判断操作类型字段是否为闪灯鸣笛
+ (BOOL)isHornAndFlashMode:(SOSRemoteOperationType)type;

/// 判断操作类型字段是否为下发 POI 点
+ (BOOL)isSendPOIOperation:(SOSRemoteOperationType)type;

+(void)startHVACSetting;
/// 发起车辆操作请求
- (void)startOperationWithOperationType:(SOSRemoteOperationType)type;

/// 发送到车 Type 仅限 TBT / ODD / Auto , 传入其它值不进行操作
- (void)sendToCarWithOperationType:(SOSRemoteOperationType)type AndPOI:(SOSPOI *)poi;
/// 通过 Vin 号下发到车  仅限 TBT / ODD / Auto , 传入其它值不进行操作
- (void)sendToCarWithOperationType:(SOSRemoteOperationType)type  Vin:(NSString *)vin AndPOI:(SOSPOI *)poi;

/// 发起车辆操作请求
- (void)startOperationWithOperationType:(SOSRemoteOperationType)type WithParameters:(NSString *)parameter;

- (void)checkAuthWithOperationType:(SOSRemoteOperationType)type Parameters:(NSString *)parameter Success:(void (^)(SOSRemoteOperationType type, NSString *parameter))success Failure:(void (^)(void))failure;

//检查套餐包
+ (BOOL)checkPackageServiceInPage:(UIViewController *)selfVc WithType:(SOSRemoteOperationType)type;

+ (NSString *)getActionResultMessageWithType:(SOSRemoteOperationType)type AndStaus:(RemoteControlStatus)status ErrorCode:(NSString *)errorCode;

///弹出PIN验证页面(登录后)，验证pin码但不做车辆操作，比如enroll验证pin
- (void)checkPINCodeSuccess:(void (^)(void))success;

/// 更新 Token, PIN 网络校验
+ (void)upgradeTokenWithInputPwd:(NSString *)pwd Success:(void (^)(void))success Failure:(void (^)(NSString *))failure;

///登录前验证pin码，不涉及车辆操作
- (void)checkPINCodeWithIdpid:(NSString *)idpid Success:(void (^)(void))success;

/// 获取存储的车辆位置
- (SOSPOI *)loadSavedVehicleLocation;



/**
 下发车辆操作，手表直接调用

 @param type 车辆操作类型
 @param needResponse 不知道干嘛的
 */
- (void)startServiceWithOperationType:(SOSRemoteOperationType)type withResponse:(BOOL)needResponse;


/**
 For Apple Watch，返回套餐包报错信息

 @param type 远程操作种类
 @return 套餐包报错信息
 */
+ (AppleWatchOperationResultStatus)watch_checkPackageWithType:(SOSRemoteOperationType)type;


/*
 
 ** 监测指令下发状态 使用范例
 
[[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOS_VEHICLE_OPERATE_NOTIFICATION object:nil] subscribeNext:^(NSNotification *x) {
    NSDictionary *userInfo = x.userInfo;
//	@{@"state":@(RemoteControlStatus), @"OperationType" : @(SOSRemoteOperationType) , @"message": message}
    SOSRemoteOperationType operationType = [userInfo[@"OperationType"] intValue];
    if (operationType == SOSRemoteOperationType_UnLockCar) {
        RemoteControlStatus state = [userInfo[@"state"] intValue];
        switch (state) {
            case RemoteControlStatus_InitSuccess:
                
                break;
            case RemoteControlStatus_OperateSuccess:
                
                break;
            case RemoteControlStatus_OperateTimeout:
            case RemoteControlStatus_OperateFail:
                
                break;
            default:
                break;
        }
    }
}];
 
*/

@end
