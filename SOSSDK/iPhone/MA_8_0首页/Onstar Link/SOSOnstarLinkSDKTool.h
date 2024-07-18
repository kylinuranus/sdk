//
//  SOSOnstarLinkSDKTool.h
//  Onstar
//
//  Created by Coir on 2018/7/23.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>


#if __has_include(<OnStarVersionSDK/YFOnStarVersionManager.h>)
#import <OnStarVersionSDK/YFOnStarVersionManager.h>
#endif

@interface SOSOnstarLinkSDKTool : NSObject

#if __has_include(<OnStarVersionSDK/YFOnStarVersionManager.h>)

#if TARGET_IPHONE_SIMULATOR
#else
@property (nonatomic, assign) YFOnStarLinkStatus onstarLinkStatus;
#endif

#endif
@property (nonatomic, assign) BOOL isOnstarLinkRunning;

+ (SOSOnstarLinkSDKTool *)sharedInstance;

+ (void)enterOnstarLink;

+ (void)configOnstarLinkSDK;

/// 设置客户端 OTA 升级 Block
+ (void)configOTABlock;

/// 设置客户端拨打电话 Block
+ (void)configCallOnstarBlock;

/// 触发 SDK 导航至 POI
+ (void)navigateToPoiWithLatitude:(NSString *)latitude longitude:(NSString *)longitude;

/// 获取主页面悬浮 Button
+ (UIView *)getOnstarLinkButtonView;

@end

//#endif
