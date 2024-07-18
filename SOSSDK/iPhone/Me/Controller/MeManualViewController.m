//
//  MeManualViewController.m
//  Onstar
//
//  Created by Apple on 16/10/11.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "MeManualViewController.h"
#import "LoadingView.h"
 
#import "SOSCheckRoleUtil.h"
#import "CustomerInfo.h"

@interface MeManualViewController ()<WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSURL *url;

@end

@implementation MeManualViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.extendedLayoutIncludesOpaqueBars = YES;

    if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
        if ([SOSCheckRoleUtil isVisitor]) {
            //访客显示 Gen9 用户手册
            self.url = [NSURL URLWithString:gen9_Manual_URL];
        } else {
            if ([CustomerInfo sharedInstance].currentVehicle.gen10) {
                self.url = [NSURL URLWithString:gen10_Manual_URL];
            } else {
                self.url = [NSURL URLWithString:gen9_Manual_URL];
            }
        }
    } else {
        //未登录显示 Gen10 用户手册
        self.url = [NSURL URLWithString:gen9_Manual_URL];
    }

    [self.view addSubview:self.webView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self webLoadRequest];
}

- (WKWebView*)webView
{
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        _webView.navigationDelegate = self;
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.opaque = NO;
        [_webView addObserver:self
                   forKeyPath:@"title"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    }
    return _webView;
}

- (void)webLoadRequest
{
    [[LoadingView sharedInstance] startIn:self.view withNavigationBar:NO];
    NSString *HTTP_LOCALE_CHINESE  = @"zh";
    NSString *HTTP_LOCALE_ENGLISH = @"en";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
    [request addValue:NONil([LoginManage sharedInstance].accessToken) forHTTPHeaderField:@"Authorization"];
    [request setValue:[Util clientInfo] forHTTPHeaderField:@"CLIENT-INFO"];
    NSString *locale = HTTP_LOCALE_CHINESE;
    if ([[SOSLanguage getCurrentLanguage] isEqualToString:LANGUAGE_ENGLISH]) {
        locale = HTTP_LOCALE_ENGLISH;
    }
    [request addValue:locale forHTTPHeaderField:@"locale"];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    NSLog(@"H5加载URL: %@",request.URL);
    [_webView loadRequest:request];
    NSLog(@"H5加载Header: %@",request.allHTTPHeaderFields);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.webView.navigationDelegate = nil;
}

#pragma mark - webView delegate





-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    [[LoadingView sharedInstance] stop];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [[LoadingView sharedInstance] stop];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(title))]) {
        self.navigationItem.title = self.webView.title;
    }
}

@end
