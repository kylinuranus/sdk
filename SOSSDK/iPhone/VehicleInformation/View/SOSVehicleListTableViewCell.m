
//
//  SOSVehicleListTableViewCell.m
//  Onstar
//
//  Created by Genie Sun on 2017/8/1.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSVehicleListTableViewCell.h"

@implementation SOSVehicleListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
