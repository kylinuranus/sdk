//
//  SOSDonateDataTool.h
//  Onstar
//
//  Created by Coir on 2018/9/17.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 积分公益操作类型
typedef enum {
    SOSDonateOperationType_Non = 0,
    /// 积分公益 登录
    SOSDonateOperationType_Login = 1,
    /// 积分公益 远程启动
    SOSDonateOperationType_Remote_Start,
    /// 积分公益 远程取消启动
    SOSDonateOperationType_Remote_StartCancel,
    /// 积分公益 车门上锁
    SOSDonateOperationType_LockCar,
    /// 积分公益 车门解锁
    SOSDonateOperationType_UnlockCar,
    /// 积分公益 车辆定位
    SOSDonateOperationType_Car_Location,
    /// 积分公益 闪灯鸣笛
    SOSDonateOperationType_LightAndHorn,
    /// 积分公益 驾驶行为评分
    SOSDonateOperationType_Behavior_Score,
    /// 积分公益 油耗排名
    SOSDonateOperationType_Fuel_Rank
}	SOSDonateOperationType;


@interface SOSDonateDataObj : NSObject

@property (nonatomic, copy) NSString *ID;

@property (nonatomic, copy) NSString *createdTs;

@property (nonatomic, copy) NSString *updatedTs;

@property (nonatomic, copy) NSString *projectName;

@property (nonatomic, copy) NSString *eventName;

@property (nonatomic, copy) NSString *targetIntegral;

@property (nonatomic, copy) NSString *donationIntegral;

@property (nonatomic, copy) NSString *supplementaryIntegral;

@property (nonatomic, copy) NSString *imageUrl;

@property (nonatomic, copy) NSString *projectDescription;

@property (nonatomic, copy) NSString *startDate;

@property (nonatomic, copy) NSString *endDate;

@property (nonatomic, copy) NSString *yesterdayDonationIntegral;

@end

@interface SOSDonateUserInfo : NSObject

//@property (nonatomic, copy) NSString *id;

@property (nonatomic, copy) NSString *createdTs;

@property (nonatomic, copy) NSString *donationIntegral;

@property (nonatomic, copy) NSString *earnIntegral;

@property (nonatomic, copy) NSString *idpUserId;

@property (nonatomic, copy) NSString *phoneNumber;

@property (nonatomic, copy) NSString *remainingIntegral;

@property (nonatomic, copy) NSString *updatedTs;

@property (nonatomic, copy) NSString *yesterdayDonationIntegral;

@property (nonatomic, copy) NSString *yesterdayEarnIntegral;

@end

@interface SOSDonateDataTool : NSObject
/// 添加登录监听.用于增加积分
+ (void)addLoginObserver;

/// 获取用户积分信息
+ (void)getDonateInfoSuccess:(SOSSuccessBlock)success Failure:(SOSFailureBlock)failure;

/// 获取参与过的活动
+ (void)getActivityListSuccess:(SOSSuccessBlock)success Failure:(SOSFailureBlock)failure;

/// 增加用户积分
+ (void)modifyUserDonateInfoWithActionType:(SOSDonateOperationType)operationType Success:(SOSSuccessBlock)success Failure:(SOSFailureBlock)failure;

/// 远程遥控操作 SOSRemoteOperationType 转换为 SOSDonateOperationType
+ (SOSDonateOperationType)getDonateOperationTypeWithRemoteOperationType:(SOSRemoteOperationType)remoteType;

@end
