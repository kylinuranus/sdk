//
//  SOSOnMy21DoorStatusCell.m
//  Onstar
//
//  Created by Creolophus on 2020/2/24.
//  Copyright © 2020 Shanghai Onstar. All rights reserved.
//

#import "SOSOnMy21DoorStatusCell.h"

@interface SOSOnMy21DoorStatusCell ()
@property (strong, nonatomic) UIImageView *my21AllClosedImageView;
@property (strong, nonatomic) UIImageView *my21DriverDoorImageView;
@property (strong, nonatomic) UIImageView *my21CoDriverDoorImageView;
@property (strong, nonatomic) UIImageView *my21LeftRearDoorImageView;
@property (strong, nonatomic) UIImageView *my21RightRearDoorImageView;
@end

@implementation SOSOnMy21DoorStatusCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)configData:(SOSICM2ItemState)allDoorState {
    if (allDoorState == SOSICM2ItemState_open) {
        _my21AllClosedImageView.hidden = YES;
        SOSICM2VehicleStatus *status = CustomerInfo.sharedInstance.icmVehicleStatus;
        //隐藏的imageView不需要调用get方法实例化,直接调用变量
        (status.driverDoorStatus != SOSICM2ItemState_open) ? (_my21DriverDoorImageView.hidden = YES) : (self.my21DriverDoorImageView.hidden = NO);
        (status.co_driverDoorStatus != SOSICM2ItemState_open) ? (_my21CoDriverDoorImageView.hidden = YES) : (self.my21CoDriverDoorImageView.hidden = NO);
        (status.leftRearDoorStatus != SOSICM2ItemState_open) ? (_my21LeftRearDoorImageView.hidden = YES) : (self.my21LeftRearDoorImageView.hidden = NO);
        (status.rightRearDoorStatus != SOSICM2ItemState_open) ? (_my21RightRearDoorImageView.hidden = YES) : (self.my21RightRearDoorImageView.hidden = NO);


    }else {
        self.my21AllClosedImageView.hidden = NO;
        _my21DriverDoorImageView.hidden = YES;
        _my21CoDriverDoorImageView.hidden = YES;
        _my21LeftRearDoorImageView.hidden = YES;
        _my21RightRearDoorImageView.hidden = YES;
    }
}

- (UIImageView *)my21AllClosedImageView {
    if (!_my21AllClosedImageView) {
        _my21AllClosedImageView = UIImageView.new;
        _my21AllClosedImageView.image = [UIImage imageNamed:@"Icon／48x48／icon_air_move-seat_open_48x48"];
        [self.contentView addSubview:_my21AllClosedImageView];
        [_my21AllClosedImageView mas_makeConstraints:^(MASConstraintMaker *make){
            make.center.equalTo(self.contentView);
            make.width.height.equalTo(@48);
        }];

    }
    return _my21AllClosedImageView;
}

- (UIImageView *)my21DriverDoorImageView {
    if (!_my21DriverDoorImageView) {
        _my21DriverDoorImageView = UIImageView.new;
        _my21DriverDoorImageView.image = [UIImage imageNamed:@"icon_door_state_left-ahead_48x48"];
        [self.contentView addSubview:_my21DriverDoorImageView];
        [_my21DriverDoorImageView mas_makeConstraints:^(MASConstraintMaker *make){
            make.center.equalTo(self.contentView);
            make.width.height.equalTo(@48);
        }];

    }
    return _my21DriverDoorImageView;
}

- (UIImageView *)my21CoDriverDoorImageView {
    if (!_my21CoDriverDoorImageView) {
        _my21CoDriverDoorImageView = UIImageView.new;
        _my21CoDriverDoorImageView.image = [UIImage imageNamed:@"icon_door_state_right-ahead_48x48"];
        [self.contentView addSubview:_my21CoDriverDoorImageView];
        [_my21CoDriverDoorImageView mas_makeConstraints:^(MASConstraintMaker *make){
            make.center.equalTo(self.contentView);
            make.width.height.equalTo(@48);
        }];

    }
    return _my21CoDriverDoorImageView;
}

- (UIImageView *)my21LeftRearDoorImageView {
    if (!_my21LeftRearDoorImageView) {
        _my21LeftRearDoorImageView = UIImageView.new;
        _my21LeftRearDoorImageView.image = [UIImage imageNamed:@"icon_door_state_left-hinder_48x48"];
        [self.contentView addSubview:_my21LeftRearDoorImageView];
        [_my21LeftRearDoorImageView mas_makeConstraints:^(MASConstraintMaker *make){
            make.center.equalTo(self.contentView);
            make.width.height.equalTo(@48);
        }];

    }
    return _my21LeftRearDoorImageView;
}

- (UIImageView *)my21RightRearDoorImageView {
    if (!_my21RightRearDoorImageView) {
        _my21RightRearDoorImageView = UIImageView.new;
        _my21RightRearDoorImageView.image = [UIImage imageNamed:@"icon_door_state_right-hinder_48x48"];
        [self.contentView addSubview:_my21RightRearDoorImageView];
        [_my21RightRearDoorImageView mas_makeConstraints:^(MASConstraintMaker *make){
            make.center.equalTo(self.contentView);
            make.width.height.equalTo(@48);
        }];

    }
    return _my21RightRearDoorImageView;
}

@end
