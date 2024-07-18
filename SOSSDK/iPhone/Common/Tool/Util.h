//
//  Util.h
//  Onstar
//
//  Created by Alfred Jin on 1/17/11.
//  Copyright 2011 plenware. All rights reserved.
//

#import "SOSVehicleVariousStatus.h"
#import <Foundation/Foundation.h>
#import "UITextField+Keyboard.h"
#import "NSString+SOSCategory.h"
#import "SOSNetworkOperation.h"
#import "ResponseDataObject.h"
#import "UIButton+FillColor.h"
#import "SOSNavigateHeader.h"
#import "MsgCenterManager.h"      //addbyWQ 20180607
#import "NSDataAES256.h"
#import "UIView+Utils.h"
#import "SOSLanguage.h"
#import "ServiceURL.h"
#import "OthersUtil.h"
NS_ASSUME_NONNULL_BEGIN
//车辆充电状态
#define SOSVehicleChargeStateCharging           @"charging"
#define SOSVehicleChargeStateNotCharging        @"not_charging"
#define SOSVehicleChargeStateChargingComplete   @"charging_complete"
#define SOSVehicleChargeStateChargingAborted    @"charging_aborted"

typedef NS_ENUM(NSInteger, SOSVehicleStatus) {
    SOSVehicleStatusUnknow,
    SOSVehicleStatusBest,
    SOSVehicleStatusBetter,
    SOSVehicleStatusBad
};

typedef NS_ENUM(NSInteger,EditStatus) {
    FinishStatus = 0,
    CancelStatus,
    EditingStatus,
};

typedef NS_ENUM(NSInteger,SOSChargeStatus) {
    SOSChargeStatus_Unknow,
    SOSChargeStatus_charging ,
    SOSChargeStatus_not_charging,
    SOSChargeStatus_charging_complete,
    SOSChargeStatus_charging_aborted
};



@class SOSPOI;
@class ErrorInfo;

//删除了UIAlertView+block, block放这里来
typedef void(^CompleteBlock) (NSInteger buttonIndex);

@interface Util : NSObject

+ (void)writeToDocuments;
+ (void)writeConfig:(NSString *)keyName setValue:(NSObject *)value;
+ (NSString *)readConfig:(NSString *)keyName;

+ (NSMutableArray *)readCaclulateDate;
+ (void)writeCaclulateWithMulateArray:(NSMutableArray *)arr;


+ (NSString *)addVINPrexWithString:(NSString *)vin;
+ (NSString *)removeVINPrexWithString:(NSString *)vin;
+ (NSString *)addChargeModePrexWithString:(NSString *)vin;
+ (NSString *)removeChargeModePrexWithString:(NSString *)vin;

//+ (NSString *)renewToken;
+ (NSData*)encryptString:(NSString*)plaintext withKey:(NSString*)key;
+ (NSString*)decryptData:(NSData*)ciphertext withKey:(NSString*)key;

+ (void)updateTBTinfoTableWithStatus:(NSString *)newStatus andID:(NSNumber *)keyID atTable:(NSString *)tableNmae;
+ (void)insertInto:(NSString *)tableNmae WithSendTBTinfos:(NSDictionary *)poiInfos;
+ (void)insertInto:(NSString *)tableNmae WithRequestId:(NSString *)requestID andRequestType:(NSString *)requestType;
+ (NSMutableArray *)getDestinationItemsFrom:(NSString *)tableNmae;
+ (void)deleteVinInfoWithID:(NSNumber *)vinID fromTable:(NSString *)tableNmae;

+ (NSString*)checkInputString:(NSString*)str;



+ (BOOL)isiPhoneXSeries;

+ (NSMutableDictionary *)getCurrentDeviceID;
+ (NSMutableDictionary *)getCurrentDeviceInfoDic ;
//获取系统语言
+ (NSString *)getMetaLanguage;


+ (BOOL)vehicleIsEV;
+ (BOOL)vehicleIsBEV;
+ (BOOL)vehicleIsBuick;
+ (BOOL)vehicleIsCadillac;
+ (BOOL)vehicleIsChevrolet;

+ (NSString *)getVehicleBrandName;



+ (BOOL)isValidNumber:(NSString *)toCheck;
+ (BOOL)isNotEmptyString:(NSString *)string;
+ (UIViewController*)findTopViewControllerOfClass:(Class)classname  fromControllers:(NSArray*)controllers;
+ (int)indexOfTopViewControllerOfClass:(Class)classname  fromControllers:(NSArray*)controllers;
+ (NSString*)getVerDate;
+ (BOOL)isDeviceiPhone6Plus;
+ (BOOL)isDeviceiPhone6;
+ (BOOL)isDeviceiPhone5;
+ (BOOL)isDeviceiPhone4;
+ (BOOL)isUpgradeUser;
+ (NSString*)getConfigureURL;
+ (NSString*)getStaticConfigureURL:(NSString *)relativePath;
+ (NSString*)getmOnstarStaticConfigureURL:(NSString *)relativePath;
+ (NSString*)getOMOnstarStaticConfigureURL:(NSString *)relativePath;
+ (UIImage *)zoomImage:(UIImage *)image WithScale:(int)scale;
+ (SOSPOI *)convertToSOSpoiFromDict:(NSDictionary *)dict;


#define K_PROPERTY_NAME         @"Pname"
#define K_PROPERTY_TYPE         @"Ptype"
+ (NSMutableArray *)propertyNanmeAndPropertyTypeFromObject:(id)obj;
+ (BOOL)copySamePropertyFromObj1:(id)obj1 ToObj2:(id)obj2;

+ (BOOL)isValidateUserName:(NSString *)userName;
+ (BOOL)isValidateEmail:(NSString *)email;
+ (BOOL)isValidatePhone:(NSString *)phone;
+ (BOOL)isValidateMobilePhone:(NSString*)phone;
+ (BOOL)isValidatePassword:(NSString *)password;
+ (BOOL)isValidateCarControlPassword:(NSString *)password ;
+ (BOOL)isNumeber:(NSString *)str;
+ (BOOL)isValidateVin:(NSString *)vin;
+ (BOOL)isValidateSSID:(NSString *)ssid;
+ (BOOL)isValidateInfo3SSID:(NSString *)ssid;
+ (BOOL)isvalidateSSIDPassword:(NSString *)password;


+ (BOOL)isCorrectLicenseNum:(NSString* )liscenseNo;
+ (BOOL)isCorrectEngineNum:(NSString* )engineNo;

+ (NSString *)trim:(UITextField *)textfield;
+ (NSString *)trimString:(NSString *)str_ ;
+ (NSString *)trimWhite:(UITextField *)textfield;
+ (NSString *)removeWhiteSpaceString:(NSString *)string;
+ (NSArray *)cityInfoArray;
//省及简写table
+ (NSArray *)provinceInfoArray;
+ (NSArray *)insuranceInfoArray;
//性别及简写
+ (NSArray *)genderInfoArray;
//用车类型及简写
+ (NSArray *)vehicleTypeInfoArray;

//简写->省名称，省为本地propertyList
+ (NSString *)acronymToZhcn:(NSString *)arconym __attribute((deprecated("已废弃，使用acronymToZhcn:(NSString *)arconym compareList")));
//简写->省，省为接口获取
+ (NSString *)acronymToZhcn:(NSString *)arconym compareList:(NSArray *)proList;
//+ (NSString *)zh_CNToArconym:(NSString *)zh compareList:(NSArray *)proList ;
//服务端substitute -> 客户端实际显示内容转换
+ (NSString *)serverSubstituteToZhcn:(NSString *)arconym comparisonTable:(NSString *)tableName;
//客户端实际显示内容转换 -> 服务端substitute
+ (NSString *)ClientShowToserverSubstitute:(NSString *)arconym comparisonTable:(NSString *)tableName;

+ (NSDate *)convertGTM0ToGTM8WithDate:(NSDate *)date;
////TODO ，注册部分本地mock报文
//+ (NSString *)testLocalJson;
+ (NSString *)testLocalSubscriberJson;

+ (void)writeVisotrConfig:(NSString *)keyName setValue:(NSObject *)value;
+ (NSArray *)readVisitorConfig:(NSString *)keyName;
+ (void)writeToVisitorDocuments;

+ (BOOL)isvalidateTempPassword:(NSString *)password;

// wechat payment
+ (NSString *)md5:(NSString *)input;
+ (NSString *)md5:(NSString *)input WithSalt:(NSString *)salt;
+ (NSString *)sha1:(NSString *)input;
+ (NSString *)getIPAddress:(BOOL)preferIPv4;
+ (NSDictionary *)getIPAddresses;
+ (NSString *)getIPAddress;

//设置公网ip
+ (void )setPublicIP;
//获取公网ip
+ (NSString *)getPublicIP;
//获取mac地址
+ (void)reFreshSSIDInfo;
+ (NSString *)getMACAddress;

+ (NSString *)visibleErrorMessage:(NSString *)message;
#pragma mark --- alert
/**
 显示9.0UI的AlertView,默认一个确定按钮

 @param title_ title
 @param message_ message
 @param complete_ callback
 */
+ (void)showAlertWithTitle:(nullable NSString *)title_ message:(nullable NSString *)message_ completeBlock:(nullable CompleteBlock) complete_;


/**
 显示9.0UI的AlertView,可传入一个确定按钮标题

 @param title title
 @param message message
 @param confirmBtnString 确定按钮标题
 @param complete callback
 */
+ (void)showAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message confirmBtn:(nullable NSString *)confirmBtnString completeBlock:(nullable CompleteBlock)complete;

/**
 显示9.0UI的AlertView

 @param title_ title
 @param message_ message
 @param complete_ callback
 @param canceltitle_ 取消按钮
 @param othertitles_ 复数按钮
 */
+ (void)showAlertWithTitle:(nullable NSString *)title_ message:(nullable NSString *)message_  completeBlock:(nullable CompleteBlock)complete_  cancleButtonTitle:(nullable NSString *)canceltitle_ otherButtonTitles:(nullable NSString *)othertitles_,...;
//RVM使用样式
+ (void)showAlertRVMStytleWithTitle:(nullable NSString *)title_ message:(nullable NSString *)message_  completeBlock:(CompleteBlock)complete_  cancleButtonTitle:(nullable NSString *)canceltitle_ otherButtonTitles:(NSString *)othertitles_,...;
#pragma mark

+ (NSString *)maskMobilePhone:(NSString *)number;
+ (NSString *)maskEmailWithStar:(NSString *)email;
+ (NSString *)findCityNameWithCityCode:(NSString *)cityCode;
+ (BOOL)isValidateGeoFencingName:(NSString *)geoFencingName;
+ (NSString *)calculateTextNumber:(NSString *)textA maxLength:(int)maxLength;

+ (NSString *)localizeErrorCode:(NSString *)errorCode;
/**
 *  计算字符长度,支持中英文等
 *
 *  @param string a string
 *
 *  @return 返回长度
 */
+ (int)calculateStringLength:(NSString *)string;
//+ (BOOL)isInHouseVersion;
+ (NSString *)aMapAPIKey;
+ (NSString *)osType;

/**
 与+ (NSString *)osType 类似，但是为了某些图片适配，区分了iphoneX
 @return
 */
+ (NSString *)currentDeviceType;
+ (NSString *)bannerosType;

+ (NSString *)md5HexDigest:(NSString *)inputStr;
//+ (BOOL)reLoginWithTimeOut:(NSString *)errorCode;
+ (NSString *)getStoryBoard;
+ (NSString *)getPersonalcenterStoryBoard;

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
+ (void)playAlertSound;

#pragma mark json 转 数组
+ (NSArray *)arrayWithJsonString:(NSString *)jsonString;

+ (NSString *)getAppVersionCode;

+ (BOOL)vehicleIsPHEV;
+ (BOOL)vehicleIsG9;
+ (BOOL)vehicleIsG10;
+ (BOOL)vehicleIsD2JBI;

+ (BOOL)vehicleIsIcm;
/// 是否为 ICM 2.0 车
+ (BOOL)vehicleIsICM2;
+ (BOOL)vehicleIsMy21;

+ (BOOL)vehicleIsG8;
+ (BOOL)vehicleIsInfo3;
+ (BOOL)vehicleIsInfo34;


+ (SOSVehicleStatus)updateVehicleStatus;
+ (SOSVehicleConditionCategory)updateVehicleConditionCategory;
+ (SOSChargeStatus)updateChargeStatus;

/**
 *  @brief 根据idpid存储小O开启状态
 */
+ (void)saveMrOOpenFlagByidpid:(NSString *)idpid withFlag:(BOOL)flag;

/**
 *  @brief 根据idpid读取小O开启状态
 */
+ (NSNumber *)readMrOOpenFlagByidpid:(NSString *)idpid;




/**
 *  隐藏左侧的菜单项
 */
//+ (void)hideLeftMenuView;
// 按钮边框颜色
+ (UIButton *)borderColor_forBtn:(UIButton *)btn color:(UIColor *)color;
// 按钮边框颜色
+ (UIButton *)borderColor_forBtn:(UIButton *)btn;

+ (void)toastWithMessage:(NSString *)Message;
+ (void)toastWithVerifyCode:(NSString *)Message;
+ (void)showFootPrintFirstShowNotice;

+ (void)showNetworkErrorToastView;
//弹出顶部提示框，自定义提示内容
+ (void)showToastViewTitle:(NSString *)title detailTitle:(NSString *)detailTitle backgroundColor:(UIColor *)bgcolor showTime:(NSTimeInterval)timeinterval;

+ (void)showLoadingView;

+ (void)hideLoadView;


//获取当前显示controller
+ (UIViewController *)getPresentedViewController;

#pragma mark 空白
+ (BOOL)isBlankString:(NSString *)string;
+ (BOOL)isProvinceAcronym:(NSString *)string;


//检查是否是2g3g用户,是的话给出弹框
+(BOOL) show23gPackageDialog;

/**
 弹框提醒用户对APP评价
 */
+ (void)alertUserEvluateApp;
+ (void) refuseRating;
+ (void) goodRating;

+ (BOOL)isValidPercentValue:(NSString *)value;

+ (NSString *)getDevicePlatform;

+ (UINavigationController *)currentNavigationController;

//+ (void)contactOnstarAction;

+ (NSString *)clientInfo;
//当前时间字符串
+ (NSString *)SOS_stringDate;


+ (void)getVehicleReportCallback:(void(^)(NSString *VehicleOptStatus))opt;
+ (void)openVehicleService:(void(^)(void))compCallback httpMethod:(NSString *)httpMethod;

/**
 get value form IOS system setting at app lanuch
 */
+ (void)ServerIPFromSettings;

+ (void)removeShortcutEditFile;

+ (BOOL)isAllowNotification;

//获取时间戳：times,精确到毫秒
+ (NSString *)getTimeStampFromDate:(NSDate *)date;

//获取格式化日期
+ (NSString *)getFormatterDate:(NSDate *)date;

+ (void)assginVehicleCommansData:(NSString *)str;

+ (NSString *)generateTimeStamp;

+ (NSString *)generateNonce;

+ (void)LoginFrist_SuccessWithIdpid:(NSString *)idpid withVin:(NSString *)vin;

+ (BOOL)isToastLoadUserProfileFailure;

+ (BOOL)isLoadUserProfileFailure;

//压缩imagedata不超过10MB
+ (NSData *)zipImageDataLessthan10MB:(NSData *)imageData __attribute((deprecated("已废弃, 请使用 compressedImageFiles")));
+ (NSData *)zipImageDataLessthan1MB:(UIImage *)image __attribute((deprecated("已废弃, 请使用 compressedImageFiles")));
+ (NSData *)compressedImageFiles:(UIImage *)image imageKB:(CGFloat)fImageKBytes;
+ (NSString *)recodesign:(NSString *)str;


/**
 获取某个类的所有属性名

 @param theClass 类
 @return 属性数组
 */
+ (NSArray <NSString *>*)getAllPropertyKeys:(Class)theClass;

/**
 获取某个类的所有属性值

 @param object 要查找所有属性值的对象
 @param ignoreKeys 忽略的key
 @return 值数组
 */
+ (NSArray <NSString *>*)getAllPropertyValues:(__kindof NSObject *)object ignoreKeys:(NSArray <NSString *>*)ignoreKeys;


/**
 防止重签名

 @return 是否重签名
 */
+ (BOOL)checkCodesign;

+ (UIColor *)randomColor;

+ (NSString *)getChineseForBrand:(NSString *)brand;

+ (NSString *)jsonFromDict:(NSDictionary *)dict;

+ (BOOL)isValidMirrorUserName:(NSString *)userName;
+ (BOOL)isValidateIDCard:(NSString *)cardNum;


+ (void)fireLocalNotification:(nullable NSString *)title body:(NSString *)body identifier:(NSString *)identifier;

+ (NSDictionary *)parseURLParam:(NSString *)url;

#pragma mark - MA9.0 通用HUD控件

/**
 1.请直接使用以下方法而不是直接调用SVProgressHUD，方便以后替换
 2.Loading需要手动调用dismiss隐藏
 3.Success\Error\Info 2秒后消失

 @param status 话术
 @param subStatus 次级话术
 */

/***************************Loading*****************************/
+ (void)showHUD;
+ (void)showHUDWithStatus:(nullable NSString *)status;
+ (void)showHUDWithStatus:(nullable NSString *)status subStatus:(nullable NSString *)subStatus;

/***************************Success*****************************/
+ (void)showSuccessHUDWithStatus:(nullable NSString *)status;
+ (void)showSuccessHUDWithStatus:(nullable NSString *)status subStatus:(nullable NSString *)subStatus;

/***************************Error*****************************/
+ (void)showErrorHUDWithStatus:(nullable NSString *)status;
+ (void)showErrorHUDWithStatus:(nullable NSString *)status subStatus:(nullable NSString *)subStatus;

/***************************Info*****************************/
+ (void)showInfoHUDWithStatus:(nullable NSString *)status;
+ (void)showInfoHUDWithStatus:(nullable NSString *)status subStatus:(nullable NSString *)subStatus;

+ (void)dismissHUD;
#pragma mark - 操作系统日历
/***************************增加日历日程*****************************/

+ (void)saveEventStartDate:(NSDate*)startData endDate:(NSDate*)endDate alarm:(float)alarm eventTitle:(NSString*)eventTitle location:(NSString*)location notes:(NSString*)notes;
+ (void)saveEvents:(NSArray <SOSUserScheduleItem *>*)events successHandler:(void(^)(void))handler;
+ (void)deleteEvents:(NSArray <SOSUserScheduleItem *>*)events;

+(NSString *)ToHex:(long long int)tmpid;

+ (NSString *)hexStringFromString:(NSString *)string;
+ (NSString *)stringFromHexString:(NSString *)hexString;
+ (NSString *)getHexByDecimal:(NSInteger)decimal;

+ (NSString *)timeformatFromSeconds:(NSInteger)seconds ;


+ (NSString *)decodeBase64:(NSString *)base64;
@end
NS_ASSUME_NONNULL_END
