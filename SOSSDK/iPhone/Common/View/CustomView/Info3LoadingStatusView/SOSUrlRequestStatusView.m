//
//  SOSUrlRequestStatusView.m
//  Onstar
//
//  Created by lizhipan on 17/1/5.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSUrlRequestStatusView.h"

@implementation SOSUrlRequestStatusView
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initBaseView];
    }
    return self;
}
- (void)initBaseView
{
    _retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_retryButton setTitle:@"重试" forState:UIControlStateNormal];
    [_retryButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [_retryButton setBackgroundImage:[UIImage imageNamed:@"retrybackground"] forState:UIControlStateNormal];
    [_retryButton setFrame:CGRectMake(10, (self.frame.size.height - 20.0)/2,40,20)];
    _retryButton.hidden = YES;
    [_retryButton addTarget:self action:@selector(redoAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_retryButton];
    
    _activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_activity setFrame:CGRectMake(0, 0,20,20)];
    _activity.center = _retryButton.center;
    _activity.hidesWhenStopped = YES;
    [self addSubview:_activity];
    
    _clearTextButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [_clearTextButton setFrame:CGRectMake(self.frame.size.width - 25, (self.frame.size.height - 20.0)/2,20,20)];
    [_clearTextButton setImage:[UIImage imageNamed:@"清除icon"] forState:UIControlStateNormal];
    _clearTextButton.hidden = YES;
    _clearButtonVisiable = NO;
    [_clearTextButton addTarget:self action:@selector(clearText) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_clearTextButton];
}
- (void)startAnimation
{
    [_activity startAnimating];
    _retryButton.hidden = YES;
}
- (void)stopAnimation
{
    [_activity stopAnimating];
    _retryButton.hidden = NO;
}
- (void)resetRequestStatus
{
    if (_activity.isAnimating) {
        [_activity stopAnimating];
    }
    if (!_retryButton.hidden) {
        _retryButton.hidden = YES;
    }
}
- (void)clearText
{
    if (_clearField) {
        [_clearField setText:@""];
    }
    [self hideClearButton];
}

- (void)hideClearButton
{
    _clearButtonVisiable = NO;
    [_clearTextButton setHidden:YES];
    [self resetRequestStatus];
}

- (void)showClearButton
{
    _clearButtonVisiable = YES;
    [_clearTextButton setHidden:NO];
}

- (void)redoAction
{
    _redoBlock();
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)dealloc
{
    NSLog(@"=======SOSUrlRequestStatusView====Needdealloc====");
}
@end
