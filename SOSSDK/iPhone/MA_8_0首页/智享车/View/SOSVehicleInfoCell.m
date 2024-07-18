//
//  SOSVehicleInfoCell.m
//  Onstar
//
//  Created by lmd on 2017/9/22.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSVehicleInfoCell.h"
#import "SOSVehicleInfoView.h"

@interface SOSVehicleInfoCell ()
@property (nonatomic, strong) SOSVehicleInfoView *vehicleInfoView;
@end
@implementation SOSVehicleInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setUpView {
    [self.containerView.configCellView addSubview:self.vehicleInfoView];
    [self.vehicleInfoView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.containerView.configCellView);
    }];
    self.containerView.titleLb.text = @"车辆信息";
    self.containerView.shadowView.image = [UIImage imageNamed:@"tile_shadow_purple"];
    self.containerView.iconSign.image = [UIImage imageNamed:@"icon_car"];

}

- (SOSVehicleInfoView *)vehicleInfoView {
    if (!_vehicleInfoView) {
        _vehicleInfoView = [SOSVehicleInfoView viewFromXib];
    }
    return _vehicleInfoView;
}

- (void)refresh {
    LOGIN_STATE_TYPE state = [LoginManage sharedInstance].loginState;
    if (state == LOGIN_STATE_NON) {
        self.status = RemoteControlStatus_OperateSuccess;
    }else if (state == LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS) {
        self.status = RemoteControlStatus_OperateSuccess;
    }else if (state == LOGIN_STATE_LOADINGTOKEN) {
        self.status = RemoteControlStatus_InitSuccess;
    }
    [self.vehicleInfoView refresh];
}

@end
