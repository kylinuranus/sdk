//
//  SOSVehicleEVDataView.m
//  Onstar
//
//  Created by TaoLiang on 2018/10/25.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSVehicleEVDataView.h"

@implementation SOSVehicleEVDataView


- (void)refresh {
    _mileageLabel.text = [self getResult:[CustomerInfo sharedInstance].bevBatteryRange];
    _label0.text = @"预估续航里程";
    _label2.text = [self fetchChargeStateDescription];
    _chargeStateImageView.image = [self fetchChargeStateImage];
    
    
}

- (NSString *)getResult:(NSString *)res {
    if (![Util isValidNumber:res]) {
        return @"--";
    }
    return res;
}

- (UIImage *)fetchChargeStateImage {
    NSString *imageName = @"icon_car_battery_unknown_smart_purple_idle_50x50";
    NSString *chargeState = [CustomerInfo sharedInstance].chargeState;
    if ([chargeState isEqualToString:SOSVehicleChargeStateCharging]) {
        imageName = @"icon_car_battery_ongoing_smart_purple_idle_50x50";
    }else if ([chargeState isEqualToString:SOSVehicleChargeStateNotCharging]) {
        if ([Util isValidNumber:[CustomerInfo sharedInstance].bevBatteryStatus]) {
            NSInteger batteryStatus = ([CustomerInfo sharedInstance].bevBatteryStatus.integerValue / 10) * 10;
            imageName = [NSString stringWithFormat:@"icon_car_battery_%@_smart_purple_idle_50x50", @(batteryStatus)];
        }
    }else if ([chargeState isEqualToString:SOSVehicleChargeStateChargingComplete]) {

        imageName = @"icon_car_battery_ending_smart_purple_idle_50x50";
    }else if ([chargeState isEqualToString:SOSVehicleChargeStateChargingAborted]) {
        imageName = @"icon_car_battery_unknown_smart_purple_idle_50x50";
    }
    return [UIImage imageNamed:imageName];
}



- (NSString *)fetchChargeStateDescription {
    NSString *description = @"充电状态";
    NSString *chargeState = [CustomerInfo sharedInstance].chargeState;
    if ([chargeState isEqualToString:SOSVehicleChargeStateCharging]) {
        description = @"充电中";
    }else if ([chargeState isEqualToString:SOSVehicleChargeStateNotCharging]) {
        description = @"电池电量";
    }else if ([chargeState isEqualToString:SOSVehicleChargeStateChargingComplete]) {
        description = @"充电完成";
    }else if ([chargeState isEqualToString:SOSVehicleChargeStateChargingAborted]) {
        description = @"异常退出";
    }
    return description;
}


@end
