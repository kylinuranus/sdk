//
//  SOSGreetingUtil.h
//  Onstar
//
//  Created by lmd on 2017/9/29.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSGreetingCache.h"
//#import "SOSFlutterManager.h"

@interface SOSGreetingModel : NSObject
@property (nonatomic, assign) NSInteger greetingsID;
@property (nonatomic, copy) NSString *functionName;
@property (nonatomic, copy) NSString *condition;
@property (nonatomic, copy) NSString *role;
@property (nonatomic, copy) NSString *greetings;
@property (nonatomic, copy) NSString *subGreetings;
@property (nonatomic, copy) NSString *linkText;
@property (nonatomic, copy) NSString *linkType;
@property (nonatomic, copy) NSString *target;
@property (nonatomic, copy) NSString *startDate;
@property (nonatomic, copy) NSString *endDate;
@property (nonatomic, copy) NSString *isOpen;
@property (nonatomic, copy) NSString *funcId;

//车况icon图标
@property (nonatomic, copy) NSString *icon;

@end

typedef NS_ENUM(NSInteger, SOSGreetingType) {
    SOSGreetingTypeVehicle,//智享车
    SOSGreetingTypeStarTravel,//星旅程
    SOSGreetingTypeLife,//悦生活
    SOSGreetingTypeVehicleCondition,//车况
    SOSGreetingTypeVehicleInfo,//车辆信息
    SOSGreetingTypeFootmark//足迹
};


@interface SOSGreetingManager : NSObject
//@property (nonatomic, assign) BOOL flutterEnable;
//@property (nonatomic, assign) BOOL isFlutterChangeVehicle;//是否Fluttter切车重登陆

/**
 当前角色问候语
 */
@property (nonatomic, strong) id roleGreeting;

/// 流量包data
@property (nonatomic, strong) id flowData;

/// 用户流量包剩余流量
@property (nonatomic, strong) id packageRemainData;

/// 安吉星套餐包
@property (nonatomic, strong) id packageData;

/// 用户套餐包剩余天数
@property (nonatomic, strong) id packageRemainDays;


/**
足迹data
 */
//@property (nonatomic, strong) id footmarkData;

/**
 车况状态
 */
@property (nonatomic, assign) RemoteControlStatus vehicleStatus;


/**
 外部调用
 */
//- (void)getFootMarkData;

+ (instancetype)shareInstance ;
+ (NSString *)role ;
- (SOSGreetingModel *)getGreetingModelWithType:(SOSGreetingType)type;


/**
 强制刷新问候语
 */
- (void)refreshGreeting;


/**
 刷新首页头部问候语(包含 问候语接口 套餐包接口 gen10(4g流量包接口))
 note:不刷新车况,车况需调用刷车况接口
 */
- (void)refreshGreetingAndPackages;

/**
 清除某项卡片缓存
 强制刷新某项卡片
 @param name 需要清除卡片的名称
 */
- (void)clearCardCache:(NSString *)cardName;

- (void)refreshPackageIfNeeded;

/// 获取用户当前可用套餐包数据
- (void)getPackageListSuccess:(void (^)(NSMutableArray <NNPackagelistarray *> *packageArray))completion Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion;

- (void)getPackageRemainDaysSuccess:(void (^)(NSString *remainDay))completion Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion;

@end



