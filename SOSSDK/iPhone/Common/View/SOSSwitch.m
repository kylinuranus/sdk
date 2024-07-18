//
//  SOSSwitch.m
//  Onstar
//
//  Created by Coir on 2020/1/14.
//  Copyright © 2020 Shanghai Onstar. All rights reserved.
//

#import "SOSSwitch.h"

@interface SOSSwitch ()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *stateImgView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGes;
@property (nonatomic, strong) UIPanGestureRecognizer *panGes;

@end

@implementation SOSSwitch

- (instancetype)initWithCoder:(NSCoder *)coder	{
    self = [super initWithCoder:coder];
    if (self) {
        [self configSelf];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame		{
    self = [super initWithFrame:frame];
    if (self) {
        [self configSelf];
        self.frame = frame;
        [self layoutIfNeeded];
    }
    return self;
}

+ (instancetype)new	{
    SOSSwitch *newSwitch = [[SOSSwitch alloc] init];
    [newSwitch configSelf];
    return newSwitch;
}

- (void)setOn:(BOOL)on	{
    [self setOn:on animated:YES];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated	{
    if (on == _on) 		return;
    _on = on;
    __weak __typeof(self) weakSelf = self;
    [self.stateImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.mas_centerY);
        if (on)		make.right.equalTo(weakSelf.mas_right);
        else        make.left.equalTo(weakSelf.mas_left);
    }];
    if (animated) {
            [UIView animateWithDuration:.2 animations:^{
                [weakSelf layoutIfNeeded];
            } completion:^(BOOL finished) {
                if (on)		weakSelf.stateImgView.image = [UIImage imageNamed:@"SOS_Switch_Open"];
                else		weakSelf.stateImgView.image = [UIImage imageNamed:@"SOS_Switch_Close"];
            }];
    }	else	{
        [self layoutIfNeeded];
        if (on)        weakSelf.stateImgView.image = [UIImage imageNamed:@"SOS_Switch_Open"];
        else        weakSelf.stateImgView.image = [UIImage imageNamed:@"SOS_Switch_Close"];
    }
}

- (void)configSelf    {
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 46, 11)];
    self.bgView.backgroundColor = [UIColor colorWithHexString:@"ECF3FE"];
    self.bgView.layer.masksToBounds = YES;
    self.bgView.layer.cornerRadius = 5.5f;
    [self addSubview:self.bgView];
    __weak __typeof(self) weakSelf = self;
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf).offset(1);
        make.right.equalTo(weakSelf).offset(-1);
        make.height.equalTo(@11);
        make.centerY.equalTo(weakSelf.mas_centerY);
    }];
    
    self.stateImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SOS_Switch_Close"]];
    [self addSubview:self.stateImgView];
    [self.stateImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.mas_centerY);
        make.left.equalTo(weakSelf.mas_left);
    }];
    
    self.tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerAction:)];
    [self addGestureRecognizer:self.tapGes];
    self.panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerAction:)];
    [self addGestureRecognizer:self.panGes];
    
    self.frame = CGRectMake(0, 0, 48, 30);
    [self layoutIfNeeded];
}

- (void)gestureRecognizerAction:(UIGestureRecognizer *)ges	{
    BOOL shouldRespondDelegate = NO;
    if (ges == self.tapGes) {
        [self setOn:!self.isOn];
        shouldRespondDelegate = YES;
    }	else if (ges == self.panGes)	{
        if (self.panGes.state == UIGestureRecognizerStateEnded) {
            CGPoint point = [self.panGes translationInView:self];
            [self setOn:(point.x >= 0)];
            shouldRespondDelegate = YES;
        }
    }
    
    if (shouldRespondDelegate && self.delegate && [self.delegate respondsToSelector:@selector(sosSwitchValueChanged:)]) {
        [self.delegate sosSwitchValueChanged:self];
    }
}

- (void)dealloc	{
    [self removeGestureRecognizer:self.panGes];
    [self removeGestureRecognizer:self.tapGes];
}

@end
