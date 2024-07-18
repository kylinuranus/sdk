//
//  SOSVehicleInfoUtil.h
//  Onstar
//
//  Created by onstar on 2017/10/16.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString static *KVehicleInfoNotification = @"KVehicleInfoNotification";

@interface SOSVehicleInfoUtil : NSObject

+ (void)requestVehicleInfo;
+ (void)requestVehicleInfoSuccess:(void(^)(id result))success Failure:(void(^)(id result))failure;

+ (void)requestICM2VehicleInfoSuccess:(void(^)(id result))success Failure:(void(^)(id result))failure;

/**
 查找车辆EnginNumber/LicensePlate
 如果userDefault有就使用，如果没有就后端查找
 @param success 返回车辆EnginNumber/LicensePlate Model
 */
+ (void)requestVehicleEngineNumberComplete:(void(^)(NNVehicleInfoModel *vehicleModel))success;

@end
