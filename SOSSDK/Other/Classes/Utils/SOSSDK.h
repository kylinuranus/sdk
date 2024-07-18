//
//  SOSUtils.h
//  SOSSDK
//
//  Created by onstar on 2018/1/2.
//

#import <Foundation/Foundation.h>

@interface SOSSDK : NSObject

typedef NS_ENUM(NSInteger, SOSEnv) {
    SOSEnvDeveloperment = 25,   //测试
    SOSEnvRelease   = 2           //生产
};
typedef NS_ENUM(NSInteger, SOSLoginState) {
    SOSSDKLoginStateNone,
    SOSSDKLoginStateSuccess,
    SOSSDKLoginStateFail
};
typedef UIViewController *(^SetLoginViewControllerBlock)(void);


/**
设置环境
 */
@property (nonatomic, assign) SOSEnv env;


/**
 buick登录导航控制器
 note:若调用须先设置'sos_setLoginVc'
 */
@property (nonatomic, weak, readonly) UINavigationController *buickLoginViewController;

    
    
    

#pragma mark --functions
/**
 单例
 */
+ (instancetype)shareInstance;



///**
// 当前sos登录状态
// note:若需要可监听值改变
// */
@property (nonatomic) SOSLoginState loginState;
//
/**
 设置登录控制器 传入登录vc供SOS使用

 @param setLoginViewControllerBlock SetLoginViewControllerBlock对象
 note:类型为'UIViewController'
 */
    
+ (void)sos_setLoginVc:(SetLoginViewControllerBlock)setLoginViewControllerBlock;


/**
 登录时调用
 @param ticket 登录使用ticket
 @param idp 登录idpuserID
 */
+ (void)sos_loginByTicket:(NSString *)ticket
                idpUserId:(NSString *)idp;

/**
 登录时调用
 @param ticket 登录使用ticket
 @param idp 登录idpuserID
 */
+ (void)sos_loginByTicket:(NSString *)ticket
                idpUserId:(NSString *)idp
                loginStatusCallBack:(void(^)(SOSLoginState type))loginStateChangeCallBack;

/**
 退出登录调用
 note:buick退出时需同时调用
 */
+ (void)sos_logOut;


/**
 获得SOS注册页面

 @return 注册vc
 */
+ (UIViewController *)sos_getRegisterViewController;


/**
 获得SOS车况界面
 如果返回nil，使用自定义界面
 */
+ (nullable UIViewController *)sos_getVehicleCondationViewControllerWithController:(UIViewController*)caller;


/**
  显示安吉星首页

 @param dismissBlock 回到buick首页时回调
 */
+ (void)sos_showOnstarModuleWithDismissBlock:(void(^)(void))dismissBlock ;


/**
 安吉星 初始化 -主要是凯迪在用,别克不用
 */
+ (void) sos_initApp;
/**
 回到buick首页
 */
+ (void)sos_dismissOnstarModule ;




//keys

//微信
+ (NSString *)wxKey;

//高德
+ (NSString *)mapKey ;

//OCR
+ (NSString *)idCardKey ;


@end
