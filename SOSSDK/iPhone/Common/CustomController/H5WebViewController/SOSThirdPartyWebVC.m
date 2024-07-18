//
//  SOSThirdPartyWebVC.m
//  Onstar
//
//  Created by Coir on 2019/9/10.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSThirdPartyWebVC.h"
#import "LoadingView.h"

@interface SOSThirdPartyWebVC ()	<WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) NSURL *url;

@end

@implementation SOSThirdPartyWebVC

- (id)initWithUrl:(NSString *)url	{
    self = [super init];
    if (self) {
        self.url = [url mj_url];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = NO;
    __weak __typeof(self) weakSelf = self;
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) configuration:config];
    [self.view addSubview:self.wkWebView];
    [self.wkWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];

    [self setLeftBackBtnCallBack:^{
        if (weakSelf.wkWebView.canGoBack) {
            [weakSelf.wkWebView goBack];
        }	else	{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
    [[self.wkWebView rac_valuesAndChangesForKeyPath:@"loading" options:NSKeyValueObservingOptionNew observer:self] subscribeNext:^(RACTwoTuple<id,NSDictionary *> *x) {
        NSNumber *isLoading = x.first;
        if ([isLoading isKindOfClass:[NSNumber class]]) {
            if (isLoading.boolValue) {
                [Util showHUD];
            }	else	{
                [Util dismissHUD];
            }
        }
    }];
    self.wkWebView.UIDelegate = self;
    self.wkWebView.navigationDelegate = self;
    [self.wkWebView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

- (void)loadURL:(NSString *)url		{
    self.url = [NSURL URLWithString:url];
    [self.wkWebView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

#pragma mark - WK Navigation Delegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    self.url = webView.URL;
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.wkWebView evaluateJavaScript:@"document.title" completionHandler:^(id object, NSError * error) {
        if ([object isKindOfClass:[NSString class]]) {
            self.title = object;
        }
    }];
}

//提交发生错误时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"webView Load URL Error: %@", error);
}

// 接收到服务器跳转请求即服务重定向时之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
}

// 根据WebView对于即将跳转的HTTP请求头信息和相关信息来决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    //判断是返回操作
    if (navigationAction.navigationType==WKNavigationTypeBackForward) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }	else	{
        NSString *urlStr = navigationAction.request.URL.absoluteString;
        NSLog(@"发送跳转请求：%@",urlStr);
        if ([urlStr hasPrefix:@"tel:"]) {
            [SOSUtil callPhoneNumber:[urlStr substringFromIndex:@"tel:".length]];
            decisionHandler(WKNavigationActionPolicyCancel);
        }    else if ([urlStr hasPrefix:@"weixin://"])    {
            [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
            decisionHandler(WKNavigationActionPolicyCancel);
        }    else if ([urlStr hasPrefix:@"com.onstar.newlink://"])    {
            decisionHandler(WKNavigationActionPolicyCancel);
        }	else if ([urlStr hasPrefix:@"alipay://"])	{
            NSURL *alipayURL = [NSURL URLWithString:urlStr];
            
            [[UIApplication sharedApplication] openURL:alipayURL];
            decisionHandler(WKNavigationActionPolicyAllow);
        }	else  {
            decisionHandler(WKNavigationActionPolicyAllow);
        }
    }
}
    
// 根据客户端受到的服务器响应头以及response相关信息来决定是否可以跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSString * urlStr = navigationResponse.response.URL.absoluteString;
    NSLog(@"当前跳转地址：%@",urlStr);
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationResponsePolicyCancel);
}

/*
//需要响应身份验证时调用 同样在block中需要传入用户身份凭证
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    //用户身份信息
    NSURLCredential * newCred = [[NSURLCredential alloc] initWithUser:@"" password:@"" persistence:NSURLCredentialPersistenceNone];
    //为 challenge 的发送方提供 credential
    [challenge.sender useCredential:newCred forAuthenticationChallenge:challenge];
    completionHandler(NSURLSessionAuthChallengeUseCredential,newCred);
}*/

//进程被终止时调用
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
    [Util dismissHUD];
}

- (void)dealloc	{
    [Util dismissHUD];
}



@end
