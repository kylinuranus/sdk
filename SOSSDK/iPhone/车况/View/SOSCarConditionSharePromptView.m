//
//  SOSCarConditionSharePromptView.m
//  Onstar
//
//  Created by TaoLiang on 2018/9/3.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSCarConditionSharePromptView.h"

@implementation SOSCarConditionSharePromptView

+ (instancetype)showWithTapped:(void (^)(void))tapped {
    SOSCarConditionSharePromptView *view = [[SOSCarConditionSharePromptView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
    if (tapped) {
        view.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            tapped();
        }];
        [view addGestureRecognizer:tapGesture];
    }
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.906 green:0.949 blue:0.984 alpha:1.000];
        UILabel *label = [UILabel new];
        label.textColor = [UIColor colorWithHexString:@"107FE0"];
        label.text = @"别忘了查看爱车车况，并分享呦！";
        label.font = [UIFont systemFontOfSize:14];
        [self addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make){
            make.centerY.equalTo(self);
            make.left.equalTo(@16);
        }];
        
        UIImageView *arrow = [UIImageView new];
        arrow.image = [UIImage imageNamed:@"icon_arrow_right"];
        [self addSubview:arrow];
        [arrow mas_makeConstraints:^(MASConstraintMaker *make){
            make.centerY.equalTo(self);
            make.right.equalTo(@-12);
        }];


    }
    return self;
}

@end
