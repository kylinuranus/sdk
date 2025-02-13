//
//  HDWindowLogger.h
//  HDWindowLogger
//
//  Created by Damon on 2019/5/28.
//  Copyright © 2019 Damon. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HDWindowLoggerItem;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HDLogType) {
    kHDLogTypeNormal = 0,   //textColor #fbf2d5
    kHDLogTypeWarn,         //textColor #f6f49d
    kHDLogTypeError,        //textColor #ff7676
    kHDLogTypeSuccess
};

#pragma mark -
#pragma mark - 快捷宏定义输出类型
#define HDNormalLog(log) [HDWindowLogger printLog:log withLogType:kHDLogTypeNormal]     //普通类型的输出
#define HDWarnLog(log) [HDWindowLogger printLog:log withLogType:kHDLogTypeWarn]         //警告类型的输出
#define HDErrorLog(log) [HDWindowLogger printLog:log withLogType:kHDLogTypeError]       //错误类型的输出
#define HDSuccessLog(log) [HDWindowLogger printLog:log withLogType:kHDLogTypeSuccess]   //成功类型的输出

#pragma mark -
#pragma mark - HDWindowLogger
@interface HDWindowLogger : UIWindow
@property (strong, nonatomic, readonly) NSMutableArray *mLogDataArray;  //log信息内容
+ (HDWindowLogger *)defaultWindowLogger;

/**
 根据日志的输出类型去输出相应的日志，不同日志类型颜色不一样

 @param log 日志内容
 @param logType 日志类型
 */
+ (void)printLog:(id)log withLogType:(HDLogType)logType;

/**
 删除log日志
 */
+ (void)cleanLog;


/**
 改变显示状态
 */
+ (void)changeVisible;

/**
 显示log窗口
 */
+ (void)show;


/**
 隐藏整个log窗口
 */
+ (void)hide;


/**
 只隐藏log的输出窗口，保留悬浮图标
 */
+ (void)hideLogWindow;


/**
 为了节省内存，可以设置记录的最大的log数，超出限制删除最老的数据，默认100条

 @param logCount 0为不限制
 */
+ (void)setMaxLogCount:(NSInteger)logCount;
@end

#pragma mark -
#pragma mark - 每个打印的item
@interface HDWindowLoggerItem : NSObject
@property (assign, nonatomic) HDLogType mLogItemType;
@property (strong, nonatomic) id mLogContent;
@property (strong, nonatomic) NSDate *mCreateDate;
///获取item的拼接的打印内容
- (NSString *)getFullContentString;
@end

NS_ASSUME_NONNULL_END
