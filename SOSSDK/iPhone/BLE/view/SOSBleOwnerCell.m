//
//  SOSBleOwnerCell.m
//  Onstar
//
//  Created by onstar on 2018/7/19.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSBleOwnerCell.h"

#import "SOSBleOwnerView.h"

@interface SOSBleOwnerCell ()

@property (nonatomic, strong) SOSBleOwnerView *bleOwnerView;

@end

@implementation SOSBleOwnerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setUpView {
    [self.containerView.configCellView addSubview:self.bleOwnerView];
    [self.bleOwnerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.containerView.configCellView);
    }];
    
    self.containerView.titleLb.text = @"共享我的车";
    self.containerView.shadowView.image = [UIImage imageNamed:@"tile_shadow_purple"];
    self.containerView.iconSign.image = [UIImage imageNamed:@"icon_smart car_sharing_25x25"];
    
}

- (SOSBleOwnerView *)bleOwnerView {
    if (!_bleOwnerView) {
        _bleOwnerView = [SOSBleOwnerView viewFromXib];
    }
    return _bleOwnerView;
}


@end
