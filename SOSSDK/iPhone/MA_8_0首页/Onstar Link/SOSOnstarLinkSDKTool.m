//
//  SOSOnstarLinkSDKTool.m
//  Onstar
//
//  Created by Coir on 2018/7/23.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSMroService.h"
#import "SOSOnstarLinkSDKTool.h"
#import "SOSOnstarLinkDataTool.h"

#if __has_include(<VBOnstarOSDK/VBOnstarOSDK.h>)
#import <VBOnstarOSDK/VBOnstarOSDK.h>
#import <YFLinkCoreFramework/YFLinkCoreFramework.h>
#endif

#import "SOSMapHeader.h"
//#import <OnStarVersionSDK/YFLinkVCOnstarOManager.h>

#if TARGET_IPHONE_SIMULATOR
@implementation SOSOnstarLinkSDKTool
+ (SOSOnstarLinkSDKTool *)sharedInstance {
    return nil;
}

+ (UIView *)getOnstarLinkButtonView    {
    return nil;
}

@end
#else


@interface SOSOnstarLinkSDKTool ()
#if __has_include(<OnStarVersionSDK/YFOnStarVersionManager.h>)
<YFOnStarVersionManagerDelegate>

@property (nonatomic, weak) YFOnStarVersionManager *YFManager;
#endif
@end

@implementation SOSOnstarLinkSDKTool


+ (SOSOnstarLinkSDKTool *)sharedInstance {
    static SOSOnstarLinkSDKTool *sharedOBJ = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedOBJ = [[self alloc] init];
    });
    return sharedOBJ;
}
#if __has_include(<OnStarVersionSDK/YFOnStarVersionManager.h>)

- (YFOnStarLinkStatus)onstarLinkStatus	{
    if (!self.YFManager)		return YFOnStarLinkStatusUnknown;
    else						return self.YFManager.onStarLinkStatus;
}

- (BOOL)isOnstarLinkRunning		{
    return 	!(self.onstarLinkStatus == YFOnStarLinkStatusUnknown || self.onstarLinkStatus == YFOnStarLinkStatusExit);
}

+ (void)enterOnstarLink		{
    // 正常入口点击
    if ([SOSOnstarLinkSDKTool sharedInstance].isOnstarLinkRunning)		[SOSDaapManager sendActionInfo:Onstarlink_entrance__click];
    // 暂离返回
    else																[SOSDaapManager sendActionInfo:Ontsrlink_connection_templeave_end];
    
    [SOSOnstarLinkSDKTool configMrO];
    [[YFOnStarVersionManager sharedInstance] enterOnStarLinkWithKeyWindow:SOS_APP_DELEGATE.window];
}

+ (void)configOnstarLinkSDK    {
    [SOSOnstarLinkSDKTool sharedInstance].YFManager = [YFOnStarVersionManager sharedInstance];
    [YFOnStarVersionManager sharedInstance].yf_onStarLinkDelegate = [SOSOnstarLinkSDKTool sharedInstance];
    [SOSOnstarLinkSDKTool configOTABlock];
    [SOSOnstarLinkSDKTool configCallOnstarBlock];
    [SOSOnstarLinkSDKTool configOnstarHelpPageBlock];
    
    [[[LoginManage sharedInstance] rac_valuesAndChangesForKeyPath:@"loginState" options:NSKeyValueObservingOptionNew observer:[SOSOnstarLinkSDKTool sharedInstance]] subscribeNext:^(RACTwoTuple<id,NSDictionary *> *x) {
        id newValue = x.first;
        // 用户退出登录
        if ([newValue isKindOfClass:[NSNumber class]] && [newValue intValue] == LOGIN_STATE_NON) {
            [SOSOnstarLinkDataTool sharedInstance].dataModel = nil;
            if ([SOSOnstarLinkSDKTool sharedInstance].YFManager) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    YFOnStarLinkStatus status = [YFOnStarVersionManager sharedInstance].onStarLinkStatus;
                    if (status != YFOnStarLinkStatusExit) {
                        [[YFOnStarVersionManager sharedInstance] exitOnStarLink];
                    }
                    // 销毁单例对象
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [YFOnStarVersionManager destroyInstance];
//                        self.YFManager = nil;
                    });
                    [SOSOnstarLinkSDKTool sharedInstance].YFManager = nil;
                    // 隐藏 Onstar Link 暂离图标
                    [[NSNotificationCenter defaultCenter] postNotificationName:SOSOnstarLinkButtonStateShouldChangeNotification object:@(NO)];
                });
            }
        }
    }];
}

+ (void)configMrO	{
    // 车主时, 读取状态, 非车主默认开启
//    if ([SOSCheckRoleUtil isOwner]) {
//        BOOL shouldOpenMrO = [Util readMrOOpenFlagByidpid:[CustomerInfo sharedInstance].userBasicInfo.idpUserId].boolValue;
//        if (shouldOpenMrO)        {
//            [SOSMroService sharedMroService];
//            [[YFOnStarVersionManager sharedInstance] setOnStarOStatus:YES];
//        }    else    {
            [[YFOnStarVersionManager sharedInstance] setOnStarOStatus:NO];
//        }
//    }    else    {
//        [SOSMroService sharedMroService];
//        [[YFOnStarVersionManager sharedInstance] setOnStarOStatus:YES];
//    }
}

/// 设置客户端 OTA 升级 Block
+ (void)configOTABlock        {
    [YFOnStarVersionManager sharedInstance].checkOTABlock = ^() {
//        [Util showAlertMessage:@"checkOTABlock" withDelegate:nil];
        NSString *url = [Util getStaticConfigureURL:SOSOnstasrLinkGetOTAInfoURL];
    	url = [url stringByReplacingOccurrencesOfString:@"https" withString:@"http"];
        SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
//            [Util showAlertMessage:@"check OTA Success" withDelegate:nil];
            NSDictionary *sourceDic = [responseStr mj_JSONObject];
            /*
            //此处OnstarApp进行网络请求，请求OTA数据,如果成功接收数据，回调的NSDictionary有如下字段
            NSDictionary *successDict = @{ @"errMsg" : @"",                             //网络请求是否成功
                                           @"errcode" : @"0",                           //版本号
                                           @"update_content" : @"更新的内容：<br/>1.dddddd<br/>2.ggggggggggggg ",//更新内容
                                           @"update_time" : @"1527995605000",           //时间戳
                                           @"versionName" : @"V2.0.2",                  //固件名称
                                           @"versionCode" : @"20002",                   //固件版本号
                                           @"url" : @"http://114.215.25.223:8091/static/app-release.apk"   //固件地址
                                           };
            //如果接口请求失败，返回的NSDictionary有如下字段
            NSDictionary *failDict = @{@"isSuccess": @NO,                           //网络请求是否成功
             @"statusCode": @"400",
             @"errorMessage": @"xxxxxxx"
             };    */
            /**SDK可以直接根据isSuccess判断接口是否请求成功，再进行接下来的处理*/
            if (sourceDic.count) {
                [[YFOnStarVersionManager sharedInstance] updateCarAppVersionByDictionary:sourceDic];
            }
        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
//            [Util showAlertMessage:@"check OTA Failure" withDelegate:nil];
            NSDictionary *failDict = @{@"isSuccess": @NO, @"statusCode": @(statusCode), @"errorMessage": responseStr};
            [[YFOnStarVersionManager sharedInstance] updateCarAppVersionByDictionary:failDict];
        }];

        [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
        [operation setHttpMethod:@"GET"];
        [operation start];
    };
}

/// 设置客户端拨打电话 Block
+ (void)configCallOnstarBlock    {
    [YFOnStarVersionManager sharedInstance].willCallOnstarBlock = ^(NSString *latitude, NSString *longitude) {
//        [Util showAlertMessage:[NSString stringWithFormat:@"latitude: %@ longitude: %@", latitude, longitude] withDelegate:nil];
        /*
        //Onstar App处理上传经纬度逻辑，无论成功失败，都会调用SDK拨打电话回调（该方法由SDK自行定义），此时SDK将电话真正拨出。
        NSString *url = [BASE_URL stringByAppendingFormat:SOSOnstasrLinkUploadUserLocationURL];
        SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
            [[YFOnStarVersionManager sharedInstance] calloutOnStarServiceWithNumber:@"400-820-1188"];
        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            [[YFOnStarVersionManager sharedInstance] calloutOnStarServiceWithNumber:@"400-820-1188"];
        }];
        
        [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
        [operation setHttpMethod:@"POST"];
        [operation start];        */
        
        [[YFOnStarVersionManager sharedInstance] calloutOnStarServiceWithNumber:@"02151847550"];
    };
}

/// 设置 Onstar Link 帮助界面 Block
+ (void)configOnstarHelpPageBlock		{
    [YFOnStarVersionManager sharedInstance].enterOnStarLinkHelpBlock = ^() {
        [SOSDaapManager sendActionInfo:Ontsrlink_connection_help];
    };
    [YFOnStarVersionManager sharedInstance].exitOnStarLinkHelpBlock = ^{
    };
}

+ (void)navigateToPoiWithLatitude:(NSString *)latitude longitude:(NSString *)longitude		{
    if (!(latitude.length && longitude.length && latitude.floatValue && longitude.floatValue))		return;
    //传入坐标
    [[YFOnStarVersionManager sharedInstance] navigationToPoiWithLatitude:latitude longitude:longitude];
}

#pragma mark - YFOnStarVersionManagerDelegate
///手机与车机连接
- (void)yf_connectStatusConnected {
    NSLog(@"yf_connectStatusConnected");
    [SOSDaapManager sendActionInfo:Ontsrlink_connection_successful];
}

///手机与车机断开
- (void)yf_connectStatusDisconnected {
    NSLog(@"yf_connectStatusDisconnected");
}

/**
 * 进出安吉星Link状态变化
 */
- (void)yf_onStarLinkStatusChange:(YFOnStarLinkStatus)onStarLinkStatus	{
    NSLog(@"onStarLinkStatus : %ld", (long)onStarLinkStatus);
    // 车主时, 读取状态, 非车主默认开启
//    BOOL shouldOpenMrO = [Util readMrOOpenFlagByidpid:[CustomerInfo sharedInstance].userBasicInfo.idpUserId].boolValue;
//    BOOL isMroGlobalWakeup = ![SOSCheckRoleUtil isOwner] || [SOSMroService isMroGlobalWakeup];
//    BOOL shouldChangeWakeUp = NO;
    switch (onStarLinkStatus) {
        case YFOnStarLinkStatusUnknown:
            break;
        case YFOnStarLinkStatusBack:	{
            // 暂离时隐藏小O,关闭监听
            [SOSDaapManager sendActionInfo:Ontsrlink_connection_templeave_start];
//            shouldChangeWakeUp = YES;
//            isMroGlobalWakeup = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
//                if (shouldOpenMrO)         [[NSNotificationCenter defaultCenter] postNotificationName:SOS_CHANGE_MRO_SETTING_OPEN_STATE_NOTIFICATION object:@(NO)];
                // 显示 Onstar Link 暂离图标
                [[NSNotificationCenter defaultCenter] postNotificationName:SOSOnstarLinkButtonStateShouldChangeNotification object:@(YES)];
                UINavigationController *nav = [SOS_APP_DELEGATE fetchMainNavigationController];
                if (nav.viewControllers.count) {
                    [[SOS_APP_DELEGATE fetchMainNavigationController] popToRootViewControllerAnimated:NO];
                }
            });
            break;
        }
        case YFOnStarLinkStatusStart:
//            shouldChangeWakeUp = YES;
            break;
        case YFOnStarLinkStatusEnter:
//            shouldChangeWakeUp = YES;
            [SOS_APP_DELEGATE pauseSOSMusicIfNeeded];
            break;
        case YFOnStarLinkStatusExit:	{
//            shouldChangeWakeUp = YES;
            [SOS_APP_DELEGATE restoreAudioSessionCatergory];
            // 销毁单例对象
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [YFOnStarVersionManager destroyInstance];
//                self.YFManager = nil;
//            });
            // 退出 Onstar Link 模块时,恢复小O状态
//            [[NSNotificationCenter defaultCenter] postNotificationName:SOS_CHANGE_MRO_SETTING_OPEN_STATE_NOTIFICATION object:@(shouldOpenMrO)];
            // 隐藏 Onstar Link 暂离图标
            [[NSNotificationCenter defaultCenter] postNotificationName:SOSOnstarLinkButtonStateShouldChangeNotification object:@(NO)];
            break;
        }
        default:
            break;
    }
    // 恢复小O监听设置
//    if (shouldChangeWakeUp)    {
//        if (isMroGlobalWakeup)    {
//            [[SOSMroService sharedMroService] openGlobalWakeUp];
//            [[YFOnStarVersionManager sharedInstance] setIsGlobalWakeUp:YES];
//        }    else    {
//            [[SOSMroService sharedMroService] closeGlobalWakeUp];
//            [[YFOnStarVersionManager sharedInstance] setIsGlobalWakeUp:NO];
//        }
//    }
}

// 暂离浮窗 Button
+ (UIView *)getOnstarLinkButtonView	{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor colorWithWhite:.9 alpha:1] forState:UIControlStateHighlighted];
    button.frame = CGRectMake(0, 0, 120, 40);
    [button setTitleForAllState:@"返回智联映射"];
    [button setTitleColor:[UIColor colorWithHexString:@"4D87E1"] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:13.0];
    button.layer.cornerRadius = 20;
    button.layer.masksToBounds = YES;
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [SOSDaapManager sendActionInfo:Ontsrlink_connection_templeave_back_click];
        [SOSOnstarLinkSDKTool enterOnstarLink];
    }];
    
    UIView *bgview = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT * .6, 120, 40)];
    bgview.right = SCREEN_WIDTH + 15;
    [bgview addSubview:button];
    bgview.clipsToBounds = NO;
    bgview.layer.shadowOpacity = .7;
    bgview.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    bgview.layer.shadowOffset = CGSizeMake(5, 5);
    bgview.layer.shadowRadius = 10;
    bgview.hidden = YES;
    return bgview;
}
#endif
@end
#endif
