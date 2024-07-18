//
//  SOSInfoTableViewCell.m
//  Onstar
//
//  Created by Genie Sun on 2017/7/31.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSInfoTableViewCell.h"

@implementation SOSInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [SOSUtilConfig setCancelBackKeyBoardWithTextField:_tf target:self];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)CancelBackKeyboard:(id)sender{
    [_tf resignFirstResponder];
}

@end
