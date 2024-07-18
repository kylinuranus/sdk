
//  LoginManage.m
//  Onstar
//
//  Created by Shoujun Xue on 9/26/12.
//  Copyright (c) 2012 Shanghai Onstar. All rights reserved.
//

#import "OpenUDID.h"
#import "LoadingView.h"
#import "CustomerInfo.h"
#import "NSString+JWT.h"
#import "AppPreferences.h"
#import "SOSBBWCEduWebVC.h"
#import "SOSCheckRoleUtil.h"
#import "ServiceController.h"
#import "SOSLoginDbService.h"
#import "SOSKeyChainManager.h"
#import "ViewControllerLogin.h"
#import "ClientTraceIdManager.h"
#import "SOSLoginUserDbService.h"
#import "SOSRegisterInformation.h"
#import "PushNotificationManager.h"
#import "CustomNavigationController.h"
#import "SOSTripPOIVC.h"
#import "AccountInfoUtil.h"
#import "SOSBiometricsManager.h"
#import "ViewControllerFingerprintpw.h"
#import "RegisterUtil.h"
#import "SOSEditQAPinViewController.h"
#import "SOSCardUtil.h"
#import "SOSAgreement.h"
#import "SOSAgreementAlertView.h"
#ifndef SOSSDK_SDK
#import "SOSMusicPlayer.h"
#import "SOSIMLoginManager.h"
#endif
#import "SOSHomeTabBarCotroller.h"
//#import "SOSYearReportView.h"
#import "SOSSimplePopView.h"
#import "SOSGreetingManager.h"

#import "SOSUserLocation.h"
#import "SOSPhoneBindController.h"
#import "CollectionToolsOBJ.h"
#import "SOSGeoModifyMobileVC.h"
#if __has_include("SOSSDK.h")
#import "SOSSDK.h"
#endif
//#import "SOSFlutterDB.h"

#import "SOSCheckLawAgreementView.h"
#import "SOSFlexibleAlertController.h"

#define NEED_POP_TO_ROOT        0
#define NEED_POP                1
#define NEED_RELOGIN            2
#define SAFE_THRESHOLD          240 //240秒
static NSString *const keyLoginResult        = @"loginResult";
static char     *const keyLoginResultContext = "login result context";
static NSString *const keyLoginState         = @"loginState";
static NSString *const sosKeyHasLoginWithUsername   = @"sosHasLoginWithUsername";
extern NSString *kSOSServiceOptState;
//NSNotificationName const sosKNeedPopNotify = @"sosKNeedPopNotify";

@class ViewControllerLogin;

@interface LoginManage()     {
    UIViewController *fromViewController;
    NSString *currentUserName;
    NSString *tempPwd; //存储密码
    NSOperationQueue * popQueue;
}
- (void)initalLoginStatus;
- (void)checkLoginInBackGround;

/**
 dismiss登录界面
 @param viewController
 */
- (void)dismissLoginNavgationController:(UIViewController *)viewController;
- (void)doCompletionOnMainThread:(NSNumber *)condition;
@end

@implementation LoginManage
//@synthesize loginState;
@synthesize loginResult;
@synthesize loginType;
@synthesize pinCode;
//@synthesize loginStartTime, loginEndTime;
@synthesize errorMessage;

static LoginManage * loginManage = nil;

void (^LoginCompletion)(BOOL);

+ (LoginManage *)sharedInstance
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        loginManage = [[self alloc] init];
        [loginManage addObserver:loginManage forKeyPath:keyLoginResult options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:keyLoginResultContext];
        [loginManage addObserver:loginManage forKeyPath:keyLoginState options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:keyLoginResultContext];
    });
    return loginManage;
}

- (void)initalLoginStatus
{
    self.loginState = LOGIN_STATE_NON;
    loginResult = LOGIN_RESULT_NON;
}

- (void)dealloc
{
    [loginManage removeObserver:loginManage forKeyPath:keyLoginResult];
    [loginManage removeObserver:loginManage forKeyPath:keyLoginState];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([change objectForKey:NSKeyValueChangeNewKey] == [change objectForKey:NSKeyValueChangeOldKey]) {
        if ([keyPath isEqualToString:@"loginResult"]) {
            if( loginResult == LOGIN_RESULT_CANCEL){
                completionCondition = NO;
                double delayInSeconds = 0.6;//王健功修改
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self doCompletionOnMainThread:[NSNumber numberWithBool:completionCondition]];
                });
            }
        }
        return;
    }
    if ([keyPath isEqualToString:@"loginResult"]) {
        switch (loginResult) {
            case LOGIN_RESULT_NON:
                [self performSelectorOnMainThread:@selector(resetLoginNavigationController) withObject:nil waitUntilDone:NO];
                completionCondition = NO;
                return;
                break;
            case LOGIN_RESULT_CANCEL:
            {
                completionCondition = NO;
                break;
            }
            case LOGIN_RESULT_TOKENSUCCESS:
                [self performSelectorOnMainThread:@selector(dismissLoginNavgationController:) withObject:parentViewController waitUntilDone:NO];
                completionCondition = YES;
                break;
            case LOGIN_RESULT_ERROR:
                [self performSelectorOnMainThread:@selector(resetLoginNavigationController) withObject:nil waitUntilDone:NO];
                completionCondition = NO;
                break;
            default:
                break;
        }
        // if the data fresh request in the que, it wiil be first
        double delayInSeconds = 0.6;//王健功修改
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self doCompletionOnMainThread:[NSNumber numberWithBool:completionCondition]];
        });
    } else if ([keyPath isEqualToString:@"loginState"]) {
        switch (self.loginState) {
            case LOGIN_STATE_NON:
            case LOGIN_STATE_LOADINGTOKENSUCCESS:
                [self resetLoginNavigationController];
                break;
            default:
                break;
        }
    }
}
- (void)resetLoginInstance
{
    
    [SOSSDK shareInstance].loginState = SOSSDKLoginStateNone;
    [[CustomerInfo sharedInstance] logout];
    self.loginState = LOGIN_STATE_NON;
    self.loginResult = LOGIN_RESULT_NON;
    self.loadingUserProfile = LOGIN_LOADING_USER_PROFILE_NON;
    [self setIdToken:nil];
    [self setAccessToken:nil];
    [self setScope:nil];
    self.needLoadCache = NO;
    [SOSKeyChainManager clearLoginTokenScop];
}
#pragma mark - 登出
- (void)doLogout
{
#ifndef SOSSDK_SDK
    //需要用到userId,优先调用清理数据
    [[SOSMusicPlayer sharedInstance] clearData];
    [[SOSIMLoginManager sharedManager] clearData];
#endif
    [self clearPopQueue];
//#if __has_include("SOSSDK.h")
//    [SOSSDK shareInstance].loginState = SOSSDKLoginStateNone;
//    if (!SOS_ONSTAR_WINDOW.hidden) {
//        [Util toastWithMessage:@"请重新进入安吉星!"];
//    }
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        if (!SOS_ONSTAR_WINDOW.hidden) {
//               [SOSSDK sos_dismissOnstarModule];
//           }
//    });
//   
//#endif
    [self logoutFromSever];
    [self resetLoginInstance];
    [self stopMonitorToken];
    pinCode = nil;
    [[ServiceController sharedInstance] cleanUpVehicleSevices];
    
//    [[[SOSNetworkOperation alloc] init] cancelAllRequest];

    NSUserDefaults *appGroupDefaults = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_IDENTIFIER];
    [appGroupDefaults setObject:@"" forKey:APP_GROUP_PIN_CODE];
    [appGroupDefaults synchronize];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.failedMainInterfaceArray removeAllObjects];
    
}

- (void)checkAndShowLoginViewWithFromViewCtr:(UIViewController *)fromViewController1 andTobePushViewCtr:(UIViewController *)tobePushViewController completion:(void (^)(BOOL finished))completion     {
    if ([Util isToastLoadUserProfileFailure])	return;
    parentViewController = fromViewController1;
    if (tobePushViewController != nil) {
        subViewController = tobePushViewController;
    } else {
        subViewController = nil;
    }
    //进入条件未满足
    if (_dependenceIllegal) {
        //进入条件未满足
        //9.0逻辑,如果顶部提示条显示中,则不显示中间Toast;
        //如果顶部提示条被用户X掉了,则不显示中间Toast,显示顶部条
        
        SOSHomeTabBarCotroller *tabVC = (SOSHomeTabBarCotroller *) [SOS_APP_DELEGATE fetchRootViewController];
        if ([tabVC promptViewIsShowing]) {
            //UI新增需求
            if (tabVC.promptView.style == SOSTopPromptStyleRefreshing) {
                [Util showHUDWithStatus:@"信息获取中，请稍候"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [Util dismissHUD];
                });
            }else if (tabVC.promptView.style == SOSTopPromptStyleRefreshFailed) {
                [Util showErrorHUDWithStatus:@"操作失败" subStatus:NSLocalizedString(@"NeedRefreshMainData", nil)];
            }
        }else {
            dispatch_async_on_main_queue(^{
                tabVC.promptView.style = SOSTopPromptStyleRefreshFailed;
            });
        }

        _dependenceIllegal = NO;
        return;
    }
   
    //登录中
    if ([self isInLoadingMainInterface]) {
        if (_ignoreConnectingVehicleAlert) {
            _Oncompletion = [completion copy];
            [self performSelectorOnMainThread:@selector(doCompletion:) withObject:@(YES) waitUntilDone:YES];
            _ignoreConnectingVehicleAlert = NO;
            return;
        }
#ifndef SOSSDK_SDK
        [Util showAlertWithTitle:nil message:NSLocalizedString(@"ConnectingVehicle", nil) completeBlock:nil];
#endif
        return;
    }
    if (self.loginState == LOGIN_STATE_NON) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentLoginNavgationController:parentViewController];
        });
        return;
    }
    _Oncompletion = [completion copy];
    [self performSelectorOnMainThread:@selector(doCompletion:) withObject:@(YES) waitUntilDone:YES];
}

/**
 Default Dependence :LOGIN_STATE_LOADINGTOKEN
 @param fromViewController1
 @param completion
 */
- (void)checkAndShowLoginViewWithFromViewCtr:(UIViewController *)fromViewController1 completion:(void (^)(BOOL finished))completion		{
    LoginCompletion = [completion copy];
    parentViewController = fromViewController1;
    if (_dependenceIllegal) {
        SOSHomeTabBarCotroller *tabVC = (SOSHomeTabBarCotroller *) [SOS_APP_DELEGATE fetchRootViewController];
        if ([tabVC promptViewIsShowing]) {
            //UI新增需求
            if (tabVC.promptView.style == SOSTopPromptStyleRefreshing) {
                [Util showHUDWithStatus:@"信息获取中，请稍候"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [Util dismissHUD];
                });
            }else if (tabVC.promptView.style == SOSTopPromptStyleRefreshFailed) {
                [Util showErrorHUDWithStatus:@"操作失败" subStatus:NSLocalizedString(@"NeedRefreshMainData", nil)];
            }
        }else {
            dispatch_async_on_main_queue(^{
                tabVC.promptView.style = SOSTopPromptStyleRefreshFailed;
            });
        }

        _dependenceIllegal = NO;
        return;
    }
    if (self.loginState == LOGIN_STATE_NON) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentLoginNavgationController:parentViewController];
        });
        
    }	else if(self.loginState == LOGIN_STATE_LOADINGTOKEN)  {
#ifndef SOSSDK_SDK
        [Util showAlertWithTitle:nil message:NSLocalizedString(@"ConnectingVehicle", nil) completeBlock:nil];
#endif
    }	else {
        LoginCompletion(YES);
        return;
    }
}
//代替上面这个方法
- (void)checkAndShowLoginViewFromViewController:(UIViewController *)fromViewController withLoginDependence:(BOOL)dependence showConnectVehicleAlertDependence:(BOOL)isConnectVehicle completion:(void (^)(BOOL finished))completion	{
    parentViewController = fromViewController;
    if (self.loginState == LOGIN_STATE_NON) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentLoginNavgationController:parentViewController];
        });
        return;
    }
#ifndef SOSSDK_SDK
    if (isConnectVehicle) {
        [Util showAlertWithTitle:nil message:NSLocalizedString(@"ConnectingVehicle", nil) completeBlock:nil];
        return;
    }
#endif
    //进入条件未满足
    //9.0逻辑,如果顶部提示条显示中,则不显示中间Toast;
    //如果顶部提示条被用户X掉了,则不显示中间Toast,显示顶部条
    if (!dependence) {
        SOSHomeTabBarCotroller *tabVC = (SOSHomeTabBarCotroller *) [SOS_APP_DELEGATE fetchRootViewController];
        if ([tabVC promptViewIsShowing]) {
            //UI新增需求
            if (tabVC.promptView.style == SOSTopPromptStyleRefreshing) {
                [Util showHUDWithStatus:@"信息获取中，请稍候"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [Util dismissHUD];
                });
            }else if (tabVC.promptView.style == SOSTopPromptStyleRefreshFailed) {
                [Util showErrorHUDWithStatus:@"操作失败" subStatus:NSLocalizedString(@"NeedRefreshMainData", nil)];
            }
        }else {
            dispatch_async_on_main_queue(^{
                tabVC.promptView.style = SOSTopPromptStyleRefreshFailed;
            });
        }
       
        return;
    }

    
    _Oncompletion = [completion copy];
    [self performSelectorOnMainThread:@selector(doCompletion:) withObject:@(YES) waitUntilDone:YES];
}

- (void)checkAndShowRefreshWarningAlertFromViewCtr:(UIViewController *)fromViewController1 withLoginDependence:(BOOL)dependence showConnectVehicleAlertDependence:(BOOL)isConnectVehicle completion:(void (^)(BOOL finished))completion;
{
    parentViewController = fromViewController1;
#ifndef SOSSDK_SDK
    if (isConnectVehicle) {
        [Util showAlertWithTitle:nil message:NSLocalizedString(@"ConnectingVehicle", nil) completeBlock:nil];

        return;
    }
#endif
    //进入条件未满足
    //9.0逻辑,如果顶部提示条显示中,则不显示中间Toast;
    //如果顶部提示条被用户X掉了,则不显示中间Toast,显示顶部条
    if (!dependence) {
        SOSHomeTabBarCotroller *tabVC = (SOSHomeTabBarCotroller *) [SOS_APP_DELEGATE fetchRootViewController];
        if ([tabVC promptViewIsShowing]) {
            //UI新增需求
            if (tabVC.promptView.style == SOSTopPromptStyleRefreshing) {
                [Util showHUDWithStatus:@"信息获取中，请稍候"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [Util dismissHUD];
                });
            }else if (tabVC.promptView.style == SOSTopPromptStyleRefreshFailed) {
                [Util showErrorHUDWithStatus:@"操作失败" subStatus:NSLocalizedString(@"NeedRefreshMainData", nil)];
            }

        }else {
            dispatch_async_on_main_queue(^{
                tabVC.promptView.style = SOSTopPromptStyleRefreshFailed;
            });
        }

        return;
    }

    if (self.loginState == LOGIN_STATE_NON) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentLoginNavgationController:parentViewController];
        });
        return;
    }
    _Oncompletion = [completion copy];
    [self performSelectorOnMainThread:@selector(doCompletion:) withObject:@(YES) waitUntilDone:YES];
}

BOOL completionCondition = YES;
- (void)checkLoginInBackGround  {
    [self initalLoginStatus];
    [self performSelectorOnMainThread:@selector(presentLoginNavgationController:) withObject:parentViewController waitUntilDone:YES];
}

- (void)resetLoginNavigationController     {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!_continueShowLoading) {
            [Util dismissHUD];
            //        [[LoadingView sharedInstance] stop];
        }
        if (_continueShowLoading) {
            //切车时候，做重新登录
            _continueShowLoading = NO;
        }
        [_loginNav popToRootViewControllerAnimated:NO];
        
    });
    
    
}

- (void)presentLoginNavgationController:(UIViewController *)viewController {
//    if (SOS_ONSTAR_PRODUCT) {
    if (!_loginNav) {
        [self relocaLoginNav];
    }
//        if (!_loginNav.topViewController || ![_loginNav.topViewController isKindOfClass:[ViewControllerLogin class]]) {
//            [self relocaLoginNav];
//        }
//    }else {
//        NSAssert(_loginNav, @"登录页面不能为空!");
//    }
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        NSLog(@"---%@",_loginNav.navigationController);
        NSLog(@"---%@",_loginNav.navigationController.childViewControllers);
        id loginVC1 = [_loginNav.navigationController.childViewControllers firstObject];
        UINavigationController *tempVC = (UINavigationController *)viewController;
        for (UIViewController *vc in tempVC.viewControllers) {
            if ([vc isKindOfClass:[loginVC1 class]])   {
                [tempVC popToViewController:vc animated:YES];
                return;
            }
        }
    }
    if (!_loginNav.presentingViewController) {
        if (viewController.presentedViewController) {
            [viewController dismissViewControllerAnimated:YES completion:^{
              
            }];
            [viewController presentViewController:_loginNav animated:YES completion:nil];
        }else{
            [viewController presentViewController:_loginNav animated:YES completion:nil];
        }
        
    }else{
        NSLog(@"登录界面已经在显示---%@--",_loginNav);
        if (_loginNav.viewControllers.count >1) {
            [_loginNav popToRootViewControllerAnimated:YES];
        }
    }
}

- (void)dismissLoginNav     {
    [self dismissLoginNavAnimated:NO];
}

- (void)dismissLoginNavAnimated:(BOOL)animated {
    [_loginNav dismissViewControllerAnimated:animated completion:^{
        _loginNav = nil;
    }];
}

- (void)dismissLoginNavgationController:(UIViewController *)viewController     {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (viewController && [viewController isKindOfClass:[UIViewController class]]) {
            [viewController dismissViewControllerAnimated:NO completion:^{
                _loginNav = nil;
            }];
        }
        if (_loginNav) {
            [_loginNav dismissViewControllerAnimated:NO completion:^{
                _loginNav = nil;
            }];
            [self resetLoginNavigationController];
        }
    });
    
}

- (void)doCompletionOnMainThread:(NSNumber *)condition     {
    if ([condition boolValue]) {
        [CustomerInfo sharedInstance].hasLogin = YES;
        
    } else {
        if (loginResult == LOGIN_RESULT_ERROR)
        {
            // when error happened in login process clear password and remember me flag
//            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:NEED_REMEMBER_ME];
//            [[NSUserDefaults standardUserDefaults] removeObjectForKey: PREFERENCE_PASSWORD];
//            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    [self doCompletion:condition];
}

- (void)doCompletion:(NSNumber *)condition     {
    [CustomerInfo sharedInstance].needShowAlert = YES;

    if (_Oncompletion)	_Oncompletion([condition boolValue]);
    
    if (subViewController != nil && condition.boolValue) {
        [parentViewController.navigationController pushViewController:subViewController animated:YES];
    }
    parentViewController = nil;
    _Oncompletion = nil;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (loginManage == nil) {
            loginManage = [super allocWithZone:zone];
            return loginManage;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id) init {
    self = [super init];
    if (self) {
        
        refreshQueue = dispatch_queue_create("RefreshTokenQueue", 0);
    }
    return self;
}
- (UINavigationController *)loginNav {
    if (!_loginNav) {
        if (SOS_ONSTAR_PRODUCT) {
            ViewControllerLogin *viewLogin = [[ViewControllerLogin alloc] initWithNibName:@"ViewLogin" bundle:nil];
//            viewLogin.modalPresentationStyle = UIModalPresentationFullScreen;
//            viewLogin.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            _loginNav = [[CustomNavigationController alloc] initWithRootViewController:viewLogin];
//            _loginNav.modalPresentationStyle = UIModalPresentationFullScreen;
        }
    }
    return _loginNav;
}
//- (void)setloginNav:(UINavigationController *)loginNavigation
//{
//    loginNav = loginNavigation;
//}
#pragma mark 重新创建登录页面
- (void)relocaLoginNav
{
#if __has_include("SOSSDK.h")
    id buickLoginViewController = [SOSSDK shareInstance].buickLoginViewController;
//    NSAssert(buickLoginViewController, @"登录页面不能为空!");
//    NSAssert([buickLoginViewController isKindOfClass:[UINavigationController class]], @"buickLoginViewController is not kind of UINavigationController");
    _loginNav = buickLoginViewController;
#else
    UIViewController *viewLogin = [[ViewControllerLogin alloc] initWithNibName:@"ViewLogin" bundle:nil];
    viewLogin.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    _loginNav = [[CustomNavigationController alloc] initWithRootViewController:viewLogin];
//    _loginNav.modalPresentationStyle = UIModalPresentationFullScreen;
#endif
    
}

- (void)loginFromViewController:(UIViewController *)fromVC withUserName:(NSString *)userName password:(NSString *)password stateWatcher:(void(^)(LOGIN_STATE_TYPE type))stateCallback
{
    parentViewController = fromVC;
    [self oAuthLoginWithUserName:userName password:password];
    currentUserName = userName;
    tempPwd = password;
    if (stateCallback) {
        _sdkStateCallBack = stateCallback;
    }
}
// autologin
- (void)autoLoginIfNeeded     {
//    if ([LoginManage.sharedInstance isLoadingTokenReady]) {
//        return;
//    }
    //如果token接口信息体不为空才可以进行自动登录
    NSString *reslutStr = [[SOSLoginDbService sharedInstance] searchTokenOnstarAccount];
    if (reslutStr.isNotBlank) {
        [[LoginManage sharedInstance] doAutoLogin];
    }
}
- (void)doAutoLogin
{
    [LoginManage sharedInstance].loadingUserProfile = LOGIN_LOADING_USER_PROFILE_NON;
    [self loadCachedToken];
    // 缓存中有IdToken，则不需要用户名密码登录
    if ([_idToken length] > 0) {
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //自动登录使用缓存
            self.needLoadCache = YES;
            [self oAuthReAuthToken:YES];
//        });
    } else {
        [Util hideLoadView];
        [LoginManage sharedInstance].loginState = LOGIN_STATE_NON;
    }
}

- (void)initProfile:(NSString *)responseStr
{
    newProfile = [SOSLoginUserDefaultVehicleVO mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
    if (!newProfile.currentSuite) {
        newProfile.currentSuite = [[SOSOnstarSuiteVO alloc] init];
        newProfile.currentSuite.role = @"visitor";
    }
    //用户信息设置到CustomerInfo
    [[CustomerInfo sharedInstance] setUserBasicInfo:newProfile];
    [CustomerInfo sharedInstance].govid = [newProfile.subscriber governmentId]; //add 8.0
    //原版中获取问候语后通过isExpiredSubscriber字段check包的过期状态
    // 在加载套餐包信息的接口中可获得此信息
//    [CustomerInfo sharedInstance].isExpired = [newProfile expiredSubscriber];
//    [CustomerInfo sharedInstance].userBasicInfo.currentSuite.role = [newProfile.currentSuite role];
    [CustomerInfo sharedInstance].guid = [newProfile.idmUser guid];
//    [CustomerInfo sharedInstance].email = [profile email];
//    [CustomerInfo sharedInstance].isEmptyPhoneNo = ;//add v7.1
//    [CustomerInfo sharedInstance].userBasicInfo.idmUser.mobilePhoneNumber = [newProfile.idmUser mobilePhoneNumber];

//    [CustomerInfo sharedInstance].gaaPhoneNumber = [newProfile.subscriber mobilePhone];//add v7.1
//    [CustomerInfo sharedInstance].appFlag = [newProfile.idmUser appFlag];//add info3
    //原版中legalFlag用于登录后显示info3的弹窗
    //另外有接口查询tcps状态，不在此接口中判断
//    [CustomerInfo sharedInstance].legalFlag = [profile legalFlag];//add info3
    
//    [CustomerInfo sharedInstance].carSharingFlag = [newProfile.ve carSharingFlag];//add info3
    
//    [CustomerInfo sharedInstance].gaaPhoneNumber = [newProfile.subscriber mobilePhone];
//    [CustomerInfo sharedInstance].userBasicInfo.idmUser.lastName = [newProfile.idmUser lastName];
//    [CustomerInfo sharedInstance].userBasicInfo.idmUser.firstName = [newProfile.idmUser firstName];
//    [CustomerInfo sharedInstance].userBasicInfo.idmUser.nickName = [newProfile.idmUser nickName];
    
    [CustomerInfo sharedInstance].ecMobile = newProfile.subscriber.emergencyContact.contact.mobile;
    [CustomerInfo sharedInstance].ecFirstName = newProfile.subscriber.emergencyContact.contact.familyName;
    [CustomerInfo sharedInstance].ecLastName = newProfile.subscriber.emergencyContact.contact.givenName;
    [CustomerInfo sharedInstance].isEcInfoDisplay = newProfile.preference.ecContactDisplay;
    
    NSDictionary *vehicleUnitFeatures = newProfile.currentSuite.vehicle.vehicleUnitFeatures;
    if (vehicleUnitFeatures.count) {
        NSDictionary *valueDic = vehicleUnitFeatures[@"WIFI_SUPPORTED"];
        if (valueDic.count) {
            [CustomerInfo sharedInstance].currentVehicle.wifiSupported = [valueDic[@"value"] boolValue];
        }
    }
    // 刷新 Services 信息
    [[CustomerInfo sharedInstance].servicesInfo getResponseFromSeriverForce:NO complete:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kSOSServiceOptState object:nil];
    }];
    
    [self checkIsDefaultPin:[CustomerInfo sharedInstance].userBasicInfo.subscriber.governmentId];
}


- (void)addLoginSuccessReport	{
    [SOSDaapManager sendActionInfo:Login];
}

- (void)loginTokenSuccess	{
    //token成功，创建一个记录失败接口的数组记录失败接口
    if (!_failedMainInterfaceArray) {
        _failedMainInterfaceArray = [NSMutableArray array];
    }else{
        [_failedMainInterfaceArray removeAllObjects];
    }

    //更新登录状态
    self.loginResult = LOGIN_RESULT_TOKENSUCCESS;
    self.loginState = LOGIN_STATE_LOADINGTOKENSUCCESS;
    
    [SOSDaapManager sendActionInfo:SOS_Login_Success];
    [ServiceController sharedInstance].loginFlagForDataRefresh = YES;
    //登录成功重置ClientTraceId
    [[ClientTraceIdManager sharedInstance] resetClientTraceId];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.needLoadCache) {
            [self loadUserBasicInfoFromCache:YES];
        }else{
            [self loadUserBasicInfoFromCache:NO];
        }
    });
}
#pragma mark -  手动登录
#pragma mark              --用户名密码登录，获取idToken,有效期一年
- (void)oAuthLoginWithUserName:(NSString *)userName password:(NSString *)password      {
#ifndef SOSSDK_SDK
    //手动登录会重置状态,需要检测4G状态下用户开始播歌和试用期提醒,要弹框
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SOSMusicShouldDetectNetwork];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SOSMusicShouldShowTrialAlert];
    [[NSUserDefaults standardUserDefaults] synchronize];
#endif
    self.isLoginManual = true;
    self.loadingUserProfile = LOGIN_LOADING_USER_PROFILE_NON;
    
    self.loginState = LOGIN_STATE_LOADINGTOKEN;
    self.loginSuccessActionActivity = YES;
    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_URL, ONSTAR_API_OAUTH];
    NNOAuthRequest *request = [[NNOAuthRequest alloc] init];
    [request setClient_id:@"REMOTE_LINK_IOS_OAUTH_6"];
    [request setGrant_type:@"password"];
    [request setUsername:userName];

#ifndef SOSSDK_SDK
    NSString * saveKey = [NSString stringWithFormat:@"%@_%@",sosKeyHasLoginWithUsername,userName];
    BOOL hasLogin = UserDefaults_Get_Bool(saveKey);
    if (hasLogin) {
        [request setPassword:[[password sha256String] uppercaseString]];
    }else{
        [request setPassword:password];
    }
#else
     [request setPassword:password];
#endif
    [request setScope:@"msso onstar mag_subscriber mag_visitor"]; // mag_visitor for visitor login. 固定的，不用修改
    [request setDevice_id:[OpenUDID value]];
    [request setNonce:[Util generateNonce]];
    [request setTimestamp:[Util generateTimeStamp]];
    [self recordLoginStarTime];
    NSString *inputStr = [request mj_JSONString];
    NSLog(@"======== inputStr decoded string [%@]", inputStr);

    NSString *encodedStr = [NSString jwtEncode:inputStr];
    @weakify(self);
    SOSNetworkOperation *operation = [[SOSNetworkOperation alloc] initWithURL:url params:encodedStr needReturnSourceData:YES successBlock:^(SOSNetworkOperation *operation, id responseStr) {

        @strongify(self);
        if ([responseStr length] > 0) {
            NSString *decodedStr = [NSString jwtDecode:responseStr];
            NSLog(@"======== response decoded string [%@]", decodedStr);
            NNOAuthLoginResponse *oauthResponseObj = [NNOAuthLoginResponse mj_objectWithKeyValues:[Util dictionaryWithJsonString:decodedStr]];
            if (oauthResponseObj.idpUserId.isNotBlank) {
                //如果拿到token中idpid信息，才算token接口成功
                [self setAccessToken:[oauthResponseObj access_token]];//用于请求头的Authorization请求字段"NHFSNTNCQXNqTmQ1L2RYNkRLOGpab21xWnlBaHczb0lNUldYSXpPb25sUTeFZn
                [self setTokenType:[oauthResponseObj token_type]];//用于请求头的Authorization请求字段的Bearer
                [self setAccessTokenLevel:ACCESS_TOKEN_LEVEL_NORMAL];
                [self setExpires_in:     [NSString stringWithFormat:@"%d",  ( [oauthResponseObj.expires_in intValue]/1000)] ];//用于刷新token
                
                //不在使用
                self.tokenExpireDate = [NSDate dateWithTimeIntervalSinceNow:[self.expires_in doubleValue] - SAFE_THRESHOLD];
                self.tokenExpireTimeInterval = [[NSDate date] timeIntervalSince1970] + ([self.expires_in doubleValue] - SAFE_THRESHOLD);
                
                
                [self setIdToken:[oauthResponseObj id_token]];//用于自动登录的assertion请求body
                [self saveFilteredScope:[oauthResponseObj scope]];
                if (self.idToken != nil) {            //保存id token 到本地，用来自动登录
                    [self saveToken:self.idToken withScope:self.scope];
                }
                [[CustomerInfo sharedInstance] setTokenBasicInfo:oauthResponseObj];//保存到本地,供其他页面使用
                
                
                [self saveTokenOnstarAccount:decodedStr];//保存返回值到数据
                NSInteger period = [self->_expires_in integerValue] - SAFE_THRESHOLD;
                [self restartMonitorTokenInSec:period];//定时刷新token
                [self loginTokenSuccess];//更新登录状态
                
                [SOSSDK shareInstance].loginState = SOSSDKLoginStateSuccess;//更新状态,给三大品牌用的

#ifndef SOSSDK_SDK
                if (!hasLogin) {
                    UserDefaults_Set_Bool(YES, saveKey);
                }
#endif

            }else{
                [self loginFail:NSLocalizedString(@"server_error", nil)];
                [self recordLoginTimeWithStatus:NO];

            }
        }
        else{
            [self loginFail:NSLocalizedString(@"server_error", nil)];
            [self recordLoginTimeWithStatus:NO];
        }
        [SOSDaapManager sendSysLayout:[LoginManage sharedInstance].loginStartTimeIntervel endTime:[[NSDate date] timeIntervalSince1970] interfaceStatusCode:[NSString stringWithFormat:@"%ld",operation.statusCode] funcId:Login_token];

    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        NSString *errorCode = [dic objectForKey:@"code"]?[dic objectForKey:@"code"]:[dic objectForKey:@"error"];
        if(errorCode){
            
            [SOSSDK shareInstance].loginState = SOSSDKLoginStateFail;
            if ([errorCode isEqualToString:@"invalid_token"]) {
                
                [SOSSDK shareInstance].loginState = SOSSDKLoginStateNone;
                [self loginFail:NSLocalizedString(@"invalid_token", nil)];
                
                
            }else  if ([errorCode isEqualToString:@"E9004"]) {
                

#if __has_include("SOSSDK.h")
#else
                                                              // 强制升级
                                              [Util showAlertWithTitle:nil message:NSLocalizedString(@"E9004", nil) completeBlock:^(NSInteger buttonIndex) {
                                                  if (buttonIndex) {
                                                      NSString *appURLInAPPStore = @"https://itunes.apple.com/cn/app/an-ji-xing/id437190725?mt=8";
                                                      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appURLInAPPStore]];
                                                      [self resetLoginInstance];
                                                      [ServiceController sharedInstance].loginFlagForDataRefresh = NO;
                                                  }
                                              } cancleButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OkButtonTitle", nil), nil];

#endif
            } else {
                [self loginFail:NSLocalizedString(errorCode, nil)];
            }
        }else{
            [self loginFail:NSLocalizedString(@"server_error", nil)];
        }
        [self recordLoginTimeWithStatus:NO];
        
        [SOSDaapManager sendSysLayout:[LoginManage sharedInstance].loginStartTimeIntervel endTime:[[NSDate date] timeIntervalSince1970] interfaceStatusCode:[NSString stringWithFormat:@"%ld",statusCode] funcId:Login_token];

    }];
    [operation start];
}
#pragma mark  --使用token自动登录
- (BOOL)oAuthReAuthToken:(BOOL)forLogin     {
    
    __block BOOL isSuccess = YES;
    self.isRefreshingAccessToken = YES;
    self.isLoginManual = NO;
    if (forLogin) {
        [LoginManage sharedInstance].loginState = LOGIN_STATE_LOADINGTOKEN;
    }
    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_URL, ONSTAR_API_OAUTH];
    NNOAuthRequest *request = [[NNOAuthRequest alloc] init];
    [request setClient_id:@"REMOTE_LINK_IOS_OAUTH_6"];
    [request setGrant_type:@"urn:ietf:params:oauth:grant-type:jwt-bearer"];
    [request setAssertion:_idToken];
    [request setScope:@"msso onstar mag_subscriber mag_visitor"];
   // [request setScope:self.scope];
    [request setDevice_id:[OpenUDID value]];
    [request setNonce:[Util generateNonce]];
    [request setTimestamp:[Util generateTimeStamp]];
    NSString *inputStr = [request mj_JSONString];
    NSString *encodedStr = [NSString jwtEncode:inputStr];
    [self recordLoginStarTime];
    //    NSDate *startDt = [NSDate date];
    SOSNetworkOperation *operation = [[SOSNetworkOperation alloc] initWithURL:url params:encodedStr needReturnSourceData:YES successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        if ([responseStr length] > 0) {
            NSString *decodedStr = [NSString jwtDecode:responseStr];
            NSLog(@"使用token自动登录%@",decodedStr);
            NNOAuthLoginResponse *response = [NNOAuthLoginResponse mj_objectWithKeyValues:[Util dictionaryWithJsonString:decodedStr]];
            self.accessToken = [response access_token];
            self.tokenType = [response token_type];
            [self saveFilteredScope:[response scope]];
            self.accessTokenLevel = ACCESS_TOKEN_LEVEL_NORMAL;
            self.expires_in =  [NSString stringWithFormat:@"%d",  ( [response.expires_in intValue]/1000)]  ;
            self.tokenExpireDate = [NSDate dateWithTimeIntervalSinceNow:[self.expires_in doubleValue] - SAFE_THRESHOLD];
            self.tokenExpireTimeInterval = [[NSDate date] timeIntervalSince1970] + ([self.expires_in doubleValue] - SAFE_THRESHOLD);
            
            NSString *reslutStr = [[SOSLoginDbService sharedInstance] searchTokenOnstarAccount];
            if (reslutStr){
                NNOAuthLoginResponse *oauthResponseCache = [NNOAuthLoginResponse mj_objectWithKeyValues:[Util dictionaryWithJsonString:reslutStr]];
                [[CustomerInfo sharedInstance] setTokenBasicInfo:oauthResponseCache];
            }else{
                
                [SOSSDK shareInstance].loginState = SOSSDKLoginStateNone;
                [self loginFail:NSLocalizedString(@"invalid_token", nil)];
                [self recordLoginTimeWithStatus:NO];
                return ;
            }
            if (forLogin) {
                // 新的access token，重新监控
                NSInteger period = [_expires_in integerValue] - SAFE_THRESHOLD;
                [self restartMonitorTokenInSec:period];
                //判断是否有缓存
                if ([[SOSLoginUserDbService sharedInstance] searchUserIdToken:_idToken].isNotBlank) {
                    [self loginTokenSuccess];
                }
                //如果没有缓存，和以前的自动登录一样的流程
                else
                {
                    //未取得缓存，加载
                    self.needLoadCache = NO;
                    [self loginTokenSuccess];
                }
            }
        }
    
        [SOSDaapManager sendSysLayout:[LoginManage sharedInstance].loginStartTimeIntervel endTime:[[NSDate date] timeIntervalSince1970] interfaceStatusCode:[NSString stringWithFormat:@"%ld",operation.statusCode] funcId:Login_token];
        retryFlag = NO;
        self.isRefreshingAccessToken = NO;
        
        [SOSSDK shareInstance].loginState = SOSSDKLoginStateSuccess;
   
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        
        
        [SOSSDK shareInstance].loginState = SOSSDKLoginStateFail;
        if (forLogin) {
            NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
            NSString *errorCode = [dic objectForKey:@"code"]?[dic objectForKey:@"code"]:[dic objectForKey:@"error"];
            if ([errorCode isEqualToString:@"invalid_token"]) {
                [SOSSDK shareInstance].loginState = SOSSDKLoginStateNone;
                [self loginFail:NSLocalizedString(@"invalid_token", nil)];
                 
            }else{
                
                [self loginFail:NSLocalizedString(errorCode, nil)];
            }
            retryFlag = NO;
            isSuccess = NO;
            [self recordLoginTimeWithStatus:NO];
        } else {
            if (retryFlag) {
                NSLog(@"刷新AccessToken失败，重试失败。。。");
                NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
                NSString *errorCode = [dic objectForKey:@"code"]?[dic objectForKey:@"code"]:[dic objectForKey:@"error"];
                if ([errorCode isEqualToString:@"invalid_token"]) {
                    [SOSSDK shareInstance].loginState = SOSSDKLoginStateNone;
                    [self loginFail:NSLocalizedString(@"invalid_token", nil)];
                }else{
                    [self loginFail:NSLocalizedString(errorCode, nil)];
                }
                [self stopMonitorToken];
                retryFlag = NO;
            } else {
                NSLog(@"刷新AccessToken失败，准备重试一次。。。");
                [self oAuthReAuthToken:YES];
                retryFlag = YES;
            }
        }
        self.isRefreshingAccessToken = NO;
        [SOSDaapManager sendSysLayout:[LoginManage sharedInstance].loginStartTimeIntervel endTime:[[NSDate date] timeIntervalSince1970] interfaceStatusCode:[NSString stringWithFormat:@"%ld",operation.statusCode] funcId:Login_token];

    }];
    
//    if (fromLogin) {
//        // 登录拿到token
//        [operation startSync];
//    } else {
        // 定期刷新
        [operation start];
//    }
    return isSuccess;
}
-(void)recordLoginStarTime{
    self.loginStartTimeIntervel = [[NSDate date] timeIntervalSince1970];
}
-(void)recordLoginTimeWithStatus:(BOOL)finish{
    if ([LoginManage sharedInstance].loginStartTimeIntervel!=0) {
         [SOSDaapManager sendSysLayout:[LoginManage sharedInstance].loginStartTimeIntervel endTime:[[NSDate date] timeIntervalSince1970] loadStatus:finish funcId:LOGIN_TIME];
        if (self.isLoginManual) {
            [SOSDaapManager sendSysLayout:[LoginManage sharedInstance].loginStartTimeIntervel endTime:[[NSDate date] timeIntervalSince1970] loadStatus:finish funcId:LOGIN_TIME2];

        }else{
            [SOSDaapManager sendSysLayout:[LoginManage sharedInstance].loginStartTimeIntervel endTime:[[NSDate date] timeIntervalSince1970] loadStatus:finish funcId:LOGIN_TIME1];

        }
    }
    [LoginManage sharedInstance].loginStartTimeIntervel = 0;
}
- (void)saveFilteredScope:(NSString *)responseScope     {
    NSString *tmpScope = [responseScope stringByReplacingOccurrencesOfString:@"msso" withString:@""];
    [self setScope:tmpScope];
}

/**
 保存idToken用于自动登录

 @param idToken idToken
 @param scope scope
 */
- (void)saveToken:(NSString *)idToken withScope:(NSString *)scope     {
    [SOSKeyChainManager saveIdToken:idToken withScope:scope];
}
/**
 缓存Token 接口返回onstarAccount
 @param responseStr
 */
- (void)saveTokenOnstarAccount:(NSString *)responseStr
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *reslutStr = [[SOSLoginDbService sharedInstance]searchTokenOnstarAccount];
           if (!IsStrEmpty (reslutStr)) {
               [[SOSLoginDbService sharedInstance] UpdateTokenOnstarAccountReposeString:responseStr];
           }else{
               [[SOSLoginDbService sharedInstance] insertTokenOnstarAccountReposeString:responseStr];
           }
    });
}
- (void)loadCachedToken     {
    NSDictionary *tokenDict = [SOSKeyChainManager readLoginTokenScope];
    if (tokenDict && [tokenDict isKindOfClass:[NSDictionary class]]) {
        NSString *tmpToken = (NSString *)[tokenDict objectForKey:KEY_LOGIN_ID_TOKEN];
        [self setIdToken:tmpToken];
        NSString *tmpScope = (NSString *)[tokenDict objectForKey:KEY_LOGIN_SCOPE];
        [self setScope:tmpScope];
    }
}

- (void)savePinCode:(NSString *)pin     {
    [SOSKeyChainManager savePinCode:pin forIdpid:[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
}

- (void)loadCachedPinCode     {
    BOOL openFLg = [[SOSKeyChainManager readFingerPrint:[CustomerInfo sharedInstance].userBasicInfo.idpUserId] boolValue];
    if (openFLg) {
        self.pinCode = [SOSKeyChainManager loadCachedPinCode:[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
    }
}
#pragma mark - loginStep 2 = 获取用户基本信息(手动登录加载用户基本信息,用户基本信息来自网络请求)
static NSInteger getUserBasicInfoSyncNum = 0;
- (void)loadUserBasicInfoFromCache:(BOOL)useCache
{
    if (useCache) {
        NSString * cache = [[SOSLoginUserDbService sharedInstance] searchUserIdToken:_idToken];
        if (cache) {
            [self initProfile:cache];
           
            self.loginState = LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS;
            if (![SOSCheckRoleUtil isVisitor]){
                [self loadCachedPinCode];
                [[CustomerInfo sharedInstance] updateVehicleAttribute];
                //获取车辆commands,自动登录使用缓存
                [self loadVehicleCommandsFromCache:YES needLoadSecondaryResource:YES];
                //默默刷新用户基本信息
                [self refreshUserBasicInfo];
            }else{
                //判断任何用户第一次登录
                [Util LoginFrist_SuccessWithIdpid:[CustomerInfo sharedInstance].userBasicInfo.idpUserId withVin:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
                [self loginSuccessAndNeedLoadSecondaryResource:YES];
            }
        }else{
            [self loadUserBasicInfoFromCache:NO];
        }

    }else{
        self.loginState = LOGIN_STATE_LOADINGUSERBASICINFO;
        getUserBasicInfoSyncNum++;
        NSTimeInterval startsuite = [[NSDate date] timeIntervalSince1970];
        NSLog(@"手动登录从服务器请求UserBasicInfo第%@次", @(getUserBasicInfoSyncNum));
        [OthersUtil loadUserBasicInfoByidpuserID:[CustomerInfo sharedInstance].tokenBasicInfo.idpUserId successHandler:^(SOSNetworkOperation *operation,NSString *response) {
            
            [SOSDaapManager sendSysLayout:startsuite endTime:[[NSDate date] timeIntervalSince1970] interfaceStatusCode:[NSString stringWithFormat:@"%ld",operation.statusCode] funcId:Login_suite];

            getUserBasicInfoSyncNum = 0;
            dispatch_async(dispatch_get_main_queue(), ^{
                SOSLoginUserDefaultVehicleVO * userBasicInfo = [SOSLoginUserDefaultVehicleVO mj_objectWithKeyValues:[Util dictionaryWithJsonString:response]];
                //如果用户信息拉取后解析成功
                if (userBasicInfo) {
                    [self initProfile:response];
                    [self checkIDM:userBasicInfo.idmUser.mobilePhoneNumber email:userBasicInfo.idmUser.emailAddress];
                    //手动登录保存userBasicinfo信息
                    [self saveUserBasicInfo:response];
                    //非Mobile注册帐号未完成验证,在手动登录时候可能有此情况，自动登录不会出现
                    if (!newProfile.idmUser.verification_status)	{
                        [self processNotMobileRegistUser];
                    }	else	{
                        self.loginState = LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS;
                    
                        //保存用户登录信息
                        [self saveUserLoginInfo];
                        if (![SOSCheckRoleUtil isVisitor]){
                            [self loadCachedPinCode];
                            [[CustomerInfo sharedInstance] updateVehicleAttribute];
                            //获取车辆commands
                            [self loadVehicleCommandsFromCache:NO needLoadSecondaryResource:YES];

                        }	else	{
                            //非车主登录完成
                            [Util LoginFrist_SuccessWithIdpid:[CustomerInfo sharedInstance].userBasicInfo.idpUserId withVin:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
                            [self loginSuccessAndNeedLoadSecondaryResource:YES];
                            [self recordLoginTimeWithStatus:YES];
                        }
                    }
                    [self checkPopView];
                }	else	{
                    self.loginState = LOGIN_STATE_LOADINGUSERBASICINFOFAIL;
                }
            });
            if (_failedMainInterfaceArray) {
                [_failedMainInterfaceArray removeAllObjects];
            }
            
        } failureHandler:^(NSInteger statusCode,NSString *responseStr, NNError *error) {
            [SOSDaapManager sendSysLayout:startsuite endTime:[[NSDate date] timeIntervalSince1970] interfaceStatusCode:[NSString stringWithFormat:@"%ld",statusCode] funcId:Login_suite];

                if (getUserBasicInfoSyncNum<=2) {
                    [self loadUserBasicInfoFromCache:NO];
                }else{
                    getUserBasicInfoSyncNum = 0;
                    NSLog(@"从服务器同步请求UserProfile 三次都失败...")
                    if (!useCache) {
                        if (_failedMainInterfaceArray) {
                            [_failedMainInterfaceArray addObject:@(LOGIN_STATE_LOADINGUSERBASICINFOFAIL)];
                        }
                    }
                    self.loginState = LOGIN_STATE_LOADINGUSERBASICINFOFAIL;
                    [self recordLoginTimeWithStatus:NO];
                }
        }];
    }
}
#pragma mark -- 自动登录刷新suite接口中用户基本信息
static NSInteger refreshUserBasicInfoNum = 0;
//异步刷新UserProfile，如果获取失败则重试2次
- (void)refreshUserBasicInfo
{
    refreshUserBasicInfoNum++;
    BOOL isExpired = [[SOSLoginUserDbService sharedInstance] isExpiredIdToken:_idToken];
    //缓存已经过期
    if (isExpired) {
        [LoginManage sharedInstance].loadingUserProfile = LOGIN_LOADING_USER_PROFILE_INPROGRESS;
        NSLog(@"正在刷新userBasicInfo:第%@次， 缓存已过期",@(refreshUserBasicInfoNum));
    }
    else
    {
        NSLog(@"正在刷新userBasicInfo:第%@次， 缓存未过期",@(refreshUserBasicInfoNum));
    }
    NSTimeInterval startsuite = [[NSDate date] timeIntervalSince1970];

    [OthersUtil loadUserBasicInfoByidpuserID:[CustomerInfo sharedInstance].tokenBasicInfo.idpUserId successHandler:^(SOSNetworkOperation *operation,NSString *response) {
        [SOSDaapManager sendSysLayout:startsuite endTime:[[NSDate date] timeIntervalSince1970] interfaceStatusCode:[NSString stringWithFormat:@"%ld",operation.statusCode] funcId:Login_suite];

            dispatch_async(dispatch_get_main_queue(), ^{
                SOSLoginUserDefaultVehicleVO * userBasicInfo = [SOSLoginUserDefaultVehicleVO mj_objectWithKeyValues:[Util dictionaryWithJsonString:response]];
                [LoginManage sharedInstance].loadingUserProfile = LOGIN_LOADING_USER_PROFILE_NON;
                //如果用户信息拉取后解析成功
                if (userBasicInfo) {
                    refreshUserBasicInfoNum = 0;
                    [self initProfile:response];
                    [self checkIDM:userBasicInfo.idmUser.mobilePhoneNumber email:userBasicInfo.idmUser.emailAddress];
                    //手动登录保存userBasicinfo信息
                    [self saveUserBasicInfo:response];
                        //保存用户登录信息
//                        [self saveUserLoginInfo];
                        if (![SOSCheckRoleUtil isVisitor]){
                            [self loadCachedPinCode];
                            [[CustomerInfo sharedInstance] updateVehicleAttribute];
                            
                        }else{
                            //非车主登录完成
                            [Util LoginFrist_SuccessWithIdpid:[CustomerInfo sharedInstance].userBasicInfo.idpUserId withVin:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
                            [self recordLoginTimeWithStatus:YES];
                        }
                  
                    [self checkPopView];
                    [self refreshCommands:isExpired];
                }else{
                    if (refreshUserBasicInfoNum<=2) {
                        [self refreshUserBasicInfo];
                    }else{
                        [self recordLoginTimeWithStatus:NO];
                    }
                }
            });
            
        } failureHandler:^(NSInteger statusCode,NSString *responseStr, NNError *error) {
            
            [SOSDaapManager sendSysLayout:startsuite endTime:[[NSDate date] timeIntervalSince1970] interfaceStatusCode:[NSString stringWithFormat:@"%ld",statusCode] funcId:Login_suite];

                if (refreshUserBasicInfoNum<=2) {
                    [self refreshUserBasicInfo];
                }else{
                    refreshUserBasicInfoNum = 0;
                    NSLog(@"从服务器刷新UserBasicInfo 三次都失败...")
                    [LoginManage sharedInstance].loadingUserProfile = LOGIN_LOADING_USER_PROFILE_FAILURE;
                    [self recordLoginTimeWithStatus:NO];
                }
        }];
    
}

//
//-(BOOL)isShowIMD
//{
//    NSNumber *n = UserDefaults_Get_Object([CustomerInfo sharedInstance].userBasicInfo.idpUserId);
//    if (n) {
//        if ([n intValue] >= 3) {     //3次以后不弹
//            return NO;
//        }else
//        {
//            return YES;
//        }
//    }else
//    {
//        return YES;
//    }
//}

-(void)checkIDM:(NSString *)phone email:(NSString*)email{
    //    if (SOS_APP_DELEGATE.isgsp) {
    if (![CustomerInfo sharedInstance].userBasicInfo.idmUser.verification_status) { //bench创建CSM的邮箱账号登录后需要验证邮箱，此时不能弹出
        return;
    }
    if ([SOSCheckRoleUtil isVisitor]) {
        if (!phone.isNotBlank) {
            @weakify(self);
            [self addPopViewAction:^{
                [Util showAlertWithTitle:@"绑定服务手机号" message:@"检测到您尚未绑定服务手机号，绑定后便于我们提供更优质的服务。" completeBlock:^(NSInteger buttonIndex) {
                   
                        SOSGeoModifyMobileVC *vc = [SOSGeoModifyMobileVC new];
                                           vc.isReplenishMobile = YES;
                                           [vc setBackHandler:^{
                                               @strongify(self);
                                               [self nextPopViewAction];
                                               [self checkIDM:phone email:email];
                                           }];
                                           [vc setCompleteHandler:^{
                                               @strongify(self);
                                               [self nextPopViewAction];
                                           }];
                                           [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:vc animated:YES];
                   
                } cancleButtonTitle:nil otherButtonTitles:@"立即绑定",nil];
            }];
        }
    }else{
        
        if (!phone.isNotBlank) {
            @weakify(self);
            [self addPopViewAction:^{
                [Util showAlertWithTitle:@"未绑定手机号" message:@"为了保障您的账号安全，请先绑定服务手机号再继续使用服务" completeBlock:^(NSInteger buttonIndex) {
                    
                        SOSGeoModifyMobileVC *vc = [SOSGeoModifyMobileVC new];
                                           vc.isReplenishMobile = YES;
                                           [vc setBackHandler:^{
                                               @strongify(self);
                                               [self nextPopViewAction];
                                               [self checkIDM:phone email:email];
                                           }];
                                           [vc setCompleteHandler:^{
                                               @strongify(self);
                                               [self nextPopViewAction];
                                           }];
                                           [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:vc animated:YES];
                   
                } cancleButtonTitle:nil otherButtonTitles:@"立即绑定",nil];
            }];
        }
        
    }
    
    //    }
    
}

#pragma mark --登录后保存suite用户基本信息
/**
 保存用户信息到DB
 @param responseStr 用户信息字符串
 */
- (void)saveUserBasicInfo:(NSString *)responseStr
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //    if ([SOSGreetingManager shareInstance].flutterEnable) {
//                NSString *key = [NSString stringWithFormat:@"%@_MobileUser",[CustomerInfo sharedInstance].tokenBasicInfo.idpUserId];
//                [SOSFlutterDB insertOrUpdateWithKey:key value:responseStr];
        //    }

            if (!IsStrEmpty([[SOSLoginUserDbService sharedInstance] searchUserIdToken:_idToken])) {
                [[SOSLoginUserDbService sharedInstance] updateUserIdToken:_idToken reposeString:responseStr];
            }
            else
            {
                [[SOSLoginUserDbService sharedInstance] insertUserIdToken:_idToken reposeString:responseStr];
            }
            
    });

}
/**
 保存用户名到NSUserDefault
 */
- (void)saveUserLoginInfo
{
    //保存密码用户名 到keyChain
    if (tempPwd != nil) {
        BOOL flg  = [SOSCheckRoleUtil isOwner];
        [SOSKeyChainManager saveLoginUserName:[newProfile.idmUser mobilePhoneNumber] andPassword:tempPwd withEamil:[newProfile.idmUser emailAddress] withIdpid:[newProfile idpUserId] owner:flg];
    }
    //自动登录，currentUserName为空
    if (!currentUserName) {
        currentUserName = UserDefaults_Get_Object(NN_CURRENT_USERNAME);
    }
    //mask userName
    if ([Util isValidatePhone:currentUserName]) {
        UserDefaults_Set_Object([currentUserName stringInterceptionHide], NN_MASK_USERNAME);
    }
    else
    {
        if ([Util isValidateEmail:currentUserName]) {
            UserDefaults_Set_Object([currentUserName stringEmailInterceptionHide], NN_MASK_USERNAME);
        }
        else
        {
            UserDefaults_Set_Object([currentUserName maskedUserName], NN_MASK_USERNAME);
        }
    }
    UserDefaults_Set_Object(currentUserName, NN_CURRENT_USERNAME);
}

/**
 登录成功
 */
- (void)loginSuccessAndNeedLoadSecondaryResource:(BOOL)needLoadSecondaryResource
{
    self.loginState = LOGIN_STATE_LOADINGVEHICLEPRIVILIGESUCCESS;
    [ServiceController sharedInstance].loginFlagForDataRefresh = YES;
    // after successfuly login upload report
    [self addLoginSuccessReport];
     //登录成功，发送车辆改变的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:SOS_ACCOUNT_VEHICLE_HAS_CHANGED object:Nil];
    if (needLoadSecondaryResource) {
        [self loadSecondaryResource];
    }
}
#pragma mark - Login step 3 = 获取车辆支持命令
static NSInteger commonGetCommandsSyncNum = 0;

- (void)loadVehicleCommandsFromCache:(BOOL)useCache needLoadSecondaryResource:(BOOL)loadSecondary
{
    if (loadSecondary) {
        [self loadSecondaryResource];
    }
    if (useCache) {
        //从缓存DB取得的Commands
        NSString *reslutStr = [[SOSLoginDbService sharedInstance] searchVehicleCommands:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
        if (reslutStr && reslutStr.length > 0) {
            [Util assginVehicleCommansData:reslutStr];
            self.loginState = LOGIN_STATE_LOADINGVEHICLECOMMANDSESUCCESS;
            [self loadVehiclePrivilegeFromCache:YES];
        } else {
            //没有command缓存信息，同步取得command，重试2次报错，重新登录
            [self loadVehicleCommandsFromCache:NO needLoadSecondaryResource:NO];
        }
    }
    else{
        //从服务器获取Commands
        self.loginState = LOGIN_STATE_LOADINGVEHICLECOMMANDS;
        commonGetCommandsSyncNum++;
        NSLog(@"从服务器获取Commands第======%@次====",@(commonGetCommandsSyncNum));
        NSTimeInterval startcommands = [[NSDate date] timeIntervalSince1970];

        [OthersUtil loadUserVehicleCommandsByVin:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin successHandler:^(SOSNetworkOperation *operation,NSString *responseStr) {
            [SOSDaapManager sendSysLayout:startcommands endTime:[[NSDate date] timeIntervalSince1970] interfaceStatusCode:[NSString stringWithFormat:@"%ld",operation.statusCode] funcId:Login_commands];

            commonGetCommandsSyncNum = 0;
            if ([responseStr length]>0) {
                //缓存Commands
                [self saveVehicleCommands:responseStr];
                //设置CustomerInfo车相关属性
                [Util assginVehicleCommansData:responseStr];
                self.loginState = LOGIN_STATE_LOADINGVEHICLECOMMANDSESUCCESS;
                [self loadVehiclePrivilegeFromCache:NO];
            }else{
                self.loginState = LOGIN_STATE_LOADINGVEHICLECOMMANDSFAIL;
                [self recordLoginTimeWithStatus:NO];
            }
            if (_failedMainInterfaceArray) {
                [_failedMainInterfaceArray removeAllObjects];
            }

        } failureHandler:^(NSInteger statusCode,NSString *responseStr, NSError *error) {
            [SOSDaapManager sendSysLayout:startcommands endTime:[[NSDate date] timeIntervalSince1970] interfaceStatusCode:[NSString stringWithFormat:@"%ld",statusCode] funcId:Login_commands];

            //获取commands失败，默默再获取2次
            if (commonGetCommandsSyncNum<=2) {
                [self loadVehicleCommandsFromCache:NO needLoadSecondaryResource:NO];
                self.loginState = LOGIN_STATE_LOADINGVEHICLECOMMANDSFAIL;
                ;
            }
            else
            {
                commonGetCommandsSyncNum = 0;
                NSLog(@"从服务器获取Commands三次都失败...")
                if (!useCache) {
                    [_failedMainInterfaceArray addObject:@(LOGIN_STATE_LOADINGVEHICLECOMMANDSFAIL)];
                }
                self.loginState = LOGIN_STATE_LOADINGVEHICLECOMMANDSFAIL;
                [self recordLoginTimeWithStatus:NO];
            }
        }];
    }
}
#pragma mark --自动登录刷新Commands，自动登录无需设置登录状态，但切车造成的自动登录需要设置登录状态
static NSInteger refreshCommandsNum = 0;
//异步刷新Commands，如果获取失败则重试2次
- (void)refreshCommands:(BOOL)isExpired
{
    refreshCommandsNum++;
    if (isExpired) {
        [LoginManage sharedInstance].loadingUserProfile = LOGIN_LOADING_USER_PROFILE_INPROGRESS;
        NSLog(@"正在刷新车辆Commands:第%@次， 缓存已过期",@(refreshCommandsNum));
    }else{
        NSLog(@"正在刷新车辆Commands:第%@次， 缓存未过期",@(refreshCommandsNum));
    }
    NSString *url =[NSString stringWithFormat:(@"%@" ONSTAR_API_COMMANDS), BASE_URL, [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    NSTimeInterval startcommands = [[NSDate date] timeIntervalSince1970];

    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        
        [SOSDaapManager sendSysLayout:startcommands endTime:[[NSDate date] timeIntervalSince1970] interfaceStatusCode:[NSString stringWithFormat:@"%ld",operation.statusCode] funcId:Login_commands];

            if ([responseStr length]>0) {
                refreshCommandsNum = 0;
                //缓存Commands
                [self saveVehicleCommands:responseStr];
                //设置CustomerInfo车相关属性
                [Util assginVehicleCommansData:responseStr];
                [self refreshPrivilege:isExpired];
            }else{
                if (refreshCommandsNum<=2) {
                    [self refreshCommands:isExpired];
                }else{
                    [self recordLoginTimeWithStatus:NO];
                }
            }
        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            
            [SOSDaapManager sendSysLayout:startcommands endTime:[[NSDate date] timeIntervalSince1970] interfaceStatusCode:[NSString stringWithFormat:@"%ld",statusCode] funcId:Login_commands];

            //获取commands失败，默默再获取2次
            if (refreshCommandsNum<=2) {
                [self refreshCommands:isExpired];
            }
            else
            {
                refreshCommandsNum = 0;
                NSLog(@"从服务器刷新Commands三次都失败...");
                [self recordLoginTimeWithStatus:NO];
            }
        }];
        [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
        [operation setHttpMethod:@"GET"];
        [operation start];
    
}
/**
 缓存Commands
 @param responseStr
 */
- (void)saveVehicleCommands:(NSString *)responseStr
{
//    if ([SOSGreetingManager shareInstance].flutterEnable) {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//         NSString *key = [NSString stringWithFormat:@"%@_ServiceFeatureCommandEntity",[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
//                [SOSFlutterDB insertOrUpdateWithKey:key value:responseStr];
        //    }
            NSString *reslutStr = [[SOSLoginDbService sharedInstance] searchVehicleCommands:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
            if (!IsStrEmpty(reslutStr)) {
                [[SOSLoginDbService sharedInstance] UpdateVehicleCommands:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin andReposeString:responseStr];
            }else{
                [[SOSLoginDbService sharedInstance] insertVehicleCommands:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin andReposeString:responseStr];
            }
    });
       
}
- (void)loginFail:(NSString *)error     {
    NSLog(@"token接口失败");
    [self resetLoginInstance];
    if (error != nil) {
        if (![error isEqualToString:@""]) {
            [SOSUtil showCustomAlertWithTitle:@"提示" message:error completeBlock:nil];
        }
    }
    else
    {
        [SOSUtil showCustomAlertWithTitle:@"提示" message:NSLocalizedString(@"SOMP-604", nil) completeBlock:nil];
    }
    [ServiceController sharedInstance].loginFlagForDataRefresh = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:SOS_AUTO_LOGIN_FAIL object:Nil];
}


#pragma mark --checkPIN
- (void)checkIsDefaultPin:(NSString *)govid {
    if (govid.length >=6) {
        SOSRegisterCheckPINRequest * pinRequest = [[SOSRegisterCheckPINRequest alloc] init];
        pinRequest.accountID = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId;
        pinRequest.ignoreFailCount = YES;
        NSInteger fromIdx = govid.length - 6;
        NSString *aesPin = [SOSUtil AES128EncryptString:[govid substringFromIndex:fromIdx]];
        pinRequest.pin = aesPin;
        [RegisterUtil checkPIN:[pinRequest mj_JSONString] successHandler:^(NSString *responseStr) {
            [CustomerInfo sharedInstance].userBasicInfo.subscriber.isDefaultPin = [responseStr isEqualToString:@"0"];
        } failureHandler:^(NSString *responseStr) {
            
        }];
    }
}

//- (void)checkPinWithGovId:(NSString *)govid Complete:(void (^)(BOOL success, NSInteger errorCode,NSString *failResponse))complete_  {
//    
////    NSString * recordKey = [NSString stringWithFormat:@"%@_%@",sosKeyIsDefaultPin,[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
////    NSNumber * isDefault = UserDefaults_Get_Object(recordKey);
////
////    if (isDefault) {
////        complete_(isDefault.boolValue, 0,nil);
////    }
//    SOSRegisterCheckPINRequest * pinRequest = [[SOSRegisterCheckPINRequest alloc] init];
//    pinRequest.accountID = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId;
//    pinRequest.ignoreFailCount = YES;
//    NSInteger fromIdx = govid.length - 6;
//    if (fromIdx >= 0) {
//        NSString *aesPin = [SOSUtil AES128EncryptString:[govid substringFromIndex:fromIdx]];
//        pinRequest.pin = aesPin;
//    }
//    [RegisterUtil checkPIN:[pinRequest mj_JSONString] successHandler:^(NSString *responseStr) {
//        
//        dispatch_async_on_main_queue(^(){
//            complete_([responseStr isEqualToString:@"0"], 0,nil);
//        });
//        
//    } failureHandler:^(NSString *responseStr) {
//        dispatch_async_on_main_queue(^(){
//            complete_(NO, 1,responseStr);
//        });
//    }];
//}
#pragma mark - loginStep 4 =获取车辆可用功能，代替之前serviceEntitlement
static NSInteger requestPrivilegeTimesNum = 0;

- (void)loadVehiclePrivilegeFromCache:(BOOL)useCache
{
    if (useCache) {
        NSString *reslutStr = [[SOSLoginDbService sharedInstance] searchVehiclePrivilege:[[CustomerInfo sharedInstance] getIdpidVinStr]];
        if (reslutStr) {
            SOSVehicleAndPackageEntitlement * entitlement = [SOSVehicleAndPackageEntitlement mj_objectWithKeyValues:[Util dictionaryWithJsonString:reslutStr]];
//            [Util toastWithMessage:@"获取车辆支持服务成功"];
            [[CustomerInfo sharedInstance] updateServiceEntitlement:entitlement];
            [self loginSuccessAndNeedLoadSecondaryResource:NO];
        }else{
            [self loadVehiclePrivilegeFromCache:NO];
        }
    }else{
        self.loginState = LOGIN_STATE_LOADINGVEHICLEPRIVILIGE;
        requestPrivilegeTimesNum++;
        
        NSTimeInterval startprivilege = [[NSDate date] timeIntervalSince1970];

        [OthersUtil loadVehiclePrivilegeSuccessHandler:^(SOSNetworkOperation *operation,NSString *response) {
            
            [SOSDaapManager sendSysLayout:startprivilege endTime:[[NSDate date] timeIntervalSince1970] interfaceStatusCode:[NSString stringWithFormat:@"%ld",operation.statusCode] funcId:Login_availablefuncs];

            SOSVehicleAndPackageEntitlement * entitlement = [SOSVehicleAndPackageEntitlement mj_objectWithKeyValues:[Util dictionaryWithJsonString:response]];
            requestPrivilegeTimesNum = 0;
            if (entitlement) {
                [[CustomerInfo sharedInstance] updateServiceEntitlement:entitlement];
                [self saveVehiclePrivilege:response];
                [self loginSuccessAndNeedLoadSecondaryResource:NO];
                [self recordLoginTimeWithStatus:YES];
            }else{
                self.loginState = LOGIN_STATE_LOADINGVEHICLEPRIVILIGEFAIL;
                 [self recordLoginTimeWithStatus:NO];
            }
            if (_failedMainInterfaceArray) {
                [_failedMainInterfaceArray removeAllObjects];
            }
        } failureHandler:^(NSInteger statusCode,NSString *responseStr, NNError *error) {
            [SOSDaapManager sendSysLayout:startprivilege endTime:[[NSDate date] timeIntervalSince1970] interfaceStatusCode:[NSString stringWithFormat:@"%ld",statusCode] funcId:Login_availablefuncs];

            //获取commands失败，默默再获取2次
            if (requestPrivilegeTimesNum<=2) {
                [self loadVehiclePrivilegeFromCache:NO];
            }
            else
            {
                requestPrivilegeTimesNum = 0;
                NSLog(@"从服务器获取Privilege三次都失败...")
                if (!useCache) {
                    [_failedMainInterfaceArray addObject:@(LOGIN_STATE_LOADINGVEHICLEPRIVILIGEFAIL)];
                }
                self.loginState = LOGIN_STATE_LOADINGVEHICLEPRIVILIGEFAIL;
                [self recordLoginTimeWithStatus:NO];
            }
        }];
    }
}
#pragma mark --自动登录刷新Privilege
static NSInteger refreshPrivilegeNum = 0;
//异步刷新Privilege，如果获取失败则重试2次
- (void)refreshPrivilege:(BOOL)isExpired
{
    refreshPrivilegeNum++;
    if (isExpired) {
//        [LoginManage sharedInstance].loadingUserProfile = LOGIN_LOADING_USER_PROFILE_INPROGRESS;
        NSLog(@"正在刷新Privilege:第%@次， 缓存已过期",@(refreshPrivilegeNum));
    }else{
        NSLog(@"正在刷新Privilege:第%@次， 缓存未过期",@(refreshPrivilegeNum));
    }
    NSTimeInterval startprivilege = [[NSDate date] timeIntervalSince1970];

    [OthersUtil loadVehiclePrivilegeSuccessHandler:^(SOSNetworkOperation *operation,NSString *response) {
        
        [SOSDaapManager sendSysLayout:startprivilege endTime:[[NSDate date] timeIntervalSince1970] interfaceStatusCode:[NSString stringWithFormat:@"%ld",operation.statusCode] funcId:Login_availablefuncs];

            SOSVehicleAndPackageEntitlement * entitlement = [SOSVehicleAndPackageEntitlement mj_objectWithKeyValues:[Util dictionaryWithJsonString:response]];
            if (entitlement) {
                refreshPrivilegeNum = 0;
                //缓存Privilege,更新serviceEntitlement
                [[CustomerInfo sharedInstance] updateServiceEntitlement:entitlement];
                [self saveVehiclePrivilege:response];
                [self recordLoginTimeWithStatus:YES];
            }else{
                if (refreshPrivilegeNum<=2) {
                    [self refreshPrivilege:isExpired];
                }else{
                    [self recordLoginTimeWithStatus:NO];
                }
            }
        } failureHandler:^(NSInteger statusCode,NSString *responseStr, NNError *error) {
            
            [SOSDaapManager sendSysLayout:startprivilege endTime:[[NSDate date] timeIntervalSince1970] interfaceStatusCode:[NSString stringWithFormat:@"%ld",statusCode] funcId:Login_availablefuncs];

            if (refreshPrivilegeNum<=2) {
                [self refreshPrivilege:isExpired];
            }
            else
            {
                refreshPrivilegeNum = 0;
                NSLog(@"从服务器刷新privilege三次都失败...")
                [self recordLoginTimeWithStatus:NO];
            }
        }];
    
}
/**
 缓存Privilege,根据idpid+vin组合
 @param responseStr
 */
- (void)saveVehiclePrivilege:(NSString *)responseStr
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *reslutStr = [[SOSLoginDbService sharedInstance] searchVehiclePrivilege:[[CustomerInfo sharedInstance] getIdpidVinStr]];
        if (!IsStrEmpty(reslutStr)) {
            [[SOSLoginDbService sharedInstance] UpdateVehiclePrivilege:[[CustomerInfo sharedInstance] getIdpidVinStr] andReposeString:responseStr];
        }else{
            [[SOSLoginDbService sharedInstance] insertVehiclePrivilege:[[CustomerInfo sharedInstance] getIdpidVinStr] andReposeString:responseStr];
        }
    });
    
}
- (void)addTouchIdObserver {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @weakify(self);
        [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOS_PresentTouchID_Notification object:nil] subscribeNext:^(NSNotification *notification) {
            @strongify(self);
            if ([notification.object isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = notification.object;
                if ([dic[@"BBWC_Edu_End"] boolValue]) {
                    static dispatch_once_t onceToken;
                    dispatch_once(&onceToken, ^{
                        [SOSCardUtil routerToStarTravelH5];
                    });
                }
            }
            [self presentTouchID];
        }];
    });
}

- (void)presentTouchID{
    if (!SOS_ONSTAR_PRODUCT) {
        return;
    }

    //验证指纹密码
    BOOL isSupportBiometrics = [SOSBiometricsManager isSupportBiometrics];
    //首次登录：输入用户名密码，登录后首页自动弹框：是否启用指纹密码/开启后XXXXX。确认/取消--确认：跳转指纹密码页面可进行设置，取消，停留在首页，下次该账户在该设备上登录后不再弹框提示开启指纹验证。
    if (isSupportBiometrics) {
        //支持指纹
        if ([SOSCheckRoleUtil isOwner]) {
            NSMutableDictionary *dic = UserDefaults_Get_Object(@"openFingerPwdAlert");
            NSNumber *alertIsShowed = dic[[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
            if (!alertIsShowed.boolValue) {
                BOOL openFLg = [[SOSKeyChainManager readFingerPrint:[CustomerInfo sharedInstance].userBasicInfo.idpUserId] boolValue];
                if (!openFLg) {
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:dic];
                    [dict setObject:[NSNumber numberWithBool:YES] forKey:[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
                    UserDefaults_Set_Object(dict, @"openFingerPwdAlert");
                    
                    NSString *title = [SOSBiometricsManager isSupportFaceId] ? @"启用面容 ID" : @"启用指纹 ID";
                    
                    [self addPopViewAction:^{
                        [Util showAlertWithTitle:title message:@"可用于登录及代替服务密码执行车辆服务" completeBlock:^(NSInteger buttonIndex) {
                            if (buttonIndex == 1) {
                                UIStoryboard *fingerPwStoryboard = [UIStoryboard storyboardWithName:[Util getPersonalcenterStoryBoard] bundle:nil];
                                ViewControllerFingerprintpw *fingerPrint = [fingerPwStoryboard instantiateViewControllerWithIdentifier:@"ViewControllerFingerprintpw"];
                                [(UINavigationController *)[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:fingerPrint animated:YES];
                            }else{
                                [loginManage nextPopViewAction];
                            }
                        } cancleButtonTitle:@"取消" otherButtonTitles:@"去启用", nil];
                    }];
                        
                }
            }
        }
    }
    
}
#pragma mark Logins Step 5 = 加载次级数据,包括TCPS、
#pragma mark -- 查看当前用户是否有新的协议需要签署
- (void)loadSecondaryResource
{
    
//    if([LoginManage sharedInstance].isClickShowOnstarModule){
//        [self loadTCPSNeedConfirm];
//    }
//
    
    
    [CollectionToolsOBJ getHomeAndCompanyMessage];
    [self loadSchedules];
    [self requestRAConfig];
}

-(void)checkPopView
{
    NSString *url = [Util getConfigureURL];
    url = [url stringByAppendingFormat:@"%@",LOGINPOPUP];
    SOSNetworkOperation* sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSLog(@"===========checkYearReport success========= %@",responseStr);
        NSError *error;
//        //todo test
//        responseStr = @"[{\"description\": \"个人年度报告二期\",\"popupCode\": \"PERSONAL_ANNUAL_REPORT_V2\",\"popupContent\": \"xx\",\"popupImg\": \"http://www.xinhuanet.com/photo/2019-12/01/1125295291_15751995730981n.jpg\",\"reportUrl\": \"http://www.baidu.com\"}]";
        NSData *data = [responseStr dataUsingEncoding:NSUTF8StringEncoding];
        id jsonData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (!error && [jsonData isKindOfClass:NSArray.class]) {
            NSArray *arr = jsonData;
            if (![arr isKindOfClass:[NSArray class]])    return ;
            [self readToPopView:arr];
        }else {
            [self readToPopView:nil];
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        NSLog(@"============checkYearReport fail============");
        [self readToPopView:nil];
    }];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation setHttpHeaders:@{@"Channel":@"onstarapp",@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
//#endif
   
}

-(void)readToPopView:(NSArray*)datas
{
//    __block BOOL isPopReport = NO;
    __block BOOL isPopQuestion = NO;
    __block BOOL isPopBBWC = NO;
    
    if ([datas isKindOfClass:[NSArray class]] && datas.count >0) {
        [datas enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *d = (NSDictionary*)obj;
            if ([d[@"popupCode"] isEqualToString:@"SECURITY_QUESTION"])
            {
                isPopQuestion = YES;
            }else if ([d[@"popupCode"] isEqualToString:@"BBWC_EDUCATION"]){
                isPopBBWC = YES;
            }
           
            if ([d[@"popupCode"] isEqualToString:@"AUTO_INDUSTRY_REPORT"]){
                @weakify(self);
                //弹出行业报告
                [self addPopViewAction:^{
                    UIWindow *keyWindow = SOS_ONSTAR_WINDOW;//[UIApplication sharedApplication].keyWindow;
                    SOSSimplePopView *view = [SOSSimplePopView instanceView];
                    [view configWithDic:d];
                    view.clickFunctionID = IndustryReport4_PopupWindow;
                    view.closeFunctionID = IndustryReport4_PopupWindow_Close;
                    view.frame = keyWindow.bounds;
                    [keyWindow addSubview:view];
                    view.dismissComplete = ^{
                        @strongify(self);
                        [self nextPopViewAction];
                    };
                }];
            }
            if ([d[@"popupCode"] isEqualToString:@"PERSONAL_ANNUAL_REPORT_V2"]){
                @weakify(self);
                //弹出个人年度报告
                [self addPopViewAction:^{
                    UIWindow *keyWindow = SOS_ONSTAR_WINDOW;//[UIApplication sharedApplication].keyWindow;
                    SOSSimplePopView *view = [SOSSimplePopView instanceView];
                    [view configWithDic:d];
                    view.clickFunctionID = AnnualReport2_PopupWindow;
                    view.closeFunctionID = AnnualReport2_PopupWindow_Close;
                    view.frame = keyWindow.bounds;
                    [keyWindow addSubview:view];
                    view.dismissComplete = ^{
                        @strongify(self);
                        [self nextPopViewAction];
                    };
                }];
            }
        }];
    }
   
    [self isPopView:[datas count]>0  question:isPopQuestion bbwc:isPopBBWC];
}

-(void)isPopView:(BOOL)isPop   question:(BOOL)question bbwc:(BOOL)bbwc
{
    NSLog(@"  ispopQuestion %d   ispopBBWC %d ",question,bbwc);
    if (isPop) //有弹窗
    {
        [self addTouchIdObserver];
        if (question) {    //无年度报告,有安全问题
                [self popQaQuestion];
            }else{
              if (bbwc) {   //无年度报告无安全问题，有BBWC
                    [SOSCardUtil routerToBBwcWithType:nil];
                }
            }
    }else //没有任何弹窗
    {
        [self presentTouchID];
    }

}


//-(void)popReport:(BOOL)showQaQuestion bbwc:(BOOL)showBBWC
//{
////    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
////    SOSYearReportView *view = [SOSYearReportView instanceView];
////    view.frame = keyWindow.bounds;
////    [keyWindow addSubview:view];
////    @weakify(self)
////    view.dismissComplete = ^{
////        @strongify(self)
//        //[weakView removeFromSuperview];
//        if (showQaQuestion) {
//            NSLog(@"yearReportClose---- showQaQuest");
//            [self popQaQuestion];
//        }else if (showBBWC)
//        {
//            NSLog(@"yearReportClose---- showBBWC");
//            [SOSCardUtil routerToBBwcWithType:nil];
//        }else{
//
//        }
////    };
//    [self addQaObserver:showQaQuestion];
//}

//-(void)addQaObserver:(BOOL)showQaQuestion
//{
//    @weakify(self);
//    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOS_PopupQaQuestion object:nil] subscribeNext:^(NSNotification *notification) {
//        @strongify(self);
//        if (showQaQuestion) {
//            [self popQaQuestion];
//        }
//    }];
//}


-(void)popQaQuestion
{
    UINavigationController *personNav =  (UINavigationController *)([SOS_APP_DELEGATE fetchMainNavigationController]);
    SOSEditQAPinViewController *vc1 = [SOSEditQAPinViewController new];
    CustomNavigationController *cvc = [[CustomNavigationController alloc] initWithRootViewController:vc1];
    [personNav presentViewController:cvc animated:YES completion:nil];
}


- (void)loadTCPSNeedConfirm {
     NSArray<NSString *> *types = @[agreementName(ONSTAR_TC), agreementName(ONSTAR_PS), agreementName(SGM_TC), agreementName(SGM_PS)];
    [self loadTCPSNeedConfirmTypes:types];
}
-(void)loadSchedules{
    [AccountInfoUtil getUserOnstarSchedulesWithIdpid:[CustomerInfo sharedInstance].userBasicInfo.idmUser.idpUserId andDate:[Util getTimeStampFromDate:[NSDate date]] successBlock:^(NSString *response) {
        //todo test
//#ifdef DEBUG
//        response = @"[{\"serviceId\":\"21312312312\",\"remindDate\":\"1566799022\",\"remindContent\":\"test001\",\"processingStatus\":\"1\"},{\"serviceId\":\"21312312315\",\"remindDate\":\"1566885422\",\"remindContent\":\"test002\",\"processingStatus\":\"2\"}]";
//#endif
        SOSUserScheldulesResp *res =[[SOSUserScheldulesResp alloc] init];
        [res setUserScheldules:[SOSUserScheduleItem mj_objectArrayWithKeyValuesArray:[Util dictionaryWithJsonString:response]]];
        NSMutableArray  * addSch = [NSMutableArray array];
        NSMutableArray  * deleteSch = [NSMutableArray array];
        for (SOSUserScheduleItem * item in res.userScheldules) {
            if ([item.processingStatus isEqualToString:@"1"]) {
                [addSch addObject:item];
            }else{
                if ([item.processingStatus isEqualToString:@"2"]) {
                    [deleteSch addObject:item];
                }
            }
        }
        
        [Util saveEvents:addSch successHandler:^{
            [AccountInfoUtil bindClientScheduleIds:addSch successBlock:^(NSString *response) {
#ifdef DEBUG
                if (response) {
                    if ([[[Util dictionaryWithJsonString:response] objectForKey:@"isBindSuccess"] boolValue]) {
                        [Util toastWithMessage:@"日程添加后上传绑定成功"];
                    }else{
                        [Util toastWithMessage:@"日程添加后绑定失败"];
                    }
                }
#endif
            } failedBlock:^{
#ifdef DEBUG
                [Util toastWithMessage:@"日程添加后上传绑定失败"];
#endif
            }];
        }];
        [Util deleteEvents:deleteSch];
        
    } failedBlock:^{
        
    }];
}
-(void)requestRAConfig {
   
    NSString *url = [BASE_URL stringByAppendingFormat:@"/sos/contentinfo/v1/switch?dictCode=R001"];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSArray * arr = [Util arrayWithJsonString: responseStr];
        [arr enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[obj objectForKey:@"feature"] isEqualToString:@"ra_status"]) {
                [CustomerInfo sharedInstance].sosRAStatus = [[obj objectForKey:@"open"] boolValue];
                *stop = YES;
            }
        }];
      } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
          
      }];
      [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
      [operation setHttpMethod:@"GET"];
      [operation start];
}
-(void)loadTCPSNeedConfirmTypes:(NSArray *)types {
   
    [SOSAgreement requestAgreementsWhichNeedSignWithTypes:types success:^(NSDictionary *response) {
      
     //   [LoginManage sharedInstance].isClickShowOnstarModule = false;
        if (response.allKeys.count <= 0) {  //已经签署过,数组为空,直接返回
            [LoginManage sharedInstance].isSignAgreementState = true;
            return;
        }
        [LoginManage sharedInstance].isSignAgreementState = false;
        NSMutableArray<SOSAgreement *> *agreements = @[].mutableCopy;
        [types enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([response.allKeys containsObject:obj]) {
                SOSAgreement *model = [SOSAgreement mj_objectWithKeyValues:response[obj]];
                [agreements addObject:model];
               
            }
        }];
      
//        __weak __typeof(self)weakSelf = self;
//        [weakSelf addPopViewAction:^{
         //  SOSAgreementAlertView *view = [SOSAgreementAlertView new];
//            view.tag=-10000;
//            view.agreements = agreements;
//            view.agree = ^{
//                [SOSDaapManager sendActionInfo:TCPS_protocol_update_prompt_agree];
//                [weakSelf requestSignAgreements:agreements];
//                [weakSelf nextPopViewAction];
//            };
//            view.disagree = ^{
//                [SOSDaapManager sendActionInfo:TCPS_protocol_update_prompt_reject];
//                [weakSelf nextPopViewAction];
//                #if __has_include("SOSSDK.h")
//                                [weakSelf doLogout];
//                                [SOSSDK sos_dismissOnstarModule];
//                #else
//                                [weakSelf doLogout];
//                #endif
//
//            };
//
//            NSLog(@"xiexin=%@",[SOS_APP_DELEGATE fetchRootViewController]);
//            NSLog(@"xiexinview=%@",[SOS_APP_DELEGATE fetchRootViewController].view );
//            NSLog(@"window=%@",  [UIApplication sharedApplication].delegate.window);
//
//            if([SOS_APP_DELEGATE fetchRootViewController].view != nil&&
//               [[SOS_APP_DELEGATE fetchRootViewController].view respondsToSelector:@selector(viewWithTag:)]){
//
//                if(![[SOS_APP_DELEGATE fetchRootViewController].view viewWithTag:-10000]){
//
//                   //[view showInView:[SOS_APP_DELEGATE fetchRootViewController].view];
//                 }
//             }
//
//        }];
        
   
        
        
        SOSCheckLawAgreementView *contentView =[[SOSCheckLawAgreementView alloc] initWithFrameAndData:agreements];
        SOSFlexibleAlertController *ac = [SOSFlexibleAlertController
                                          alertControllerWithImage:nil
                                          title:@"服务协议和隐私政策"
                                          message:nil
                                          customView:contentView
                                          preferredStyle:SOSAlertControllerStyleAlert
                                          isOnStarStyle:true];
        
        ac.margins=40;
        [ac setTitleFont:[UIFont boldSystemFontOfSize:16]];
        
        contentView.tapAgreement2 = ^(NSInteger line,  SOSAgreement *model) {
            
            NSString *url = model.url;
            NSString *title = model.docTitle;
 
            UIView *popView=[[UIView alloc] init];
           popView.height=350;
            popView.width=SCREEN_WIDTH-80;
            popView.top=15;
        //   popView.backgroundColor=[UIColor yellowColor];
            
            
            WKWebView *webView = WKWebView.new;
          //  webView.scrollView.contentInset = UIEdgeInsetsMake(0, 20, 0, 20);
            webView.top=20;
            webView.left=20;
            webView.height = 350;
             webView.width = popView.width-40;
            webView.navigationDelegate=self;
            
            [webView loadRequest:   [NSURLRequest requestWithURL: [NSURL URLWithString:url]]];
            [popView addSubview:webView];
            
        
            SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:nil
                                                                                            title:title
                                                                                          message:nil
                                                                                       customView:popView
                                                                                   preferredStyle:SOSAlertControllerStyleAlert
                                                                                    isOnStarStyle:true];
     
            
            vc.margins=40;
            SOSAlertAction *ac0 = [SOSAlertAction actionWithTitle:@"确定" style:SOSAlertActionStyleDefault handler:^(SOSAlertAction * _Nonnull action) {
            }];
            [vc addActions:@[ac0]];
            [vc show];
            
        };
        __weak __typeof(self)weakSelf = self;
        SOSAlertAction *acCancel = [SOSAlertAction actionWithTitleOnStarStyle:@"不同意"
                                                             style:SOSAlertActionStyleCancel
                                        
                                                           handler:^(SOSAlertAction * _Nonnull action) {
            [SOSDaapManager sendActionInfo:TCPS_protocol_update_prompt_reject];
                         [weakSelf nextPopViewAction];
                         #if __has_include("SOSSDK.h")
                                         [weakSelf doLogout];
                                         [SOSSDK sos_dismissOnstarModule];
                         #else
                                         [weakSelf doLogout];
                         #endif
        
             
           
        }];
        
        SOSAlertAction *acConfirm = [SOSAlertAction actionWithTitleOnStarStyle:@"同意"
                                                              style:SOSAlertActionStyleDefault
                            
                                                            handler:^(SOSAlertAction * _Nonnull action) {
            
            [SOSDaapManager sendActionInfo:TCPS_protocol_update_prompt_agree];
                      [weakSelf requestSignAgreements:agreements];
                  [weakSelf nextPopViewAction];
        
            
        }];
        
        NSLog(@"根目录3=%@",  SOS_ONSTAR_WINDOW.rootViewController );
        NSLog(@"根目录3-keywindow=%@",  SOS_KEY_WINDOW);
        NSLog(@"根目录3-sowwindow=%@",  SOS_ONSTAR_WINDOW);
        NSLog(@"根目录3-delegate-window=%@",  SOS_BUICK_WINDOW);
        [ac addActions:@[acCancel, acConfirm]];
        [ac show];
        
//        SOS_ONSTAR_WINDOW.backgroundColor=[UIColor clearColor];
//
//        [SOS_APP_DELEGATE fetchRootViewController].view.backgroundColor=[UIColor clearColor];
//        [SOS_ONSTAR_WINDOW.rootViewController presentViewController:ac animated:true completion:nil];
 
      
     
        
        
        
        
    } fail:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [LoginManage sharedInstance].isClickShowOnstarModule = false;
        [LoginManage sharedInstance].isSignAgreementState=false;
    }];
}

- (void)requestSignAgreements:(NSArray<SOSAgreement *> *)agreements {
    [SOSAgreement requestSignAgreements:agreements success:^(NSDictionary *response) {
        
      
        
    } fail:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
     
        [Util toastWithMessage:responseStr];
//        [self doLogout];
    }];
}

//车辆相关操作，需要PIN码验证
- (NSString *)oauthUpgrade:(NSString *)code     {
    __block NSString *errorCode = nil;
    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_URL, ONSTAR_API_UPGRADE];
    NNUpgradeRequest *request = [[NNUpgradeRequest alloc] init];
    [request setClient_id:@"REMOTE_LINK_IOS_OAUTH_6"];
    [request setCredential_type:@"PIN"];
    [request setCredential:code];
    [request setDevice_id:[OpenUDID value]];
    [request setNonce:[Util generateNonce]];
    [request setTimestamp:[Util generateTimeStamp]];
    
    NSString *inputStr = [request mj_JSONString];
    NSLog(@"Upgrade Json string: [%@]", inputStr);
    
    NSString *encodedStr = [NSString jwtEncode:inputStr];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:encodedStr successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        if (operation.statusCode == 200) {
            NSLog(@"========== OAuth upgrade successful!");
            [[LoginManage sharedInstance] setAccessTokenLevel:ACCESS_TOKEN_LEVEL_UPGRADED];
            self.pinCode = code;
            [self savePinCode:code];
            errorCode = @"0";
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        NSLog(@"======== response [%@]", responseStr);
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        if (dic) {
            errorCode =[dic objectForKey:@"code"];
            if ([errorCode isEqualToString:@"L7_304"]) {
                errorCode = @"1";//最多输错10次
            }	else if ([errorCode isEqualToString:@"L7_305"])	{
                errorCode = @"2";//输错10次被锁
            }	else	{
                if ([responseStr myContainsString:@"lock"]) {
                    errorCode = @"2";
                }	else	{
                    errorCode = responseStr;//call IG failed
                }
            }
        }
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation startSync];
    return errorCode;
}

static BOOL retryFlag = NO;

#pragma mark - 验证Pin码
- (NSString *)oAuthPinReAuthToken:(NSString *)code     {
    __block NSString *errorCode = nil;
    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_URL, ONSTAR_API_OAUTH];
    NNOAuthRequest *request = [[NNOAuthRequest alloc] init];
    [request setClient_id:@"REMOTE_LINK_IOS_OAUTH_6"];
    [request setGrant_type:@"urn:onstar:params:oauth:grant-type:jwt-bearer-pin"];
    [request setAssertion:_idToken];
    [request setPin:code];
    [request setScope:[NSString stringWithFormat:@"%@ priv", self.scope]];
    [request setDevice_id:[OpenUDID value]];
    [request setNonce:[Util generateNonce]];
    [request setTimestamp:[Util generateTimeStamp]];
    
    NSString *inputStr = [request mj_JSONString];
    NSLog(@"PinReauth Json string: [%@]", inputStr);
    
    NSString *encodedStr = [NSString jwtEncode:inputStr];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:encodedStr successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        if ([responseStr length] > 0) {
            NSString *decodedStr = [NSString jwtDecode:responseStr];
            NSLog(@"======== reauth response decoded string [%@]", decodedStr);
            NNOAuthLoginResponse *response = [NNOAuthLoginResponse mj_objectWithKeyValues:[Util dictionaryWithJsonString:decodedStr]];
            self.accessToken = [response access_token];
            self.tokenType = [response token_type];
            self.expires_in = [response expires_in];
            self.accessTokenLevel = ACCESS_TOKEN_LEVEL_UPGRADED;
            self.tokenExpireDate = [NSDate dateWithTimeIntervalSinceNow:[self.expires_in doubleValue] - SAFE_THRESHOLD];
            self.tokenExpireTimeInterval = [[NSDate date] timeIntervalSince1970] + ([self.expires_in doubleValue] - SAFE_THRESHOLD);
            self.pinCode = code;
            [self savePinCode:code];
            errorCode = @"0";
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        NSLog(@"======== response [%@]", responseStr);
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        if (dic) {
            NSString *errorCode =[dic objectForKey:@"code"];
            if ([errorCode isEqualToString:@"L7_304"]) {
                errorCode = @"1";//最多输错10次
            }else if([errorCode isEqualToString:@"L7_305"]){
                errorCode = @"2";//输错10次被锁
            }else{
                errorCode = @"3";//call IG failed
            }
        }
    }];
    //[operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation startSync];
    return errorCode;
}

- (void)startMonitorToken     {
    [self startMonitorTokenInSec:0];
    /*
     tokenMonitorTimer = [NSTimer scheduledTimerWithTimeInterval:[_expires_in doubleValue] - SAFE_THRESHOLD target:self selector:@selector(oAuthReAuthTokenInBackground) userInfo:nil repeats:YES];
     [[NSRunLoop currentRunLoop] addTimer:tokenMonitorTimer forMode:NSRunLoopCommonModes];
     [[NSRunLoop currentRunLoop] run];
     */
}

- (NSTimeInterval)accessTokenTimeLeft     {
    NSTimeInterval timeLeft = 0;
    if (self.accessToken && self.enterBackgroundTimeInterval > 0) {
        timeLeft = self.tokenExpireTimeInterval - self.enterBackgroundTimeInterval;
    } else {
        timeLeft = 0;
    }
    return timeLeft;
}

- (void)upgradeToken     {
    if ([self needVerifyPin]) {
        [self upgradeToken:pinCode];
    }
}

- (NSString *)upgradeToken:(NSString *)inputPin     {
    NSString *errorCode = nil;
    if ([self checkNeedRefresh]) {
        // 后半段重新获取accesstoken，如果成功则需要重启timer。
        errorCode = [self oAuthPinReAuthToken:inputPin];
        if ([errorCode isEqualToString:@"0"]) {
            NSInteger period = [_expires_in integerValue] - SAFE_THRESHOLD;
            [self restartMonitorTokenInSec:period];
        }
    } else {
        errorCode = [self oauthUpgrade:inputPin];
    }
    return errorCode;
}

- (BOOL)needVerifyPin     {
    return [self accessTokenLevel] == ACCESS_TOKEN_LEVEL_NORMAL;
}

- (BOOL)checkNeedRefresh     {
    /* timer的启动时间，根据间隔时间取模的值来判断。 */
    NSInteger period = [_expires_in integerValue] - SAFE_THRESHOLD;
    NSDate *startDate = [NSDate dateWithTimeInterval:- (period) sinceDate:[tokenMonitorTimer fireDate]];
    NSInteger deltaTime = [[NSDate date] timeIntervalSinceDate:startDate];
    NSInteger reminder = deltaTime % period;
    return reminder > (period / 2);
}

- (NSString *)authorization     {
    if(_tokenType ==nil || _accessToken == nil){
        return @"Authorization";
    }   else    {
        return [NSString stringWithFormat:@"%@ %@", _tokenType, _accessToken];
    }
}

#pragma mark - 监控Token
- (void)restartMonitorTokenInSec:(NSInteger)delaySec     {
    [self stopMonitorToken];
    [self startMonitorTokenInSec:delaySec];
}

- (void)stopMonitorToken     {
    if (refreshTokenTimer) {
        dispatch_source_cancel(refreshTokenTimer);
        //        dispatch_suspend(refreshTokenTimer); //Suspend停止Timer，已经释放Timer
    }
    /*
     [tokenMonitorTimer invalidate];
     tokenMonitorTimer = nil;
     */
}

- (void)startMonitorTokenInSec:(NSInteger)delaySec     {
    
    delaySec=delaySec;
    
    NSLog(@"delaySec=%ld",(long)delaySec);
    NSLog(@"_expires_in=%f",[_expires_in doubleValue] - SAFE_THRESHOLD);
    //([_expires_in doubleValue] - SAFE_THRESHOLD) * NSEC_PER_SEC
    
    //提前4分钟更新token, 间隔时间也为26分钟
    if ([_expires_in doubleValue] - SAFE_THRESHOLD > 0) { //保证时间间隔大于0
        refreshTokenTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, refreshQueue);
        dispatch_source_set_timer(refreshTokenTimer, dispatch_time(DISPATCH_TIME_NOW, delaySec * NSEC_PER_SEC), ([_expires_in doubleValue] - SAFE_THRESHOLD) * NSEC_PER_SEC, 0);
        //定期刷新token
        __block __weak LoginManage *weakSelf = self;
        dispatch_source_set_event_handler(refreshTokenTimer, ^{
          //  [SOSSDK shareInstance].loginState = SOSSDKLoginStateNone;
            //[self resetLoginInstance];
            [weakSelf oAuthReAuthToken:NO];
        });
        
        
        dispatch_resume(refreshTokenTimer);
    }
}

static NSInteger loadCommandsNum = 0;
//异步刷新Commands，如果获取失败则重试2次
- (void)asyncGet3SupportedCommands:(BOOL)isExpired
{
    loadCommandsNum++;
    if (isExpired) {
        [LoginManage sharedInstance].loadingUserProfile = LOGIN_LOADING_USER_PROFILE_INPROGRESS;
        NSLog(@"正在异步获取车辆Commands:第%@次， 缓存已过期",@(loadCommandsNum));
    }
    else
    {
        NSLog(@"正在异步获取车辆Commands:第%@次， 缓存未过期",@(loadCommandsNum));
    }
    NSString *url =[NSString stringWithFormat:(@"%@" ONSTAR_API_COMMANDS), BASE_URL, [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
//    NSDate *startDt = [NSDate date];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        loadCommandsNum = 0;
        //如果正在获取异步信息，用户去设置画面点击退出登录，不要做任何操作
        if ([LoginManage sharedInstance].loginState!=LOGIN_STATE_LOADINGTOKENSUCCESS)return ;
//        [self reportStartTime:startDt code:@"LoginGetCommand" value:@"success" fid:AutoLogin_GetCommand];
        [LoginManage sharedInstance].loadingUserProfile = LOGIN_LOADING_USER_PROFILE_NON;
        if ([responseStr length]>0) {
            [self saveVehicleCommands:responseStr];
            [Util assginVehicleCommansData:responseStr];
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        //如果正在获取异步信息，用户去设置画面点击退出登录，不要做任何操作
        if ([LoginManage sharedInstance].loginState!=LOGIN_STATE_LOADINGTOKENSUCCESS)
        {
            loadCommandsNum = 0;
            return ;
        }
//        [self reportStartTime:startDt code:@"LoginGetCommand" value:@"fail" fid:AutoLogin_GetCommand];
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        NNError * comerror;
        comerror = [NNError mj_objectWithKeyValues:dic];
        
        if (loadCommandsNum<=2) {
            [self asyncGet3SupportedCommands:isExpired];
        }
        else
        {
            loadCommandsNum = 0;
            if (isExpired) {
                //如果缓存已经过期，获取command失败则需要toast提示且不能做操作
                [LoginManage sharedInstance].loadingUserProfile = LOGIN_LOADING_USER_PROFILE_FAILURE;
                [Util toastWithMessage:@"您的信息获取失败，请重新登录或联系安吉星客服。"];
            }
        }
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];
}

- (void)logoutFromSever{
    NSString *url = [NSString stringWithFormat:@"%@%@%@", BASE_URL, ONSTAR_API_OAUTH,@"?removeIdToken=true"];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        if (operation.statusCode == 200) {
            NSLog(@"Sever端删除idtoken成功");
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
//        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
//        NNError * comerror;
//        comerror = [NNError mj_objectWithKeyValues:dic];
        NSLog(@"Sever端删除idtoken失败!%@",responseStr);
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"DELETE"];
    [operation start];
}

/**
 非Mobile注册用户需要验证
 */
- (void)processNotMobileRegistUser
{
    [[LoadingView sharedInstance] stop];
//    NSString * tempidToken = self.idToken;
//    NSString * tempTokenScope = self.scope;
    [self doLogout];
  dispatch_async(dispatch_get_main_queue(), ^{
//#if __has_include("SOSSDK.h")
  //      [SOSSDK sos_showOnstarModuleWithDismissBlock:nil];
//#endif
//        [Util showAlertWithTitle:nil message:NSLocalizedString(@"Need_Verify_User",nil) completeBlock:^(NSInteger buttonIndex) {
//            if (!currentUserName) {
//                currentUserName = UserDefaults_Get_Object(NN_CURRENT_USERNAME);
//            }
//            SOSBBWCEduWebVC *moreVc = [[SOSBBWCEduWebVC alloc] initWithUrl:[NSString stringWithFormat:INFO3_NOT_APP_USER_LOGIN,currentUserName]];
//            [moreVc setCloseCompleteBlock:^(){
////                if (self.idToken == nil) {
////                    //设置回token
////                    [self saveToken:tempidToken withScope:tempTokenScope];
////                    self.idToken = tempidToken;
////                }
//                [[LoadingView sharedInstance] startIn:_loginNav.view];
//                // **/
//                //清除profile数据库记录,因为profile可能发生改变了,需要重新获取
//                [[SOSLoginUserDbService sharedInstance] clearDB];
//                [SOSUtil clearLoginUserRecord];
//                [self oAuthLoginWithUserName:currentUserName password:tempPwd];
//            }];
////            UINavigationController *personNav =  (UINavigationController *)([SOS_APP_DELEGATE fetchMainNavigationController]);
////            [personNav presentViewController:moreVc animated:YES completion:nil];
//
//            if (_loginNav.presentingViewController) {
//                [_loginNav pushViewController:moreVc animated:YES];
//            }
//            else
//            {
//                [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:moreVc animated:YES];
//            }
//        } cancleButtonTitle:@"立即验证" otherButtonTitles:nil];
        
        
        
        [SOSUtil showCustomAlertWithTitle:@"" message:NSLocalizedString(@"Need_Verify_User",nil)  cancleButtonTitle:@"立即验证" otherButtonTitles:nil    completeBlock:^(NSInteger buttonIndex){

            if (!currentUserName) {
                currentUserName = UserDefaults_Get_Object(NN_CURRENT_USERNAME);
            }
            SOSBBWCEduWebVC *moreVc = [[SOSBBWCEduWebVC alloc] initWithUrl:[NSString stringWithFormat:INFO3_NOT_APP_USER_LOGIN,currentUserName]];
            [moreVc setCloseCompleteBlock:^(){
//                if (self.idToken == nil) {
//                    //设置回token
//                    [self saveToken:tempidToken withScope:tempTokenScope];
//                    self.idToken = tempidToken;
//                }
                [[LoadingView sharedInstance] startIn:_loginNav.view];
                // **/
                //清除profile数据库记录,因为profile可能发生改变了,需要重新获取
                [[SOSLoginUserDbService sharedInstance] clearDB];
                [SOSUtil clearLoginUserRecord];
                [self oAuthLoginWithUserName:currentUserName password:tempPwd];
            }];
//            UINavigationController *personNav =  (UINavigationController *)([SOS_APP_DELEGATE fetchMainNavigationController]);
//            [personNav presentViewController:moreVc animated:YES completion:nil];

            if (_loginNav.presentingViewController) {
                [_loginNav pushViewController:moreVc animated:YES];
            }
            else
            {
                [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:moreVc animated:YES];
            }
        }];
    });

}

- (void)setLoginState:(LOGIN_STATE_TYPE)loginState {
    if (_sdkStateCallBack) {
        _sdkStateCallBack(loginState);
    }
    _loginState = loginState;
}


/**
 重新加载登录主接口中失败的接口
 */
- (void)reLoadMainInterface
{
    if (_failedMainInterfaceArray.count >0 ) {
    NSNumber * failStep = [_failedMainInterfaceArray objectAtIndex:0];
    switch (failStep.integerValue ) {
        case LOGIN_STATE_LOADINGUSERBASICINFOFAIL:
        {
            [self loadUserBasicInfoFromCache:NO];
        }
            break;
        case LOGIN_STATE_LOADINGVEHICLECOMMANDSFAIL:
        {
            [self loadVehicleCommandsFromCache:NO needLoadSecondaryResource:NO];
        }
            break;
        case LOGIN_STATE_LOADINGVEHICLEPRIVILIGEFAIL:
        {
            [self loadVehiclePrivilegeFromCache:NO];
        }
            break;

            
        default:
            break;
    }
    }
}
/**
 是否加载某个主接口失败
 @return
 */
- (BOOL)isLoadingMainInterfaceFail;
{
    return self.loginState < 0 ;
}
/**
 是否完成Token接口
 @return
 */
- (BOOL)isLoadingTokenReady;
{
     return self.loginState < LOGIN_STATE_LOADINGTOKENFAIL || self.loginState >= LOGIN_STATE_LOADINGTOKENSUCCESS;
}
/**
 是否完成加载用户基本信息,此时已经得到绝大部分用户信息
 @return
 */
- (BOOL)isLoadingUserBasicInfoReady;
{
    return self.loginState < LOGIN_STATE_LOADINGUSERBASICINFOFAIL || self.loginState >= LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS;
}
/**
 是否完成加载车辆支持Commands
 @return
 */
- (BOOL)isLoadingVehicleCommandsReady;
{
    return self.loginState < LOGIN_STATE_LOADINGVEHICLECOMMANDSFAIL || self.loginState >= LOGIN_STATE_LOADINGVEHICLECOMMANDSESUCCESS;
}
/**
 完成加载用户基本信息或者未登录
 @return
 */
- (BOOL)isLoadingUserBasicInfoReadyOrUnLogin;
{
    return self.loginState < LOGIN_STATE_LOADINGUSERBASICINFOFAIL || self.loginState >= LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS || self.loginState == LOGIN_STATE_NON;
}
/**
 是否完成登录的4个主要接口
 @return
 */
- (BOOL)isLoadingMainInterfaceReady;
{
    return  self.loginState == LOGIN_STATE_LOADINGVEHICLEPRIVILIGESUCCESS;
}
/**
 完成登录的4个主要接口或者Unlogin
 @return
 */
- (BOOL)isLoadingMainInterfaceReadyOrUnlogin;
{
    return  self.loginState == LOGIN_STATE_LOADINGVEHICLEPRIVILIGESUCCESS || self.loginState == LOGIN_STATE_NON;
}
/**
 正在登录的4个主要接口ING
 @return
 */
- (BOOL)isInLoadingMainInterface;
{
    return self.loginState >0 && self.loginState % 2 != 0 ;
}
/**
// 当前是否处于加载用户主要信息的接口过程中
// @return
// */
//- (BOOL)isLoadingMainUserProfile
//{
//    return self.loginState != LOGIN_STATE_NON && self.loginState % 2 == 0;
//}
//
///**
// 当前是否已经顺利完成登录主要接口
// @return
// */
//- (BOOL)isLoadMainUserProfileFinish
//{
////    return self.loginResult >= LOGIN_USERVEHICLEPRIVILEGE_RESULT_SUCCESS;
//}
#pragma mark -Pop Action
- (void)addPopViewAction:(void (^)(void))popAction;
{
   @synchronized (self) {
        if (!popQueue) {
            popQueue = [[NSOperationQueue alloc] init];
            popQueue.name = @"onstar.pop";
            popQueue.maxConcurrentOperationCount = 1;
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNext) name:sosKNeedPopNotify object:nil];
        }
        __weak __typeof (self)weakSelf = self;
        [popQueue addOperationWithBlock:^{
             __strong __typeof(weakSelf)strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), popAction);
            if (!strongSelf->popQueue.isSuspended) {
                 [strongSelf->popQueue setSuspended:YES];
            }
        }];
    }
}
//- (void)processNext
//{
//    @synchronized (self) {
//           if (popQueue && popQueue.suspended) {
//                  [popQueue setSuspended:NO];
//              }
//       }
//}
- (void)nextPopViewAction{
    @synchronized (self) {
              if (popQueue && popQueue.suspended) {
                     [popQueue setSuspended:NO];
                 }
          }
}
-(void)clearPopQueue{
    if (popQueue) {
        [popQueue cancelAllOperations];
    }
}
#pragma mark-
- (void)setLoginSuccessAction:(void (^)(void))loginSuccessAction {
    !loginSuccessAction?:loginSuccessAction();
    _loginSuccessAction = loginSuccessAction;
    if (!loginSuccessAction) {
        self.loginSuccessActionActivity = NO;
    }

}


@end
