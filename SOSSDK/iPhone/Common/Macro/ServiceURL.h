//
//  ServiceURL.h
//  Onstar
//
//  Created by Joshua on 7/31/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#pragma mark -- Product ENV

#define BASE_URL                            ([Util getConfigureURL])

//h5上传图片接口
#define H5_updateFile_URL                   SOS_DEV?@"https://idt1.onstar.com.cn/mweb/mweb-main-rest/api/v1/banner/updateFile":@"https://www.onstar.com.cn/mweb/mweb-main-rest/api/v1/banner/updateFile"

#define FingerPrintDealEn_us   SOS_DEV?@"http://m-idt2.onstar.com.cn/mweb/idt5/onstar70/html/fingerprints/FingerprintDealEn-us.html":@"https://m.onstar.com.cn/mweb/vehicle/html/fingerprints/FingerprintDealEn-us.html"
#define FingerPrintDealZh_cn   SOS_DEV?@"http://m-idt2.onstar.com.cn/mweb/idt5/onstar70/html/fingerprints/FingerprintDealZh-cn.html":@"https://m.onstar.com.cn/mweb/vehicle/html/fingerprints/FingerprintDealZh-cn.html"
#define FaceIDDealZh_cn        SOS_DEV?@"http://idt5.onstar.com.cn/mweb/ma80/protocol/faceid.html":@"https://www.onstar.com.cn/mweb/ma80/protocol/faceid.html"


//电子手册
#define gen10_Manual_URL       SOS_DEV?([Util getOMOnstarStaticConfigureURL:@"/manual/wap10/index.jsp"]):@"https://om.onstar.com.cn/manual/wap10/index.jsp"
#define gen9_Manual_URL        SOS_DEV?([Util getOMOnstarStaticConfigureURL:@"/manual/wap9/index.jsp"]):@"https://om.onstar.com.cn/manual/wap9/index.jsp"


//通用分享地址
#define SHARE_TO_WEIXIN_URL                 [Util getStaticConfigureURL:@"/mweb/ma80/ShareService/index.html?osType=iPhone"]
//后视镜&行车记录仪分享地址
#define SHARE_TO_WEIXIN_RVM_URL                [Util getStaticConfigureURL:@"/mweb/ma80/mirror/position.html?"]

//应用服务介绍
#define App_Intro_CN                        ([Util getStaticConfigureURL:@"/mweb/ma80/introduce/introduce.html"])
//#define SmartDriver_agreement_share_URL     ([Util getStaticConfigureURL:@"/mweb/mweb-main/static/OnStar-MA7.0-h5/html/car-assessment/car-inspection.html"])
//驾驶行为评价协议
//#define SmartDriver_agreement_URL           ([Util getStaticConfigureURL:@"/mweb/mweb-main/static/OnStar-MA7.0-h5/html/car-assessment/SmartDriver-agreement.html"])
//更多服务
#define NEW_moreService_CN                  ([Util getStaticConfigureURL:@"/static/html/mobile/v1/service_more_zh.html"])
///早鸟活动规则：
#define    Early_Bird_Rules_URL             ([Util getStaticConfigureURL:@"/static/html/mobile/v1/early_bird_rules.html"])
///早鸟活动条款：
#define    Early_Bird_Provision_URL         ([Util getStaticConfigureURL:@"/static/html/mobile/v1/early_bird_conditions.html"])
#define OWNERlIFE_DISCLAIMER                ([Util getStaticConfigureURL:@"/mweb/mweb-main/static/OnStar-MA7.0-h5/html/car-butler/car-inspection.html"])

//默认报错页面
#define ERROR_500_URL                       ([Util getStaticConfigureURL:@"/mweb/mweb-main/static/OnStar-MA7.0-h5/html/500.html"])
#define FORGET_PASSWORD_URL                 ([Util getStaticConfigureURL:@"/mweb/mweb-page/newForgetPwd/index?from=ios&local=%@"])







#pragma mark -- END
///////////////////////////////////// END: SIT/UAT Enviroement ///////////////////////////////////////////

/***********************start** 8.0H5 链接地址************/
#pragma mark - 8.0 H5 链接地址
//BBWC教育页面
#define BBWC_EDUCATION                      ([Util getStaticConfigureURL:@"/static/html/WOnstarWeb/html/static-mobile-pages/Active/BBWCEdu/index.html?vehicle=%@"])
//爱车评估xx
#define CAR_ASSESSMENT_URL                  ([Util getStaticConfigureURL:@"/mweb/ma80/carEvaluation/index.html"])

#define CAR_FootPrint_URL                  ([Util getStaticConfigureURL:@"/mweb/ma80/track/index.html#/index"])

//驾驶行为xx
#define DRIVING_SCORE_URL                   ([Util getStaticConfigureURL:@"/mweb/ma80/drivingScore/index.html#/?isFirstInfo=%@"])

#define UBI_INSURANCE_URL                   ([Util getStaticConfigureURL:@"/mweb/ma80/ubi/index.html"])
#define ROAD_HELP_URL                       ([Util getStaticConfigureURL:@"/mweb/mweb-main/static/OnStar-MA7.0-h5/html/car-butler/roadrescue.html"])

//油耗水平排名xx
#define DRIVING_OIL_CONSUMPTION_DEFAULTURL         ([Util getStaticConfigureURL:@"/mweb/ma80/oilwear/html/oil_consumption.html"])
//能耗水平排名
#define DRIVING_ENERGINE_CONSUMPTION_URL    ([Util getStaticConfigureURL:@"/mweb/ma80/energyC/html/oil_consumption.html"])
//星享之旅
#define STAR_TRAVEL_URL                     [Util getStaticConfigureURL:@"/mweb/ma80/OnstarTravel/content.html?onstarCloseView=Yes&ctrlLoading=Y"]
//爱车课堂
#define VEHICLE_EDU_URL                     [Util getStaticConfigureURL:@"/mweb/ma80/carClass/index.html"]
//忘记密码
#define FORGETPASSWORD_URL                  [Util getStaticConfigureURL:@"/mweb/ma80/forgetpwd/index.html"]
//注册说明
#define Register_Guide_URL                  [Util getStaticConfigureURL:@"/mweb/ma80/accountshare/registGuide.html"]

//遥控分享说明
#define REMOTE_SHARE_MANUAL                 [Util getStaticConfigureURL:@"/mweb/ma80/accountshare/index.html"]
//使用须知8.0
#define REMOTE_CONTROL_USER_MANUAL          [Util getStaticConfigureURL:@"/mweb/ma80/useinstruction/index.html"]

//使用须知 ICM 2.0-------8.3
#define REMOTE_CONTROL_USER_MANUAL_ICM2          [Util getStaticConfigureURL:@"/mweb/ma80/useinstruction/useinstruction.html"]



#define KPackageUsageURL      [Util getStaticConfigureURL:@"/mweb/ma80/packageStatistics/index.html"]

#pragma mark - End
/***********************end** 8.0H5 链接地址************/

#define SERVER_IP_INT_KEY                   @"Env_id"
#define PORTAL_URL_KEY                      @"Portal_URL"
#define PORTAL_PILOT_VALUE                  1
#define PORTAL_PILOT_URL                    @"Pilot"

// OnStar API
#define ONSTAR_API_OAUTH                    @"/api/v1/oauth/token"
#define ONSTAR_API_UPGRADE                  @"/api/v1/oauth/token/upgrade"
#define ONSTAR_API_COMMANDS                 @"/api/v1/account/vehicles/%@/commands"
//#define ONSTAR_API_FEATURES                 @"/api/v1/account/vehicles/%@/features"//没有调用

//====remote control need check PIN
#define ONSTAR_API_LOCKDOOR                 @"/api/v1/account/vehicles/%@/commands/lockDoor"
#define ONSTAR_API_UNLOCKDOOR               @"/api/v1/account/vehicles/%@/commands/unlockDoor"
#define ONSTAR_API_REMOTESTART              @"/api/v1/account/vehicles/%@/commands/start"
#define ONSTAR_API_CANCELSTART              @"/api/v1/account/vehicles/%@/commands/cancelStart"
#define ONSTAR_API_ALERT                    @"/api/v1/account/vehicles/%@/commands/alert"
#define ONSTAR_API_LOCATION                 @"/api/v1/account/vehicles/%@/commands/location"
#define ONSTAR_API_CANCELALERT              @"/api/v1/account/vehicles/%@/commands/cancelAlert"

#define ONSTAR_API_DATAREFRESH              @"/api/v1/account/vehicles/%@/commands/diagnostics"
#define ONSTAR_API_TBT                      @"/api/v1/account/vehicles/%@/commands/sendTBTRoute"
#define ONSTAR_API_ODD                      @"/api/v1/account/vehicles/%@/navUnit/commands/sendNavDestination"

#define ONSTAR_API_POLLING                  @"/api/v1/account/vehicles/%@/requests/%@"
#define ONSTAR_API_REMOTE_HISTORY           @"/api/v1/account/vehicles/%@/requests"

//====hotspot
#define ONSTAR_API_GET_INFO                 @"/api/v1/account/vehicles/%@/hotspot/commands/getInfo"
#define ONSTAR_API_SET_INFO                 @"/api/v1/account/vehicles/%@/hotspot/commands/setInfo"
#define ONSTAR_API_GET_STATUS               @"/api/v1/account/vehicles/%@/hotspot/commands/getStatus"
#define ONSTAR_API_ENABLE_STATUS            @"/api/v1/account/vehicles/%@/hotspot/commands/enable"
#define ONSTAR_API_DISABLET_STATUS          @"/api/v1/account/vehicles/%@/hotspot/commands/disable"

//EV，PHEV
//#define ONSTAR_API_CHARGE_OVERRIDE          @"/api/v1/account/vehicles/%@/commands/chargeOverride"
#define ONSTAR_API_GET_PROFILE              @"/api/v1/account/vehicles/%@/commands/getChargingProfile"
#define ONSTAR_API_SET_PROFILE              @"/api/v1/account/vehicles/%@/commands/setChargingProfile"
#define ONSTAR_API_GET_SCHEDULE             @"/api/v1/account/vehicles/%@/commands/getCommuteSchedule"
#define ONSTAR_API_SET_SCHEDULE             @"/api/v1/account/vehicles/%@/commands/setCommuteSchedule"
//#define ONSTAR_API_STOP_FAST_CHARGE         @"/api/v1/account/vehicles/%@/commands/stopFastCharge"
//#define ONSTAR_API_CREATE_TRIP_PLAN         @"/api/v1/account/vehicles/%@/commands/createTripPlan"
#pragma mark -Login(MA8.2)

#define ONSTAR_API_LOGIN_USERBASICINFO         @"/sos/mobileaggr/v1/user/%@/suite"
//#define ONSTAR_API_LOGIN_USERVEHICLEASSETS  @"/mobile/api/v1/user/assets"
#define ONSTAR_API_LOGIN_USERVEHICLEPRIVILEGE  @"/sos/package/v1/vehicle_package/avaliableFuncs?vin=%@&role=%@"

#pragma mark -Account Info
//******************************************** 登录以及获取用户信息
//info3 获取userprofile

//修改密码
#define NEW_CHANGE_PASSWORD                 @"/sos/mobileuser/v1/user/subscriber/%@/password"

//update email and phone
#define NEW_CHANGE_MOBILE_EMAIL             @"/sos/mobileuser/v1/user/register/subscriber/contact"

#define NEW_CHANGE_GETCODE                  @"/msp/api/v3/user/subscriber/%@/code"

//info3 非app注册用户验证h5页面
#define INFO3_NOT_APP_USER_LOGIN      ([Util getStaticConfigureURL:@"/mweb/ma80/info3/info3-verify.html?username=%@&type=app"])
#pragma mark -CheckAPPVersion
#define MA82_API_Check_APPVersion           @"/sos/contentinfo/v2/appVersion/now?os=IPHONE&version=%@"
#define MA92_API_Check_Prepayment           @"/sos/contentinfo/v1/switch/prepaidCard"


#pragma mark -Register
//******************************************* Register *******************************************
#define INFO3_REGISTER_SUBSCRIBER           @"/sos/registry/api/v1/user/register/info3/subscriber"

//info3 0-2

#define INFO3_REGISTER_Visitor                 @"/sos/registry/api/v1/user/register/info3/visitor"


//info3 0-1

//#define INFO3_REGISTER_UPGRADE                @"/msp/api/v3/user/register/info3/upgrade"

//info3 1-2

#define NEW_REGISTER_CHECK_UNIQUE           @"/sos/registry/api/v1/user/register/checkUnique"//checkUnique


#define NEW_REGISTER_CODE_IMAGE_CAPTCHA     @"/sos/registry/api/v1/user/register/captcha/required"  //图片验证码

#define NEW_REGISTER_CODE_IMAGE_CAPTCHA_GENERATE       @"/sos/registry/api/v1/user/register/captcha/generate/%@"

#define NEW_REGISTER_CODE_IMAGE_CAPTCHA_VALIDATE  @"/sos/registry/api/v1/user/register/captcha/validate/%@/%@"


//7.2 info3
#define INFO3_REGISTER_CODE_GET               @"/sos/registry/api/v1/user/register/info3/code/send"//info3统一发送验证码
#define INFO3_REGISTER_CODE_CHECK               @"/sos/registry/api/v1/user/register/info3/code/validation"//info3 校验验证码


/***********************start 8.0新增接口************/
#define Register_Vehicle_Enroll                 @"/sos/registry/api/v1/user/register/enroll/validation"

#define Register_Subscriber_Check               @"/sos/registry/api/v1/user/register/subscriber/validation"

#define Register_Govid_Check                    @"/sos/registry/api/v1/user/register/enroll/vehicle/validation"

#define Register_Govid_Change_Check             @"/sos/registry/api/v1/user/register/enroll/validation/govid"


#define Register_Subscriber_Submit              @"/sos/registry/api/v1/user/register/enroll/submit"

#define BBWC_Security_Question                  @"/sos/mobileuser/v1/public/security_questions?govid="

#define BBWC_Info                               @"/sos/mobileuser/v1/user/subscriber/enroll/info/encrypt"


#define BBWC_Submit                             @"/sos/registry/api/v1/user/subscriber/%@/accounts/%@/vehicles/%@/bbwc"

#define OnstarUserInfo_Submit                   @"/sos/mobileuser/v1/user/subscriber/accounts/vehicles/userInfo"


#define Enroll_Upload_ReceiptPhoto              @"/mweb/mweb-main-rest/api/v1/img/file/imgs"
//注册验证pin码
#define Register_Check_Pin                      @"/sos/mobileuser/v1/user/register/validation/pin"

#define Upgrade_Check_IsgaaSub                  @"/sos/registry/api/v1/user/register/gaaMobileAndEmail"

#define Upgrade_Check_Visitor                   @"/sos/registry/api/v1/user/register/enroll/vehicles/add"

#define Modify_Pin_Check                        @"/sos/mobileuser/v1/user/update/userInfo/validation/pin"

/***********************end** 8.0新增接口************/

#pragma mark -Vehicle Info
//*******************************************车辆信息*******************************************************
// 切换车辆
#define NEW_GET_VEHICLE_LIST                @"/sos/mobileuser/v1/user/subscriber/%@/accounts/vehicles"


//info3切车
#define INFO3_CHANGE_VEHICLE                  @"/sos/mobileuser/v1/user/subscriber/accounts/%@/vehicles/info3/switch"
//ovd email
#define OLD_OVD_EMAIL                  @"/sos/vehInfo/v1/user/subscriber/%@/accounts/%@/vehicles/%@/ovds"
#define NEW_OVD_EMAIL                  @"/sos/vehInfo/v2/GetEmailReport/getOVDEmailHtml?subscriberID=%@&vin=%@"

#define NEW_OVD_EMAIL_DETAIL            @"/sos/vehInfo/v1/user/subscriber/%@/accounts/%@/vehicles/%@/ovds/%@"

//车辆信息
#define VEHICLE_INFO_URL                  @"/sos/vehInfo/v1/user/vehicles/%@/extravehinfo"



//7.2 info3
#define VEHICLE_IS_INFO3_BY_GID                  @"/sos/registry/api/v1/vehicle/info3/infotainment_capable/getGidVehicleUnit?gid="

#define VEHICLE_IS_INFO3_BY_VIN                  @"/sos/registry/api/v1/vehicle/info3/infotainment_capable/getVinVehicleUnit?vin="

//#define INFO3_LATEST_TCPS_LEGAL                  @"/msp/api/v3/legal/documents"      //相关类已不再调用
/*******************7.3 车分享************/
//车分享列表
#define CARSHARING_LIST                  @"/sos/carsharing/v1/user/carSharing/%@/%@/users"     //   /{accountId}/{subscriberId}/

//车分享设置时效
#define CARSHARING_SETTING_AUTH          @"/sos/carsharing/v1/user/carSharing/%@/%@/authorization"      //    /{accountId}/{subscriberId}/


//获取当前用户车分享权限
#define CARSHARING_STATUS                @"/sos/carsharing/v1/user/carSharing/%@/%@/status"     //    {accountId}/{subscriberId}

/*******************7.3 车分享************/
#pragma mark -Package & PPC
//********************************************买包*****************************************************
// 可以购买的套餐包
#define NEW_PURCHASE_PACKAGE_CORE                @"/sos/package/v1/qualified_product/core"   // 可以购买的核心套餐包
#define NEW_PURCHASE_PACKAGE_DATA                @"/sos/package/v1/qualified_product/data"   // 可以购买的流量套餐包

//查询LBS收货人信息接口
#define SOS_Order_LBS_Consignee_URL  @"/sos/order/v1/lbs/last/delivery"

//创建订单
#define SOS_Order_Creat_URL                 @"/sos/order/v1/order/saveOrder"
//创建LBS订单
#define SOS_Order_Creat_LBS_URL  @"/sos/order/v2/order"

//ADD 7.2												/v1/paySgin/getOrderPaySign/
#define NEW_GET_PURCHASE_ORDER_INFO         @"/sos/order/v1/paySgin/getOrderPaySign/%@"
//ADD 7.4 支付列表
//#define PAYMENT_CHANNEL                  	@"/msp/api/v3/paymentChannel/paymentChannelList"
#define PAYMENT_IAPSERVICE               	@"/sos/order/v1/applepay/callback"
/** 智能后视镜支付验证URL */
#define Payment_IAPRearviewMirrorService @"/sos/order/v2/applePay/app/payCallBack"

#define NEW_PURCHASE_GET_ORDER_HISTORY      @"/sos/order/v1/order/history"

#define NEW_PURCHASE_GET_ORDER_LBS_LIST      @"/sos/order/v2/orders"


#define NEW_PURCHASE_QUERY_ORDER_STATUS_URL @"/sos/order/v1/order/%@"
#define NEW_PURCHASE_SAVE_INVOICE_URL       @"/msp/api/v3/user/subscriber/%@/accounts/%@/vehicles/%@/package/%@/order/%@/invocice"
//获取流量包列表
#define NEW_PURCHASE_GET_DATA_LIST_URL      @"/sos/package/v1/vehicle_product/data"

//加包
#define NEW_PACKAGEINFO_URL_PRE             @"/sos/package/v1/vehicle_product/core?vin=%@"
//MA90
#define SOSPackageServiceURL               @"/sos/package/v1/vehicle_package/overview?vin=%@&gen9=%@" //返回剩余套餐/流量

#define Package_GetRemainDays_URL           @"/sos/package/v1/remaining_days?vin=%@"
#define Package_GetRemainData_URL           @"/sos/package/v1/remaining_bytes?vin=%@&packageCode=%@"
// PPC card
#define NEW_PPC_GET_ACCOUNT_BY_VIN          @"/sos/mobileuser/v1/user/subscriber/account?vin=%@"

#define NEW_PPC_ACTIVATE_CARD_BY_ID         @"/sos/package/v1/prepaid_card"

#define NEW_PPC_GET_ACTIVATE_HISTORY        @"/sos/package/v1/prepaid_card/history?OSType=%@"


#pragma mark -Dealers
// ********************************************经销商以及首选经销商********************************************
//首选经销商
#define NEW_GET_PREFERRED_DEALER_DEALER     @"/sos/mobileuser/v1/user/vehicles/dealers/prefer"

#define NEW_GET_PREFERRED_UPDATE_DEALER     @"/sos/mobileuser/v1/user/vehicles/dealers/prefer"
//周边经销商
#define NEW_DEALER_GET_CITYDEALERS          @"/sos/dealerinfo/v1/citydealer/list?cityCode=%@&longitude=%@&latitude=%@&queryType=%@&dealerBrand=%@"

#define DEALER_NEARBY_LIST                  @"/sos/mobileaggr/v1/dealers/nearby"

#define NEW_DEALER_GETAROUNDDEALERS         @"/msp/api/v3/user/subscriber/%@/accounts/%@/vehicles/%@/dealers/around"

//预约经销商
//#define NEW_GET_DEALERS             @"/msp/api/v3/user/subscriber/%@/accounts/%@/vehicles/%@/maintenance/dealers"
#define NEW_GETDEALERPREORDERS      @"/msp/api/v3/user/subscriber/%@/accounts/%@/vehicles/%@/maintenance/order"
#define NEW_SENDDEALERPREORDER      @"/msp/api/v3/user/subscriber/%@/accounts/%@/vehicles/%@/maintenance/order"


#pragma mark -Map
//*******************************************地图***********************************************************

// 收藏目的地地址
#define NEW_ADD_FAVOURITE_DESTINATION            @"/sos/valueadded/v1/poi/destination"
#define SOS_Check_Collection_State_URL           @"/sos/valueadded/v1/poi/favorite/isAdd?fuid=%@"

#define DEL_FAVOURITE_DESTINATION            	@"/sos/valueadded/v1/poi/destination/%@"
#define SOS_Delete_All_Colections_URL            @"/sos/valueadded/v1/poi/destination/delete"



// 获取收藏列表
#define NEW_GET_LIST_DESTINATION            @"/sos/valueadded/v1/poi/favorites?pageNumber=%@&pageSize=%@"


//获取家和公司Poi信息
#define HOME_POI_GET                        @"/sos/valueadded/v1/poi/destinations"


//设置家和公司Poi
#define HOME_POI_SET                        @"/sos/valueadded/v1/poi/destination"



//geo fence
#define NEW_GEOFENCE                        @"/sos/valueadded/v1/vehicle/user/accounts/%@/vehicles/%@/location/geo_fencing"


#pragma mark -Others
//******************************************Others*********************************************
// 获取landingpage
#define NEW_GET_LANDING_IMAGE_URL           @"/sos/contentinfo/v1/public/landingpage"

// 广播
#define NEW_GET_BROADCAST_DETAIL            @"/msp/api/v3/public/broadcasts/%@"

// 广告Banner
#define NEW_BANNER                          @"/sos/contentinfo/v1/public/banners"


//#define PROVINCE_URL                        @"/msp/api/v3/public/region/province"
#define PROVINCE_URL                        @"/sos/dict/v1/region/province?locale=zh_CN"

//#define PROVINCE_CITY_URL                   @"/msp/api/v3/public/region/city/%@"
#define PROVINCE_CITY_URL                   @"/sos/dict/v1/region/city/%@"


//内容管理【指南:（真实故事，服务贴士，服务介绍）使用帮助，安吉星服务协议】
#define NEW_GET_CONTENT                     @"/sos/contentinfo/v1/public/contents"

//#define NEW_GET_CONTENT_DETAIL              @"/msp/api/v3/public/contents/%@?versionCode=%@&category=%@"
#define NEW_GET_CONTENT_DETAIL              @"/sos/contentinfo/v1/public/content"


// Save device/Session
#define NEW_SAVE_DEVICE_URL                 @"/sos/mobileuser/v1/public/device_info"


#define NEW_SAVE_SESSION_URL                 @"/sos/mobileuser/v1/public/save_session"

// 启动检查SDK版本
#define NEW_CHECK_APP_VERSION_URL           @"/sos/contentinfo/v1/public/appVersion"

////报告
//#define MSP_REPORT                          @"/msp/api/v3/public/report"
//充电通知
#define NEW_phevCharge                      @"/sos/vehInfo/v1/user/vehicles/%@/phevcharge"


//获取Layer7闪灯鸣笛时间
#define REMOTE_ALERT_TIME_URL               @"/msp/api/v3/public/alert_duration"     //app端不再调用


#pragma mark -第三方查询
//检测itunes app版本
#define CHECK_ITUNES_VERSION                @"https://itunes.apple.com/cn/lookup?id=%@"


//获取第三方链接：滴滴，Yhouse，高尔夫
//#define GET_SUPHKP_URL                      @"/msp/api/v3/thirdparty/h5/redirect/mro?partner_id=%@"
#define GET_SUPHKP_URL                      @"/sos/contentinfo/v1/thirdparty/redirect/mro?partner_id=%@"

///充电桩列表
#define     Charge_Station_List_URL         @"/sos/valueadded/v1/thirdparty/charge_station/stations"
///充电桩详情
#define     Charge_Station_Detail_URL       @"/sos/valueadded/v1/thirdparty/charge_station/stations?stationId=%@"

///我的足迹多城市,概览
//#define My_FootPrint_OverView_URL           @"/sos/trail/v1/user/vehicles/%@/services/footprint/summary"
#define My_FootPrint_OverView_URL           @"/sos/trail/v2/footprint/sum"


///我的足迹单城市,详情
#define My_FootPrint_Detail_URL             @"/sos/trail/v1/user/vehicles/%@/services/footprint/city?city=%@"

//上传足迹
#define My_FootPrint_Upload_URL           @"/sos/trail/v2/footprint"

///删除某条足迹
#define Delete_My_FootPrint_URL             @"/sos/mobileuser/v1/user/vehicles/%@/footprint/%@"


///概览模式 分享接口
#define Share_FootPrint_OverView_URL        @"/mweb/mweb-main-rest/resources/v1/user/subscriber/%@/accounts/%@/vehicles/%@/services/footprint/summary?longitude=%@&latitude=%@"

///详情模式 分享接口
#define Share_FootPrint_Detail_URL          @"/mweb/mweb-main-rest/resources/v1/user/subscriber/%@/accounts/%@/vehicles/%@/services/footprint/city?longitude=%@&latitude=%@&city=%@&scale=%@"


//----------------------------Local Vehicle Service-------------------------
//打开、关闭服务,根据httpMethod(PUT/DELETE)区分操作状态(open/close)
#define open_local_service_URL              @"/sos/mobileuser/v1/user/%@/vehicles/%@/services"
#define update_local_service_URL            @"/sos/mobileuser/v1/user/%@/vehicles/%@/services/%@"
#define update_lbs_service_URL              @"/sos/mobileuser/v1/user/%@/equipment/services?serviceNames=LBS"
//查询服务状态,如果serviceNames不给的话查询全部服务
#define get_local_services_URL              @"/sos/mobileuser/v1/user/%@/vehicles/%@/services/%@"

//msp第三方平台网站做分发
#define MSP_Dispatch_3rd_Sec @"/sos/contentinfo/v2/thirdparty/dispatch"

//凯迪拉克 俱乐部 URL
#define CadillacClubURL @"http://cadillac-club.mysgm.com.cn/touch/control/home"
//雪佛兰
#define ChevroletClubURL  @"http://uclub.mysgm.com.cn/touch/index.html"
///获取设置信息-TAN/OVD/DA提醒设置
#define GetNotifyConfig     @"/sos/mobileuser/v1/user/subscriber/%@/vehicles/%@/notifypreference?btype=%@"
///修改设置信息-TAN/OVD/DA提醒设置
#define ChangeNotifyConfig     @"/sos/mobileuser/v1/user/notifypreference"


///用户是否绑定过微信
#define ValidatenotifyConfig  @"/sos/mobileuser/v1/user/validateNotifyConfig"

///设置TAN/OVD提醒发送验证码
//#define Sendnotifypreference @"/msp/api/v3/user/subscriber/%@/notifypreference/code"
#define Sendnotifypreference @"/sos/mobileuser/v1/user/subscriber/notifypreference/code"

///设置TAN/OVD提醒校验验证码
//#define ValidatenotifyCode   @"/msp/api/v3/user/subscriber/%@/notifypreference/validation"
#define ValidatenotifyCode   @"/sos/mobileuser/v1/user/subscriber/notifypreference/validation"


//爱车评估
//#define URL_CarReport           @"/msp/api/v3/user/evaluate/carconditionreport"      //接口已不再调用
//能耗排名
#define URL_EnergyRank          @"/sos/ods/v1/user/energyeconomy/rank/cardshow"

//驾驶行为评分
#define URL_DrivingScore        @"/sos/ods/v1/user/smartdrive/getdrivingscore/cardshow"

// 获取近期行程卡片数据
#define URL_RecentTrailData    	@"/sos/trail/v2/trip/card/data"

//油耗排名
#define URL_OilRank             @"/sos/ods/v1/user/fueleconomy/rank/cardshow"



//星享之旅
//#define URL_StarTravel          @"/msp/api/v3/travel/getCurrentTravelInfo"
#define URL_StarTravel          @"/sos/valueadded/v1/travel/getCurrentTravelInfo"



#define URL_Greeting            @"/sos/mobileuser/v1/public/greetings/%@"



//登录成功后获取上汽保险信息弹框
#define URL_InsurancePrompt     @"/sos/contentinfo/v1/commonPrompt"


//可否显示UBI接口
#define URL_ShowUBI             @"/sos/valueadded/v1/ubi/showUBI"



// LBS 服务协议地址
#define SOSMirrorProtocolURL             ([Util getStaticConfigureURL:@"/mweb/ma80/mirror/recorder.html"])

#define LBSGetProtocolStatueURL     @"/sos/mobileuser/v1/user/%@/equipment/services?serviceNames=LBS"
// PUT  新增LBS设备管理接口
#define LBSAddDeviceURL             @"/sos/smartdevice/v1/lbs/service/saveOrUpdateDevice"

// POST LBS设备登录接口
#define LBSLoginDeviceURL           @"/sos/smartdevice/v1/lbs/service/login"

// POST 一体机使用说明书
#define OMInstructionURL           @"https://www.onstar.com.cn/mweb/ma80/aioImac/recorder.html"

// GET  用户LBS设备查询接口   根据idpUserId获取用户名下的所有LBS设备

#define LBSGetDeviceListURL         @"/sos/smartdevice/v1/lbs/service/getDevices"
//#define LBSGetDeviceListURL         @"/msp/api/v3/thirdparty/lbs/%@"


// GET  根据设备id获取实时位置接口        (地图类型，String类型，可选值范围” baidu,google,amap,默认值amap”)
#define LBSGetLocationURL           @"/sos/smartdevice/v1/lbs/thirdparty/lbs/getTracking?id=%@&mapType=amap"

// GET  根据设备id获取历史轨迹接口         轨迹查询 开始/结束 时间,北京时区,格式yyyy-MM-dd HH:mm:ss
#define LBSGetHistoryLocationURL    @"/sos/smartdevice/v1/lbs/thirdparty/lbs/getHistory?id=%@&mapType=google&startTime=%@&endTime=%@"

// GET  查询LBS电子围栏接口
#define LBSGetGEOURL                @"/sos/smartdevice/v1/lbs/electricFence/getElectricFence/%@"

// POST 删除LBS电子围栏接口
#define LBSDeleteGEOURL                @"/sos/smartdevice/v1/lbs/electricFence/deleteElectricFence"


// POST 新增/更新LBS电子围栏接口
#define LBSUpdateGEOURL              @"/sos/smartdevice/v1/lbs/electricFence/saveOrUpdate"



/***********************start** 8.1H5 链接地址************/
//H5 8.1新增上传图片接口
#define MA8_1_H5_UPDATEFILE_URL     ([Util getStaticConfigureURL:@"/mweb/mweb-main-rest"])
//问题与反馈地址URL
#define MA8_1_Question_Feedback_URL ([Util getStaticConfigureURL:@"/mweb/ma80/problemFeedback/index.html"])
//用车手账H5界面
#define VEHICLE_ACCOUNT_URL          [Util getStaticConfigureURL:@"/mweb/ma80/carAccount/home.html"]
//用车手账接口
#define VEHICLE_CASHBOOK_API         @"/sos/valueadded/v1/accountBook/user/accountBook/fee?vin="

/***********************end** 8.1H5 链接地址************/

/***********************start** 8.2接口 地址************/
#define MA8_2_H5_CarSecretary_PromptRule_URL    [Util getStaticConfigureURL:@"/mweb/ma80/vehicleSecretary/notify.html"]
#define MA8_2_AR_Config_URL                 ([Util getStaticConfigureURL:@"/static/AR/config/IOS"])

#define MA8_2_CarSecretary_API                  @"/sos/valueadded/v1/vehicle/subscriber/%@/accounts/%@/vehicles/%@/vehicleSecretary/info"

#define MA8_2_VerifyPersonInfoURL                  @"/mweb/ma80/redirect/realNameAuthentication.html"

#define MA8_2_OLD_DAAP_REPORT       @"/daap/api/v1/data/upload"
#define MA8_2_DAAP_CLIENT_INFO      @"/daap/api/v1/data/clientInfo"
#define MA8_2_DAAP_ACTION_INFO      @"/daap/api/v1/data/actionInfo"
#define MA8_2_DAAP_SYS              @"/daap/api/v1/data/sendSys"


/***********************end** 8.2接口 地址************/


/*******************start**** 8.3接口 地址****************/

#define MA8_3_TCPS              @"/sos/tcps/v2/latest?channel=mobile"
#define MA8_3_TCPS_NEED_SIGN    @"/sos/tcps/v2/tosign?channel=mobile"
#define MA8_3_TCPS_SIGN         @"/sos/tcps/v2/sign?channel=mobile"

#define MA8_3_FEEDBACK_URL      ([Util getStaticConfigureURL:@"/mweb/ma80/problemFeedback/feedback.html"])
#define MA8_3_BDI_MORE          ([Util getmOnstarStaticConfigureURL:@"/probes/list.html"])


/*******************end**** 8.3接口 地址****************/

/*****************start******8.4 新增接口 地址 **********/

//POST  智能后视镜绑定用户与设备  设备id
//#define BINDMIRROR @"/sos/rvmirror/v1/rvms/%@/user/actions/bind"
#define BINDMIRROR @"/sos/rvmirror/v1/rvm/bind/vehicle"

//GET  获取已绑定的智能后视镜列表 用户id
#define BINDMIRRORLIST @"/sos/rvmirror/v1/user/rvms"
//DELETE  智能后视镜解绑用户与设备   设备id
//#define UNBINDMIRROR @"/sos/rvmirror/v1/rvms/%@/user/actions/unbind"
#define UNBINDMIRROR @"/sos/rvmirror/v1/rvm/%@/user/actions/unbind"

// GET 后视镜订单列表记录接口
#define RearviewOrdersList @"/sos/order/v1/devices/%@/orders"

//POST智能后视镜保存/修改设备用户信息   用户id
//#define SAVEMIRRORINFO @"/sos/rvmirror/v1/user/%@"
#define SAVEMIRRORINFO @"/sos/rvmirror/v1/user"

//POST智能后视镜车辆信息保存/修改
//#define SAVEVEHICLEINFO @"/sos/rvmirror/v1/rvm/vehicleInfo"
#define SAVEVEHICLEINFO @"/sos/rvmirror/v1/rvm/%@/vehicleInfo"

//GET  智能后视镜查询设备配置信息   设备id
#define GETMIRRORINFO @"/sos/rvmirror/v1/screen/%@/vehicle"
//GET  智能后视镜查询设备绑定的用户信息   idpUserId 设备id
//#define GETMIRRORUSERINFO @"/sos/rvmirror/v1/users/%@/rvm/%@"
#define GETMIRRORUSERINFO @"/sos/rvmirror/v1/user"

//  后视镜流量购买  设备id
#define GETMIRRORRECHCHARGE @"/sos/rvmirror/v1/rvms/%@/sim/recharge/url"
//获取wifi设置 GET
#define GETWIFISETTING @"/sos/rvmirror/v1/rvms/%@/wifi"
//保存wifi设置 POST
#define SAVEWIFISETTING @"/sos/rvmirror/v1/rvms/%@/wifi"
//获取fm设置
#define GETFMSETTING @"/sos/rvmirror/v1/rvms/%@/fm"
//保存fm设置
#define SAVEFMSETTING @"/sos/rvmirror/v1/rvms/%@/fm"
//查询下发结果
#define GETREQUESTRESULT   @"/sos/rvmirror/v1/resultdata/%@"
//获取后视镜位置
#define GETDEVICELOCATION  @"/sos/rvmirror/v1/rvms/%@/location"
//导航下发 设备id
#define SENDDOWNNAV @"/sos/rvmirror/v1/rvms/%@/destination/actions/send"
//获取后视镜列表（新）
#define GETMIRRORLIST @"/sos/rvmirror/v2/users/rvms"
//获取绑定后视镜时的token
#define GETMIRRORTOKEN @"/sos/rvmirror/v1/rvms/qr/%@/bindToken"
//获取后视镜位置刷新时间
#define GETMIRRORREFRESHTIME @"/sos/rvmirror/v1/rvms/refreshTime"
//根据imei获取后视镜对应vin号，修改设备信息时用
#define GETMIRRORVIN @"/sos/rvmirror/v1/rvm/%@/complete/bindInfo"

// 当前套餐及未开启套餐
#define CURRENTMIRRORPACKAGE @"/sos/mobileaggr/v1/package/local/offerings?imei=%@"
// 点击购买更多后的可买包
#define MIRRORPACKAGECANBUY @"/sos/package/v1/local/packages?imei=%@"


#pragma mark --Mobile User
//GET      根据 idpUserId 查询安吉星用户绑定 OnstarLink 情况
#define SOSOnstasrLinkGetBindInfoURL             @"/sos/mobileuser/v1/user/%@/onstarLink"
//POST  绑定 onstarLink
#define SOSOnstasrLinkBindURL                    @"/sos/mobileuser/v1/user/%@/onstarLink"
//PUT   修改 onstarLink 绑定手机号
#define SOSOnstasrLinkModifyPhoneNumURL          @"/sos/mobileuser/v1/user/%@/onstarLink"

//POST  onstarLink 发送验证码
#define SOSOnstasrLinkSendVerificationCodeURL     @"/sos/mobileuser/v1/user/securitycode?username=&receiver=%@&destType=S"
//POST  onstarLink 校验验证码
#define SOSOnstasrLinkCheckVerificationCodeURL     @"/sos/mobileuser/v1/user/securitycode/verification?username=&receiver=%@&destType=S&secCode=%@"
//GET
#define SOSOnstarUserBindWechatQueryURL     @"/sos/mobileuser/v1/user/wechat/app/bindstatus"
//PUT
#define SOSOnstarUserUnBindWechatURL        @"/sos/mobileuser/v1/user/wechat/app/unbind"
//实名认证check
#define SOSOnstarUserRealNameVerifyURL        @"/sos/vehInfo/v1/user/certification"

//GET      获取 onstarLink OTA 升级信息
#define SOSOnstasrLinkGetOTAInfoURL                 @"/mweb/onstarlink/ota.json"
//POST  上传 onstarLink 用户经纬度            TODO 待后续版本完善
//#define SOSOnstasrLinkUploadUserLocationURL        @""

#define SOSDEALER_RECORD        ([Util getStaticConfigureURL:@"/mweb/ma80/redealer/index.html#/reRecord"])
//更新idm用户信息
#define Upgrade_User_Info                       @"/sos/mobileuser/v1/users/"
#define SOSUpload_User_Hotkey                       @"/sos/mobileuser/v1/user/hotKey/upload"
#define SOSUser_Schedules                       @"/sos/mobileaggr/v1/user/schedules"
#define SOSUser_Schedules_Bind                  @"/sos/mobileaggr/v1/user/schedule/bind"

//新上传头像接口
#define UPLOAD_AVATAR                           @"/sos/mobileBizAggr/v1/users/avatar"
#define SOS_IM_COMPLAIN_URL                     @"/mweb/ma80/social/index.html"

/**********************8.4.1 ****************/
#define SOS_Vehicle_Condition_Share_URL         @"/mweb/ma80/carSituation/index.html"

// GET 获取/修改用户积分公益 积分信息
#define SOSGetUserDonateInfoURL                 @"/sos/credit/v1/user/%@/public_welfare/score"
// GET 获取积分公益 参与过的活动信息
#define SOSGetDonateActivityListURL				@"/sos/credit/v1/user/%@/public_welfare/projects"

// H5 参与过的公益活动详情页
#define SOSH5DonateDetailURL					@"/mweb/ma80/publicScore/details/detail%@.html"

/**********************8.4.1 ****************/
#define SOS_Vehicle_Condition_Share_URL         @"/mweb/ma80/carSituation/index.html"

// 安悦 协议页面
#define SOSAYAgreementURL

// 安悦 H5 Header
#define  SOSAYChargeH5HeaderURL 				SOS_DEV ? @"http://tapp.anyocharging.com:6337/aycharge/v1/html" : @"http://api.anyocharging.com:6337/aycharge/v1/html"
// 安悦 H5 解锁充电桩
#define  SOSAYChargeURL_UNLOCK 					@"/unlock?sessionId=%@&deviceNumber=%@&sourceId=onstar"
// 安悦 H5 用户钱包
#define  SOSAYChargeURL_Wallte                	@"/wallet?sessionId=%@&sourceId=onstar"
// 安悦 H5 订单历史
#define  SOSAYChargeURL_Order_History           @"/historyorder?sessionId=%@&sourceId=onstar"
// 安悦 H5 订单详情
#define  SOSAYChargeURL_Order_Detail            @"/currentorder?sessionId=%@&sourceId=onstar"

// POST 安悦 用户登录/注册
#define SOSAYChargeLoginURL						@"/sos/valueadded/v1/thirdparty/charge_station/loginorregister"
// GET	安悦 查询当前用户是否存在在途订单
#define SOSAYChargecheckUserOrderURL      		@"/sos/valueadded/v1/thirdparty/charge_station/orderstate"
// POST	安悦 获取验证码
#define SOSAYVerifyCodeURL           			@"/sos/mobileuser/v1/user/securitycode?receiver=%@&username=&destType=S"

// POST 法率网 获取用户签名
#define SOSiLawMessageURL                       @"/sos/valueadded/v1/user/encryp/information"

/**********************9.0 ****************/
#ifdef SOSSDK_SDK

#define SOSLifeHomeURL                          ([Util getStaticConfigureURL:@"/mweb/ma80/h5/#/oneAppLife"])

#else

#define SOSLifeHomeURL                          ([Util getStaticConfigureURL:@"/mweb/ma80/life2/index.html#/home"])

#endif

#define SOSFetchVehicleAvatarURL                @"/sos/mobileaggr/v1/vehicle/image"
#define SOSRecentJoureny                       ([Util getStaticConfigureURL:@"/mweb/ma80/drivingScore/index.html#/journey"])

#define SOSUploadNotificationStatus                        @"/sos/mobileuser/v1/user/notification/status"

// POST 前端监控
#define SOSMonitorURL                          @"/api/v2/spans"

//GET 登陆后获取需要弹窗的类别
#define LOGINPOPUP                             @"/sos/mobileuser/v1/popups/loggedIn"
//点击了年度报告
#define LOGINPOPUPACCEPT                       @"/sos/mobileuser/v1/popupLog"

#define GET_TOTAL_MESSAGE @"/sos/internalmsg/v1/user/%@/message?version=%@"
#define DEL_MESSAGE @"/sos/internalmsg/v1/user/%@/message/category/%@"


//IDM账号验证码验证
#define IDM_VERIFICATION_CODE                      @"/sos/mobileuser/v2/user/securitycode/verification"
//IDM账号绑定
#define IDM_ACCOUNT_BIND                           @"/sos/mobileuser/v1/mobile/bindOrMerge"
//IDM账号合并
#define IDM_ACCOUNT_MERGE                          @"/sos/mobileuser/v1/account/merge"


#define  SOSSocialCreateOrder   @"/sos/valueadded/v1/pickup/create/app"
#define  SOSSocialSelectOrder   @"/sos/valueadded/v1/pickup/info/app"
#define  SOSSocialChangeState   @"/sos/valueadded/v1/pickup/state/app"

//后台开关,是否注册极光推送
#define JPUSH_TRIGGER   @"/sos/mobileaggr/v1/pushNotify/available"

// 获取图形验证码  GET
#define SOSSmartDevice_GetImgCodeURL		@"/sos/smartdevice/v1/image/verificationCode"
// 发送手机验证码  POST
#define SOSSmartDevice_GetSMSCodeURL    	@"/sos/smartdevice/v1/msg/verificationCode"
// 校验手机验证码  PUT
#define SOSSmartDevice_verifySMSCodeURL		@"/sos/smartdevice/v1/msg/verificationCode/verify"

#define SOS_Car_Class_GetInfo_URL			@"/sos/contentinfo/v1/vehicle/association/resource/%@?version=%@"

// 获取补充手机号业务图形验证码  GET
#define SOSReplenishMobile_GetImgCodeURL        @"/sos/mobileuser/v1/user/graphics/verificationCode"
// 发送补充手机号业务手机验证码  POST
#define SOSReplenishMobile_GetSMSCodeURL        @"/sos/mobileuser/v1/user/phone/verificationCode"
#define SOSReplenishMobile_verifySMSCodeURL         @"/sos/mobileuser/v1/user/supplemenPhone"


// 根据经纬度获取50KM所有加油站信息		GET
#define SOSOilStationListURL				@"/sos/valueadded/v1/wisdomCheers/petrolStationList"
// 根据idpuserid 获取订单列表			GET
#define SOSOilOrderListURL                	@"/sos/valueadded/v1/wisdomCheers/orderList"
// 获取油号列表						GET
#define SOSOilInfoListURL                	@"/sos/valueadded/v1/wisdomCheers/oilInfoList"
// 获取油站所有油号信息               	GET
#define SOSStationOilInfoListURL          	@"/sos/valueadded/v1/wisdomCheers/queryStationOilList"
// 根据油站id和油号查询符合条件的油枪号	GET
#define SOSOilGunInfoListURL       			@"/sos/valueadded/v1/wisdomCheers/oilgunNumList"

#define GET_MESSAGE_LIST              @"/sos/internalmsg/v1/user/%@/message/category/%@?pageSize=10&pageNum=%ld"
#define SOS_UpdateMessage_Read        @"/sos/internalmsg/v1/user/message"
#define SOS_UpdateMessage_Delete      @"/sos/internalmsg/v1/user/%@/message/category/%@"

#define SOSGoToPayOil_H5_URL					SOS_DEV ? @"https://test-open.czb365.com/redirection/todo/?platformType=92650843 &platformCode=%@&gasId=%@&gunNo=%@" : @"https://open.czb365.com/redirection/todo?platformType=92650843&platformCode=%@&gasId=%@&gunNo=%@"
