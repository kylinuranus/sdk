//
//  CarNumInputView.m
//  Onstar
//
//  Created by Coir on 16/5/12.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "CarNumInputView.h"
#import "UIView+Radius.h"
#import "ScreenInfo.h"

@interface CarNumInputView ()

@property (nonatomic, copy) NSString *outputStr;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) UIButton *finishButton;
@property (nonatomic, strong) NSArray <NSString *>*titArray;
@property (nonatomic, strong) NSMutableArray <UIButton *>*btnArray;
@end

@implementation CarNumInputView

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
    CGFloat carNumInputViewwHeight = 232 + [ScreenInfo sharedInstance].kTabBarBottomHeight;
    self.frame = CGRectMake(0, 0, kScreenWidth, carNumInputViewwHeight);
    [self addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
    
    [self.backView addSubview:self.topLabel];
    [self.topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.top.mas_equalTo(16);
        make.width.mas_greaterThanOrEqualTo(20);
    }];
    
    [self.backView addSubview:self.finishButton];
    [self.finishButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-16);
        make.top.mas_equalTo(self.topLabel);
        make.width.mas_greaterThanOrEqualTo(20);
        make.bottom.mas_equalTo(self.topLabel);
    }];
    
    CGFloat buttonWidth = 32.0;
    CGFloat buttonHeight = 28.0;
    for (NSUInteger i = 0; i < self.titArray.count; i ++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor whiteColor];
        //        button.layer.cornerRadius = 2.0;
        //        button.layer.masksToBounds = YES;
        button.layer.borderColor = UIColorHex(0xCFCFCF).CGColor;
        button.layer.borderWidth = 1.0;
        [button setTitle:self.titArray[i] forState:UIControlStateNormal];
        [button setTitleColor:UIColorHex(0x828389) forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 14];
        [button addTarget:self action:@selector(carNumButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.backView addSubview:button];
        [self.btnArray addObject:button];
        CGFloat spacing = (kScreenWidth - (buttonWidth * 8) - 32)/7;
        CGFloat buttonX = 16 + (buttonWidth + spacing) * (i % 8);
        CGFloat buttonY = 58 + (buttonHeight + 14) * (i / 8);
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(buttonX);
            make.top.mas_equalTo(buttonY);
            make.size.mas_equalTo(CGSizeMake(buttonWidth, buttonHeight));
        }];
        button.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
        [UIView setupAllAroundRadius:button size:CGSizeMake(2, 2)];
    }
}
#pragma mark 按钮点击
- (void)carNumButtonClick:(UIButton *)button {
    for (UIButton *allBtn in self.btnArray) {
        allBtn.backgroundColor = [UIColor whiteColor];
        allBtn.layer.borderColor = UIColorHex(0xCFCFCF).CGColor;
        [allBtn setTitleColor:UIColorHex(0x828389) forState:UIControlStateNormal];
    }
    [self buttonSetSelectState:button];
    self.outputStr = button.titleLabel.text;
    self.finishButton.enabled = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(outputStrChanged:)]) {
        [self.delegate outputStrChanged:self.outputStr];
    }
}
-(void)buttonSetSelectState:(UIButton *)button{
    button.backgroundColor = UIColorHex(0x6896ED);
       button.layer.borderColor = [UIColor clearColor].CGColor;
       [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}
#pragma mark 确定
- (void)finishButtonClick:(UIButton *)button  {
    if (self.outputStr) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(finishInput)]) {
            [self.delegate finishInput];
        }
    }
}
-(void)setSelect:(NSString *)str{
    if (str) {
        NSInteger ind = [_titArray indexOfObject:str];
        if (_btnArray.count >ind) {
            [self buttonSetSelectState:[_btnArray objectAtIndex:ind]];
        }
    }
}
#pragma mark - 懒加载
- (NSArray<NSString *> *)titArray {
    if (!_titArray) {
        _titArray = [NSArray arrayWithObjects:@"京",@"津",@"沪",@"渝",@"冀",@"豫", @"云",@"辽",@"黑",@"湘",@"皖",@"鲁",@"新",@"苏",@"浙",@"赣",@"鄂",@"桂",@"甘",@"晋",@"蒙",@"陕",@"吉",@"闽",@"贵",@"粤",@"青",@"藏",@"川",@"宁",@"琼", nil];
    }
    return _titArray;
}
- (NSMutableArray<UIButton *> *)btnArray {
    if (!_btnArray) {
        _btnArray = [NSMutableArray array];
    }
    return _btnArray;
}
- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor whiteColor];
        _backView.layer.shadowColor = [UIColorHex(0x6570B5) colorWithAlphaComponent:0.2].CGColor;
        _backView.layer.shadowOffset = CGSizeMake(0, 0);
        _backView.layer.shadowOpacity = 1;
        _backView.layer.shadowRadius = 8;
    }
    return _backView;
}
- (UILabel *)topLabel {
    if (!_topLabel) {
        _topLabel = [[UILabel alloc] init];
        _topLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 16];
        _topLabel.backgroundColor = [UIColor clearColor];
        _topLabel.textAlignment = NSTextAlignmentCenter;
        _topLabel.textColor = UIColorHex(0x28292F);
        _topLabel.text = @"选择省份";
    }
    return _topLabel;
}
- (UIButton *)finishButton {
    if (!_finishButton) {
        _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _finishButton.backgroundColor = [UIColor clearColor];
        _finishButton.enabled = NO;
        [_finishButton setTitle:@"确定" forState:UIControlStateNormal];
        [_finishButton setTitleColor:UIColorHex(0x6896ED) forState:UIControlStateNormal];
        _finishButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 16];
        [_finishButton addTarget:self action:@selector(finishButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishButton;
}
@end
