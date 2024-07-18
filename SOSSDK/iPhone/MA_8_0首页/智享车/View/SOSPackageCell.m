//
//  SOSPackageCell.m
//  Onstar
//
//  Created by lmd on 2017/9/22.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSPackageCell.h"
#import "SOSPackageView.h"

@interface SOSPackageCell ()
@property (nonatomic, strong) SOSPackageView *packageView;
@end
@implementation SOSPackageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUpView {
    [self.containerView addSubview:self.packageView];
    [self.packageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.containerView);
    }];
    
//    self.containerView.shadowView.image = [UIImage imageNamed:@"tile_shadow_purple"];
//    self.containerView.iconSign.image = [UIImage imageNamed:@"car_tip_text"];

//    if ([LoginManage sharedInstance].loginState == LOGIN_STATE_LOADINGVEHICLEPRIVILIGESUCCESS) {
//        if ([CustomerInfo sharedInstance].isExpired) {
    self.packageView.packageImage.image = [UIImage imageNamed:@"image_car_my_onstar"];
//        }else {
//            self.packageView.packageImage.image = [UIImage imageNamed:@"image_car_my_onstars"];
//        }
//    }else {
//        self.packageView.packageImage.image = [UIImage imageNamed:@"image_car_my_onstar"];
//    }
}
- (void)refresh
{
    if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
        if ([CustomerInfo sharedInstance].isExpired) {
            self.packageView.packageImage.image = [UIImage imageNamed:@"image_car_my_onstar"];
        }else {
            self.packageView.packageImage.image = [UIImage imageNamed:@"image_car_my_onstars"];
        }
    }else {
        self.packageView.packageImage.image = [UIImage imageNamed:@"image_car_my_onstar"];
    }
}
- (SOSPackageView *)packageView {
    if (!_packageView) {
        _packageView = [SOSPackageView viewFromXib];
    }
    return _packageView;
}


@end
