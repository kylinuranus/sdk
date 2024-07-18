//
//  SOSVehicle.m
//  Onstar
//
//  Created by Onstar on 2018/3/2.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSVehicle.h"

NSString static*  KUserdefaultICM2VehicleStatusKey = @"KUserdefaultICM2VehicleStatusKey";

@implementation SOSVehicle

@end


@implementation SOSICM2VehicleStatus


+ (void)saveCurrentResultToUserDefaults        {
    NSString *vin = [CustomerInfo sharedInstance].currentVehicle.vin;
    if (!vin.length)    return;
    
    SOSICM2VehicleStatus *icm2VehicleStatus = [CustomerInfo sharedInstance].icmVehicleStatus;
    NSDictionary *keyValuesDic = icm2VehicleStatus.mj_keyValues;
    if (keyValuesDic.count > 1) {
        NSString *md5VinStr = vin.md5String;
        NSMutableDictionary *originDic = [NSMutableDictionary dictionaryWithDictionary:UserDefaults_Get_Object(KUserdefaultICM2VehicleStatusKey)];
        originDic[md5VinStr] = keyValuesDic;
        UserDefaults_Set_Object(originDic, KUserdefaultICM2VehicleStatusKey);
    }
}

+ (SOSICM2VehicleStatus *)readSavedVehicleStatus       {
    SOSICM2VehicleStatus *icm2VehicleStatus = [CustomerInfo sharedInstance].icmVehicleStatus;
    if (icm2VehicleStatus.requestTime)        return icm2VehicleStatus;
    NSString *vin = [CustomerInfo sharedInstance].currentVehicle.vin;
    if (!vin.length)            return nil;
    
    NSDictionary *allSavedValues = UserDefaults_Get_Object(KUserdefaultICM2VehicleStatusKey);
    if (allSavedValues.count) {
        NSString *md5VinStr = vin.md5String;
        NSDictionary *dic = allSavedValues[md5VinStr];
        if (dic.count > 1) {
            SOSICM2VehicleStatus *vehicleStatus = [SOSICM2VehicleStatus mj_objectWithKeyValues:dic];
            if (vehicleStatus)    {
                [CustomerInfo sharedInstance].icmVehicleStatus = vehicleStatus;
                return vehicleStatus;
            }
        }
    }
    return nil;
}

@end
