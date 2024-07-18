//
//  AppPreferences.h
//  Onstar
//
//  Created by Alfred Jin on 1/24/11.
//  Copyright 2011 plenware. All rights reserved.
//

#import "SOSNotificationKeys.h"
#import "SOSLibKeys.h"
#import "SOSCacheKeys.h"
#import "SOSSDKDefines.h"

#define SOS_APP_DELEGATE ((AppDelegate_iPhone*)[UIApplication sharedApplication].delegate)

/// 组队用户状态
typedef enum {
    /// 正常状况
    SOSGroupTripTeamMemberStatus_Normal = 1,
    /// 离线状态
    SOSGroupTripTeamMemberStatus_OffLine,
    /// 异常状态
    SOSGroupTripTeamMemberStatus_UnNormal,
    /// 紧急状态
    SOSGroupTripTeamMemberStatus_Emergency,
}    SOSGroupTripTeamMemberStatus;


/// 远程操作类型
typedef NS_ENUM(NSUInteger, SOSRemoteOperationType)   {
    /// 车门上锁
    SOSRemoteOperationType_LockCar = 0,
    /// 车门解锁
    SOSRemoteOperationType_UnLockCar,
    /// 远程启动
    SOSRemoteOperationType_RemoteStart,
    /// 取消远程启动
    SOSRemoteOperationType_RemoteStartCancel,
    /// 车辆闪灯
    SOSRemoteOperationType_Light,
    /// 车辆鸣笛
    SOSRemoteOperationType_Horn,
    /// 车辆闪灯&鸣笛
    SOSRemoteOperationType_LightAndHorn,
    
    //以下为 ICM 车辆命令
    
    /// 打开天窗
    SOSRemoteOperationType_OpenRoofWindow,
    /// 关闭天窗
    SOSRemoteOperationType_CloseRoofWindow,
    /// 打开车窗
    SOSRemoteOperationType_OpenWindow,
    /// 关闭车窗
    SOSRemoteOperationType_CloseWindow,
    /// 打开后备箱
    SOSRemoteOperationType_OpenTrunk,
    /// 开启空调
    SOSRemoteOperationType_OpenHVAC,
    /// 关闭空调
	SOSRemoteOperationType_CloseHVAC,
    
    // 9.0 新增
    /// 车辆定位
    SOSRemoteOperationType_VehicleLocation,
    ///车况，先占位。
    SOSRemoteOperationType_VehicleData,
    /// 下发 TBT
    SOSRemoteOperationType_SendPOI_TBT,
    /// 下发 ODD
    SOSRemoteOperationType_SendPOI_ODD,
    /// 自动下发 (根据用户设置,自动选择 TBT/ODD)
    SOSRemoteOperationType_SendPOI_Auto,
    SOSRemoteOperationType_ValidatePin, //仅仅验证Pin,
    
    SOSRemoteOperationType_UnlockTrunk,
    SOSRemoteOperationType_LockTrunk,

// TODO
//    /// 拉取车况
//    SOSRemoteOperationType_GetVehicleConditionn,
//    /// 配置车载WIFI
//    SOSRemoteOperationType_ConfigVehicleWIFI,
    SOSRemoteOperationType_VOID = NSIntegerMax,
};

/// 远程操作状态
typedef enum     {
    /// 初始状态
    RemoteControlStatus_Void = 0,
    /// 开始下发指令
    RemoteControlStatus_InitSuccess ,
    /// 拉取回调成功
    RemoteControlStatus_OperateSuccess,
    /// 操作失败 (下发失败或拉取回调失败)
    RemoteControlStatus_OperateFail,
    /// 操作超时 (拉取回调超时)
    RemoteControlStatus_OperateTimeout

} 	RemoteControlStatus;

typedef enum _USER_OPERATION{
    OPERATION_NOTHING = 0,
    OPERATION_CHOOSE_CITY,
    OPERATION_LOCATING,
    OPERATION_VEHICLE_LOCATING,
    OPERATION_CLEAR,
    ///长按地图
    OPERATION_LONGPRESS,
    ///改变 LBS 围栏中心点
    OPERATION_Change_LBS_GEO_Center
}   UserOperation;

typedef enum _SearchType{
    SearchType_Current_Location = 0,
    SearchType_Vehicle_Location,
    SearchType_City_Center,
    SearchType_Pois,
    SearchType_History
}   SearchType;

///地图显示类型
typedef NS_ENUM(NSUInteger, MapType) {
    /// 地图根视图，显示我的位置
    MapTypeRootWindow = 1,
    /// 地图展示Poi点, 不需要显示 "查看更多"
    MapTypeShowPoiPoint,
    /// 地图展示Poi点, 从列表模式进入,需显示 "查看更多"
    MapTypeShowPoiPointFromList,
    /// 地图展示Poi 列表
    MapTypeShowPoiList,
    /// 地图展示车辆定位
    MapTypeShowCarLocation,
    /// 地图展示足迹Poi点  概览模式
    MapTypeShowFootPrintPoiPointsOverViewMode,
    /// 地图展示足迹Poi点  详情模式
    MapTypeShowFootPrintPoiPointsDetailMode,
    /// 地图展示充电桩详情
    MapTypeShowChargeStation,
    /// 地图展示充电桩列表
    MapTypeChargeStationList,
    /// 地图路径展示
    MapTypeShowRoute,
    /// 一键到家
    MapTypeEasyGoHome,
    /// 一键到公司
    MapTypeEasyGoCompany,
    /// 加油站列表
    MapTypeOil,
    /// 加油站 详情(第三方油站)
    MapTypeOilDetail,
    /// LBS 设备实时定位
    MapTypeLBSCurrentLocation,
    /// LBS 模式 用户定位
    MapTypeLBSUserLocation,
    /// LBS 历史轨迹
    MapTypeLBSHistoryLocation,
    /// 显示 家 地址
    MapTypeShowHomeAddress,
    /// 显示 公司 地址
    MapTypeShowCompanyAddress,
    /// 选点模式,用于选择 住家/公司/路线起终点/围栏中心点 等
    MapTypePickPoint,
    ///选点模式,带有 查看更多 ,用于选择 住家/公司/路线起终点/围栏中心点 等
    MapTypePickPointFromList,
    /// 显示 电子围栏
    MapTypeShowGeoCycle,
    /// 显示 经销商 POI 点
    MapTypeShowDealerPOI,
    /// 显示智能后视镜位置
    MapTypeShowRVMirror,
};

typedef enum _POIType	{
    ///POI点
    POI_TYPE_POI = 1,
    ///POI点,列表模式
    POI_TYPE_List_POI,
    ///当前定位
    POI_TYPE_CURRENT_LOCATION,
    ///车辆定位
    POI_TYPE_VEHICLE_LOCATION,
    ///路线起点
    POI_TYPE_ROUTE_BEGIN,
    ///路线终点
    POI_TYPE_ROUTE_END,
    ///我的足迹,概览
    POI_TYPE_FootPrint_OverView,
    ///我的足迹,详情
    POI_TYPE_FootPrint_Detail,
    /// 家  地址
    POI_TYPE_Home,
    /// 公司 地址
    POI_TYPE_Company,
    ///经销商POI
    POI_TYPE_Dealer,
    /// 电子围栏中心点, 围栏打开
    POI_TYPE_GeoCenter_ON,
    /// 电子围栏中心点, 围栏关闭
    POI_TYPE_GeoCenter_OFF,
    /// 充电桩
    POI_TYPE_ChargeStation,
    /// 加油站
    POI_TYPE_OilStation,
    /// LBS 设备定位点
    POI_TYPE_LBS,
    /// LBS 历史轨迹
    POI_TYPE_LBS_History,
    /// 后视镜poi
    POI_TYPE_MIRROR,

}   POIType;

/// 导航策略
typedef NS_ENUM(NSUInteger, DriveStrategy) {
    ///速度优先（时间)
    DriveStrategyTimeFirst = 0,
//    ///费用优先（不走收费路段的最快道路）
//    DriveStrategyCostFirst = 1,
    ///距离优先
    DriveStrategyDestanceFirst = 2,
//    ///不走快速路
//    DriveStrategyNoFastRoad = 3,
//    ///结合实时交通（躲避拥堵）
//    DriveStrategyAvoidJam = 4,
//    ///多策略（同时使用速度优先、费用优先、距离优先三个策略）
//    DriveStrategyCombine = 5,
    ///不走高速
    DriveStrategyNoExpressWay = 6,
//    ///不走高速且避免收费
//    DriveStrategyNoExpressWayAndAvoidCharge = 7,
//    ///躲避收费和拥堵
//    DriveStrategyAvoidChargeAndJam = 8,
//    ///不走高速且躲避收费和拥堵
//    DriveStrategyNoExpressWayAndAvoidChargeAndIam = 9,
    
    ///步行策略
    DriveStrategyWalk = 99,
};

typedef enum _SOSAnnotationType{
    ANNOTATION_TYPE_POI=0,//default
    ANNOTATION_TYPE_CAR,
    ANNOTATION_TYPE_ME
    
}SOSAnnotationType;
// Find my vehicle end ================================================

typedef enum _UserRegisterActionAction{
    checkUserName = 1,
    checkMobileEmail,
    checkNickName,
    checkAllUnique,
    checkCode,
    checkAgree,
    checkPassword,
    checkSameUserName,
    
} UserRegisterAction;

typedef NS_ENUM(NSInteger, SOSVehicleConditonStatus) {
    SOSVehicleConditonUnknown,
    SOSVehicleConditonNormal,//正常显示
    SOSVehicleConditonInCharge,
    SOSVehicleConditonChargeComplete
    
};
//#define INHOUSE_APP_BUNDERID                @"com.shanghaionstar.onstarInHouse"
#define CURRENT_DEVICE_ID					@"CURRENT_DEVICE_ID"
#define CURRENT_SYSTEM_VERSION				@"CURRENT_SYSTEM_VERSION"
#define CURRENT_SYSTEM_NAME                 @"CURRENT_SYSTEM_NAME"
#define CURRENT_IMSI						@""

#pragma mark ---***设备、屏幕相关
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define ISIPAD                          (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define SCREEN_WIDTH                    ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT                   ([UIScreen mainScreen].bounds.size.height)
#define SCALE_HEIGHT(height)            SCREEN_HEIGHT/667.0*height
#define SCALE_WIDTH(width)              SCREEN_WIDTH/375.0*width
#define STATUSBAR_HEIGHT                [UIApplication sharedApplication].statusBarFrame.size.height
#define SOS_NAVIGATIONBAR_HEIGHT        (STATUSBAR_HEIGHT + 44)

#define KEY_WINDOW                      [UIApplication sharedApplication].keyWindow
//ONSTAR
#define SOS_ONSTAR_BUNDLEID             @"com.shanghaionstar.onstar"
#define SOS_ONSTAR_PRODUCT              [[UIApplication sharedApplication].appBundleID isEqualToString:SOS_ONSTAR_BUNDLEID]
//凯迪
#define SOS_CD_BUNDLEID             @"com.shanghaigm.MyCadillac"
#define SOS_CD_PRODUCT              [[UIApplication sharedApplication].appBundleID isEqualToString:SOS_CD_BUNDLEID]
//buick
#define SOS_BUICK_BUNDLEID             @"com.industryillusion.ibuick"
#define SOS_BUICK_PRODUCT              [[UIApplication sharedApplication].appBundleID isEqualToString:SOS_BUICK_BUNDLEID]

//雪佛兰
#define SOS_MYCHEVY_BUNDLEID             @"com.wangfan.myChevy"
#define SOS_MYCHEVY_PRODUCT              [[UIApplication sharedApplication].appBundleID isEqualToString:SOS_MYCHEVY_BUNDLEID]

#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS     (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5             (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6             (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P            (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define IS_IPHONE_3_5           (IS_IPHONE_4_OR_LESS || IS_IPHONE_5)
#define IS_IPHONE_XSeries      	[Util isiPhoneXSeries]

#define SystemVersion        [[UIDevice currentDevice].systemVersion floatValue]
#define iOS11_OR_LATER  NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_11_0
#define iOS10_OR_LATER	NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_9_x_Max   //暂定
#define iOS9_OR_LATER	NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_9_0
#define iOS8_OR_LATER	NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0
#define iOS7_OR_LATER	NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0

#pragma mark----------------------------------

#pragma mark ---***Const

#define REMOTE_CONTROL_TIME_OUT_TIMER		180

#define POLLING_TIMER_INTERVAL				10

#pragma mark----------------------------------

#define ALERT_NEED_RELOGIN                  @"ALERT_NEED_RELOGIN"
#define CHARGE_ALERT_DELEGATE_NULL          @"CHARGE_ALERT_DELEGATE_NULL"

#define DEFAULT_CITY_CODE					@"000"

#define K_CADILLAC_YEAR                     @"2010"
#define K_CADILLAC_MODEL_EN                 @"Cadillac SLS"
#define K_CADILLAC_MODEL_CN                 @"凯迪拉克 赛威"

#define PREFERENCE_TEMP_USER_NAME			@"temp_username"
#define PREFERENCE_USER_NAME				@"username"
#define PREFERENCE_PASSWORD					@"password"
#define NEED_REMEMBER_ME					@"NEED_REMEMBER_ME"
#define NEED_AUTO_REFRESH					@"NEED_AUTO_REFRESH"
#define NEED_REMOTE_AUDIO                   @"NEED_REMOTE_AUDIO"
#define NEED_REMOTE_OPTSTATUS               @"NEED_REMOTE_OPTSTATUS"         //能耗排名开关
#define NEED_REMOTE_CARSTATUSREPORT         @"NEED_REMOTE_CARSTATUSREPORT"   //车况鉴定报告开关

#define NEED_REMOTE_Viberate                @"NEED_REMOTE_Viberate"
#define TIP_OPEN_FINGER                     @"TIP_OPEN_FINGER"
//#define NEED_SHOW_MRO                       @"NEED_SHOW_MRO"
#define NEED_NOT_NOTICE_AT_SEETINGPAGE       @"NEED_NOT_NOTICE_AT_SEETINGPAGE"
#define ISNOTFIRSTSET                       @"ISNOTFIRSTSET"
#define AppLaunchBefore                     @"AppLaunchBefore"
#define AUTO_LOGIN                          @"AUTO_LOGIN"

#define REMOTE_COMMAND_IDPID                     @"REMOTE_COMMAND_IDPID"
#define REMOTE_COMMAND_VIN                       @"REMOTE_COMMAND_VIN"
#define REMOTE_COMMAND_TYPE                      @"REMOTE_COMMAND_TYPE"
#define REMOTE_COMMAND_STATUS                    @"REMOTE_COMMAND_STATUS"
#define REMOTE_COMMAND_CODE                      @"REMOTE_COMMAND_CODE"
#define REMOTE_COMMAND_DATE                      @"REMOTE_COMMAND_DATE"
#define REMOTE_COMMAND_ACT                       @"REMOTE_COMMAND_ACT"
#define Remote_Operation_Type					 @"Remote_Operation_Type"

#define AUTONAVI_CHANNEL        @"onstar"
#define AUTONAVI_KEY            @"GDsBZoaJOL3VRcDhunxRxR3ADVhoxuI0qXlleC4h"
#define AUTONAVI_RESCTRICT_KEY  @"91255BBA539330E8DF3761979C7A0A77"
#define OUTPUT_JSON             @"json"

#define GOOD_COMMENT   1000000

#pragma mark ---***多语言设置
#define CHINESE @"zh_CN"
#define ENGLISH @"en"

#define ONSTAR_APP_LANGUAGE @"OnStarAppLanguage"

#define META_LANGUAGE_CHINESE				@"zh-CN"

#define META_LANGUAGE_ENGLISH				@"en-US"
#pragma mark -----------------------------------------------


#define SERVER_RESPONSE_SUCCESS				@"success"
#define SERVER_RESPONSE_INPROGRESS			@"inProgress"
#define SERVER_RESPONSE_FAILURE				@"failure"

#define VIN_INFOS_DATABASE_TABLE			@"vinInfosDatabaseTable"
#define VIN_INFOS_KEY_ID					@"vinInfosKeyID"
#define VIN_INFOS_KEY_VIN					@"vinInfosKeyVin"


#define VIN_INFOS_KEY_MODEL					@"vinInfosKeyModel"
#define VIN_INFOS_KEY_MAKE					@"vinInfosKeyMake"
#define VIN_INFOS_KEY_REQUEST_ID			@"vinInfosKeyRequestID"
#define VIN_INFOS_KEY_REQUEST_TYPE			@"vinInfosKeyRequestType"

#define SEND_TO_TBT_DATABASE_TABLE			@"sendToTBTDatabaseTable"
#define SEND_TO_TBT_REQUEST_ID				@"SEND_TO_TBT_REQUEST_ID"

#define STORY_CALL_ME                        @"TRUE_STORY"    //真实故事
#define ASSISTANT_CALL_ME                    @"ASSISTANT"     //服务贴士
#define PROMOTION_CALL_ME                    @"PROMOTION"     //优惠信息
#define OVD_EMAIL_CALL_ME                    @"OVD_EMAIL"

#define ABOUT_FEATURES                      @"ONSTAR_GNJS"   //应用功能介绍
#define ABOUT_FAQ                           @"ONSTAR_SYBZ"   //反馈
#define ABOUT_INTRODUCTION                  @"ONSTAR_FWJS"   //服务介绍
#define ABOUT_WELCOME                       @"ONSTAR_WELCOME"   //欢迎页
#define ONSTAR_AD                           @"ONSTAR_ADVERTISEMENT"

#define BANNER_HOME                         @"HOME_BANNER"      //首页广告
#define MA9_INDEX_BANNER                    @"MA9.0_INDEX_BANNER"
#define BANNER_DISCOVERY                    @"DISCOVERY_BANNER" //发现广告
#define BANNER_IAP                          @"IAP_BANNER"       //iap引流banner
#define BANNER_UBI                          @"UBI_BANNER"       //UBI banner
#define BANNER_MALL                          @"MALL_BANNER"       //UBI Mall

#define BANNER_MUSIC                        @"MIGU_MUSIC_BANNER"//云音乐banner
//#define BANNER_RECOMMEND                    @"RECOMMEND_BANNER"//精彩推荐(千人千面)
#define BANNER_FULL_SCREEN_AD               @"FLOAT_BANNER"     //首页浮窗广告

#define BANNER_OWNERLIFE                    @"CAR_MANAGER,LIFE_MANAGER,HOT_PROMOTION"      //车主生活
#define BANNER_MAINTAIN                     @"MAINTAIN_BANNER"  //保养广告
#define BANNER_INSURANCE                    @"INSURANCE_BANNER" //保险广告
#define BANNER_RENEW                        @"RENEW_BANNER"     //换证广告


#define BUICK_CARE_CALL_ME                  @"BUICK_CARE"
#define BUICK_CARE_JPFW                     @"BUICK_CARE_JPFW"//精品服务
#define BUICK_CARE_HDXX                     @"BUICK_CARE_HDXX"//活动信息
#define BUICK_CARE_YCTS                     @"BUICK_CARE_YCTS"//养车贴士
#define IPHONE_SMALL                        @"IPHONE_SMALL"
#define IPHONE_LARGE                        @"IPHONE_LARGE"
#define IPHONE_X                            @"IPHONEX"

#define IPAD_LARGE                          @"IPAD"

#define BANNER_IPHONE4                             @"IPHONE4"
#define BANNER_IPHONE5                             @"IPHONE5"

#define POLLING_HAS_ENDED					@"polling has ended"
#define POLLING_TIMER_NEED_START			@"polling timer need start"
#define POLLING_TBT_HAS_ENDED				@"polling TBT has ended"

#define REMOTE_REQUEST_TYPE					@"RemoteRequestType"
#define REMOTE_REQUEST_STATUS               @"RemoteRequestStatus"
#define REMOTE_REQUEST_COMPLETE_TIME		@"RemoteRequestCompleteTime"


//data refersh
#define GET_VEHICLE_DATA_REQUEST			@"GetVehicleDataRequest"
//remote control , 宏代表availableFuncs返回对应Key
#define LOCK_DOOR_REQUEST					@"lock"
#define UNLOCK_DOOR_REQUEST					@"unLock"
#define REMOTE_START_REQUEST				@"remoteStart"
#define REMOTE_STOP_REQUEST                 @"cancelStart" //支持远程启动就支持远程关闭
#define VEHICLE_ALERT_REQUEST				@"vehicleAlert"
#define VEHICLE_ALERT_HORN_REQUEST			@"VehicleAlertHornRequest"
#define VEHICLE_ALERT_FLASHLIGHTS_REQUEST   @"VehicleAlertLightRequest"
#define VEHICLE_CANCEL_ALERT_REQUEST        @"VehicleCancelAlertRequest"
//find my vehicle
#define GET_VEHICLE_LOCATION_REQUEST        @"vehicleLocation"
//odd
#define SEND_TO_NAV_REQUEST                 @"SendToNAVRequest"
//tbt
#define SEND_TO_TBT_REQUEST					@"SendToTBTRequest"

//EV
#define GET_CHARGE_MODE_REQUEST             @"GetChargeModeRequest"
#define CHARGE_OVER_RIDE_REQUEST            @"ChargeOverrideRequest"
#define GET_DEPARTURE_TIME_REQUEST          @"GetDepartureTableRequest"

#define SET_CHARGE_PROFILE_REQUEST          @"setChargingProfileRequest"
#define GET_CHARGE_PROFILE_REQUEST          @"getChargingProfileRequest"

#define SET_SCHEDULE_REQUEST                @"setCommuteScheduleRequest"
#define GET_SCHEDULE_REQUEST                @"getCommuteScheduleRequest"

#define STOP_CHARGE_REQUEST                 @"stopChargeRequest"
#define CREATE_TRIP_PLAN_REQUEST            @"createTripPlanRequest"

//hotspot
#define GET_HOTSPOT_INFO_REQUEST            @"GetHotspotInfoRequest"
#define GET_HOTSPOT_STATUS_REQUEST          @"GetHotspotStatusRequest"
#define SET_HOTSPOT_INFO_REQUEST            @"SetHotspotInfoRequest"
#define DISABLE_HOTSPOT_REQUEST             @"DisableHotspotRequest"
#define ENABALE_HOTSPOT_REQUEST             @"EnableHotspotRequest"

#define GET_PACKAGE_SERVICE_REQUEST         @"GetPackageServiceRequest"



#define VEHICLE_ALERT_OVERRIDE				@"DOOR_IGNITION"

#define CONTENT_CATEGORY_STORY				@"TRUE_STORY"
#define CONTENT_CATEGORY_ASSISTANT			@"ASSISTANT"
#define CONTENT_CATEGORY_PROMOTION			@"PROMOTION"
#define CONTENT_CATEGORY_OVD_EMAIL			@"OVD_EMAIL"

#define TIRE_PRESSURE_STATUS_GREEN			@"GREEN"
#define TIRE_PRESSURE_STATUS_YELLOW			@"YELLOW"
#define TIRE_PRESSURE_STATUS_RED            @"RED"


//My21 GB
#define BRAKE_PAD_LIFE_No_Action        @"NO ACTION"
#define BRAKE_PAD_LIFE_Not_Present      @"NOT PRESENT"
#define BRAKE_PAD_LIFE_Ok               @"OK"
#define BRAKE_PAD_LIFE_Change_Soon      @"CHANGE SOON"
#define BRAKE_PAD_LIFE_Change_Now       @"CHANGE NOW"
#define BRAKE_PAD_LIFE_Disabled         @"DISABLED"
#define BRAKE_PAD_LIFE_Service          @"SERVICE"


#define TIRE_PRESSURE_STATUS_G			@"G"
#define TIRE_PRESSURE_STATUS_Y			@"Y"
#define TIRE_PRESSURE_STATUS_R          @"R"

#define DEFAULT_SEARCH_AROUND				@"DEFAULT_SEARCH_AROUND"

/* Added by Vladimir */
#define CHANGE_PRIORITY_AT_INDEX_PAGE_NOTIFICATION	@"NoticicationHomePriority"
//#define DISMISS_MESSAGE_VIEW_CONTROLLER     @"DismissMessageViewController"
/* Vladimir */


//车牌号，发动机号改变通知
#define  LISENCENUM_ENGINENUM_CHANGE_NOTIFICATION     @"LISENCENUM_ENGINENUM_CHANGE_NOTIFICATION"




#define MAP_KEY_KEY                             @"MAP_KEY_KEY"
#define MAP_KEY                                 [[NSUserDefaults standardUserDefaults] objectForKey:MAP_KEY_KEY]==nil?@"c2b0f58a6f09cafd1503c06ef08ac7aeb7ddb91a8139a410a3e48f13e57ea1e6bf77fbd71afd0244":[[NSUserDefaults standardUserDefaults] objectForKey:MAP_KEY_KEY]

#define AROUND_SEARCH_CALL_ME				@"AROUND_SEARCH_CALL_ME"
#define NAME_SEARCH_CALL_ME					@"NAME_SEARCH_CALL_ME"
#define FAVORITE_LIST_CALL_ME				@"FAVORITE_LIST_CALL_ME"
#define HISTORY_LIST_CALL_Me				@"HISTORY_LIST_CALL_Me"
#define DEFAULT_AROUND_SEARCH_CLASSIFY		@"DEFAULT_AROUND_SEARCH_CLASSIFY"
#define DEFAULT_NAME_SEARCH_CLASSIFY		@"DEFAULT_NAME_SEARCH_CLASSIFY"

#define K_PREVIOUS_VERSION                  @"K_PREVIOUS_VERSION"
#define K_INSTALLED_VERSION                 @"K_INSTALLED_VERSION"
#define K_LATEST_VERSION                    @"K_LATEST_VERSION" //王健功添加，用于记录上个提示升级的版本号

#define K_FIRST_TIME_LOAD                   @"isFirstTimeLoad"

#define K_SEARCH_RESULT_NAME				@"K_SEARCH_RESULT_NAME"
#define K_SEARCH_RESULT_LOCATION_NAME		@"K_SEARCH_RESULT_LOCATION_NAME"
#define K_SEARCH_RESULT_NEAR_NAME			@"K_SEARCH_RESULT_NEAR_NAME"
#define K_SEARCH_RESULT_ADDRESS				@"K_SEARCH_RESULT_ADDRESS"
#define K_SEARCH_RESULT_PHONE_NUMBER		@"K_SEARCH_RESULT_PHONE_NUMBER"
#define K_SEARCH_RESULT_CROSS               @"K_SEARCH_RESULT_CROSS"
#define K_SEARCH_RESULT_DISTRICT_NAME       @"K_SEARCH_RESULT_DISTRICT_NAME"
#define K_SEARCH_RESULT_CITY_NAME           @"K_SEARCH_RESULT_CITY_NAME"
#define K_SEARCH_RESULT_PROVINCE_NAME       @"K_SEARCH_RESULT_PROVINCE_NAME"
#define K_POI_COORDINATE					@"K_POI_COORDINATE"
#define K_LATITUDE							@"K_LATITUDE"
#define K_LONGITUDE							@"K_LONGITUDE"
#define K_DESTINATION_TYPE_INTERSECTION		@"INTERSECTION"
#define K_SEND_TO_TBT_STATUS				@"K_SEND_TO_TBT_STATUS"
#define K_SEND_TO_TBT_TIME					@"K_SEND_TO_TBT_TIME"
#define K_SEND_TO_TBT_VIN					@"VEHICLE_VIN"    // 车辆vin
#define K_DESTINATION_ID					@"K_DESTINATION_ID"

#define K_CURRENT_LATITUDE                  @"K_CURRENT_LATITUDE"
#define K_CURRENT_LONGITUDE                 @"K_CURRENT_LONGITUDE"

// auto send TBT
#define K_AUTO_SEND_TO_TBT					@"K_AUTO_SEND_TO_TBT"
#define AUTO_SEND_TO_CAR_CALL_ME            @"AUTO_SEND_TO_CAR_CALL_ME"
#define AUTO_SEND_TO_CAR_Already            @"AUTO_SEND_TO_CAR_Already"

#define K_DEFAULT_SEND_NAME                 @"K_DEFAULT_SEND_NAME"
#define K_DEFAULT_SEND_ADDRESS              @"K_DEFAULT_SEND_ADDRESS"
#define K_DEFAULT_SEND_PHONE                @"K_DEFAULT_SEND_PHONE"
#define K_DEFAULT_SEND_CITY                 @"K_DEFAULT_SEND_CITY"
#define K_DEFAULT_SEND_CATEGORY             @"K_DEFAULT_SEND_CATEGORY"
#define K_DEFAULT_SEND_DES_LONGITUDE        @"K_DEFAULT_SEND_DES_LONGITUDE"
#define K_DEFAULT_SEND_DES_LATITUDE         @"K_DEFAULT_SEND_DES_LATITUDE"
#define K_DEFAULT_SEND_CUR_LONGITUDE        @"K_DEFAULT_SEND_CUR_LONGITUDE"
#define K_DEFAULT_SEND_CUR_LATITUDE         @"K_DEFAULT_SEND_CUR_LATITUDE"
#define K_DEFAULT_SEND_START_TIME           @"K_DEFAULT_SEND_START_TIME"
#define K_DEFAULT_SEND_COMPLETE_TIME        @"K_DEFAULT_SEND_COMPLETE_TIME"

#define K_CAR_LOCATION_STAR                 @"K_CAR_LOCATION_STAR" //拿到车辆位置反地理编码后赋值


#define FLAG_NOT_FIRST_TIME_RUNNING         @"FLAG_NOT_FIRST_TIME_RUNNING"


#define CONTACT_ONSTART_NUMBER				@"4008201188"
#define CONTACT_ONSTART_slash               @"400-820-1188"

#define K_SEARCH_MORE_WHO_CALL_ME			@"K_SEARCH_MORE_WHO_CALL_ME"
#define K_SEARCH_MORE_KEY_WORDS				@"K_SEARCH_MORE_KEY_WORDS"
#define K_SEARCH_MORE_CITY_NAME				@"K_SEARCH_MORE_CITY_NAME"
#define K_SEARCH_MORE_CENTER_POI_X			@"K_SEARCH_MORE_CENTER_POI_X"
#define K_SEARCH_MORE_CENTER_POI_Y			@"K_SEARCH_MORE_CENTER_POI_Y"

#define K_SAVE_DESTINATION_DIRECT			@"DIRECT"
#define K_SAVE_DESTINATION_REMIND			@"REMIND"

#define K_ORIGIN                            @"ORIGIN"
#define K_DESTINATION                       @"DESTINATION"

#pragma mark ---***道路描述
#define K_SEGMENT_ROAD_LENGTH               @"K_SEGMENT_ROAD_LENGTH"
#define K_SEGMENT_FORM                      @"K_SEGMENT_FORM" //道路描述
#define K_SEGMENT_GRADE                     @"K_SEGMENT_GRADE" //道路等级
#define K_SEGMENT_DIRECTION                 @"K_SEGMENT_DIRECTION" //行使方向
#define K_SEGMENT_ROAD_NAME                 @"K_SEGMENT_ROAD_NAME"
#define K_SEGMENT_DRIVE_TIME                @"K_SEGMENT_DRIVE_TIME"
#define K_SEGMENT_ACTION                    @"K_SEGMENT_ACTION"
#define K_SEGMENT_ACCESSORIAL_INFO          @"K_SEGMENT_ACCESSORIAL_INFO"
#define K_SEGMENT_TEXT_INFO                 @"K_SEGMENT_TEXT_INFO"
#define K_SEGMENT_START_X                   @"K_SEGMENT_START_X"
#define K_SEGMENT_START_Y                   @"K_SEGMENT_START_Y"
#define K_SEGMENT_END_X                     @"K_SEGMENT_END_X"
#define K_SEGMENT_END_Y                     @"K_SEGMENT_END_Y"
#define K_ROUTE_INFO_ARRAY                  @"K_ROUTE_INFO_ARRAY"
#define K_ROUTE_POINT_ARRAY                 @"K_ROUTE_POINT_ARRAY"

#define ROUTE_ORIGIN_CALL_ME				@"ROUTE_ORIGIN_CALL_ME"
#define ROUTE_DESTINATION_CALL_ME			@"ROUTE_DESTINATION_CALL_ME"
#define ORIGIN_DEST_FROM_POI_LIST           @"ORIGIN_DEST_FROM_POI_LIST"
#define ORIGIN_DEST_FROM_FAVORITE           @"ORIGIN_DEST_FROM_FAVORITE"

#define K_MY_LOCATION                       @"K_MY_LOCATION"
#define K_MY_LOCATION_NAME                  @"K_MY_LOCATION_NAME"

#define K_NEED_SHOW_TRAFFIC					@"K_NEED_SHOW_TRAFFIC"
#define K_ROUTE_SELECTED_OPTION             @"K_ROUTE_SELECTED_OPTION"
#pragma mark ------------------------------------------


#define LANDING_IMAGE_SHOWN_DONE            @"LANDING_IMAGE_SHOWN_DONE"


// 上次的车辆操作请求
#define LAST_VEHICLE_COMMAND_RESULT         @"LAST_VEHICLE_COMMAND_RESULT"

// Non Login start ================================================
#define LOGIN_STATE                         @"LOGIN_STATE"
#define LOGIN_RESULT                        @"LOGIN_RESULT"
#define INTRODUCTION_FLAG                   @"INTRODUCTION_FLAG"
#define INTRODUCTION_YES                    @"YES"
#define INTRODUCTION_NO                     @"NO"

// Non Login end   ================================================

// Find my vehicle start ================================================
#define CREATE_ROUTE_LINE                   @"CREATE_ROUTE_LINE"
#define CREATE_ROUTE_LINE_AROUND            @"CREATE_ROUTE_LINE_AROUND"
#define CURRENT_LOCATION_STATUS             @"CURRENT_LOCATION_STATUS"
#define CURRENT_LOCATION_MESSAGE            @"CURRENT_LOCATION_MESSAGE"
#define CURRENT_LOCATION                    @"CURRENT_LOCATION"
#define VEHICLE_LOCATION_STATUS             @"VEHICLE_LOCATION_STATUS"
#define VEHICLE_LOCATION_MESSAGE            @"VEHICLE_LOCATION_MESSAGE"
#define VEHICLE_LOCATION_ERROR_TAG          @"VEHICLE_LOCATION_ERROR_TAG"
#define VEHICLE_LOCATION                    @"VEHICLE_LOCATION"


// form autonavi scheme
//#define AUTONAVI_SCHEME                     @"onstar2autonavi"
//#define AUTONAVI_TBT_REPORT_CONTENT         @"AutoNavi"


// 系统消息定义 用于轮训完成后的通知
#define VEHICLE_UNLOCK_DOOR_SUCCESS         @"VEHICLE_UNLOCK_DOOR_SUCCESS"
#define VEHICLE_LOCK_DOOR_SUCCESS           @"VEHICLE_LOCK_DOOR_SUCCESS"
#define VEHICLE_START_ENGINE_SUCCESS        @"VEHICLE_START_ENGINE_SUCCESS"
#define VEHICLE_STOP_ENGINE_SUCCESS         @"VEHICLE_STOP_ENGINE_SUCCESS"
#define VEHICLE_FIND_VEHICLE_SUCCESS        @"VEHICLE_FIND_VEHICLE_SUCCESS"
#define VEHICLE_REFRESH_DATA_SUCCESS        @"VEHICLE_REFRESH_DATA_SUCCESS"
#define VEHICLE_HORN_LIGHT_SUCCESS          @"VEHICLE_HORN_LIGHT_SUCCESS"
#define VEHICLE_HORN_SUCCESS                @"VEHICLE_HORN_SUCCESS"
#define VEHICLE_LIGHT_SUCCESS               @"VEHICLE_LIGHT_SUCCESS"
#define VEHICLE_ALEART_FINGER               @"VEHICLE_ALEART_FINGER"
#define VEHICLE_OPERATION_FAIL              @"VEHICLE_OPERATION_FAIL"
#define LOGIN_TIME_OUT                      @"LOGIN_TIME_OUT"

#pragma mark -----***SOSManger
#define IOS7_NAVIGATION_BAR_HEIGHT      64.0f

#define CURRENT_LOCATION_ID_ANNOTATION      @"CURRENT_LOCATION_ID_ANNOTATION"
#define VEHICLE_LOCATION_ID_ANNOTATION      @"VEHICLE_LOCATION_ID_ANNOTATION"
#define POI_LOCATION_ID_ANNOTATION          @"POI_LOCATION_ID_ANNOTATION"

#define CURRENT_LOCATION_ID_POPWINDOW       @"CURRENT_LOCATION_ID_POPWINDOW"
#define VEHICLE_LOCATION_ID                 @"VEHICLE_LOCATION_ID"
#define POI_LOCATION_ID                     @"POI_LOCATION_ID"

#define MY_APP_SESSION_KEY                  self.migSessionKey
#define MY_VIN                              self.vin

#pragma mark -----
#define colorFromRGB(r, g, b, a)  [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#pragma mark ---***角色
#define ROLE_OWNER @"owner"
#define ROLE_DRIVER @"driver"
#define ROLE_PROXY @"proxy"
#define ROLE_VISITOR @"visitor"
#pragma mark --------------------------------------


// P&P service control -- package and platform
//TODO 后端以后会精准控制到底是TBT不可用还是ODD不可用，目前依然沿袭之前逻辑，tbt／odd混合一起
//#define PP_NAVIGATION_Deprecate              @"M05NAVIGATION"     // TBT and ODD
//#define PP_REMOTE_CONTROL_Deprecate          @"M07REMOTE_CONTROL"

//#define PP_DATA_REFRESH            @"M01DATA_REFRESH"
//#define PP_FIND_VEHICLE            @"M06FIND_CAR"
//#define PP_OVD                     @"M04OVD"
//#define PP_SAFETY_ZONE             @"M08SAFETY_ZONE"
////
//#define PP_VehicleLocation              @"vehicleLocation"
#define PP_GeoFence                     @"geoFence"
#define PP_DataRefresh                  @"dataRefresh"
//Remotecontrol
#define PP_RemoteStart                  @"remoteStart"
#define PP_Lock                         @"lock"
#define PP_VehicleAlert                 @"vehicleAlert"
#define PP_UnLock                       @"unLock"
//Navigation
#define PP_Odd                          @"odd"
#define PP_Tbt                          @"tbt"

#define PP_OvdReport                    @"ovdReport"

//ApplePush 设备Token
#define kApplePushSaveDeviceToken  		@"ApplePushSaveDeviceToken"
//指纹密码验证PIN通知
#define kFingerprintValidationPINNote 	@"kFingerprintValidationPINNote"
//指纹密码PIN请求
#define FINGERPRINT_PIN_REQUEST			@"fingerprintPINRequest"
//是否需要提醒实名认证
#define KShouldNoticeVerifyPersionInfo	@"KShouldNoticeVerifyPersionInfo"
#define SOSkSwitchVehicleSuccess           @"SOSkSwitchVehicleSuccess"

// MrO换肤
#define MrOClothes_big                  @"MrOClothes_big_imageName"
#define MrOClothes_small                @"MrOClothes_small_imageName"

#define MrOType                         @"MrOBrandType"

#define MrOTypeDefault                  @"DEFAULT"
#define MrOTypeBrand                    @"BRAND"
#define MrOTypeNoHelmet                 @"NOHELMET"

#define MrOBrandTypeCadillac            @"CADILLAC"
#define MrOBrandTypeBuick               @"BUICK"
#define MrOBrandTypeChevrolet           @"CHEVROLET"

#define NETWORK_TIMEOUT                 @"NETWORK_TIMEOUT"
#define BACKEND_ERROR                   @"server_error"
#define NN_MASK_USERNAME                @"NN_MASK_USERNAME"
#define NN_CURRENT_USERNAME             @"NN_CURRENT_USERNAME"
#define NN_TEMP_USERNAME                @"NN_TEMP_USERNAME"

//所有的idpid 用来判断用户第一次登录
#define NN_TEMP_USERLOGIN_IDPID         @"userIdpid_all"
//所有的vin  
#define NN_TEMP_USERLOGIN_vin           @"uservin_all"


#define WEEK_DAY1                       @"MON"
#define WEEK_DAY2                       @"TUE"
#define WEEK_DAY3                       @"WED"
#define WEEK_DAY4                       @"THU"
#define WEEK_DAY5                       @"FRI"
#define WEEK_DAY6                       @"SAT"
#define WEEK_DAY0                       @"SUN"

//#define TIME_0                          @"00"
//#define TIME_15                         @"15"
//#define TIME_30                         @"30"
//#define TIME_45                         @"45"

#define CM_DEFAULT_IMMEDIATE            @"DEFAULT_IMMEDIATE"
#define CM_IMMEDIATE                    @"IMMEDIATE"
#define CM_RATE_BASED                   @"RATE_BASED"
#define CM_DEPARTURE_BASED              @"DEPARTURE_BASED"
#define CM_PHEV_AFTER_MIDNIGHT          @"PHEV_AFTER_MIDNIGHT"

#define RT_PEAK                         @"PEAK"
#define RT_MIDPEAK                      @"MIDPEAK"
#define RT_OFFPEAK                      @"OFFPEAK"
#define RT_INVALID                      @"INVALID"

//#define TBT_OR_ODD                         @"TBTOrODD"  //下发首选项



#define  LICENSENUM_CAR     @"CarInfoTypeLicenseNum"
#define  ENGINENUM_CAR      @"CarInfoTypeEngineNum"
#define  VIN_CAR                        @"CarInfoTypeVin"

#define  ShortCutTypeEasyBackHome       @"ShortCutTypeEasyBackHome"
#define  ShortCutTypeEasyBackCompany    @"ShortCutTypeEasyBackCompany"
#define  ShortCutTypeLockDoor           @"ShortCutTypeLockDoor"
#define  ShortCutTypeUnlockDoor         @"ShortCutTypeUnlockDoor"

#define  Success_Count                  @"successCount"
#define  Total_Alert                    @"totalAlert"
#define  Comment_Count                  @"commentCount"
#define  Refuse_Count                   @"refuseCount"

#define TIRE_PRESSURE_LF_GREEN   @"leftTop-b"
#define TIRE_PRESSURE_LF_YELLOW  @"leftTop-y"
#define TIRE_PRESSURE_LF_RED     @"leftTop-r"

#define TIRE_PRESSURE_LR_GREEN   @"leftBtm-b"
#define TIRE_PRESSURE_LR_YELLOW  @"leftBtm-y"
#define TIRE_PRESSURE_LR_RED     @"leftBtm-r"

#define TIRE_PRESSURE_RF_GREEN   @"rightTop-b"
#define TIRE_PRESSURE_RF_YELLOW  @"rightTop-y"
#define TIRE_PRESSURE_RF_RED     @"rightTop-r"

#define TIRE_PRESSURE_RR_GREEN   @"rightBtm-b"
#define TIRE_PRESSURE_RR_YELLOW  @"rightBtm-y"
#define TIRE_PRESSURE_RR_RED     @"rightBtm-r"

#define APP_NAME						@"onstar"
#define APPLE_WATCH_NAME                @"com.shanghaionstar.onstar.watchkitapp"

#define DECRIPE_AES256(VALUE,KEY)		[Util decryptData:[NSData dataWithBase64EncodedString:VALUE] withKey:KEY]
#define PARTNER_APP_ID					@"8l40opGU2zqsT2rXngH2D2lZLhweXMp2NmIQRM/ZkihG3SEbAzPSVltxIGpBJJS9"
#define PARTNER_APP_PWD					@"0z6fn4V7eagdH4s6XDlAf5kT1VuMfITy6QgrbGHQ+bE="



#define SOS_DEV                         [SOSEnvConfig config].development
static NSString *const bledbkey = @"com.onstar.bledbkey";
//存储上次连接的车的key
static NSString *const bleConnectdbkey = @"com.onstar.bleConnectdbkey";
#define APP_INNER_VERSION               ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"])

#define APP_VERSION_REQUEST             APP_VERSION

#define AMapKey                         ([Util aMapAPIKey])
#define AMapKeyInHouse                  @"5c1c3de32c3ecbddf53e1a7d960de396"

#define AMapKeyIpadAppStore             @"b4b287bca798e0a1b2f37968dcd9d2a1"

//#define SOS_BDI_APP_KEY                 (SOS_DEV ? @"87b4b263237a72d8f31969b062e3a0bc": @"3c784f94e94c0ae48820e1878b965e9c")
#define SOS_BDI_BID                     (SOS_DEV ? @"596709208989102": @"597958278519002")


#define DEVICE_OS_NAME					(ISIPAD?@"IPAD":@"IPHONE")

#define NEED_FORCE_UPGRADE				@"MANDATORY"

#define XML_DATE_FORMAT					@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
#define XML_DATE_FORMAT_WITH_ZONE		@"yyyy-MM-dd'T'HH:mm:ss.SSS"
#define DATE_AM_OR_PM					@"aaa"
#define DATE_HOUR						@"HH"
#define DATE_MINUTE						@"mm"
#define DATE_SECOND						@"ss"
#define DATE_DAY						@"dd"
#define DATE_MONTH						@"MM"
#define DATE_YEAR						@"yyyy"

#define NONil(obj) (obj==nil?@"":obj)
#define NNil(obj) (((obj == nil) || [obj isEqual:@"null"])?@"":obj)
#define NONull(obj) ([obj isEqual:@"null"]?@"":obj)
#define NONullToXX(obj) (obj == nil?@"xx":obj)
#define NONNullCChar(char) (char == NULL?"":char)
#define NOTime(obj)(obj == nil ?@"00":obj)


#define FONT_NORMAL              14
#define FONT_PLUS                18
#define BTN_WIDTH (SCREEN_WIDTH / 3 - 30)

#pragma mark ---***用户修改邮箱或者手机
#define TO_UP_ORIGNY  60
#pragma mark ------------------------------------------------

#pragma mark---***MacroMethod

#define BUILD_TIME						[Util getVerDate]


/**
 *	永久存储对象
 *
 *	@param	object    需存储的对象
 *	@param	key    对应的key
 */
#define UserDefaults_Set_Object(object, key)                                                                                                 \
({                                                                                                                                             \
NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];                                                                         \
[defaults setObject:object forKey:key];                                                                                                    \
[defaults synchronize];                                                                                                                    \
})

/**
 *	永久存储对象
 *
 *	@param	object    需存储的对象
 *	@param	key    对应的key
 */
#define UserDefaults_Set_Bool(object, key)                                                                                                 \
({                                                                                                                                             \
NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];                                                                         \
[defaults setBool:object forKey:key];                                                                                                    \
[defaults synchronize];                                                                                                                    \
})

/**
 *	取出永久存储的对象
 *
 *	@param	key    所需对象对应的key
 *	@return	key所对应的对象
 */
#define UserDefaults_Get_Object(key) [[NSUserDefaults standardUserDefaults] objectForKey:key]
#define UserDefaults_Get_Bool(key) [[NSUserDefaults standardUserDefaults] boolForKey:key]

//是否为空或是[NSNull null]
#define NotNilAndNull(_ref)  (((_ref) != nil) && (![(_ref) isEqual:[NSNull null]]))
#define IsNilOrNull(_ref)   (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]))

//字符串是否为空
#define IsStrEmpty(_ref)    (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]) ||([(_ref)isEqualToString:@""]) ||([(_ref)isEqualToString:@"(null)"]))
//数组是否为空
#define IsArrEmpty(_ref)    (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]) ||([(_ref) count] == 0))
//弱引用宏     1. SOSWeakSelf(self);  2. weakself.xx
#define SOSWeakSelf(weakSelf) __weak __typeof(&*self)weakSelf = self;
#define IS_SENDING_ODD_First_REQUEST  [NSString stringWithFormat:@"IS_SENDING_ODD_First_REQUEST_%@",[Util md5:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin]]

#define SOS_GetClassString(Class) NSStringFromClass([Class class])

#define SP_ID @"WkhPVTE5OTA="

