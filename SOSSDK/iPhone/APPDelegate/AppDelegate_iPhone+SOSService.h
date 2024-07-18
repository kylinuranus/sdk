//
//  AppDelegate_iPhone+SOSService.h
//  Onstar
//
//  Created by lizhipan on 2017/9/15.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "AppDelegate_iPhone.h"

@interface AppDelegate_iPhone (SOSService)



/**
 腾讯bugly
 */
- (void)initBugly;

/**
 高德地图初始化
 */
- (void)initAmap;

///**
// 小O初始化
// */
//- (void)initMrO;



/**
 网易云信初始化
 */
- (void)initNIM;

/**
 设置部分启动写入参数
 */
- (void)initLaunchingPara;


- (void)autoLoadVehicleData;
- (void)observeLoginSuccessAction;

/**
 AvaudioSessionCategory设置为云音乐需要的模式
 */
- (void)setMusicAvaudioSessionCategoryPlayback;

/**
 AvaudioSessionCategory设置为小O需要的模式
 */
- (void)setMroAvaudioSessionCategoryPlayAndRecord;


/**
 暂停云音乐
 */
- (void)pauseSOSMusicIfNeeded;


/**
 恢复audioSeesion设置
 */
- (void)restoreAudioSessionCatergory;

@end
