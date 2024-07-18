//
//  SOSDateFormatter.m
//  Onstar
//
//  Created by TaoLiang on 2017/11/22.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSDateFormatter.h"


@implementation SOSDateFormatter

static SOSDateFormatter *dateFormatter = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [SOSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy年MM月dd日";
    });
    return dateFormatter;
}

//- (NSString *)stringFromDate:(NSDate *)date {
//    self.dateFormat = @"yyyy年MM月dd日";
//    return [super stringFromDate:date];
//}

//- (NSDate *)dateFromString:(NSString *)string {
//    self.dateFormat = @"yyyy年MM月dd日";
//    return [super dateFromString:string];
//
//}

- (NSDate *)style1_dateFromString:(NSString *)string {
    self.dateFormat = @"yyyy-MM-dd";
    return [super dateFromString:string];
}

- (NSString *)style1_stringFromDate:(NSDate *)date {
    self.dateFormat = @"yyyy-MM-dd";
    return [super stringFromDate:date];
}


- (NSString *)style2_stringFromDate:(NSDate *)date {
    self.dateFormat = @"M月dd日";
    return [super stringFromDate:date];
}

- (NSDate *)style3_dateFromString:(NSString *)string {
    self.dateFormat = @"yyyy年M月dd日 HH:mm";
    return [super dateFromString:string];
}

- (NSString *)style3_stringFromDate:(NSDate *)date {
    self.dateFormat = @"yyyy年M月dd日 HH:mm";
    return [super stringFromDate:date];
}

- (NSDate *)style4_dateFromString:(NSString *)string {
    self.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [super dateFromString:string];
}

- (NSString *)style4_stringFromDate:(NSDate *)date	 {
    self.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [super stringFromDate:date];
}
- (NSString *)style5_stringFromDate:(NSDate *)date     {
    self.dateFormat = @"MM-dd HH:mm:ss";
    return [super stringFromDate:date];
}

- (NSString *)style6_stringFromDate:(NSDate *)date {
    self.dateFormat = @"MM-dd HH:mm";
    return [super stringFromDate:date];
}

+ (BOOL)isSameDay:(NSDate *)date1 date2:(NSDate *)date2 {
    NSTimeInterval timeInterval = [date2 timeIntervalSinceDate:date1];
    int days = ((int)timeInterval)/(3600*24);
    return abs(days) == 0 ? YES : NO;

}

/// 获取格林威治当前时间, 格式为 yyyy-MM-dd'T'HH:mm:ss.SSS'Z'
- (NSString *)getGenerateTimeStamp    {
    return [self dateStrWithDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" Date:nil
                                             timeZone:@"UTC"];
}

/// 获取 时间戳 对应日期, 格式为 yyyy-MM-dd HH:mm:ss
- (NSString *)dateStringFromTimeStamp:(long long)timeStamp        {
    NSDateFormatter *stampFormatter = [[NSDateFormatter alloc] init];
    [stampFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *stampDate = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    NSLog(@"时间戳转化时间 >>> %@",[stampFormatter stringFromDate:stampDate]);
    return [self dateStrWithDateFormat:@"yyyy-MM-dd HH:mm:ss" Date:stampDate timeZone:nil];
    return [self stringFromDate:stampDate];
}
/// 获取 时间戳 对应日期, 格式为 yyyy/MM
- (NSString *)simpleDateStringFromTimeStamp:(long long)timeStamp	{
    NSDateFormatter *stampFormatter = [[NSDateFormatter alloc] init];
    [stampFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *stampDate = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    NSLog(@"时间戳转化时间 >>> %@",[stampFormatter stringFromDate:stampDate]);
    return [self dateStrWithDateFormat:@"yyyy/M" Date:stampDate timeZone:nil];
    return [self stringFromDate:stampDate];
}
- (NSString *)simpleDateDisYearStringFromTimeStamp:(long long)timeStamp    {
    NSDateFormatter *stampFormatter = [[NSDateFormatter alloc] init];
    [stampFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *stampDate = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    NSLog(@"时间戳转化时间 >>> %@",[stampFormatter stringFromDate:stampDate]);
    return [self dateStrWithDateFormat:@"MM-dd HH:mm:ss" Date:stampDate timeZone:nil];
    return [self stringFromDate:stampDate];
}
- (NSString *)dateStrWithDateFormat:(NSString *)dateFormat Date:(NSDate *)date timeZone:(NSString *)timeZone    {
    NSDate *sourceDate;
    if (date == nil)    sourceDate = [NSDate date];
    else                sourceDate = [date copy];
    if (!dateFormatter)		[SOSDateFormatter sharedInstance];
    [dateFormatter setDateFormat:dateFormat];
    dateFormatter.dateFormat = dateFormat;
    if (timeZone.length)     dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:timeZone];
    NSString *destDateString = [dateFormatter stringFromDate:sourceDate];
    dateFormatter.timeZone = nil;
    return destDateString;
}

/// 将传入的时间字符串转化为 NSDate    传入字符串格式为 yyyy-MM-dd'T'HH:mm:ss.SSS'Z'
- (NSDate *)getDateWithSourceDateString:(NSString *)sourceDateStr    {
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSDate *date = [dateFormatter dateFromString:sourceDateStr];
    dateFormatter.timeZone = nil;
    return date;
}

+ (NSString *)gapTimeStrFromNowWithDate:(NSDate *)date	{
    NSTimeInterval timeInterval = -[date timeIntervalSinceNow];
    if (timeInterval < 120) 		return @"刚刚";
    int min = timeInterval / 60;
    if (min < 60)				return [NSString stringWithFormat:@"%d分钟前", min];
    int hour = timeInterval / 3600;
    if (hour < 24)				return [NSString stringWithFormat:@"%d小时前", hour];
    int day = timeInterval / (3600 * 24);
    return [NSString stringWithFormat:@"%d天前", day];
}

@end
