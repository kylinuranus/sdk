//
//  PushNotificationManager.h
//  Onstar
//
//  Created by Apple on 16/12/13.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushNotificationManager : NSObject
+ (void)resetReminderOpenApp;
//获取calendar对象
+ (NSCalendar *)getCurrentCalendar;
//获取yyyy-MM-dd格式dataformatter
+ (NSDateFormatter *)getYmdDateFomatter;
+ (NSDateFormatter *)getZhcnSingledatefomatter;
//
+ (NSDateFormatter *)getZhcndatefomatter;
//获取yyyy-MM-dd HH:mm:ss格式dataformatter
+ (NSDateFormatter *)getYmdHmsDateFomatter;
//设置车主生活通知
+ (void)settingOwnerLifePush;

//设置驾照到期日提醒通知
+ (void)settingLicenseExpireAlertAndPush:(NSDate *)dt isAlert:(BOOL)isAlert;

//设置交强险到期日提醒通知
+ (void)settingCompulsoryInsuranceExpireAlertAndPush:(NSDate *)dt isAlert:(BOOL)isAlert;

//设置商业险到期日提醒通知
+ (void)settingBusinessInsuranceExpireAlertAndPush:(NSDate *)dt isAlert:(BOOL)isAlert;

//取消驾照到期日、交强险到期日、商业险到期日通知
+ (void)cancelLicenseBusinessInsuranceNotification;

//设置车检日期提醒通知
+ (void)settingCarDetectionNotify:(NSDate *)drivingLicenseDate ;

//取消车检日提醒通知
+ (void)cancelCarDetectionNotification;

@end
