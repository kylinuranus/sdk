//
//  CustomerInfo.h
//  Onstar
//
//  Created by Alfred Jin on 1/26/11.
//  Copyright 2011 plenware. All rights reserved.
//

#import "SOSLoginUserDefaultVehicleVO.h"
#import <Foundation/Foundation.h>
#import "SOSServicesInfo.h"

@class NNGetDataListResponse;

@interface CustomerInfo : NSObject {
}

+ (CustomerInfo *)sharedInstance;
+ (void)insertInto:(NSString *)tempTableNmae;
+ (void)selectVehicleDataFromDB:(NSString *)tempTableNmae;
//+ (void)insertChargeModeInto:(NSString *)tempTableNmae;
//+ (void)selectChargeModeFrom:(NSString *)tempTableNmae;
/**
 判断用户是否是CMS注册上来的用户
 @return return YES 代表是CMS注册
 */
- (BOOL)isCMSRegisterUser;

- (void)logout;

@property (nonatomic, strong) SOSVehicle *currentVehicle;
/// 安悦充电 Session ID
@property (nonatomic, copy) NSString *aySessionID;

/// ICM 新增部件 车况
@property (nonatomic, strong) SOSICM2VehicleStatus *icmVehicleStatus;
@property (nonatomic, assign)  RemoteControlStatus icmVehicleRefreshState;

@property (nonatomic, strong) SOSServicesInfo *servicesInfo;
@property (nonatomic, strong) NSString * mig_appSessionKey;
@property (nonatomic, strong) NSString * mag_appSessionKey;
@property (nonatomic, strong) NSString * auth_token;
@property (nonatomic, strong) NSString * sp_token;
//第一步Token携带的onstar基本信息
@property (nonatomic, strong) NNOAuthLoginResponse * tokenBasicInfo;
//第二步Suite携带用户信息
@property (nonatomic, strong) SOSLoginUserDefaultVehicleVO * userBasicInfo;
@property (nonatomic, strong) NSString * masked_user_name;
@property (nonatomic, assign) BOOL remote_control_optin_status;
@property (nonatomic, assign) BOOL fmv_optin_status;
@property (readwrite)		  BOOL		 rpo_flag;
@property (nonatomic, strong) NSMutableArray *additional_account_no;
@property (nonatomic, copy)   NSString *guid;
//套餐包是否过期
@property (nonatomic, assign) BOOL isExpired;
//add info3    协议是否发生变化
@property (nonatomic,assign) BOOL legalFlag;
//是否被分享授权 有true 没有flase
@property (nonatomic,assign) BOOL carSharingFlag;
@property (nonatomic,assign) BOOL sosRAStatus;

//add8.0 添加govid
@property (nonatomic,copy  )   NSString *govid;
#pragma mark ----------------CustomerInfo内车相关Attribute
@property (nonatomic, strong) NSString * vehicleRange;
@property (nonatomic, strong) NSString * oDoMeter;
@property (nonatomic, strong) NSString * lifeTimeFuelEcon;
@property (nonatomic, strong) NSString * fuelLavel;
@property (nonatomic, strong) NSString * fuelLavelInGas;
@property (nonatomic, strong) NSString * oilLife;
@property (nonatomic, strong) NSString * lastTripDistance;
@property (nonatomic, strong) NSString * lastTripFuelEcon;
@property (nonatomic, strong) NSString * tirePressurePlacardFront;
@property (nonatomic, strong) NSString * tirePressureLF;
@property (nonatomic, strong) NSString * tirePressureLFStatus;
@property (nonatomic, strong) NSString * tirePressureLR;
@property (nonatomic, strong) NSString * tirePressureLRStatus;
@property (nonatomic, strong) NSString * tirePressureRF;
@property (nonatomic, strong) NSString * tirePressureRFStatus;
@property (nonatomic, strong) NSString * tirePressureRR;
@property (nonatomic, strong) NSString * tirePressureRRStatus;
@property (nonatomic, strong) NSString * tirePressurePlacardRear;

@property (nonatomic, strong) NSString * timeYear;
@property (nonatomic, strong) NSString * timeMonth;
@property (nonatomic, strong) NSString * timeDay;
@property (nonatomic, strong) NSString * timeAMorPM;
@property (nonatomic, strong) NSString * timeHour;
@property (nonatomic, strong) NSString * timeMinute;
@property (nonatomic, strong) NSString * timeSecond;

@property (nonatomic, strong) NSString * chargeMode;
@property (nonatomic, strong) NSString * timeYearVolt;
@property (nonatomic, strong) NSString * timeMonthVolt;
@property (nonatomic, strong) NSString * timeDayVolt;
@property (nonatomic, strong) NSString * timeAMorPMVolt;
@property (nonatomic, strong) NSString * timeHourVolt;
@property (nonatomic, strong) NSString * timeMinuteVolt;
@property (nonatomic, strong) NSString * timeSecondVolt;

@property (nonatomic, strong) NSString * batteryLevel;
@property (nonatomic, strong) NSString * evVoltage;
@property (nonatomic, strong) NSString * chargeStartTime;
@property (nonatomic, strong) NSString * chargeEndTime;
@property (nonatomic, strong) NSString * chargeState;
@property (nonatomic, strong) NSString * chargeModeHome;
@property (nonatomic, strong) NSString * evRange;
@property (nonatomic, strong) NSString * evTotleRange;
@property (nonatomic, strong) NSString * plugInState;

//EV new property
@property(nonatomic,strong)NSString *getChargeMode;
@property(nonatomic,strong)NSString *evScheduledChargeStart;
@property(nonatomic,strong)NSString *getCommuteSchedule;
@property(nonatomic,strong)NSString *evPlugVoltage;
@property(nonatomic,strong)NSString *evBatteryLevel;
@property(nonatomic,strong)NSString *evPlugState;
@property(nonatomic,strong)NSString *evEstimatedChargeEnd;
@property(nonatomic,strong)NSString *evChargeState;
@property(nonatomic,strong)NSString *lifeTimeEVOdometer;
//K228 BEV 电动车
@property (copy, nonatomic) NSString *bevBatteryRange;
@property (copy, nonatomic) NSString *bevBatteryStatus;

//My21 GB 空气滤清器
@property (copy, nonatomic) NSString *airFilterStatus;
@property (copy, nonatomic) NSString *brakePadLifeFront;
@property (copy, nonatomic) NSString *brakePadLifeRear;
@property (copy, nonatomic) NSString *brakePadLifeStatus;


@property (nonatomic, strong) NSMutableArray *vehicleList;
@property (nonatomic, strong) NSMutableArray *vinList;
@property (nonatomic, strong) NSMutableArray *carYearList;
@property (nonatomic, strong) NSMutableArray *modelList;

@property (nonatomic, readwrite) BOOL needShowAlert;
@property (nonatomic, readwrite) BOOL hasLogin;
@property (nonatomic, readwrite) BOOL needContinuePolling;
@property (nonatomic, readwrite) BOOL remoteControlDidLoad;
@property (nonatomic, strong) NSString *aroundSearchCategory;

/* Check Package End */
@property(nonatomic, strong) NSString *wifi_SSID;
@property(nonatomic, strong) NSString *wifi_pwd;
@property(nonatomic, strong) NSString *wifi_status;
#pragma mark ----------------CustomerInfo内车相关Attribute End

@property (nonatomic, strong) SOSVehiclePrivilege *vehicleServicePrivilege;
//@property(nonatomic, strong) NSString *rateType;
@property(nonatomic, strong) NSArray *scheduleList;
///当前位置POI点
@property (nonatomic, strong) SOSPOI *currentPositionPoi;
///车辆定位POI点
@property (nonatomic, strong) SOSPOI *carLocationPoi;
///足迹Dic
@property (nonatomic, strong) NSMutableDictionary *footPrintDic;
///家的地址POI点
@property (nonatomic, strong) SOSPOI *homePoi;
///公司地址POI点
@property (nonatomic, strong) SOSPOI *companyPoi;

///当前电子围栏
@property (nonatomic, strong) NNGeoFence *currentGeoFence;

- (void)clearVehicleCommand;

@property(nonatomic,strong) NSString *changePhoneNo;
@property(nonatomic,strong) NSString *changeEmailNo;

///smart home
@property(nonatomic,strong) NSString *wifiName;
@property(nonatomic,strong) NSString *idPidAccessToken;
@property(nonatomic,strong) NSString *QrcodeString;
@property(nonatomic,strong) NNMachinelistArray *machineDetail;
@property(nonatomic,strong) NSString * distanceLength;
@property(nonatomic,strong) NNgeofencing * geofenceList;
@property(nonatomic,strong) NNGetSmartHomedeviceList * smartHomeDeviceList;
@property(nonatomic,strong) NSDictionary * geoFencingStatusDict;
@property(nonatomic,strong) NSString * deviceName;
//驾照到期日
@property(nonatomic,copy) NSString *licenseExpireDate;
@property(nonatomic,copy) NSString *accountNumber;
@property(nonatomic, copy) NSString *province;
@property(nonatomic, copy) NSString *city;
@property(nonatomic, copy) NSString *address1;
@property(nonatomic, copy) NSString *address2;
@property(nonatomic, copy) NSString *zip;

@property (nonatomic, assign) BOOL phev;
@property (nonatomic, assign) BOOL hornSelected;
@property (nonatomic, assign) BOOL flashSelected;

@property(nonatomic, assign) BOOL showCarAlert_Home;
@property(nonatomic, assign) BOOL showCarAlert_H5;

//8.2 我的 - 爱车小秘书 - 紧急联系人
///电话
@property (copy, nonatomic) NSString *ecMobile;
///姓
@property (copy, nonatomic) NSString *ecFirstName;
///名
@property (copy, nonatomic) NSString *ecLastName;
///是否显示紧急联系人
@property (assign, nonatomic) BOOL isEcInfoDisplay;
/**
 更新customerinfo中车相关信息,针对某些特别车型（ICM、Info34等）更改genid，否则会产生功能缺失
 */
- (void)updateVehicleAttribute;
/**
 更新Vehicle支持的服务以及用户套餐包是否过期
 @param entitlement
 */
- (void)updateServiceEntitlement:(SOSVehicleAndPackageEntitlement *)entitlement;

/**
  获取登录用户idpid&vin组合字符串
 @return
 */
- (NSString *)getIdpidVinStr;
/**
  是否在预约经销商界面,基类中埋点用
 @return
 */
@property (assign, nonatomic) BOOL isInDelear;
@end
