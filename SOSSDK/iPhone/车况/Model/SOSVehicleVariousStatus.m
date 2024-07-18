//
//  SOSVehicleVariousStatus.m
//  Onstar
//
//  Created by Genie Sun on 2017/8/18.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSVehicleVariousStatus.h"

@implementation SOSVehicleVariousStatus
@synthesize gasStatus,tirePressureStatus,oilStatus,batteryStatus;

+ (VehicleStatus)tirePressureStatus
{
    NSInteger tireStatusMask = 0;
    if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.tirePressureSupport){
        //左前轮
        if ([[CustomerInfo sharedInstance].tirePressureLFStatus isEqualToString:TIRE_PRESSURE_STATUS_RED]) {
            tireStatusMask |= PRESSURE_RED;
        }else if ([[CustomerInfo sharedInstance].tirePressureLFStatus isEqualToString:TIRE_PRESSURE_STATUS_YELLOW]) {
            tireStatusMask |= PRESSURE_YELLOW;
        }else if ([[CustomerInfo sharedInstance].tirePressureLFStatus isEqualToString:TIRE_PRESSURE_STATUS_GREEN]){
            tireStatusMask |= PRESSURE_GREEN;
        }
        
        //右前轮
        if ([[CustomerInfo sharedInstance].tirePressureRFStatus isEqualToString:TIRE_PRESSURE_STATUS_RED]) {
            tireStatusMask |= PRESSURE_RED;
        }else if ([[CustomerInfo sharedInstance].tirePressureRFStatus isEqualToString:TIRE_PRESSURE_STATUS_YELLOW]) {
            tireStatusMask |= PRESSURE_YELLOW;
        }else if ([[CustomerInfo sharedInstance].tirePressureRFStatus isEqualToString:TIRE_PRESSURE_STATUS_GREEN]){
            tireStatusMask |= PRESSURE_GREEN;
        }
        
        //左后轮
        if ([[CustomerInfo sharedInstance].tirePressureLRStatus isEqualToString:TIRE_PRESSURE_STATUS_RED]) {
            tireStatusMask |= PRESSURE_RED;
        }else if ([[CustomerInfo sharedInstance].tirePressureLRStatus isEqualToString:TIRE_PRESSURE_STATUS_YELLOW]) {
            tireStatusMask |= PRESSURE_YELLOW;
        }else if ([[CustomerInfo sharedInstance].tirePressureLRStatus isEqualToString:TIRE_PRESSURE_STATUS_GREEN]){
            tireStatusMask |= PRESSURE_GREEN;
        }

        //右后轮
        if ([[CustomerInfo sharedInstance].tirePressureRRStatus isEqualToString:TIRE_PRESSURE_STATUS_RED]) {
            tireStatusMask |= PRESSURE_RED;
        }else if ([[CustomerInfo sharedInstance].tirePressureRRStatus isEqualToString:TIRE_PRESSURE_STATUS_YELLOW]) {
            tireStatusMask |= PRESSURE_YELLOW;
        }else if ([[CustomerInfo sharedInstance].tirePressureRRStatus isEqualToString:TIRE_PRESSURE_STATUS_GREEN]){
            tireStatusMask |= PRESSURE_GREEN;
        }
    }
    
    if (tireStatusMask >= 0x100) {
        return PRESSURE_RED;
    } else if (tireStatusMask >= 0x010) {
        return  PRESSURE_YELLOW;
    } else if (tireStatusMask > 0x000) {
        return PRESSURE_GREEN;
    } else {
        return STATUS_NONE;
    }
}

+ (VehicleStatus)gasStatus
{
    if ([Util vehicleIsEV]) {
        return STATUS_NONE;
    }
    
    if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.fuelTankInfoSupport)
    {
        if ([Util isValidPercentValue:[CustomerInfo sharedInstance].fuelLavel] != YES)
        {
            return STATUS_NONE;
        } else {
            CGFloat gasValue = [[CustomerInfo sharedInstance].fuelLavel floatValue];
//            if (gasValue > 92) {
//                return GAS_GREEN_PERFECT;
//            } else
            if (gasValue > 20) {
                return GAS_GREEN_GOOD;
            } else if (gasValue > 10) {
                return GAS_YELLOW;
            } else {
                return GAS_RED;
            }
        }
    }else{
        return STATUS_NONE;
    }
}

+ (VehicleStatus)batteryStatusCharge {
    SOSChargeStatus chargeStatus = [Util updateChargeStatus];
    if (chargeStatus == SOSChargeStatus_not_charging) {
        if ([Util vehicleIsBEV]) {
            if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.bevBatteryStatusSupported) {
                if([Util isValidPercentValue:[CustomerInfo sharedInstance].bevBatteryStatus]!= YES){
                    return STATUS_NONE;
                }else{
                    CGFloat batteryValue = [[CustomerInfo sharedInstance].bevBatteryStatus floatValue];
                    if (batteryValue > 20 && batteryValue <= 100 ) {
                        return BATTERY_GREEN;
                    } else if (batteryValue > 10 && batteryValue <= 20) {
                        return BATTERY_YELLOW;
                    } else {
                        return BATTERY_RED;
                    }
                }
            }
        }else if ([Util vehicleIsPHEV]) {
            if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.evBatteryLevelSupport) {
                if([Util isValidPercentValue:[CustomerInfo sharedInstance].batteryLevel]!= YES){
                    return STATUS_NONE;
                }else{
                    CGFloat batteryValue = [[CustomerInfo sharedInstance].batteryLevel floatValue];
                    if (batteryValue > 20&& batteryValue <= 100 ) {
                        return BATTERY_GREEN;
                    } else if (batteryValue > 10 && batteryValue <= 20) {
                        return BATTERY_YELLOW;
                    } else {
                        return BATTERY_RED;
                    }
                }
            }
            
        }
    }else if (chargeStatus == SOSChargeStatus_charging_aborted) {
        return BATTERY_RED;
    }
    
    return STATUS_NONE;
}

+ (VehicleStatus)brakeStatus {
    if (Util.vehicleIsMy21) {
        SOSVehicle *vehicle = CustomerInfo.sharedInstance.currentVehicle;
        if (!vehicle.brakePadLifeSupported) {
            return STATUS_NONE;
        }
        NSString *brakeStatus = CustomerInfo.sharedInstance.brakePadLifeStatus.uppercaseString;
        if (
            brakeStatus.length <= 0 ||
            [brakeStatus isEqualToString:BRAKE_PAD_LIFE_Not_Present] ||
            [brakeStatus isEqualToString:BRAKE_PAD_LIFE_No_Action] ||
            [brakeStatus isEqualToString:BRAKE_PAD_LIFE_Disabled] ||
            [brakeStatus isEqualToString:BRAKE_PAD_LIFE_Service]
            ) {
            return STATUS_NONE;
        }
        if ([brakeStatus isEqualToString:BRAKE_PAD_LIFE_Ok]) {
            return BRAKE_GREEN;
        }
        if ([brakeStatus isEqualToString:BRAKE_PAD_LIFE_Change_Soon]) {
            return BRAKE_YELLOW;
        }
        if ([brakeStatus isEqualToString:BRAKE_PAD_LIFE_Change_Now]) {
            return BRAKE_RED;
        }
        
    }
    return STATUS_NONE;
}

+ (VehicleStatus)batteryStatus {
    if ([Util vehicleIsBEV]) {
        if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.bevBatteryStatusSupported) {
            if([Util isValidPercentValue:[CustomerInfo sharedInstance].bevBatteryStatus]!= YES){
                return STATUS_NONE;
            }else{
                CGFloat batteryValue = [[CustomerInfo sharedInstance].bevBatteryStatus floatValue];
                if (batteryValue > 20 && batteryValue <= 100 ) {
                    return BATTERY_GREEN;
                } else if (batteryValue > 10 && batteryValue <= 20) {
                    return BATTERY_YELLOW;
                } else {
                    return BATTERY_RED;
                }
            }
        }
    }else if ([Util vehicleIsPHEV]) {
        if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.evBatteryLevelSupport) {
            if([Util isValidPercentValue:[CustomerInfo sharedInstance].batteryLevel]!= YES){
                return STATUS_NONE;
            }else{
                CGFloat batteryValue = [[CustomerInfo sharedInstance].batteryLevel floatValue];
                if (batteryValue > 20&& batteryValue <= 100 ) {
                    return BATTERY_GREEN;
                } else if (batteryValue > 10 && batteryValue <= 20) {
                    return BATTERY_YELLOW;
                } else {
                    return BATTERY_RED;
                }
            }
        }
        
    }
    
    return STATUS_NONE;
}

+ (VehicleStatus)oilStatus
{
    if ([Util vehicleIsEV]) {
        return STATUS_NONE;
    }
    
    if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.oilLifeSupport) {
        if ([Util isValidPercentValue:[CustomerInfo sharedInstance].oilLife] != YES)
        {
            return STATUS_NONE;
        } else {
            CGFloat oilValue = [[CustomerInfo sharedInstance].oilLife floatValue];
            if (oilValue > 20) {
                return OIL_GREEN;
            } else if (oilValue > 10) {
                return OIL_YELLOW;
            } else {
                return OIL_RED;
            }
        }
    } else {
        return STATUS_NONE;
    }
}

+ (UIColor *) returnColorWithtirePressureStatus:(NSString *)str
{
    if ([str isEqualToString:TIRE_PRESSURE_STATUS_RED]) {
        return [UIColor colorWithHexString:STATUS_RED];
    }else if ([str isEqualToString:TIRE_PRESSURE_STATUS_YELLOW])
    {
        return [UIColor colorWithHexString:STATUS_YELLOW];
    }else if ([str isEqualToString:TIRE_PRESSURE_STATUS_GREEN])
    {
        return [UIColor colorWithHexString:STATUS_GREEN];
    }
    return nil;
}

+ (void) LBWithTextChangeCommentAndColor:(UILabel *)LB text:(NSString *)infoText color:(NSString *)colorStr
{
    dispatch_async_on_main_queue(^{
        LB.text = (infoText == nil) ? @"--" : infoText;
        LB.textColor = (colorStr == nil) ? [UIColor colorWithHexString:STATUS_GREEN] : [self returnColorWithtirePressureStatus:colorStr];
    });
}

@end
