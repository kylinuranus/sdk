//
//  SOSAlertView.m
//  Onstar
//
//  Created by Genie Sun on 16/6/29.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "SOSAlertView.h"
#import "LoadingView.h"
#if __has_include("SOSSDK.h")
#import "SOSExtension.h"
#endif

#define kColorNormal   [UIColor colorWithHexString:@"1d81dd"]
#define kColorCancel   [UIColor colorWithHexString:@"131329"]

@interface SOSAlertView()<WKNavigationDelegate>

@end

@implementation SOSAlertView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame])		{
        CGFloat margin = 20.f;
        CGFloat width = SCREEN_WIDTH * 0.8;
        CGFloat titleH = 20.f;
        CGFloat btnH = 45.f;
        CGFloat height = SCREEN_HEIGHT *0.56;
        CGFloat middleH = height - margin - titleH - 10. - btnH;
        
        CGFloat x = (SCREEN_WIDTH-width)/2.0;
        CGFloat y = (SCREEN_HEIGHT-height)/2.0;

        self.frame = CGRectMake(x, y, width, height);
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 8.f;
        self.layer.masksToBounds = YES;

        self.titleLabel.frame = CGRectMake(0, margin, width, titleH);
        self.cancelButton.frame = CGRectMake(0, height-45.f, self.width/2.f, btnH);
        self.completeBtn.frame = CGRectMake(self.width/2.f, height-45.f, self.width/2.f, btnH);
        self.sosWebView.frame = CGRectMake(0, titleH+margin+10.f, width, middleH);

        [self addSubview:self.titleLabel];
        [self addSubview:self.completeBtn];
        [self addSubview:self.cancelButton];
        [self addSubview:self.sosWebView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_isTCPSAlert) {
        [_cancelButton removeFromSuperview];
        [_completeBtn setFrame:CGRectMake(0, _completeBtn.frame.origin.y, self.width, _completeBtn.frame.size.height)];
    }	else	[_cancelButton setTitle:self.cancelStr forState:UIControlStateNormal];
    
    [_completeBtn setTitle:self.submitStr forState:UIControlStateNormal];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (WKWebView *)sosWebView	{
    if (!_sosWebView) {
        _sosWebView = [[WKWebView alloc] init];
        _sosWebView.backgroundColor = [UIColor whiteColor];
        _sosWebView.navigationDelegate = self;
        _sosWebView.opaque = NO;
        [_sosWebView addObserver:self
                     forKeyPath:@"title"
                        options:NSKeyValueObservingOptionNew
                        context:nil];
    }
    return _sosWebView;
}

- (void)loadURL_No_header:(NSString *)strURL     {
    [[LoadingView sharedInstance] startIn:self withNavigationBar:NO];
    NSURL *url = [NSURL URLWithString:strURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.sosWebView loadRequest:request];
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:[[UIApplication sharedApplication].windows lastObject].bounds];
        _maskView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.400];
        _maskView.alpha = 0.f;
    }
    return _maskView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = kColorCancel;
        _titleLabel.font = [UIFont systemFontOfSize:15.f];
    }
    return _titleLabel;
}

- (UIButton *)completeBtn {
    if (!_completeBtn) {
        _completeBtn = [UIButton buttonWithType:0];
        [_completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_completeBtn setBackgroundColor:kColorNormal forState:0];
        [_completeBtn.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
        [_completeBtn addTarget:self action:@selector(complete:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _completeBtn;
}

- (UIButton *) cancelButton	{
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:0];
        [_cancelButton setTitleColor:kColorCancel forState:UIControlStateNormal];
        [_cancelButton.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
        [_cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

#pragma mark - showAlertView
- (void)showAlertView {
    UIWindow *keyWindow = SOS_ONSTAR_WINDOW;
    [keyWindow addSubview:self.maskView];
    [keyWindow addSubview:self];
    self.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    [UIView animateWithDuration:0.25 animations:^{
        self.maskView.alpha = 1.f;
        self.alpha = 1.f;
        self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    } completion:^(BOOL finished) {

    }];
}

#pragma mark - dismissAlertView
- (void)dismissAlertView {
    
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0.f;
        self.maskView.alpha = 0.f;
        self.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    }completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
            [self.maskView removeFromSuperview];
        }
    }];
}

#pragma mark - complete
- (void)complete:(id)sender {
    if (_agreeAction) {
        _agreeAction(YES);
    }
    [self dismissAlertView];
}

#pragma mark - cancel
- (void)cancel:(id)sender {
    if (_agreeAction) 	_agreeAction(NO);
    [self dismissAlertView];
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [[LoadingView sharedInstance] stop];

}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(title))]) {
        
        NSString *title  = NSLocalizedString(@"AgreeOnstar", nil);
        if (_isTCPSAlert && object == self.sosWebView && ![Util isBlankString:self.sosWebView.title]) {
            title  = self.sosWebView.title;
        }
        self.title = title;
    }
}

-(void)dealloc{
    
    [_sosWebView removeObserver:self forKeyPath:@"title"];
}

@end
