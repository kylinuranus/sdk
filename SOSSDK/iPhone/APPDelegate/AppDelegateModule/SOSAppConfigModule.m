//
//  SOSAppConfigModule.m
//  Onstar
//
//  Created by TaoLiang on 2019/3/18.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSAppConfigModule.h"
#import "SOSReachability.h"
#import "ThreeDToucManager.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "UIImage+GIFImage.h"
#import "PushNotificationManager.h"
#import "SOSDonateDataTool.h"
#import "RMStore.h"
#import "ServiceController.h"
#import "AppDelegate_iPhone+SOSService.h"
#if __has_include(<BlePatacSDK/BlueToothManager.h>)
#import "BlueToothManager+SOSBleExtention.h"
#endif
#import "WeiXinManager.h"
#import "SOSPoiHistoryDataBase.h"

#ifndef SOSSDK_SDK
#import "SOSCheckLawAgreementView.h"
#import "SOSFlexibleAlertController.h"
#import "AvoidCrash.h"
#import "SOSAgreementAlertView.h"
 #if DEBUG || TEST
 #import "RemoteConsole.h"
 #import <WHDebugTool/WHDebugToolManager.h>
 #endif
//#import "FlutterBoost.h"
#import <SOSBugly/Bugly.h>
#else
//#import <flutter_boost/FlutterBoost.h>
//#import <SOSBugly/SOSBugly.h>
#endif
//#import "PlatformRouterImp.h"

#import "SOSGreetingManager.h"
//#import "SOSFlutterManager.h"

@implementation SOSAppConfigModule

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    NSArray *noneSelClassStrings = @[  @"NSNull", @"NSNumber", @"NSString", @"NSDictionary", @"NSArray" ];
//    [AvoidCrash setupNoneSelClassStringsArr:noneSelClassStrings];
    #ifndef SOSSDK_SDK
    [AvoidCrash makeAllEffective];
    //监听通知:AvoidCrashNotification, 获取AvoidCrash捕获的崩溃日志的详细信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealwithCrashMessage:) name:AvoidCrashNotification object:nil];
    #endif

//    PlatformRouterImp *router = [PlatformRouterImp new];
//           [FlutterBoostPlugin.sharedInstance startFlutterWithPlatform:router
//                                                           onStart:^(FlutterEngine *engine) {
//                                                               [router registMethodChannelWithEngine:engine];
//                                                           }];
//    [[SOSFlutterManager shareInstance] requestFlutterConfig];
    
#ifndef SOSSDK_SDK
    //8.2加入,判断是否重签名
    if (![Util checkCodesign]) {
        self.window.rootViewController = [UIViewController new];
        [self.window makeKeyAndVisible];
        return YES;
    }
//    [self migrateDB];
//    if ([SOSGreetingManager shareInstance].flutterEnable) {

       
//    }
#if DEBUG || TEST
    // ios系统设置里的 测试环境 选择,只为测试用.
    [Util ServerIPFromSettings];
    //远程控制台输出
    [[RemoteConsole shared] startServer];
#endif
    
#if DEBUG
    //memory\fps\cpu
//    [WHDebugToolManager toggleWith:DebugToolTypeAll];

#endif
    [self checkLawAgreement];
#endif
    [self configUIAppearacne];

    [SOS_APP_DELEGATE initBugly];
    [SOS_APP_DELEGATE initAmap];
    // 网易云信
    [SOS_APP_DELEGATE initNIM];
    [SOS_APP_DELEGATE initLaunchingPara];
#if __has_include(<BlePatacSDK/BlueToothManager.h>)
   [BlueToothManager sosConfig];
#endif
    // 注册微信,微博
    [[WeiXinManager shareInstance] registerApp];

    
    [SOSReachability SOSNetworkStatuswithSuccessBlock:^(NSInteger status) {
        //初始化Reachability时候AFNetworkReachabilityStatus=AFNetworkReachabilityStatusUnknown
        if (status != AFNetworkReachabilityStatusUnknown) {
            [Util setPublicIP];
            [Util reFreshSSIDInfo];
        }
    }];
    
    //3D Touch
    [ThreeDToucManager config3DTouch];
    //键盘,解决fabric的crash问题,这个一定要放在主线程
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;
    manager.enableAutoToolbar = NO;
    manager.shouldResignOnTouchOutside = YES;
    
    if (SOS_ONSTAR_PRODUCT) {
        [RMStore defaultStore];
    }
    [PushNotificationManager resetReminderOpenApp];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if(![defaults boolForKey:ISNOTFIRSTSET])    {
            [defaults setBool:YES forKey:NEED_REMOTE_Viberate];
            [defaults setBool:YES forKey:NEED_REMOTE_AUDIO];
            [defaults setBool:YES forKey:ISNOTFIRSTSET];
            [defaults setBool:YES forKey:TIP_OPEN_FINGER];
            [defaults synchronize];
        }
        
        [Util writeToVisitorDocuments];
        
        sqlite3_config(SQLITE_CONFIG_SERIALIZED);
        
        [ServiceController sharedInstance];
        
        [Util writeConfig:@"accountVehicleChanged" setValue:@""];
        [Util writeConfig:@"accountChanged" setValue:@""];
        [Util writeConfig:@"vehicleChanged" setValue:@""];
        [Util writeConfig:@"vinChanged" setValue:@""];
        [Util writeConfig:@"temp_vehicle_name" setValue:@""];
        [Util writeConfig:@"temp_vehicle_vin" setValue:@""];
        [Util writeConfig:@"temp_vehicle_year" setValue:@""];
        [Util writeConfig:@"temp_vehicle_model" setValue:@""];
        [Util writeConfig:@"temp_account_no" setValue:@""];
        

        
    });
    //查看是否允许自动刷新车况，如果允许，则登录成功后自动刷新
    [SOS_APP_DELEGATE autoLoadVehicleData];
    
    //检测登录状态执行登录成功后一些ACTION
    [SOS_APP_DELEGATE observeLoginSuccessAction];


    // 积分公益增加积分 登录监听
    [SOSDonateDataTool addLoginObserver];
    //9.1执行一次,以后版本删除,迁移即刻出发历史老数据到新数据库
//    [[SOSPoiHistoryDataBase sharedInstance] transferOldDataIfNeeded];

    return YES;
}

/// 9.4新需求,新客户端得同意协议才能操作,否则退出
//- (void)checkLawAgreement {
//    NSString *key = @"MA9.4_CHECK_LAW";
//    if ([NSUserDefaults.standardUserDefaults boolForKey:key]) {
//        return;
//    }
//    
//    SOSCheckLawAgreementView *contentView = SOSCheckLawAgreementView.new;
//    
//    SOSFlexibleAlertController *ac = [SOSFlexibleAlertController alertControllerWithImage:nil title:@"服务协议和隐私协议" message:nil customView:contentView preferredStyle:SOSAlertControllerStyleAlert];
//
//    contentView.tapAgreement = ^(NSInteger line, NSInteger index) {
////        [ac dismissViewControllerAnimated:NO completion:nil];
//        NSArray<NSString *> *types = @[agreementName(ONSTAR_TC), agreementName(ONSTAR_PS)];
//        [SOSAgreement requestAgreementsWithTypes:types success:^(NSDictionary *response) {
//            if (response.allKeys.count != types.count) {
//                [Util toastWithMessage:@"获取协议内容失败"];
//                return;
//            }
//            NSMutableArray<SOSAgreement *> *agreements = @[].mutableCopy;
//            [types enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                if ([response.allKeys containsObject:obj]) {
//                    SOSAgreement *model = [SOSAgreement mj_objectWithKeyValues:response[obj]];
//                    [agreements addObject:model];
//                }
//            }];
//            
//            WKWebView *webView = WKWebView.new;
//            webView.scrollView.contentInset = UIEdgeInsetsMake(15, 0, 0, 0);
//            webView.height = 350;
//            SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:nil title:agreements[index].docTitle message:nil customView:webView preferredStyle:SOSAlertControllerStyleAlert];
//            [webView loadRequest:[NSURLRequest requestWithURL:agreements[index].url.mj_url]];
//            SOSAlertAction *ac0 = [SOSAlertAction actionWithTitle:@"确定" style:SOSAlertActionStyleDefault handler:^(SOSAlertAction * _Nonnull action) {
////                [self checkLawAgreement];
//            }];
//            [vc addActions:@[ac0]];
//            [vc show];
//            
//        } fail:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
//            [Util toastWithMessage:@"获取协议内容失败"];
//        }];
//    };
//    
//    SOSAlertAction *acCancel = [SOSAlertAction actionWithTitle:@"不同意" style:SOSAlertActionStyleCancel handler:^(SOSAlertAction * _Nonnull action) {
//        abort();
//    }];
//    
//    SOSAlertAction *acConfirm = [SOSAlertAction actionWithTitle:@"同意" style:SOSAlertActionStyleDefault handler:^(SOSAlertAction * _Nonnull action) {
//        [NSUserDefaults.standardUserDefaults setBool:YES forKey:key];
//    }];
//    
//    [ac addActions:@[acCancel, acConfirm]];
//    [ac show];
//    
//}

#pragma mark - 3D Touch 相关
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    [ThreeDToucManager application:application performActionForShortcutItem:shortcutItem completionHandler:completionHandler];
}


- (void)configUIAppearacne {
#ifndef SOSSDK_SDK
    UIImage *info = [UIImage animatedImageNamed:@"prompt_info_" duration:2];
    UIImage *loading = [UIImage animatedImageNamed:@"prompt_loading_" duration:2];
    UIImage *error = [UIImage animatedImageNamed:@"HUD_prompt_failure_" duration:2];
    UIImage *success = [UIImage animatedImageNamed:@"HUD_prompt_success_" duration:2];

    //全局UI设置
    [UISwitch appearance].onTintColor = [UIColor colorWithRGB:0x1D81DD];
    [SVProgressHUD setSuccessImage:success];
    [SVProgressHUD setInfoImage:info];
    [SVProgressHUD setErrorImage:error];
    [SVProgressHUD setLoadingImage:loading];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeGIF];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setCornerRadius:4];
    [SVProgressHUD setHapticsEnabled:YES];
    [SVProgressHUD setMinimumSize:CGSizeMake(110, 0)];
    [SVProgressHUD setImageViewSize:CGSizeMake(48, 48)];
    [SVProgressHUD setMaximumDismissTimeInterval:2];
    [SVProgressHUD setMinimumDismissTimeInterval:2];
    [SVProgressHUD setFont:[UIFont systemFontOfSize:14]];
    [SVProgressHUD setSubFont:[UIFont systemFontOfSize:12]];
    [SVProgressHUD setMaxSupportedWindowLevel:UIWindowLevelNormal + 1];
#endif
    
}

#pragma mark - AvoidCrash Notification
- (void)dealwithCrashMessage:(NSNotification *)note {
    NSDictionary *info = note.userInfo;
    NSString *errorReason = [NSString stringWithFormat:@"【ErrorReason】%@========【ErrorPlace】%@========【DefaultToDo】%@========【ErrorName】%@", info[@"errorReason"], info[@"errorPlace"], info[@"defaultToDo"], info[@"errorName"]];
    NSArray *callStack = info[@"callStackSymbols"];
    NSArray *subArr = callStack;
    if (callStack.count > 3) {
        subArr = [callStack subarrayWithRange:NSMakeRange(0, 3)];
    }
#if DEBUG || TEST
    [Util showAlertWithTitle:@"Ops!" message:[NSString stringWithFormat:@"AvoidCrash 捕获问题:\nReason:\n%@\n\ncallStack:\n%@", errorReason, subArr] completeBlock:nil];
//    [Bugly reportExceptionWithCategory:3 name:@"AvoidCrash 捕获问题" reason: errorReason callStack:callStack extraInfo:info terminateApp:NO];
#else
//    [Bugly reportExceptionWithCategory:3 name:@"AvoidCrash 捕获问题" reason: errorReason callStack:callStack extraInfo:info terminateApp:NO];
#endif
}

@end
