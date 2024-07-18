//
//  LBSConsigneeHeaderView.m
//  LBSTest
//
//  Created by jieke on 2019/6/13.
//  Copyright © 2019 jieke. All rights reserved.
//

#import "LBSConsigneeHeaderView.h"

@interface LBSConsigneeHeaderView ()

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel *lbsConsigneeNameLabel;
@end

@implementation LBSConsigneeHeaderView

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
        make.width.mas_equalTo(kScreenWidth);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    [self.backView addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(10);
    }];
    
    [self.backView addSubview:self.lbsConsigneeNameLabel];
    [self.lbsConsigneeNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.right.mas_equalTo(-16);
        make.top.mas_equalTo(self.lineView.mas_bottom).offset(76);
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
        _lineView.backgroundColor = UIColorHex(0xF3F5FE);
    }
    return _lineView;
}
- (UILabel *)lbsConsigneeNameLabel {
    if (!_lbsConsigneeNameLabel) {
        _lbsConsigneeNameLabel = [[UILabel alloc] init];
        _lbsConsigneeNameLabel.font = [UIFont fontWithName:@"PingFang-SC-Bold" size: 16];
        _lbsConsigneeNameLabel.backgroundColor = [UIColor clearColor];
        _lbsConsigneeNameLabel.textColor = UIColorHex(0x304D8F);
        _lbsConsigneeNameLabel.textAlignment = NSTextAlignmentCenter;
        _lbsConsigneeNameLabel.text = @"请填写收货人信息";
    }
    return _lbsConsigneeNameLabel;
}
@end
