//
//  SOSSocialGPSEndView.m
//  Onstar
//
//  Created by onstar on 2019/4/25.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSSocialGPSEndView.h"

@implementation SOSSocialGPSEndView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)finishTap:(id)sender {
    !self.finishTapBlock?:self.finishTapBlock();
}

@end
