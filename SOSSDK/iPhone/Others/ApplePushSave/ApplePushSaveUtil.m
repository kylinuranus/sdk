//
//  ApplePushSaveUtil.m
//  Onstar
//
//  Created by Apple on 15-4-13.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import "ApplePushSaveUtil.h"
#import "OpenUDID.h"
#import "AppPreferences.h"
#import "CustomerInfo.h"
#import "SOSNetworkOperation.h"
#import "RequestDataObject.h"
#import "ResponseDataObject.h"
#ifndef SOSSDK_SDK
#import "JPUSHService.h"
#endif
@implementation ApplePushSaveUtil

+ (void)saveDeviceInfoWithIsBind:(NSString *)isBind userID:(NSString *)userID {
  
    [self saveDeviceInfoWithIsBind:isBind userID:userID channel:@"jpush"];
      
}

+ (void)saveDeviceInfoWithIsBind:(NSString *)isBind userID:(NSString *)userID channel:(NSString *)channel    {
    //保存设备信息到服务器
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //21:IOS IPHONE, 22:IOS IPAD
    NSString *deviceType = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)?@"21":@"22";
    NSString * deviceID = [OpenUDID value];
    
    NSString *url = [BASE_URL stringByAppendingString:NEW_SAVE_DEVICE_URL];
    NNSaveDeviceInfoRequest *req = [[NNSaveDeviceInfoRequest alloc] init];
    [req setDeviceID:deviceID];
    [req setDeviceOS:@"IOS"];
    [req setDeviceType:deviceType];
    [req setIsNotification:@"Y"];
    [req setIsAlert:@"Y"];
    [req setIsBind:isBind];
        // 极光
#ifndef SOSSDK_SDK
        NSString *deviceToken = [JPUSHService registrationID];
        [req setDeviceChannel:channel];
        [req setDeviceToken:deviceToken];
#endif
    NSString *postData = [req mj_JSONString];
    SOSNetworkOperation * sosOperation = [SOSNetworkOperation requestWithURL:url
                                 params:postData
                           successBlock:nil failureBlock:nil];
    [sosOperation setHttpMethod:@"PUT"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}

+ (void)saveSession     {
   
        [self saveSessionChannel:@"jpush"];
    
}

+ (void)saveSessionChannel:(NSString *)channel     {
    
    if ([[UIApplication sharedApplication]currentUserNotificationSettings].types == UIUserNotificationTypeNone) {
        [OthersUtil loadAppAllowNotify:@"off" successHandler:nil failureHandler:nil];
    }else{
        [OthersUtil loadAppAllowNotify:@"on" successHandler:nil failureHandler:nil];
    }
    
    NSString *url = [BASE_URL stringByAppendingString:NEW_SAVE_SESSION_URL];

    //21:IOS IPHONE, 22:IOS IPAD
    NSString *deviceType = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)?@"21":@"22";

    NNSaveSessionRequest *req = [[NNSaveSessionRequest alloc] init];
    [req setDeviceID:[OpenUDID value]];
    [req setSubscriberID:[CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId];
    [req setDeviceType:deviceType];
    [req setDeviceOS:@"IOS"];
    [req setUserName:[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
    [req setChannelID:@"1"];
    [req setEmail:@""];
    [req setMobileNumber:@""];
    [req setRole:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.role];
        //极光
#ifndef SOSSDK_SDK
    NSString *deviceToken = [JPUSHService registrationID];
    [req setDeviceChannel:channel];
    [req setDeviceToken:deviceToken];
//    [req setAppleDeviceToken:UserDefaults_Get_Object(kApplePushSaveDeviceToken)];
#endif
//    else {
//        //信鸽
//        NSString *deviceToken = [defaults objectForKey:kApplePushSaveDeviceToken];
//        [req setDeviceToken:deviceToken];
//    }
    
    
    VehicleInformation *vehicles = [[VehicleInformation alloc] init];
    [vehicles setVin:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    [vehicles setModel:[[CustomerInfo sharedInstance] currentVehicle].model];
    [vehicles setMake:[[CustomerInfo sharedInstance] currentVehicle].make];
    [vehicles setModelDesc: [[CustomerInfo sharedInstance] currentVehicle].modelDesc];
    [vehicles setMakeDesc:[[CustomerInfo sharedInstance] currentVehicle].makeDesc];
    [vehicles setYear:[[CustomerInfo sharedInstance] currentVehicle].year];
    
    NSMutableArray *vehicleArr = [NSMutableArray new];
    [vehicleArr  addObject:vehicles];
    [req setVehicles:vehicleArr];
    
    [req setUserID:[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
    
    NSString *postStr = [req mj_JSONString];
    
    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url
                                 params:postStr
                           successBlock:^(SOSNetworkOperation *operation, id returnData) {
                               
                              
                               
                           } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                               
                           }];
    
    [sosOperation setHttpMethod:@"PUT"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}


@end
