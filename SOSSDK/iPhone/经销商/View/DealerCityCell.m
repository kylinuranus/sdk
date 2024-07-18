//
//  DealerCityCell.m
//  Onstar
//
//  Created by huyuming on 16/1/22.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "DealerCityCell.h"

@implementation DealerCityCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DealerCityBgColor"]];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.provinceName.adjustsFontSizeToFitWidth = YES;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
