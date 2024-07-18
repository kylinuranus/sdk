//
//  SOSBEVView.m
//  Onstar
//
//  Created by Genie Sun on 2017/7/26.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSBEVView.h"
#import "UIImage+GIFImage.h"

@interface SOSBEVView ()
@property (weak, nonatomic) IBOutlet UIImageView *carImgView;
@property (weak, nonatomic) IBOutlet UIImageView *chargeImgView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImgView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBtnLeftCons;
@property (weak, nonatomic) IBOutlet SOSCustomBtn *chargeSettingBtn;
@end

@implementation SOSBEVView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)awakeFromNib {
    [super awakeFromNib];
    //补回8.5消失的充电设置按钮
    _searchBtnLeftCons.active = ![Util vehicleIsEV];
//    _searchBtnLeftCons.priority = [Util vehicleIsEV] ? UILayoutPriorityDefaultLow : UILayoutPriorityRequired;
    _chargeSettingBtn.hidden = [Util vehicleIsEV];
}

- (void)configView {
    NSString *carImageName;
    NSString *chargeImgName;
     SOSChargeStatus chargeStatus = [Util updateChargeStatus];
    _carImgView.hidden = NO;
    _chargeImgView.hidden = NO;
    _bgImgView.hidden = YES;
    if (chargeStatus == SOSChargeStatus_charging) {
        _carImgView.hidden = YES;
        _chargeImgView.hidden = YES;
        _bgImgView.hidden = NO;
        _bgImgView.image = [UIImage imageWithGIFNamed:@"tile_condition_electric_charging_375x150"];
        return;
    }else if (chargeStatus == SOSChargeStatus_charging_complete) {
        carImageName = @"Image／OnStar_image_2D-car_150x501";
        chargeImgName = @"tile_condition_electric_charged_112x112";
    }else if (chargeStatus == SOSChargeStatus_not_charging) {
        chargeImgName = @"tile_condition_electric_n_112x112";
        
        NSString *level = [Util vehicleIsPHEV]? [CustomerInfo sharedInstance].batteryLevel : [CustomerInfo sharedInstance].bevBatteryStatus;
        if([Util isValidPercentValue:level]!= YES){
            carImageName = @"Icon／Car／icon_2D-car_def_150x50(11)";
        }else{
            NSInteger batteryValue = [level integerValue];
            if (batteryValue > 90) {
                carImageName = @"Icon／Car／icon_2D-car_def_150x50(1)";
            }else if (batteryValue > 80 ) {
                carImageName = @"Icon／Car／icon_2D-car_def_150x50(2)";
            }else if (batteryValue > 70) {
                carImageName = @"Icon／Car／icon_2D-car_def_150x50(3)";
            }else if (batteryValue > 60 ) {
                carImageName = @"Icon／Car／icon_2D-car_def_150x50(4)";
            }else if (batteryValue > 50 ) {
                carImageName = @"Icon／Car／icon_2D-car_def_150x50(5)";
            }else if (batteryValue > 40 ) {
                carImageName = @"Icon／Car／icon_2D-car_def_150x50(6)";
            }else if (batteryValue > 30 ) {
                carImageName = @"Icon／Car／icon_2D-car_def_150x50(7)";
            }else if (batteryValue > 20) {
                carImageName = @"Icon／Car／icon_2D-car_def_150x50(8)";
            }else if (batteryValue > 10) {
                carImageName = @"Icon／Car／icon_2D-car_def_150x50(9)";
            } else {//<10
                carImageName = @"Icon／Car／icon_2D-car_def_150x50(10)";
            }
            
        }
        UIImage * carImg =[UIImage imageNamed:carImageName];
        if (carImg) {
            _carImgView.image = carImg;
        }else{
          _carImgView.image = [UIImage imageNamed:@"car_side_full"];
        }
        
        if (chargeImgName) {
            _chargeImgView.image = [UIImage imageNamed:chargeImgName];
        }

    }else {
        //异常或未知
        carImageName = @"Icon／Car／icon_2D-car_def_150x50(11)";
        chargeImgName = @"tile_condition_electric_n_112x112";
    }
    
    
//    BOOL support = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.evBatteryLevelSupport;
//    if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.evBatteryLevelSupport) {
    
    
//    }else{
//        carImageName = @"Icon／Car／icon_2D-car_def_150x50(11)";
//    }
    _carImgView.image = [UIImage imageNamed:carImageName];
    _chargeImgView.image = [UIImage imageNamed:chargeImgName];
//    if ([Util vehicleIsEV]) {
//        NSString *carImageName = @"car_side_full";
//        NSString *chargeImgName;
//        NSString *chargeState = [CustomerInfo sharedInstance].chargeState;
//        if ([chargeState isEqualToString:SOSVehicleChargeStateCharging]) {
//            carImageName = @"car_side_charging";
//            chargeImgName = @"car_electric_passion_blue_idle";
//
//        }else if ([chargeState isEqualToString:SOSVehicleChargeStateNotCharging]) {
//            if ([Util isValidNumber:[CustomerInfo sharedInstance].bevBatteryStatus]) {
//                NSInteger batteryStatus = ([CustomerInfo sharedInstance].bevBatteryStatus.integerValue / 10) * 10;
//                carImageName = [NSString stringWithFormat:@"car_side_%@_charging", @(batteryStatus)];
//            }
//            chargeImgName = @"car_electric_passion_blue_idle_noline";
//
//        }else if ([chargeState isEqualToString:SOSVehicleChargeStateChargingComplete]) {
//            carImageName = @"car_side_full_charging";
//            chargeImgName = @"car_electric_passion_blue_idle";
//        }else if ([chargeState isEqualToString:SOSVehicleChargeStateChargingAborted]) {
//            carImageName = @"car_side_full_abnormal_300x100";
//            chargeImgName = @"car_electric_passion_blue_idle_noline";
//        }
//
//        _carImgView.image = [UIImage imageNamed:carImageName];
//        if (chargeImgName) {
//            _chargeImgView.image = [UIImage imageNamed:chargeImgName];
//        }
//    }else {
//        if ([[CustomerInfo sharedInstance].chargeState isEqualToString:SOSVehicleChargeStateCharging]) {
//            self.carImgView.image = [UIImage imageNamed:@"car_side_charging"];
//            self.chargeImgView.image = [UIImage imageNamed:@"car_electric_passion_blue_idle"];
//        }else {
//            self.carImgView.image = [UIImage imageNamed:@"car_side_full"];
//            self.chargeImgView.image = [UIImage imageNamed:@"car_electric_passion_blue_idle_noline"];
//        }
//    }
}


- (IBAction)pushChargeStation:(id)sender {
    [SOSDaapManager sendActionInfo:CARCONDITIONS_SEARCHNEARBYCHARGER];
    [self.delegate pushChargeStationVc];
}

- (IBAction)pushSettingVc:(id)sender {
    [self.delegate pushSettingVc];
}

@end
