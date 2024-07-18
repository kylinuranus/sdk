//
//  SOSTopPromptView.m
//  Onstar
//
//  Created by TaoLiang on 2018/12/28.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSTopPromptView.h"
#import "SVIndefiniteAnimatedView.h"
#import "UILabel+DetectLink.h"
#import "SOSTopNetworkTipView.h"

@interface SOSTopPromptView ()
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) SVIndefiniteAnimatedView *animatedView;
//@property (strong, nonatomic) UIButton *refreshBtn;
@property (strong, nonatomic) UILabel *promptLabel;
@property (strong, nonatomic) UIButton *closeBtn;

@end

@implementation SOSTopPromptView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundView = [UIView new];
        _backgroundView.backgroundColor = [[UIColor colorWithHexString:@"#DD8316"] colorWithAlphaComponent:0.9];
        _backgroundView.layer.cornerRadius = 4.f;
        [self addSubview:_backgroundView];
        [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make){
            make.edges.equalTo(self);
        }];
        
        _animatedView = [[SVIndefiniteAnimatedView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        _animatedView.strokeThickness = 2;
        _animatedView.strokeColor = [UIColor whiteColor];
        _animatedView.radius = 8;
        [self addSubview:_animatedView];
        [_animatedView mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(@10);
            make.centerY.equalTo(self);
            make.width.height.equalTo(@24);
        }];
        
        _promptLabel = [UILabel new];
        _promptLabel.textColor = [UIColor whiteColor];
        _promptLabel.font = [UIFont systemFontOfSize:11];
        [self addSubview:_promptLabel];
        [_promptLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.centerY.equalTo(self);
            make.left.equalTo(@40);
        }];
        
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[UIImage imageNamed:@"Icon／34x34／trip_icon_position_del_34x34"] forState:UIControlStateNormal];
        [self addSubview:_closeBtn];
        [_closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make){
            make.centerY.and.right.equalTo(self);
            make.size.equalTo(@34);
            make.left.equalTo(_promptLabel.mas_right).offset(6);
        }];
        self.tag = KTOPTAG;
        
        _style = SOSTopPromptStyleUndefine;
    }
    return self;
}

- (void)setStyle:(SOSTopPromptStyle)style {
    /**
    4. 身份获取失败后显示的逻辑：
    a. 获取失败后仅在在5个导航页顶部显示（二级页面不显示）悬浮框，用户可以选择关闭/刷新
    b，用户关闭后悬浮框后，点击需要“获取身份成功”的功能时，继续弹出顶部悬浮框
    c, 如果顶部悬浮框存在的情况下，用户点击需要“获取身份成功”的功能时，Toast 提示用户“身份信息获取失败…”
    d. 补充：身份信息获取失败后，目前识别的需要进入二级界面的功能有：车辆共享中心（因为有蓝牙钥匙功能，需要支持用户任何情况下都可以进入）。
    但车辆共享中心中同时存在“远程遥控共享管理（原车分享功能）”，需要身份信息获取成功。--该情况不需要在二级页面弹顶部悬浮窗，用户点击后弹Toast需要“获取身份成功”的功能时即可
    5. 身份信息获取失败和网络连接异常两种顶部弹窗，网络连接异常优先弹出。（监控到网络有不好->好后，网络连接异常顶部弹窗自动消失）---开发已确认
     */
    if ([SOSTopNetworkTipView showing]) {
        [self removeFromSuperview];
        return;
    }
    
    if (_style == style) {
        return;
    }
    _style = style;

    switch (style) {
        case SOSTopPromptStyleLogining: {
            _backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.9f];
            _promptLabel.text = @"正在登录，请稍候..";
            _promptLabel.userInteractionEnabled = NO;
            _animatedView.hidden = NO;
            _closeBtn.hidden = YES;
            [self updatePromptLabelLeading];
            break;
        }
            
        case SOSTopPromptStyleRefreshing: {
            _backgroundView.backgroundColor = [[UIColor colorWithHexString:@"#DD8316"] colorWithAlphaComponent:0.9];
            _promptLabel.text = @"正在刷新身份信息,请稍候..";
            _promptLabel.userInteractionEnabled = NO;
            _animatedView.hidden = NO;
            _closeBtn.hidden = NO;
            [self updatePromptLabelLeading];

            break;
        }
        case SOSTopPromptStyleRefreshFailed: {
            _backgroundView.backgroundColor = [[UIColor colorWithHexString:@"#DD8316"] colorWithAlphaComponent:0.9];
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"身份信息获取失败，已为您展示DEMO数据，请刷新"];
            [attrStr addAttributes:@{
                                     NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                                     NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#F7FF00"]
                                     }
                             range:NSMakeRange(attrStr.length - 2, 2)];
            _promptLabel.attributedText = attrStr;
            [_promptLabel detectRanges:@[[NSValue valueWithRange:NSMakeRange(attrStr.length - 3, 3)]] tapped:^(NSInteger index) {
                [self refresh];
            }];
            _animatedView.hidden = YES;
            _closeBtn.hidden = NO;
            [self updatePromptLabelLeading];
            break;
        }
        default:
            break;
    }
}

- (BOOL)showing {
    return self.superview;
}

- (void)updatePromptLabelLeading {
    [_promptLabel mas_updateConstraints:^(MASConstraintMaker *make){
        make.left.mas_equalTo(_animatedView.hidden ? 10 : 40);
    }];
    [self layoutIfNeeded];

}

- (void)refresh {
    _refreshHandler ? _refreshHandler() : nil;

}

- (void)show {
    [KEY_WINDOW addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(@(STATUSBAR_HEIGHT));
        make.left.equalTo(@15);
        make.right.equalTo(@-15);
        make.height.equalTo(@34);
    }];

}

- (void)dismiss {
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.transform = CGAffineTransformIdentity;
        self.alpha = 1;
    }];
}

@end
