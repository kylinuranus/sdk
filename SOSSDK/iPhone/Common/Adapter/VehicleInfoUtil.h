//
//  VehicleInfoUtil.h
//  Onstar
//
//  Created by Vicky on 16/6/30.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VehicleInfoUtil : NSObject
//Sum:4 old
//获取车辆列表

//切换车辆

//修改车牌号（已完成）
//+ (void)putVehicle_baseinfo_requestWithLicensePlate:(NSString *)licensePlate engineNumber:(NSString *)engineNumber success:(void (^)(void))success failure:(void (^)(void))failure ;

+ (void)updateVehicleLicensePlate:(NSString * )licenseNumber_ engine:(NSString *)engineNumber_ success:(void (^)(void))success failure:(void (^)(NSString * resp_))failure;

//车况检测报告

//车况检测报告详情

//新增到期保险日期，交强险到期日期，驾照到期日期

//修改到期保险日期，交强险到期日期，驾照到期日期
+ (void)updateVehicleDrivingLicenseInfo:(NSString *)drivingLicenseDate success:(void (^)(void))success failure:(void (^)(NSString * resp_))failure;
//新增保险公司信息

//修改保险公司信息

//获取车型配置信息：豪华型，舒适型

//修改车型配置信息：豪华型，舒适型

#pragma mark -----Info3
    //车是否是info3车
+ (void)vehicleIsInfo3JudgeBygid:(NSString *)userId vehicleVin:(NSString *)vin successHandler:(void(^)(ResponseInfo * res))success failureHandler:(void(^)(NSString *responseStr, NNError *error))failure;



@end
