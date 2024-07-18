//
//  SOSVehicleCashBookTableViewCell.m
//  Onstar
//
//  Created by Onstar on 2017/12/21.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSVehicleCashBookTableViewCell.h"
#import "SOSVehicleCashBookView.h"
@interface SOSVehicleCashBookTableViewCell()
@property (nonatomic, strong) SOSVehicleCashBookView *cashBookView;
@end

@implementation SOSVehicleCashBookTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setUpView {
    [self.containerView addSubview:self.cashBookView];
    
    [self.cashBookView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.containerView);
    }];
//    self.containerView.titleLb.text = @"用车手账";
//    self.containerView.shadowView.image = [UIImage imageNamed:@"tile_shadow_orange"];
//    self.containerView.iconSign.image = [UIImage imageNamed:@"icon_life_list_cashbook"];
    
}

- (SOSVehicleCashBookView *)cashBookView {
    if (!_cashBookView)
    {
        _cashBookView = [SOSVehicleCashBookView viewFromXib];
    }
    return _cashBookView;
}

- (void)refreshWithResp:(id)response {
    [super refreshWithResp:response];
//    [self showErrorStatusView];
    [self.cashBookView refreshWithResponseData:response
                                                 status:self.status];
}

- (UIImage *)statusImage {
    return self.cashBookView.bgView.image;
}

-(void)dealloc{
    NSLog(@"SOSVehicleCashBookTableViewCell dealloc");
}
@end
