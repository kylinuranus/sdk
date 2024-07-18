//
//  HomePageViewControllerUtil.h
//  Onstar
//
//  Created by Apple on 16/6/29.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HandleDataRefreshDataUtil : NSObject

/**
 *  设置车辆信息
 *
 *  @param dic 车辆信息
 */
+ (void)setupVehicleStatusInfo:(NSDictionary *)dic;

+ (NSMutableAttributedString *)AttributeString:(NSString *)str andRearNumber:(int)rear;

+ (BOOL)isValidPercentValue:(NSString *)value;

//+ (void) channelTitleListArr:(NSArray *)channelTitleListArr channelimageListArr:(NSArray *)channelimageListArr channelselectimageListArr:(NSArray *)channelselectimageListArr filePath:(NSString *)filePath;

/**
 *  未登录用户、访客，默认快捷键(一键到家、车辆位置、预约经销商、搜索兴趣点)
 *
 *  @param selectFilePath selectFilePath
 *  @param arrFix         arrFix
 *  @param arrTo          arrTo
 */
//+ (void)default_unloggedin_visitor:(NSString *)selectFilePath arrFix:(NSArray *)arrFix arrTo:(NSArray *)arrTo;

/**
 *  根据角色写入快捷键文件
 *
 *  @param selectFilePath selectFilePath
 *  @param arrFix         arrFix
 *  @param arrTo          arrTo
 */
//+ (void)writeShortcutFile:(NSString *)selectFilePath arrFix:(NSArray *)arrFix arrTo:(NSArray *)arrTo;

/**
 *  是否显示驾驶评分
 *
 *  @return BOOL
 */
+ (BOOL)showDriveScore;

+ (void)drivingBehavior:(UINavigationController *)navi;
+ (void)oilConsumptionRanking:(UINavigationController *)navi;
@end
