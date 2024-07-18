//
//  PushNotificationManager.m
//  Onstar
//
//  Created by Apple on 16/12/13.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "PushNotificationManager.h"
#import <UserNotifications/UserNotifications.h>
#import "SOSCheckRoleUtil.h"
#import "AccountInfoUtil.h"
#import "SOSDateFormatter.h"

#define OPEN_APP_CYCLE_10           @"OPEN_APP_CYCLE_10"
#define OPEN_APP_CYCLE_20           @"OPEN_APP_CYCLE_20"
#define OPEN_APP_KEY                @"AlertKey"
#define OPEN_APP_CYCLE_10_DURATION  (60*60*24*10)
#define OPEN_APP_CYCLE_20_DURATION  (60*60*24*20)
#define TEST_DURATION_1             (60*1)
#define TEST_DURATION_2             (60*2)

#define License_Renewal_60          @"License_Renewal_60"
#define License_Renewal_30          @"License_Renewal_30"
#define License_Renewal_7           @"License_Renewal_7"
#define License_Renewal_0           @"License_Renewal_0"
#define License_Renewal_KEY         @"License_Renewal_KEY"

//车检iden
#define CarDetection_Notify_KEY     @"Car_Detection_Notify_KEY"

//交强险
#define Compulsory_Insurance_Expire_90          @"Compulsory_Insurance_Expire_90"
#define Compulsory_Insurance_Expire_60          @"Compulsory_Insurance_Expire_60"
#define Compulsory_Insurance_Expire_30          @"Compulsory_Insurance_Expire_30"
#define Compulsory_Insurance_Expire_KEY         @"Compulsory_Insurance_Expire_KEY"
//商业险
#define Business_Insurance_Expire_90          @"Business_Insurance_Expire_90"
#define Business_Insurance_Expire_60          @"Business_Insurance_Expire_60"
#define Business_Insurance_Expire_30          @"Business_Insurance_Expire_30"
#define Business_Insurance_Expire_KEY         @"Business_Insurance_Expire_KEY"
//满6年
static NSString * const kVehicleDetection_Notification_before3;
static NSString * const kVehicleDetection_Notification_before7;
static NSString * const kVehicleDetection_Notification_before30;
//6年内
static NSString * const kVehicleDetection_Notification_1_year_before3;//第二年
static NSString * const kVehicleDetection_Notification_1_year_before7;//第二年
static NSString * const kVehicleDetection_Notification_1_year_before30;//第二年

static NSString * const kVehicleDetection_Notification_2_year_before3;//第四年
static NSString * const kVehicleDetection_Notification_2_year_before7;//第四年
static NSString * const kVehicleDetection_Notification_2_year_before30;//第四年

static NSString * const kVehicleDetection_Notification_3_year_before3;//第六年
static NSString * const kVehicleDetection_Notification_3_year_before7;//第六年
static NSString * const kVehicleDetection_Notification_3_year_before30;//第六年

static NSString *const ownerLifePushHour = @"09";

@implementation PushNotificationManager
//#define kDevelopment 1   //本地通知测试开关，设置情况下本地通知在设置时间2分钟后推送本地通知

+ (void)resetReminderOpenApp
{
//    UIApplication *app = [UIApplication sharedApplication];
//    NSArray *localNotifyArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
//    for (UILocalNotification *item in localNotifyArray) {
////        [[UIApplication sharedApplication] cancelLocalNotification:item];
//        if ([[[item userInfo] objectForKey:OPEN_APP_KEY] isEqualToString:OPEN_APP_CYCLE_10] ||
//            [[[item userInfo] objectForKey:OPEN_APP_KEY] isEqualToString:OPEN_APP_CYCLE_20]) {
//            [[UIApplication sharedApplication] cancelLocalNotification:item];
//        }
//    }
//
//    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:OPEN_APP_CYCLE_10_DURATION]; // 10天提醒
//    UILocalNotification *noti = [[UILocalNotification alloc] init];
//    noti.fireDate = date;
//    noti.timeZone = [NSTimeZone defaultTimeZone];
//    noti.repeatInterval = 0; // don't repeat
//    noti.soundName = UILocalNotificationDefaultSoundName;
//    noti.alertBody = NSLocalizedString(@"SB028_MSG002", nil);
//    //设置userinfo 方便在之后需要撤销的时候使用
//    NSDictionary *infoDic = [NSDictionary dictionaryWithObject:OPEN_APP_CYCLE_10 forKey:OPEN_APP_KEY];
//    noti.userInfo = infoDic;
//    //添加推送到uiapplication
//    [app scheduleLocalNotification:noti];
//
//    date = [NSDate dateWithTimeIntervalSinceNow:OPEN_APP_CYCLE_20_DURATION]; // 20天提醒
//    noti = [[UILocalNotification alloc] init];
//    noti.fireDate = date;
//    noti.timeZone = [NSTimeZone defaultTimeZone];
//    noti.repeatInterval = 0; // don't repeat
//    noti.soundName = UILocalNotificationDefaultSoundName;
//    noti.alertBody = NSLocalizedString(@"SB028_MSG003", nil);
//    //设置userinfo 方便在之后需要撤销的时候使用
//    infoDic = [NSDictionary dictionaryWithObject:OPEN_APP_CYCLE_20 forKey:OPEN_APP_KEY];
//    noti.userInfo = infoDic;
//    //添加推送到uiapplication
//    [app scheduleLocalNotification:noti];
}
+ (NSCalendar *)getCurrentCalendar
{
    static dispatch_once_t onceToken;
    static NSCalendar * calendar;
    dispatch_once(&onceToken, ^{
    calendar = [NSCalendar currentCalendar];
    });
    return calendar;
}
+ (NSDateFormatter *)getYmdDateFomatter
{
    static dispatch_once_t onceToken;
    static NSDateFormatter * dateformatter;
    dispatch_once(&onceToken, ^{
        dateformatter = [[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"yyyy-MM-dd"];
    });
    return dateformatter;
}
+ (NSDateFormatter *)getZhcnSingledatefomatter
{
    static dispatch_once_t onceToken;
    static NSDateFormatter * dateformatter;
    dispatch_once(&onceToken, ^{
        dateformatter = [[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"yyyy年M月d日"];
    });
    return dateformatter;
}

+ (NSDateFormatter *)getZhcndatefomatter
{
    static dispatch_once_t onceToken;
    static NSDateFormatter * dateformatter;
    dispatch_once(&onceToken, ^{
        dateformatter = [[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"yyyy年MM月dd日"];
    });
    return dateformatter;
}

+ (NSDateFormatter *)getYmdHmsDateFomatter
{
    static dispatch_once_t onceToken;
    static NSDateFormatter * dateformatter;
    dispatch_once(&onceToken, ^{
        dateformatter = [[NSDateFormatter alloc] init];
        [dateformatter setTimeZone:[NSTimeZone systemTimeZone]];
        [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    });
    return dateformatter;
}

//设置车主生活通知
+ (void)settingOwnerLifePush
{
    if ([[LoginManage sharedInstance] isLoadingMainInterfaceReady] &&
        [SOSCheckRoleUtil isOwner]) {

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];

        //获取驾照日期
        [AccountInfoUtil getAccountInfo:NO Success:^(NNExtendedSubscriber *subscriber) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置驾照到期日提醒通知
                if (!IsStrEmpty(subscriber.licenseExpireDate)) {
                    NSDate *date=[dateFormatter dateFromString:subscriber.licenseExpireDate];
                    [self settingLicenseExpireAlertAndPush:date isAlert:NO];
                }
            });
        } Failed:^{
        }];
        //获取保险日期以及行驶证日期
 
        if([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin&&[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin.length>0){
            
            NSString *url = [BASE_URL stringByAppendingFormat:VEHICLE_INFO_URL,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];

            SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NNVehicleInfoModel *vehicleInfo  =[NNVehicleInfoModel mj_objectWithKeyValues:responseStr];
                    //设置交强险到期日提醒通知
                    if (!IsStrEmpty(vehicleInfo.compulsoryInsuranceExpireDate)) {
                        NSDate *date=[dateFormatter dateFromString:vehicleInfo.compulsoryInsuranceExpireDate];
                        [self settingCompulsoryInsuranceExpireAlertAndPush:date isAlert:NO];
                    }
                    //设置商业险到期日提醒通知
                    if (!IsStrEmpty(vehicleInfo.businessInsuranceExpireDate)) {
                        NSDate *date=[dateFormatter dateFromString:vehicleInfo.businessInsuranceExpireDate];
                        [self settingBusinessInsuranceExpireAlertAndPush:date isAlert:NO];
                    }
                    //设置车检提醒通知
                    if (!IsStrEmpty(vehicleInfo.drivingLicenseDate)) {
                        NSDate *date=[dateFormatter dateFromString:vehicleInfo.drivingLicenseDate];
                        [self settingCarDetectionNotify:date];
                    }

                });
            } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            }];
            [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
            [operation setHttpMethod:@"GET"];
            [operation start];
        }
      
    }
}

+ (BOOL)isNineAfter
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone systemTimeZone]];
    [df setDateFormat:@"HH"];
    NSInteger hh = [[df stringFromDate:[NSDate date]] integerValue];
    return hh >= ownerLifePushHour.integerValue;
}

//设置驾照到期日提醒通知
+ (void)settingLicenseExpireAlertAndPush:(NSDate *)dt isAlert:(BOOL)isAlert
{
    //删除以前的换证通知
    NSArray *localNotifyArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *item in localNotifyArray) {
        if ([[[item userInfo] objectForKey:License_Renewal_KEY] isEqualToString:License_Renewal_60] ||
            [[[item userInfo] objectForKey:License_Renewal_KEY] isEqualToString:License_Renewal_30] ||
            [[[item userInfo] objectForKey:License_Renewal_KEY] isEqualToString:License_Renewal_7] ||
            [[[item userInfo] objectForKey:License_Renewal_KEY] isEqualToString:License_Renewal_0]) {
            [[UIApplication sharedApplication] cancelLocalNotification:item];
        }
    }
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval editDate = [dt timeIntervalSince1970];
    if ([SOSDateFormatter isSameDay:[NSDate date] date2:dt]) {
        
    }else if (editDate < now) {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:@"亲爱的安吉星车主，您的驾照已过期，请及时前往相关部门进行换证" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ac0 = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil];
        [ac addAction:ac0];
        [ac show];
    }

//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
//    [dateFormatter setDateFormat:@"yyyyMMdd"];
//
//    NSString *expireDate = [dateFormatter stringFromDate:dt];
//    NSString *nowDt = [dateFormatter stringFromDate:[NSDate date]];
//
//    NSString *key = [NSString stringWithFormat:@"licenseExpireDateFirst_%@",[Util md5:[CustomerInfo sharedInstance].userBasicInfo.idpUserId]];
//    BOOL flg = UserDefaults_Get_Bool(key);
//    //首次填写驾照信息才提醒，如果不是首次填写，就不管了。修改是不管的，不弹框
//    if (!flg && IsStrEmpty([CustomerInfo sharedInstance].licenseExpireDate) && isAlert) {
//        UserDefaults_Set_Bool(YES, key);
//        //场景1：驾照到期日进行提醒，首次填写驾照信息，即弹框提醒车主距离换证还有多少时间；
//        if ([expireDate integerValue]>[nowDt integerValue]) {
//            NSDate *date1=[dateFormatter dateFromString:nowDt];
//            NSDate *date2=[dateFormatter dateFromString:expireDate];
//            NSTimeInterval time=[date2 timeIntervalSinceDate:date1];
//            int days=((int)time)/(3600*24);
//            NSDateFormatter *df = [[NSDateFormatter alloc] init];
//            [df setTimeZone:[NSTimeZone systemTimeZone]];
//            [df setDateFormat:@"yyyy年MM月dd日"];
//
//            NSString *info = [NSString stringWithFormat:@"亲爱的安吉星车主，您的驾照将在%i天后失效，请在%@前前往相关部门进行换证，安吉星将定期提醒您哦;",days+1,[df stringFromDate:date2]];
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:info delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"知道了", nil];
//            [alertView show];
//        }
//        //场景2：若填写的驾照到期日早于当前系统日期，需进行提醒。
//        if ([expireDate integerValue]<[nowDt integerValue]) {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"亲爱的安吉星车主，您的驾照已过期，请及时前往相关部门进行换证;" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"知道了", nil];
//            [alertView show];
//        }
//
//        if ([expireDate integerValue]==[nowDt integerValue]) {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"亲爱的安吉星车主，您的驾照将于今天到期，根据相关法律法规规定，有效期满后未换证车主，驾驶证属于失效状态，如果发生交通事故，保险公司不予赔付。为避免以上情况发生，请您尽快携带相关材料前往相关机构进行换证;" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"知道了", nil];
//            [alertView show];
//        }
//    }
//
//    //在notification中，用户点击话术将跳转到对应页面：例如车主收到保险到期的推送，点击后，进入车主生活中的保险页面。所以本地通知需要设置userInfo里面的属性type， 根据type跳转到相应的页面
//    //换证-驾照到期日前60天、30天、7天 推送提醒, 早上9点
//    //比如提前30天，就30天那天早上9点
//    //应该是提醒时间=到期日-当前日期+1,  如果今天是11日，18日到期，就12日提醒
//    if ([expireDate integerValue]>[nowDt integerValue]) {
//        NSDate *date1=[dateFormatter dateFromString:nowDt];
//        NSDate *date2=[dateFormatter dateFromString:expireDate];
//        NSTimeInterval time=[date2 timeIntervalSinceDate:date1];
//        int days=((int)time)/(3600*24);
//
//        NSDateFormatter *df = [[NSDateFormatter alloc] init];
//        [df setTimeZone:[NSTimeZone systemTimeZone]];
//        [df setDateFormat:@"yyyyMMdd HH:mm:ss"];
//        //截止日期
//        NSDate *dt1 = [df dateFromString:[NSString stringWithFormat:@"%@ %@:00:00",expireDate,ownerLifePushHour]];
//
//        //7天推送提醒，早上9:00
//        if (days>=6) {
//            NSCalendar *calendar = [NSCalendar currentCalendar];
//            NSDateComponents *com = [calendar components:NSCalendarUnitDay fromDate:dt1];
//            [com  setDay:-6];
//            NSDate *dt2 = [calendar dateByAddingComponents:com toDate:dt1 options:0];
//
//            UILocalNotification *localNote = [[UILocalNotification alloc] init];
//            localNote.fireDate = [NSDate dateWithTimeIntervalSinceNow:[dt2 timeIntervalSinceDate:[NSDate date]]];
//            localNote.timeZone = [NSTimeZone defaultTimeZone];
//            localNote.alertBody = @"亲爱的安吉星车主，您的驾照还有7天后到期，请您合理安排时间，携带相关材料前往相关机构进行换证;";
//            localNote.userInfo = @{@"aps" : @{@"alert":@{@"receiveType": @"11"}},
//                                   License_Renewal_KEY:License_Renewal_7};
//            if (!(days==6 && [self isNineAfter])) {
//                [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
//            }
//        }
//        //30天推送提醒，早上9:00
//        if (days>=29) {
//            NSCalendar *calendar = [NSCalendar currentCalendar];
//            NSDateComponents *com = [calendar components:NSCalendarUnitDay fromDate:dt1];
//            [com  setDay:-29];
//            NSDate *dt2 = [calendar dateByAddingComponents:com toDate:dt1 options:0];
//
//            UILocalNotification *localNote = [[UILocalNotification alloc] init];
//            localNote.fireDate = [NSDate dateWithTimeIntervalSinceNow:[dt2 timeIntervalSinceDate:[NSDate date]]];
//            localNote.timeZone = [NSTimeZone defaultTimeZone];
//            localNote.alertBody = @"亲爱的安吉星车主，您的驾照还有30天后到期，请您合理安排时间，携带相关材料前往相关机构进行换证;";
//            localNote.userInfo = @{@"aps" : @{@"alert":@{@"receiveType": @"11"}},
//                                   License_Renewal_KEY:License_Renewal_30};
//            if (!(days==29 && [self isNineAfter])) {
//                [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
//            }
//        }
//        //60天推送提醒，早上9:00
//        if (days>=59) {
//            NSCalendar *calendar = [NSCalendar currentCalendar];
//            NSDateComponents *com = [calendar components:NSCalendarUnitDay fromDate:dt1];
//            [com  setDay:-59];
//            NSDate *dt2 = [calendar dateByAddingComponents:com toDate:dt1 options:0];
//
//            UILocalNotification *localNote = [[UILocalNotification alloc] init];
//            localNote.fireDate = [NSDate dateWithTimeIntervalSinceNow:[dt2 timeIntervalSinceDate:[NSDate date]]];
//            localNote.timeZone = [NSTimeZone defaultTimeZone];
//            localNote.alertBody = @"亲爱的安吉星车主，您的驾照还有60天后到期，请您合理安排时间，携带相关材料前往相关机构进行换证;";
//            localNote.userInfo = @{@"aps" : @{@"alert":@{@"receiveType": @"11"}},
//                                   License_Renewal_KEY:License_Renewal_60};
//            if (!(days==59 && [self isNineAfter])) {
//                [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
//            }
//        }
//
//        //提醒日期 到期日早上9:00
//        UILocalNotification *localNote = [[UILocalNotification alloc] init];
//        localNote.fireDate = [NSDate dateWithTimeIntervalSinceNow:[dt1 timeIntervalSinceDate:[NSDate date]]];
//        localNote.timeZone = [NSTimeZone defaultTimeZone];
//        localNote.alertBody = @"亲爱的安吉星车主，您的驾照将于今天到期，根据相关法律法规规定，有效期满后未换证车主，驾驶证属于失效状态，如果发生交通事故，保险公司不予赔付。为避免以上情况发生，请您尽快携带相关材料前往相关机构进行换证;";
//        localNote.userInfo = @{@"aps" : @{@"alert":@{@"receiveType": @"11"}},
//                               License_Renewal_KEY:License_Renewal_0};
//        [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
//    }
//
//    if ([expireDate integerValue]==[nowDt integerValue]) {
//        NSDateFormatter *df = [[NSDateFormatter alloc] init];
//        [df setTimeZone:[NSTimeZone systemTimeZone]];
//        [df setDateFormat:@"yyyyMMdd HH:mm:ss"];
//        //截止日期
//        NSDate *dt1 = [df dateFromString:[NSString stringWithFormat:@"%@ %@:00:00",expireDate,ownerLifePushHour]];
//        NSTimeInterval time=[[NSDate date] timeIntervalSinceDate:dt1];
//        //今天9点之前需要进行通知提醒
//        if (time<0) {
//            //提醒日期 到期日早上9:00
//            UILocalNotification *localNote = [[UILocalNotification alloc] init];
//            localNote.fireDate = [NSDate dateWithTimeIntervalSinceNow:[dt1 timeIntervalSinceDate:[NSDate date]]];
//            localNote.timeZone = [NSTimeZone defaultTimeZone];
//            localNote.alertBody = @"亲爱的安吉星车主，您的驾照将于今天到期，根据相关法律法规规定，有效期满后未换证车主，驾驶证属于失效状态，如果发生交通事故，保险公司不予赔付。为避免以上情况发生，请您尽快携带相关材料前往相关机构进行换证;";
//            localNote.userInfo = @{@"aps" : @{@"alert":@{@"receiveType": @"11"}},
//                                   License_Renewal_KEY:License_Renewal_0};
//            [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
//        }
//    }
}

//设置交强险到期日提醒通知
+ (void)settingCompulsoryInsuranceExpireAlertAndPush:(NSDate *)dt isAlert:(BOOL)isAlert
{
    //删除以前的交强险到期通知
    NSArray *localNotifyArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *item in localNotifyArray) {
        if ([[[item userInfo] objectForKey:Compulsory_Insurance_Expire_KEY] isEqualToString:Compulsory_Insurance_Expire_90] ||
            [[[item userInfo] objectForKey:Compulsory_Insurance_Expire_KEY] isEqualToString:Compulsory_Insurance_Expire_60] ||
            [[[item userInfo] objectForKey:Compulsory_Insurance_Expire_KEY] isEqualToString:Compulsory_Insurance_Expire_30]) {
            [[UIApplication sharedApplication] cancelLocalNotification:item];
        }
    }

//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
//    [dateFormatter setDateFormat:@"yyyyMMdd"];
//
//    NSString *expireDate = [dateFormatter stringFromDate:dt];
//    NSString *nowDt = [dateFormatter stringFromDate:[NSDate date]];
//    if ([expireDate integerValue]>=[nowDt integerValue]) {
//        NSDate *date1=[dateFormatter dateFromString:nowDt];
//        NSDate *date2=[dateFormatter dateFromString:expireDate];
//        NSTimeInterval time=[date2 timeIntervalSinceDate:date1];
//        int days=((int)time)/(3600*24);
//
//        //若填写的交强险到期日早于当前系统日期小于或者等于30天，进行弹窗提醒
//        if ((days+1<=30) && isAlert) {
//            NSString *info = [NSString stringWithFormat:@"亲爱的安吉星车主，您的交强险将于%i天后到期，请您及时与保险公司续保，以确保人身财产的有效保障;",days+1];
//            [[[UIAlertView alloc] initWithTitle:nil message:info delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"知道了", nil] show];
//        }
//
//        NSDateFormatter *df = [[NSDateFormatter alloc] init];
//        [df setTimeZone:[NSTimeZone systemTimeZone]];
//        [df setDateFormat:@"yyyyMMdd HH:mm:ss"];
//        //截止日期
//        NSDate *dt1 = [df dateFromString:[NSString stringWithFormat:@"%@ %@:00:00",expireDate,ownerLifePushHour]];
//
//        //30天推送提醒，早上9:00
//        if (days>=29) {
//            NSCalendar *calendar = [NSCalendar currentCalendar];
//            NSDateComponents *com = [calendar components:NSCalendarUnitDay fromDate:dt1];
//            [com  setDay:-29];
//            NSDate *dt2 = [calendar dateByAddingComponents:com toDate:dt1 options:0];
//
//            UILocalNotification *localNote = [[UILocalNotification alloc] init];
//            localNote.fireDate = [NSDate dateWithTimeIntervalSinceNow:[dt2 timeIntervalSinceDate:[NSDate date]]];
//            localNote.timeZone = [NSTimeZone defaultTimeZone];
//            localNote.alertBody = @"亲爱的安吉星车主，您的交强险将于30天后到期，请您及时与保险公司续保，以确保人身财产的有效保障;";
//            localNote.userInfo = @{@"aps" : @{@"alert":@{@"receiveType": @"12"}},
//                                   Compulsory_Insurance_Expire_KEY:Compulsory_Insurance_Expire_30};
//            if (!(days==29 && [self isNineAfter])) {
//                [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
//            }
//        }
//        //60天推送提醒，早上9:00
//        if (days>=59) {
//            NSCalendar *calendar = [NSCalendar currentCalendar];
//            NSDateComponents *com = [calendar components:NSCalendarUnitDay fromDate:dt1];
//            [com  setDay:-59];
//            NSDate *dt2 = [calendar dateByAddingComponents:com toDate:dt1 options:0];
//
//            UILocalNotification *localNote = [[UILocalNotification alloc] init];
//            localNote.fireDate = [NSDate dateWithTimeIntervalSinceNow:[dt2 timeIntervalSinceDate:[NSDate date]]];
//            localNote.timeZone = [NSTimeZone defaultTimeZone];
//            localNote.alertBody = @"亲爱的安吉星车主，您的交强险将于60天后到期，请您及时与保险公司续保，以确保人身财产的有效保障;";
//            localNote.userInfo = @{@"aps" : @{@"alert":@{@"receiveType": @"12"}},
//                                   Compulsory_Insurance_Expire_KEY:Compulsory_Insurance_Expire_60};
//            if (!(days==59 && [self isNineAfter])) {
//                [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
//            }
//        }
//        //90天推送提醒，早上9:00
//        if (days>=89) {
//            NSCalendar *calendar = [NSCalendar currentCalendar];
//            NSDateComponents *com = [calendar components:NSCalendarUnitDay fromDate:dt1];
//            [com  setDay:-89];
//            NSDate *dt2 = [calendar dateByAddingComponents:com toDate:dt1 options:0];
//
//            UILocalNotification *localNote = [[UILocalNotification alloc] init];
//            localNote.fireDate = [NSDate dateWithTimeIntervalSinceNow:[dt2 timeIntervalSinceDate:[NSDate date]]];
//            localNote.timeZone = [NSTimeZone defaultTimeZone];
//            localNote.alertBody = @"亲爱的安吉星车主，您的交强险将于90天后到期，请您及时与保险公司续保，以确保人身财产的有效保障;";
//            localNote.userInfo = @{@"aps" : @{@"alert":@{@"receiveType": @"12"}},
//                                   Compulsory_Insurance_Expire_KEY:Compulsory_Insurance_Expire_90};
//            if (!(days==89 && [self isNineAfter])) {
//                [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
//            }
//        }
//    }
}

//设置商业险到期日提醒通知
+ (void)settingBusinessInsuranceExpireAlertAndPush:(NSDate *)dt isAlert:(BOOL)isAlert
{
    //删除以前的商业险到期通知
    NSArray *localNotifyArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *item in localNotifyArray) {
        if ([[[item userInfo] objectForKey:Business_Insurance_Expire_KEY] isEqualToString:Business_Insurance_Expire_90] ||
            [[[item userInfo] objectForKey:Business_Insurance_Expire_KEY] isEqualToString:Business_Insurance_Expire_60] ||
            [[[item userInfo] objectForKey:Business_Insurance_Expire_KEY] isEqualToString:Business_Insurance_Expire_30]) {
            [[UIApplication sharedApplication] cancelLocalNotification:item];
        }
    }

//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
//    [dateFormatter setDateFormat:@"yyyyMMdd"];
//
//    NSString *expireDate = [dateFormatter stringFromDate:dt];
//    NSString *nowDt = [dateFormatter stringFromDate:[NSDate date]];
//    if ([expireDate integerValue]>=[nowDt integerValue]) {
//        NSDate *date1=[dateFormatter dateFromString:nowDt];
//        NSDate *date2=[dateFormatter dateFromString:expireDate];
//        NSTimeInterval time=[date2 timeIntervalSinceDate:date1];
//        int days=((int)time)/(3600*24);
//
//        //若填写的商业险到期日早于当前系统日期小于或者等于30天，进行弹窗提醒
//        if ((days+1<=30) && isAlert) {
//            NSString *info = [NSString stringWithFormat:@"亲爱的安吉星车主，您的商业险将于%i天后到期，请您及时与保险公司续保，以确保人身财产的有效保障;",days+1];
//            [[[UIAlertView alloc] initWithTitle:nil message:info delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"知道了", nil] show];
//        }
//
//        NSDateFormatter *df = [[NSDateFormatter alloc] init];
//        [df setTimeZone:[NSTimeZone systemTimeZone]];
//        [df setDateFormat:@"yyyyMMdd HH:mm:ss"];
//        //截止日期
//        NSDate *dt1 = [df dateFromString:[NSString stringWithFormat:@"%@ %@:00:00",expireDate,ownerLifePushHour]];
//
//        //30天推送提醒，早上9:00
//        if (days>=29) {
//            NSCalendar *calendar = [NSCalendar currentCalendar];
//            NSDateComponents *com = [calendar components:NSCalendarUnitDay fromDate:dt1];
//            [com  setDay:-29];
//            NSDate *dt2 = [calendar dateByAddingComponents:com toDate:dt1 options:0];
//
//            UILocalNotification *localNote = [[UILocalNotification alloc] init];
//            localNote.fireDate = [NSDate dateWithTimeIntervalSinceNow:[dt2 timeIntervalSinceDate:[NSDate date]]];
//            localNote.timeZone = [NSTimeZone defaultTimeZone];
//            localNote.alertBody = @"亲爱的安吉星车主，您的商业险将于30天后到期，请您及时与保险公司续保，以确保人身财产的有效保障;";
//            localNote.userInfo = @{@"aps" : @{@"alert":@{@"receiveType": @"12"}},
//                                   Business_Insurance_Expire_KEY:Business_Insurance_Expire_30};
//            if (!(days==29 && [self isNineAfter])) {
//                [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
//            }
//        }
//        //60天推送提醒，早上9:00
//        if (days>=59) {
//            NSCalendar *calendar = [NSCalendar currentCalendar];
//            NSDateComponents *com = [calendar components:NSCalendarUnitDay fromDate:dt1];
//            [com  setDay:-59];
//            NSDate *dt2 = [calendar dateByAddingComponents:com toDate:dt1 options:0];
//
//            UILocalNotification *localNote = [[UILocalNotification alloc] init];
//            localNote.fireDate = [NSDate dateWithTimeIntervalSinceNow:[dt2 timeIntervalSinceDate:[NSDate date]]];
//            localNote.timeZone = [NSTimeZone defaultTimeZone];
//            localNote.alertBody = @"亲爱的安吉星车主，您的商业险将于60天后到期，请您及时与保险公司续保，以确保人身财产的有效保障;";
//            localNote.userInfo = @{@"aps" : @{@"alert":@{@"receiveType": @"12"}},
//                                   Business_Insurance_Expire_KEY:Business_Insurance_Expire_60};
//            if (!(days==59 && [self isNineAfter])) {
//                [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
//            }
//        }
//        //90天推送提醒，早上9:00
//        if (days>=89) {
//            NSCalendar *calendar = [NSCalendar currentCalendar];
//            NSDateComponents *com = [calendar components:NSCalendarUnitDay fromDate:dt1];
//            [com  setDay:-89];
//            NSDate *dt2 = [calendar dateByAddingComponents:com toDate:dt1 options:0];
//
//            UILocalNotification *localNote = [[UILocalNotification alloc] init];
//            localNote.fireDate = [NSDate dateWithTimeIntervalSinceNow:[dt2 timeIntervalSinceDate:[NSDate date]]];
//            localNote.timeZone = [NSTimeZone defaultTimeZone];
//            localNote.alertBody = @"亲爱的安吉星车主，您的商业险将于90天后到期，请您及时与保险公司续保，以确保人身财产的有效保障;";
//            localNote.userInfo = @{@"aps" : @{@"alert":@{@"receiveType": @"12"}},
//                                   Business_Insurance_Expire_KEY:Business_Insurance_Expire_90};
//            if (!(days==89 && [self isNineAfter])) {
//                [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
//            }
//        }
//    }
}

//取消驾照到期日、交强险到期日、商业险到期日通知
+ (void)cancelLicenseBusinessInsuranceNotification
{
    NSArray *localNotifyArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
    //驾照到期日
    for (UILocalNotification *item in localNotifyArray) {
        if ([[[item userInfo] objectForKey:License_Renewal_KEY] isEqualToString:License_Renewal_60] ||
            [[[item userInfo] objectForKey:License_Renewal_KEY] isEqualToString:License_Renewal_30] ||
            [[[item userInfo] objectForKey:License_Renewal_KEY] isEqualToString:License_Renewal_7] ||
            [[[item userInfo] objectForKey:License_Renewal_KEY] isEqualToString:License_Renewal_0]) {
            [[UIApplication sharedApplication] cancelLocalNotification:item];
        }
    }
    //交强险到期日
    for (UILocalNotification *item in localNotifyArray) {
        if ([[[item userInfo] objectForKey:Compulsory_Insurance_Expire_KEY] isEqualToString:Compulsory_Insurance_Expire_90] ||
            [[[item userInfo] objectForKey:Compulsory_Insurance_Expire_KEY] isEqualToString:Compulsory_Insurance_Expire_60] ||
            [[[item userInfo] objectForKey:Compulsory_Insurance_Expire_KEY] isEqualToString:Compulsory_Insurance_Expire_30]) {
            [[UIApplication sharedApplication] cancelLocalNotification:item];
        }
    }
    //商业险到期日
    for (UILocalNotification *item in localNotifyArray) {
        if ([[[item userInfo] objectForKey:Business_Insurance_Expire_KEY] isEqualToString:Business_Insurance_Expire_90] ||
            [[[item userInfo] objectForKey:Business_Insurance_Expire_KEY] isEqualToString:Business_Insurance_Expire_60] ||
            [[[item userInfo] objectForKey:Business_Insurance_Expire_KEY] isEqualToString:Business_Insurance_Expire_30]) {
            [[UIApplication sharedApplication] cancelLocalNotification:item];
        }
    }
}

#pragma mark---设置车检通知
+ (void)settingCarDetectionNotify:(NSDate *)drivingLicenseDate //行驶证日期
{
//    NSDate * currentDate = [NSDate date];
//    //            //获取系统的时区
//    //        NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
//    //            //系统时间距离GMT time interval
//    //        NSInteger interval = [timeZone secondsFromGMTForDate:currentDate];
//    //        currentDate = [currentDate dateByAddingTimeInterval:interval];
//#ifdef kDevelopment
//    //为方便测试，目前通知时间按照设置行驶证时间后2分钟本地通知
//    drivingLicenseDate = [drivingLicenseDate dateByAddingTimeInterval:120];
//#else
//    NSString *drivingLicenseDateString = [[self getYmdDateFomatter] stringFromDate:drivingLicenseDate];
//    drivingLicenseDateString = [drivingLicenseDateString stringByAppendingString:@" 09:00:00"];
//    drivingLicenseDate = [[self getYmdHmsDateFomatter] dateFromString:drivingLicenseDateString];
//#endif
//    NSLog(@"当前日期:====%@= 选择的行驶证日期====%@=",currentDate,drivingLicenseDate);
//    NSDateComponents *adcomps = nil;
//    NSDateComponents *sixYearOffSetcomps = nil;
//    adcomps = [[self getCurrentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:drivingLicenseDate];//自动转换时区为系统时区 +8h
//    //    [adcomps setTimeZone:timeZone];
//    sixYearOffSetcomps= [[self getCurrentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:drivingLicenseDate];
//    [sixYearOffSetcomps setYear:6];
//    [sixYearOffSetcomps setDay:-29];
//    [sixYearOffSetcomps setMonth:0];
//    [sixYearOffSetcomps setHour:0];
//    [sixYearOffSetcomps setMinute:0];
//    [sixYearOffSetcomps setSecond:0];
//    NSDate *sixYear = [[self getCurrentCalendar] dateByAddingComponents:sixYearOffSetcomps toDate:drivingLicenseDate options:0];
//    NSComparisonResult compare6Yearbefore30 = [currentDate compare:sixYear];
//    if (compare6Yearbefore30 != NSOrderedDescending) {
//        //前6年每隔2年车检日提前发送通知
//        for (int i = 1; i < 4; i++) {
//            [adcomps setYear:i*2];
//            [adcomps setMonth:0];
//            //30天 当前时间>=车检30天需要添加通知，否则车检已经过去,不再添加
//            [adcomps setDay:-29];
//            [adcomps setHour:0];
//            [adcomps setMinute:0];
//            [adcomps setSecond:0];
//            NSDate *before30date = [[self getCurrentCalendar] dateByAddingComponents:adcomps toDate:drivingLicenseDate options:0];
//            NSString *before30dateStr = [[self getYmdDateFomatter] stringFromDate:before30date];
//            NSComparisonResult compare30 = [currentDate compare:before30date];
//            if (compare30 != NSOrderedDescending)
//            {
//
//                [self scheduleLocalNotificationTitle:@"车检提醒" subtitle:@"" body:[NSString stringWithFormat:@"亲爱的安吉星车主，您的车检将在30天后失效，请在%@前前往相关部门进行车检，安吉星将定期提醒您哦!",before30dateStr] dateComponents:[[self getCurrentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:before30date] date:before30date identifier:[NSString stringWithFormat:@"kVehicleDetection_Notification_%d_year_before30",i] repeates:NO repeatInterval:0];
//            }
//            //7天 当前时间>=车检7天需要添加通知，否则车检已经过去,不再添加
//            [adcomps setDay:-6];
//            NSDate *before7date = [[self getCurrentCalendar] dateByAddingComponents:adcomps toDate:drivingLicenseDate options:0];
//            NSString *before7dateStr = [[self getYmdDateFomatter] stringFromDate:before7date];
//            NSComparisonResult compare7 = [currentDate compare:before7date];
//            if (compare7 != NSOrderedDescending)
//            {
//                [self scheduleLocalNotificationTitle:@"车检提醒" subtitle:@"" body:[NSString stringWithFormat:@"亲爱的安吉星车主，您的车检将在7天后失效，请在%@前前往相关部门进行车检，安吉星将定期提醒您哦!",before7dateStr]  dateComponents:[[self getCurrentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:before7date] date:before7date identifier:[NSString stringWithFormat:@"kVehicleDetection_Notification_%d_year_before7",i] repeates:NO repeatInterval:0];
//            }
//
//            //3天 当前时间>=车检3天需要添加通知，否则车检已经过去,不再添加
//            [adcomps setDay:-2];
//            NSDate *before3date = [[self getCurrentCalendar] dateByAddingComponents:adcomps toDate:drivingLicenseDate options:0];
//            NSString *before3dateStr = [[self getYmdDateFomatter] stringFromDate:before3date];
//            NSComparisonResult compare3 = [currentDate compare:before3date];
//            if (compare3 != NSOrderedDescending)
//            {
//
//                [self scheduleLocalNotificationTitle:@"车检提醒" subtitle:@"" body:[NSString stringWithFormat:@"亲爱的安吉星车主，您的车检将在3天后失效，请在%@前前往相关部门进行车检，安吉星将定期提醒您哦!",before3dateStr] dateComponents:[[self getCurrentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:before3date] date:before3date identifier:[NSString stringWithFormat:@"kVehicleDetection_Notification_%d_year_before3",i] repeates:NO repeatInterval:0];
//
//            }
//            NSLog(@"---前6年内将要进行车检日期=3:%@(7:%@,30:%@)",before3dateStr,before7dateStr,before30dateStr);
//        }
//    }
//    //超过6年，车检日前30天 当前时间>=车检30天需要添加通知，否则车检已经过去,不再添加
//    [adcomps setYear:6];
//    [adcomps setMonth:0];
//    [adcomps setDay:-29];
//
//    NSDate *before30date = [[self getCurrentCalendar] dateByAddingComponents:adcomps toDate:drivingLicenseDate options:0];
//    NSString *before30dateStr = [[self getYmdDateFomatter] stringFromDate:before30date];
//    NSComparisonResult compare30 = [currentDate compare:before30date];
//    if (compare30 != NSOrderedDescending)
//    {
//
//        [self scheduleLocalNotificationTitle:@"车检提醒"  subtitle:@""  body:[NSString stringWithFormat:@"亲爱的安吉星车主，您的车检将在30天后失效，请在%@前前往相关部门进行车检，安吉星将定期提醒您哦!",before30dateStr] dateComponents:[[self getCurrentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:before30date] date:before30date identifier:[NSString stringWithFormat:@"kVehicleDetection_Notification_before30"] repeates:YES repeatInterval:NSCalendarUnitYear];
//    }
//
//    //超过6年，车检日前7天 当前时间>=车检7天需要添加通知，否则车检已经过去,不再添加
//    [adcomps setDay:-6];
//    NSDate *before7date = [[self getCurrentCalendar] dateByAddingComponents:adcomps toDate:drivingLicenseDate options:0];
//    NSString *before7dateStr = [[self getYmdDateFomatter] stringFromDate:before7date];
//    NSComparisonResult compare7 = [currentDate compare:before7date];
//    if (compare7 != NSOrderedDescending)
//    {
//
//        [self scheduleLocalNotificationTitle:@"车检提醒"  subtitle:@"" body:[NSString stringWithFormat:@"亲爱的安吉星车主，您的车检将在7天后失效，请在%@前前往相关部门进行车检，安吉星将定期提醒您哦!",before7dateStr] dateComponents:[[self getCurrentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:before7date] date:before7date identifier:[NSString stringWithFormat:@"kVehicleDetection_Notification_before7"] repeates:YES repeatInterval:NSCalendarUnitYear];
//    }
//    //超过6年，车检日前3天 当前时间>=车检3天需要添加通知，否则车检已经过去,不再添加
//    [adcomps setDay:-2];
//    NSDate *before3date = [[self getCurrentCalendar] dateByAddingComponents:adcomps toDate:drivingLicenseDate options:0];
//    NSString *before3dateStr = [[self getYmdDateFomatter] stringFromDate:before3date];
//    NSComparisonResult compare3 = [currentDate compare:before3date];
//    if (compare3 != NSOrderedDescending)
//    {
//
//        [self scheduleLocalNotificationTitle:@"车检提醒" subtitle:@"" body:[NSString stringWithFormat:@"亲爱的安吉星车主，您的车检将在3天后失效，请在%@前前往相关部门进行车检，安吉星将定期提醒您哦!",before3dateStr] dateComponents:[[self getCurrentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:before3date] date:before3date identifier:[NSString stringWithFormat:@"kVehicleDetection_Notification_before3"] repeates:YES repeatInterval:NSCalendarUnitYear];
//        NSLog(@"---超过6年将要进行车检日期=%@(%@,%@)",before3dateStr,before30dateStr,before7dateStr);
//    }
}
//取消车检日通知
+ (void)cancelCarDetectionNotification
{
    if ([[UIDevice currentDevice].systemVersion floatValue] < 10.0)
    {
        NSArray *localNotifyArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
        for (UILocalNotification *item in localNotifyArray) {
            if ( [[item userInfo] objectForKey:CarDetection_Notify_KEY] != nil) {
                [[UIApplication sharedApplication] cancelLocalNotification:item];
            }
        }
    }
    else
    {
        
        NSArray * idenArr = [NSArray arrayWithObjects:kVehicleDetection_Notification_before3,kVehicleDetection_Notification_before7,kVehicleDetection_Notification_before30,kVehicleDetection_Notification_1_year_before3,kVehicleDetection_Notification_1_year_before7,kVehicleDetection_Notification_1_year_before30,kVehicleDetection_Notification_2_year_before3,kVehicleDetection_Notification_2_year_before7,kVehicleDetection_Notification_2_year_before30,kVehicleDetection_Notification_3_year_before3,kVehicleDetection_Notification_3_year_before7,kVehicleDetection_Notification_3_year_before30, nil];
        [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:idenArr];
    }
}

+ (void)scheduleLocalNotificationTitle:(NSString *)title subtitle:(NSString *)subtitle body:(NSString *)body dateComponents:(NSDateComponents *)dateCom date:(NSDate *)fireDate identifier:(NSString *)identify repeates:(BOOL)isRepeate repeatInterval:(NSCalendarUnit)repeatInterval
{
//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
//
//    if ([[UIDevice currentDevice].systemVersion floatValue] < 10.0)
//    {
//        //10.0之前使用UILocalNotification创建本地通知
//        UILocalNotification *notify = [[UILocalNotification alloc] init];
//        notify.fireDate = fireDate;
//        notify.timeZone = [NSTimeZone defaultTimeZone];
//        notify.repeatInterval = repeatInterval;
//        notify.soundName = UILocalNotificationDefaultSoundName;
//        notify.alertBody = body;
//        NSDictionary *identiferDic = @{@"aps" : @{@"alert":@{@"receiveType": @"13"}},
//                                       CarDetection_Notify_KEY:identify};
//        notify.userInfo = identiferDic;
//        [[UIApplication sharedApplication] scheduleLocalNotification:notify];
//    }
//    else
//    {
//        //10.0之后使用UNUserNotificationCenter发送本地通知
//        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
//        // 主标题
//        content.title =[NSString localizedUserNotificationStringForKey:title arguments:nil];
//        // 副标题
//        content.subtitle =[NSString localizedUserNotificationStringForKey:subtitle arguments:nil];
//        content.body =[NSString localizedUserNotificationStringForKey:body arguments:nil];
//        content.sound = [UNNotificationSound defaultSound];
//        // 设置触发时间
//
//        UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateCom repeats:isRepeate];
//        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identify content:content trigger:trigger];//identifier必须唯一!!
//        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
//
//        }];
//    }
//#else
//
//    UILocalNotification *notify = [[UILocalNotification alloc] init];
//    notify.fireDate = fireDate;
//    notify.timeZone = [NSTimeZone defaultTimeZone];
//    notify.repeatInterval = repeatInterval;
//    notify.soundName = UILocalNotificationDefaultSoundName;
//    notify.alertBody = body;
//    //设置userinfo
//    NSDictionary *identiferDic = @{@"aps" : @{@"alert":@{@"receiveType": @"13"}},
//                                   CarDetection_Notify_KEY:identify};
//    notify.userInfo = identiferDic;
//    [[UIApplication sharedApplication] scheduleLocalNotification:notify];
//#endif
}




@end
