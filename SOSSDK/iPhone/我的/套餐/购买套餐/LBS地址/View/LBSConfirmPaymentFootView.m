//
//  LBSConfirmPaymentFootView.m
//  LBSTest
//
//  Created by jieke on 2019/6/13.
//  Copyright © 2019 jieke. All rights reserved.
//

#import "LBSConfirmPaymentFootView.h"
#import "NSAttributedString+Category.h"
#import "UIImage+GradientColor.h"

@interface LBSConfirmPaymentFootView ()

@property (nonatomic, strong) UIView *bigBackView;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *originalPriceLabel;
@property (nonatomic, strong) UILabel *discountLabel;
@property (nonatomic, strong) UILabel *moneyLabel;
@property (nonatomic, strong) UIButton *paymentOrdersBtn;
@end

@implementation LBSConfirmPaymentFootView

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
    [self addSubview:self.bigBackView];
    [self.bigBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    [self.bigBackView addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(66);
    }];
    
    [self.backView addSubview:self.originalPriceLabel];
    [self.originalPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.top.mas_equalTo(12);
        make.width.mas_greaterThanOrEqualTo(20);
    }];
    
    [self.discountLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.backView addSubview:self.discountLabel];
    [self.discountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.originalPriceLabel.mas_bottom).offset(6);
        make.left.mas_equalTo(self.originalPriceLabel);
        make.width.mas_greaterThanOrEqualTo(20);
    }];
    
    [self.paymentOrdersBtn setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.backView addSubview:self.paymentOrdersBtn];
    [self.backView addSubview:self.moneyLabel];
    [self.paymentOrdersBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(112, 66));
    }];
    [self.moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.paymentOrdersBtn.mas_left).offset(-16);
        make.top.mas_equalTo(21);
        make.left.mas_equalTo(self.discountLabel.mas_right).offset(5);
    }];
    
}
- (void)setPackageInfos:(PackageInfos *)packageInfos {
    _packageInfos = packageInfos;
    NSString *originalPriceLabelText = [NSString stringWithFormat:@"原价 ¥ %@", packageInfos.annualPrice];
    self.originalPriceLabel.attributedText = [NSAttributedString setStrikethroughTitle:originalPriceLabelText];
    NSString *discountLabelText = [NSString stringWithFormat:@"优惠 ¥ %@", packageInfos.discountAmount];
    self.discountLabel.text = discountLabelText;
    [self setupMoneyAttributedText:packageInfos];
}
#pragma mark 支付订单
- (void)paymentOrdersBtnClick:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(confirmPaymentFootViewPaymentBtnClick)]) {
        [self.delegate confirmPaymentFootViewPaymentBtnClick];
    }
}
#pragma mark 富文本
- (void)setupMoneyAttributedText:(PackageInfos *)packageInfos {
    NSString *leftString = @"¥  ";
    NSString *rightString = packageInfos.actualPrice;
    NSString *string = [NSString stringWithFormat:@"%@%@", leftString, rightString];
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc]initWithString:string];
    NSRange leftRange = NSMakeRange(0, leftString.length);
    [attributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:23] range:leftRange];
    NSRange rightRange = NSMakeRange(leftString.length, rightString.length);
    [attributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:34] range:rightRange];
    self.moneyLabel.attributedText = attributedStr;
}
#pragma mark - 懒加载
- (UIView *)bigBackView {
    if (!_bigBackView) {
        _bigBackView = [[UIView alloc] init];
        _bigBackView.backgroundColor = UIColorHex(0xF3F5FE);
    }
    return _bigBackView;
}
- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor whiteColor];
        _backView.layer.shadowColor = [UIColorHex(0x6570B5) colorWithAlphaComponent:0.4].CGColor;
        _backView.layer.shadowOffset = CGSizeMake(0, 0);
        _backView.layer.shadowOpacity = 1;
        _backView.layer.shadowRadius = 8;
    }
    return _backView;
}
- (UILabel *)originalPriceLabel {
    if (!_originalPriceLabel) {
        _originalPriceLabel = [[UILabel alloc] init];
        _originalPriceLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 13];
        _originalPriceLabel.backgroundColor = [UIColor clearColor];
        _originalPriceLabel.textColor = UIColorHex(0xA4A4A4);
    }
    return _originalPriceLabel;
}
- (UILabel *)discountLabel {
    if (!_discountLabel) {
        _discountLabel = [[UILabel alloc] init];
        _discountLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 13];
        _discountLabel.backgroundColor = [UIColor clearColor];
        _discountLabel.textColor = UIColorHex(0xF18F19);
    }
    return _discountLabel;
}
- (UILabel *)moneyLabel {
    if (!_moneyLabel) {
        _moneyLabel = [[UILabel alloc] init];
        _moneyLabel.font = [UIFont fontWithName:@"PingFang-SC-Bold" size: 23];
        _moneyLabel.backgroundColor = [UIColor clearColor];
        _moneyLabel.textColor = UIColorHex(0x9D8169);
        _moneyLabel.textAlignment = NSTextAlignmentRight;
    }
    return _moneyLabel;
}
- (UIButton *)paymentOrdersBtn {
    if (!_paymentOrdersBtn) {
        _paymentOrdersBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_paymentOrdersBtn setTitle:@"支付订单" forState:UIControlStateNormal];
        [_paymentOrdersBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _paymentOrdersBtn.backgroundColor = UIColorHex(0x9D8169);
        _paymentOrdersBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size: 17];
        [_paymentOrdersBtn addTarget:self action:@selector(paymentOrdersBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        UIColor *topColor = UIColorHex(0xCCB7A2);
        UIColor *bottomColor = UIColorHex(0x9D8169);
        UIImage *bgImg = [UIImage gradientColorImageFromColors:@[topColor, bottomColor] gradientType:GradientTypeTopToBottom imgSize:CGSizeMake(112, 66)];
        _paymentOrdersBtn.backgroundColor = [UIColor colorWithPatternImage:bgImg];
    }
    return _paymentOrdersBtn;
}
@end
