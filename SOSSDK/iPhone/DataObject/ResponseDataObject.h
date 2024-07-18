//
//  ResponseDataObject.h
//  Onstar
//
//  Created by Joshua on 15/8/26.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//



@class SOSPOI;
#import "SOSQSModelProtol.h"

#pragma mark-common remote control response

@interface CommandResponse : NSObject
@property (nonatomic, copy) NSString *requestTime;
@property (nonatomic, copy) NSString *completionTime; //polling
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *body;
@end
#pragma mark-data refresh
@interface DiagnosticElement : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *unit;
@end

#pragma mark - 基础类

@interface NNErrorDetail : NSObject
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *msg;
@end

@interface ResponseStatus : NSObject
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *detail;
@end
@interface ResponseInfo : NSObject
@property (nonatomic,assign) BOOL desc;
@property (nonatomic, copy) NSString *code;
@end

@interface Broadcastlist : NSObject
@property (weak, nonatomic, readonly) NNErrorDetail *errorInfo;
@property (nonatomic, strong) NSArray *broadcastList;

@end

@interface BroadCastDataResponse : NSObject
@property (nonatomic, copy) NSString *broadcastListId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *modelNumber;
@property (nonatomic, copy) NSString *publishTime;
@property (nonatomic, copy) NSString *content;
@end

@interface BroadcastDetail : NSObject
@property (nonatomic, copy) NSString *broadcastDetailId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *model;
@property (nonatomic, copy) NSString *publishTimestamp;
@property (nonatomic, copy) NSString *expireTimestamp;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *contentUrl;
@property (nonatomic, copy) NSString *osType;
@property (nonatomic, assign) NSInteger readStatus;
@property (weak, nonatomic, readonly) NNErrorDetail *errorInfo;
@end
#pragma mark-INFO3 TCPS
@interface TCPSResponseItem : NSObject
@property (nonatomic, copy) NSString *acceptanceDateTime;
@property (nonatomic, copy) NSString *accepted;
@property (nonatomic, copy) NSString *acknowledged;
@property (nonatomic, copy) NSString *acknowledgedDateTime;
@property (nonatomic, copy) NSString *acknowledgedName;
@property (nonatomic, copy) NSString *acknowledgedReason;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *critical;
@property (nonatomic, copy) NSString *daysToAct;
@property (nonatomic, copy) NSString *docTitle;
@property (nonatomic, copy) NSString *tcpsItemId;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *revision;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *url;

    @end

@interface TCPSResponse : NSObject
@property (nonatomic, strong) NSArray *tcps;
- (NSString *)getTCPSUrlAtIndex:(NSInteger)index;
    @end
//__deprecated_msg("使用SOSCheckAppVersionResponse")
@interface CheckInAppVersionResponse : NSObject
@property (nonatomic, assign) NSInteger appID;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *urlLocation;
@property (nonatomic, copy) NSString *appVersion;
@property (nonatomic, assign) BOOL isAvailable;
@property (nonatomic, assign) BOOL available;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *app_version_status;
@end
//MA92
@interface SOSCheckAppVersionResponse : NSObject
@property (nonatomic, assign) BOOL update;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *force;
@property (nonatomic, copy) NSString *alert;
@property (nonatomic, copy) NSString *markPoint;
@property (nonatomic, copy) NSString *alertImgUrl;
@property (nonatomic, copy) NSString *updateNote;
@property (nonatomic, copy) NSString *os;
@property (nonatomic, copy) NSString *marketUrl;
@property (nonatomic, copy) NSString *releaseDate;
-(BOOL)isMustUpgradeVersion;
-(BOOL)needAlertVersion;
@end

@interface NNPreferDealerDataResponse : NSObject
@property (nonatomic, copy) NSString *cityCode;
@property (nonatomic, copy) NSString *postcode;
@property (nonatomic, copy) NSString *companyName;
@property (nonatomic, copy) NSString *cityName;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *distance;
@property (nonatomic, copy) NSString *dealerCode;
@property (nonatomic, copy) NSString *telephone;
@property (nonatomic, copy) NSString *dealerName;
@property (nonatomic, copy) NSString *partyID;
@property (nonatomic, copy) NSString *province;
@property (assign, nonatomic) BOOL isPreferredDealer;
@property (weak, nonatomic, readonly) NNErrorDetail *errorInfo;
@end

@interface NNUpdatePreferDealer : NSObject
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *effectiveDateTime;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NNErrorDetail *errorinfo;
@end


@interface NNLandingPage : NSObject
@property (nonatomic, copy) NSString *lid;
@property (nonatomic, copy) NSString *startTime;
@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, copy) NSString *expireTime;
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, strong) NNErrorDetail *errorInfo;

@property (nonatomic, copy) NSString  *canShare;
@property (nonatomic, copy) NSString *thumbnailUrl;
@property (nonatomic, copy) NSString *url;
@property (copy, nonatomic) NSString *pageType;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *isTitle;

@end

@interface DiagnosticResponse : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray *diagnosticElement;
@end

//套餐
@interface PackageListResponse : NSObject
@property (nonatomic, copy) NSArray *packageArray;
@property (nonatomic, strong) NNErrorDetail *errorInfo;
@end

//套餐详情
@interface PackageInfos : NSObject
@property (nonatomic, copy) NSString *packageId;

@property (nonatomic, copy) NSString *productNumber;

@property (nonatomic, copy) NSString* packagePrice;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *actualPrice;
@property (nonatomic, copy) NSString *packageType;
/// Package Name - 显示名
@property (nonatomic, copy) NSString *packageName;
/// 折扣价
@property (nonatomic, copy) NSString *discountAmount;
@property (nonatomic, copy) NSString *discountId;
/// 折扣名称
@property (nonatomic, copy) NSString *discountName;          //

@property (nonatomic, copy) NSString *offerDesc;
@property (nonatomic, copy) NSString *expiryDate;

@property (nonatomic, copy) NSString *finalPrice;   //实际价

@property (nonatomic, copy) NSString *annualPrice;   		//折扣价

///开始时间
@property (nonatomic, copy) NSString *startDate;
///结束时间
@property (nonatomic, copy) NSString *endDate;
///订单购买时间
@property (nonatomic, copy) NSString *purchaseDate;
///订单持续时长
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, copy) NSString *durationUnit;
/// Package ID
@property (nonatomic, copy) NSString *offerId;
/// Package Name - EDM 用于买包
@property (nonatomic, copy) NSString *offerName;
///手机端tab名称
@property (nonatomic, copy) NSString *degreeDesc;
///记录package热度等级，即手机端tab页显示位置,取值：0,1,2
@property (nonatomic, copy) NSString *degreeCode;
@property (nonatomic, copy) NNErrorDetail *errorInfo;
///是否为早鸟包
@property (nonatomic, copy) NSNumber *isEBPackage;
///包的详情 URL
@property (nonatomic, copy) NSString *descUrl;
/** 是不是LBS套餐 */
@property (nonatomic, copy) NSString *isLBSPackage;


@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *placeholder;

@property (nonatomic, copy) NSString *deliveryAddr;
@property (nonatomic, copy) NSString *deliveryName;
@property (nonatomic, copy) NSString *deliveryPhone;
//@property (nonatomic, copy) NSString *description;
//@property (nonatomic, copy) NSNumber *remainingDay;        //暂无此字段
@end

@interface JsonError : NSObject
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *message;
@end


@interface NNPageable : NSObject
@property (nonatomic, copy) NSString * pageNumber;
@property (nonatomic, copy) NSString * totalSize;
@property (nonatomic, assign) BOOL  offset;
@property (nonatomic, copy) NSString * pageSize;
@end

@interface NNGetOrderHistoryResponse : NSObject
@property (nonatomic, strong) NNPageable *pageable;
@property (nonatomic, copy) NSArray  *orderList;
@property (nonatomic, strong) NNErrorDetail *errorInfo;
@end

@interface NNSubscriber : NSObject
@property (nonatomic, copy) NSString *subscriberID;
@property (nonatomic, copy) NSString *idpID;
@property (nonatomic, copy) NSString *guid;    //add v7.4 
@property (nonatomic, copy) NSString *governmentID;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *nickName;//add v8.0,昵称
@property (nonatomic, copy) NSString *idmPhoneNumber;//add v8.0,idm Mobile
@property (nonatomic, copy) NSString *role;
@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic, copy) NSString *defaultAccountID;
@property (nonatomic, copy) NSString *vin;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, assign) BOOL isEmptyPhoneNo;//add v7.1
@property (nonatomic, copy ) NSString * gaaPhoneNumber;//add v7.1
//@property (nonatomic,assign) BOOL appFlag;//add info3
@property (nonatomic,assign) BOOL legalFlag;//add info3
@property (nonatomic,assign) BOOL carSharingFlag;//add 7.3 是否支持车分享
@property (nonatomic, assign) BOOL expiredSubscriber;
//@property (nonatomic, assign) BOOL remindSetFlag;
//@property (nonatomic, assign) BOOL ubiFlag;
//@property (nonatomic, copy) NSString *ubiUrl;
@property (nonatomic, copy) NSString *licenseExpireDate;
//@property (nonatomic, copy) NSString *brand;
//TODO 7.3
@property (nonatomic, copy) NSString *accountNumber;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *address1;
@property (nonatomic, copy) NSString *address2;
@property (nonatomic, copy) NSString *zip;

@property (nonatomic, strong) NSArray* corePackages;

//8.2 我的 - 爱车小秘书 - 紧急联系人
///电话
@property (copy, nonatomic) NSString *ecMobile;
///姓
@property (copy, nonatomic) NSString *ecFirstName;
///名
@property (copy, nonatomic) NSString *ecLastName;
///是否显示紧急联系人
@property (assign, nonatomic) BOOL isEcInfoDisplay;

@end

@interface NNExtendedSubscriber : NNSubscriber
@property (nonatomic, copy) NSString *make;
@property (nonatomic, copy) NSString *model;
//9.0.1 basic_info接口替换为enroll/info后增加
@property (nonatomic, copy) NSString *accountID;
@property (nonatomic, copy) NSString *accountType;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *inputGovid;
@property (nonatomic, copy) NSString *insuranceCompany;
@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, copy) NSString *postcode;
@property (nonatomic, copy) NSString *preferDealerCode;
@property (nonatomic, copy) NSString *preferDealerName;
@property (nonatomic, copy) NSString *saleDealer;
@property (nonatomic, copy) NSString *saleDealerName;

//@property (nonatomic, copy) NSString *nickName;
@end

@interface NNAccount : NSObject
@property (nonatomic, copy) NSString *accountID;
@property (nonatomic, copy) NSString *idpID;
@property (nonatomic, strong) NSArray *vehicles;
@property (nonatomic, copy) NSString *role;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *defaultVin;
@end

@interface NNVehicles : NSObject
@property (nonatomic, copy) NSString *vin;
@property (nonatomic, copy) NSString *make;
@property (nonatomic, copy) NSString *model;
@property (nonatomic, copy) NSString *gen8;
@property (nonatomic, copy) NSString *gen10;

@end

@interface NNPackageinfo : NSObject
@property (nonatomic, copy) NSString *endDate;
@property (nonatomic, copy) NSString *startDate;
@property (nonatomic, copy) NSString* actualPrice;
@property (nonatomic, copy) NSString* packageOffer;
@property (nonatomic, copy) NSString *purchaseDate;
@property (nonatomic, copy) NSString *packageId;
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, copy) NSString * packagePrice;
@property (nonatomic, copy) NSString *packageName;
@end

@interface NNOrderInfo : NSObject
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *orderId;
@property (nonatomic, strong) NNPackageinfo *packageInfo;
@property (nonatomic, strong) NNExtendedSubscriber *subscriber;
@end

@interface NNPaymentparameters : NSObject

@end

//创建订单
@interface NNCreateOrderResponse : NSObject
@property (nonatomic, copy) NSString *status;
@property (nonatomic, strong) NNPaymentparameters *paymentParameters;
//@property (nonatomic, copy) NSString *orderId;
@property (nonatomic, strong) NNPackageinfo *packageInfo;
@property (nonatomic, strong) NNExtendedSubscriber *subscriber;
@property (nonatomic, strong) NNErrorDetail *errorInfo;

@property (nonatomic, copy) NSString *offeringName;
@property (nonatomic, copy) NSString *actualPrice;
@property (nonatomic, copy) NSString *buyOrderId;


@end

//EV
@interface NNChargingProfileRequest : NSObject
@property (nonatomic, copy) NSString *chargeMode;
@property (nonatomic, copy) NSString *rateType;
@end

@interface NNChargingProfile : NSObject
@property (nonatomic, strong) NNChargingProfileRequest *chargingProfile;
@end

@interface NNSchedule : NSObject
@property (nonatomic, copy) NSString *dayOfWeek;
@property (nonatomic, copy) NSString *departTime;
@end

@interface NNWeeklyCommuteSchedule : NSObject
@property (nonatomic, strong) NSArray *dailyCommuteSchedule;
@end

@interface NNCommuteSchedule : NSObject
@property (nonatomic, strong) NNWeeklyCommuteSchedule *weeklyCommuteSchedule;
@end

//content
@interface NNContentHeader : NSObject
@property (nonatomic, copy) NSString *contentId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *contentNUM;
@end

@interface NNContentHeaderCatogry : NSObject
@property (nonatomic, copy) NSString *category;
@property (nonatomic, strong) NSArray *contentHeaderList;
@end

@interface NNContent : NSObject
@property (nonatomic, strong) NNContentHeader *header;
@property (nonatomic, copy) NSString *contentUrl;
@end

@interface NNContentDeatil : NSObject
@property (nonatomic, copy) NSString *category;
@property (nonatomic, strong) NNContent *content;
@end

//banner
@interface NNBanner : NSObject<NSCopying, SOSQSModelProtol>
@property (nonatomic, strong) NSNumber *bannerID;
@property (nonatomic, copy) NSString *bannerNUM;
@property (nonatomic, copy) NSString *title;//下面对应的文字
@property (nonatomic, copy) NSString *imgUrl;//banner图片
@property (nonatomic, copy) NSString *contentUrl;
@property (nonatomic, copy) NSString *imgType;
@property (nonatomic, copy) NSString *updateTS;
@property (nonatomic, copy) NSString *expiredStartTS;
@property (nonatomic, copy) NSString *expiredEndTS;
@property (nonatomic, copy) NSString *showType; //1.App原生打开，3:webivew打开，4.浏览器打开
@property (nonatomic, copy) NSString *languagePreference;
@property (nonatomic, copy) NSString *openStatus;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *exposureMonitoringUrl;
@property (nonatomic, copy) NSString *clickMonitoringUrl;
@property (nonatomic, copy) NSString *isScaling; //后加的参数 ，缩放h5
@property (nonatomic, copy) NSString * isH5Title;//是否显示H5标题
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *paramData; //后台可配置，可为空，传给第三方用
@property (nonatomic, copy) NSString *partnerId;//第三方标识
@property (nonatomic, copy) NSString *functionId;//functionID
@property (nonatomic, copy) NSString *attributeData;//提交第三方url时, 需要在表单/json中包含的字段
@property (nonatomic, copy) NSString *httpMethod;//-- 提交第三方url使用的httpMethod,默认“GET”
@property (nonatomic, copy) NSString *contentType;//-- 提交第三方url时使用的数据格式: 目前只支持json
@property (nonatomic, copy) NSString *callFuncNm;//-- 当showType为1(App内部打开)时, 客户端onclick事件调用的方法名
@property (nonatomic, copy) NSString *category;//--用于车主生活中做分类：CAR_MANAGER,LIFE_MANAGER,HOT_PROMOTION
@property (nonatomic, assign) BOOL canSharing;//--是否允许分享
@property (nonatomic, copy) NSString * thumbnailsUrl;//分享图标url
@end


//@interface NNBannerList : NSObject
//@property (nonatomic, strong) NSArray *bannerList;
//@end

@interface NNCarOwnerLiving : NSObject
@property (nonatomic, strong) NSArray *CAR_MANAGER;
@property (nonatomic, strong) NSArray *LIFE_MANAGER;
@property (nonatomic, strong) NSArray *HOT_PROMOTION;
@end

//ovd email
@interface NNContentHeaderList : NSObject
@property (nonatomic, copy) NSString *cid;
@property (nonatomic, copy) NSString *title;
@end

@interface NNOVDList : NSObject
@property (nonatomic, strong) NSArray *contentHeaderList;
@end

@interface NNOVDStatus : NSObject
@property (nonatomic, strong) NSNumber *status;
@property (nonatomic, copy) NSString *descrip;
@end

@interface NNOvdStatusInfo : NSObject
@property (nonatomic,strong) NNOVDStatus *engineTransmission;
@property (nonatomic,strong) NNOVDStatus *drainage;
@property (nonatomic,strong) NNOVDStatus *airBag;
@property (nonatomic,strong) NNOVDStatus *stabiliTrak;
@property (nonatomic,strong) NNOVDStatus *abs;
@property (nonatomic,strong) NNOVDStatus *onStar;
@property (nonatomic,strong) NNOVDStatus *lithiumBattery;
@property (nonatomic,strong) NNOVDStatus *dynamoelectricBrake;
@property (nonatomic,strong) NNOVDStatus *electricDrive;
@end


@interface NNvehicleMaintenance : NSObject
@property (nonatomic, strong) NSNumber *engineOilHealth;
@property (nonatomic, strong) NSNumber *odometer;
@end


@interface NNIndividualTirePressure : NSObject
@property (nonatomic, copy) NSString *frontLeftIcon;
@property (nonatomic, strong) NSNumber *frontLeftPressure;
@property (nonatomic, strong) NSNumber *frontLeftStatus;
@property (nonatomic, copy) NSString *frontRightIcon;
@property (nonatomic, strong) NSNumber *frontRightPressure;
@property (nonatomic, strong) NSNumber *frontRightStatus;
@property (nonatomic, copy) NSString *rearLeftIcon;
@property (nonatomic, strong) NSNumber *rearLeftPressure;
@property (nonatomic, strong) NSNumber *rearLeftStatus;
@property (nonatomic, copy) NSString *rearRightIcon;
@property (nonatomic, strong) NSNumber *rearRightPressure;
@property (nonatomic, strong) NSNumber *rearRightStatus;
@end

@interface NNTirePressure : NSObject
@property (nonatomic, strong) NSNumber *frontPlacard;
@property (nonatomic, strong) NSNumber *rearPlacard;
@property (nonatomic, strong) NNIndividualTirePressure *individualTirePressure;
@end

@interface NNOvdMaintenanceInfo : NSObject
@property (nonatomic, strong) NNvehicleMaintenance *vehicleMaintenance;
@property (nonatomic, strong) NNTirePressure *tirePressure;
@end


@interface NNVehicleProfile : NSObject
@property (nonatomic, copy) NSString *vehicleImage;
@property (nonatomic, copy) NSString *vehicleMakeUrl;
@end

@interface NNOVDEmail : NSObject
@property (nonatomic, strong) NNOvdStatusInfo *ovdStatusInfo;
@property (nonatomic, strong) NNOvdMaintenanceInfo *ovdMaintenanceInfo;
@property (nonatomic, strong) NNVehicleProfile *vehicleProfile;
@end

@interface NNOVDEmailDTO : NSObject
@property (nonatomic, strong) NNOVDEmail *ovdEmailDTO;

@end

//geo fencing

@interface NNCenterPoiCoordinate : NSObject
@property (nonatomic, copy) NSString *longi;
@property (nonatomic, copy) NSString *lati;
+ (NNCenterPoiCoordinate *)coordinateWithLongitude:(NSString *)lon AndLatitude:(NSString *)lat;
@end

@interface NNVehicle : NSObject
@property (nonatomic, copy) NSString *vin;
@property (nonatomic, copy) NSString *make;
@property (nonatomic, copy) NSString *model;
@property (nonatomic, assign) BOOL d2jbi;
@property (nonatomic, copy) NSString *manufacturerName;
@property (nonatomic, copy) NSString *stationID;
@property (nonatomic, copy) NSString *makeDesc;
@property (nonatomic, copy) NSString *modelDesc;
@property (nonatomic, copy) NSString *manufacturerDesc;
@property (nonatomic, copy) NSString *year;
@property (nonatomic, copy) NSString *accountID;
@property (nonatomic, strong) NSArray *serviceEntitlement;
@property (nonatomic, strong) NSArray *vehicleUnitFeatures;
@property (nonatomic, strong) NSArray *supportedVehicleElements;
@property (nonatomic, assign) BOOL gen8;
///暂时只用于判断是否显示 实名认证 入口
@property (nonatomic, assign) BOOL gen9;
@property (nonatomic, assign) BOOL gen10;
@property (nonatomic, assign) BOOL icm;         //7.4增加新车型ICM
@property (nonatomic, assign) BOOL superCruise; //7.4增加新车型超级克鲁兹
@property (nonatomic, assign) BOOL info3;//info3增加，判断该车是否是info3车
@property (nonatomic, assign) BOOL bbwc;
@property (nonatomic, weak, readonly) NSString *makeModel;
@property (nonatomic, assign) BOOL fmvOpt;
@property (nonatomic, assign) BOOL remoteControlOpt;
@property (nonatomic, assign) BOOL supportEvaluate;
@property (nonatomic, assign) BOOL phev;
@property (nonatomic, assign) BOOL info34;

@property (nonatomic, copy) NSString *brand;//by lmd 8.0


/**
 12月26日修改,该字段包含如下值：
 Gen8
 Gen9
 Gen10
 Info3
 Info34
 以后后台都用这个字段来传车类型
 */
@property (copy, nonatomic) NSString *vehicleBaseType;
@end

@interface NNServiceEntitlement : NSObject
@property (nonatomic, copy) NSString *objectID;
@property (nonatomic, copy) NSString *entitledIndicator;
@end

@interface NNVehicleFeature : NSObject
@property (nonatomic, copy) NSString *featureName;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *valueType;
@property (nonatomic, copy) NSString *featureSettings;
@end

@interface NNSupportedDiagnostics : NSObject
@property (nonatomic, strong) NSArray *supportedDiagnostic;
@end

@interface NNCommandData : NSObject
@property (nonatomic, strong) NNSupportedDiagnostics *supportedDiagnostics;
@end

@interface NNCommand : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) NNCommandData *commandData;
@end

@interface NNCommands : NSObject
@property (nonatomic, strong) NSArray *command;
@end

@interface NNSupportedCommands : NSObject
@property (nonatomic, strong) NNCommands *commands;
@end

/// 电子围栏
@interface NNGeoFence : NSObject <NSCopying>
@property (nonatomic, copy) NSString *geoFencingID;
@property (nonatomic, copy) NSString *vin;
@property (nonatomic, copy) NSString *centerPoiName;
@property (nonatomic, copy) NSString *centerPoiAddress;
/// 电话 (LBS 模式时,使用 Mobile 字段)
@property (nonatomic, copy) NSString *mobilePhone;
/// 围栏半径(km)
@property (nonatomic, copy) NSString *range;
/// 围栏半径单位,仅用于智能家居围栏
@property (nonatomic, copy) NSString *rangeUnit;
@property (nonatomic, copy) NSString *geoFencingName;

/// 围栏状态 (0,1)
@property (nonatomic, copy) NSString *geoFencingStatus;
@property (nonatomic, copy) NSString *acctNum;
@property (nonatomic, copy) NSString *vehMake;
@property (nonatomic, copy) NSString *vehModel;
@property (nonatomic, strong) NNVehicle *vehicle;
/// 围栏提醒方式 IN / OUT
@property (nonatomic, copy) NSString *alertType;
@property (nonatomic, copy) NSString *expiredDate;
@property (nonatomic, strong) NNCenterPoiCoordinate *centerPoiCoordinate;
/// 围栏操作方式 (ADD / UPDATE) 9.2 版本交互去除 DELETE 操作,围栏不可删除
@property (nonatomic, copy) NSString *operationType;
/// 智能家居添加
@property (nonatomic, copy) NSString *geoFencingDescription;

/// 是否为新建围栏, 设置该值时会连带改变 operationType
@property (nonatomic, assign) BOOL isNewToAdd;
/// 是否为编辑模式
@property (nonatomic, assign) BOOL isEditStatus;
/// 是否是 LBS 围栏
@property (nonatomic, assign) BOOL isLBSMode;

///

- (BOOL)isOpen;

- (NSString *)getGeoMobile;

@end

/// LBS 电子围栏
@interface NNLBSGeoFence : NNGeoFence


/// 电子围栏 ID
@property (nonatomic, copy) NSString *Id;
/// LBS 设备 ID
@property (nonatomic, copy) NSString *deviceId;
/// LBS 设备 ID
@property (nonatomic, copy) NSString *LBSDeviceName;
/// 围栏名称
@property (nonatomic, copy) NSString *name;
/// 围栏描述
//@property (nonatomic, copy) NSString *description;
/// 语言 -- ZH_CN
@property (nonatomic, copy) NSString *languageCode;
/// 用户 idpuserId
@property (nonatomic, copy) NSString *idpuserId;
/// 纬度
@property (nonatomic, copy) NSString *latitude;
/// 经度
@property (nonatomic, copy) NSString *longitude;
/// 半径
//@property (nonatomic, copy) NSString *range;
/// 围栏状态: ON / OFF
@property (nonatomic, copy) NSString *fenceStatus;
/// 提醒类型: IN / OUT
//@property (nonatomic, copy) NSString *alertType;
/// 提醒手机号
@property (nonatomic, copy) NSString *mobile;
/// 用户 VIN 号
//@property (nonatomic, copy) NSString *vin;
/// 用户 subscriber id
@property (nonatomic, copy) NSString *subscriber_id;
/// 过期日期, 非必传
//@property (nonatomic, copy) NSString *expiredDate;
/// 验证 修改手机号 token
@property (nonatomic, copy) NSString *verifyFlagtoken;

@end

@interface NNGeoFenceList : NSObject
@property (nonatomic, strong) NSArray *geoFenceList;
@end

@interface NNError :NSObject
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *code;
@end


@interface NNErrorInfo : NSObject
@property (nonatomic, strong) NNError *error;
@end

@interface NNGetPackageListResponse : NSObject
@property (nonatomic, copy) NSString *totalRemainingDay;
@property (nonatomic, strong) NSArray *packageList;
@property (nonatomic, strong) NNError *errorInfo;
@end
//支付渠道列表
@interface channelList : NSObject
@property (nonatomic,strong)NSArray *channels;
@end

@interface NNPackagelistarray : NSObject
@property (nonatomic, copy) NSString *packageId;
//@property (nonatomic, assign) NSInteger packagePrice;
//@property (nonatomic, copy) NSString *desc;
//@property (nonatomic, assign) NSInteger actualPrice;
@property (nonatomic, copy) NSString *packageType;
@property (nonatomic, copy) NSString *packageName;
//@property (nonatomic, assign) NSInteger packageOffer;
//@property (nonatomic, copy) NSString *packageOfferName;
@property (nonatomic, copy) NSString *endDate;
//@property (nonatomic, copy) NSString *discountId;
//@property (nonatomic, copy) NSString *offerDesc;
@property (nonatomic, copy) NSString *expiryDate;
@property (nonatomic, copy) NSString *startDate;
@property (nonatomic, copy) NSString *duration;
//@property (nonatomic, copy) NSString *packageOfferId;
@property (nonatomic, copy) NSString *basePackage;
@property (nonatomic, copy) NSString *remainingDay;
@property (nonatomic, copy) NSString *active;
@property (nonatomic, copy) NSString *totalUsage;
@property (nonatomic, copy) NSString *totalUsageUnit;
@property (nonatomic, copy) NSString *startDateTime;
@property (nonatomic, copy) NSString *expiredDateTime;
@property (nonatomic, copy) NSString *usedUsage;
@property (nonatomic, copy) NSString *packageCode;
@property (nonatomic, copy) NSString *packageDesc;
@property (nonatomic, copy) NSString *remainUsage;
@property (nonatomic, copy) NSString *remainUsageUnit;
@end
//4G
@interface NNGetDataListResponse : NSObject
@property (nonatomic, copy) NSString *currentRemainUsage;
@property (nonatomic, copy) NSString *currRemainUsageUnit;
@property (nonatomic, copy) NSString *totalRemainUsageUnit;
@property (nonatomic, copy) NSString *totalRemainUsage;
@property (nonatomic, copy) NSArray *packageUsageInfos;
@property (nonatomic, strong) NNError *errorInfo;
@end

@interface NNSaveDeviceInfoResponse : NSObject
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, copy) NSString *code;
@end


@interface NNSaveSessionResponse : NSObject
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, copy) NSString *code;
@end


//feedback
@interface NNFeedbackInfo : NSObject
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *code;
@end


@interface NNGetWapPayUrlResponse : NSObject
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, copy) NSString *wapUrl;
@property (nonatomic, copy) NSString *callBackUrl;
@property (nonatomic, strong) NNErrorDetail *errorInfo;
@end


@interface NNQueryOrderStatusResponse : NSObject
@property (nonatomic, copy) NSString *orderId;
@property (nonatomic, copy) NSString *status;
@property (weak, nonatomic, readonly) NNErrorDetail *errorInfo;
@end

@interface NNGetVehicleListResponse : NSObject
@property (nonatomic, strong) NSArray *vehicles;
@end

@interface NNDealers : NSObject
///是否为首选经销商
@property (nonatomic, strong) NSNumber *isPreferredDealer;
@property (nonatomic ,copy) NSString *dealersid;
//@property (nonatomic, strong) NNCenterPoiCoordinate *directionCoordinate;
@property (nonatomic, strong) NNCenterPoiCoordinate *locationCoordinate;
//@property (nonatomic, copy) NSString *cityName;
//@property (nonatomic, copy) NSString *postcode;
//@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *dealerName;
//@property (nonatomic, strong) NNCenterPoiCoordinate *currentLocation;
@property (nonatomic, copy) NSString *cityCode;
//@property (nonatomic, copy) NSString *dealerBrand;
@property (nonatomic, copy) NSString *address;
//@property (nonatomic, copy) NSString *companyName;
@property (nonatomic, copy) NSString *dealerCode;
//后台返回带单位KM/M,修改数据类型
@property (nonatomic, assign) float distance;
@property (nonatomic, copy) NSString *distanceWithUnit;

/// 新增品牌字段 BUICK("1"), CADILLAC("2"), CHEVROLET("3")
@property (nonatomic, copy) NSString *brandCode;


@property (nonatomic, copy) NSString *telephone;
//预约经销商 后加的
@property (nonatomic, copy) NSString *serviceName;
@property (nonatomic, copy) NSString *openId;
@property (nonatomic, copy) NSString *storeSt;
@property (nonatomic, copy) NSString *serviceTel;
@property (nonatomic, copy) NSString *dealerSt;
@property (nonatomic, copy) NSString *serviceAddress;
@property (nonatomic, copy) NSString *serviceLat;
@property (nonatomic, copy) NSString *serviceLng;
@property (nonatomic, copy) NSString *ascSt;
@property (nonatomic, copy) NSString *saleTel;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *serviceCode;

@property (strong, nonatomic, readonly) SOSPOI *poi;
/// 是否为推荐经销商
@property (nonatomic, assign) BOOL isRecommendDealer;
@end


@interface NNAroundDealerResponse : NSObject
@property (nonatomic, copy) NSArray *dealers;
//@property (nonatomic, copy) NSString *cityCode;
@property (nonatomic, strong) NNPageable *pageable;
@property (nonatomic, strong) NNErrorDetail *errorInfo;
@end

//register
@interface NNMessage : NSObject
@property (nonatomic, retain) NSString *messageCode;
@property (nonatomic, retain) NSString *messageDetail;
@end

@interface NNRegisterResponse : NSObject
@property (nonatomic, copy) NSString *emailAddress;
@property (nonatomic, copy) NSString *mobilePhoneNumber;
@property (nonatomic, copy) NSString *isEmailUnique;
@property (nonatomic, copy) NSString *isMobileUnique;
@property (nonatomic, copy) NSString *isNickNameUnique;
@property (nonatomic, copy) NSString *isUserNameUnique;
@property (nonatomic, strong) NNErrorDetail *errorInfo;
@property (nonatomic, strong) NNMessage *message;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *bbwcMessage;
@property (nonatomic, copy) NSString *secCode;
@property (nonatomic, copy) NSString *captchaId;
@property (nonatomic, copy) NSString *captchaValue;
@end


@interface NNGetActivateHistoryResponse : NSObject
@property (nonatomic, strong) NNPageable *pageable;
@property (nonatomic, strong) NSArray *orderList;
@property (nonatomic, strong) NNErrorDetail *errorInfo;
@end

@interface NNOrderList : NSObject
@property (nonatomic, copy) NSString *cardNo;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *orderId;
@property (nonatomic, strong) NNAccount *accountInfo;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, strong) NNExtendedSubscriber *subscriberInfo;
@property (nonatomic, copy) NSString *vehicleId;
@property (nonatomic, copy) NSString *activateDate;
@property (nonatomic, strong) PackageInfos *packageInfo;
@end


@interface NNActivatePPCResponse : NSObject
@property (nonatomic, copy) NSString *status;
@property (nonatomic, strong) PackageInfos *packageInfo;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, strong) NNExtendedSubscriber *subscriberInfo;
@property (nonatomic, strong) NNExtendedSubscriber *accountInfo;
@property (nonatomic, strong) NNErrorDetail *errorInfo;
@end

@interface NNDealersList : NSObject
@property (nonatomic, copy) NSArray *dealers;
@property (nonatomic, strong) NNPageable *pageable;
@end

@interface NNOrdersList : NSObject
@property (nonatomic, copy) NSArray *orders;
@property (nonatomic, strong) NNPageable *pageable;
@end

@interface NNOrders : NSObject
@property (nonatomic, copy) NSString *regTime;
@property (nonatomic, copy) NSString *preStatus;
@property (nonatomic, copy) NSString *stationName;
@property (nonatomic, copy) NSString *lineName;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *preType;
@end

@interface NNHeadPhotoResponse : NSObject
@property (nonatomic, copy) NSString *idpID;
@property (nonatomic, copy) NSString *fullUrl;
@end

@class SOSPOI;

@interface GetDestinationResponse : NSObject  ///property count  12

@property (nonatomic, copy) NSString *favoriteDestinationID;
@property (nonatomic, copy) NSString *idpID;
@property (nonatomic, copy) NSString *poiNickname;
@property (nonatomic, copy) NSString *poiName;
@property (nonatomic, copy) NSString *poiAddress;
@property (nonatomic, copy) NSString *poiPhoneNumber;
@property (nonatomic, copy) NSString *poiCatetory;
///"1"-家,"2"-公司
@property (nonatomic, copy) NSString *customCatetory;
@property (nonatomic, strong) NNCenterPoiCoordinate *poiCoordinate;
@property (nonatomic, strong) NNCenterPoiCoordinate *mobileCoordinate;
@property (nonatomic, copy) NSString *cityCode;
@property (nonatomic, copy) NSString *provience;

@property (nonatomic, strong, readonly) SOSPOI *poi;

@end


@interface NNProfiles : NSObject
@property (nonatomic, copy) NSString *wind_speed;
@property (nonatomic, copy) NSString *eco;
@property (nonatomic, copy) NSString *mode;
@property (nonatomic, copy) NSString *temperature;
@property (nonatomic, copy) NSString *tempIn;
@end

@interface NNMachinelistArray : NSObject
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, strong) NNProfiles *profiles;
@property (nonatomic, strong) NNGeoFence *geoFencing;
@property (nonatomic, copy) NSString *vin;
@property (nonatomic, copy) NSString *accountID;
@property (nonatomic, copy) NSString *deviceType;
@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, copy) NSString *platform;
@property (nonatomic, copy) NSString *idpID;
@property (nonatomic, assign) NSInteger switchStatus;
@property (nonatomic, copy) NSString *geoFencingStatus;
@end

@interface NNgeofencing : NSObject
@property (nonatomic, strong) NSArray *geofencings;
@end

//我的特惠
@interface NNMyPreferentialModel : NSObject
@property (nonatomic, copy) NSString *title;//特惠标题
@property (nonatomic, copy) NSString *url;//特惠跳转路径
@property (nonatomic, copy) NSString *imgUrl;//显示的图片地址
@property (nonatomic, copy) NSString *category;//分类：常用入口、热门活动
@property (nonatomic, assign) BOOL defaultDataFlg;//默认数据
@property (nonatomic, copy) NSString *paramData;
@end

@interface NNVehicleInfoModel : NSObject
@property (nonatomic, copy) NSString *accountID;
@property (nonatomic, copy) NSString *vin;
@property (nonatomic, copy) NSString *engineNumber;//发动机编号
@property (nonatomic, copy) NSString *licensePlate;//车牌
@property (nonatomic, copy) NSString *insuranceComp;//保险公司
@property (nonatomic, copy) NSString *compulsoryInsuranceExpireDate;//交强险到期日
@property (nonatomic, copy) NSString *businessInsuranceExpireDate;//商业险到期日
@property (nonatomic, copy) NSString *drivingLicenseDate;//行驶证日期
@end

@interface NNGetSmartHomedeviceList : NSObject
@property (nonatomic, strong) NSArray *devices;
@end

@interface NNEsarray : NSObject
@property (nonatomic, copy) NSString *accountID;
@property (nonatomic, copy) NSString *optStatus;
@property (nonatomic, copy) NSString *vin;
@property (nonatomic, copy) NSString *serviceName;
@end


@interface NNSmartHomeStatus : NSObject
@property (nonatomic, strong) NSArray *esArray;
@end

@interface NNToken : NSObject
@property (nonatomic ,copy) NSString *accessToken;
@property (nonatomic ,copy) NSString *refreshToken;
@property (nonatomic ,copy) NSString *expireTime;
@end

@interface  NNDispatcherRep : NSObject
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *jsonStr;
@end

@interface NNNotifyConfig : NSObject
@property (nonatomic, copy) NSString *btype;
@property (nonatomic, copy) NSString *subscriber_id;
@property (nonatomic, copy) NSString *vin;
@property (nonatomic, copy) NSString *sms_checked;
@property (nonatomic, copy) NSString *mail_checked;
@property (nonatomic, copy) NSString *wechat_checked;
@property (nonatomic, copy) NSString *mobile_checked;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *mail;
@property (nonatomic, copy) NSString *oldphone;
@property (nonatomic, copy) NSString *iscall;
@end

@interface NNwechainLogin : NSObject
@property (nonatomic, assign) BOOL mobileLogin;
@property (nonatomic, assign) BOOL wechatLogin;
@end


@interface NNserviceObject : NSObject
@property (nonatomic, copy) NSString *accountID;
@property (nonatomic, assign) BOOL optStatus;
@property (nonatomic, copy) NSString *vin;
@property (nonatomic, copy) NSString *serviceName;
@property (nonatomic, assign) BOOL availability;
@property (nonatomic, copy) NSString *idpID;
@end
#pragma mark - 8.2 登录
/**登录第一步token返回**/
@interface SOSUserTokenInfo : NSObject
@property (nonatomic, copy) NSString *country_code;
@property (nonatomic, copy) NSString *account_no;
//@property (nonatomic, copy) NSString *idpUserId;//由上层结构(NNOAuthLoginResponse)赋值
//@property (nonatomic, copy) NSString *nickName;//由上层结构(NNOAuthLoginResponse)赋值
@end

@interface NNOAuthLoginResponse : NSObject
@property (nonatomic, copy) NSString *access_token;
@property (nonatomic, copy) NSString *token_type;
@property (nonatomic, copy) NSString *expires_in;
@property (nonatomic, copy) NSString *scope;
@property (nonatomic, strong) SOSUserTokenInfo *onstar_account_info;//携带了一部分用户信息
@property (nonatomic, copy) NSString *idpUserId;//idm用户唯一标识
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *id_token;//idm令牌
@end
/****/
/**登录第二步登录第二步获取用户基本信息**/
//@interface SOSuserBasicDTO : NSObject
//@property (nonatomic, copy) NSString *idpUserId;   //idm用户唯一标识
//@property (nonatomic, copy) NSString *subscriberId;//GAA用户唯一标识
//@property (nonatomic, copy) NSString *defaultVin;  //默认登录vin
//@property (nonatomic, copy) NSString *accountNumber;//默认账号number
//@property (nonatomic, assign) BOOL    isFirstLogin;//是否首次登录
//@property (nonatomic, copy) NSString *avatarUrl;   //头像地址
//@end
@interface NNUerBasicInfo : NSObject
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, strong) SOSUserTokenInfo *data;
@end
/****/
/**登录第三步获取车支持服务，即之前serviceEntitlement(当前套餐包支持的服务)**/
@interface SOSVehiclePrivilege : NSObject
@property (nonatomic, assign) BOOL vehicleLocation;
@property (nonatomic, assign) BOOL geoFence;
@property (nonatomic, assign) BOOL dataRefresh;
@property (nonatomic, assign) BOOL remoteStart;
@property (nonatomic, assign) BOOL lock;
@property (nonatomic, assign) BOOL vehicleAlert;
@property (nonatomic, assign) BOOL unLock;
@property (nonatomic, assign) BOOL odd;
@property (nonatomic, assign) BOOL ovdReport;
@property (nonatomic, assign) BOOL tbt;

@property (nonatomic, assign) BOOL remoteHVAC;
@property (nonatomic, assign) BOOL sunroofControl;
@property (nonatomic, assign) BOOL windowsControl;
@property (nonatomic, assign) BOOL trunkOpen;
/**
 远程控制任一功能未true，则代表可执行remoteControl
 @return
 */
- (BOOL)hasVehicleServiceAviliable;
@end

@interface SOSVehicleAndPackageEntitlement : NSObject
@property (nonatomic, assign)BOOL hasAvaliablePackage;
@property (nonatomic, strong)SOSVehiclePrivilege *map;
@end
/****/
@interface NNservicesOpt : NSObject
@property (nonatomic, strong) NSArray <NNserviceObject *>*servicesList;
@end


#pragma mark - 8.0 注册
//省份Or城市信息
@interface NNProvinceInfoObject : NSObject
@property (nonatomic, copy) NSString *locale;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *createDate;
@property (nonatomic, copy) NSString *lastUpdateDate;
@property (nonatomic, copy) NSString *deleteFlag;
@property (nonatomic, copy) NSString *name;
@end
//获取到城市列表
@interface NNProvincesObject : NSObject
@property (nonatomic, strong) NSArray *provinceList;
@end

//检测govid是否有对应subscriber
@interface NNCheckAccountObject : NSObject
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, assign) BOOL hasSubscriber;
@property (nonatomic, copy) NSString *code;
@end
//bbwc 问题
@interface NNBBWCQuestion : NSObject
@property (nonatomic, copy) NSString *questionID;
@property (nonatomic, copy) NSString *answer;
@property (nonatomic, copy) NSString *title;
@end

#pragma mark -end
//
@interface NNCarReportResp : NSObject
@property (nonatomic, copy) NSString *linkUrl;
@property (nonatomic, copy) NSString *score;
@property (nonatomic, copy) NSString *rankMsg;
@property (nonatomic, copy) NSString *scoreName;
@property (nonatomic, copy) NSString *mockFlag;
@end

//获取油耗排名
@interface NNOilRankResp : NSObject
@property (nonatomic, copy) NSString *linkUrl;
@property (nonatomic, assign) BOOL recentUseFlag;//近期是否驾驶
@property (nonatomic, copy) NSString *rankMsg;
@property (nonatomic, copy) NSString *mockFlag;
@property (nonatomic, copy) NSString *fuelRatio;

@end

//获取综合能耗排名
@interface NNEngrgyRankResp : NSObject
@property (nonatomic, copy) NSString *linkUrl;
/// 排名
@property (nonatomic, copy) NSString *costRatioRank;
@property (nonatomic, assign) BOOL recentUseFlag;//近期是否驾驶
@property (nonatomic, copy) NSString *rankMsgTitle;
@property (nonatomic, copy) NSString *rankMsg;
@property (nonatomic, copy) NSString *mockFlag;
/// 百公里消耗
@property (nonatomic, copy) NSString *costRatio;
@end

//获取驾驶行为评分
@interface NNDrivingScoreResp : NSObject
@property (nonatomic, copy) NSString *linkUrl;
@property (nonatomic, assign) BOOL recentUseFlag;//近期是否驾驶
@property (nonatomic, copy) NSString *score;
@property (nonatomic, copy) NSString *scoreName;
@property (nonatomic, copy) NSString *mockFlag;
@end

// 近期行程返回
@interface SOSTrailResp : NSObject
@property (nonatomic, copy) NSString *linkUrl;
@property (nonatomic, assign) BOOL recentUseFlag;//近期是否驾驶
@property (nonatomic, copy) NSString *mockFlag;
@property (nonatomic, copy) NSDictionary *data;
@end

//获取手账信息
@interface NNVehicleCashResp : NSObject
@property (nonatomic, copy) NSString *multiMonthStatistics;//当月
@property (nonatomic, copy) NSString *monthStatistics;     //年度
@property (nonatomic, assign) BOOL demo;     

-(instancetype)initWithMonthStatistics:(NSString *)ms yearStatistics:(NSString *)ys;
@end

@interface NNStarTravelStageInfo :NSObject
@property (nonatomic, copy) NSString *stageId;
@property (nonatomic, copy) NSString *stageName;
@property (nonatomic, copy) NSString *stageCode;
@property (nonatomic, copy) NSString *isCompleted;
@property (nonatomic, copy) NSString *isCurrent;
@property (nonatomic, copy) NSString *progress;
@property (nonatomic, copy) NSString *orderNum;
@property (nonatomic, copy) NSString *comments;
@property (nonatomic, copy) NSString *formatComments;
@property (nonatomic, copy) NSString *bannerUrl;
@property (nonatomic, copy) NSString *startDate;
@property (nonatomic, copy) NSString *endDate;
@property (nonatomic, assign) NSInteger startDateTime;
@property (nonatomic, assign) NSInteger endDateTime;
@property (nonatomic, copy) NSString *userGroups;
@end

//星旅程
@interface NNStarTravelResp: NSObject
@property (nonatomic, copy) NSString *idpUserId;
@property (nonatomic, copy) NSString *vin;
@property (nonatomic, copy) NSString *subscriberId;
@property (nonatomic, copy) NSString *serviceDays;
@property (nonatomic, strong) NNStarTravelStageInfo *currentStageInfo;
@end


@interface NNBBWCResponse : NNFeedbackInfo
@property (nonatomic, copy) NSString *vehicleType;
@end
@interface NNBBWCQuestionList : NSObject
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, strong) NSArray *questions;
@end

@interface NNLBSDadaInfo: NSObject	<NSCopying>

///主键(为空时为新建，不为空时更新删除)
@property (nonatomic, strong) NSNumber *ID;
///创建时间(新增时为系统时间，更新删除时为以存储时间)
@property (nonatomic, copy) NSString *createts;
///逻辑删除标识位（新增更新时为1，删除时为0）
@property (nonatomic, copy) NSString *status;
///更新时间(系统时间)
@property (nonatomic, copy) NSString *updatets;
///设备唯一IMEI/ID号
@property (nonatomic, copy) NSString *deviceid;
///MD5加密后字符
@property (nonatomic, copy) NSString *password;
///自定义设备名称
@property (nonatomic, copy) NSString *devicename;
///设备类型(固定：LBS)
@property (nonatomic, copy) NSString *devicetype;
///设备平台(固定：gps902)
@property (nonatomic, copy) NSString *platform;
///amap(高德地图)
@property (nonatomic, copy) NSString *maptype;

- (void)setCreatesWithDate:(NSDate *)date;

@end



@interface NNLBSLocationPOI: NSObject

/// 第三方返回状态
@property (nonatomic, copy) NSString *state;
/// 设备定位时间
@property (nonatomic, copy) NSString *positionTime;
/// 纬度
@property (nonatomic, copy) NSString *lat;
/// 经度
@property (nonatomic, copy) NSString *lng;
/// 速度
@property (nonatomic, copy) NSString *speed;
/// 角度
@property (nonatomic, copy) NSString *course;
/// 是否停止
@property (nonatomic, copy) NSString *isStop;
/// 停留时间
@property (nonatomic, copy) NSString *stopMinute;
/// 行驶状态 (0:未启用,1:运动,2:静止,3:离线)
@property (nonatomic, copy) NSString *status;


// 以下属性用于 历史轨迹

///设备 IMEI
@property (nonatomic, copy) NSString *imei;

/// 设备定位时间
@property (nonatomic, copy) NSString *pt;
/// 速度
@property (nonatomic, copy) NSString *s;
/// 角度
@property (nonatomic, copy) NSString *c;
/// 是否停止,1停止,0运动
@property (nonatomic, copy) NSString *stop;
/// 停止分钟
@property (nonatomic, copy) NSString *stm;
/// 定位方式,0:LBS,1:GPS
@property (nonatomic, copy) NSString *g;

@end

//消息中心 addByWQ

@interface MessageModel:NSObject
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *categoryIcon;
@property (nonatomic, copy) NSString *categoryZh;
@property (nonatomic, copy) NSString *lastMsgTime;
@property (nonatomic, copy) NSString *lastMsgTitle;
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, assign) NSInteger count;

@end

@interface MessageCenterModel:NSObject
@property(nonatomic,strong)NSArray<MessageModel *> *notificationStatusList;
@end


@interface MessageCenterListModel:NSObject
@property(nonatomic,strong)NSArray *notifications;
@property (nonatomic, assign) NSInteger totalElements;
@property (nonatomic, assign) NSInteger totalPages;
@property (nonatomic, assign) NSInteger number;
@property (nonatomic, assign) NSInteger size;

@end

@interface NotifyOrActModel:NSObject
@property (nonatomic, copy) NSString *notificationId;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *sendDate;
@property (nonatomic, copy) NSString *sendDateTime;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *result;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSString *pictureAdress;
@property (nonatomic, assign)NSInteger pageNum;
@property (nonatomic, copy) NSString *secondCategory;
@property (nonatomic, copy) NSString *thirdCategory;
@end

@interface NearByDealerList:NSObject

@property(nonatomic,strong)NSArray *nearbyDealer;
@property(nonatomic,strong)NSArray *recommendDealer;


@end

@interface NearByDealerModel:NSObject
@property (nonatomic, copy) NSString *dealerId;
@property (nonatomic, copy) NSString *dealerName;
@property (nonatomic, copy) NSString *distanceWithUnit;
@property (nonatomic, copy) NSString *distance;
@property (nonatomic, copy) NSString *cityCode;
@property (nonatomic, copy) NSString *dealerCode;
@property (nonatomic, copy) NSString *telephone;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *longitude;
@property (nonatomic, copy) NSString *latitude;

@property (nonatomic, copy, readonly) SOSPOI *poi;

@end

@interface MirrorVehicleInfo:NSObject
@property (nonatomic, copy) NSString *imei;
@property (nonatomic, copy) NSString *vin;
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSString *vehicleLicense;
@property (nonatomic, copy) NSString *wifiStatus;
@property (nonatomic, copy) NSString *wifiSsid;
@property (nonatomic, copy) NSString *wifiPassword;
@property (nonatomic, copy) NSString *fmStatus;
@property (nonatomic, assign) CGFloat *fmBand;
/** 判断套餐类型 */
@property (nonatomic, copy) NSString *packages;
@end


@interface MirrorUserInfo:NSObject
@property (nonatomic, copy) NSString *rvmUserNickname;
@property (nonatomic, copy) NSString *rvmUserName;
@property (nonatomic, copy) NSString *rvmUserBirthday;
@property (nonatomic, copy) NSString *rvmUserGovId;
@property (nonatomic, copy) NSString *rvmUserPhone;


@end

@interface MirrorModel:NSObject
@property (nonatomic, retain) MirrorUserInfo *userInfo;
@property (nonatomic, strong) NSMutableArray<MirrorVehicleInfo*> *vehScreens;
@end


@interface MirrorCollectInfo:NSObject

@property (nonatomic, copy) NSString *cityCode;
@property (nonatomic, copy) NSString *poiAddress;
@property (nonatomic, copy) NSString *latitude;
@property (nonatomic, copy) NSString *longitude;
@property (nonatomic, copy) NSString *poiName;
@property (nonatomic, copy) NSString *poiNickname;
@property (nonatomic, copy) NSString *poiPhoneNumber;
@property (nonatomic, copy) NSString *provience;

@end


@interface MirrorSettingModel:NSObject

@property (nonatomic, copy) NSString *wifiPassword;
@property (nonatomic, copy) NSString *wifiSSID;
@property (nonatomic, assign) BOOL wifiStatus;
@property (nonatomic, copy) NSString *fmBand;
@property (nonatomic, assign) BOOL fmStatus;
@property (nonatomic, assign) BOOL wifiFlag;
@property (nonatomic, assign) BOOL FmFlag;
@end

@interface MirrorLocationModel:NSObject

@property (nonatomic, assign) BOOL isDefault;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, copy) NSString *poiAddress;
@property (nonatomic, copy) NSString *poiName;

@end

@interface MirrorPackageDetail : NSObject

@property (nonatomic, copy) NSString *expirationTime;
@property (nonatomic, copy) NSString *offeringCode;
@property (nonatomic, copy) NSString *offeringName;
@property (nonatomic, copy) NSString *startTime;
@property (nonatomic, copy) NSString *remainingData;
@property (nonatomic, copy) NSString *totalData;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *buyOrderId;
@end


@interface MirrorActivePackage : NSObject

@property (nonatomic, copy) NSString *buyOrderId;
@property (nonatomic, copy) NSString *packageName;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *remainingData;
@property (nonatomic, copy) NSString *totalData;
@property (nonatomic, retain) NSArray *offerings;
@property (nonatomic, copy) NSString *isOpen;

@end


@interface MirrorUnactivePackage : NSObject

@property (nonatomic, copy) NSString *buyOrderId;
@property (nonatomic, copy) NSString *packageName;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *remainingData;
@property (nonatomic, copy) NSString *totalData;
@property (nonatomic, retain) NSArray *offerings;
@property (nonatomic, copy) NSString *isOpen;

@end

@interface MirrorPackage : NSObject

@property(nonatomic,retain)NSArray *activePackages;
@property(nonatomic,retain)NSArray *inActivePackages;

@end


@interface MirrorCanBuyPackageDetail : NSObject

@property (nonatomic, copy) NSString *offeringCode;
@property (nonatomic, copy) NSString *offeringName;

@end


@interface MirrorDataPackage : NSObject    //基础套餐包

@property (nonatomic, copy) NSString *packageCode;
@property (nonatomic, copy) NSString *packageName;
@property (nonatomic, copy) NSString *packageType;
@property (nonatomic, copy) NSString *originalPrice;
@property (nonatomic, copy) NSString *discountPrice;
@property (nonatomic, retain) NSArray *offerings;
@property (nonatomic, copy) NSString *isOpen;

@end


@interface MirrorCorePackage : NSObject     //4G互联包

@property (nonatomic, copy) NSString *packageCode;
@property (nonatomic, copy) NSString *packageName;
@property (nonatomic, copy) NSString *packageType;
@property (nonatomic, copy) NSString *originalPrice;
@property (nonatomic, copy) NSString *discountPrice;
@property (nonatomic, retain) NSArray *offerings;
@property (nonatomic, copy) NSString *isOpen;

@end


@interface MirrorCanBuyPackage : NSObject

@property(nonatomic,retain)NSArray *dataPackages;
@property(nonatomic,retain)NSArray *corePackages;

@end

@interface MirrorRearviewOrdersModel : NSObject

@property (nonatomic, copy) NSString *buyOrderId;
@property (nonatomic, copy) NSString *buyTime;
@property (nonatomic, copy) NSString *packageName;
@property (nonatomic, copy) NSString *imei;
@property (nonatomic, copy) NSString *actualPrice;
@property (nonatomic, copy) NSString *originalPrice;

@end

@interface MirrorRearviewOrdersList : NSObject

@property (nonatomic, strong) NSArray<MirrorRearviewOrdersModel *> *orderList;
@end





////////////MA9:信息流设置
@interface SOSInfoFlowSetting: NSObject
@property (nonatomic, copy) NSString *belongType;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *switchContent;
@property (nonatomic, copy) NSString *switchTitle;
@end

/// 订单历史 单项
@interface SOSOrderHistoryModel : NSObject
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *orderType;
//@property (nonatomic, nullable, copy) id payTime;
//@property (nonatomic, nullable, copy) id transactionId;
@property (nonatomic, copy) NSString *payChannel;
@property (nonatomic, copy) NSString *buyChannel;
@property (nonatomic, copy) NSString *buyOrderId;
@property (nonatomic, copy) NSString *vin;
@property (nonatomic, copy) NSString *offeringName;
@property (nonatomic, copy) NSString *offeringId;
@property (nonatomic, assign) CGFloat actualPrice;
//@property (nonatomic, nullable, copy) id createUserid;
//@property (nonatomic, nullable, copy) id storeId;
//@property (nonatomic, nullable, copy) id dkfAccount;
//@property (nonatomic, nullable, copy) id payUserid;
@property (nonatomic, assign) CGFloat total;
@property (nonatomic, assign) NSInteger discount;
@property (nonatomic, assign) NSInteger duration;
@property (nonatomic, copy) NSString *durationUnit;
@property (nonatomic, copy) NSString *productNumber;
@property (nonatomic, copy) NSString *discountId;
//@property (nonatomic, nullable, copy) id buyerName;
@property (nonatomic, assign) NSInteger createDate;
//@property (nonatomic, nullable, copy) id lastUpdateDate;
@property (nonatomic, assign) NSInteger orderId;
//@property (nonatomic, nullable, copy) id protocolId;
@property (nonatomic, assign) NSInteger packageStartDate;
@property (nonatomic, assign) NSInteger  packageEndDate;
//@property (nonatomic, nullable, copy) id lcoalAddressId;
//@property (nonatomic, nullable, copy) id lpaId;
//@property (nonatomic, nullable, copy) id rownum;
@end

/// 订单历史返回结果
@interface SOSOrderHistoryListModel : NSObject
@property (nonatomic, strong) NSArray *result;
@property (nonatomic, assign) int currentPage;
@property (nonatomic, assign) int pageSize;
@property (nonatomic, assign) int totalPages;
@property (nonatomic, assign) int totalSize;
@property (nonatomic, assign) int offset;
//@property (nonatomic, assign) BOOL notPage;
@end

@interface SOSMSRespModel : NSObject
@property (nonatomic, copy) NSString *errorCode;
@property (nonatomic, copy) NSString *errorMessage;
@property (nonatomic, copy) id data;
@end

@interface SOSGetPackageServiceResponse : NSObject
@property (nonatomic, copy) NSString *currRemainingDays;
@property (nonatomic, copy) NSString *escort;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, strong)NNGetDataListResponse *remainingBytes;
@end

@interface SOSSocialOrderInfoResp : NSObject
@property (nonatomic, copy) NSString *statusName;
@property (nonatomic, copy) NSString *destinationLocation;
//@property (nonatomic, copy) NSString *state;
//@property (nonatomic, strong)NNGetDataListResponse *remainingBytes;
@end

/////
#pragma mark- 随星助理
@interface SOSUserScheduleItem : NSObject
@property (nonatomic, copy) NSString *serviceId;
@property (nonatomic, copy) NSString *calendarId;
@property (nonatomic, copy) NSString *remindDate;
@property (nonatomic, copy) NSString *remindContent;
@property (nonatomic, copy) NSString *processingStatus;
@end
@interface SOSUserScheldulesResp : NSObject
@property (nonatomic, strong) NSArray *userScheldules;
@end

@interface SOSSocialOrderShareInfoResp : NSObject
@property (nonatomic, copy) NSString *pickupToken;
@property (nonatomic, copy) NSString *onstarMomentShareUrl;
@property (nonatomic, copy) NSString *wechatShareUrl;
@end

/// 优惠加油,第三方油站
@interface SOSOilStation : NSObject
/// City Code
@property (nonatomic, copy) NSString *cityCode;
/// City Name
@property (nonatomic, copy) NSString *cityName;
/// 区域编号
@property (nonatomic, copy) NSString *countyCode;
/// 省份编码
@property (nonatomic, copy) NSString *provinceCode;
/// 省份名称
@property (nonatomic, copy) NSString *provinceName;
/// 区域名称 (ex:徐汇区)
@property (nonatomic, copy) NSString *countyName;
/// 距中心点距离 (KM)
@property (nonatomic, assign) double distance;
/// 加油站地址
@property (nonatomic, copy) NSString *gasAddress;
/// 加油站 纬度 X
@property (nonatomic, assign) double gasAddressLatitude;
/// 加油站 经度 Y
@property (nonatomic, assign) double gasAddressLongitude;
/// 油站 ID
@property (nonatomic, copy) NSString *gasId;
/// 油站大图 URL
@property (nonatomic, copy) NSString *gasLogoBig;
/// 油站略缩图 URL
@property (nonatomic, copy) NSString *gasLogoSmall;
///  油站名称
@property (nonatomic, copy) NSString *gasName;
/// 油站类型（1 中石油，2 中石化，3 壳牌，4 其他）
@property (nonatomic, copy) NSString *gasType;
/// 油站 ID (待确认)
@property (nonatomic, copy) NSString *stationID;
/// 油号名称
@property (nonatomic, copy) NSString *oilName;
/// 油号编码
@property (nonatomic, copy) NSString *oilNo;
/// 油号类别: 1 汽油，2 柴油，3 天然气
@property (nonatomic, copy) NSString *oilType;
/// 油枪价格
@property (nonatomic, copy) NSString *priceGun;
/// 国标价
@property (nonatomic, copy) NSString *priceOfficial;
/// 优惠加油价格
@property (nonatomic, copy) NSString *priceYfq;

- (SOSPOI *)transToPOI;

@end

/// 优惠加油订单
@interface SOSOilOrder : NSObject

/// 订单号
@property (nonatomic, copy) NSString *orderId;
/// 支付号
@property (nonatomic, copy) NSString *paySn;
/// 手机号
@property (nonatomic, copy) NSString *phone;
/// 订单生成时间, 时间格式 2017-09-27 00:00:00
@property (nonatomic, copy) NSString *orderTime;
/// 支付时间, 时间格式 2017-09-27 00:00:00
@property (nonatomic, copy) NSString *payTime;
/// 退款时间, 时间格式 2017-09-27 00:00:00
@property (nonatomic, copy) NSString *refundTime;
/// 油站名称
@property (nonatomic, copy) NSString *gasName;
/// 省名称
@property (nonatomic, copy) NSString *province;
/// 市名称
@property (nonatomic, copy) NSString *city;
/// 县名称
@property (nonatomic, copy) NSString *county;
/// 枪号
@property (nonatomic, copy) NSString *gunNo;
/// 油号
@property (nonatomic, copy) NSString *oilNo;
/// 实付金额(单位:元)
@property (nonatomic, copy) NSString *amountPay;
/// 订单总金额(单位:元)
@property (nonatomic, copy) NSString *amountGun;
/// 优惠金额(单位:元)
@property (nonatomic, copy) NSString *amountDiscounts;
/// 订单状态	(1, "已支付"， 4, "退款申请中"， 5, "已退款"， 6, "退款失败")
@property (nonatomic, copy) NSString *orderStatusName;
/// 优惠券金额(单位:元)
@property (nonatomic, copy) NSString *couponMoney;
/// 优惠券 Id
@property (nonatomic, copy) NSString *couponId;
/// 优惠券 Code
@property (nonatomic, copy) NSString *couponCode;
/// 升数
@property (nonatomic, copy) NSString *litre;
/// 支付方式
@property (nonatomic, copy) NSString *payType;
/// 最终享受单价(单位:元)
@property (nonatomic, copy) NSString *priceUnit;
/// 国标价(单位:元)
@property (nonatomic, copy) NSString *priceOfficial;
/// 枪价 (单位:元)
@property (nonatomic, copy) NSString *priceGun;
/// 订单来源
@property (nonatomic, copy) NSString *orderSource;


@end

/// 油号信息
@interface SOSOilInfoObj : NSObject

/// 是否为默认油号
@property (nonatomic, assign) BOOL defaultShow;
/// 油号名称
@property (nonatomic, copy) NSString *oilName;
/// 油号数字
@property (nonatomic, copy) NSString *oilNo;

@end
