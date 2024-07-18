//
//  SOSVehicleInsuranceCell.m
//  Onstar
//
//  Created by lmd on 2017/9/21.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSVehicleInsuranceCell.h"
#import "SOSVehicleInsuranceView.h"

@interface SOSVehicleInsuranceCell ()
@property (nonatomic, strong) SOSVehicleInsuranceView *vehicleInsuranceView;
@end

@implementation SOSVehicleInsuranceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUpView {
    [self.containerView addSubview:self.vehicleInsuranceView];
    self.vehicleInsuranceView.layer.cornerRadius = 6.0f;
    [self.vehicleInsuranceView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.containerView);
    }];
}

- (SOSVehicleInsuranceView *)vehicleInsuranceView {
    if (!_vehicleInsuranceView) {
        _vehicleInsuranceView = [SOSVehicleInsuranceView viewFromXib];
    }
    return _vehicleInsuranceView;
}

- (void)refreshWithResp:(id)response {
    [super refreshWithResp:response];
//    [self showErrorStatusView:YES statusLabelColor:[UIColor blackColor]];

//    if (response == nil) {
//        self.status = RemoteControlStatus_OperateSuccess;
//    }else if (self.status == RemoteControlStatus_InitSuccess) {
//        //显示读取中
//        self.statusView.status = RemoteControlStatus_InitSuccess;//懒加载创建
//        self.statusView.hidden = NO;
//        self.statusView.statusLabel.textColor = UIColorHex(0x107FE0);
//    }
    
    if ([response isKindOfClass:[NSArray class]] || [response isEqual:@NO]) {
        [self.vehicleInsuranceView refreshWithBanners:response];
    }
}

@end
