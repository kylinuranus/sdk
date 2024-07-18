//
//  SOSInsuranceFloatView.m
//  Onstar
//
//  Created by Genie Sun on 2017/3/23.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSInsuranceFloatView.h"

@interface SOSInsuranceFloatView()
{
    dispatch_source_t timer;
}
@property (nonatomic, assign) CGFloat tipLbW;
@end

@implementation SOSInsuranceFloatView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
        [self initUI];
        [self createBezirePath:frame];
    }
    return self;
}


- (void)initUI
{
    self.userInteractionEnabled = YES;
    self.longview = [[UIView alloc] init];
    self.longview.clipsToBounds = YES;
    self.longview.backgroundColor = [UIColor colorWithRed:0.16 green:0.68 blue:0.98 alpha:1.00];
    [self addSubview:self.longview];

    self.tipLbBgView = [[UIView alloc] init];
    self.tipLbBgView.clipsToBounds = YES;
    self.tipLbBgView.backgroundColor = [UIColor colorWithRed:0.16 green:0.68 blue:0.98 alpha:1.00];
    [self.longview addSubview:self.tipLbBgView];

    self.tipLb1 = [[UILabel alloc] init];
    self.tipLb1.font = [UIFont systemFontOfSize:11];
    self.tipLb1.textAlignment = NSTextAlignmentCenter;
    self.tipLb1.layer.masksToBounds = YES;
    self.tipLb1.layer.cornerRadius = 5;
    self.tipLb1.backgroundColor = [UIColor clearColor];
    [self.tipLbBgView addSubview:self.tipLb1];

    self.tipLb2 = [[UILabel alloc] init];
    self.tipLb2.font = [UIFont systemFontOfSize:11];
    self.tipLb2.textAlignment = NSTextAlignmentCenter;
    self.tipLb2.layer.masksToBounds = YES;
    self.tipLb2.layer.cornerRadius = 5;
    self.tipLb2.backgroundColor = [UIColor clearColor];
    [self.tipLbBgView addSubview:self.tipLb2];

    self.gestureReceiveView = [[UIView alloc] init];
    self.gestureReceiveView.clipsToBounds = YES;
    [self.longview addSubview:self.gestureReceiveView];
    
    self.arrowBtn = [UIButton buttonWithType:0];
    [self.arrowBtn setImage:[UIImage imageNamed:@"保险箭头"] forState:0];
    [self.arrowBtn setImage:[UIImage imageNamed:@"保险打开箭头"] forState:UIControlStateSelected];

    [self.arrowBtn addTarget:self action:@selector(showAndhideview:) forControlEvents:UIControlEventTouchUpInside];
    [self.longview addSubview:self.arrowBtn];
}

- (void)tapTowebView
{
    [self.delegate tapTowebview];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    self.tipLb1.attributedText = attributedText;
    _tipLbW = [self.tipLb1 sizeThatFits:CGSizeMake(CGFLOAT_MAX,30)].width;

    CGFloat maxW = self.size.width-15-10-13-25;
    if(_tipLbW>maxW){
        self.tipLb2.attributedText = attributedText;
        _tipLbW = maxW;
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
        dispatch_source_set_timer(timer,dispatch_walltime(DISPATCH_TIME_NOW, NSEC_PER_SEC * 2), 0.2*NSEC_PER_SEC, 0);
        dispatch_source_set_event_handler(timer, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self changePos];
            });
        });
        dispatch_resume(timer);
    }
    else
    {
        if(timer!=nil)
        {
            dispatch_resume(timer);
            dispatch_source_cancel(timer);
            timer = nil;
        }
    }
    self.tipLbBgView.frame = CGRectMake(55, 0, _tipLbW, self.size.height);
    self.gestureReceiveView.frame = CGRectMake(55, 0, _tipLbW, self.size.height);

    self.longview.frame = CGRectMake(-30, 0, (55+_tipLbW+23), self.size.height);
    self.arrowBtn.frame = CGRectMake(self.longview.size.width - 10-13, 7 / 2, 13, 23);

    self.tipLb1.frame = CGRectMake(0, 0, 0, self.size.height);
    [self.tipLb1 sizeToFit];
    self.tipLb1.centerY = self.size.height/2.0;

    if(!IsStrEmpty(self.tipLb2.attributedText.string))
    {
        self.tipLb2.frame = CGRectMake(self.tipLb1.width+50, 0, 0, self.size.height);
        [self.tipLb2 sizeToFit];
        self.tipLb2.centerY = self.size.height/2.0;
    }
    self.hidden = NO;
}

- (void)createBezirePath:(CGRect)frame
{
    self.longview.layer.cornerRadius = frame.size.height / 2;
    self.tipLb1.userInteractionEnabled = YES;
    self.tipLb1.textColor = [UIColor whiteColor];
    self.tipLb2.userInteractionEnabled = YES;
    self.tipLb2.textColor = [UIColor whiteColor];
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTowebView)];
    //修复UBI弹条不跳转
    [self.gestureReceiveView addGestureRecognizer:self.tap];
}

- (void)showAndhideview:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
             self.longview.frame = CGRectMake(-30, 0, 48/2 + 30, 30);
             self.arrowBtn.frame = CGRectMake(35, 7 / 2, 13, 23);
         } completion:^(BOOL finished) {
         }];
    }else{
        [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
             self.longview.frame = CGRectMake(-30, 0, (55+_tipLbW+23), self.size.height);
             self.arrowBtn.frame = CGRectMake(self.longview.size.width - 10-13, 7 / 2, 13, 23);
         } completion:^(BOOL finished) {
         }];
    }
}

- (void)changePos
{
    CGPoint curPosLb1 = self.tipLb1.center;
    if(curPosLb1.x <  -(self.tipLb1.width/2.0) )
    {
        self.tipLb1.center = CGPointMake((CGRectGetMaxX(self.tipLb2.frame)+50+(self.tipLb1.width/2.0)), 15);
    }
    else
    {
        [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.tipLb1.center = CGPointMake(curPosLb1.x - 10, 15);
        } completion:^(BOOL finished) {
        }];
    }

    CGPoint curPosLb2 = self.tipLb2.center;
    if(curPosLb2.x <  -(self.tipLb2.width/2.0) )
    {
        self.tipLb2.center = CGPointMake((CGRectGetMaxX(self.tipLb1.frame)+50+(self.tipLb2.width/2.0)), 15);
    }
    else
    {
        [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.tipLb2.center = CGPointMake(curPosLb2.x - 10, 15);
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)dealloc
{
    if(timer!=nil)
    {
        dispatch_resume(timer);
        dispatch_source_cancel(timer);
        timer = nil;
    }
}

@end
