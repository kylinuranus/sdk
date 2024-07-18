//
//  SOSAppLifeCircleModule.m
//  Onstar
//
//  Created by TaoLiang on 2019/3/18.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSAppLifeCircleModule.h"
#ifndef SOSSDK_SDK
#import "SOSIMNotificationCenter.h"
#if DEBUG || TEST
#import "RemoteConsole.h"
#endif

#endif
#import "UIImage+Screenshot.h"



@interface SOSAppLifeCircleModule ()
/**
 进入后台毛玻璃View
 */
@property (strong, nonatomic) UIImageView *blurImageView;
@end

@implementation SOSAppLifeCircleModule

- (void)applicationWillResignActive:(UIApplication *)application {
#ifndef SOSSDK_SDK
    NSInteger count = [SOSIMNotificationCenter sharedCenter].unreadCount;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
#endif
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
#ifndef SOSSDK_SDK
    //远程控制台输出
#if DEBUG || TEST
    [[RemoteConsole shared] startServer];
#endif
#endif
 
    
    // 图标上的数字清零 并且清空通知中心的消息通知
    //    [application setApplicationIconBadgeNumber:1]; // 单独设置0 有时候失败，tricky的办法先设置为1，再置为0
    [application setApplicationIconBadgeNumber:0];
    if (SystemVersion >= 10.) {
        [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
    }

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [SOS_APP_DELEGATE.window addSubview:self.blurImageView];
    [[LoginManage sharedInstance] stopMonitorToken];
    
//    _bgTaskToken = [application beginBackgroundTaskWithExpirationHandler:^{
//        [application endBackgroundTask:_bgTaskToken];
//        _bgTaskToken = UIBackgroundTaskInvalid;
//    }];

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [_blurImageView removeFromSuperview];
    _blurImageView = nil;

    [[LoginManage sharedInstance] setEnterBackgroundTimeInterval:[[NSDate date] timeIntervalSince1970]]; //保存从后台启动的时间
    
    // 如果accesstoken 失效，立刻重启timer
    if ([[LoginManage sharedInstance] idToken] && [[LoginManage sharedInstance] isLoadingTokenReady]) {
        NSTimeInterval timeLeft = [[LoginManage sharedInstance] accessTokenTimeLeft];
        
        if (timeLeft <= 0) { // token已经过期
            [[LoginManage sharedInstance] restartMonitorTokenInSec:0];
        } else {
            [[LoginManage sharedInstance] restartMonitorTokenInSec:timeLeft];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
#ifndef SOSSDK_SDK
#if DEBUG || TEST
    [[RemoteConsole shared] stopServer];
#endif
#endif

}

/**
 进入后台的毛玻璃效果
 
 @return 毛玻璃View
 */

- (UIImageView *)blurImageView {
    if (!_blurImageView) {
        _blurImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        UIImage *blurImage = [UIImage screenshot].bluredImage;
        _blurImageView.image = blurImage;
    }
    return _blurImageView;
}

@end
