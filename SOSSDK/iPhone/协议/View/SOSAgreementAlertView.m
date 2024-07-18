//
//  SOSAgreementAlertView.m
//  Onstar
//
//  Created by TaoLiang on 20/04/2018.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSAgreementAlertView.h"
#import "SOSAgreementAlertTopView.h"


@interface SOSAgreementAlertView ()<WKNavigationDelegate>
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) SOSAgreementAlertTopView *topView;
@property (strong, nonatomic) UIView *bottomView;

@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) WKWebView *webView;


@end

@implementation SOSAgreementAlertView

- (instancetype)initWithAlertViewStyle:(SOSAgreementAlertViewStyle)alertStyle {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _backgroundView = [UIView new];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 0.5;
        [self addSubview:_backgroundView];
        [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make){
            make.edges.equalTo(self);
        }];
        
        _containerView = [UIView new];
        _containerView.width = kAgreementContainerWidth;
        _containerView.backgroundColor = [UIColor whiteColor];
        _containerView.layer.cornerRadius = 10;
        _containerView.layer.masksToBounds = YES;
        [self addSubview:_containerView];
        [_containerView mas_makeConstraints:^(MASConstraintMaker *make){
            make.center.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(kAgreementContainerWidth, SCREEN_HEIGHT * 0.7));
        }];
        
        _topView = [[SOSAgreementAlertTopView alloc] initWithFrame:CGRectMake(0, 0, kAgreementContainerWidth, 0)];
        __weak __typeof(self)weakSelf = self;
        _topView.select = ^(NSUInteger index) {
            SOSAgreement *agreement = weakSelf.agreements[index];
            weakSelf.titleLabel.text = agreement.docTitle;
            NSString *urlString = agreement.url;
            [weakSelf.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
        };
        
        [_containerView addSubview:_topView];
        [_topView mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.top.right.equalTo(_containerView);
        }];
        
        _titleLabel = [UILabel new];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [_containerView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(_topView.mas_bottom).offset(15);
            make.left.right.equalTo(_containerView);
        }];
        
        WKUserContentController *wkUController = [[WKUserContentController alloc] init];
        WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
        wkWebConfig.userContentController = wkUController;
        // 自适应屏幕宽度js
        NSString *jSString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
        WKUserScript *wkUserScript = [[WKUserScript alloc] initWithSource:jSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [wkUController addUserScript:wkUserScript];
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:wkWebConfig];
        _webView.navigationDelegate = self;
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.opaque = NO;
//        _webView.scalesPageToFit = YES;
        [_containerView addSubview:_webView];
        [_webView mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.right.equalTo(_containerView);
            make.top.equalTo(_titleLabel.mas_bottom).offset(10);
        }];
        
        _bottomView = [UIView new];
        [_containerView addSubview:_bottomView];
        [_bottomView mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.bottom.right.equalTo(_containerView);
            make.top.equalTo(_webView.mas_bottom);
            make.height.mas_equalTo(50);
        }];
        
        self.alertStyle = alertStyle;

    }
    return self;
}

- (void)setAlertStyle:(SOSAgreementAlertViewStyle)alertStyle {
    _alertStyle = alertStyle;
    switch (alertStyle) {
        case SOSAgreementAlertViewStyleLogin:
        case SOSAgreementAlertViewStyleRVM:
        {
            UIButton *disagreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            if (_alertStyle ==SOSAgreementAlertViewStyleLogin) {
                [disagreeBtn setTitle:@"不同意" forState:UIControlStateNormal];

                 [disagreeBtn setBackgroundColor:[UIColor colorWithRed:0.055 green:0.498 blue:0.878 alpha:1.000]];
                disagreeBtn.tintColor = [UIColor whiteColor];

            }else{
                [disagreeBtn setTitle:@"再想想" forState:UIControlStateNormal];
                [disagreeBtn setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]];
                [disagreeBtn setTitleColor:[UIColor colorWithRed:164/255.0 green:164/255.0 blue:164/255.0 alpha:1.0] forState:0];
            }
            
          
            [disagreeBtn addTarget:self action:@selector(disagreeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [_bottomView addSubview:disagreeBtn];
            [disagreeBtn mas_makeConstraints:^(MASConstraintMaker *make){
                make.left.top.bottom.equalTo(_bottomView);
                make.width.equalTo(_bottomView.mas_width).dividedBy(2).offset(-.5);
            }];
            
            UIButton *agreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [agreeBtn setTitle:@"同意" forState:UIControlStateNormal];

            agreeBtn.tintColor = [UIColor whiteColor];
            if (_alertStyle ==SOSAgreementAlertViewStyleLogin) {
                [agreeBtn setBackgroundColor:[UIColor colorWithRed:0.055 green:0.498 blue:0.878 alpha:1.000]];

            }else{
                [agreeBtn setBackgroundColor:[UIColor whiteColor]];
                [agreeBtn setTitleColor:[UIColor colorWithRed:104/255.0 green:150/255.0 blue:237/255.0 alpha:1.0] forState:0];


            }
            [agreeBtn addTarget:self action:@selector(agreeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [_containerView addSubview:agreeBtn];
            [agreeBtn mas_makeConstraints:^(MASConstraintMaker *make){
                make.right.top.bottom.equalTo(_bottomView);
                make.width.equalTo(_bottomView.mas_width).dividedBy(2).offset(-.5);
            }];
            break;
        }
        case SOSAgreementAlertViewStyleSignUp: {
            UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
            confirmButton.tintColor = [UIColor whiteColor];
            [confirmButton setTitle:@"确认" forState:UIControlStateNormal];
            [confirmButton setBackgroundColor:[UIColor whiteColor]];
            [confirmButton setTitleColor:[UIColor colorWithRed:104/255.0 green:150/255.0 blue:237/255.0 alpha:1.0] forState:0];
            [confirmButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
            [_bottomView addSubview:confirmButton];
            [confirmButton mas_makeConstraints:^(MASConstraintMaker *make){
                make.edges.equalTo(_bottomView);
            }];

            break;
        }
            
        default:
            break;
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [self initWithAlertViewStyle:SOSAgreementAlertViewStyleLogin];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [self initWithAlertViewStyle:SOSAgreementAlertViewStyleLogin];
    if (self) {
        
    }
    return self;
}

- (void)setAgreements:(NSArray<SOSAgreement *> *)agreements {
    _agreements = agreements;
    [_topView mas_updateConstraints:^(MASConstraintMaker *make){
        if (agreements.count > 1) {
            make.height.mas_equalTo(32);
        }else {
            make.height.mas_equalTo(0);
        }
    }];
    _topView.agreements = agreements;


}


- (void)show {
    UIWindow * keyWindow = SOS_ONSTAR_WINDOW;
    [self showInView:keyWindow];
}

- (void)showInView:(__kindof UIView *)parentView {
    [parentView addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(parentView);
    }];
    [self layoutIfNeeded];
    _containerView.layer.affineTransform = CGAffineTransformMakeScale(0.9, 0.9);
    self.alpha = 0.f;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
        _containerView.layer.affineTransform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)hide {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)agreeBtnClicked {
    [self hide];
    if (_agree) {
        _agree();
    }
}

- (void)disagreeBtnClicked {
    [self hide];
    if (_disagree) {
        _disagree();
    }
}

#pragma web view delegate

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    if ([webView.URL.absoluteString.lowercaseString containsString:@"gspServer".lowercaseString]) {
        NSString *pStr = @"var objs = document.getElementsByTagName('p');\n"
        "for(var i=0; i<objs.length; i++) {\n"
        "objs[i].style.setProperty('font-size','15px','important');objs[i].style.margin = 15;} \n";
        [webView evaluateJavaScript:pStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            
        }];
    }
}

@end
