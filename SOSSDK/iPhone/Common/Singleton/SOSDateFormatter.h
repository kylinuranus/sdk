//
//  SOSDateFormatter.h
//  Onstar
//
//  Created by TaoLiang on 2017/11/22.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOSDateFormatter : NSDateFormatter

/** DataFormatter 初始化耗时较多,故采用单例模式调用 */
+ (instancetype)sharedInstance;


/**
 style: yyyy-MM-dd

 @param string 日期string
 @return date
 */
- (NSDate *)style1_dateFromString:(NSString *)string;
- (NSString *)style1_stringFromDate:(NSDate *)date;

/**
 style: M月dd日

 @param date 日期
 @return 日期字符串
 */
- (NSString *)style2_stringFromDate:(NSDate *)date;

/** style yyyy年M月dd日 HH:mm */
- (NSDate *)style3_dateFromString:(NSString *)string;

/** style yyyy年M月dd日 HH:mm */
- (NSString *)style3_stringFromDate:(NSDate *)date;

/** yyyy-MM-dd HH:mm:ss */
- (NSDate *)style4_dateFromString:(NSString *)string;

/** yyyy-MM-dd HH:mm:ss */
- (NSString *)style4_stringFromDate:(NSDate *)date;
- (NSString *)style5_stringFromDate:(NSDate *)date;
/// MM-dd HH:mm
- (NSString *)style6_stringFromDate:(NSDate *)date;
/// 获取格林威治当前时间, 格式为 yyyy-MM-dd'T'HH:mm:ss.SSS'Z'
- (NSString *)getGenerateTimeStamp;

/// 获取 时间戳 对应日期, 格式为 yyyy-MM-dd HH:mm:ss
- (NSString *)dateStringFromTimeStamp:(long long)timeStamp;

/// 获取 时间戳 对应日期, 格式为 yyyy/MM
- (NSString *)simpleDateStringFromTimeStamp:(long long)timeStamp;
- (NSString *)simpleDateDisYearStringFromTimeStamp:(long long)timeStamp    ;
/// 常用 TimeZone: 北京时间: @"GMT+0800"		格林威治时间: @"UTC"
- (NSString *)dateStrWithDateFormat:(NSString *)dateFormat Date:(NSDate *)date timeZone:(NSString *)timeZone;

/// 将传入的时间字符串转化为 NSDate    传入字符串格式为 yyyy-MM-dd'T'HH:mm:ss.SSS'Z'
- (NSDate *)getDateWithSourceDateString:(NSString *)sourceDateStr;

/**
 判断是否同一天

 @param date1
 @param date2
 @return 
 */
+ (BOOL)isSameDay:(NSDate *)date1 date2:(NSDate *)date2;

/// 获取传入 date 据现在的间隔时长 (刚刚/xx分钟前/xx小时前/xx天前)
+ (NSString *)gapTimeStrFromNowWithDate:(NSDate *)date;


@end
