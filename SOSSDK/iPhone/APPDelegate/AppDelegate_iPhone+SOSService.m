//
//  AppDelegate_iPhone+SOSService.m
//  Onstar
//
//  Created by lizhipan on 2017/9/15.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//
#import "SOSMapHeader.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppDelegate_iPhone+SOSService.h"
#import "SOSPageScrollViewController.h"
#ifndef SOSSDK_SDK
#import <OnstarOSDK/OnstarOSDK.h>
#import "SOSMusicPlayer.h"
#import <NIMSDK/NIMSDK.h>
#import "NIMKit.h"
#import "SOSAttachmentDecoder.h"
#import "SOSSocialCellLayoutConfig.h"
#endif

#import <AVFoundation/AVFoundation.h>
#import "SOSWebViewController.h"
#import "SOSVehicleInfoUtil.h"
#import "SOSKeyChainManager.h"
#import "SOSGreetingManager.h"
#import "SOSLoginPopView.h"
//#import "SOSFlutterManager.h"


#import "SOSMroService.h"
#import "LoadingView.h"
#import "SOSPOPUtil.h"
//#import <SOSBugly/Bugly.h>
#import "SOSLoginUserDbService.h"


@implementation AppDelegate_iPhone (SOSService)

- (void)initBugly {
    //Flutter端调用
//    if(![SOSGreetingManager shareInstance].flutterEnable) {
//        BuglyConfig * config = [[BuglyConfig alloc] init];
//        config.version = [UIApplication sharedApplication].appVersion;
//    #if DEBUG || TEST
//        config.blockMonitorEnable = YES;
//    #endif
//        [Bugly startWithAppId: BUGLY_APP_KEY
//    #if DEBUG
//            developmentDevice:YES
//    #endif
//                       config:config];
//    }
}


- (void)initAmap {
    /***高德***/
    //AmapLocation and AmapSearch Framework support ATS
    [AMapServices sharedServices].enableHTTPS = YES;
    //配置用户Key，为保证应用启动时定位成功，此方法需放在主线程
    [AMapServices sharedServices].apiKey = AMapKey;
    //    ///任性的高德又移除了MAMapServices类
    //    [MAMapServices sharedServices].apiKey = AMapKey;
    /***/

}

- (void)initNIM {
#ifndef SOSSDK_SDK
    //appkey 是应用的标识，不同应用之间的数据（用户、消息、群组等）是完全隔离的。
    //如需打网易云信 Demo 包，请勿修改 appkey ，开发自己的应用时，请替换为自己的 appkey 。
    //并请对应更换 Demo 代码中的获取好友列表、个人信息等网易云信 SDK 未提供的接口。
    //云信后台OnstarTest
    NSString *appKey = SOS_NIM_APP_KEY;
    NIMSDKOption *option = [NIMSDKOption optionWithAppKey:appKey];
    option.apnsCername = SOS_NIM_CER_NAME;
    [[NIMSDK sharedSDK] registerWithOption:option];
    
    [NIMCustomObject registerCustomDecoder:[[SOSAttachmentDecoder alloc]init]];
    //注册 NIMKit 自定义排版配置
    [[NIMKit sharedKit] registerLayoutConfig:[SOSSocialCellLayoutConfig new]];
#endif
}

- (void)initLaunchingPara	{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //非首次启动
    BOOL bNotFirstTime = [defaults boolForKey:FLAG_NOT_FIRST_TIME_RUNNING];
    if(!bNotFirstTime)  {
        [SOSKeyChainManager clearFingerPrint];
        [SOSKeyChainManager clearLoginTokenScop];
        [SOSKeyChainManager clearLoginuserNameAndPassword];
        [defaults removeObjectForKey:@"openFingerPwdAlert"];
        [defaults setBool:YES forKey:FLAG_NOT_FIRST_TIME_RUNNING];
        [defaults setInteger:0 forKey:K_ROUTE_SELECTED_OPTION];
        NSNumber *chooseTag = [NSNumber numberWithInteger:1];
        [defaults setObject:chooseTag forKey:DEFAULT_SEARCH_AROUND];
        [defaults setInteger:0 forKey:Success_Count];
        [defaults setInteger:0 forKey:Total_Alert];
        [defaults setInteger:0 forKey:Comment_Count];
        [defaults setInteger:0 forKey:Refuse_Count];
        [defaults synchronize];
    }
}

- (void)autoLoadVehicleData {
    @weakify(self)
    [RACObserve([LoginManage sharedInstance], loginState) subscribeNext:^(NSNumber *x) {
        @strongify(self)
        dispatch_async_on_main_queue(^{
            if (x.integerValue == LOGIN_STATE_LOADINGVEHICLEPRIVILIGESUCCESS) {
                [self loadData];
            }else if (x.integerValue == LOGIN_STATE_NON) {
                [SOSGreetingManager shareInstance].vehicleStatus = RemoteControlStatus_Void;
            }else if (x.integerValue == LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS) {
               #ifndef SOSSDK_SDK
                [self showPOP];
                #endif

            }
            
            if (x.integerValue == LOGIN_STATE_NON || [[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
                [self refreshMrOState];
            }
            
        });
    }];
}

- (void)observeLoginSuccessAction {
    [RACObserve([LoginManage sharedInstance], loginState) subscribeNext:^(NSNumber *x) {
        dispatch_async_on_main_queue(^{
            if (x.integerValue == LOGIN_STATE_LOADINGVEHICLEPRIVILIGESUCCESS) {
                ![LoginManage sharedInstance].loginSuccessAction?:[LoginManage sharedInstance].loginSuccessAction();
                [LoginManage sharedInstance].loginSuccessAction = nil;
            }else if (x.integerValue == LOGIN_STATE_NON) {
                [LoginManage sharedInstance].loginSuccessAction = nil;
            }
        });
    }];
}



- (void)refreshMrOState    {
    if (!SOS_ONSTAR_PRODUCT) {
        return;
    }
    
    if ([LoginManage sharedInstance].loginState == LOGIN_STATE_NON) {
        if ([SOSMroService isMroGlobalWakeup] && SOS_APP_DELEGATE.isMroActive) {
            //关闭小O全局唤醒
            [[SOSMroService sharedMroService] closeGlobalWakeUp];
        }
        SOS_APP_DELEGATE.isMroActive = NO;
    }    else    {
        BOOL isExpired = [[SOSLoginUserDbService sharedInstance] isExpiredIdToken:[LoginManage sharedInstance].idToken];
        BOOL needShowMrO = [[Util readMrOOpenFlagByidpid:[CustomerInfo sharedInstance].userBasicInfo.idpUserId] boolValue];
        if ([SOSCheckRoleUtil isOwner]  && needShowMrO && !isExpired){
            SOS_APP_DELEGATE.isMroActive = YES;
            if ([SOSMroService  isMroGlobalWakeup]) {
                [[SOSMroService sharedMroService] openGlobalWakeUp];
            }
        }   else    {
            SOS_APP_DELEGATE.isMroActive = NO;
        }
    }
    
}

- (void)loadData {
//    if (![SOSGreetingManager shareInstance].flutterEnable) {
//        //flutter端会加载缓存调用handle方法加载z车况数据至内存
        [CustomerInfo selectVehicleDataFromDB:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
//    }
//    SOSFlutterVehicleConditionEnable({}, {[CustomerInfo selectVehicleDataFromDB:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];});
    
    if (![SOSCheckRoleUtil checkPackageServiceAvailable:PP_DataRefresh andNeedPopError:NO]) {
        [SOSGreetingManager shareInstance].vehicleStatus = RemoteControlStatus_OperateFail;
        return;
    }
    BOOL autoRefreshInAppSetting = [[NSUserDefaults standardUserDefaults] boolForKey:NEED_AUTO_REFRESH];
    //CR:优化车况自动刷新开关逻辑,在开关关闭的情况下,无论有无缓存,都停止刷新车况
    if (autoRefreshInAppSetting == YES )	{
        // 自动刷新
        NSTimeInterval start = [[NSDate date] timeIntervalSince1970] ;
        [SOSVehicleInfoUtil requestVehicleInfoSuccess:^(id result) {
           [SOSDaapManager sendSysLayout:start endTime:[[NSDate date] timeIntervalSince1970]  loadStatus:YES  funcId:VEHICLEDIA_LOADTIME];
        }  Failure:^(id result) {
            // 排除因登录状态,重复操作导致的车况刷新操作未能开始的场景
            if (result) {
                [SOSDaapManager sendSysLayout:start endTime:[[NSDate date] timeIntervalSince1970] loadStatus:NO  funcId:VEHICLEDIA_LOADTIME];
            }
        }];
    }
}

/**
 登录后弹框
 */
- (void)showPOP {
    NSString *showDate = UserDefaults_Get_Object(SOS_INSURANCE_KEY);
    NSDate *date = [NSDate date];
    NSString *today = [date stringWithFormat:@"yyyy-MM-dd"];
    if ([showDate isEqualToString:today]) {
//        [Util showAlertWithTitle:@"" message:@"xxx" completeBlock:^(NSInteger buttonIndex) {
//            
//        }];
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SOSPOPUtil getInsurancePromptSuccess:^(SOSInsuranceModel *insuranceModel) {
            if ([insuranceModel.isPrompt isEqualToString:@"N"]) {
                return;
            }
            [[LoginManage sharedInstance] addPopViewAction:^{
                SOSLoginPopView *guideView = [SOSLoginPopView quickInit];
                [guideView.imageView sd_setImageWithURL:[NSURL URLWithString:insuranceModel.promptImageUrl] placeholderImage:[UIImage imageNamed:@"iapGuidePlaceholder"]];
                [guideView showInView:KEY_WINDOW imgTapBlock:^{
                    [self showPopWebWithUrl:insuranceModel.refLinkUrl];
                    if ([insuranceModel.promptType isEqualToString:@"2"]) {
                        //超速
                        [SOSDaapManager sendActionInfo:Joylifead_banner_speeding];
                    }else if ([insuranceModel.promptType isEqualToString:@"1"]){
                        //节假日
                        [SOSDaapManager sendActionInfo:Joylifead_banner_specifieddate];
                    }
                    [guideView dismiss];
                    [[LoginManage sharedInstance] nextPopViewAction];
                }];
            }];
            NSDate *date = [NSDate date];
            NSString *today = [date stringWithFormat:@"yyyy-MM-dd"];
            UserDefaults_Set_Object(today, SOS_INSURANCE_KEY);
            
        } Failed:^(NSString *responseStr, NSError *error) {
            
        }];
        
    });
}

- (void)showPopWebWithUrl:(NSString *)url {
    
    SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:url];
    id navc = [[CustomNavigationController alloc] initWithRootViewController:vc];
    if (navc) {
        UINavigationController *v =  (UINavigationController *)([SOS_APP_DELEGATE fetchMainNavigationController]);
        [v presentViewController:navc animated:YES completion:nil];
    }
}


- (void)setMusicAvaudioSessionCategoryPlayback{
        if (self.isMroActive) {
            if (![[AVAudioSession sharedInstance].category isEqualToString:AVAudioSessionCategoryPlayback])  {
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
                [[AVAudioSession sharedInstance] setActive:YES error:nil];
                //通知小O停止录音
//                [[NSNotificationCenter defaultCenter] postNotificationName: kVBAVAudiosessionCategoryValueDidChange object:nil];
            }
        }
}
- (void)setMroAvaudioSessionCategoryPlayAndRecord{
        if (self.isMroActive ) {
            //小O 全局唤醒或者在小O界面内
            if (!self.isMusicPlaying) {
                if (![[AVAudioSession sharedInstance].category isEqualToString:AVAudioSessionCategoryPlayAndRecord]) {
                    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
                    [[AVAudioSession sharedInstance] setActive:YES error:nil];
//                    [[NSNotificationCenter defaultCenter] postNotificationName: kVBAVAudiosessionCategoryValueDidChange object:nil];
                }
                
            }
        }
}

- (void)pauseSOSMusicIfNeeded {
#ifndef SOSSDK_SDK
    if (self.isMusicPlaying) {
        [[SOSMusicPlayer sharedInstance] pause];
    }
#endif
}

- (void)restoreAudioSessionCatergory {
    if ([SOSMroService isMroGlobalWakeup]) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];

    }else {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}


@end
