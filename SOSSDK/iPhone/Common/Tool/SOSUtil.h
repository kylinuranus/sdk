//
//  SOSUtil.h
//  Onstar
//
//  Created by lizhipan on 17/3/28.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSWebViewController.h"
#import "CustomerInfo.h"
#import "SOSSearchResult.h" 
#import "CustomNavigationController.h"

#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}
#endif

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)



//与安吉星服务有关的tool方法合并在此处
static  NSString * const kVerifyCodeSubscriberSenario = @"REG_SUBSCRIBER";
static  NSString * const kVerifyCodeVisitorSenario     = @"REG_VISITOR";
static  NSString * const kPreference_Confirm_TCPS     = @"confirmTCPS";
static  NSString * const soskWebDispatch_External     = @"EXTERNAL";

extern  NSString * const kDefault_Account_Avatar     ;


#define  AES128IV    @"360fe65ae392fec2"
#define  AES128KEY  @"360fe65ae392fec2"

@interface SOSUtil : NSObject
#pragma mark --- banner点击弹出加载H5的webViewController
//根据点击banner生成webViewController
+ (SOSWebViewController *)generateBannerClickController:(NNBanner *)banner;

//根据点击banner生成webViewController作为rootViewController的NavigationViewController
+ (CustomNavigationController*)bannerClickShowController:(NNBanner *)banner;
#pragma mark --- 注册部分返回特定错误信息code判断
+ (void)presentLoginFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC;
/**
 服务端返回信息是否代表操作成功，即返回的code = E0000
 */
+ (BOOL)isOperationResponseSuccess:(NSDictionary *)resDic;
/**
 服务端返回信息内desc字段是true or false
 */
+ (BOOL)isOperationResponseDescSuccess:(NSDictionary *)resDic;

//GAA中有对应的subscriber，且注册过MA
+ (BOOL)isOperationResponseMAAndSubscriber:(NSDictionary *)resDic;
//VIN已经enroll过,但没注册过MA
+ (BOOL)isOperationResponseEnrolledNoneMA:(NSDictionary *)resDic;
//VIN不存在
+ (BOOL)isOperationResponseNonexistenceVIN:(NSDictionary *)resDic;
//VIN已经enroll过,且注册过MA
+ (BOOL)isOperationResponseMAVINEnrolled:(NSDictionary *)resDic;
// 手机号／vin／goivd已经注册过MA
+ (BOOL)isOperationResponseAlreadyRegister:(NSDictionary *)resDic;
//添加车辆visitor输入govid绑定车辆成功
+ (BOOL)isOperationResponseUpgradeSuccess:(NSDictionary *)resDic;
//VIN已经提交了enroll请求
+ (BOOL)isOperationResponseRequestEnrolled:(NSDictionary *)resDic;

+ (NSArray *)vehicleSupportCommandArray;
/**
 添加车辆/升级车主

 @param resDic 后端返回报文
 @return return NSArray ,[0]表示提示title,[1]表示提示detailTitle,[3]对应的code 
 */
+ (NSArray *)visitorAddVehicleResponse:(NSDictionary *)resDic;

//注册验证pin码失败报错
+ (NSString *)checkPINResponseCode:(NSString *)resStr;

#pragma mark --- 打电话兼容ios10及以下
+ (void)callPhoneNumber:(NSString *)phoneNumber;
+ (void)callDearPhoneNumber:(NSString *)phoneNumber;
#pragma mark --- 进入买包界面
+ (void)callBuyDataPackageController;
+ (void)callBuyOnstarPackageController;

#pragma mark --- role汉语
+ (NSString *)roleZHcn:(NSString *)roleen;
#pragma mark --- 品牌emip内代码->msp内代码
+ (NSString *)brandToMSP:(NSString *)br_emip;

#pragma mark --- 用户同意最新tcps协议本地记录
+ (void)recordAccountConfirmNewTCPS:(NSString *)account;
+ (BOOL)queryAccountAreadyConfirmTCPS:(NSString *)account;
#pragma mark - 8.0颜色
//
+ (UIColor *)onstarLightViewControllerTitleColor;

+ (UIColor *)onstarLightGray;
//C4C4C9
+ (UIColor *)onstarButtonDisableColor;
//107FE0
+ (UIColor *)onstarButtonEnableColor;
//59708A
+ (UIColor *)onstarTextFontColor;

//#4E5059
+ (UIColor *)onstarBlackColor;
//#28292f
+ (UIColor *)defaultLabelBlack;
//#828389
+ (UIColor *)defaultSubLabelBlack;
//#6896ED
+ (UIColor *)defaultLabelLightBlue;

+ (int)getUserLevelWithDonationIntegral:(NSString*)donationIntegralStr    ;
#pragma mark - button state
+ (void)setButtonStateDisableWithButton:(UIButton *)button;
+ (void)setButtonStateDisableWithButton:(UIButton *)button withColor:(UIColor *)apColor  ;
+ (void)setButtonStateEnableWithButton:(UIButton *)button;
+ (UILabel *)onstarLabelWithFrame:(CGRect )rect fontSize:(CGFloat)fontSize;

/**
 清除登录界面用户信息
 */
+ (void)clearLoginUserRecord;

/**
 显示一个自定义对话框，按钮只有一个"知道了"
 @param title_
 @param message_
 @param complete_
 */
+ (void)showCustomAlertWithTitle:(NSString *)title_ message:(NSString *)message_ completeBlock:(CompleteBlock)complete_;

+ (void)showCustomAlertWithTitle:(NSString *)title_ message:(NSString *)message_ cancleButtonTitle:(NSString *)cancleTitle_ otherButtonTitles:(NSArray *)titleArray_ completeBlock:(CompleteBlock)complete_ ;
/**
 显示一个下部有默认安吉星电话的自定义对话框
 @param title_ 标题
 @param message_ 信息
 @param complete_
 @param canceltitle_
 @param otherTitles_
 */
+ (void)showOnstarAlertWithTitle:(NSString *)title_ message:(NSString *)message_ alertModel:(NSInteger)alertModel_ completeBlock:(CompleteBlock)complete_  cancleButtonTitle:(NSString *)canceltitle_ otherButtonTitles:(NSArray *)otherTitles_;
#pragma mark -AES128
/**
 *  加密
 *
 *  @param string 需要加密的string
 *
 *  @return 加密后的字符串
 */
+ (NSString *)AES128EncryptString:(NSString *)string;

/**
 *  解密
 *
 *  @param string 加密的字符串
 *
 *  @return 解密后的内容
 */
+ (NSString *)AES128DecryptString:(NSString *)string;
#pragma mark - 登录相关
/**
 从数据库中获取profile对象缓存

 @return 对象
 */
+ (SOSLoginUserDefaultVehicleVO *)getProfileObjFromDatabase;

/**
 将prole写入数据库
 @param profile profile对象
 */
+ (void)saveProfileObjToDatabase:(SOSLoginUserDefaultVehicleVO *)profile;

///// 是否需要显示实名认证入口
//+ (BOOL)shouldShowVerifyPersonInfo;

//+ (BOOL)isRightLoginStateForNoticeVerifyPersionInfo ;
+ (UIImage *)brandImageWithBrandStr:(NSString *)str;

@end

/**
 客户端显示汉字与服务端存储代码转换
 */
@interface SOSClientAcronymTransverter : NSObject
@property(nonatomic,copy)NSString * clientShow;      //客户端显示内容
@property(nonatomic,copy)NSString * serverSubstitute;//服务端实际提供内容
@end

@interface SOSClientAcronymTransverterCollection : NSObject
@property(nonatomic,strong)NSArray * transArr;
@end
