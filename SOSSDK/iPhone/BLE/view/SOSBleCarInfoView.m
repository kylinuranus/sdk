//
//  SOSBleCarInfoView.m
//  Onstar
//
//  Created by onstar on 2018/7/25.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSBleCarInfoView.h"
#import "SOSBleUtil.h"

@implementation SOSBleCarInfoView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)showOwnerCarInfo {
    self.carTypeLabel.text =  [NSString stringWithFormat:@"%@ %@款",[[CustomerInfo sharedInstance] currentVehicle].modelDesc,[[CustomerInfo sharedInstance] currentVehicle].year];
    self.vinLabel.text = [NSString stringWithFormat:@"%@",[SOSBleUtil recodesign:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin]];
    if ([Util vehicleIsCadillac]) {
        self.carLogoImageView.image = [UIImage imageNamed:@"brand_cadillac_font"];
    } else if ([Util vehicleIsBuick]){
        self.carLogoImageView.image = [UIImage imageNamed:@"brand_BUICK_font"];
    }else if ([Util vehicleIsChevrolet])
    {
        self.carLogoImageView.image = [UIImage imageNamed:@"brand_chevrolet_font"];
    }
//    self.carLogoImageView.image = [SOSUtilConfig returnImageBySortOfCarbrand];
}

@end
