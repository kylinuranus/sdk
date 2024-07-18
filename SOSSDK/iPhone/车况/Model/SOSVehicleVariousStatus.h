//
//  SOSVehicleVariousStatus.h
//  Onstar
//
//  Created by Genie Sun on 2017/8/18.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSNS_ENUM.h"

@interface SOSVehicleVariousStatus : NSObject
@property(readwrite,nonatomic) VehicleStatus oilStatus; //机油  // Rate for vehicle
@property(readwrite,nonatomic)VehicleStatus tirePressureStatus; //胎压
@property(readwrite,nonatomic)VehicleStatus gasStatus; //燃油
@property(readwrite,nonatomic)VehicleStatus batteryStatus;//电池


+ (VehicleStatus)tirePressureStatus;
+ (VehicleStatus)gasStatus;
+ (VehicleStatus)batteryStatus;
//车况
+ (VehicleStatus)batteryStatusCharge;
+ (VehicleStatus)oilStatus;

+ (VehicleStatus)brakeStatus;

+ (UIColor *) returnColorWithtirePressureStatus:(NSString *)str;
+ (void) LBWithTextChangeCommentAndColor:(UILabel *)LB text:(NSString *)infoText color:(NSString *)colorStr;

@end
