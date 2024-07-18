//
//  AppDelegate_iPhone.h
//  Onstar
//
//  Created by Alfred Jin on 1/4/11.
//  Copyright 2011 plenware. All rights reserved.
//

#import <SQLCipher/sqlite3.h>
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
//@class GetSubscriberInfoResponse;
//@class ViewControllerIntroducePage;

@interface AppDelegate_iPhone : UIResponder<UIApplicationDelegate> {
    sqlite3    *database;
    NSMutableDictionary * shareDestinationDict;
    NSString * shortLinkId;
}

//@property (nonatomic, strong) SOSSideViewController *rootTabBarVC;

@property (nonatomic, strong) UIWindow *window;
//@property (nonatomic, strong) GetSubscriberInfoResponse *subscriberResponse;
//@property (nonatomic, strong) GetSubscriberInfoResponse *tempSubscriberResponse;
//@property (nonatomic, assign) BOOL IsGoAppStore;
/**
 小O是否在使用
 */
@property(nonatomic,assign)BOOL isMroActive;
@property(nonatomic,assign)BOOL useSkin;

/**
 是否在播放云音乐
 */
@property(nonatomic,assign)BOOL isMusicPlaying;
/*
 是否开启前端监控
 */
@property(nonatomic,assign)BOOL isStartMonitor;

//@property (nonatomic, assign) BOOL isgsp;//兼容gsp版本
//@property (nonatomic, assign) BOOL prepaymentAvailable;//预付费卡可用状态,默认NO

- (void)switchLoginView;
- (void)showHomePage;
- (void)showHomePageWithComplete:(void(^)(void))complete;
- (sqlite3 *)database;

/**
 获取mainVC的contentNavigationController
 */
- (UINavigationController *)fetchMainNavigationController;

/**
 获取mainVC
 */
- (UITabBarController *)fetchRootViewController;

/**
 隐藏左边栏
 */
- (void)hideMainLeftMenu;

- (void)  didFinishLaunchingWithOptionsLazyLoading;
#warning SDK使用勿删
///子类继承
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions NS_REQUIRES_SUPER;
//- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken NS_REQUIRES_SUPER;
//- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error NS_REQUIRES_SUPER;
#pragma mark - app life circle
- (void)applicationWillResignActive:(UIApplication *)application NS_REQUIRES_SUPER;
- (void)applicationDidBecomeActive:(UIApplication *)application NS_REQUIRES_SUPER;
- (void)applicationDidEnterBackground:(UIApplication *)application NS_REQUIRES_SUPER;
- (void)applicationWillEnterForeground:(UIApplication *)application NS_REQUIRES_SUPER;
- (void)applicationWillTerminate:(UIApplication *)application NS_REQUIRES_SUPER;
#pragma mark - 3D Touch 相关
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler NS_REQUIRES_SUPER;
//允许使用第三方输入法
- (BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier NS_REQUIRES_SUPER;
//- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler NS_REQUIRES_SUPER;
//- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler NS_REQUIRES_SUPER;
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options NS_REQUIRES_SUPER;

@end

