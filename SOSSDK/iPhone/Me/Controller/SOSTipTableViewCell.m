//
//  SOSTipTableViewCell.m
//  Onstar
//
//  Created by Genie Sun on 2017/3/14.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSTipTableViewCell.h"

@implementation SOSTipTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)tapAction:(UITapGestureRecognizer *)sender {
    [self.delegate tapActionToSet:self];
}
@end
