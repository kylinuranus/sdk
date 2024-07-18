//
//  callAlert.m
//  SOSCustomAlertView
//
//  Created by Genie Sun on 2017/7/18.
//  Copyright © 2017年 Onstar. All rights reserved.
//

#import "callAlert.h"

@implementation callAlert
- (IBAction)callOnstar:(id)sender {
    if (self.functionID) {
        [SOSDaapManager sendActionInfo:self.functionID];
    }
    [SOSUtil callPhoneNumber:self.callOnstarButton.titleLabel.text];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
