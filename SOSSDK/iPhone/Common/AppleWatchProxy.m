//
//  AppleWatchProxy.m
//  Onstar
//
//  Created by Joshua on 15/6/3.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import "AppleWatchProxy.h"
#import "CustomerInfo.h"
#import "SOSCheckRoleUtil.h"
#import "AppPreferences.h"
 
#import "Util.h"
#import "ServiceController.h"
#import "AppDelegate_iPhone.h"
#import "HandleDataRefreshDataUtil.h"

#import "SOSRemoteTool.h"
#import <WatchConnectivity/WatchConnectivity.h>
#import "SOSGreetingManager.h"
#import "SOSVehicleInfoUtil.h"
#import <UserNotifications/UserNotifications.h>

@interface AppleWatchProxy ()
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (nonatomic, strong) NSTimer *myTimer;

@end

//#import "SOSServiceForWatch.h"
@implementation AppleWatchProxy     {
    NSMutableDictionary * resultDic;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOS_VEHICLE_OPERATE_NOTIFICATION object:nil] subscribeNext:^(NSNotification *noti) {
            NSDictionary *notiDic = noti.userInfo;
            RemoteControlStatus resultState = [notiDic[@"state"] intValue];
//            SOSRemoteOperationType operationType = [notiDic[@"OperationType"] intValue];
            
            
            if (WCSession.isSupported && WCSession.defaultSession.isWatchAppInstalled) {
                NSError *err = nil;
                [WCSession.defaultSession updateApplicationContext:notiDic error:&err];
                if (err) {
                    NSLog(@"给手表传输内容出错:%@", err)
                }else {
                    if (resultState != RemoteControlStatus_OperateSuccess) {
                        return;
                    }
                    [Util fireLocalNotification:nil body:@"车辆远程操作成功!" identifier:@"localNoti"];
                }
            }

            [self endBackgroundTask];
        }];
        
//        [RACObserve([LoginManage sharedInstance], loginState) subscribeNext:^(NSNumber *x) {
//            if (x.integerValue == LOGIN_STATE_NON) {
//                if (WCSession.isSupported && WCSession.defaultSession.isWatchAppInstalled) {
//                    NSError *err = nil;
//                    NSDictionary *dic = @{APPLE_WATCH_RESULT_STATUS: @(AppleWatchOperationLoginNone)};
//                    [WCSession.defaultSession updateApplicationContext:dic error:&err];
//                    if (err) {
//                        NSLog(@"给手表传输内容出错:%@", err)
//                    }
//                }
//            }
//        }];

    }
    return self;
}

- (NSDictionary *)handleAppleWatchRequest:(NSDictionary *)userInfo callBack:(void (^)(NSDictionary *))reply     {
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    switch ([[userInfo objectForKey:APPLE_WATCH_OPERATION_KEY] integerValue]) {
        case AppleWatchOperationWakeUpParent: // 唤醒parent app
        {
            resultDict[APPLE_WATCH_RESULT_STATUS] = @(AppleWatchOperationResultSuccess);
        }
            break;
        case AppleWatchOperationLogin: //手表登录命令
        {
            AppleWatchOperationResultStatus resultStatus;
//            resultStatus = [AppleWatchProxy handleLoginRequest];
            resultStatus = [AppleWatchProxy handleLoginRequestWithtimeout:[userInfo objectForKey:@"isTimeOut"]];
            resultDict[APPLE_WATCH_RESULT_STATUS] = @(resultStatus);
            if (resultStatus == AppleWatchOperationLoginSuccess) {
                resultDict[@"userInfo"] = [CustomerInfo.sharedInstance mj_keyValuesWithIgnoredKeys:@[@"footPrintDic"]].toJson;
                SOSGreetingModel *model = [SOSGreetingManager.shareInstance getGreetingModelWithType:SOSGreetingTypeVehicleCondition];
                resultDict[@"condition"] = model.condition;
            }
        }
            break;
        case AppleWatchOperationCheckLoginStatus:
        {
            AppleWatchOperationResultStatus resultStatus = AppleWatchOperationLoginNone;
            if ([[LoginManage sharedInstance] isLoadingMainInterfaceReady]) {
                resultStatus = AppleWatchOperationLoginSuccess;
            }else if ([LoginManage.sharedInstance isInLoadingMainInterface]) {
                resultStatus = AppleWatchOperationLoginInProgress;
            }else if ([LoginManage.sharedInstance isLoadingMainInterfaceFail]) {
                resultStatus = AppleWatchOperationLoginFail;
            }
            resultDict[APPLE_WATCH_RESULT_STATUS] = @(resultStatus);
            NSLog(@"========= Polling login status from apple watch, status [%@]", @(resultStatus));
        }
            break;
        case AppleWatchOperationCheckPin:
        {
            NSString * pinInput = [userInfo objectForKey:@"PinCode"];
            if (pinInput && pinInput.length > 0) {
                inputPinCode = pinInput;
            } else {
                inputPinCode = nil;
            }
            resultDict = [self checkPINWithOperation:[userInfo objectForKey:VEHICLE_OPERATION_KEY]];
        }
            break;
        case AppleWatchOperationRefreshData:
        {
            NSString * responseString = [userInfo objectForKey:@"Response"];
            NSString * needReturnData = [userInfo objectForKey:@"NeedReturnData"];
            
            //如果没有数据保存，保存数据跳过
            if (responseString && responseString.length) {
                [self setRefreshData:responseString];
            }
            //如果YES返回数据，NO不返回数据
            if (needReturnData && [needReturnData isEqualToString:@"YES"]) {
                resultDict = [self getRefreshData];
            }
        }
            break;
        case AppleWatchOperationCommon:
        {
            NSString * operation = [userInfo objectForKey:VEHICLE_OPERATION_KEY];
            resultDict = [NSMutableDictionary dictionaryWithDictionary: [self startOperation:operation callBack:reply]];
        }
            break;
        case AppleWatchOperationUpdateVehicleService:
        {
            [[ServiceController sharedInstance] updatePerformVehicleService];
        }
            break;

        case AppleWatchOperationCleanUpVehicleService:
        {
            [[ServiceController sharedInstance] cleanUpVehicleSevices];
        }
            break;

        case AppleWatchOperationReport:
        {
            NSString * functionid = [userInfo objectForKey:APPLE_WATCH_REPORT_FUNCTIONID];
//            NSString *content =[userInfo objectForKey:APPLE_WATCH_REPORT_CONTENT];
//            // report watch home page button click
////            ReportRecord * autoRefreshRecord = [[SOSReportService shareInstance]
////                                                createRecordWithFunctionID:functionid
////                                                StartTime:[NSDate date]
////                                                EndTime:[NSDate date]
////                                                Operation:REPORT_OPPERATION_ACCEPT
////                                                Content:content];
////            [[SOSReportService shareInstance] recordAction:autoRefreshRecord];
//            [[SOSReportService shareInstance] recordEventWithFunctionID:functionid type:TypeEnumToString(Interaction) objectType:TypeEnumToString(OtherContent) objectID:content operation:@"" result:TypeEnumToString(ResultSuccess) extra:nil];
//
//            // after successfuly login upload report
//            [[SOSReportService shareInstance] calculateReportNumber:NO];
            
            [SOSDaapManager sendActionInfo:functionid];
        }
            break;
            
        case ApplewatchOperationAlertTime:{
            
            dispatch_queue_t serialQueue=dispatch_queue_create("alertTimeThreadQueue", DISPATCH_QUEUE_SERIAL);
            
              dispatch_async(serialQueue, ^{
                    NSLog(@"============patch 1");
                    [[ServiceController sharedInstance] getAlertTimeFromMSP];
                });
              dispatch_async(serialQueue, ^{
                NSLog(@"============patch 2");
                [resultDict setObject:NONil([ServiceController sharedInstance].duration) forKey:APPLE_WATCH_ALERT_TIME_KEY];
            });
            
        }
            
        //二期新增
        case AppleWatchOperationFire: {
            NSNumber *opeNum = userInfo[VEHICLE_OPERATION_KEY];
            if (opeNum.intValue == SOSRemoteOperationType_VehicleData) {
                if (WCSession.isSupported && WCSession.defaultSession.isWatchAppInstalled) {
                    [SOSVehicleInfoUtil requestVehicleInfoSuccess:^(id result) {

                        SOSGreetingModel *model = [SOSGreetingManager.shareInstance getGreetingModelWithType:SOSGreetingTypeVehicleCondition];
                        NSDictionary *response = @{@"state":@(RemoteControlStatus_OperateSuccess), @"OperationType" : opeNum, @"message": [CustomerInfo.sharedInstance mj_keyValuesWithIgnoredKeys:@[@"footPrintDic"]].toJson, @"condition": model.condition};
                        
                        NSError *err = nil;
                        [WCSession.defaultSession updateApplicationContext:response  error:&err];
//                        [WCSession.defaultSession sendMessage:response replyHandler:nil errorHandler:nil];
                        if (err) {
                            NSLog(@"给手表传输内容出错:%@", err)
                        }
                        [Util fireLocalNotification:nil body:@"车辆远程操作成功!" identifier:@"localNoti"];
                        [self endBackgroundTask];
                        
                    } Failure:^(id result) {
                        NSDictionary *response = @{@"state":@(RemoteControlStatus_OperateFail), @"OperationType" : opeNum, @"message": [CustomerInfo.sharedInstance mj_keyValuesWithIgnoredKeys:@[@"footPrintDic"]].toJson};
                        
                        NSError *err = nil;
//                        [WCSession.defaultSession sendMessage:response replyHandler:nil errorHandler:nil];
                        [WCSession.defaultSession updateApplicationContext:response  error:&err];
                        if (err) {
                            NSLog(@"给手表传输内容出错:%@", err)
                        }
                        [self endBackgroundTask];
                        
                    }];
                    __weak __typeof(self)weakSelf = self;
                    self.backgroundTaskIdentifier = [UIApplication.sharedApplication beginBackgroundTaskWithExpirationHandler:^{
                        [weakSelf endBackgroundTask];
                    }];
                    [self beginBackgroundTask];
                }

            }else {
                NSString *param = userInfo[VEHICLE_OPERATION_KEY_PARAM];
                if (param.length > 0) {
                    SOSRemoteTool.sharedInstance.parameter = param;
                }
                
                [SOSRemoteTool.sharedInstance startServiceWithOperationType:opeNum.intValue withResponse:NO];
                [self beginBackgroundTask];
            }
            
            
            //为了follow老代码逻辑，return一个无用的字典
            resultDict[APPLE_WATCH_RESULT_STATUS] = @"异步执行中...该部分交互暂时结束";
            
        }
        default:
            break;
    }
    
    return resultDict;
}

- (void)timerMethod:(NSTimer *)paramSender{
    
    // backgroundTimeRemaining 属性包含了程序留给的我们的时间
    NSTimeInterval backgroundTimeRemaining = UIApplication.sharedApplication.backgroundTimeRemaining;
    
    if (backgroundTimeRemaining == DBL_MAX){
        
        NSLog(@"Background Time Remaining = Undetermined");
        
    } else {
        
        NSLog(@"Background Time Remaining = %.02f Seconds", backgroundTimeRemaining);
        
    }
}

- (void)beginBackgroundTask {
    static NSUInteger times = 0;
    times++;
    dispatch_async_on_main_queue(^{
        __weak __typeof(self)weakSelf = self;
        self.myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                        target:self
                                                      selector:@selector(timerMethod:)
                                                      userInfo:nil
                                                       repeats:YES];
        self.backgroundTaskIdentifier = [UIApplication.sharedApplication beginBackgroundTaskWithExpirationHandler:^{
            [weakSelf endBackgroundTask];
            if (times < 2) {
                [weakSelf beginBackgroundTask];
            }
        }];
    });

}


- (void)endBackgroundTask{
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    AppDelegate_iPhone *weakDel = SOS_APP_DELEGATE;
    __weak __typeof(self)weakSelf = self;
    dispatch_async(mainQueue, ^(void) {
        AppDelegate_iPhone *strongAppDel = weakDel;
        if (strongAppDel != nil){
            [weakSelf.myTimer invalidate];
            NSLog(@"已结束后台任务");
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
            // 销毁后台任务标识符
            weakSelf.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        }
    });
}


- (void)setRefreshData:(NSString *) responseString     {
    NSDictionary *resultDict = [Util dictionaryWithJsonString:responseString];
    [HandleDataRefreshDataUtil setupVehicleStatusInfo:resultDict];
}

- (NSMutableDictionary *)getRefreshData     {
    /*
     @property (nonatomic, retain) NSString *fuelLevel;
     @property (nonatomic, retain) NSString *oilLife;
     @property (nonatomic, retain) NSString *odoMeter;
     @property (nonatomic, retain) NSString *lfTire;
     @property (nonatomic, retain) NSString *lrTire;
     @property (nonatomic, retain) NSString *rfTire;
     @property (nonatomic, retain) NSString *rrTire;
     */
    [CustomerInfo selectVehicleDataFromDB:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    
    NSMutableDictionary * mDic = [[NSMutableDictionary alloc] init];
    CustomerInfo * customer = [CustomerInfo sharedInstance];
    [mDic setValue:customer.fuelLavel  forKey:@"fuelLevel"];
    [mDic setValue:customer.oilLife  forKey:@"oilLife"];
    [mDic setValue:customer.oDoMeter  forKey:@"odoMeter"];
    [mDic setValue:customer.tirePressureLF   forKey:@"lfTire"];
    [mDic setValue:customer.tirePressureLR   forKey:@"lrTire"];
    [mDic setValue:customer.tirePressureRF   forKey:@"rfTire"];
    [mDic setValue:customer.tirePressureRR   forKey:@"rrTire"];
    [mDic setValue:customer.tirePressureLFStatus forKey:@"lfstatus"];
    [mDic setValue:customer.tirePressureLRStatus forKey:@"lrstatus"];
    [mDic setValue:customer.tirePressureRFStatus forKey:@"rfstatus"];
    [mDic setValue:customer.tirePressureRRStatus forKey:@"rrstatus"];
    
    NSString * tireSupport = customer.currentVehicle.tirePressureSupport?@"YES":@"NO";
    [mDic setValue:tireSupport forKey:@"tireSupport"];
    
    return mDic;
    
}
//检查Ping验证码是否需重新输入
- (NSMutableDictionary *)checkPINWithOperation:(NSNumber *)operation     {
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    
    // 第一步 检查是否登录
    AppleWatchOperationResultStatus loginStatus = [AppleWatchProxy handleLoginRequest];
    if (loginStatus == AppleWatchOperationLoginNone) {
        // 请在手机上登录
        [dic setObject:@(AppleWatchOperationLoginNone) forKey:APPLE_WATCH_RESULT_STATUS];
        return dic;
    } else if (loginStatus == AppleWatchOperationLoginInProgress) {
        // 正在登录的错误
        [dic setObject:@(AppleWatchOperationLoginInProgress) forKey:APPLE_WATCH_RESULT_STATUS];
        return dic;
    } else if (loginStatus == AppleWatchOperationLoginSuccess) {
        // 登录成功
    }
    
    // 第五步 检查有没有其它操作
    BOOL isUniqueOperation = [[ServiceController sharedInstance] canPerformVehicleService];
    if (!isUniqueOperation) {
        [dic setObject:@(AppleWatchOperationResultIsRunning) forKey:APPLE_WATCH_RESULT_STATUS];
        return dic;
    }
    
    

//    // 第二步 检查用户角色, data refresh不需要判断
//    if ([operation integerValue] != OperationRefreshData) {
//        BOOL isOwner = [AppleWatchProxy checkRole];
//        if (!isOwner) {
//            [dic setObject:@(AppleWatchRoleIsNotPermitted) forKey:APPLE_WATCH_RESULT_STATUS];
//            return dic;
//        }
//    }
    
    // 第三步 检查是否支持该Feature
//    BOOL isSupported = [AppleWatchProxy checkFeatureSupported:operation];
//    if (!isSupported) {
//        [dic setObject:@(AppleWatchVehicleOperationNotSupported) forKey:APPLE_WATCH_RESULT_STATUS];
//        return dic;
//    }
    
    // 第四步 检查是否过期
    if (operation.intValue != SOSRemoteOperationType_VehicleData) {
        AppleWatchOperationResultStatus resultStatus = [AppleWatchProxy checkFeatureAvailable:operation];
        if (resultStatus != AppleWatchPackageServiceAvailable) {
            [dic setObject:@(resultStatus) forKey:APPLE_WATCH_RESULT_STATUS];
            return dic;
        }

    }
    
    
    
    NSString * vin = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin;
//    NSString * sessionKey = [CustomerInfo sharedInstance].mig_appSessionKey;
    if (operation.intValue == SOSRemoteOperationType_VehicleData) {
        //数据刷新不需要输入PIN码
        [dic setObject:@(AppleWatchOperationCheckPinSuccess) forKey:APPLE_WATCH_RESULT_STATUS];
//        [dic setObject:@"PIN check success" forKey:@"errorInfo"];
//        [dic setObject:@"SUCCESS" forKey:@"status"];
//        [dic setObject:vin forKey:@"VIN"];
//        [dic setObject:[self getDataRefreshList] forKey:@"dataRefreshList"];//刷新数据
//        [dic setObject:BASE_URL forKey:@"IP"];
////        [dic setObject:[Util getMetaLanguage] forKey:@"Language"];
//        [dic setObject:[SOSLanguage getCurrentLanguage] forKey:@"Language"];
//        [dic setObject:[LoginManage sharedInstance].accessToken forKey:@"accessToken"];
//        [dic setObject:[LoginManage sharedInstance].tokenType forKey:@"tokenType"];
        
    } else if (![[LoginManage sharedInstance] needVerifyPin]) {
        // 不需要验证PIN
        [dic setObject:@(AppleWatchOperationCheckPinSuccess) forKey:APPLE_WATCH_RESULT_STATUS];
//        [dic setObject:@"PIN check success" forKey:@"errorInfo"];
//        [dic setObject:@"SUCCESS" forKey:@"status"];
//        [dic setObject:vin forKey:@"VIN"];
//        [dic setObject:[self getDataRefreshList] forKey:@"dataRefreshList"];//刷新数据
//        [dic setObject:BASE_URL forKey:@"IP"];
//        [dic setObject:[SOSLanguage getCurrentLanguage] forKey:@"Language"];
//
//        [dic setObject:[LoginManage sharedInstance].accessToken forKey:@"accessToken"];
//        [dic setObject:[LoginManage sharedInstance].tokenType forKey:@"tokenType"];
    }
    else if ([inputPinCode length] == 0) {
        // 需要验证PIN并且手表未输入PIN来验证
        [dic setObject:@(AppleWatchOperationCheckPinNone) forKey:APPLE_WATCH_RESULT_STATUS];
        [dic setObject: @"PIN no found !!!" forKey: @"errorInfo"];
        [dic setObject: @"FAIL" forKey:@"status"];
    }
    else
    {
        // 除dataRefresh外的实车操作，需要验证PIN 并且已经输入PIN
        PIN_CHECK_TYPE pingStatus;
        NSString * pingStatusStr = [[LoginManage sharedInstance] upgradeToken:inputPinCode];
        if ([pingStatusStr isEqualToString:@"0"] || [pingStatusStr isEqualToString:@"1"] || [pingStatusStr isEqualToString:@"2"]) {
            pingStatus = [[[LoginManage sharedInstance] upgradeToken:inputPinCode] intValue];
        }
        else{
            pingStatus = 3;
        }

        inputPinCode = nil;
        
        if (PIN_CHECK_FAILED == pingStatus || PIN_ERROR_OR_EMPTY == pingStatus) {
            [dic setObject:@(AppleWatchOperationCheckPinFail) forKey:APPLE_WATCH_RESULT_STATUS];
            [dic setObject:@"PIN check fail !!!" forKey:@"errorInfo"];
            [dic setObject: @"FAIL" forKey:@"status"];
        }
        else if (PIN_MORE_THAN_3 == pingStatus) {
            [dic setObject:@(AppleWatchOperationCheckPinExceedMax) forKey:APPLE_WATCH_RESULT_STATUS];
            [dic setObject:@"PIN check more than 3 ..." forKey:@"errorInfo"];
            [dic setObject: @"FAIL" forKey:@"status"];

        }
        else if(PIN_CHECK_SUCCESS == pingStatus)
        {
            // 如果pin验证成功
            [dic setObject:@(AppleWatchOperationCheckPinSuccess) forKey:APPLE_WATCH_RESULT_STATUS];
            [dic setObject:@"PIN check success" forKey:@"errorInfo"];
            [dic setObject:@"SUCCESS" forKey:@"status"];
            [dic setObject:vin forKey:@"VIN"];
            [dic setObject:[self getDataRefreshList] forKey:@"dataRefreshList"];//刷新数据
            [dic setObject:BASE_URL forKey:@"IP"];
            [dic setObject:[SOSLanguage getCurrentLanguage] forKey:@"Language"];

            [dic setObject:[LoginManage sharedInstance].accessToken forKey:@"accessToken"];
            [dic setObject:[LoginManage sharedInstance].tokenType forKey:@"tokenType"];
        }
        else if(PIN_LOGIN_INFO_EMPTY == pingStatus)
        {
            [dic setObject:@(ApplewatchNetworkError) forKey:APPLE_WATCH_RESULT_STATUS];
            [dic setObject:@"PIN login info empty !!!" forKey:@"errorInfo"];
            [dic setObject: @"FAIL" forKey:@"status"];
        }
        else if(NETWORK_ERROR == pingStatus)
        {
            [dic setObject:@(ApplewatchNetworkError) forKey:APPLE_WATCH_RESULT_STATUS];
            [dic setObject:@"network error" forKey:@"errorInfo"];
            [dic setObject: @"FAIL" forKey:@"status"];
        } else if (PIN_NEED_RELOGIN == pingStatus) {
            [dic setObject:@(AppleWatchOperationLoginTimeOut) forKey:APPLE_WATCH_RESULT_STATUS];
            [dic setObject:@"network error" forKey:@"errorInfo"];
            [dic setObject: @"FAIL" forKey:@"status"];
        }
    }
    return dic;
}
- (NSDictionary *) startOperation:(NSString *) operation callBack:(void (^)(NSDictionary *))reply     {
    resultDic = [[NSMutableDictionary  alloc] init];

    return resultDic;
}


- (NSMutableArray *)getDataRefreshList     {
      BOOL isEV = [Util vehicleIsEV];
    
      NSMutableArray *requestTypes = [[NSMutableArray alloc] init];
    
      if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.lastTripDistanceSupport)
          [requestTypes addObject:@"LAST TRIP DISTANCE"];
    
      if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.oilLifeSupport)
          [requestTypes addObject:@"OIL LIFE"];
    
      if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.odoMeterSupport)
          [requestTypes addObject:@"ODOMETER"];
    
      if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.fuelTankInfoSupport)
          [requestTypes addObject:@"FUEL TANK INFO"];
    
      if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vehicleRangeSupported)
          [requestTypes addObject:@"VEHICLE RANGE"];
    
      if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.lifetimeFuelEconSupport)
          [requestTypes addObject:@"LIFETIME FUEL ECON"];
    
      if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.lastTripFuelEconSupport)
          [requestTypes addObject:@"LAST TRIP FUEL ECONOMY"];
    
      if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.tirePressureSupport)
          [requestTypes addObject:@"TIRE PRESSURE"];
    
      if (isEV || [Util vehicleIsBEV])
      {
          [requestTypes addObject:@"EV BATTERY LEVEL"];
          
          [requestTypes addObject:@"EV CHARGE STATE"];
          
          [requestTypes addObject:@"EV PLUG STATE"];
          
          [requestTypes addObject:@"EV PLUG VOLTAGE"];
          
          [requestTypes addObject:@"EV SCHEDULED CHARGE START"];
          
          [requestTypes addObject:@"EV ESTIMATED CHARGE END"];
          
          [requestTypes addObject:@"GET CHARGE MODE"];
          
          [requestTypes addObject:@"GET COMMUTE SCHEDULE"];
      }
    
      return requestTypes;

}


+ (AppleWatchOperationResultStatus)handleLoginRequest     {
    AppleWatchOperationResultStatus resultStatus = AppleWatchOperationLoginNone;
    if ([[LoginManage sharedInstance] isLoadingMainInterfaceReady]) {
        // 已登录，返回成功
        resultStatus = AppleWatchOperationLoginSuccess;
        
    } else if ([LoginManage sharedInstance].loginState == LOGIN_STATE_LOADINGTOKEN) {
        // 正在登录
        resultStatus = AppleWatchOperationLoginInProgress;
        
    } else {
        // 未登录
        resultStatus = AppleWatchOperationLoginNone;
    }
    return resultStatus;
}


+ (AppleWatchOperationResultStatus)handleLoginRequestWithtimeout:(id)isTimeOut{
    AppleWatchOperationResultStatus resultStatus = AppleWatchOperationLoginNone;
    if (isTimeOut) {
        resultStatus = AppleWatchOperationLoginNone;
        return resultStatus;
    }
    if ([[LoginManage sharedInstance] isLoadingMainInterfaceReady]) {
        // 已登录，返回成功
        resultStatus = AppleWatchOperationLoginSuccess;
        
    } else if ([[LoginManage sharedInstance] isInLoadingMainInterface]) {
        // 正在登录
        resultStatus = AppleWatchOperationLoginInProgress;
    } else {
        // 未登录
        resultStatus = AppleWatchOperationLoginNone;
    }
    return resultStatus;
}

+ (BOOL)checkFeatureSupported:(NSNumber *)operation     {
    BOOL isSupported = YES;
    switch ([operation integerValue]) {
        case OperationLockDoor:
            isSupported = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.lockDoorSupported;
            break;
        case OperationUnlockDoor:
            isSupported = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.unlockDoorSupported;
            break;
        case OperationStartEngine:
            isSupported = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.remoteStartSupported;
            break;
        case OperationHornLight:
        case OperationHorn:
        case OperationLight:
            isSupported = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vehicleAlertSupported;
            break;
        default:
            break;
    }
    return isSupported;
}

//+ (BOOL)checkRole     {
//    // 车主才能操作
//    return [[[CustomerInfo sharedInstance].userBasicInfo.currentSuite.role lowercaseString] isEqualToString:ROLE_OWNER];
//}

+ (AppleWatchOperationResultStatus)checkFeatureAvailable:(NSNumber *)operation     {
    return [SOSRemoteTool watch_checkPackageWithType:operation.intValue];

}

@end
