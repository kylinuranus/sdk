//
//  TLMroRestrictionErrorView.m
//  Onstar
//
//  Created by TaoLiang on 2017/11/24.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "TLMroRestrictionErrorView.h"

@interface TLMroRestrictionErrorView ()

@property (strong, nonatomic) UILabel *label;

@end

@implementation TLMroRestrictionErrorView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _label = [UILabel new];
        _label.textColor = [UIColor lightGrayColor];
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
        [_label mas_makeConstraints:^(MASConstraintMaker *make){
            make.center.equalTo(self);
            make.left.equalTo(@20);
        }];

    }
    return self;
}

- (void)setErrorMsg:(NSString *)errorMsg {
    _errorMsg = errorMsg;
    _label.text = errorMsg.length > 0 ? errorMsg : @"查询失败，请稍后再试";
}

@end
