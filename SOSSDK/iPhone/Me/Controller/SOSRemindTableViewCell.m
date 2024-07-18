//
//  SOSRemindTableViewCell.m
//  Onstar
//
//  Created by Genie Sun on 2017/3/14.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSRemindTableViewCell.h"

@implementation SOSRemindTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)changeSwitchValue:(switchBtnState)changeState {
    if (changeState) {
        self.switchValue = changeState;
    }
}

- (IBAction)changeValue:(UISwitch *)sender {
    if (self.switchValue) {
        self.switchValue(sender);
    }
}

- (void)createSwitchStatus:(BOOL)flg {
    [self.switchbtn setOn:flg animated:YES];
}

@end
