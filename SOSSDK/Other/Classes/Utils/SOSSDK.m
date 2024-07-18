//
//  SOSUtils.m
//  SOSSDK
//
//  Created by onstar on 2018/1/2.
//

#import "SOSSDK.h"
//#import "SOSDefines.h"
#import "AppDelegate_iPhone.h"
#import "SOSExtension.h"
#import "SOSRegisterInformation.h"
#import "OwnerViewController.h"
#import "PushNotificationManager.h"
#import "ClientTraceIdManager.h"
#import "SOSLoginUserDbService.h"
#import "VersionManager.h"
#import <Toast/Toast.h>
#import "SOSEnvConfig.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "UIImage+GIFImage.h"
//#import "FLBFlutterViewContainer.h"
//#import "SOSFlutterManager.h"

#if __has_include(<BlePatacSDK/BlueToothManager.h>)
#import "BlueToothManager+SOSBleExtention.h"
#endif


@interface SOSSDK ()
 
/**
 回到buick首页回调
 [SOSSDK shareInstance].sosDismissCallBack = ^{
 //可以做一些UI处理
 //如设置回buick导航 全局颜色...
 };
 */
@property (nonatomic, copy) void(^sosDismissCallBack)(void);


@property (nonatomic, strong, readwrite) UINavigationController *buickLoginViewController;

@property (nonatomic, copy) SetLoginViewControllerBlock setLoginViewControllerBlock;


 

@end


static bool isInitSosConfig=false;

@implementation SOSSDK
 

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static SOSSDK *_instance;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        _instance.loginState = SOSSDKLoginStateNone;
    });
    
    return _instance;
}

- (UINavigationController *)buickLoginViewController {

    NSAssert(self.setLoginViewControllerBlock, @"请先调用'sos_setLoginVc'");

    UIViewController *buickLoginViewController = self.setLoginViewControllerBlock();
    NSAssert(buickLoginViewController, @"请正确调用'sos_setLoginVc'");
    CustomNavigationController *navc = [[CustomNavigationController alloc] initWithRootViewController:buickLoginViewController];
    return navc;
}

+ (void)sos_setLoginVc:(SetLoginViewControllerBlock)setLoginViewControllerBlock {
    [SOSSDK shareInstance].setLoginViewControllerBlock = setLoginViewControllerBlock;
}


/**
 登录调用
 
 @param name 登录用户名
 @param pwd 登录密码
 */
+ (void)sos_loginWithLoginName:(NSString *)name
                      loginPwd:(NSString *)pwd
{
    
    [LoginManage sharedInstance].isClickShowOnstarModule = false;
    if ([LoginManage sharedInstance].loginState != LOGIN_STATE_NON) {
        [self sos_logOut:NO];
    }
 
    [[LoginManage sharedInstance] loginFromViewController:nil
                                             withUserName:name
                                                 password:pwd stateWatcher:nil];
    
}
+ (void)sos_loginByTicket:(NSString *)ticket
                idpUserId:(NSString *)idp{
    [self sos_loginWithLoginName:idp loginPwd:ticket];
}
+ (void)sos_loginByTicket:(NSString *)ticket
                idpUserId:(NSString *)idp
              loginStatusCallBack:(void(^)(SOSLoginState type))loginStateChangeCallBack{
 
    [LoginManage sharedInstance].isClickShowOnstarModule = false;
    [[LoginManage sharedInstance] loginFromViewController:nil
                                             withUserName:idp
                                                 password:ticket stateWatcher:^(LOGIN_STATE_TYPE type) {
        
        if (type == LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS) {
            [SOSSDK shareInstance].loginState = SOSSDKLoginStateSuccess;
           if (loginStateChangeCallBack) {
               loginStateChangeCallBack(SOSSDKLoginStateSuccess);
           }
            
        }else if (type == LOGIN_STATE_LOADINGTOKENFAIL || type == LOGIN_STATE_LOADINGUSERBASICINFOFAIL  ) {
            
            [SOSSDK shareInstance].loginState = SOSSDKLoginStateFail;
              if (loginStateChangeCallBack) {
                  loginStateChangeCallBack(SOSSDKLoginStateFail);
              }
        }
        else if ( type == LOGIN_STATE_NON){
            
            [SOSSDK shareInstance].loginState = SOSSDKLoginStateNone;
              if (loginStateChangeCallBack) {
                  loginStateChangeCallBack(SOSSDKLoginStateNone);
              }
        }
        
    }];
    
}

/**
 退出登录调用
 note:buick退出时需同时调用
 */
+ (void)sos_logOut:(BOOL)pop {
    [[SOS_APP_DELEGATE fetchMainNavigationController] popToRootViewControllerAnimated:NO];
    [[LoginManage sharedInstance] doLogout];
    [[ClientTraceIdManager sharedInstance] resetClientTraceId];
}

+ (void)sos_logOut {
    [self sos_logOut:YES];
}

- (void)setEnv:(SOSEnv)env {
    _env = env;
    [SOSEnvConfig config].sos_env = env;
    [SOSEnvConfig config].development = (env != SOSEnvRelease);
}

/**
 获得SOS注册页面
 
 @return 注册vc
 */
+ (UIViewController *)sos_getRegisterViewController {
//    [[SOSReportService shareInstance] recordActionWithFunctionIDMA80:Register];
    OwnerViewController *ownerVC= [[OwnerViewController alloc]initWithNibName:@"OwnerViewController" bundle:nil];
    [SOSRegisterInformation sharedRegisterInfoSingleton].registerWay = SOSRegisterWayNormalRegister;
    return ownerVC;
}


+ (nullable UIViewController *)sos_getVehicleCondationViewControllerWithController:(UIViewController*)caller{
//    if (![SOSFlutterManager shareInstance].buick_cond_942_ios) {
//           return nil;
//    }else{
////        FLBFlutterViewContainer *vc = FLBFlutterViewContainer.new;
////        [vc setName:@"vehicle://vehicle_condition_page" params:@{@"type":[NSNumber numberWithInt:0]}];
//////        [caller addChildViewController:vc];
//////        [caller didMoveToParentViewController:vc];
//////        [caller.view addSubview:vc.view];
////        return vc;
//    }
    return nil;
}



+ (void) sos_initApp{
    
    if(!isInitSosConfig){//只初始化一次,知道程序结束才能重新初始化
        AppDelegate_iPhone * mydelegate =  [UIApplication sharedApplication].delegate;
       [mydelegate didFinishLaunchingWithOptionsLazyLoading];
       isInitSosConfig=true;
    }
    
    
}

+ (void)sos_showOnstarModuleWithDismissBlock:(void(^)(void))dismissBlock {
    
    [LoginManage sharedInstance].isClickShowOnstarModuleCount = 0;
    if (SOS_BUICK_PRODUCT) {//别克在这里初始化,凯迪在这里初始化有问题,他使用sos_initApp来初始化
        
        if(!isInitSosConfig){//只初始化一次,知道程序结束才能重新初始化
            AppDelegate_iPhone * mydelegate =  [UIApplication sharedApplication].delegate;
           [mydelegate didFinishLaunchingWithOptionsLazyLoading];
           isInitSosConfig=true;
        }
        
    }
 
  
    [self configUIAppearacne];

    if (dismissBlock) {
        [SOSSDK shareInstance].sosDismissCallBack = dismissBlock;
    }
    id vc = [SOS_APP_DELEGATE fetchRootViewController];
//    id vc = [(AppDelegate_iPhone *)[UIApplication sharedApplication].delegate mainVC];
    NSLog(@"mainVC === %@",vc);
    SOS_ONSTAR_WINDOW.rootViewController = vc;
    [SOS_ONSTAR_WINDOW makeKeyAndVisible];
//    SOS_ONSTAR_WINDOW.alpha = 0;
    SOS_ONSTAR_WINDOW.hidden = NO;
    [UIView transitionWithView:SOS_ONSTAR_WINDOW
                      duration:0.15f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
//                        SOS_ONSTAR_WINDOW.alpha = 1;
                    } completion:nil];
    [[VersionManager sharedInstance] checkNewVersion];
    
 
//    if([LoginManage sharedInstance].loginResult==LOGIN_RESULT_TOKENSUCCESS){
//        [[LoginManage sharedInstance] loadTCPSNeedConfirm];
//    }
   
    [LoginManage sharedInstance].isClickShowOnstarModule = true;

}

+ (void)sos_dismissOnstarModule {
    if ([SOSSDK shareInstance].sosDismissCallBack) {
        [SOSSDK shareInstance].sosDismissCallBack();
    }
    
    [UIView transitionWithView:SOS_BUICK_WINDOW
                      duration:0.15f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
//                        SOS_ONSTAR_WINDOW.alpha = 0;
                    } completion:^(BOOL finished) {
                        SOS_ONSTAR_WINDOW.hidden = YES;
                        SOS_BUICK_WINDOW.hidden = NO;
                        [SOS_BUICK_WINDOW makeKeyAndVisible];
                        
                        [self configDefaultSVPHUDStyle];
                        
                    }];
    
}


//微信
+ (NSString *)wxKey {
    return [SOSSDKKeyUtils wxKey];
}

//高德
+ (NSString *)mapKey {
    return [SOSSDKKeyUtils mapKey];
}

//OCR
+ (NSString *)idCardKey {
    return [SOSSDKKeyUtils idCardKey];
}


+ (void)configUIAppearacne {

    //全局UI设置
    [UISwitch appearance].onTintColor = [UIColor colorWithRGB:0x1D81DD];
    [SVProgressHUD setSuccessImage:[UIImage imageWithGIFNamed:@"icon_feedback_success_48x48"]];
    [SVProgressHUD setInfoImage:[UIImage imageWithGIFNamed:@"icon_feedback_attention_48x48"]];
    [SVProgressHUD setErrorImage:[UIImage imageWithGIFNamed:@"icon_feedback_fail_48x48"]];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setCornerRadius:4];
//    [SVProgressHUD setHapticsEnabled:YES];
    [SVProgressHUD setMinimumSize:CGSizeMake(110, 0)];
    [SVProgressHUD setImageViewSize:CGSizeMake(48, 48)];
    [SVProgressHUD setMaximumDismissTimeInterval:2];
    [SVProgressHUD setMinimumDismissTimeInterval:2];
    [SVProgressHUD setFont:[UIFont systemFontOfSize:14]];
    [SVProgressHUD setMaxSupportedWindowLevel:UIWindowLevelNormal + 1];
    [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[CustomNavigationController class]]].tintColor = [UIColor colorWithHexString:@"067FE0"];

}

+ (void)configDefaultSVPHUDStyle {
    NSBundle *bundle = [NSBundle bundleForClass:[SVProgressHUD class]];
    NSURL *url = [bundle URLForResource:@"SVProgressHUD" withExtension:@"bundle"];
    NSBundle *imageBundle = [NSBundle bundleWithURL:url];
    [SVProgressHUD setInfoImage: [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"info" ofType:@"png"]]];
    [SVProgressHUD setSuccessImage:[UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"success" ofType:@"png"]]];
    [SVProgressHUD setErrorImage:[UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"error" ofType:@"png"]]];
    //                        [SVProgressHUD setLoadingImage:nil];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    [SVProgressHUD setImageViewSize:CGSizeMake(28, 28)];
    [SVProgressHUD setMinimumSize:CGSizeZero];
    [SVProgressHUD setCornerRadius:14.0];
    [SVProgressHUD setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
}
@end
