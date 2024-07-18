//
//  SOSAgreementAlertTopButton.m
//  Onstar
//
//  Created by TaoLiang on 25/04/2018.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSAgreementAlertTopButton.h"
#import "SOSAgreementConst.h"

@implementation SOSAgreementAlertTopButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setBackgroundColor:SOSAgreementGrayColor forState:UIControlStateSelected];
        [self setTitleColor:SOSAgreementGrayColor forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        self.showsTouchWhenHighlighted = NO;
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    size.width = size.width + 10;
    return size;
}

@end
