//
//  SOSDaapManager.m
//  Onstar
//
//  Created by TaoLiang on 2018/2/5.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSDaapManager.h"
#import "OpenUDID.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "SOSTrackManagerUtil.h"
#import "NSString+Category.h"

@implementation SOSDaapManager

+ (void)sendClientInfo {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"EverRecordDeviceInfoToDAAP"]) {
        return;
    }
    NSMutableDictionary *dic = [SOSDaapManager getClientInfoBasicParam];

    NSString *url = [Util getmOnstarStaticConfigureURL:MA8_2_DAAP_CLIENT_INFO];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:[dic toJson] successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"EverRecordDeviceInfoToDAAP"];
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        
    }];
    operation.enableLog = NO;
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"POST"];
    [operation start];
}

+(NSString*) getTimeValue:(NSTimeInterval)value{
    
    NSString *valueStr =  [NSString stringWithFormat:@"%0.f", value];//获取整数位
    if(valueStr.length==13){ //整数位是13位,直接返回13位时间戳
        return valueStr;
    }else{//将10位整数转成13位时间戳
        return [SOSDaapManager convertTimeInterval:value];
    }
}

+ (void)sendActionInfo:(NSString *)triggerPointId {
    @try {
        
        if(![NSString isBlankString:triggerPointId]){
            
            
            [[SOSTrackManagerUtil sharedInstance] track:triggerPointId
                                          selfDefine:@{}
                                       isImmediately:false];
        }
        
    } @catch (NSException *exception) {
         
    } @finally {
         
    }
    
}
+ (void)sendActionInfo:(NSString *)triggerPointId responseSuccess:(void(^)(void))success_ responseFail:(void(^)(void))fail_ {
     
    @try {
        
        if(![NSString isBlankString:triggerPointId]){
            
 
            
            [[SOSTrackManagerUtil sharedInstance] track:triggerPointId
                                          selfDefine:@{}
                                       isImmediately:false];
            
            if (success_) {
                     success_();
              }
            
        }
        
    } @catch (NSException *exception) {
         
    } @finally {
         
    }
    
}

+ (void)sendSysBanner:(NSString *)bannerId funcId:(NSString *)funcId{
    [self sendSysBanner:bannerId type:@"banner" funcId:funcId];
}

+ (void)sendSysBanner:(NSString *)bannerId type:(NSString *)type funcId:(NSString *)funcId {
    
    @try {
        
        if(![NSString isBlankString:funcId]){
            
            NSMutableDictionary *selfDefine= [NSMutableDictionary new];
            [selfDefine setObject: ![NSString isBlankString:bannerId]?bannerId:@"" forKey:@"G109"];
            [selfDefine setObject: ![NSString isBlankString:type]?type:@"" forKey:@"G110"];
            [selfDefine setObject: funcId forKey:@"triggerPointId"];

            
            [[SOSTrackManagerUtil sharedInstance] track:funcId
                                          selfDefine:selfDefine
                                       isImmediately:false];
            
        }
        
    } @catch (NSException *exception) {
         
    } @finally {
         
    }
}

+ (void)sendSysLayout:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime funcId:(NSString *)funcId{
    
    
    @try {
        
        if(![NSString isBlankString:funcId]){
            
            if (startTime > endTime) {
                NSLog(@"daap时长不对");
                return;
            }
            
            NSMutableDictionary *selfDefine= [NSMutableDictionary new];
            [selfDefine setObject:![NSString isBlankString:[SOSDaapManager getTimeValue:startTime]]?[SOSDaapManager getTimeValue:startTime]:@""     forKey:@"G101"];
            [selfDefine setObject:![NSString isBlankString:[SOSDaapManager getTimeValue:endTime]]?[SOSDaapManager getTimeValue:endTime]:@""  forKey:@"G102"];
            [selfDefine setObject: funcId forKey:@"triggerPointId"];
            
          
            
            [[SOSTrackManagerUtil sharedInstance] track:funcId
                                          selfDefine:selfDefine
                                       isImmediately:false];
        }
        
    } @catch (NSException *exception) {
         
    } @finally {
         
    }


}
+ (void)sendSysLayout:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime loadStatus:(BOOL)status funcId:(NSString *)funcId{
   
    @try {
        
        if(![NSString isBlankString:funcId]){
            
            if (startTime > endTime) {
                NSLog(@"daap时长不对");
                return;
            }
            
          
            NSMutableDictionary *selfDefine= [NSMutableDictionary new];
            [selfDefine setObject:![NSString isBlankString:[SOSDaapManager getTimeValue:startTime]]?[SOSDaapManager getTimeValue:startTime]:@""     forKey:@"G101"];
            [selfDefine setObject:![NSString isBlankString:[SOSDaapManager getTimeValue:endTime]]?[SOSDaapManager getTimeValue:endTime]:@""  forKey:@"G102"];
            [selfDefine setObject: funcId forKey:@"triggerPointId"];
            [selfDefine setObject:@(status) forKey:@"G104"];
            
 
            [[SOSTrackManagerUtil sharedInstance] track:funcId
                                          selfDefine:selfDefine
                                       isImmediately:false];
        }
        
    } @catch (NSException *exception) {
         
    } @finally {
         
    }
    
   
}
+ (void)sendSysLayout:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime interfaceStatusCode:(NSString *)code funcId:(NSString *)funcId{
 
    
    
    @try {
        
        if(![NSString isBlankString:funcId]){
            
            
            if (startTime > endTime) {
                NSLog(@"daap时长不对");
                return;
            }
     
            
            NSMutableDictionary *selfDefine= [NSMutableDictionary new];
            [selfDefine setObject:![NSString isBlankString:[SOSDaapManager getTimeValue:startTime]]?[SOSDaapManager getTimeValue:startTime]:@""     forKey:@"G101"];
            [selfDefine setObject:![NSString isBlankString:[SOSDaapManager getTimeValue:endTime]]?[SOSDaapManager getTimeValue:endTime]:@""  forKey:@"G102"];
            [selfDefine setObject: funcId forKey:@"triggerPointId"];
            [selfDefine setObject:![NSString isBlankString:code]?code:@"" forKey:@"G105"];
            
            
            [[SOSTrackManagerUtil sharedInstance] track:funcId
                                          selfDefine:selfDefine
                                       isImmediately:false];
            
        }
        
    } @catch (NSException *exception) {
         
    } @finally {
         
    }
   
}

+ (void)sendSysLayout:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime maxUploadTime:(NSTimeInterval)interv loadStatus:(BOOL)status funcId:(NSString *)funcId{
    
    @try {
        
        if(![NSString isBlankString:funcId]){
            
            
            if (startTime > endTime) {
                NSLog(@"daap时长不对");
                return;
            }

            NSMutableDictionary *selfDefine= [NSMutableDictionary new];
            [selfDefine setObject:![NSString isBlankString:[SOSDaapManager getTimeValue:startTime]]?[SOSDaapManager getTimeValue:startTime]:@""     forKey:@"G101"];
            [selfDefine setObject:![NSString isBlankString:[SOSDaapManager getTimeValue:endTime]]?[SOSDaapManager getTimeValue:endTime]:@""  forKey:@"G102"];
            [selfDefine setObject: funcId forKey:@"triggerPointId"];
            [selfDefine setObject:@(status) forKey:@"G104"];
            
    
            
            [[SOSTrackManagerUtil sharedInstance] track:funcId
                                          selfDefine:selfDefine
                                       isImmediately:false];
            
        }
        
    } @catch (NSException *exception) {
         
    } @finally {
         
    }
}
+ (NSString *)getUUID {
    NSString *kSOSDaapManagerUUIDKey = @"kSOSDaapManagerUUIDKey";
    NSString *uuid = [[NSUserDefaults standardUserDefaults] valueForKey:kSOSDaapManagerUUIDKey];
    if (uuid.length <= 0) {
        uuid = [NSUUID UUID].UUIDString;
        [[NSUserDefaults standardUserDefaults] setValue:uuid forKey:kSOSDaapManagerUUIDKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return uuid;
}

+ (NSMutableDictionary *)getClientInfoBasicParam {
    NSMutableDictionary *basicDic = @{}.mutableCopy;
    basicDic[@"type"] = @"sendClientInfo";
    basicDic[@"clientId"] = [SOSDaapManager getUUID];
    basicDic[@"channel"] = @"client";
    basicDic[@"lon"] = NONil(((SOSPOI *)[[CustomerInfo sharedInstance] currentPositionPoi]).longitude);
    basicDic[@"lat"] = NONil(((SOSPOI *)[[CustomerInfo sharedInstance] currentPositionPoi]).latitude);
    basicDic[@"ipAddress"] = [Util getPublicIP] ? : @"0.0.0.0";
//    basicDic[@"address"] = [Util getMACAddress];
    basicDic[@"appVersion"] = APP_VERSION;
    basicDic[@"timestamp"] = [SOSDaapManager convertTimeInterval:[NSDate date].timeIntervalSince1970];
    basicDic[@"platform"] = @"iOS";
    basicDic[@"device"] = [Util getDevicePlatform];
    basicDic[@"deviceType"] = ISIPAD ? @"iPad" : @"iPhone";
    basicDic[@"carrieroperator"] = [SOSDaapManager getCarrierName];
    basicDic[@"OS"] = [UIDevice currentDevice].systemName;
    
    
    basicDic[@"OSVersion"] = [UIDevice currentDevice].systemVersion;
    basicDic[@"resolution"] = [SOSDaapManager getScrrenResolution];
    basicDic[@"cpuNum"] = [NSString stringWithFormat:@"%@", @([NSProcessInfo processInfo].activeProcessorCount)];
    basicDic[@"diskTotal"] = [SOSDaapManager getTotalDiskSpace];
    basicDic[@"memoryTotal"] = [SOSDaapManager getTotalMemory];
    basicDic[@"root"] = @([SOSDaapManager isJailBreak]);
    return basicDic;
}

+ (NSMutableDictionary *)getActionInfoParam:(NSString *)triggerPointId {
    NSMutableDictionary *basicDic = @{}.mutableCopy;
    basicDic[@"type"] = @"sendAction";
    NSDictionary *clientDic = @{
                                @"clientId": [SOSDaapManager getUUID],
                                @"channel": @"client",
                                @"ipAddress": [Util getPublicIP] ? : @"0.0.0.0",
                                @"lon": NONil(((SOSPOI *)[[CustomerInfo sharedInstance] currentPositionPoi]).longitude),
                                @"lat": NONil(((SOSPOI *)[[CustomerInfo sharedInstance] currentPositionPoi]).latitude),
                                @"clientVersion":[Util getAppVersionCode],
                                @"clientModel": [Util getDevicePlatform]
                                };
    basicDic[@"client"] = clientDic;
    NSDictionary *userDic = @{
                           @"idpUserId": NONil([CustomerInfo sharedInstance].userBasicInfo.idpUserId),
                           @"subscriberID": NONil([CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId),
                           @"accountID": NONil([CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId),
                           @"role": NONil([CustomerInfo sharedInstance].userBasicInfo.currentSuite.role),
                           @"VIN": NONil([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin),
                           };
    basicDic[@"user"] = userDic;
    NSDictionary *functionDic = @{
                               @"funcID": NONil(triggerPointId),
                               @"timestamp": [SOSDaapManager convertTimeInterval:[NSDate date].timeIntervalSince1970]
                               };
    basicDic[@"function"] = functionDic;
    return basicDic;
}

+ (NSMutableDictionary *)getSysBasicParam {
    NSMutableDictionary *basicDic = @{}.mutableCopy;
    basicDic[@"type"] = @"sendSys";
    NSDictionary *clientDic = @{
                                @"clientId": [SOSDaapManager getUUID],
                                @"channel": @"client",
                                @"ipAddress": [Util getPublicIP] ? : @"0.0.0.0",
                                @"lon": NONil(((SOSPOI *)[[CustomerInfo sharedInstance] currentPositionPoi]).longitude),
                                @"lat": NONil(((SOSPOI *)[[CustomerInfo sharedInstance] currentPositionPoi]).latitude),
                                @"clientVersion":[Util getAppVersionCode],
                                @"clientModel": [Util getDevicePlatform]
                                };
    basicDic[@"client"] = clientDic;
    NSDictionary *userDic = @{
                              @"idpUserId": NONil([CustomerInfo sharedInstance].userBasicInfo.idpUserId),
                              @"subscriberID": NONil([CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId),
                              @"accountID": NONil([CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId),
                              @"role": NONil([CustomerInfo sharedInstance].userBasicInfo.currentSuite.role),
                              @"VIN": NONil([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin),
                              };
    basicDic[@"user"] = userDic;

    return basicDic;
}


+ (NSString *)getScrrenResolution {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat screenX = SCREEN_WIDTH * scale;
    CGFloat screenY = SCREEN_HEIGHT * scale;
    NSString *resolution = [NSString stringWithFormat:@"%@*%@", @(screenX), @(screenY)];
    return resolution;
}

+ (NSString *)getTotalDiskSpace {
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) return @"";
    int64_t space =  [[attrs objectForKey:NSFileSystemSize] longLongValue];
    if (space < 0) space = -1;
    //    return space;
    NSString *totalDiskInfo = [NSString stringWithFormat:@"%.2f GB", space/1000/1000/1000.0];
    return totalDiskInfo;
    
}

+ (NSString *)getTotalMemory {
    int64_t totalMemory = [[NSProcessInfo processInfo] physicalMemory];
    if (totalMemory < -1) totalMemory = -1;
    NSString *totalMemoryInfo = [NSString stringWithFormat:@" %.2f GB", totalMemory/1000/1000/1000.0];
    return totalMemoryInfo;
}

+ (NSString *)getCarrierName {
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = networkInfo.subscriberCellularProvider;
    NSString *carrierName = @"";    //网络运营商的名字
    NSString *code = carrier.mobileNetworkCode;
    if ([code isEqualToString:@"00"] || [code isEqualToString:@"02"] || [code isEqualToString:@"07"]) {

        carrierName = @"中国移动";
        
    }else if ([code isEqualToString:@"03"] || [code isEqualToString:@"05"]) {
        
        carrierName =  @"中国电信";
        
    }else if ([code isEqualToString:@"01"] || [code isEqualToString:@"06"]) {
        
        carrierName =  @"中国联通";
        
    }
    return carrierName;
}

+ (BOOL)isJailBreak {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]]) {
        return YES;
    }
    return NO;
}

+ (NSString *)convertTimeInterval:(NSTimeInterval)timeInterval {
    return [NSString stringWithFormat:@"%@", @((long long)(timeInterval * 1000))];
}
                             
                             
                             
                             
                             
                             


@end

