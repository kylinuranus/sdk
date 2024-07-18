//
//  SOSMsgHotActivityHead.m
//  Onstar
//
//  Created by WQ on 2018/5/23.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSMsgHotActivityHead.h"


@implementation SOSMsgHotActivityHead
{
    UIImageView *bg;
    UILabel *lb;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    self.backgroundColor = [UIColor Gray246];
    
    lb = [UILabel new];
    lb.text = @"———— 所有活动已加载完成 ————";
    lb.textColor =  [UIColor Gray185];
    lb.font = [UIFont systemFontOfSize:12];
    lb.hidden = YES;
    [self addSubview:lb];
    
    bg = [UIImageView new];
    bg.layer.masksToBounds = YES;
    bg.layer.cornerRadius = 12;
    bg.backgroundColor = [UIColor Gray185];
    [self addSubview:bg];
    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(26);
    }];

    _lb_date = [[UILabel alloc] init];
    _lb_date.textColor = [UIColor whiteColor];
    _lb_date.text = @"2018-05-22";
    _lb_date.textAlignment = NSTextAlignmentCenter;
    _lb_date.font = [UIFont systemFontOfSize:14];
    [bg addSubview:_lb_date];
    [_lb_date mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bg.mas_centerX);
        make.centerY.equalTo(bg.mas_centerY);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(20);
    }];
}

- (void)becomeFirstHead
{
    lb.hidden = NO;
    
    [lb mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(6);
        make.centerX.equalTo(self.mas_centerX);
        make.width.mas_equalTo(214);
        make.height.mas_equalTo(14);

    }];
    
    [bg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY).offset(10);
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(26);
    }];
}

- (void)reset
{
    lb.hidden = YES;
    [bg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(26);
    }];
}


- (void)dealloc
{
    NSLog(@"-----dealloc-----");
}



@end
