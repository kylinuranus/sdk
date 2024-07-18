//
//  SOSNavigateTool.h
//  Onstar
//
//  Created by Coir on 27/10/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoadingView.h"

@interface SOSNavigateTool : NSObject

/// 显示路况,并跳转地图页面
+ (void)showTraffic:(BOOL)show;

/// 跳转附近加油站
+ (void)showAroundOilStationWithCenterPOI:(SOSPOI *)poi FromVC:(UIViewController *)vc;

/// 跳转电子围栏页面
+ (void)showGeoPageFromVC:(UIViewController *)fromVC;

/// 跳转智能家居页面
//+ (void)showSmartHomeFromVC:(__kindof UIViewController *)fromVC;

/// 9.0+ Trip 导航下发  只有车载导航时，点击后即为车载导航； 只有音控领航时，点击后即为音控领航； 二者皆有时，点击后弹出选项。
+ (void)sendToCarAutoWithPOI:(SOSPOI *)poi;

/// 导航下发,增加 DaapFuncID , ODDDaapFuncID 和 CancelDaapFuncID, 用于埋点需求
+ (void)sendToCarAutoWithPOI:(SOSPOI *)poi TBTDaapFuncID:(NSString *)tbtID AndODDDaapFuncID:(NSString *)oddID CancelDaapFuncID:(NSString *)cancelID;

@end
