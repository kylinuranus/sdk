//
//  SOSCarConditionTwo.m
//  Onstar
//
//  Created by Genie Sun on 2017/7/28.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSCarConditionTwo.h"
#import "SOSVehicleVariousStatus.h"


@interface SOSCarConditionTwo ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fuleViewConst;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *rightView;

@end

@implementation SOSCarConditionTwo

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self configView];
}

/**
 车辆检测报告刷新
 */
- (void)configViewForDectViewWidth:(NNOVDEmailDTO *)ovdEmail {
    self.fuleViewConst.constant = 0;
    [self layoutIfNeeded];
    NSString *oilHealth =[NSString stringWithFormat:@"%@", ovdEmail.ovdEmailDTO.ovdMaintenanceInfo.vehicleMaintenance.engineOilHealth];
    if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.oilLifeSupport && [Util isValidNumber:oilHealth])
    {
        int intValue = [oilHealth floatValue] + 0.5;
        _FuelLb.text = [NSString stringWithFormat:@"%d", intValue];

    }
    else {
        _FuelLb.text = @"--";
    }
    
    NSString *odometer = [NSString stringWithFormat:@"%@",ovdEmail.ovdEmailDTO.ovdMaintenanceInfo.vehicleMaintenance.odometer];
    if ([Util isValidNumber:odometer])
    {
        int intValue = [odometer floatValue] + 0.5;
        _meter.text = [NSString stringWithFormat:@"%d", intValue];
    }
    else {
        _meter.text =@"--";
    }
    
}


- (void)configView
{
    if ([Util vehicleIsEV]) {
        self.fuleViewConst = 0;
        [_leftView mas_updateConstraints:^(MASConstraintMaker *make){
            make.width.equalTo(@0);
        }];
        [_rightView mas_updateConstraints:^(MASConstraintMaker *make){
            make.width.equalTo(_containerView);
        }];

    }else if ([Util vehicleIsPHEV]){
        //混动车
        self.fuleViewConst.constant = SCREEN_WIDTH/3;
        if([CustomerInfo sharedInstance].fuelLavel.isNotBlank) {
            _oilLb.text = [CustomerInfo sharedInstance].fuelLavel;
        }else {
            _oilLb.text = @"--";
        }
    }else{
        self.fuleViewConst.constant = 0;
    }
    [self layoutIfNeeded];
    
    
    if([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.oilLifeSupport && [Util isValidNumber:[CustomerInfo sharedInstance].oilLife])
    {
        _FuelLb.text = [CustomerInfo sharedInstance].oilLife;
    }else{
        _FuelLb.text = @"--";
    }
    
    if ([Util isValidNumber:[CustomerInfo sharedInstance].oDoMeter]) {
        _meter.text = [CustomerInfo sharedInstance].oDoMeter;
    }else{
        _meter.text = @"--";
    }
}

@end
