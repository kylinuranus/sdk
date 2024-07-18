//
//  SOSPushNotificationModule.m
//  Onstar
//
//  Created by TaoLiang on 2019/3/15.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSPushNotificationModule.h"
#ifndef SOSSDK_SDK
#import "SOSMusicPlayer.h"
#import "SOSMusicSocket.h"
#import <NIMSDK/NIMSDK.h>
#import "SOSIMLoginManager.h"
#endif
#import "ApplePushSaveUtil.h"

#import "SOSLandingViewController.h"
#import "SOSMsgCenterController.h"
#import "SOSCustomAlertView.h"
#import "SOSCardUtil.h"
#import "OwnerLifeVehicleDetectionController.h"
#import "OwnerLifeInsuranceController.h"
#import "SOSCarSecretaryViewController.h"
#import "HandleDataRefreshDataUtil.h"
#import "SOSMsgHotActivityController.h"
#import "OwnerLifeRenewalController.h"
//#import "ViewControllerAssistantOVDEmail.h"
#import "SOSSocialService.h"


#if __has_include("SOSSDK.h")
#import "SOSSDK.h"
#else
#import "JPUSHService.h"
#endif

@interface SOSPushNotificationModule ()<UNUserNotificationCenterDelegate> //, JPUSHRegisterDelegate>

@end

@implementation SOSPushNotificationModule

+ (void)pushNotificationIsOn:(void (^)(BOOL))isOn {
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 10.0) {
        
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            isOn(settings.authorizationStatus == UNAuthorizationStatusAuthorized || settings.authorizationStatus == UNAuthorizationStatusNotDetermined);
        }];
    } else if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0) {
        
        UIUserNotificationSettings *settings = [UIApplication sharedApplication].currentUserNotificationSettings;
        isOn(settings.types != UIUserNotificationTypeNone);
    }
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#ifndef SOSSDK_SDK
    application.applicationIconBadgeNumber = 0;
    [self initJPushWithOptions:launchOptions];
    [self registerPush:application];
    
    //IOS10以下，程序没有启动时，点击消息会调用此方法
    if (SystemVersion < 10.)    {
        if (launchOptions != nil)   {
            NSDictionary *remoteUserInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
            if (remoteUserInfo)  {
                NSLog(@"收到远程消息: %@", remoteUserInfo);
                [self handleNotificationUserInfo:remoteUserInfo];
            }
        }
    }
    
    [ApplePushSaveUtil saveDeviceInfoWithIsBind:@"Y" userID:@""];

    [RACObserve([LoginManage sharedInstance], loginState) subscribeNext:^(NSNumber *x) {
        if (x.integerValue == LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS) {
            [ApplePushSaveUtil saveSession];
        }
    }];
#endif
    return YES;
}

#pragma mark - 注册推送相关
- (void)initJPushWithOptions:(NSDictionary *)launchOptions {
    //Required
    //notice: 3.0.0 及以后版本注册可以这样写，也可以继续用之前的注册方式
    //    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    //    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound|JPAuthorizationOptionProvidesAppNotificationSettings;
    //    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    // Required
    // init Push
    // notice: 2.1.5 版本的 SDK 新增的注册方法，改成可上报 IDFA，如果没有使用 IDFA 直接传 nil
    // 如需继续使用 pushConfig.plist 文件声明 appKey 等配置内容，请依旧使用 [JPUSHService setupWithOption:launchOptions] 方式初始化。
#ifndef SOSSDK_SDK
    [JPUSHService setupWithOption:launchOptions appKey:JPUSH_APP_KEY
                          channel:@"App Store"
                 apsForProduction:SOS_DEV
            advertisingIdentifier:nil];
#endif
}

- (void)registerPush:(UIApplication *)application {
    
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 10.0) {
        // iOS10及以上版本
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                // 点击允许
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    NSLog(@"推送setting: %@", settings);
                }];
                dispatch_async_on_main_queue(^{
                    [application registerForRemoteNotifications];
                });
            } else {
                // 点击不允许
                NSLog(@"推送注册失败")
            }
        }];
    } else if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0) {
        // iOS8及以上 iOS10以下
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
}


#pragma mark - device token 回调相关
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //注册设备
#ifndef SOSSDK_SDK
    NSString * appleDeviceTokenStr;
    if (@available(iOS 13.0, *)) {
        NSMutableString *deviceTokenString = [NSMutableString string];
        const char *bytes = deviceToken.bytes;
        NSInteger count = deviceToken.length;
        for (int i = 0; i < count; i++) {
            [deviceTokenString appendFormat:@"%02x", bytes[i]&0x000000FF];
        }
        appleDeviceTokenStr = deviceTokenString.copy;
    } else {
        appleDeviceTokenStr =  [[[[deviceToken description]
                                       stringByReplacingOccurrencesOfString:@"<" withString:@""]
                                      stringByReplacingOccurrencesOfString:@">" withString:@""]
                                     stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:appleDeviceTokenStr forKey:kApplePushSaveDeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NIMSDK sharedSDK] updateApnsToken:deviceToken];
    NSLog(@"device token == %@", appleDeviceTokenStr);
    [JPUSHService registerDeviceToken:deviceToken];
#if DEBUG || TEST
    //延迟5秒方便remoteConsole抓log
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
            NSLog(@"极光推送registrationID is %@", registrationID);
        }];
        
    });
#endif
    
#endif
    

   
    

    
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", error.description);
}

#pragma mark - 处理收到的推送相关,分iOS10之后和iOS9
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionBadge);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    // 获取通知所带的数据
    [self handleNotificationUserInfo:response.notification.request.content.userInfo];
    completionHandler();
}
#endif

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self handleNotificationUserInfo:userInfo];
}

#pragma mark - 业务推送跳转处理
- (void)handleNotificationUserInfo:(NSDictionary *)userInfo {
    if (!userInfo) {
        return;
    }
#ifndef SOSSDK_SDK
    NSDictionary *aps = userInfo[@"aps"];
    if ([aps containsObjectForKey:@"nim"] && [aps[@"nim"] boolValue]) {
        [self handleNIMMessage:userInfo];
        return;
    }
#endif
    [LoginManage sharedInstance].loginSuccessAction = ^{
        [self handleOnstarPushNotification:userInfo updateUI:YES];
    };
}

- (void)handleNIMMessage:(NSDictionary *)message {
    #ifndef SOSSDK_SDK
    if ([SOS_APP_DELEGATE.window.rootViewController isKindOfClass:[SOSLandingViewController class]])    {
        SOSLandingViewController * landingView =((SOSLandingViewController*)self.window.rootViewController);
        [landingView setCompleteBlock:^{
            [self showHomePage];
            [[SOSIMLoginManager sharedManager] pushToIMHomePageFrom:[SOS_APP_DELEGATE fetchMainNavigationController]];
        }];
    }else {
#if __has_include("SOSSDK.h")
        [SOSSDK sos_showOnstarModuleWithDismissBlock:nil];
#endif
        [[SOSIMLoginManager sharedManager] pushToIMHomePageFrom:[SOS_APP_DELEGATE fetchMainNavigationController]];
        
    }
#endif

}

///推送消息处理
- (void)handleOnstarPushNotification:(NSDictionary*)userInfo updateUI:(BOOL)updateUI {
    /*
     处理远程消息，根据key值判断是普通消息，还是提示打开app消息，如果用户点击app或者是打开app消息，直接进入应用，如果用户点击消息打开app，进入广播中心列表
     {
     aps = {
     alert = {
     body = receiveType;
     link = "http://www.baidu.com";
     receiveType = 3;
     };
     badge = 1;
     sound = "beep.wav";
     };
     link = "http://www.baidu.com";
     xg = {
     bid = 1225404398;
     ts = 1453961692;
     };
     }
     */
    UIApplication *application = [UIApplication sharedApplication];
    //B2C后台区分三种消息
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    NSDictionary *alert = [aps objectForKey:@"alert"];
    if (![alert isKindOfClass:NSDictionary.class]) {
        return;
    }
    NSString *receiveType = [alert objectForKey:@"receiveType"];
    NSString *pressurequeryFlg = [alert objectForKey:@"pressurequeryFlg"];
    
    // 1:进入广播中心   2:打开app   3,webview直接打开   4:打开ovd界面   5:用户登录后，打开webview   10: 跳转远程控制页面   15: 跳转首页   16: 续包弹窗提醒   17: 未续包弹窗提醒   20: 小O车况查询成功本地通知   21: 跳转车主生活换证页面   22: 保险通知提醒   23: 车检通知提醒   24: 还贷跳转首页   25: 跳转爱车小秘书首页   26: 跳转远程控制页面		35:跳转到里程险投保页		36: 跳转到里程险账单页面 200:跳转记录仪视频列表

    if (receiveType && [receiveType isKindOfClass:[NSString class]]) {
        // receiveType may be NSNull
        switch ([receiveType intValue]) {
            case 1: {
                if (application.applicationState != UIApplicationStateBackground) {
                    if (updateUI) {
                        SOSMsgCenterController *messagedetailVc = [[SOSMsgCenterController alloc]init];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([self.window.rootViewController isKindOfClass:[SOSLandingViewController class]])    {
                                SOSLandingViewController * landingView =((SOSLandingViewController*)self.window.rootViewController);
                                [landingView setCompleteBlock:^{
                                    [self showHomePage];
                                    [[LoginManage sharedInstance] checkAndShowLoginViewWithFromViewCtr:[SOS_APP_DELEGATE fetchMainNavigationController].topViewController andTobePushViewCtr:nil completion:^(BOOL finished) {
                                        if (finished) {
                                            [SOSDaapManager sendActionInfo:My_massage_push];
                                            [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:messagedetailVc animated:YES];
                                        }
                                    }];
                                }];
                            }    else    {
#if __has_include("SOSSDK.h")
                                [SOSSDK sos_showOnstarModuleWithDismissBlock:nil];
#endif
                                
                                
                                [[LoginManage sharedInstance] checkAndShowLoginViewWithFromViewCtr:[SOS_APP_DELEGATE fetchMainNavigationController].topViewController andTobePushViewCtr:nil completion:^(BOOL finished) {
                                    if (finished) {
                                        [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:messagedetailVc animated:YES];
                                    }
                                }];
                            }
                        });
                    }
                }
            }
                break;
            case 2:
            case 3: {
                NSString * url = [alert objectForKey:@"link"];
                [LoginManage sharedInstance].loginSuccessAction = nil;
                [self openWebViewNonLogin:url];
                if (!updateUI) {
                }
            }
                break;
            case 4:    {
                //if (application.applicationState != UIApplicationStateBackground) {
                if (updateUI) {
                    [self openOVD];
                }
                // }
            }
                break;
            case 5:    {
                NSString *url = [alert objectForKey:@"link"];
                if ([url length]>0 && updateUI) {
                    [self openWebViewAfterLogin:url];
                }
            }
                break;
            case 26:
            case 10:
                //推送app通知时在原接收类型基础上增加receiveType=10，用来标示进行跳转远程控制页面
                [self jumpToRemoteView];
                break;
            case 15:    {
                //推送app通知时在原接收类型基础上增加receiveType=15，用来标示进行跳转安吉星手机应用主页
                [LoginManage sharedInstance].loginSuccessAction = nil;
                [self jumpToHomepage];
            }
                break;
            case 16:    {
                [LoginManage sharedInstance].loginSuccessAction = nil;
                NSString * title = [alert objectForKey:@"title"];
                NSString *msg = [alert objectForKey:@"body"];
                //用户已续包 APP首页弹框显示 流量包有效期到期前1天、前15天，后续有服务包提醒：
                SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:title detailText:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
                alert.notificationDetailText = msg;//[NSString stringWithFormat: @"您的 %@ 当前中国移动流量包有效期至%@，当前流量包到期后，您购买的%@中国移动流量包将自动开启。", vType, pDate, pName];;
                [alert setPageModel:SOSAlertViewModelNotification];
                [alert setBackgroundModel:SOSAlertBackGroundModelWhite];
                [alert setButtonMode:SOSAlertButtonModelHorizontal];
                dispatch_async_on_main_queue(^{
#if __has_include("SOSSDK.h")
                    [SOSSDK sos_showOnstarModuleWithDismissBlock:nil];
#endif
                    
                    [alert show];
                });
            }
                break;
            case 17:    {
                [LoginManage sharedInstance].loginSuccessAction = nil;
                //用户未续包 APP首页弹框跳转: 流量包有效期到期前1天、前15天，后续无服务包提醒：
                NSString * title = [alert objectForKey:@"title"];
                NSString *msg = [alert objectForKey:@"body"];
                //                NSString *vType;
                //                NSString *pDate;
                //
                //                NSDictionary * body = [[alert objectForKey:@"body"] mj_JSONObject];
                //                if ([body isKindOfClass:[NSDictionary class]]) {
                //                    vType = [body objectForKey:@"vType"];
                //                    pDate = [body objectForKey:@"pDate"];
                //                }
                
                
                SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:title detailText:nil cancelButtonTitle:@"购买4G流量套餐" otherButtonTitles:nil];
                alert.notificationDetailText = msg;//[NSString stringWithFormat:@"您的 %@ 当前中国移动流量包有效期至%@，点击购买互联车辆安全卫士套餐，为车载Wi-Fi加油！", vType, pDate];;
                [alert setPageModel:SOSAlertViewModelNotification];
                [alert setBackgroundModel:SOSAlertBackGroundModelWhite];
                [alert setButtonMode:SOSAlertButtonModelHorizontal];
                [alert setButtonClickHandle:^(NSInteger clickIndex) {
                    [SOSCardUtil routerToBuyOnstarPackage:PackageType_4G];
                }];
                dispatch_async_on_main_queue(^{
#if __has_include("SOSSDK.h")
                    [SOSSDK sos_showOnstarModuleWithDismissBlock:nil];
#endif
                    [alert show];
                });
            }
                break;
            case 20:    {
                //小o查询车况分类信息，进入后台运行之后，查询车况成功弹出本地通知，点击通知弹出车况模拟画面
                if (pressurequeryFlg && [pressurequeryFlg isKindOfClass:[NSString class]]) {
#if __has_include("SOSSDK.h")
                    [SOSSDK sos_showOnstarModuleWithDismissBlock:nil];
#endif
                    
                    if ([pressurequeryFlg isEqualToString:@"1"]) {
                        //查询胎压
                        [SOSCardUtil routerToVehicleCondition];
                    }
                    else
                    {
                        //显示整个车况
                        [SOSCardUtil routerToVehicleCondition];
                    }
                }
            }
                break;
            case 21:    {
                //车主生活换证通知提醒
                [[LoginManage sharedInstance] dismissLoginNav];
                [[LoginManage sharedInstance] checkAndShowLoginViewWithFromViewCtr:[SOS_APP_DELEGATE fetchMainNavigationController].topViewController andTobePushViewCtr:nil completion:^(BOOL finished) {
                    if (finished) {
                        if ([SOSCheckRoleUtil isVisitor]) return;
                        if ([SOSCheckRoleUtil isDriverOrProxy]) return;
                        
                        OwnerLifeRenewalController *vc = [[OwnerLifeRenewalController alloc] init];
                        [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:vc animated:YES];
                    }
                }];
            }
                break;
            case 22:    {
                // 保险通知提醒
                [[LoginManage sharedInstance] dismissLoginNav];
                [[LoginManage sharedInstance] checkAndShowLoginViewWithFromViewCtr:[SOS_APP_DELEGATE fetchMainNavigationController] andTobePushViewCtr:nil completion:^(BOOL finished) {
                    if (finished) {
                        if ([SOSCheckRoleUtil isVisitor]) return;
                        if ([SOSCheckRoleUtil isDriverOrProxy]) return;
                        
                        OwnerLifeInsuranceController *vc = [[OwnerLifeInsuranceController alloc] init];
                        [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:vc animated:YES];
                    }
                }];
                break;
            }
            case 23:    {
                //车检通知提醒
                [[LoginManage sharedInstance] dismissLoginNav];
                [[LoginManage sharedInstance] checkAndShowLoginViewWithFromViewCtr:[SOS_APP_DELEGATE fetchMainNavigationController] andTobePushViewCtr:nil completion:^(BOOL finished) {
                    if (finished) {
                        if ([SOSCheckRoleUtil isOwner]) {
                            OwnerLifeVehicleDetectionController *vc = [[OwnerLifeVehicleDetectionController alloc] init];
                            [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:vc animated:YES];
                        }
                    }
                }];
            }
                break;
            case 24:{
                //还贷跳转首页
                break;
            }
            case 25:    {
                //爱车小秘书首页
                [[LoginManage sharedInstance] dismissLoginNav];
                [[LoginManage sharedInstance] checkAndShowLoginViewWithFromViewCtr:[SOS_APP_DELEGATE fetchMainNavigationController] andTobePushViewCtr:nil completion:^(BOOL finished) {
                    if (finished) {
                        if ([SOSCheckRoleUtil isOwner]) {
                            [SOSDaapManager sendActionInfo:Notification_vehiclesecretory];
                            SOSCarSecretaryViewController *vc = [SOSCarSecretaryViewController new];
                            [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:vc animated:YES];
                        }
                    }
                }];
                break;
            }
            case 27: {
                //BLE车主
                [[SOS_APP_DELEGATE fetchMainNavigationController] popToRootViewControllerAnimated:NO];
                [SOSCardUtil routerToOwnerBle];
                break;
            }
            case 28: {
                [LoginManage sharedInstance].loginSuccessAction = nil;
                [[SOS_APP_DELEGATE fetchMainNavigationController] popToRootViewControllerAnimated:NO];
                [SOSCardUtil routerToUserReceiveBlePage];
                break;
            }
            case 29: {
                [LoginManage sharedInstance].loginSuccessAction = nil;
                NSString * url = [alert objectForKey:@"link"];
                [self openWebViewWithHotMsg:url];
                break;
            }
            case 30: {
                [LoginManage sharedInstance].loginSuccessAction = nil;
                NSString *url = alert[@"link"];
                if (url.length <= 0) {
                    [SOS_APP_DELEGATE fetchRootViewController].selectedIndex = 2;
                    return;
                }
                [self openWebViewNonLogin:url];
                
                break;
            }
            // 35:跳转到里程险投保页
            case 35:
            // 36: 跳转到里程险账单页面
            case 36: {
                NSString * url = [alert objectForKey:@"link"];
                [SOSCardUtil showMileAgeInsuranceStatementVCWithURL:url FromVC:nil Success:^{
                    [SOSDaapManager sendActionInfo:Mileage_Enter_From_Notifi];
                }];
                break;
            }
                
            case 41: {
                [LoginManage sharedInstance].loginSuccessAction = nil;
                [[SOSSocialService shareInstance] selectStatus];
                break;
            }
            case 90: {
#ifndef SOSSDK_SDK
                //下发歌曲
                NSString * musicId = [alert objectForKey:@"link"];
                [[SOSMusicPlayer sharedInstance] pushToMusicHomePageFrom:nil];
                [SOSMusicPlayer sharedInstance].readyPlayMusicId = musicId;
#endif
                break;
            }
            case 200: {
                //进入视频列表
                [LoginManage sharedInstance].loginSuccessAction = nil;
                NSString * imei = [alert objectForKey:@"link"];
                [SOSCardUtil routerToCloudVideoListWithIMEI:imei];
               
                break;
            }
            default:
                break;
        }
        
    }
}

- (void)openWebView:(NSString *)url {
    void (^completionBlock)(void) = ^(){
#if __has_include("SOSSDK.h")
        [SOSSDK sos_showOnstarModuleWithDismissBlock:nil];
#endif
        
        [[SOS_APP_DELEGATE fetchMainNavigationController] dismissViewControllerAnimated:YES completion:nil];
        if ([url containsString:@"/mweb-main/static/OnStar-MA7.0-h5/html/driving-scores/driving-score.html"]) {
            [HandleDataRefreshDataUtil drivingBehavior:[SOS_APP_DELEGATE fetchMainNavigationController]];
        }    else    {
            SOSWebViewController *webVC = [[SOSWebViewController alloc] initWithUrl:url];
            [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:webVC animated:YES];
        }
    };
    if ([[LoginManage sharedInstance] isLoadingMainInterfaceReady]) {    //完整登陆，打开网页
        completionBlock();
    }else
    {
        [[LoginManage sharedInstance] setOncompletion:^(BOOL loginComplete){ //未登陆或非完整登陆，设置回调，下次走登陆后调用
            if (loginComplete) {
                completionBlock();
            }
        }];
        
        //检测是否登陆，未登陆，登陆后走上面block，已登陆但信息获取不完整，走自己的回调打开网页
        [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:[SOS_APP_DELEGATE fetchMainNavigationController] withLoginDependence:[[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin] showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
            completionBlock();
        }];
    }
    
    
    
}

- (void)openWebViewNonLogin:(NSString *)url    {
    if([url length]>0){
#if __has_include("SOSSDK.h")
        [SOSSDK sos_showOnstarModuleWithDismissBlock:nil];
#endif
        
        SOSWebViewController *webVC = [[SOSWebViewController alloc] initWithUrl:url];
        if ([self.window.rootViewController isKindOfClass:[SOSLandingViewController class]]){
            SOSLandingViewController *landingView =((SOSLandingViewController*)self.window.rootViewController);
            [landingView setCompleteBlock:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showHomePage];
                    [[SOS_APP_DELEGATE fetchMainNavigationController] dismissViewControllerAnimated:YES completion:nil];
                    [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:webVC animated:YES];
                });
            }];
            
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[SOS_APP_DELEGATE fetchMainNavigationController] dismissViewControllerAnimated:YES completion:nil];
                [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:webVC animated:YES];
            });
        }
    }
}


- (void)openWebViewWithHotMsg:(NSString *)url    {
#if __has_include("SOSSDK.h")
    [SOSSDK sos_showOnstarModuleWithDismissBlock:nil];
#endif
    SOSMsgHotActivityController *vc = [[SOSMsgHotActivityController alloc] init];
    vc.isPush = YES;
    vc.pushUrl = url;
    if ([self.window.rootViewController isKindOfClass:[SOSLandingViewController class]]){
        SOSLandingViewController *landingView =((SOSLandingViewController*)self.window.rootViewController);
        [landingView setCompleteBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showHomePage];
                [[SOS_APP_DELEGATE fetchMainNavigationController] dismissViewControllerAnimated:YES completion:nil];
                [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:vc animated:YES];
            });
        }];
        
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[SOS_APP_DELEGATE fetchMainNavigationController] dismissViewControllerAnimated:YES completion:nil];
            [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:vc animated:YES];
        });
    }
}


- (void)jumpToRemoteView
{
    dispatch_async(dispatch_get_main_queue(), ^{
#if __has_include("SOSSDK.h")
        [SOSSDK sos_showOnstarModuleWithDismissBlock:nil];
#endif
        
        [SOSCardUtil routerToRemoteControl];
    });
    
}
- (void)jumpToHomepage{
    dispatch_async(dispatch_get_main_queue(), ^{
#if __has_include("SOSSDK.h")
        [SOSSDK sos_showOnstarModuleWithDismissBlock:nil];
#endif
        
        if ([SOS_APP_DELEGATE fetchMainNavigationController].presentedViewController) {
            [[SOS_APP_DELEGATE fetchMainNavigationController] dismissViewControllerAnimated:YES completion:^(){
            }];
        }
        else
        {
            [[SOS_APP_DELEGATE fetchMainNavigationController] popToRootViewControllerAnimated:NO] ;
        }
    });
}


- (void)openWebViewAfterLogin:(NSString *)url {
    if ([self.window.rootViewController isKindOfClass:[SOSLandingViewController class]]) {
        SOSLandingViewController *landingView =((SOSLandingViewController*)self.window.rootViewController);
        [landingView setCompleteBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showHomePage];
                [self openWebView:url];
            });
        }];
    }else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self openWebView:url];
        });
    }
}


- (void)openOVD
{
    if ([self.window.rootViewController isKindOfClass:[SOSLandingViewController class]]) {
        @weakify(self);
        [LoginManage sharedInstance].loginSuccessAction = nil;
        SOSLandingViewController * landingView =((SOSLandingViewController*)self.window.rootViewController);
        [landingView setCompleteBlock:^{
            @strongify(self);
            [self showHomePage];
        }];
        
    }   else    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UINavigationController *nav = (UINavigationController *)[SOS_APP_DELEGATE fetchMainNavigationController];
            if (nav.viewControllers.count >1) {
                [nav popToRootViewControllerAnimated:NO];
            }
            [self pushOVDController];
        });
    }
}

- (void)pushOVDController {
    if (![LoginManage sharedInstance].loginNav.presentingViewController) {
        //[[SOSReportService shareInstance] recordActionWithFunctionID:Find_Diagnostics];
        //        ViewControllerAssistantOVDEmail* pushedCon = [[ViewControllerAssistantOVDEmail alloc]initWithNibName:@"ViewControllerAssistantOVDEmail" bundle:nil];
#if __has_include("SOSSDK.h")
        [SOSSDK sos_showOnstarModuleWithDismissBlock:nil];
#endif
        [SOSCardUtil routerToVehicleDetectionReport];
        
    }
}



@end
