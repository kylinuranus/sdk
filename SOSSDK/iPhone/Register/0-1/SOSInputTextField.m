//
//  MyTextField.m
//  TextFieldDemo
//
//  Created by lmd on 2017/8/24.
//  Copyright © 2017年 Fentech. All rights reserved.
//

#import "SOSInputTextField.h"
#import "Masonry.h"

@interface SOSInputTextField ()
@property (nonatomic, assign) CGFloat dx;
@property (nonatomic, assign) CGFloat dy;
@property (nonatomic, strong) UILabel *bottomTipLabel;
@property (nonatomic, assign) BOOL passwordType;
@end

@implementation SOSInputTextField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self configUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {

        [self configUI];
    }
    return self;
}

- (void)configUI {
    _dx = 17;
//    _dy = 10;
    self.rightViewMode = UITextFieldViewModeUnlessEditing;
    [self addTarget:self action:@selector(textChange) forControlEvents:UIControlEventEditingChanged];
}

- (void)textChange {
//    NSLog(@"%@",self.text);
    if (self.text.length > 0) {
        self.inputStatus = SOSInputViewStatusEditing;
    }else {
        self.inputStatus = SOSInputViewStatusNormal;
    }
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    bounds = CGRectMake(_dx, _dy, bounds.size.width - _dx - self.rightView.width - 10, bounds.size.height - _dy);
    return bounds;
}
- (CGRect)editingRectForBounds:(CGRect)bounds
{
    bounds = CGRectMake(_dx, _dy, bounds.size.width - _dx - self.rightView.width - 10, bounds.size.height - _dy);
    return bounds;
}
- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    bounds = CGRectMake(_dx, _dy, bounds.size.width - _dx - self.rightView.width - 10, bounds.size.height - _dy);
    return bounds;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    CGRect rightRect = [super rightViewRectForBounds:bounds];
    rightRect.origin.x = self.frame.size.width - rightRect.size.width - _dx;
    return rightRect;
}


- (void)setInputStatus:(SOSInputViewStatus)inputStatus {
    _inputStatus = inputStatus;
    if (inputStatus == SOSInputViewStatusNormal) {
        self.dy = self.normalText.length>0?-10:0;
        self.bottomTipLabel.hidden = NO;
        self.bottomTipLabel.text = self.normalText;
        self.bottomTipLabel.textColor = [UIColor lightGrayColor];
        if (!self.passwordType) {
            self.rightView = nil;
        }
    }else if (inputStatus == SOSInputViewStatusEditing) {
        self.dy = 0;
        self.bottomTipLabel.hidden = YES;
        self.bottomTipLabel.text = @"";
        if (!self.passwordType) {
            self.rightView = nil;
        }
    }else if (inputStatus == SOSInputViewStatusSuccess) {
        self.dy = 0;
        self.bottomTipLabel.hidden = YES;
        self.bottomTipLabel.text = @"";
        if (!self.passwordType) {
            self.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_nav_correct_idle"]];
        }
    }else if (inputStatus == SOSInputViewStatusChecking) {
        self.dy = 0;
        self.bottomTipLabel.hidden = YES;
        self.bottomTipLabel.text = @"";
        if (!self.passwordType) {
            UIActivityIndicatorView *actView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [actView startAnimating];
            self.rightView = actView;
        }
    }else {
        self.dy = self.errorText.length>0?-10:0;
        self.bottomTipLabel.hidden = NO;
        self.bottomTipLabel.text = self.errorText;
        self.bottomTipLabel.textColor = [UIColor redColor];
        if (!self.passwordType) {
            self.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_alert_red_idle"]];
        }
        
    }
}

- (void)showError:(NSString *)text {
    self.errorText = text;
    self.inputStatus = SOSInputViewStatusError;
}

- (void)setupPasswordField
{
    [super setupPasswordField];
    self.passwordType = YES;
    [self setRightViewMode:UITextFieldViewModeAlways];
}


- (void)setDy:(CGFloat)dy {
    _dy = dy;
    [self setNeedsLayout];
}

- (void)setDx:(CGFloat)dx {
    _dx = dx;
    [self setNeedsLayout];
}


- (UILabel *)bottomTipLabel {
    if (!_bottomTipLabel) {
        _bottomTipLabel = [UILabel new];
        _bottomTipLabel.font = [UIFont systemFontOfSize:12];
        _bottomTipLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:_bottomTipLabel];
        [_bottomTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self).mas_offset(10);
            make.left.mas_equalTo(_dx);
            make.right.equalTo(@-45);
        }];
    }
    return _bottomTipLabel;
}



@end
