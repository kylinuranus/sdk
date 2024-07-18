//
//  LBSConfirmOrderHeadView.m
//  LBSTest
//
//  Created by jieke on 2019/6/13.
//  Copyright © 2019 jieke. All rights reserved.
//

#import "LBSConfirmOrderSetMealHeadView.h"

@interface LBSConfirmOrderSetMealHeadView ()

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *topLineView;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation LBSConfirmOrderSetMealHeadView

#pragma mark - 系统的
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayoutView];
    }
    return self;
}
#pragma mark - Private
- (void)setupLayoutView {
    [self addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    [self.backView addSubview:self.topLineView];
    [self.topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(10);
    }];
    
    [self.backView addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topLineView.mas_bottom).offset(9);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(4);
        make.height.mas_equalTo(16);
    }];
    
    [self.backView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.lineView.mas_right).offset(8);
        make.top.mas_equalTo(self.topLineView.mas_bottom).offset(0);
        make.width.mas_greaterThanOrEqualTo(20);
        make.bottom.mas_equalTo(0);
    }];
}
#pragma mark - 懒加载
- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor whiteColor];
    }
    return _backView;
}
- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = UIColorHex(0x6896ED);
    }
    return _lineView;
}
- (UIView *)topLineView {
    if (!_topLineView) {
        _topLineView = [[UIView alloc] init];
        _topLineView.backgroundColor = UIColorHex(0xF3F5FE);
    }
    return _topLineView;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont fontWithName:@"PingFang-SC-Bold" size: 14];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = UIColorHex(0x6896ED);
        _titleLabel.text = @"套餐信息";
    }
    return _titleLabel;
}
@end

