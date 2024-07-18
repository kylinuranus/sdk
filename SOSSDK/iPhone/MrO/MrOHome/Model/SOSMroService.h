//
//  SOSMroService.h
//  Onstar
//
//  Created by Onstar on 2018/5/25.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __has_include(<OnstarOSDK/OnstarOSDK.h>)
#import <OnstarOSDK/OnstarOSDK.h>
#endif

#import "SOSVehicleInfoUtil.h"
#import "SOSMroCommandHandler.h"

@interface SOSMroService : NSObject	{
}

@property (nonatomic, strong) SOSMroCommandHandler* commandHandler;
@property(nonatomic ,assign)BOOL needResumeMusic; //假如云音乐在播放进入小O后被暂停,退出小O时是否需要恢复播放
+ (instancetype)sharedMroService;
///**
// 启动小O主界面
// */
//- (NSString *)mroGlobalWakeupKey;

/**
<<<<<<< .working
 小O全局唤醒是否打开

 @return
=======
 小O全局唤醒是否打开
 
 @return
 */
+ (BOOL)isMroGlobalWakeup;

/**
 本地记录全局唤醒是否打开
 
 @param state
 */
+ (void)updateMroGlobalWakeupState:(BOOL)state;
- (void)startMroService;
- (void)openGlobalWakeUp;
- (void)closeGlobalWakeUp;

@end
