//
//  SOSPlainVehicleConditionView.m
//  Onstar
//
//  Created by Onstar on 2019/1/20.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSPlainVehicleConditionView.h"
#import "SOSGotoVehicleConditionView.h"
#import "SOSProgressBar.h"
@implementation SOSPlainVehicleConditionView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
        self.layer.shadowOffset = CGSizeMake(3,3);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
        self.layer.shadowOpacity = 0.5;//阴影透明度，默认0
        self.layer.shadowRadius = 2;//阴影半径，默认3
        SOSGotoVehicleConditionView * gotoVehicleCondition = [[SOSGotoVehicleConditionView alloc] initWithFrame:CGRectZero];
        [self addSubview:gotoVehicleCondition];
        [gotoVehicleCondition mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(44.0f);
            make.leading.mas_equalTo(12.0f);
            make.bottom.mas_equalTo(self);
            make.trailing.mas_equalTo(12.0f);
        }];
        
    }
    return self;
}
-(void)showPlainVehicleStatusWithHeaderViewStatus:(SOSVehicleConditonStatus)st{
    switch (st) {
        case SOSVehicleConditonNormal:{
            if ([Util vehicleIsPHEV]) {
                [self phevPlainData];
            }else{
                if ([Util vehicleIsBEV]) {
                    [self evPlainData];
                }else{
                    [self fvPlainData];
                }
            }
        }
            break;
        case SOSVehicleConditonInCharge:{
            UILabel * label = [self detailLabel];
            label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];

            [label setText:@"充电中"];
           
            UIImageView * chargeStateImage;
            if (!chargeStateImage) {
                chargeStateImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vehicle_icon_incharge_blue"]];
                [self addSubview:chargeStateImage];
                [chargeStateImage mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(self).offset(10);
                    make.right.mas_equalTo(label.mas_left);
                }];
            }
            CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0];
            opacityAnimation.toValue = [NSNumber numberWithFloat:0.0];
            opacityAnimation.duration = 3.0f;
            opacityAnimation.autoreverses= YES;
            opacityAnimation.removedOnCompletion = NO;
            opacityAnimation.repeatCount = MAXFLOAT;
            [chargeStateImage.layer addAnimation:opacityAnimation forKey:nil];
        }
            
            break;
        case SOSVehicleConditonChargeComplete:{
            UILabel * label = [self detailLabel];
            label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];

            [label setText:@"充电完成"];
            UIImageView * chargeStateImage;
            if (!chargeStateImage) {
                chargeStateImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vehicle_icon_incharge_blue"]];
                [self addSubview:chargeStateImage];
                [chargeStateImage mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(self).offset(10);
                    make.right.mas_equalTo(label.mas_left);
                }];
            }
        }
            break;
        default:
//             [self phevPlainData];
            break;
    }
}
-(void)phevPlainData{

    UILabel *labelkm = [self detailLabel];
    labelkm.text = @" km";
    labelkm.textColor = [UIColor colorWithHexString:@"#A4A4A4"];
    labelkm.font = [UIFont fontWithName:@"DINNextLTPro-BoldCondensed" size: 18];
    [self addSubview:labelkm];
    [labelkm mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-12.0f);
        make.centerY.mas_equalTo(self).offset(10);
    }];
    
    UILabel *labelODOMeter = [[UILabel alloc] init];
    labelODOMeter.font = [UIFont fontWithName:@"DINNextLTPro-BoldCondensed" size: 26];
    labelODOMeter.textColor = [UIColor colorWithHexString:@"#4E5059"];
    labelODOMeter.text = [CustomerInfo sharedInstance].evTotleRange;
    [self addSubview:labelODOMeter];
    [labelODOMeter mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(labelkm.mas_left);
        make.centerY.mas_equalTo(self).offset(10);
    }];
    
    UILabel *labelphev = [[UILabel alloc] init];
    labelphev.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 14];
    labelphev.text = @"预估综合续航 ";
    labelphev.textColor = [UIColor colorWithHexString:@"#A4A4A4"];
    [self addSubview:labelphev];
    [labelphev mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(labelODOMeter.mas_left);
        make.centerY.mas_equalTo(self).offset(10);
    }];
}
-(void)evPlainData{
    
    [self makeProgress:0];

}
-(void)fvPlainData{
   
    [self makeProgress:1];
    
}
-(void)makeProgress:(NSInteger)type{
    
    UILabel * label = [self detailLabel];
    SOSProgressBar *progress = [[SOSProgressBar alloc] initWithFrame:CGRectMake(0, 0, 100.0f, 5.0f)];
    progress.backgroundColor = [UIColor colorWithHexString:@"#304D8F"];
    progress.tintColor = [UIColor colorWithHexString:@"#51FFF9"];
    [self addSubview:progress];
   
    
    if (type ==1) {
        label.font= [UIFont fontWithName:@"PingFangSC-Regular" size: 14];
        label.text =  @"燃油余量";
        if (![Util isValidNumber:[CustomerInfo sharedInstance].fuelLavel]) {
            progress.progress = 0;
        }else{
            
            progress.progress = [CustomerInfo sharedInstance].fuelLavel.floatValue/100.0f;
        }
        [progress mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(label.mas_left).offset(-10.0f);
            make.centerY.mas_equalTo(self).offset(10);
            make.width.mas_equalTo(100.0f);
            make.height.mas_equalTo(5.0f);
        }];
    }else{
        label.font = [UIFont fontWithName:@"DINNextLTPro-BoldCondensed" size:18];
        label.textColor = [UIColor colorWithHexString:@"#A4A4A4"];
        label.text = @" km";
        
        UILabel *labelBattery = [[UILabel alloc] init];
        labelBattery.textColor = [UIColor colorWithHexString:@"#4E5059"];
        labelBattery.text = [CustomerInfo sharedInstance].bevBatteryRange?[CustomerInfo sharedInstance].bevBatteryRange:@"--";
        labelBattery.font = [UIFont fontWithName:@"DINNextLTPro-BoldCondensed" size: 26];
        [self addSubview:labelBattery];
        [labelBattery mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(label.mas_leading);
            make.centerY.mas_equalTo(self).offset(10);
        }];
        [progress mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(labelBattery.mas_left).offset(-10.0f);
            make.centerY.mas_equalTo(self).offset(10);
            make.width.mas_equalTo(100.0f);
            make.height.mas_equalTo(5.0f);
        }];
        progress.progress = [CustomerInfo sharedInstance].bevBatteryStatus.floatValue/100.0f;
    }
    
}
-(UILabel *)detailLabel{
    UILabel * label = [[UILabel alloc] init];
    label.textColor = [UIColor colorWithRed:164/255.0 green:164/255.0 blue:164/255.0 alpha:1.0];
    [self addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-12.0f);
        make.height.mas_equalTo(self);
        make.centerY.mas_equalTo(self).offset(10);
    }];
    return label;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
