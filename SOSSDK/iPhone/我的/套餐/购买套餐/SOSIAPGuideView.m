//
//  SOSIAPGuideView.m
//  Onstar
//
//  Created by lmd on 2017/9/12.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSIAPGuideView.h"

@implementation SOSIAPGuideView

- (IBAction)buttonClick:(id)sender {
    [self dismiss];
}

- (void)dismiss {
    [super dismiss];
    [SOSDaapManager sendActionInfo:discountpopwindow_close];
}


@end
