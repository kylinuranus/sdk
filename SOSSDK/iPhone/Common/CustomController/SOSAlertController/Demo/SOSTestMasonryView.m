//
//  SOSTestMasonryView.m
//  Onstar
//
//  Created by TaoLiang on 2018/12/24.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSTestMasonryView.h"

@implementation SOSTestMasonryView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSMutableArray *views = @[].mutableCopy;
        for (int i=0; i<5; i++) {
            UIView *view = [self fetchView];
            [views addObject:view];
        }
        
        UIView *prev;
        for (int i = 0; i < views.count; i++) {
            UIView *v = views[i];
            [v mas_makeConstraints:^(MASConstraintMaker *make) {
                if (prev) {
                    make.top.equalTo(prev.mas_bottom).offset(10);
                    if (i == views.count - 1) {//last one
                        make.bottom.equalTo(self).offset(-10);
                    }
                }
                else {//first one
                    make.top.equalTo(self).offset(10);
                }
                
            }];
            prev = v;
        }
    }
    return self;
}

- (UIView *)fetchView {
    UIView *view = [UIView new];
    view.backgroundColor = [Util randomColor];
    [self addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make){
        make.height.equalTo(@(arc4random_uniform(50)+1));
        make.centerX.equalTo(self);
        make.width.equalTo(@(arc4random_uniform(100)+1));
    }];
    return view;

}

@end
