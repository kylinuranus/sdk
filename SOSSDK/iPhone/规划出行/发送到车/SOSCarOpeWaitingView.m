//
//  SOSCarOpeWaitingView.m
//  Onstar
//
//  Created by TaoLiang on 2017/10/31.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSCarOpeWaitingView.h"
//#import <Masonry.h>

@interface SOSCarOpeWaitingView ()
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UIButton *closeBtn;
@property (strong, nonatomic) UIImageView *statusView;
@end

@implementation SOSCarOpeWaitingView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self configView];
    }
    return self;
}

- (void)setPrompt:(NSString *)prompt	{
    _prompt = prompt;
    _statusLabel.text = prompt;
}

- (void)setStatus:(Status)status{
    _status = status;
    switch (status) {
        case StatusLoading:
            _statusView.image = [UIImage imageNamed:@"icon_loading_passion_blue_idle"];
            [self startRotateStatusView];
            break;
        case StatusFailure:
            [self endRotateView];
            _statusView.image = [UIImage imageNamed:@"icon_loading_passion_blue_idle"];
            break;
        case StatusSuccess:
            [self endRotateView];
            _statusView.image = [UIImage imageNamed:@"icon_nav_correct_idle"];
            break;
        default:
            break;
    }
}

- (void)closeBtnClicked:(id)sender{
    if (_doneBtnClicked) {
        _doneBtnClicked();
    }
}

- (void)configView{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    
    _statusLabel = [UILabel new];
    _statusLabel.numberOfLines = 0;
    _statusLabel.font = [UIFont systemFontOfSize:18];
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_statusLabel];
    [_statusLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.mas_equalTo(22);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
    }];
    
    _statusView = [UIImageView new];
    _statusView.image = [UIImage imageNamed:@"icon_loading_passion_blue_idle"];
    _statusView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_statusView];
    [_statusView mas_makeConstraints:^(MASConstraintMaker *make){
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    
    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _closeBtn.layer.borderWidth = .3;
    [_closeBtn setTitle:@"知道了" forState:UIControlStateNormal];
    [_closeBtn setTitleColor:[UIColor colorWithHexString:@"007EE7"] forState:UIControlStateNormal];
    _closeBtn.titleLabel.textColor = [UIColor colorWithHexString:@"007EE7"];
    _closeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_closeBtn addTarget:self action:@selector(closeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_closeBtn];
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.bottom.left.right.equalTo(self).offset(-1);
        make.height.mas_equalTo(50);
    }];
    
}

static NSString * const rotationKey = @"rotationAnimation";
- (void)startRotateStatusView{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = @(-2 * M_PI);
        rotationAnimation.duration = 1;
        rotationAnimation.fillMode = kCAFillModeForwards;
        rotationAnimation.repeatCount = MAXFLOAT;
        [_statusView.layer addAnimation:rotationAnimation forKey:rotationKey];

    });
}

- (void)endRotateView{
    [_statusView.layer removeAnimationForKey:rotationKey];
}

@end
