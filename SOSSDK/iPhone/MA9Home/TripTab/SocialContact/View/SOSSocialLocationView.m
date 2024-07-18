//
//  SOSSocialLocationView.m
//  Onstar
//
//  Created by onstar on 2019/4/22.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSSocialLocationView.h"

@interface SOSSocialLocationView ()

@end

@implementation SOSSocialLocationView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)refuseTap:(id)sender {
    !self.cancelTap?:self.cancelTap();
}

- (IBAction)sendToCarTap:(id)sender {
    !self.sendToCarTap?:self.sendToCarTap();
}

- (IBAction)acceptTap:(id)sender {
    !self.acceptTap?:self.acceptTap();
}

@end
