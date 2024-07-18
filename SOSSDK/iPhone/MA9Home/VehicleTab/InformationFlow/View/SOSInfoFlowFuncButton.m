//
//  SOSInfoFlowFuncButton.m
//  Onstar
//
//  Created by TaoLiang on 2018/12/13.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSInfoFlowFuncButton.h"

@implementation SOSInfoFlowFuncButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderWidth = 1;
        self.color = [UIColor colorWithHexString:@"#F18F19"];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.layer.cornerRadius = 2;
    }
    return self;
}

- (void)setColor:(UIColor *)color {
    self.layer.borderColor = color.CGColor;
    [self setTitleColor:color forState:UIControlStateNormal];
}

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    size.width = size.width + 28;
    return size;
}

@end
