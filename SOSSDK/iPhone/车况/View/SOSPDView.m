//
//  SOSPDView.m
//  Onstar
//
//  Created by Genie Sun on 2017/7/25.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSPDView.h"
#import "SOSVehicleVariousStatus.h"

@interface SOSPDView ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *my21Margin;

@end

@implementation SOSPDView


- (void)configViewForDectViewWidth:(NNOVDEmailDTO *)ovdEmail {
    
    
     NSString *frontLeft = [NSString stringWithFormat:@"%d",(int)round(ovdEmail.ovdEmailDTO.ovdMaintenanceInfo.tirePressure.individualTirePressure.frontLeftPressure.floatValue)];

     NSString *imgFrontLeft = [NSString stringWithFormat:@"%@",ovdEmail.ovdEmailDTO.ovdMaintenanceInfo.tirePressure.individualTirePressure.frontLeftIcon];
    
    //右前轮
    NSString *frontRight =[NSString stringWithFormat:@"%d", (int)round(ovdEmail.ovdEmailDTO.ovdMaintenanceInfo.tirePressure.individualTirePressure.frontRightPressure.floatValue)];
    
    NSString *imgFrontRight = [NSString stringWithFormat:@"%@",ovdEmail.ovdEmailDTO.ovdMaintenanceInfo.tirePressure.individualTirePressure.frontRightIcon];
    //左后轮
    NSString *rearLeft = [NSString stringWithFormat:@"%d",(int)round(ovdEmail.ovdEmailDTO.ovdMaintenanceInfo.tirePressure.individualTirePressure.rearLeftPressure.floatValue)];
    
    NSString *imgRearLeft = [NSString stringWithFormat:@"%@",ovdEmail.ovdEmailDTO.ovdMaintenanceInfo.tirePressure.individualTirePressure.rearLeftIcon];
    
    //右后轮
    NSString *rearRight =[NSString stringWithFormat:@"%d", (int)round(ovdEmail.ovdEmailDTO.ovdMaintenanceInfo.tirePressure.individualTirePressure.rearRightPressure.floatValue)];
    
    NSString *imgRearRight = [NSString stringWithFormat:@"%@",ovdEmail.ovdEmailDTO.ovdMaintenanceInfo.tirePressure.individualTirePressure.rearRightIcon];
    
    [self configUIWithStatus:imgFrontLeft
                 tireImgView:self.LTTireImage
               statusImgView:self.LTImage
                       label:_LTLB
                        text:frontLeft];
    
    [self configUIWithStatus:imgFrontRight
                 tireImgView:self.RTTireImage
               statusImgView:self.RTImage
                       label:_RTLB
                        text:frontRight];
    
    [self configUIWithStatus:imgRearLeft
                 tireImgView:self.LBTireImage
               statusImgView:self.LBImage
                       label:_LBLB
                        text:rearLeft];
    
    [self configUIWithStatus:imgRearRight
                 tireImgView:self.RBTireImage
               statusImgView:self.RBImage
                       label:_RBLB
                        text:rearRight];
    
    //前胎参考值
    NSString *frontPlacardPressure =[NSString stringWithFormat:@"%@", ovdEmail.ovdEmailDTO.ovdMaintenanceInfo.tirePressure.frontPlacard];
    if(![Util isValidNumber:frontPlacardPressure]){
        _FrontTireLB.text = @"前胎压参考值: --千帕";
    }else{
        _FrontTireLB.text = [NSString stringWithFormat:@"前胎压参考值: %@%@",frontPlacardPressure,@"千帕"] ;
    }
    
    //后胎参考值
    NSString *backPlacardPressure = [NSString stringWithFormat:@"%@",ovdEmail.ovdEmailDTO.ovdMaintenanceInfo.tirePressure.rearPlacard];
    if(![Util isValidNumber:backPlacardPressure]){
        _RearTireLB.text = @"后胎压参考值: --千帕";
    }else{
        _RearTireLB.text = [NSString stringWithFormat:@"后胎压参考值: %@%@",backPlacardPressure,@"千帕"] ;
    }
}


- (void)configView {

    if (CustomerInfo.sharedInstance.currentVehicle.brakePadLifeSupported) {
        NSString *frontBrakePad = CustomerInfo.sharedInstance.brakePadLifeFront;
        NSString *rearBrakePad = CustomerInfo.sharedInstance.brakePadLifeRear;
        if ([Util isValidNumber:frontBrakePad]) {
            frontBrakePad = [frontBrakePad stringByAppendingString:@"%"];
        }
        if ([Util isValidNumber:rearBrakePad]) {
            rearBrakePad = [rearBrakePad stringByAppendingString:@"%"];
        }

        _topBrakeLabel.text = frontBrakePad;
        _bottomBrakeLabel.text = rearBrakePad;
    }
    if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.tirePressureSupport){
        
        //左前
        [self configUIWithStatus:[CustomerInfo sharedInstance].tirePressureLFStatus
                     tireImgView:self.LTTireImage
                   statusImgView:self.LTImage
                           label:_LTLB
                            text:[CustomerInfo sharedInstance].tirePressureLF];
        
        //右前
        [self configUIWithStatus:[CustomerInfo sharedInstance].tirePressureRFStatus
                     tireImgView:self.RTTireImage
                   statusImgView:self.RTImage
                           label:_RTLB
                            text:[CustomerInfo sharedInstance].tirePressureRF];
        //左后
        [self configUIWithStatus:[CustomerInfo sharedInstance].tirePressureLRStatus
                     tireImgView:self.LBTireImage
                   statusImgView:self.LBImage
                           label:_LBLB
                            text:[CustomerInfo sharedInstance].tirePressureLR];
        //右后
        [self configUIWithStatus:[CustomerInfo sharedInstance].tirePressureRRStatus
                     tireImgView:self.RBTireImage
                   statusImgView:self.RBImage
                           label:_RBLB
                            text:[CustomerInfo sharedInstance].tirePressureRR];
        
        //前胎参考值
        if(![Util isValidNumber:[CustomerInfo sharedInstance].tirePressurePlacardFront]){
            _FrontTireLB.text = @"前胎压参考值: --千帕";
        }else{
            _FrontTireLB.text = [NSString stringWithFormat:@"前胎压参考值: %@%@",[CustomerInfo sharedInstance].tirePressurePlacardFront,@"千帕"] ;
        }
        //后胎参考值
        if(![Util isValidNumber:[CustomerInfo sharedInstance].tirePressurePlacardRear]){
            _RearTireLB.text = @"后胎压参考值: --千帕";
        }else{
            _RearTireLB.text = [NSString stringWithFormat:@"后胎压参考值: %@%@",[CustomerInfo sharedInstance].tirePressurePlacardRear,@"千帕"] ;
        }
    }
}


- (void)configUIWithStatus:(NSString *)status tireImgView:(UIImageView *)tireImgView statusImgView:(UIImageView *)statusImgView label:(UILabel *)label  text:(NSString *)text{
    if (![Util isValidNumber:text]) {
        label.text = @"--";
        tireImgView.image = [UIImage imageNamed:@"icon_tires_pressure_unknown"];
//        statusImgView.image = nil;
        
        return;
    }else if (text.floatValue < 0) {
        return;
    }
    
    if ([status isEqualToString:TIRE_PRESSURE_STATUS_RED] || [status isEqualToString:TIRE_PRESSURE_STATUS_R]) {
        
        label.textColor = [UIColor colorWithHexString:STATUS_RED];
        tireImgView.image = [UIImage imageNamed:@"icon_tires_pressure_alert_red"];
//        statusImgView.image = [UIImage imageNamed:@"icon_alert_red_idle"];
    }else if ([status isEqualToString:TIRE_PRESSURE_STATUS_YELLOW]  || [status isEqualToString:TIRE_PRESSURE_STATUS_Y])
    {
        label.textColor = [UIColor colorWithHexString:STATUS_YELLOW];
        tireImgView.image = [UIImage imageNamed:@"icon_tires_pressure_alert_orange"];
    }else if ([status isEqualToString:TIRE_PRESSURE_STATUS_GREEN] || [status isEqualToString:TIRE_PRESSURE_STATUS_G])
    {
//        label.textColor = [UIColor colorWithHexString:STATUS_GREEN];
        tireImgView.image = [UIImage imageNamed:@"icon_tires_pressure_passion_blue"];
        label.textColor = [UIColor cadiStytle];
//        statusImgView.image = [UIImage imageNamed:@"icon_alert_green_idle"];
    }
    label.text = text;
}


+ (UIColor *)returnColorWithtirePressureStatus:(NSString *)str
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


- (void)awakeFromNib{
    [super awakeFromNib];
//    [self configView];
    if (Util.vehicleIsMy21) {
        [self suitMy21];
    }
}

- (void)suitMy21 {
    return;
    _my21Margin.constant = 36;
    
    NSArray<UIImageView *> *tires = @[_LTTireImage, _LBTireImage, _RTTireImage, _RBTireImage];
    [tires enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *brake = UIImageView.new;
        brake.image = [UIImage imageNamed:@"icon_condition_brake_sign_31x15"];
        [self addSubview:brake];
        [brake mas_makeConstraints:^(MASConstraintMaker *make){
            make.center.equalTo(obj);
        }];

    }];
    
    UIImageView *topImageView = UIImageView.new;
    topImageView.image = [UIImage imageNamed:@"icon_condition_brake_above_70x60"];
    [self addSubview:topImageView];
    [topImageView mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(self);
        make.left.equalTo(_LTTireImage.mas_right).offset(5);
        make.bottom.equalTo(_LTTireImage.mas_centerY);
    }];
    
    UILabel *topInfoLabel = UILabel.new;
    topInfoLabel.text = @"前刹车片";
    topInfoLabel.textColor = [UIColor colorWithHexString:@"#828389"];
    topInfoLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:topInfoLabel];
    [topInfoLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(topImageView);
        make.bottom.equalTo(topImageView.mas_top).offset(-6);
    }];
    
    UILabel *topPercentageLabel = UILabel.new;
    topPercentageLabel.text = @"--";
    topPercentageLabel.textColor = [UIColor colorWithHexString:STATUS_GREEN];
    topPercentageLabel.font = [UIFont fontWithName:@"DINNextLTPro-BoldCondensed" size:26];
    [self addSubview:topPercentageLabel];
    [topPercentageLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(topInfoLabel);
        make.bottom.equalTo(topInfoLabel.mas_top).offset(-4);
    }];
    _topBrakeLabel = topPercentageLabel;
    
    UIImageView *bottomImageView = UIImageView.new;
    bottomImageView.image = [UIImage imageNamed:@"icon_condition_brake_below_70x46"];
    [self addSubview:bottomImageView];
    [bottomImageView mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(self);
        make.left.equalTo(_LBTireImage.mas_right).offset(5);
        make.top.equalTo(_LBTireImage.mas_centerY);
    }];
    
    UILabel *bottomPercentageLabel = UILabel.new;
    bottomPercentageLabel.text = @"--";
    bottomPercentageLabel.textColor = [UIColor colorWithHexString:STATUS_GREEN];
    bottomPercentageLabel.font = [UIFont fontWithName:@"DINNextLTPro-BoldCondensed" size:26];
    [self addSubview:bottomPercentageLabel];
    [bottomPercentageLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(bottomImageView);
        make.top.equalTo(bottomImageView.mas_bottom).offset(2);
    }];
    _bottomBrakeLabel = bottomPercentageLabel;
    
    UILabel *bottomInfoLabel = UILabel.new;
    bottomInfoLabel.text = @"后刹车片";
    bottomInfoLabel.textColor = [UIColor colorWithHexString:@"#828389"];
    bottomInfoLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:bottomInfoLabel];
    [bottomInfoLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(bottomPercentageLabel);
        make.top.equalTo(bottomPercentageLabel.mas_bottom).offset(4);

    }];

}

@end
