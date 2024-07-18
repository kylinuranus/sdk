//
//  LoginManage.h
//  Onstar
//
//  Created by Shoujun Xue on 9/26/12.
//  Copyright (c) 2012 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppGroupHeader.h"
#import <UIKit/UIKit.h>
#import "DataObject.h"

//用户第一次登录
#define USER_FIRST_LOGIN  @"userLogin_first"
//当前用户当前车是否第一次登录
#define USER_FIRST_LOGIN_vin  @"userLogin_first_vin"

typedef enum {
    LOGIN_RESULT_NON                          = 0,
    LOGIN_RESULT_ERROR                        = 1,
    LOGIN_RESULT_CANCEL                       = 2,
    LOGIN_RESULT_TOKENSUCCESS                 = 9,//登录成功

}LOGIN_RESULT_TYPE;
//登录状态
typedef enum {
    
    LOGIN_STATE_NON                      = 0,  //未登录
    
    //第一步
    /// 加载token中
    LOGIN_STATE_LOADINGTOKEN                  = 1,
    /// 加载token完成
    LOGIN_STATE_LOADINGTOKENSUCCESS           = 2,
    /// 加载token失败
    LOGIN_STATE_LOADINGTOKENFAIL              = -1,

    //第二步
    /// 加载用户基本数据中
    LOGIN_STATE_LOADINGUSERBASICINFO        = 3,
    /// 加载用户基本数据成功
    LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS = 4,
    /// 加载用户基本数据失败
    LOGIN_STATE_LOADINGUSERBASICINFOFAIL    = -2,
    
    //第三步
    /// 加载车辆Commands中
    LOGIN_STATE_LOADINGVEHICLECOMMANDS         = 5,
    /// 加载车辆Commands成功
    LOGIN_STATE_LOADINGVEHICLECOMMANDSESUCCESS = 6,
    /// 加载车辆Commands失败
    LOGIN_STATE_LOADINGVEHICLECOMMANDSFAIL     = -3,
    
    //第四步
    /// 加载车辆信息和权限中
    LOGIN_STATE_LOADINGVEHICLEPRIVILIGE        = 7,
    /// 加载车辆信息和权限成功
    LOGIN_STATE_LOADINGVEHICLEPRIVILIGESUCCESS = 8,
    /// 加载车辆信息和权限失败
    LOGIN_STATE_LOADINGVEHICLEPRIVILIGEFAIL    = -4,
    
//    LOGIN_STATE_ALLFINISH                      = 10
}LOGIN_STATE_TYPE;

typedef enum {
    LOGIN_LOADING_USER_PROFILE_NON = 0   ,//正常操作
    LOGIN_LOADING_USER_PROFILE_INPROGRESS,//用户点击提示：您的信息正在更新，请稍后重试
    LOGIN_LOADING_USER_PROFILE_FAILURE    //用户点击提示：您的信息获取失败，请重新登录或联系安吉星客服
}LOGIN_LOADING_USER_PROFILE_TYPE;

typedef enum {
    LOGIN_TYPE_NORMAL=0,
    LOGIN_TYPE_AUTO_SEND_TBT,
}LOGIN_TYPE;

typedef enum     {
    PIN_CHECK_SUCCESS,
    PIN_CHECK_FAILED,
    PIN_MORE_THAN_3,
    PIN_ERROR_OR_EMPTY,
    PIN_LOGIN_INFO_EMPTY,
    NETWORK_ERROR,
    PIN_NEED_RELOGIN
}PIN_CHECK_TYPE;

typedef enum     {
    ACCESS_TOKEN_LEVEL_NORMAL        = 0,
    ACCESS_TOKEN_LEVEL_UPGRADED      = 1,
} ACCESS_TOKEN_LEVEL;

/// 验证 PIN 码结果
typedef enum {
    /// 验证成功
    SOSVerifyPinResultCode_Success = 0,
    /// 验证失败,不超过 10 次
    SOSVerifyPinResultCode_Fail = 1,
    /// 验证失败超过 10 次,被锁
    SOSVerifyPinResultCode_Lock = 2
}	SOSVerifyPinResultCode;

#define ForceUpagrade           10001
#define AccessTokenExpired      10002


@interface LoginManage : NSObject{
    BOOL originTabBarHidden;
    BOOL originNavBarHidden;
    BOOL originNavBarInfoButtonStatus;
    
    __weak UIViewController *parentViewController;
    __weak UIViewController *subViewController;
    NSString        *pinCode;
    NSString *pinCodeForFingerPrint;
    NSString        *errorMessage;
//    NNSubscriber *profile;
    SOSLoginUserDefaultVehicleVO * newProfile;
    NSTimer *tokenMonitorTimer;
    
    dispatch_queue_t monitorQueue;
    dispatch_source_t refreshTokenTimer;
    dispatch_queue_t refreshQueue;
}
@property (nonatomic , strong)NSMutableArray * failedMainInterfaceArray;//收集手动登录时候失败的主接口
@property (nonatomic, assign) LOGIN_LOADING_USER_PROFILE_TYPE loadingUserProfile;
@property (atomic) LOGIN_RESULT_TYPE loginResult;
@property (nonatomic,assign) LOGIN_STATE_TYPE loginState;
@property (atomic) LOGIN_TYPE loginType;
#if __has_include("SOSSDK.h")
@property (weak, nonatomic)UINavigationController *loginNav;
#else
@property (strong, nonatomic)UINavigationController *loginNav;
#endif
@property (strong, nonatomic)NSString   *pinCode;
//@property (strong, nonatomic)NSDate     *loginStartTime;
//@property (strong, nonatomic)NSDate     *loginEndTime;
@property (strong, nonatomic)NSString   *errorCode;
@property (strong, nonatomic)NSString   *errorMessage;
@property (copy,nonatomic)void (^Oncompletion)(BOOL);
@property (copy,nonatomic)void (^sdkStateCallBack)(LOGIN_STATE_TYPE type);
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *tokenType;
@property (nonatomic, strong) NSString *idToken;
@property (nonatomic, strong) NSString *expires_in;
@property (nonatomic, strong) NSString *scope;
@property (weak, nonatomic, readonly) NSString *authorization;
@property (nonatomic, strong) NSString *loginPassword;
@property (nonatomic, assign) ACCESS_TOKEN_LEVEL accessTokenLevel;
@property (nonatomic, strong) NSDate *tokenExpireDate;
@property (nonatomic, assign) NSTimeInterval tokenExpireTimeInterval;
@property (nonatomic, assign) NSTimeInterval enterBackgroundTimeInterval;
@property (nonatomic, assign) BOOL isRefreshingAccessToken;
@property (nonatomic, assign) BOOL isLoginManual;//是否是手动登陆
@property (nonatomic, assign) BOOL isClickShowOnstarModule;//是否是点击进来安吉星的
@property (nonatomic, assign) BOOL isSignAgreementState;//是否签署协议成功

@property (nonatomic, assign) NSInteger isClickShowOnstarModuleCount;//点击安吉星入口次数

@property (nonatomic, assign) BOOL continueShowLoading;//切车会做重新登录，重新登录会调用resetLoginNav方法导致切车未完全完成结果loading界面dismiss
@property (nonatomic, assign) BOOL needLoadCache; //是否使用缓存数据，自动登录使用，false代表是手动登录，不使用缓存
//@property (nonatomic, assign) BOOL changeVehicleUseCache; //切车是否使用缓存数据，登录过程根据needLoadCache判断是否使用缓存数据，切车肯定不使用缓存
@property (nonatomic, assign) BOOL dependenceIllegal; //点击后检测依赖条件，依赖条件代表登录4步中依赖哪一步数据,如果依赖条件合法，进行下一步判断，否则阻断进行提示,默认是NO，代表是合法的，所有需要检测的地方需要设置此变量
@property (nonatomic, assign) BOOL ignoreConnectingVehicleAlert; //是否忽略“连接车辆中”提示

@property (nonatomic, assign) BOOL illegalWarningBackHomePage;//是否提示回到首页刷新

@property (nonatomic, assign) NSTimeInterval loginStartTimeIntervel;//开始登录


+ (LoginManage *)sharedInstance;

/// 检测登录状态
- (void)checkAndShowLoginViewWithFromViewCtr:(UIViewController *)fromViewController1 andTobePushViewCtr:(UIViewController *)tobePushViewController  completion:(void (^)(BOOL finished))completion;

///只检测登录是否 不push 其他 VC
- (void)checkAndShowLoginViewWithFromViewCtr:(UIViewController *)fromViewController1 completion:(void (^)(BOOL finished))completion DEPRECATED_MSG_ATTRIBUTE("请使用checkAndShowLoginViewFromViewController");

/// 检测登录状态 (传入 依赖条件/是否显示连接车辆中弹框)
- (void)checkAndShowLoginViewFromViewController:(UIViewController *)fromViewController withLoginDependence:(BOOL)dependence showConnectVehicleAlertDependence:(BOOL)isConnectVehicle completion:(void (^)(BOOL finished))completion;

/**
 如果主数据某一步加载失败，提示用户返回到主页下拉刷新
 @param fromViewController1
 @param dependence 提示回到主页条件，条件满足才可以进入，否则提示回主页
 @param isConnectVehicle 提示正在链接车辆alert
 @param completion
 */
- (void)checkAndShowRefreshWarningAlertFromViewCtr:(UIViewController *)fromViewController1 withLoginDependence:(BOOL)dependence showConnectVehicleAlertDependence:(BOOL)isConnectVehicle completion:(void (^)(BOOL finished))completion;

- (void)doLogout;
/**
 present方式弹出登录界面
 @param viewController 调起登录界面的VC
 */
- (void)presentLoginNavgationController:(UIViewController *)viewController;
- (void)oAuthLoginWithUserName:(NSString *)userName password:(NSString *)password;
- (void)doAutoLogin;

- (void)autoLoginIfNeeded;
//- (void)loginFromViewController:(UIViewController *)fromVC withUserName:(NSString *)userName password:(NSString *)password;
- (void)loginFromViewController:(UIViewController *)fromVC withUserName:(NSString *)userName password:(NSString *)password stateWatcher:(void(^)(LOGIN_STATE_TYPE type))stateCallback;


/**
 自动刷新接口
 @param fromLogin 是否是登录过程刷新调用token，如果不是则代表是token过期，此时只需刷新token，无需调用其他登录接口
 @return
 */
- (BOOL)oAuthReAuthToken:(BOOL)forLogin;
- (NSString *)oauthUpgrade:(NSString *) pincode;
- (NSString *)oAuthPinReAuthToken:(NSString *)code;
- (NSString *)upgradeToken:(NSString *)inputPin;

- (void)dismissLoginNav;
- (void)dismissLoginNavAnimated:(BOOL)animated;

#pragma mark 重新创建登录页面
- (void)relocaLoginNav;
- (void)upgradeToken;

- (void)saveToken:(NSString *)idToken withScope:(NSString *)scope;
- (void)loadCachedToken;
- (BOOL)needVerifyPin;
- (NSTimeInterval)accessTokenTimeLeft;
- (void)restartMonitorTokenInSec:(NSInteger)delaySec;
- (void)stopMonitorToken;
- (void)logoutFromSever;
/**
 保存suite接口信息
 @param responseStr
 */
- (void)saveUserBasicInfo:(NSString *)responseStr;
/**
 保存token接口信息
 @param responseStr
 */
- (void)saveTokenOnstarAccount:(NSString *)responseStr;

/**
 验证pin码是否是后6位,如果是默认后6位,则要更改默认PIN码

 @param govid 证件号
 @param complete_
 */
//- (void)checkPinWithGovId:(NSString *)govid
//                 Complete:(void (^)(BOOL success, NSInteger errorCode ,NSString *failResponse))complete_ ;
- (BOOL)isLoadingTokenReady;
- (BOOL)isLoadingUserBasicInfoReady;
- (BOOL)isLoadingUserBasicInfoReadyOrUnLogin;
- (BOOL)isLoadingVehicleCommandsReady;
- (BOOL)isLoadingMainInterfaceReady;
- (BOOL)isLoadingMainInterfaceFail;
- (BOOL)isLoadingMainInterfaceReadyOrUnlogin;
- (void)reLoadMainInterface;
- (BOOL)isInLoadingMainInterface;

- (void)loadVehiclePrivilegeFromCache:(BOOL)useCache;


- (void)loadTCPSNeedConfirm;
/**
 根据类型加载协议
 */
-(void)loadTCPSNeedConfirmTypes:(NSArray *)types;
/**
 增加一个homepage 弹出View行为
 @param popAction
 */
- (void)addPopViewAction:(void (^)(void))popAction;

/**
 执行下一个弹出View行为
 */
- (void)nextPopViewAction;

//立即执行loginSuccessAction,若未登录则在登录后执行 ,不输入密码退出登录页面或登录成功执行过后置为nil
@property (nonatomic, copy) void(^loginSuccessAction)(void);
@property (nonatomic, assign) BOOL loginSuccessActionActivity;//为YES才可执行(弹出登录页面直接X根据此状态清除action)


- (void)addTouchIdObserver;

@end
