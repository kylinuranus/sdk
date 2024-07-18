//
//  SOSMroService.m
//  Onstar
//
//  Created by Onstar on 2018/5/25.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSMroService.h"
#ifndef SOSSDK_SDK
#import "SOSMusicPlayer.h"
#endif
#import <AVFoundation/AVFoundation.h>

#if TARGET_IPHONE_SIMULATOR
@implementation SOSMroService
+ (instancetype)sharedMroService     {
    return nil;
}

+ (BOOL)isMroGlobalWakeup {
    return NO;
}

@end
#else


@interface SOSMroService ()
#if __has_include(<OnstarOSDK/OnstarOSDK.h>)
<VBOnstarODelegate>
#endif
@end

@implementation SOSMroService

+ (instancetype)sharedMroService 	{
    static dispatch_once_t onceToken;
    static SOSMroService *mros;
    dispatch_once(&onceToken, ^{
        mros = [[self alloc] init];
        NSLog(@"SOSMroService  sharedMroService 初始化了,注意!!!!!");
    });
    return mros;
}

- (instancetype)init     {
    self = [super init];
    if (self) {
#if __has_include(<OnstarOSDK/OnstarOSDK.h>)

        if (SOS_ONSTAR_PRODUCT) {
            [[VBOnstarOConfig sharedInstance] vb_initOnstarO];
            [VBOnstarOConfig sharedInstance].onstarODelegate = self;

            // 解决 XS Max 不能在首次安装登录后弹出 麦克风权限 弹窗的问题
            AVAudioSession* sharedSession = [AVAudioSession sharedInstance];
            if ([sharedSession respondsToSelector:@selector(recordPermission)]) {
                AVAudioSessionRecordPermission permission = [sharedSession recordPermission];
                switch (permission) {
                    case AVAudioSessionRecordPermissionUndetermined:    {
                        [sharedSession requestRecordPermission:^(BOOL granted) {
                            if (granted) {
                                [[VBOnstarOConfig sharedInstance] vb_initOnstarO];
                                [VBOnstarOConfig sharedInstance].onstarODelegate = self;
                            }
                        }];
                        break;
                    }
                    case AVAudioSessionRecordPermissionDenied:    /*
                        if (!UserDefaults_Get_Object(mroGlobalWakeupKey())) {
                            [sharedSession requestRecordPermission:^(BOOL granted) {
                                if (granted) {
                                    [[VBOnstarOConfig sharedInstance] vb_initOnstarO];
                                    [VBOnstarOConfig sharedInstance].onstarODelegate = self;
                                }
                            }];
                        }    */
                        NSLog(@"Denied");
                        break;
                    case AVAudioSessionRecordPermissionGranted:
                        NSLog(@"Granted");
                        break;
                    default:
                        break;
                }
            }
        }
#endif
    }
    return self;
}

/**
 全局唤醒存储标识
 @return 存储key
 */
static inline NSString *mroGlobalWakeupKey()	{
    return [NSString stringWithFormat:@"soskMroGlobalWakeup%@",[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
}

+ (BOOL)isMroGlobalWakeup	{
    BOOL globalWakeUp;
    if (!UserDefaults_Get_Object(mroGlobalWakeupKey())) {
        //默认yes,打开
        globalWakeUp = YES;
    }	else	{
        NSNumber * gf =  UserDefaults_Get_Object(mroGlobalWakeupKey());
        globalWakeUp = gf.boolValue;
    }
    return globalWakeUp;
}

+ (void)updateMroGlobalWakeupState:(BOOL)state;     {
    UserDefaults_Set_Object(@(state), mroGlobalWakeupKey());
    
}

- (void)openGlobalWakeUp     {
#ifndef SOSSDK_SDK
    if (![VBOnstarOConfig sharedInstance].isGlobalWakeUp) {
        [SOS_APP_DELEGATE setMroAvaudioSessionCategoryPlayAndRecord];
        [VBOnstarOConfig sharedInstance].isGlobalWakeUp = YES;
    }
#endif
}

- (void)closeGlobalWakeUp     {
#ifndef SOSSDK_SDK
    if ([VBOnstarOConfig sharedInstance].isGlobalWakeUp) {
        [VBOnstarOConfig sharedInstance].isGlobalWakeUp = NO;
        [SOS_APP_DELEGATE setMusicAvaudioSessionCategoryPlayback];
    }
#endif
}

- (void)startMroService     {
#ifndef SOSSDK_SDK
    [[VBOnstarOConfig sharedInstance] vb_startOnstarO];
#endif
    
}

- (void)addOnstarInfo	{
#ifndef SOSSDK_SDK
    [SOSVehicleInfoUtil requestVehicleEngineNumberComplete:^(NNVehicleInfoModel *vehicleModel) {
        dispatch_async_on_main_queue(^{
            VBUserCarModel *model = [[VBUserCarModel alloc] init];
            model.userName = [CustomerInfo sharedInstance].userBasicInfo.idmUser.idpUserId;
            model.vehicleID = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin;
            model.mobilePhoneNumber = [CustomerInfo sharedInstance].userBasicInfo.idmUser.mobilePhoneNumber;
            model.firstName = [CustomerInfo sharedInstance].userBasicInfo.idmUser.firstName;
            model.lastName = [CustomerInfo sharedInstance].userBasicInfo.idmUser.lastName;
            //设置车辆用户信息中的各项参数
            if (vehicleModel) {
                model.licensePlate = vehicleModel.licensePlate;
                model.engineNumber = vehicleModel.engineNumber;
            }
            [VBOnstarOConfig sharedInstance].userCarModel = model;
        });

    }];
    if (!_commandHandler) {
        _commandHandler = [[SOSMroCommandHandler alloc] init];
    }
    _commandHandler.baseController = (UINavigationController *)[[SOS_APP_DELEGATE fetchMainNavigationController] presentedViewController];
#endif
}

#pragma mark - 小O protocal
- (void)vb_sendToCarWithPoiName:(NSString *)poiName address:(NSString *)address latitude:(NSString *)latitude longitude:(NSString *)longitude {
    NSLog(@"导航目的地：%@", poiName);
    // TBT/ODD
    SOSPOI * sendToCarPOI = [[SOSPOI alloc] init];
    sendToCarPOI.name = poiName;
    sendToCarPOI.address = address;
    sendToCarPOI.latitude = latitude;
    sendToCarPOI.longitude = longitude;
    _commandHandler.tbtPoi = sendToCarPOI;
    [_commandHandler handleCommand:@"VEHICLENAVI"];
    [SOSDaapManager sendActionInfo:MrO_TrafficRestrictions_Result_ClickL10];
}

- (void)vb_sendCarCommandWithCommand:(NSString *)command {
    NSLog(@"车机命令:%@", command);
    //车辆操作命令
    [_commandHandler handleCommand:command];
    
}

- (void)vb_sendHousekeeperBusinessWithUrl:(NSString *)url {
    NSLog(@"超级管家业务：%@", url);
    [_commandHandler handleWebOpen:url];
}

- (void)vb_OnstartDidError:(NSError *)error	{
    
}

- (void)vb_didEnterOnstarOModule {

    NSLog(@"进入小O模块");
#ifndef SOSSDK_SDK
    //即将进入小O时候，如果正在放歌，Onstar这边控制将音乐暂停
    if (SOS_APP_DELEGATE.isMusicPlaying) {
        [[SOSMusicPlayer sharedInstance] pause];
        self.needResumeMusic = YES;
    }
#endif
    [SOS_APP_DELEGATE setMroAvaudioSessionCategoryPlayAndRecord];
    
    [SOSDaapManager sendActionInfo:MRO_TRAFFICRESTRICTIONS_RESULT_CLICKL9];
    
    [self addOnstarInfo];

}

- (void)vb_didExitOnstarOModule	{

#ifndef SOSSDK_SDK
    //即将退出小O时候，Onstar这边控制将音乐恢复播放
    if ([SOSMusicPlayer sharedInstance].musicPlayState == SOSMusicPlayStatePause && self.needResumeMusic) {
        [[SOSMusicPlayer sharedInstance] play];
        self.needResumeMusic = NO;
    }
#endif
}

- (void)dealloc	{
    NSLog(@"SOSMroService -------- dealloc");
}
@end

#endif
