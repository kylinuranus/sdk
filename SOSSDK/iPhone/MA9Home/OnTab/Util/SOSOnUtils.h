//
//  SOSOnUtils.h
//  Onstar
//
//  Created by onstar on 2018/12/25.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSOnUtils : NSObject


/**
 @return 全部基础u远程控制命令
 */
+ (NSArray *)normalFullRemoteItems;

/**
 @return 默认显示的远程控制命令 未登录/访客/登录失败显示灰色图标
 */
+ (NSArray *)defaultRemoteItems;

/**
 @return 全部icm远程控制命令
 */
+ (NSArray *)icmFullRemoteItems;

/**
 @return 当前车辆c支持的基础命令
 */
+ (NSArray *)supportNormalRemoteItems;

/**
 @return 当前车辆支持的icm命令
 */
+ (NSArray *)supportIcmRemoteItems;


@end

NS_ASSUME_NONNULL_END
