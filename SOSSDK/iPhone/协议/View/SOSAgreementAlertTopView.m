//
//  SOSAgreementAlertTopView.m
//  Onstar
//
//  Created by TaoLiang on 24/04/2018.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSAgreementAlertTopView.h"
#import "SOSAgreementAlertTopButton.h"
#import "SOSAgreementConst.h"

@interface SOSAgreementAlertTopView ()
@property (strong, nonatomic) NSMutableArray<SOSAgreementAlertTopButton *> *buttons;

@end

@implementation SOSAgreementAlertTopView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = SOSAgreementGrayColor;
    }
    return self;
}

- (void)setAgreements:(NSArray<SOSAgreement *> *)agreements {
    _agreements = agreements;
    if (agreements.count <= 0 ) {
        return;
    }
    _buttons = @[].mutableCopy;
    [_agreements enumerateObjectsUsingBlock:^(SOSAgreement * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SOSAgreementAlertTopButton *button = [SOSAgreementAlertTopButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:obj.docTitle forState:UIControlStateNormal];
        button.tag = idx;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(self);
            make.bottom.equalTo(self).offset(agreements.count == 1 ? 0 : -1);
            if (idx == 0) {
                make.left.equalTo(self);
            }else {
                make.left.equalTo(_buttons[idx-1].mas_right).offset(1);
            }
            
        }];
        [_buttons addObject:button];

    }];
    [self buttonClick:_buttons[_selectIndex]];

}

- (void)buttonClick:(UIButton *)btn {
    /*此处逻辑:
     计算被点击按钮的宽度，然后得出其他按钮的宽度
     1.被点击按钮宽度不小于平均宽度
     2.被点击按钮宽度最大为总宽度60%
    */
    static BOOL isInitial = YES;
    CGFloat margin = 1.f;
    CGFloat averageWidth = kAgreementContainerWidth / _buttons.count;
    __block CGFloat width = btn.intrinsicContentSize.width;
    __block CGFloat otherWidth;
    if (width <= averageWidth) {
        width = averageWidth;
        otherWidth = averageWidth;
    }else {
        if (width >= kAgreementContainerWidth * 0.6) {
            width = kAgreementContainerWidth * 0.6;
        }
        otherWidth = (kAgreementContainerWidth - width - (_buttons.count - 1) * margin) / (_buttons.count - 1);
    }
    [_buttons enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.selected = (obj == btn);
        [obj mas_updateConstraints:^(MASConstraintMaker *make){
            make.width.mas_equalTo(obj == btn ? width : otherWidth);
        }];
    }];
    
    if (_select) {
        _select(btn.tag);
    }
    
    if (isInitial) {
        isInitial = NO;
        return;
    }
    [UIView animateWithDuration:0.2 animations:^{
        [self layoutIfNeeded];
    }];
}

@end
