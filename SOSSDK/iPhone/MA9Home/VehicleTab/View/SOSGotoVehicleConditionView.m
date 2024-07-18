//
//  SOSGotoVehicleConditionView.m
//  Onstar
//
//  Created by Onstar on 2019/1/4.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSGotoVehicleConditionView.h"
#import "SOSCardUtil.h"
@implementation SOSGotoVehicleConditionView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
       
        [self initView];
        [self addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            [SOSCardUtil routerToVehicleCondition];
            [SOSDaapManager sendActionInfo:VEHICLEDIA_ENTRY];
        }];
    }
    return self;
}
-(void)initView{
    UIImage * icImage = [UIImage imageNamed:[NSString stringWithFormat:@"vehicletab_brand_%@",[CustomerInfo sharedInstance].currentVehicle.brand.uppercaseString]];
    if (!icImage) {
        icImage = [UIImage imageNamed:@"vehicletab_brand_fail"];
    }
    UIImageView * icon = [[UIImageView alloc] initWithImage:icImage];
    icon.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:icon];
    UILabel * label = [[UILabel alloc] init];
    label.text = @"我的车况";
    
    label.textColor = [UIColor colorWithHexString:@"#4E5059"];
    label.font = [UIFont fontWithName:@"PingFangSC-Semibold" size: 15];
    [self addSubview:label];
    
    UIImageView * arrowIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon／22x22／OnStar_icon_guide_common_22x22"]];
    [self addSubview:arrowIcon];
    
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self);
        make.centerY.mas_equalTo(self);
        make.width.mas_equalTo(22);
        make.height.mas_equalTo(22);
    }];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(icon.mas_right).mas_offset(3);
        make.centerY.mas_equalTo(self);
        make.height.mas_equalTo(21);
    }];
    [arrowIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(label.mas_right).mas_offset(2);
    }];
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
