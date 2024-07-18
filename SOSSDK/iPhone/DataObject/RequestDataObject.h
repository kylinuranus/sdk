//
//  RequestDataObject.h
//  Onstar
//
//  Created by Joshua on 15/8/26.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#ifndef Onstar_RequestDataObject_h
#define Onstar_RequestDataObject_h
//  Prefix NN -- New oNstar api
#pragma mark - 基础类
//基础类－车辆信息
@interface VehicleInformation : NSObject
@property (nonatomic, copy) NSString *vin;
@property (nonatomic, copy) NSString *accountID;
@property (nonatomic, copy) NSString *make;
@property (nonatomic, copy) NSString *model;
@property (nonatomic, copy) NSString *year;
@property (nonatomic, copy) NSString *mdn;
@property (nonatomic, copy) NSString *stationID;
@property (nonatomic, copy) NSString *makeDesc;
@property (nonatomic, copy) NSString *modelDesc;
@property (nonatomic, copy) NSString *manufacturerDesc;
@property (nonatomic, copy) NSString *vehiclePhone;
@end

//账户信息 Account
@interface AccountInfo : NSObject
@property (nonatomic, copy) NSString *accountID;
@property (nonatomic, copy) NSArray *vehicles;
@end
//用户信息 Subscriber：一个用户可对应多个账户
@interface SubscriberInfo : NSObject
@property (nonatomic, copy) NSString *idpID;
@property (nonatomic, copy) NSArray *accounts;
@end

//套餐包信息
@interface CorePackageInfo : NSObject
@property (nonatomic, copy) NSString *packageId;
@property (nonatomic, copy) NSString *packageOfferId;
@property (nonatomic, copy) NSString *packageType;
@end
//支付渠道
@interface channelDTO : NSObject
@property (nonatomic,strong)NSString *channelId;
@property (nonatomic,strong)NSString *channel;
@property (nonatomic,strong)NSString *channelDescription;
@property (nonatomic,strong)NSString * isDefault;
@property (nonatomic,assign)NSString * isAvailable;
@property (nonatomic,strong)NSString *state;
@end

//预付费卡信息
@interface PrepayCardInfo : NSObject
@property (nonatomic, copy) NSString *cardNo;
@property (nonatomic, copy) NSString *passWord;
@property (nonatomic, copy) NSString *osType;
@property (nonatomic, copy) NSString *operation;
@end

//用户行为报告
@interface ReportItemInfo : NSObject
@property (nonatomic, copy) NSString *reportId;
@property (nonatomic, copy) NSString *functionID;
@property (nonatomic, copy) NSString *timestamp;
@property (nonatomic, copy) NSString *vin;
@property (nonatomic, copy) NSString *operation;
@property (nonatomic, copy) NSString *startTimestamp;
@property (nonatomic, copy) NSString *endTimestamp;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *role;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *idpID;
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSString *deviceType;
@property (nonatomic, copy) NSString *osType;
@property (nonatomic, copy) NSString *accountID;
@property (nonatomic, copy) NSString *appVersion;
@end


//修改密码
@interface ChangePasswordRequest : NSObject
@property (nonatomic, copy) NSString *oldPassword;
@property (nonatomic, copy) NSString *theNewPassword;
@end



//获取消息列表
@interface NNGetBroadCastList : NSObject
@property (nonatomic, copy) NSString *vin;
@property (nonatomic, copy) NSString *model;
@property (nonatomic, copy) NSString *year;
@property (nonatomic, copy) NSString *osType;
@end

//用户行为报告
@interface ReportUserAction : NSObject
@property (nonatomic, copy) NSArray *reports;
@end

#pragma -EV
@interface chargingProfile : NSObject
@property (nonatomic, copy) NSString *chargeMode;
@property (nonatomic, copy) NSString *rateType;
@end

@interface dailyCommuteSchedule : NSObject
@property (nonatomic, copy) NSString *dayOfWeek;
@property (nonatomic, copy) NSString *departTime;
@end


@interface LockDoorRequest : NSObject
@property(nonatomic,strong) NSString *delay;
@end

@interface RCLockDoorRequest : NSObject
@property(nonatomic,strong) LockDoorRequest *lockDoorRequest;
@end

@interface UnlockDoorRequest : NSObject
@property(nonatomic,strong) NSString *delay;
@end

@interface RCUnlockDoorRequest : NSObject
@property(nonatomic,strong) UnlockDoorRequest *unlockDoorRequest;
@end



#pragma -alert
@interface AlertRequest : NSObject
@property(nonatomic, strong) NSString *delay;
@property(nonatomic, strong) NSString *duration;
@property(nonatomic, strong) NSArray *action;
@property(nonatomic, strong) NSArray *overriden;//override
@end


@interface RCalertRequest : NSObject
@property(nonatomic, strong) AlertRequest *alertRequest;
@end

#pragma -TBT
@interface DestinationLocation : NSObject
@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *longi;//json long
@end

@interface DestinationAddress : NSObject
@property(nonatomic, strong) NSString *country;
@property(nonatomic, strong) NSString *street;
@property(nonatomic, strong) NSString *city;
@property(nonatomic, strong) NSString *state;
@property(nonatomic, strong) NSString *zipCode;
@property(nonatomic, strong) NSString *streetNo;
@end

@interface AdditionalDestinationInfo : NSObject
@property(nonatomic, strong) NSString *destinationType;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) DestinationAddress *destinationAddress;
@end

@interface PreferDealer : NSObject
@property (nonatomic, copy) NSString *subscriber;
@property (nonatomic, copy) NSString *accounts;
@property (nonatomic, copy) NSString *vehicles;
@end


@interface TBTDestination : NSObject
@property(nonatomic, strong) DestinationLocation *destinationLocation;
@property(nonatomic, strong) AdditionalDestinationInfo *additionalDestinationInfo;
@end

@interface RCtbtDestination : NSObject
@property(nonatomic, strong) TBTDestination *tbtDestination;
@end

#pragma -naviDestination
@interface NAVDestination :NSObject
@property(nonatomic ,strong) DestinationLocation *destinationLocation;
@property(nonatomic, strong) AdditionalDestinationInfo *additionalDestinationInfo;
@end

@interface RCnavDestination : NSObject
@property(nonatomic, strong) NAVDestination *navDestination;
@end

@interface DiagnosticsRequest : NSObject
@property(nonatomic, strong) NSMutableArray *diagnosticItem;
@end

@interface RCdiagnosticsRequest : NSObject
@property(nonatomic, strong) DiagnosticsRequest *diagnosticsRequest;
@end

#pragma -wifi
@interface Hotspot : NSObject
@property (nonatomic, strong) NSString *ssid;
@property (nonatomic, strong) NSString *passphrase;
@end

@interface RCsetHotSpot : NSObject
@property (nonatomic, strong) Hotspot *hotspotInfo;
@end

//feedback
@interface NNfeedbackRequest : NSObject
@property (nonatomic, copy) NSString *appVersion;
@property (nonatomic, copy) NSString *comments;
@property (nonatomic, copy) NSString *accountID;
@property (nonatomic, copy) NSString *idpID;
@property (nonatomic, copy) NSString *vin;
@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *origin;
@property (nonatomic, copy) NSArray *base64AttachedImageList;
@end

@interface NNBase64AttachedList : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *content;
@end

//车牌号
@interface VehicleInfoRequest : NSObject
@property (nonatomic, copy) NSString *licensePlate;
@property (nonatomic, copy) NSString *engineNumber;
@end


@interface NNCurrentlocation : NSObject
@property (nonatomic, strong) NSString * longitude;
@property (nonatomic, strong) NSString * latitude;
@end


@interface NNAroundDealerRequest : NSObject
@property (nonatomic, copy) NSString *cityCode;
@property (nonatomic, copy) NSString *dealerBrand;
@property (nonatomic, strong) NNCurrentlocation *currentLocation;
@property (nonatomic, copy) NSString *queryType;
@property (nonatomic, copy) NSString *returnPreferredDealer;

//@property (nonatomic, copy) NSString *radius;
@end
@interface NNGAAEmailPhoneRequest : NSObject
@property (nonatomic, copy) NSString *emailAddress;
@property (nonatomic, copy) NSString *mobilePhoneNumber;
//@property (nonatomic, copy) NSString *radius;
@end


@interface NNSaveSessionRequest : NSObject
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *deviceOS;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *deviceType;
@property (nonatomic, copy) NSString *deviceID;
@property (nonatomic, copy) NSString *channelID;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *mobileNumber;
@property (nonatomic, strong) NSArray *vehicles;
@property (nonatomic, copy) NSString *deviceToken;
@property (nonatomic, copy) NSString *appleDeviceToken;

@property (nonatomic, copy) NSString *role;
@property (nonatomic, copy) NSString *subscriberID;
@property (nonatomic, copy) NSString *deviceChannel;

@end

@interface NNSaveDeviceInfoRequest : NSObject
@property (nonatomic, copy) NSString *isBind;               //  传"Y"，登出传 "N"
@property (nonatomic, copy) NSString *deviceOS;          //
@property (nonatomic, copy) NSString *isAlert;                  //传"Y"
@property (nonatomic, copy) NSString *deviceType;           //
@property (nonatomic, copy) NSString *deviceID;                 //设备标志符
@property (nonatomic, copy) NSString *isNotification;       //传"Y"
@property (nonatomic, copy) NSString *deviceToken;          //推送 设备token
@property (nonatomic, copy) NSString *deviceChannel;

@property (nonatomic, copy) NSString *imsi;          //sim卡
@property (nonatomic, copy) NSString *userID;          //idpid
@property (nonatomic, copy) NSString *userName;          //
@property (nonatomic, copy) NSString *channelID;          //    传"1"
@property (nonatomic, copy) NSString *email;          //
@property (nonatomic, copy) NSString *mobileNumber;          //
@property (nonatomic, copy) NSString *subscriberID;          //

@end

//EV
@interface NNChargeOverrideRequest : NSObject
@property (nonatomic, strong) NSString *mode;
@end

@interface NNEVChargeOverRide : NSObject
@property (nonatomic, strong) NNChargeOverrideRequest *chargeOverrideRequest;
@end

@interface NNEVNav : NSObject
@property (nonatomic, strong) NSString *originChargeCapable;
@property (nonatomic, strong) DestinationLocation *destinationLocation;
@end

@interface NNEVNavDestination : NSObject
@property (nonatomic, strong) NNEVNav *evNavDestination;
@end

@interface NNOnBoardDays : NSObject
@property (nonatomic, copy) NSString *totalRemainingDay;
@end

@interface NNBannerRequest : NSObject
@property(nonatomic, strong) NSString *vin;
@property(nonatomic, strong) NSString *make;
@property(nonatomic, strong) NSString *model;
@property(nonatomic, strong) NSString *year;
@property(nonatomic, strong) NSString *deviceType;
@property(nonatomic, strong) NSString *deviceOS;
@property(nonatomic, strong) NSString *languagePreference;
@property(nonatomic, strong) NSString *userID;
@property(nonatomic, strong) NSString *imgType;
@property(nonatomic, strong) NSString *versionCode;
@property(nonatomic, strong) NSString *contentType;
@property(nonatomic, strong) NSString *category;// -- 后台会根据此字段显示相应类型的banner, 多个类型用逗号隔开, 如果不传, 7.1版本以前客户端只返回首页banner, 7.1及以后版本则返回所有banner;7.1车主生活：" CAR_MANAGER,LIFE_MANAGER,HOT_PROMOTION"
@end
@interface NNTestResRequest : NSObject
@property(nonatomic, strong) NSString *key;
@property(nonatomic, strong) NSString *sig;
@property(nonatomic, strong) NSString *output;
@property(nonatomic, strong) NSString *ext;
@property(nonatomic, strong) NSString *province;
@property(nonatomic, strong) NSString *plate;
@property(nonatomic, strong) NSString *adcode;

@end
// 登录认证相关
@interface NNOAuthRequest : NSObject
@property (nonatomic, strong) NSString *client_id;
@property (nonatomic, strong) NSString *grant_type;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *scope;
@property (nonatomic, strong) NSString *device_id;
@property (nonatomic, strong) NSString *nonce;
@property (nonatomic, strong) NSString *timestamp;
@property (nonatomic, strong) NSString *assertion;
@property (nonatomic, strong) NSString *pin;
@end

// Upgrade相关
@interface NNUpgradeRequest : NSObject
@property(nonatomic, strong) NSString *client_id;
@property(nonatomic, strong) NSString *end_use_client_id;
@property(nonatomic, strong) NSString *credential_type;
@property(nonatomic, strong) NSString *credential;
@property(nonatomic, strong) NSString *device_id;
@property(nonatomic, strong) NSString *client_secret;
@property(nonatomic, strong) NSString *nonce;
@property(nonatomic, strong) NSString *timestamp;
@end

#pragma mark 经纬度
@interface NNGpsLocationCoordinate : NSObject
@property (nonatomic, copy) NSString *latitude;
@property (nonatomic, copy) NSString *longitude;

+ (instancetype)locationWithLatitude:(double)latitude Longitude:(double)longitude;

@end


#pragma mark 保存目的地
@interface NNFavoritePOI : NSObject
@property (nonatomic, copy) NSString *fuid;
@property (nonatomic, copy) NSString *favoriteDestinationID;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *idpID;
@property (nonatomic, copy) NSString *poiNickname;
@property (nonatomic, copy) NSString *poiName;
@property (nonatomic, copy) NSString *poiAddress;
@property (nonatomic, copy) NSString *poiPhoneNumber;
@property (nonatomic, copy) NSString *PoiCatetory;
@property (nonatomic, strong) NNGpsLocationCoordinate *poiCoordinate;
@property (nonatomic, strong) NNGpsLocationCoordinate *mobileCoordinate;
@property (nonatomic, copy) NSString *cityCode;
@property (nonatomic, copy) NSString *provience;
@end

#pragma mark 目的地列表
@interface GetFavoriteDestinationListRequest : NSObject
@property (nonatomic, copy) NSString *magAppSessionKey;
@property (nonatomic, copy) NSString *language;
//@property (nonatomic, assign) NSInteger pageNumber;
//@property (nonatomic, assign) NSInteger pageSize;
@end

@interface NNPurchaseRequest : NSObject
@property (nonatomic, copy) NSString *operation;
@property (nonatomic, copy) NSString *osType;
@property (nonatomic, copy) NSString *cardNo;
@property (nonatomic, copy) NSString *passWord;
@property (nonatomic, copy) NSString *vehicleId;

@end

@interface NNChangeVehicleRequest : NSObject
@property (nonatomic, copy) NSString *vin;
@property (nonatomic, copy) NSString *idpUserID;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *subscriberID;
@end
//add 7.3
@interface NNChangeAddressRequest : NSObject
@property(nonatomic, copy) NSString *accountNumber;
@property(nonatomic, copy) NSString *province;
@property(nonatomic, copy) NSString *city;
@property(nonatomic, copy) NSString *address1;
@property(nonatomic, copy) NSString *address2;
@property(nonatomic, copy) NSString *zip;
@end
#pragma mark - 8.0 注册对象
@interface CaptchaDTO: NSObject
@property (nonatomic,copy)NSString * isRequired;
@property (nonatomic,copy)NSString * captchaId;
@property (nonatomic,copy)NSString * captchaValue;
@end


@interface RegCodeDTO: NSObject
@property (nonatomic,copy)NSString * isRequired;
@property (nonatomic,copy)NSString * secCode;
@property (nonatomic,copy)NSString * destType;
@end


@interface RegisterEnrollDTO: NSObject
@property (nonatomic,strong)CaptchaDTO * captchaInfo;
@property (nonatomic,strong)RegCodeDTO * regCodeInfo;
@property (nonatomic,copy)NSString * vin;
@property (nonatomic,copy)NSString * govid;
@end



@interface NNRegisterRequest : NSObject
@property(nonatomic, strong) NSString *vin;
@property(nonatomic, strong) NSString *governmentID;
//@property(nonatomic, retain) NSString *operation;
@property(nonatomic, strong) NSString *emailAddress;
@property(nonatomic, strong) NSString *mobilePhoneNumber;
@property(nonatomic, strong) NSString *theNewEmailAddress;
@property(nonatomic, strong) NSString *theNewMobilePhoneNumber;
@property(nonatomic, strong) NSString *userName;
@property(nonatomic, strong) NSString *nickName;
@property(nonatomic, copy) NSString *firstName;//info3
@property(nonatomic, copy) NSString *lastName;//info3
@property(nonatomic, strong) NSString *passWord;
@property(nonatomic, strong) NSString *secCode;
@property(nonatomic, strong) NSString *sourceId;
@property(nonatomic, strong) NSString *destType;
@property(nonatomic, strong) NSString *licenseExpireDate;
@property(nonatomic, strong) NSString *captchaId;
@property(nonatomic, strong) NSString *captchaValue;
@property(nonatomic, strong) NSString *sendCodeSenario;
@end

//添加车辆／升级车主
@interface NNVehicleAddRequest : NNRegisterRequest
@property(nonatomic, copy) NSString *idpUserID;
@property(nonatomic, copy) NSString *subscriberID;
@property(nonatomic, copy) NSString *accountNumber;
@end


@interface NNGetUserProfile : NSObject
@property(nonatomic, copy) NSString *versionCode;
@property(nonatomic, strong) NSString *osType;
@property(nonatomic, strong) NSString *OSVersion;
@end


@interface NNDealersReserveRequest : NSObject
@property (nonatomic ,copy) NSString *brand;
@property (nonatomic, strong) NSString * longitude;
@property (nonatomic, strong) NSString * latitude;
@end

@interface NNDealersPreOrder : NSObject
@property (nonatomic ,copy) NSString *name;
@property (nonatomic ,copy) NSString *preType;
@property (nonatomic ,copy) NSString *phone;
@property (nonatomic ,copy) NSString *brand;
@property (nonatomic ,copy) NSString *stationNum;
@property (nonatomic ,copy) NSString *regTime;
@property (nonatomic ,copy) NSString *source;
@property (nonatomic ,copy) NSString *lineName;
@property (nonatomic, copy) NSString *idpId;
@property (nonatomic, copy) NSString *vin;

@end
#pragma mark - 8.2登录
//请求人车关系
@interface NNUserVehicleAssetsRequest : NSObject
@property (nonatomic ,copy) NSString *idpUserId;
@property (nonatomic ,copy) NSString *subscriberId;
@property (nonatomic ,copy) NSString *vin;
@end
//请求车辆权限
@interface NNVehiclePrivilegeRequest : NSObject
@property (nonatomic ,copy) NSString *subscriberId;
@property (nonatomic ,copy) NSString *accountType;
@property (nonatomic ,copy) NSString *vin;
@property (nonatomic ,copy) NSString *role;
@end
//头像
@interface NNHeadPhoto : NSObject
@property (nonatomic ,copy) NSString *idpID;
@property (nonatomic ,copy) NSString *userFace;
@property (nonatomic ,copy) NSString *extension;
@end

//PHEV charge
@interface NNChargeNot : NSObject
@property (nonatomic, assign) BOOL chargeSwitch;
@end

@interface NNserviceName : NSObject
@property(nonatomic,copy) NSString *serviceName;
@end

@interface NNVehicleInfoRequest : NSObject
@property (nonatomic, copy) NSString *accountID;
@property (nonatomic, copy) NSString *vin;
@property (nonatomic, copy) NSString *engineNumber;//发动机编号
@property (nonatomic, copy) NSString *licensePlate;//车牌
@property (nonatomic, copy) NSString *insuranceComp;//保险公司
@property (nonatomic, copy) NSString *compulsoryInsuranceExpireDate;//交强险到期日
@property (nonatomic, copy) NSString *businessInsuranceExpireDate;//商业保险到期日
@property (nonatomic, copy) NSString *drivingLicenseDate;//商业保险到期日

@end

@interface NNProfilesModel : NSObject
@property (nonatomic, copy) NSString *power;
@property (nonatomic, copy) NSString *mode;
@property (nonatomic, copy) NSString *temperature;
@end

@interface NNControlSmartHome : NSObject
@property (nonatomic, strong) NNProfilesModel *profiles;
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSString *switchStatus;
@property (nonatomic, copy) NSString *geoFencingStatus;
@property (nonatomic, copy) NSString *platform;
@property (nonatomic, copy) NSString *deviceType;
@end

@interface NNNewGeoFence : NSObject
@property (nonatomic, copy) NSString *range;
@property (nonatomic, copy) NSString *rangeUnit;
@property (nonatomic, copy) NSString *destinationId;
@property (nonatomic, copy) NSArray *deviceIds;
@end

@interface NNBindGeoFence : NSObject
@property (nonatomic, copy) NSString *geoFencingID;
@property (nonatomic, copy) NSArray *deviceIds;
@end

@interface NNThirdParty : NSObject
@property (nonatomic, copy) NSString *userName;//idpid
@property (nonatomic, copy) NSString *vehicleID;//VIN
@property (nonatomic, copy) NSString *licensePlate;//车牌号
@property (nonatomic, copy) NSString *engineNumber;//发动机号
@property (nonatomic, copy) NSString *mobilePhoneNumber;
@property (nonatomic, copy) NSString *emailAddress;
@property (nonatomic, copy) NSString *firstName;//名
@property (nonatomic, copy) NSString *lastName;//姓
@property (nonatomic, strong) NNGpsLocationCoordinate *location;
@property (nonatomic, copy) NSString *timestamp;
@property (nonatomic, copy) NSArray *extensions;
@end

@interface NNExtension : NSObject
@property (nonatomic ,copy) NSString *code;
@property (nonatomic, copy) NSString *value;
@end


@interface NNDispatcherReq : NSObject
@property (nonatomic ,copy) NSString *method;
//@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, copy) NSString *partner_id;
@property (nonatomic, copy) NSString *paramsData;
@property (nonatomic, copy) NSString *attributeData;
@property (nonatomic, copy) NSString *latitude;
@property (nonatomic, copy) NSString *longitude;
@property (nonatomic, copy) NSString *dispatchFrom;
@property (nonatomic, copy) NSString *dispatchKey;

@end


@interface  NNURLRequest : NSObject
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *jsonStr;
@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) NSString *contenType;
@end


@interface NNNotifyConfigRequest : NSObject
@property(nonatomic, strong) NSString *btype;
@property(nonatomic, strong) NSString *subscriber_id;
@property(nonatomic, strong) NSString *vin;
@property(nonatomic, strong) NSString *sms_checked;
@property(nonatomic, strong) NSString *mail_checked;
@property(nonatomic, strong) NSString *wechat_checked;
@property(nonatomic, strong) NSString *mobile_checked;
@property(nonatomic, strong) NSString *phone;
@property(nonatomic, strong) NSString *mail;
@property(nonatomic, strong) NSString *oldphone;
@property(nonatomic, strong) NSString *iscall;
@end


@interface NNSendNotify : NSObject
@property(nonatomic, strong) NSString *mobilePhoneNumber;
@property(nonatomic, strong) NSString *emailAddress;
@property(nonatomic, strong) NSString *destType;
@property(nonatomic, strong) NSString *secCode;
@property(nonatomic, copy) NSString *subscriberID;
@end

@interface NNTVLogin : NSObject
@property(nonatomic, strong) NSString *accessToken;//用来查询用户缓存信息
@property(nonatomic, strong) NSString *iDToken;//用来绑定关系
@property(nonatomic, strong) NSString *mobileDeviceID;//手机设备ID
@property(nonatomic, strong) NSString *mobileDeviceToken;//手机设备Token
@property(nonatomic, strong) NSString *qRCode;//二维码
@property(nonatomic, strong) NSString *functionID;
@end

//星旅程卡片接口model
//获取爱车评估信息  获取驾驶行为评分
@interface NNCarconditionReportReq : NSObject

@property (nonatomic, assign) BOOL isLogin;
@property (nonatomic, copy)   NSString *role;
@property (nonatomic, assign) BOOL isFirstInfo;

@property (nonatomic, assign) BOOL optStatus;
@property (nonatomic, assign) BOOL avalibility;
//获取综合油耗排名
@property (nonatomic, assign) BOOL isGen10;
//获取综合能耗排名
@property (nonatomic, assign) BOOL isPHEV;

@end

//获取综合油耗排名 获取综合能耗排名
@interface NNRankReq : NNCarconditionReportReq

//@property (nonatomic, assign) BOOL optStatus;
//@property (nonatomic, assign) BOOL avalibility;
//获取综合油耗排名
//@property (nonatomic, assign) BOOL isGen10;
//获取综合能耗排名
//@property (nonatomic, assign) BOOL isPHEV;

@end


#endif



