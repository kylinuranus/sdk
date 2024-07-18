//
//  VehicleInfoUtil.m
//  Onstar
//
//  Created by Vicky on 16/6/30.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "VehicleInfoUtil.h"
#import "CustomerInfo.h"
@implementation VehicleInfoUtil

+ (void)updateVehicleLicensePlate:(NSString * )licenseNumber_ engine:(NSString *)engineNumber_ success:(void (^)(void))success_ failure:(void (^)(NSString * resp_))failure_
{
    NNVehicleInfoRequest *request = [[NNVehicleInfoRequest alloc]init];
    [request setAccountID:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId];
    [request setVin:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    if (licenseNumber_) {
      [request setLicensePlate:licenseNumber_];
    }
    if (engineNumber_) {
      [request setEngineNumber:engineNumber_];
    }
    
    if([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin&&[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin.length>0){
        
        NSString *url = [BASE_URL stringByAppendingFormat:VEHICLE_INFO_URL,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];

        SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:[request mj_JSONString] successBlock:^(SOSNetworkOperation *operation, id responseStr) {
            NSDictionary *vehicleDic =[Util dictionaryWithJsonString:responseStr];
            if(vehicleDic!=nil && [vehicleDic[@"code"] isEqualToString:@"E0000"]){
                UserDefaults_Set_Object(licenseNumber_, @"CarInfoTypeLicenseNum");
                UserDefaults_Set_Object(engineNumber_, @"CarInfoTypeEngineNum");
            }
            if (success_) {
                success_();
            }
        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            if (failure_) {
                failure_(responseStr);
            }
        }];
        [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
        [operation setHttpMethod:@"PUT"];
        [operation start];
        
    }else{
        
        if (failure_) {
            failure_(@"无法修改,获取车辆信息错误");
        }
    }
   

}
+ (void)updateVehicleDrivingLicenseInfo:(NSString *)drivingLicenseDate success:(void (^)(void))success failure:(void (^)(NSString * resp_))failure
{

    NNVehicleInfoRequest *request = [[NNVehicleInfoRequest alloc]init];
    [request setAccountID:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId];
    [request setVin:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    [request setDrivingLicenseDate:drivingLicenseDate];

    if([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin&&[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin.length>0){
        
        NSString *url = [BASE_URL stringByAppendingFormat:VEHICLE_INFO_URL,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];

        SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:[request mj_JSONString] successBlock:^(SOSNetworkOperation *operation, id responseStr) {
            NSDictionary *vehicleDic =[Util dictionaryWithJsonString:responseStr];
            if(vehicleDic!=nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        success();
                    }
                });
            }
            
        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            if (failure) {
                failure(responseStr);
            }
        }];
        [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
        [operation setHttpMethod:@"PUT"];
        [operation start];
    }else{
        
        if (failure) {
            failure(@"无法修改,获取车辆信息错误");
        }
    }
  
}

#pragma mark---info3
+ (void)vehicleIsInfo3JudgeBygid:(NSString *)userId vehicleVin:(NSString *)vin successHandler:(void(^)(ResponseInfo * res))success failureHandler:(void(^)(NSString *responseStr, NNError *error))failure;
    {
        NSString * url ;
        if (userId) {
            url = [NSString stringWithFormat:@"%@%@%@",[Util getConfigureURL],VEHICLE_IS_INFO3_BY_GID,userId.stringByURLEncode];
        }
        else
        {
            url = [NSString stringWithFormat:@"%@%@%@",[Util getConfigureURL],VEHICLE_IS_INFO3_BY_VIN,vin.stringByURLEncode];
        }
        SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
            ResponseInfo *res =[ResponseInfo mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
            if (success) {
                success(res);
            }
        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            NNError * nerror = [NNError mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
                failure(responseStr,nerror);
        }];
        [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
        [sosOperation setHttpMethod:@"GET"];
        [sosOperation start];
}

@end
