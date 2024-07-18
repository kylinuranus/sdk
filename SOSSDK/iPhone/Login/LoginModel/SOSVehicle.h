//
//  SOSVehicle.h
//  Onstar
//
//  Created by Onstar on 2018/3/2.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSVehicleElement.h"
#import "SOSVehicleUnitFeature.h"

@interface SOSVehicle : NSObject
@property(nonatomic,copy)NSString * vin;
@property(nonatomic,copy)NSString * stationID;
@property(nonatomic,copy)NSString * manufacturerName;
@property(nonatomic,copy)NSString * manufacturerDesc;
@property(nonatomic,copy)NSString * make;
@property(nonatomic,copy)NSString * makeDesc;
@property(nonatomic,copy)NSString * model;
@property(nonatomic,copy)NSString * modelDesc;
@property(nonatomic,copy)NSString * year;

@property(nonatomic,copy)NSString * generationID;
@property(nonatomic,copy)NSString * generation;
@property(nonatomic,copy)NSString * generationDescription;
@property(nonatomic,copy)NSString * mdn;
@property(nonatomic,assign)BOOL ble;
/*
 addByWQ 20180906
 当用户进入远程操作界面（ICM新功能），若判断icmUpgrade符合规则，则提示相应弹框。
 用户点击弹窗后，关闭提示页面，并在APP本地记录。用户再次进入界面不弹框
 */
@property(nonatomic,assign)NSInteger icmUpgrade;


/**
 车品牌，目前是
 雪佛兰  CHEVROLET
 凯迪拉克： CADILLAC
 别克： BUICK
 */
@property(nonatomic,copy)NSString * brand;
@property(nonatomic,copy)NSString * vehiclePhone;

/**车辆本身支持的功能状态*/
@property(nonatomic,strong)NSDictionary <NSString *, SOSVehicleUnitFeature *>* vehicleUnitFeatures;

/**车辆本身支持的属性内容*/
@property(nonatomic,strong)NSDictionary<NSString *, SOSVehicleElement *>* supportedVehicleElements;


/**以下字段仅作为临时使用，待客户端完成改造后即废除*/
@property(nonatomic,assign)BOOL directWifi;
@property(nonatomic,assign)BOOL gen8;
@property(nonatomic,assign)BOOL gen9;
@property(nonatomic,assign)BOOL gen10;
@property(nonatomic,assign)BOOL phev;
@property(nonatomic,assign)BOOL d2jbi;
@property(nonatomic,assign)BOOL info3;
@property(nonatomic,assign)BOOL info34;
@property(nonatomic,assign)BOOL icm;
@property(nonatomic,assign)BOOL bev;

@property(nonatomic,assign)BOOL superCruise;
@property(nonatomic,assign)BOOL supportDAOVDTAN;
@property(nonatomic,assign)BOOL bbwc;

@property (readwrite) BOOL lockDoorSupported;
@property (readwrite) BOOL unlockDoorSupported;
@property (readwrite) BOOL remoteStartSupported;
@property (readwrite) BOOL remoteStopSupported;
@property (readwrite) BOOL vehicleAlertSupported;

@property (readwrite) BOOL getChargeModeSupport;

@property (readwrite) BOOL chargeNowSupport;

@property (readwrite) BOOL departureTableSupport;

@property (readwrite) BOOL needRefrshChargeMode;

@property (readwrite) BOOL getVehicleDataSupport;
@property (readwrite) BOOL vehicleRangeSupported;
@property (readwrite) BOOL odoMeterSupport;
@property (readwrite) BOOL lifetimeFuelEconSupport;
@property (readwrite) BOOL lastTripDistanceSupport;
@property (readwrite) BOOL lastTripFuelEconSupport;
@property (readwrite) BOOL tirePressureSupport;
@property (readwrite) BOOL fuelTankInfoSupport;
@property (readwrite) BOOL oilLifeSupport;

/// 车窗状态
@property (readwrite) BOOL windowPositionSupport;
/// 天窗状态
@property (readwrite) BOOL sunroofPositionSupport;
/// 车门状态
@property (readwrite) BOOL doorPositionSupport;
/// 上一条控车门指令
@property (readwrite) BOOL lastDoorCommandSupport;
/// 后备箱状态
@property (readwrite) BOOL trunkPositionSupport;
/// 发动机状态
@property (readwrite) BOOL engineStateSupport;
/// 车灯状态
@property (readwrite) BOOL lightStateSupport;
/// 双闪灯状态
@property (readwrite) BOOL flashStateSupport;

@property (nonatomic,assign) BOOL HVACSettingSupported;
@property (nonatomic,assign) BOOL closeSunroofSupported;
@property (nonatomic,assign) BOOL openSunroofSupported;
@property (nonatomic,assign) BOOL closeWindowSupported;
@property (nonatomic,assign) BOOL openWindowSupported;
@property (nonatomic,assign) BOOL openTrunkSupported;

//EV add supported
@property(readwrite)BOOL evScheduledChargeStartSupport;
@property(readwrite)BOOL getCommuteScheduleSupport;
@property(readwrite)BOOL evPlugVoltageSupport;
@property(readwrite)BOOL evBatteryLevelSupport;
@property(readwrite)BOOL evPlugStateSupport;
@property(readwrite)BOOL evEstimatedChargeEndSupport;
@property(readwrite)BOOL evChargeStateSupport;
@property(readwrite)BOOL lifeTimeEVOdometerSupport;

//ev new feature
@property(readwrite)BOOL getChargingProfileSupport;
@property(readwrite)BOOL setChargingProfileSupport;
@property(readwrite)BOOL getCommuteScheduleSupported;
@property(readwrite)BOOL setCommuteScheduleSupport;

/* Check Package Start */
@property (nonatomic,assign)BOOL remoteControlSupported;
@property (nonatomic,assign)BOOL dataRefreshSupported;
@property (nonatomic,assign)BOOL sendToTBTSupported;
@property (nonatomic,assign)BOOL myVehicleLocationSupported;
@property (nonatomic,assign) BOOL sendToNAVSupport;
@property (nonatomic,assign) BOOL wifiSupported;
//@property (nonatomic,assign) BOOL bbwcDone;
//@property (nonatomic,assign) BOOL geofenceSupported;



/**
 纯电车续航里程
 */
@property (assign, nonatomic) BOOL bevBatteryRangeSupported;

/**
 纯电车电池电量
 */
@property (assign, nonatomic) BOOL bevBatteryStatusSupported;

/// My21, 刹车片
@property (assign, nonatomic) BOOL brakePadLifeSupported;

/// My21,空气滤清器
@property (assign, nonatomic) BOOL engineAirFilterMonitorStatusSupported;

@property (nonatomic,assign) BOOL lockTrunkSupported;

@property (nonatomic,assign) BOOL unlockTrunkSupported;

@end

/// ICM 新部件状态
typedef enum {
    /// 部件状态: 未知
    SOSICM2ItemState_Non = 0,
    /// 部件状态: 开启
    SOSICM2ItemState_open,
    /// 部件状态: 关闭
    SOSICM2ItemState_close,
    /// 部件状态: 异常
    SOSICM2ItemState_unNormal
}	SOSICM2ItemState;

/// ICM 车辆状态
@interface SOSICM2VehicleStatus : NSObject

/// 车窗状态 			-- / close / open / DENORMALIZED
@property (nonatomic, assign) SOSICM2ItemState windowPositionStatus;
/// 天窗状态 			-- / close / open / DENORMALIZED
@property (nonatomic, assign) SOSICM2ItemState sunroofPositionStatus;
/// 发动机状态		-- / close / open
@property (nonatomic, assign) SOSICM2ItemState engineStatus;
/// 车门状态 			-- / close / open
@property (nonatomic, assign) SOSICM2ItemState carDoorStatus;
/// 后备箱状态 		-- / close / open
@property (nonatomic, assign) SOSICM2ItemState trunkStatus;
/// 车灯状态 			-- / close / open
@property (nonatomic, assign) SOSICM2ItemState lightStatus;
/// 双闪灯状态 		-- / close / open
@property (nonatomic, assign) SOSICM2ItemState flashStatus;
/// 上一条控车门指令 	-- / lock / unlock
@property (nonatomic, assign) SOSICM2ItemState lastDoorCommands;

/// 请求完成时间
@property (nonatomic, copy) NSString *completionTime;
/// 请求开始时间
@property (nonatomic, copy) NSString *requestTime;

//@property (nonatomic, assign) RemoteControlStatus refreshState;

//my21,新接收每扇门的状态,和icm字段一致
@property (nonatomic, assign) SOSICM2ItemState driverDoorStatus;
@property (nonatomic, assign) SOSICM2ItemState co_driverDoorStatus;
@property (nonatomic, assign) SOSICM2ItemState leftRearDoorStatus;
@property (nonatomic, assign) SOSICM2ItemState rightRearDoorStatus;



+ (void)saveCurrentResultToUserDefaults;

+ (SOSICM2VehicleStatus *)readSavedVehicleStatus;

@end
