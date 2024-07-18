;
//
//  SOSVehicleInfoUtil.m
//  Onstar
//
//  Created by onstar on 2017/10/16.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSVehicleData.h"
#import "ServiceController.h"
#import "SOSVehicleInfoUtil.h"
#import "SOSGreetingManager.h"
#import "SOSDateFormatter.h"
//#import "PlatformRouterImp.h"

@interface SOSVehicleInfoUtil ()

@end

@implementation SOSVehicleInfoUtil

#pragma mark 数据请求

//请求车况
+ (void)requestVehicleInfo {
    [self requestVehicleInfoSuccess:nil Failure:nil];
}


+ (void)requestVehicleInfoSuccess:(void (^)(id))success Failure:(void (^)(id))failure {
//    SOSFlutterVehicleConditionEnable({
//        [PlatformRouterImp sendEventToFlutter:CHANNELEVENT_REFRESHCONDITION arguments:nil result:^(id  _Nullable result) {
//            BOOL ret = result;
//            if (ret) {
//                if (success) {
//                    success(nil);
//                }
//
//            }else {
//                if (failure) {
//                    failure(nil);
//                }
//            }
//        }];
//    }, {
        [SOSVehicleInfoUtil requestVehicleInfoWithParameters:nil Success:success Failure:failure];
//    });
}

+ (void)requestICM2VehicleInfoSuccess:(void (^)(id))success Failure:(void (^)(id))failure	{
    NSString *parameters = @{ @"diagnosticsRequest": @{ @"diagnosticItem": [ServiceController getICM2DataRefreshRequestTypes] }}.mj_JSONString;
    [SOSVehicleInfoUtil requestVehicleInfoWithParameters:parameters Success:success Failure:failure];
}

+ (void)requestVehicleInfoWithParameters:(NSString *)parameters Success:(void (^)(id))success Failure:(void (^)(id))failure	{
    if (![[LoginManage sharedInstance] isLoadingMainInterfaceReady]) {
        if (failure)    failure(nil);
        return;
    }
//    if([CustomerInfo sharedInstance].icmVehicleStatus == nil)  [CustomerInfo sharedInstance].icmVehicleStatus = [SOSICM2VehicleStatus new];
    if (![SOSCheckRoleUtil isVisitor]) {
        
//        if ([SOSGreetingManager shareInstance].vehicleStatus == RemoteControlStatus_InitSuccess) {
//            NSLog(@"正在刷新车况,勿重复请求");
        if ([ServiceController sharedInstance].switcherLock) {
            NSString *message = NSLocalizedString(@"MultiVehicleOperationAlert", nil);
            [Util showAlertWithTitle:message message:nil completeBlock:nil];
            if (failure)    failure(nil);
            return;
        }
        
        if (parameters.length) {
            [CustomerInfo sharedInstance].icmVehicleRefreshState = RemoteControlStatus_InitSuccess;
        } else {
            [SOSGreetingManager shareInstance].vehicleStatus = RemoteControlStatus_InitSuccess;
        }
        [SOSVehicleData getVehicleDataWithParameters:parameters Success:^(id result) {
            // 暂时使用是否有传入 parameters 判断 ICM
            if (parameters.length) {
                [SOSVehicleInfoUtil handleICMVehicleResponse:result];
                [CustomerInfo sharedInstance].icmVehicleRefreshState = RemoteControlStatus_OperateSuccess;
                [SOSICM2VehicleStatus saveCurrentResultToUserDefaults];
            }	else	{
                [SOSGreetingManager shareInstance].vehicleStatus = RemoteControlStatus_OperateSuccess;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success)    success(result);
            });
        } Failed:^(id result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (parameters.length)		[CustomerInfo sharedInstance].icmVehicleRefreshState = RemoteControlStatus_OperateFail;
                else						[SOSGreetingManager shareInstance].vehicleStatus = RemoteControlStatus_OperateFail;
                if (failure)    failure(result);
            });
        }];
    }
}

/// 处理 ICM 新增部件 请求回调
+ (void)handleICMVehicleResponse:(NSDictionary *)sourceDic	{
    //正向判定会添加很多括号,不易读
    if (!([sourceDic isKindOfClass:[NSDictionary class]] && sourceDic.count)) 		return;
    NSDictionary *commandResponse = sourceDic[@"commandResponse"];
    if (!([commandResponse isKindOfClass:[NSDictionary class]] && commandResponse.count)) 		return;
    NSString *completionTimeStr = commandResponse[@"completionTime"];
    NSString *requestTimeStr = commandResponse[@"requestTime"];
    [[CustomerInfo sharedInstance].icmVehicleStatus clearSharedInstancePropertys];
    if (completionTimeStr.length) {
        NSDate *completionTime = [[SOSDateFormatter sharedInstance] getDateWithSourceDateString:completionTimeStr];
        [CustomerInfo sharedInstance].icmVehicleStatus.completionTime = [[SOSDateFormatter sharedInstance] dateStrWithDateFormat:@"yyyy-MM-dd HH:mm" Date:completionTime timeZone:@"GMT+0800"];
    }
    if (requestTimeStr.length) {
        NSDate *requestTime = [[SOSDateFormatter sharedInstance] getDateWithSourceDateString:requestTimeStr];
        [CustomerInfo sharedInstance].icmVehicleStatus.requestTime = [[SOSDateFormatter sharedInstance] dateStrWithDateFormat:@"MM-dd HH:mm" Date:requestTime timeZone:@"GMT+0800"];
    }
//    NSString *status = commandResponse[@"status"];
//    NSString *type = commandResponse[@"type"];
//    NSString *url = commandResponse[@"url"];
    
    NSDictionary *body = commandResponse[@"body"];
    if (!([body isKindOfClass:[NSDictionary class]] && body.count))		return;
    NSArray *diagnosticResponse = body[@"diagnosticResponse"];
    if (!([diagnosticResponse isKindOfClass:[NSArray class]] && diagnosticResponse.count)) 	return;
    for (NSDictionary *diagnosticDic in diagnosticResponse) {
        if (!([diagnosticDic isKindOfClass:[NSDictionary class]] && diagnosticDic.count))	return;
        NSString *name = [diagnosticDic[@"name"] uppercaseString];
        NSArray *diagnosticElements = diagnosticDic[@"diagnosticElement"];
        if (!([diagnosticElements isKindOfClass:[NSArray class]] && diagnosticElements.count))     continue;
        if (!([name isKindOfClass:[NSString class]] && name.length))     continue;
        
        SOSICM2ItemState resultState = [SOSVehicleInfoUtil getResultStateWithName:name AndDataDicArray:diagnosticElements];
        // 车窗状态
        if ([name isEqualToString:@"WINDOW POSITION STATUS"]) {
            [CustomerInfo sharedInstance].icmVehicleStatus.windowPositionStatus = resultState;
        // 天窗状态
        }    else if ([name isEqualToString:@"SUNROOF POSITION STATUS"])    {
            [CustomerInfo sharedInstance].icmVehicleStatus.sunroofPositionStatus = resultState;
        // 后备箱状态
        }    else if ([name isEqualToString:@"REAR CLOSURE AJAR STATUS"])    {
            [CustomerInfo sharedInstance].icmVehicleStatus.trunkStatus = resultState;
        // 车门状态
        }    else if ([name isEqualToString:@"DOOR AJAR STATUS"])    {
            [CustomerInfo sharedInstance].icmVehicleStatus.carDoorStatus = resultState;
        // 双闪灯状态
        }    else if ([name isEqualToString:@"HAZARDLIGHTS STATUS"])    {
            [CustomerInfo sharedInstance].icmVehicleStatus.flashStatus = resultState;
        // 发动机状态
        }    else if ([name isEqualToString:@"REMOTE START STATUS"])    {
            [CustomerInfo sharedInstance].icmVehicleStatus.engineStatus = resultState;
        // 上一条控车门指令
        }    else if ([name isEqualToString:@"DOOR LAST REMOTE LOCK STATUS"])    {
            [CustomerInfo sharedInstance].icmVehicleStatus.lastDoorCommands = resultState;
        // 车灯状态
        }    else if ([name isEqualToString:@"HEADLIGHTS STATUS"])    {
            [CustomerInfo sharedInstance].icmVehicleStatus.lightStatus = resultState;
        }
    }
}

+ (SOSICM2ItemState)getResultStateWithName:(NSString *)name	AndDataDicArray:(NSArray *)dataDicArray		{
    NSString *standardString = @"";
    // 车窗状态
    if ([name isEqualToString:@"WINDOW POSITION STATUS"] || ([name isEqualToString:@"SUNROOF POSITION STATUS"])) {
        standardString = @"FULLY CLOSED";
    }	else if ([name isEqualToString:@"DOOR AJAR STATUS"] || [name isEqualToString:@"HAZARDLIGHTS STATUS"] || [name isEqualToString:@"HEADLIGHTS STATUS"] || [name isEqualToString:@"REMOTE START STATUS"])	{
        standardString = @"FALSE";	// 为 FALSE 时,为关闭状态
    }	else if ([name isEqualToString:@"REAR CLOSURE AJAR STATUS"]/* 后备箱 */  || [name isEqualToString:@"DOOR LAST REMOTE LOCK STATUS"])    {
        standardString = @"LOCKED";	// Locked 表示 上锁
    }
    NSString *isAllClosed = @"";
    for (NSDictionary *elementDic in dataDicArray) {
        if (!([elementDic isKindOfClass:[NSDictionary class]] && elementDic.count))    return SOSICM2ItemState_Non;
        NSString *value = elementDic[@"value"];
        NSString *childItemName = elementDic[@"name"];
//        NSString *message = elementDic[@"message"];
//        NSString *status = elementDic[@"status"];
        if ([name isEqualToString:@"DOOR AJAR STATUS"]) {
            if ([childItemName isEqualToString:@"DRIVER DOOR AJAR STATUS"]) {
                CustomerInfo.sharedInstance.icmVehicleStatus.driverDoorStatus = [self handleDoorAjarStatus:value];
            }else if ([childItemName isEqualToString:@"CO DRIVER DOOR AJAR STATUS"]) {
                CustomerInfo.sharedInstance.icmVehicleStatus.co_driverDoorStatus = [self handleDoorAjarStatus:value];
            }else if ([childItemName isEqualToString:@"LEFT REAR DOOR AJAR STATUS"]) {
                CustomerInfo.sharedInstance.icmVehicleStatus.leftRearDoorStatus = [self handleDoorAjarStatus:value];
            }else if ([childItemName isEqualToString:@"RIGHT REAR DOOR AJAR STATUS"]) {
                CustomerInfo.sharedInstance.icmVehicleStatus.rightRearDoorStatus = [self handleDoorAjarStatus:value];
            }
        }
        
        // 上一条控车门指令,需要单独处理
        if ([name isEqualToString:@"DOOR LAST REMOTE LOCK STATUS"]) {
            // 目前只关注 DOOR LAST REMOTE LOCK STATUS 对应的 Value
            if ([childItemName isEqualToString:@"DOOR LAST REMOTE LOCK STATUS"]) {
                if (![value isKindOfClass:[NSString class]] || !value.length || [value.uppercaseString isEqualToString:@"UNKNOWN"]) {
                    return 	SOSICM2ItemState_Non;
                }	else if ([value.uppercaseString isEqualToString:@"LOCKED"])	{
                    return 	SOSICM2ItemState_close;
                }	else if ([value.uppercaseString isEqualToString:@"UNLOCKED"])    {
                    return 	SOSICM2ItemState_open;
                }	else	return SOSICM2ItemState_Non;
            }
        }
        
        // 无value或value为 NA , isAllClosed 保持不变
        if (![value isKindOfClass:[NSString class]] || !value.length || [value.uppercaseString isEqualToString:@"NA"])	isAllClosed = @"--";
        
        else if ([value.uppercaseString isEqualToString:standardString])    {
            // value 为 完全关闭 / 关闭
            if (isAllClosed.length)		isAllClosed = (isAllClosed.boolValue & YES) ? @"YES" : @"NO";
            else                        isAllClosed = @"YES";
        }
        // 车窗/天窗状态 新增 异常状态    !!!!! DENORMALIZED  待确定
        else if (([name isEqualToString:@"WINDOW POSITION STATUS"] || ([name isEqualToString:@"SUNROOF POSITION STATUS"]) )  && [value.uppercaseString isEqualToString:@"DENORMALIZED"]) 	{
            return SOSICM2ItemState_unNormal;
        }
        
        else    {
            // value 不是全关 / 开启
            if (isAllClosed.length)     isAllClosed = (isAllClosed.boolValue & NO) ? @"YES" : @"NO";
            else                        isAllClosed = @"NO";
        }
    }
    SOSICM2ItemState resultState;
    if (!isAllClosed.length)		resultState = SOSICM2ItemState_Non;
    else                         	resultState = isAllClosed.boolValue ? SOSICM2ItemState_close : SOSICM2ItemState_open;
    return resultState;
}

+ (SOSICM2ItemState)handleDoorAjarStatus:(NSString *)value {
    if (![value isKindOfClass:[NSString class]] || !value.length || [value.uppercaseString isEqualToString:@"UNKNOWN"]) {
        return     SOSICM2ItemState_Non;
    }    else if ([value.uppercaseString isEqualToString:@"FALSE"])    {
        return     SOSICM2ItemState_close;
    }    else if ([value.uppercaseString isEqualToString:@"TRUE"])    {
        return     SOSICM2ItemState_open;
    }    else    return SOSICM2ItemState_Non;
}

+ (void)requestVehicleEngineNumberComplete:(void(^)(NNVehicleInfoModel *vehicleModel))success	{
      __block NNVehicleInfoModel *vehicleInfo = [[NNVehicleInfoModel alloc] init];
        if ([SOSCheckRoleUtil isOwner] || [SOSCheckRoleUtil isDriverOrProxy]) {
          
            if([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin&&[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin.length>0){
                    
                    NSString *url = [BASE_URL stringByAppendingFormat:VEHICLE_INFO_URL,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];

                    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            vehicleInfo  =[NNVehicleInfoModel mj_objectWithKeyValues:responseStr];
                            UserDefaults_Set_Object(vehicleInfo.engineNumber, @"CarInfoTypeEngineNum");
                            UserDefaults_Set_Object(vehicleInfo.licensePlate, @"CarInfoTypeLicenseNum");
                            if (success) {
                                success(vehicleInfo);
                            }
                        });
                    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                        if (success) {
                            success(nil);
                        }
                    }];
                    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
                    [operation setHttpMethod:@"GET"];
                    [operation start];
                
            }    else {
                if (success) {
                    success(nil);
                }

            }
            
        }else{
            
            if (success) {
                success(nil);
            }
        }
            
           
    
}
@end
