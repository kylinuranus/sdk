
//
//  SOSBaseXibView.m
//  Onstar
//
//  Created by Genie Sun on 2017/7/31.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSBaseXibView.h"

@implementation SOSBaseXibView

- (id)initWithCoder:(NSCoder *)aDecoder		{
    self = [super initWithCoder:aDecoder];
    if (self) {
        Class class = [self class];
        UIView *view = [[[UINib nibWithNibName:NSStringFromClass(class) bundle:nil] instantiateWithOwner:self options:nil] objectAtIndex:0];
        self.frame = view.bounds;
        [self addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom);
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
        }];
    }
    return self;
}


@end
