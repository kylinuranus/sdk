
//
//  AppDelegate_iPhone.m
//  Onstar
//
//  Created by Alfred Jin on 1/4/11.
//  Copyright 2011 plenware. All rights reserved.
//


#import "AppDelegate_iPhone.h"
#import "AppDelegate_iPhone+SOSService.h"
#import "AppDelegate_iPhone+SOSOpenUrl.h"

#import "SOSHomeTabBarCotroller.h"
#import "SOSLandingViewController.h"
#import "IntroducePageViewController.h"
#import "SOSTempLandingController.h"
#import "SOSOnButtonSubclass.h"


#import "VersionManager.h"
#import "PushNotificationManager.h"
#import "FRDModuleManager.h"

#import <IQKeyboardManager/IQKeyboardManager.h>

#if __has_include("SOSSDK.h")
#import "SOSExtension.h"
#else
#import "SOSMusicPlayer.h"
#import <MiGuRunningMusicSDK/MiGuRunningMusicSDK.h>
#endif

#import "SOSSkinManager.h"
#import "SOSLaunchAdManager.h"
//#import "SOSFlutterDB.h"

 
#import "ISIDCardReaderController.h"
#import "ISVINReaderPreViewViewController.h"

@interface AppDelegate_iPhone ()
@property (nonatomic, strong) SOSHomeTabBarCotroller *mainVC;
@property (nonatomic, strong) UIApplication *applicationRef;
@property (nonatomic, strong) NSDictionary *launchOptionsRef;


@end

@implementation AppDelegate_iPhone

#pragma mark 程序入口


- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //生成Modules集合
    NSString* plistPath = [[NSBundle SOSBundle] pathForResource:@"ModulesRegister" ofType:@"plist"];
    FRDModuleManager *manager = [FRDModuleManager sharedInstance];
    [manager loadModulesWithPlistFile:plistPath];
    
   // [manager application:application willFinishLaunchingWithOptions:launchOptions];Modules未使用这个方法
    return YES;
}

 

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    
    self.applicationRef=application;
    self.launchOptionsRef=launchOptions;
    
    [MAMapView updatePrivacyShow:AMapPrivacyShowStatusDidShow privacyInfo:AMapPrivacyInfoStatusDidContain];
    [MAMapView updatePrivacyAgree:AMapPrivacyAgreeStatusDidAgree];

    
    
    NSLog(@"根目录2=%@",self.window);
//    NSLog(@"ISIDCardReaderController-getSDKVersion=%@", [ISIDCardReaderController getSDKVersion]);
//    NSLog(@"ISVINReaderPreViewViewController-getSDKVersion=%@", [[ISVINReaderPreViewViewController sharedISOpenSDKController] getSDKVersion]);
//
    return YES;
}
- (void)  didFinishLaunchingWithOptionsLazyLoading{
    
#ifndef SOSSDK_SDK
    self.useSkin = [SOSSkinManager hasNewSkin];
#endif
//    [SOSFlutterDB delEncryDBUnder10];
    [[FRDModuleManager sharedInstance] application: self.applicationRef didFinishLaunchingWithOptions:self.launchOptionsRef];
    
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    [IQKeyboardManager sharedManager].enable = YES; // IQKeyboardManager 管理键盘的第三方库（是个单例）
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    
    [self generateMainViewController];

//    安吉星设置root 引导页 SDK不需要
    if (SOS_ONSTAR_PRODUCT) {
        // 版本管理
        [[VersionManager sharedInstance] manageVersion];
        [[VersionManager sharedInstance] checkNewVersion];
        
        NSString *key = @"introducePageFirstTimeOpenApp90";
        BOOL flg = [[NSUserDefaults standardUserDefaults] boolForKey:key];
        if (flg) {  //第一次安装，landingpage与引导页2选一
            [self showLandingPage];
        }else {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self showIntroduce];
        }
        //启动后检测下当前网络状态
        [SOSNetworkOperation netWorkStatusStart];
    }
    
}


#pragma mark - Push Notification
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[FRDModuleManager sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[FRDModuleManager sharedInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [FRDModuleManager.sharedInstance application:application didReceiveRemoteNotification:userInfo];
}

#pragma mark - app life circle
- (void)applicationWillResignActive:(UIApplication *)application {
    [[FRDModuleManager sharedInstance] applicationWillResignActive:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[FRDModuleManager sharedInstance] applicationDidBecomeActive:application];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[FRDModuleManager sharedInstance] applicationDidEnterBackground:application];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[FRDModuleManager sharedInstance] applicationWillEnterForeground:application];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    [[FRDModuleManager sharedInstance] applicationWillTerminate:application];
}

#pragma mark - 3D Touch 相关
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    [[FRDModuleManager sharedInstance] application:application performActionForShortcutItem:shortcutItem completionHandler:completionHandler];
}


//允许使用第三方输入法
- (BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier     {
    if ([extensionPointIdentifier isEqualToString:APPLE_WATCH_NAME]) {
        // 允许apple watch
        return YES;
    }
    return YES;
}


- (void)showLandingPage {
//    [[LandingImageCache sharedInstance] requestLandingImageNew:^(LandingImage *landingImage) {
//        if (landingImage.imageUrl.length <= 0) {
//            [self showHomePage];
//        }else {
//            SOSLandingViewController *landingView = [[SOSLandingViewController alloc] init];
//            landingView.landingImage = landingImage;
//            [landingView setCompleteBlock:^{
//                [self showHomePage];
//            }];
//            [self.window setRootViewController:landingView];
//            [self.window makeKeyAndVisible];
//        }
//    }];
    [SOSLaunchAdManager.shareManager setup];
    [self showHomePage];
////    return;
//    SOSTempLandingController *tempC = [[SOSTempLandingController alloc] init];
//    [self.window setRootViewController:tempC];
//    [self.window makeKeyAndVisible];
}


- (void)showIntroduce {
    IntroducePageViewController *vc = [[IntroducePageViewController alloc] init];
    [vc setPreOver:^{
        if (!SOS_ONSTAR_PRODUCT)     {
            // 直接进入app
            [self showHomePage];
            return;
        };
        NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970] ;
        IntroducePageViewController *vc_1 = [[IntroducePageViewController alloc] init];
        vc_1.isPageGuideMode = YES;
        [vc_1 setPreOver:^{
            [SOSDaapManager sendSysLayout:startTime endTime:[[NSDate date] timeIntervalSince1970]  funcId:INTRODUCTION_STAYTIME];
            // 直接进入app
            [self showHomePage];
        }];
        self.window.rootViewController = vc_1;
    }];
    self.window.rootViewController = vc;
}


- (UINavigationController *)fetchMainNavigationController {
    return  self.mainVC.selectedViewController;
}
- (UITabBarController *)fetchRootViewController {
    return self.mainVC;
}

- (void)hideMainLeftMenu {
    [self.mainVC hideMenuViewController:nil];
}

- (void)showRootViewController	{
    NSString *key = @"introducePageFirstTimeOpenApp90";
    BOOL flg = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    if (flg) {
        // 直接进入app
        [self showHomePage];
    }	else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // 否则进入引导页
        IntroducePageViewController *vc = [[IntroducePageViewController alloc] init];
        [vc setPreOver:^{
            if (!SOS_ONSTAR_PRODUCT)     {
                // 直接进入app
                [self showHomePage];
                return;
            };
            NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970] ;
            IntroducePageViewController *vc_1 = [[IntroducePageViewController alloc] init];
            vc_1.isPageGuideMode = YES;
            [vc_1 setPreOver:^{
                [SOSDaapManager sendSysLayout:startTime endTime:[[NSDate date] timeIntervalSince1970] funcId:INTRODUCTION_STAYTIME];
                // 直接进入app
                [self showHomePage];
            }];
            self.window.rootViewController = vc_1;
        }];
        self.window.rootViewController = vc;
    }
}

/**
 *  主页＋侧滑
 */
- (void)generateMainViewController {
    SOSHomeTabBarCotroller *tabBarController = [[SOSHomeTabBarCotroller alloc] init];

    if (SOS_CD_PRODUCT || SOS_BUICK_PRODUCT) {
        tabBarController.selectedIndex = 1;    //避免点击landingPage时因fetchMainNavigationController返回nil无法跳转

    }else{
        [SOSOnButtonSubclass registerPlusButton];
        tabBarController.selectedIndex = 0;    //避免点击landingPage时因fetchMainNavigationController返回nil无法跳转
    }
    self.mainVC = tabBarController;
}



//咪咕音乐需要用到
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
#ifndef SOSSDK_SDK
    [[MiGuRunningMusicService sharedInstance] remoteControlReceivedWithEvent:event];
    [[SOSMusicPlayer sharedInstance] remoteControlReceivedWithEvent:event];
#endif
}
////////////////////////////



#pragma mark - 版本更新

- (void)showHomePage {
    [self.window setRootViewController:self.mainVC];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    CATransition *transition = [CATransition new];
    transition.type = kCATransitionFade;
    transition.duration = 0.3;
    [self.window.layer addAnimation:transition forKey:nil];
}
- (void)showHomePageWithComplete:(void(^)(void))complete {
    [self.window setRootViewController:self.mainVC];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    CATransition *transition = [CATransition new];
    transition.type = kCATransitionFade;
    transition.duration = 0.3;
    [self.window.layer addAnimation:transition forKey:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), complete);
}


// only for the case that need relogin.
- (void)switchLoginView     {
    // clear buick care cache
    [CustomerInfo sharedInstance].needContinuePolling = YES;
    [CustomerInfo sharedInstance].hasLogin = NO;
    [CustomerInfo sharedInstance].currentVehicle.needRefrshChargeMode = NO;
    
    [[LoginManage sharedInstance] doLogout];
}

- (sqlite3 *)database     {
    return database;
}

@end
