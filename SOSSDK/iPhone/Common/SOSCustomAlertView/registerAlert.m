//
//  registerAlert.m
//  SOSCustomAlertView
//
//  Created by Genie Sun on 2017/7/18.
//  Copyright © 2017年 Onstar. All rights reserved.
//

#import "registerAlert.h"

@implementation registerAlert
- (IBAction)callOnstar:(id)sender {
    [SOSUtil callPhoneNumber:self.phoneButton.titleLabel.text];
    if (self.functionID) {
        [SOSDaapManager sendActionInfo:self.functionID];
    }
}

@end
