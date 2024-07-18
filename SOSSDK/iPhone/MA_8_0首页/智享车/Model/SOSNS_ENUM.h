
//
//  SOSNS_ENUM.h
//  Onstar
//
//  Created by Genie Sun on 2017/8/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#ifndef SOSNS_ENUM_h
#define SOSNS_ENUM_h

typedef NS_ENUM(NSUInteger ,CELLSTATUS){
    UNLoginStatus,
    VisitorStatus,
    OwnerStatus
};

typedef NS_ENUM(NSUInteger ,SOSViewContentMode){
    SOSVehicleViewContentMode,
    SOSOnstarTripViewContentMode
};


typedef enum VehicleStatus     {
    STATUS_NONE                 = 0,
    GAS_GREEN_PERFECT           = 0x001,
    GAS_GREEN_GOOD              = 0x002,
    GAS_YELLOW                  = 0x010,
    GAS_RED                     = 0x100,
    
    OIL_GREEN                   = 0x003,
    OIL_YELLOW                  = 0x011,
    OIL_RED                     = 0x101,
    
    PRESSURE_GREEN              = 0x004,
    PRESSURE_YELLOW             = 0x012, //18
    PRESSURE_RED                = 0x102, //258
    
    BATTERY_GREEN               = 0x005,
    BATTERY_YELLOW              = 0x013,
    BATTERY_RED                 = 0x103,
    
    //My21 Global B
    BRAKE_GREEN                 = 0x006,
    BRAKE_YELLOW                = 0x014,
    BRAKE_RED                   = 0x104,
    
} VehicleStatus;

//车况分类
typedef NS_ENUM(NSUInteger, SOSVehicleConditionCategory) {
    VehicleConditionFine    = 0,        //车况优秀
    VehicleConditionNormal,             //车况正常
    TirePressureBad,                    //胎压红色告警
    FuelNotEnough,                      //燃油红色告警
    OilNotEnough,                       //机油红色告警
    BatteryNotEnough,                   //电池红色告警
    MoreThanOneBad,                     //2项及以上差
    NoVehicleConditionData,             //无车况数据
    VehicleConditionAbnormal,            //车况数据异常
    TirePressureLow,                    //胎压黄色告警,,
    FuelLow,                            //燃油黄色告警,,
    OilLow,                             //机油黄色告警,,
    BatteryLow,                         //电池黄色告警,,
    CHARGINGABORTED,                    //充电中断,,
    CHARGING,                           //充电中,,
    STATECHARGINGCOMPLETE,              //已充满,,
    BRAKEPADSNOTENOUGH,     //刹车片寿命即将耗尽
    BRAKEPADSLOW,       //刹车片磨损严重
};

typedef NS_ENUM(NSInteger ,SOSStarCardCellType) {
    //UBI
    SOSCardCellTypeInsurance = -99,
    /** 去哪 */
    SOSCardCellTypeGoWhere = 0,
    /** 规划出行 */
    SOSCardCellTypePlanTrip,
//    SOSCardCellTypeVehicleInsurance,
    /** 油耗水平 */
    SOSCardCellTypeFuelConsumption,
    /** 能耗水平 */
    SOSCardCellTypeEnergyConsumption,
    /** 驾驶行为评价 */
    SOSCardCellTypeDrivingBehavior,
    /** 我的足迹 */
    SOSCardCellTypeFootMark,
    /** LBS 安星定位 */
    SOSCardCellTypeLocation
};

typedef NS_ENUM(NSInteger ,SOSVehicleCardCellType) {
    SOSCardCellTypeStarFirst = 0,
    SOSCardCellTypeRemoteControl,
    SOSCardCellTypeCondition,
    SOSCardCellTypeBleKey,
    SOSCardCellTypeBleOwner,
    SOSCardCellTypeStarTravel,
    SOSCardCellTypePackage,
    SOSCardCellTypeAssessment,
    SOSCardCellTypeARVehicle,
    SOSCardCellTypeVehicleInfo
};

//MA9.0 我的模块
typedef NS_ENUM(NSInteger ,SOSMeCardCellType) {
   
    //车联保险
    SOSMeCardCellTypeInsurence = 0,
    //商城
    SOSMeCardCellTypeMall,
    //星享之旅
    SOSMeCardCellTypeStarTravel ,
    //套餐
    SOSMeCardCellTypePackage,
    //用车帐本
    SOSMeCardCellTypeLifeCashBook,
    //我的公益
    SOSMeCardCellTypeDonate,
    //客户服务
    SOSMeCardCellTypeCustomerService
   
};
typedef NS_ENUM(NSInteger ,SOSVehicleLifeCellType) {
    //随星听
    SOSCardCellTypeLifeMusic = 0,
    //养车生活
    SOSCardCellTypeLifeCarMantenance,
    //车主生活
    SOSCardCellTypeLifeOwnerLife,
    //用车手帐
    SOSCardCellTypeLifeCashBook,
    //车主俱乐部
    SOSCardCellTypeLifeCarOwnerClub,
    //智能互联
    SOSCardCellTypeLifeSmartHome,
    //车友群
    SOSCardCellTypeLifeInstantMessage,
    //星推荐
    SOSCardCellTypeLifeRecommendation
};


typedef NS_ENUM(NSInteger, SOSEditUserInfoType) {
    SOSEditUserInfoTypePhone,                   //修改手机号
    SOSEditUserInfoTypeMail,                    //邮箱
    SOSEditUserInfoTypeMailAdd,                 //设置新邮箱
    SOSEditUserInfoTypeCarControlPassword,       //车辆控制密码
    SOSEditUserInfoTypeMAPassword               //MA登录密码
};
#endif /* SOSNS_ENUM_h */
