//
//  SOSLBSDataTool.m
//  Onstar
//
//  Created by Coir on 23/10/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSLBSProtocolView.h"
#import "BaseSearchOBJ.h"
#import "SOSLBSHeader.h"

typedef void(^SuccessBlock)(SOSLBSPOI *lbsPOI);
static NSString * const soskDefaultVin       = @"LBS_DEFAULT_VIN_20180604";
static NSString * const soskDefaultAccountId = @"LBS_DEFUALT_ACC_20180604";

@interface SOSLBSDataTool ()  <GeoDelegate>  {
    
    
}

@property (nonatomic, strong) SOSLBSPOI *resultPOI;
@property (nonatomic, strong) BaseSearchOBJ *searchOBJ;
@property (nonatomic, copy) SuccessBlock success_block;

@end

@implementation SOSLBSDataTool

- (void)getLBSPOIWithLBSDadaInfo:(NNLBSDadaInfo *)lbsInfo Success:(void (^)(SOSLBSPOI *lbsPOI))success Failure:(SOSFailureBlock)failure  {
    [SOSLBSDataTool getDeviceLocationWithLBSTrackingID:lbsInfo.deviceid Success:^(NNLBSLocationPOI *lbsPOI) {
        __weak __typeof(self) weakSelf = self;
        if (lbsPOI.lat.length && lbsPOI.lng.length) {
            
            //转换 GPS 经纬度坐标为高德坐标系 经纬度坐标
            CLLocationCoordinate2D coor = AMapCoordinateConvert(CLLocationCoordinate2DMake(lbsPOI.lat.doubleValue, lbsPOI.lng.doubleValue), AMapCoordinateTypeGPS);
            lbsPOI.lat = @(coor.latitude).stringValue;
            lbsPOI.lng = @(coor.longitude).stringValue;
            
            weakSelf.resultPOI = [SOSLBSPOI new];
            weakSelf.resultPOI.longitude = lbsPOI.lng;
            weakSelf.resultPOI.latitude = lbsPOI.lat;
            weakSelf.resultPOI.LBSUpdateTime = lbsPOI.positionTime;
            weakSelf.resultPOI.LBSPowerState = lbsPOI.status;
            weakSelf.resultPOI.LBSDeviceName = lbsInfo.devicename;
            weakSelf.resultPOI.LBSIMEI = lbsInfo.deviceid;
            
            NSString *lbsStatus = [lbsPOI.status substringToIndex:1];
            if ([lbsStatus isEqualToString:@"0"]) {
                weakSelf.resultPOI.LBSState = @"未启用";
            }    else if ([lbsStatus isEqualToString:@"1"])    {
                weakSelf.resultPOI.LBSState = @"运动";
            }    else if ([lbsStatus isEqualToString:@"2"])    {
                weakSelf.resultPOI.LBSState = @"静止";
            }    else if ([lbsStatus isEqualToString:@"3"])    {
                weakSelf.resultPOI.LBSState = @"离线";
            }
            weakSelf.resultPOI.LBSIsOnline = (lbsStatus.intValue == 3 || lbsStatus.intValue == 0) ? @"0" : @"1";
            weakSelf.resultPOI.LBSStayTime = lbsPOI.stopMinute;
            weakSelf.resultPOI.LBSMapUpdateTime = [NSDate date];
            
            // 逆地理编码, 搜索 LBS 设备定位点
            if (!weakSelf.searchOBJ) {
                weakSelf.searchOBJ = [BaseSearchOBJ new];
                weakSelf.searchOBJ.geoDelegate = self;
            }
            
            [weakSelf.searchOBJ reGeoCodeSearchWithLocation:[AMapGeoPoint locationWithLatitude:coor.latitude longitude:coor.longitude]];
            weakSelf.success_block = success;
        }
    } Failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        NSString *errorString = responseStr;
        NSDictionary *responseDic = [responseStr mj_JSONObject];
        NSString *description = responseDic[@"description"];
        if (description.length)     errorString = description;
        if (failure)    failure(statusCode, errorString, error);
    }];
}

#pragma mark - ReGeoSearch Delegate
- (void)reverseGeocodingResults:(NSArray *)results  {
    __weak __typeof(self) weakSelf = self;
    if (results.count) {
        SOSLBSPOI *poi = results[0];
        [weakSelf.resultPOI mj_setKeyValues:[poi mj_keyValues]];
        weakSelf.resultPOI.sosPoiType = POI_TYPE_LBS;
        weakSelf.resultPOI.name = poi.name;//[NSString stringWithFormat:@"设备位置(%@)", poi.name];
        if (weakSelf.success_block)     weakSelf.success_block(weakSelf.resultPOI);
    }
}

/// 两次加盐Md5
+ (NSString *)md5withDoubleSalt:(NSString *)inputStr    {
    NSString *firstMd5Str = [Util md5:inputStr WithSalt:@"onstar"];
    return [Util md5:firstMd5Str WithSalt:@"onstar"];
}

/// 存储 md5 之后的密码
+ (void)savePassword:(NSString *)password WithDeviceID:(NSString *)deviceID     {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *vin = [self getCurrentVin];
    NSMutableDictionary *userDic = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:KSOSLBSPasswordKey]];
    if (!userDic)    userDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *vinDic = [NSMutableDictionary dictionaryWithDictionary:[userDic objectForKey:vin]];
    if (!vinDic)   vinDic = [NSMutableDictionary dictionary];
    
    vinDic[deviceID] = password;
    userDic[vin] = vinDic;
    [defaults setObject:userDic forKey:KSOSLBSPasswordKey];
    [defaults synchronize];
}

/// 获取存储的密码 (md5 之后的密码)
+ (NSString *)getSavedPasswordWithDeviceID:(NSString *)deviceID     {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *vin = [self getCurrentVin];
    NSDictionary *userDic = [defaults objectForKey:KSOSLBSPasswordKey];
    NSDictionary *vinDic = userDic[vin];
    NSString *rightPsss = vinDic[deviceID];
    return rightPsss;
}

/// 校验密码是否正确,密码为 md5 之前的 原生 String
+ (BOOL)checkPassword:(NSString *)password WithDeviceID:(NSString *)deviceID    {
    NSString *rightPsss = [SOSLBSDataTool getSavedPasswordWithDeviceID:deviceID];
    return [rightPsss isEqualToString:[SOSLBSDataTool md5withDoubleSalt:password]];
}

/// 存储 设备登录状态,用于判定设备是否需要输入密码
+ (void)saveDeviceLoginFlag:(BOOL)login WithDeviceID:(NSString *)deviceID     {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *vin = [self getCurrentVin];
    NSMutableDictionary *userDic = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:KSOSLBSLoginFlagKey]];
    if (!userDic)    userDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *vinDic = [NSMutableDictionary dictionaryWithDictionary:[userDic objectForKey:vin]];
    if (!vinDic)   vinDic = [NSMutableDictionary dictionary];
    
    vinDic[deviceID] = @(login);
    userDic[vin] = vinDic;
    [defaults setObject:userDic forKey:KSOSLBSLoginFlagKey];
    [defaults synchronize];
}

/// 获取 设备登录状态,用于判定设备是否需要输入密码
+ (NSNumber *)getSavedLoginFlagWithDeviceID:(NSString *)deviceID     {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *vin = [self getCurrentVin];
    NSDictionary *userDic = [defaults objectForKey:KSOSLBSLoginFlagKey];
    NSDictionary *vinDic = userDic[vin];
    NSNumber *flag = vinDic[deviceID];
    return flag;
}

+ (NSString *)getCurrentVin        {
    NSString * vin ;
    vin = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin;
    if (vin) {
        return vin;
    }else{
        return soskDefaultVin;
    }
}

+ (NSString *)getCurrentAccountId        {
    NSString * accountId ;
    accountId = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId;
    if (accountId) {
        return accountId;
    }else{
        return soskDefaultAccountId;
    }
}

/// 获取 LBS 协议状态,优先获取 UserDefaults 存储状态
+ (void)getUserProtocolSavedStatusSuccess:(void (^)(BOOL protocolStatus))success Failure:(SOSFailureBlock)failure    {
    SOSLBSProtocolSavedStatus status = [SOSLBSDataTool getSavedUserProtocolSavedStatus];
    switch (status) {
        case SOSLBSProtocolSavedStatus_Unknnow:    {
            //协议状态未知,请求协议状态
            [Util showHUD];
            [SOSLBSDataTool getLBSProtocolStatusSuccess:^(NSString *statusString) {
                [Util dismissHUD];
                NSString * agreeKey = [[NSString stringWithFormat:KSOSLBSProtocolKey] stringByAppendingString:[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
                if (statusString.intValue == 2) {
                    //用户已同意协议,保存状态
                    UserDefaults_Set_Object(@(YES), agreeKey);
                    if (success)    success(YES);
                }   else    {
                    //用户未同意协议,显示协议,保存状态
                    UserDefaults_Set_Object(@(NO), agreeKey);
                    if (success)    success(NO);
                }
            } Failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                [Util dismissHUD];
                [Util toastWithMessage:responseStr];
                if (failure)    failure(statusCode, responseStr, error);
            }];
            break;
        }
        case SOSLBSProtocolSavedStatus_Accepted:
            if (success)    success(YES);
            break;
        case SOSLBSProtocolSavedStatus_Rejected:
            if (success)    success(NO);
            break;
        default:
            break;
    }
}

/// 获取 LBS 协议状态,仅获取 UserDefaults 存储状态
+ (SOSLBSProtocolSavedStatus)getSavedUserProtocolSavedStatus    {
    NSString * agreeKey = [[NSString stringWithFormat:KSOSLBSProtocolKey] stringByAppendingString:[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
    NSNumber *LBSProtocolStatus = UserDefaults_Get_Object(agreeKey);
    if (LBSProtocolStatus) {
        if (LBSProtocolStatus.boolValue)    return SOSLBSProtocolSavedStatus_Accepted;
        else                                return SOSLBSProtocolSavedStatus_Rejected;
    }    else                                return SOSLBSProtocolSavedStatus_Unknnow;
}

/// 获取 LBS 协议状态,仅网络请求
+ (void)getLBSProtocolStatusSuccess:(void (^)(NSString *statusString))success Failure:(SOSFailureBlock)failure  {
    NSString * url ;
    
    url  = [NSString stringWithFormat:[BASE_URL stringByAppendingString:LBSGetProtocolStatueURL], [CustomerInfo sharedInstance].userBasicInfo.idpUserId];
    
    SOSNetworkOperation *operation = [[SOSNetworkOperation alloc] initWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *responseDic = [responseStr mj_JSONObject];
        if ([responseDic isKindOfClass:[NSArray class]]){
            responseDic = ((NSArray *)responseDic)[0];
        }
        if (responseDic.count) {
            NSString *description = responseDic[@"description"];
            NSString *statusString = responseDic[@"optStatus"];
            if (statusString.length && [responseDic[@"serviceName"] isEqualToString:@"LBS"]) {
                if (success) {
                    dispatch_async_on_main_queue(^{
                        success(statusString);
                    });
                }
            }   else    {
                if (failure) {
                    dispatch_async_on_main_queue(^{
                        failure(-1, description, nil);
                    });
                }
            }
        }else{
            success(@"1");
        }
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        NSString *errorString = responseStr;
        NSDictionary *responseDic = [responseStr mj_JSONObject];
        NSString *description = responseDic[@"description"];
        if (description.length)     errorString = description;
        if (failure) {
            dispatch_async_on_main_queue(^{
                failure(statusCode, errorString, error);
            });
        }
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];
}

/// 更新 LBS 协议状态
+ (void)setLBSProtocolStatusSuccess:(SOSSuccessBlock)success Failure:(SOSFailureBlock)failure    {
    NSString * url ;
    url = [BASE_URL stringByAppendingFormat:update_lbs_service_URL, [CustomerInfo sharedInstance].userBasicInfo.idpUserId];
    
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *responseDic = [responseStr mj_JSONObject];
        NSString *code = responseDic[@"code"];
        NSString *description = responseDic[@"description"];
        if ([code isEqualToString:@"E0000"]) {
            if (success)    success(operation, responseStr);
        }   else    {
            if (failure)    failure(-1, description, nil);
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        NSString *errorString = responseStr;
        NSDictionary *responseDic = [responseStr mj_JSONObject];
        NSString *description = responseDic[@"description"];
        if (description.length)     errorString = description;
        if (failure)    failure(statusCode, errorString, error);
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"PUT"];
    [operation start];
}

/// 添加/更新/删除 LBS 设备
+ (void)updateDeviceWithLBSDadaInfo:(NNLBSDadaInfo *)lbsInfo Success:(void (^)(NNLBSDadaInfo * lbsInfo, NSString *responseStr))success Failure:(SOSFailureBlock)failure   {
    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_URL, LBSAddDeviceURL];
    SOSNetworkOperation *operation = [[SOSNetworkOperation alloc] initWithURL:url params:[lbsInfo mj_JSONString] successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *responseDic = [responseStr mj_JSONObject];
        
        NSString *code = responseDic[@"code"];
        NSString *description = responseDic[@"description"];
        NSDictionary *lbsDataDic = responseDic[@"lbsDevice"];
        if ([code isEqualToString:@"E0000"]) {
            NNLBSDadaInfo *tempDataInfo = [NNLBSDadaInfo mj_objectWithKeyValues:lbsDataDic];
            [self savePassword:tempDataInfo.password WithDeviceID:tempDataInfo.deviceid];
            success(tempDataInfo, description);
        }   else    {
            if (failure)    failure(0, description, nil);
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        NSString *errorString = responseStr;
        NSDictionary *responseDic = [responseStr mj_JSONObject];
        NSString *description = responseDic[@"description"];
        if (description.length)     errorString = description;
        if (failure)    failure(statusCode, errorString, error);
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"POST"];
    [operation start];
}

/// 登录 LBS 设备
+ (void)loginWithDeviceID:(NSString *)deviceID AndPassword:(NSString *)passWord Success:(void (^)(NSDictionary *resultFlagDic))success Failure:(SOSFailureBlock)failure   {
    //绑定设备后卸载应用再次安装点击实时定位
    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_URL, LBSLoginDeviceURL];
    
    NSDictionary *pamramsDic = @{@"deviceid": deviceID, @"password": passWord};
    SOSNetworkOperation *operation = [[SOSNetworkOperation alloc] initWithURL:url params:[pamramsDic toJson] successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *responseDic = [responseStr mj_JSONObject];
        if ([responseDic isKindOfClass:[NSDictionary class]]) {
            NSString *code = responseDic[@"code"];
            NSString *description = responseDic[@"description"];
            if ([code isEqualToString:@"E0000"]) {
                NSDictionary *resultDic = responseDic[@"verificationResult"];
                if (success)     success(resultDic);
            }   else    {
                if (failure)    failure(-1, description, nil);
            }
        }   else    {
            if (failure)    failure(-1, @"未知错误", nil);
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        NSString *errorString = responseStr;
        NSDictionary *responseDic = [responseStr mj_JSONObject];
        NSString *description = responseDic[@"description"];
        if (description.length)     errorString = description;
        if (failure)    failure(statusCode, errorString, error);
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"POST"];
    [operation start];
}

///获取当前用户的 LBS 设备列表
+ (void)getUserLBSListSuccess:(void (^)(NSString *description, NSArray *resultArray))success Failure:(SOSFailureBlock)failure   {
    NSString *url = [BASE_URL stringByAppendingString:LBSGetDeviceListURL];
    SOSNetworkOperation *operation = [[SOSNetworkOperation alloc] initWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *responseDic = [responseStr mj_JSONObject];
        
        NSString *code = responseDic[@"code"];
        NSString *description = responseDic[@"description"];
        NSArray *lbsListArray = responseDic[@"lbsDevices"];
        if ([code isEqualToString:@"E0000"]) {
            NSMutableArray *tempArray = [NSMutableArray array];
            for (NSDictionary *tempDic in lbsListArray) {
                NNLBSDadaInfo *tempDataInfo = [NNLBSDadaInfo mj_objectWithKeyValues:tempDic];
                [self savePassword:tempDataInfo.password WithDeviceID:tempDataInfo.deviceid];
                [tempArray addObject:tempDataInfo];
            }
            if (success)    success(description, tempArray);
        }   else if ([code isEqualToString:@"E2002"])   {
            NSMutableArray *tempArray = [NSMutableArray array];
            if (success)    success(description, tempArray);
        }    else    {
            if (failure)    failure(0, description, nil);
            return;
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        NSString *errorString = responseStr;
        NSDictionary *responseDic = [responseStr mj_JSONObject];
        NSString *description = responseDic[@"description"];
        if (description.length)     errorString = description;
        if (failure)    failure(statusCode, errorString, error);
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];
}

///获取 LBS 设备当前定位
+ (void)getDeviceLocationWithLBSTrackingID:(NSString *)deviceID Success:(void (^)(NNLBSLocationPOI *lbsPOI))success Failure:(SOSFailureBlock)failure   {
    
    NSString *url = [NSString stringWithFormat:[BASE_URL stringByAppendingString:LBSGetLocationURL], deviceID];
    //    NSDictionary *d = @{@"id":deviceID,@"mapType":@"amap"};
    //    NSString *s = [Util jsonFromDict:d];
    
    SOSNetworkOperation *operation = [[SOSNetworkOperation alloc] initWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *resDic = [responseStr mj_JSONObject];
        if ([resDic isKindOfClass:[NSDictionary class]] && resDic.count>1) {
            NNLBSLocationPOI *lbsLocation = [NNLBSLocationPOI mj_objectWithKeyValues:resDic];
            if (success)     success(lbsLocation);
            return ;
        }
        if (failure)    failure(0, responseStr, nil);
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        NSString *errorString = responseStr;
        NSDictionary *responseDic = [responseStr mj_JSONObject];
        NSString *description = responseDic[@"description"];
        if (description.length)     errorString = description;
        if (failure)    failure(statusCode, errorString, error);
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];
}

///获取 LBS 设备历史定位 (轨迹)     startTime/endTime 格式 yyyy-MM-dd HH:mm:ss
+ (void)getHistoryDeviceLocationWithLBSTrackingID:(NSString *)deviceID StartTime:(NSString *)startTime AndEndTime:(NSString *)endTime Success:(void (^)(NSArray <NNLBSLocationPOI *> * deviceLocationArray))success Failure:(SOSFailureBlock)failure   {
    NSString *url = [NSString stringWithFormat:[BASE_URL stringByAppendingString:LBSGetHistoryLocationURL], deviceID, startTime, endTime];
    url = [url stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    SOSNetworkOperation *operation = [[SOSNetworkOperation alloc] initWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *resDic = [responseStr mj_JSONObject];
        NSArray *devices = resDic[@"devices"];
        NSMutableArray <NNLBSLocationPOI *>*deviceArray = [NSMutableArray array];
        if (devices.count) {
            for (NSDictionary *dic in devices) {
                NNLBSLocationPOI *lbsPOI = [NNLBSLocationPOI mj_objectWithKeyValues:dic];
                [deviceArray addObject:lbsPOI];
            }
        }
        if (success)     success(deviceArray);
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        NSString *errorString = responseStr;
        NSDictionary *responseDic = [responseStr mj_JSONObject];
        NSString *description = responseDic[@"description"];
        errorString = description.length ? description : @"暂无相应轨迹信息";
        if (failure)    failure(statusCode, errorString, error);
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];
}

/// 显示 LBS 协议
+ (void)showLBSProtocolViewWithCompleteHanlder:(void (^)(BOOL agreeStatus))completion        {
    SOSLBSProtocolView *protocolView = [SOSLBSProtocolView viewFromXib];
    protocolView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [protocolView setCompleteHanlder:^(BOOL agreeStatus) {
        if (completion)        completion(agreeStatus);
    }];
    [protocolView show:YES];
}

@end

