//
//  SOSRegisterAgreementView.m
//  Onstar
//
//  Created by TaoLiang on 02/05/2018.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSRegisterAgreementView.h"
#import "SOSCheckButton.h"

@interface SOSRegisterAgreementView ()
@property (strong, nonatomic) SOSCheckButton *firstButton;
@property (strong, nonatomic) UILabel *firstLabel;
@property (strong, nonatomic) SOSCheckButton *secondButton;
@property (strong, nonatomic) UILabel *secondLabel;


@end

@implementation SOSRegisterAgreementView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self configView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configView];
        
    }
    return self;
}

- (void)configView {
    NSArray *imageNames = @[@"icon_nav_uncheck_idle_25x25", @"icon_nav_checked_idle_25x25"];
    _firstButton = [SOSCheckButton buttonWithImageNames:imageNames];
    [_firstButton addTarget:self action:@selector(checkBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    _secondButton = [SOSCheckButton buttonWithImageNames:imageNames];
    [_secondButton addTarget:self action:@selector(checkBtnClicked:) forControlEvents:UIControlEventTouchUpInside];

    _firstLabel = [UILabel new];
    _firstLabel.textColor = [UIColor colorWithHexString:@"898994"];
    _firstLabel.numberOfLines = 0;

    _secondLabel = [UILabel new];
    _secondLabel.numberOfLines = 0;
    _secondLabel.textColor = [UIColor colorWithHexString:@"898994"];

    
    NSString *firstString = @"我已阅读并同意《安吉星服务协议》和《安吉星隐私声明》";
    NSMutableAttributedString *firstMutString = [[NSMutableAttributedString alloc] initWithString:firstString];
    [firstMutString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(0, firstMutString.length)];
    NSArray<NSValue *> *firstRanges = [self getRangesForAgreement:firstString];
    [firstRanges enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [firstMutString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"107FE0"] range:obj.rangeValue];
    }];
    _firstLabel.attributedText = firstMutString;
    
    __weak __typeof(self)weakSelf = self;
    [_firstLabel detectRanges:firstRanges tapped:^(NSInteger index) {
        if (weakSelf.tapAgreement) {
            weakSelf.tapAgreement(0, index);
        }
    }];

    
    NSString *secondString = @"我已阅读并同意《上汽通用用户条款》和《上汽通用个人隐私政策》";
    NSMutableAttributedString *secondMutString = [[NSMutableAttributedString alloc] initWithString:secondString];
    [secondMutString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(0, secondString.length)];

    NSArray<NSValue *> *secondRanges = [self getRangesForAgreement:secondString];
    [secondRanges enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [secondMutString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"107FE0"] range:obj.rangeValue];
    }];
    _secondLabel.attributedText = secondMutString;
    [_secondLabel detectRanges:secondRanges tapped:^(NSInteger index) {
        if (weakSelf.tapAgreement) {
            weakSelf.tapAgreement(1, index);
        }

    }];

    
    [self addSubview:_firstButton];
    [self addSubview:_secondButton];
    [self addSubview:_firstLabel];
    [self addSubview:_secondLabel];
    
    [_firstLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(_firstButton.mas_right).offset(5);
        make.top.right.equalTo(self);
    }];
    [_firstButton mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerY.equalTo(_firstLabel);
        make.left.equalTo(self);
    }];
    
    [_secondLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(_secondButton.mas_right).offset(5);
        make.bottom.right.equalTo(self);
        make.top.equalTo(_firstLabel.mas_bottom).offset(10);
        
    }];
    [_secondButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_secondLabel);
        make.left.bottom.equalTo(self);
    }];
    


}

- (void)checkBtnClicked:(SOSCheckButton *)button {
    button.selected = !button.selected;
    if (_checkState) {
        _checkState(_firstButton.selected && _secondButton.selected);
    }
}

- (BOOL)isAllSelected {
    return _firstButton.selected && _secondButton.selected;
}




@end
