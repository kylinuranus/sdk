//
//  SOSLifeWebViewController.m
//  Onstar
//
//  Created by TaoLiang on 2019/1/9.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSLifeWebViewController.h"
#import "TLSOSRefreshHeader.h"
#import "SOSLifeJumpHelper.h"

@interface SOSLifeWebViewController ()

@end

@implementation SOSLifeWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.webView.wkWebView.scrollView.bounces = YES;
    self.webView.wkWebView.scrollView.mj_header = [TLSOSRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(reload)];
    self.webView.wkWebView.backgroundColor = [UIColor clearColor];
    self.webView.wkWebView.opaque = NO;
}

- (void)sendThirdFuncsToHTML:(NSString *)funcsJson {
    NSString *string = [NSString stringWithFormat:@"getQuickEntry('%@')", funcsJson];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{    
        [self.webView stringByEvaluatingJavaScriptFromString:string completionHandler:nil];
    });
}

- (void)sendUnreadNumToHTML:(NSInteger)unreadCount {
    NSString *string = [NSString stringWithFormat:@"getUnreadMsg('%@')", @(unreadCount)];
    [self.webView stringByEvaluatingJavaScriptFromString:string completionHandler:nil];
}

- (void)soswebViewDidStartLoad:(SOSWebView *)webview {
}

- (void)soswebView:(SOSWebView *)webview didFailToLoadURL:(NSURL *)URL error:(NSError *)error {
    [super soswebView:webview didFailToLoadURL:URL error:error];
    [[self.webView getScrollViewOfWebview].mj_header endRefreshing];
    if ([_delegate respondsToSelector:@selector(lifeWebViewControllerDidFailToLoadURL:)]) {
        [_delegate lifeWebViewControllerDidFailToLoadURL:URL];
    }

}

- (void)soswebView:(SOSWebView *)webview didFinishLoadingURL:(NSURL *)URL {
    [super soswebView:webview didFinishLoadingURL:URL];
    [[self.webView getScrollViewOfWebview].mj_header endRefreshing];
    if ([_delegate respondsToSelector:@selector(lifeWebViewControllerDidFinishLoadingURL:)]) {
        [_delegate lifeWebViewControllerDidFinishLoadingURL:URL];
    }
}

- (void)reload {
    [SOSDaapManager sendActionInfo:LIFE_REFRESH];
    [self.webView reload];
}

- (void)MA_8_1_goFunPage:(NSString *)para {
    if ([para isEqualToString:@"更多"]) {
        [SOSDaapManager sendActionInfo:LIFE_MORE];
        _editFuncs ? _editFuncs() : nil;
        return;
    }else if ([para isEqualToString:@"星友圈"]) {
        [SOSDaapManager sendActionInfo:LIFE_SOCIAL];
        SOSLifeJumpHelper *helper = [[SOSLifeJumpHelper alloc] initWithFromViewController:self];
        [helper jumpTo:para para:nil];
    }

    NSData *jsonData = [para dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&err];
    if (err) {
        return;
    }
    //这里MJExtension似乎有bug,转换para会丢失中文内容
    NNBanner *banner = [NNBanner mj_objectWithKeyValues:para];
    banner.title = dic[@"title"];
    NSString *key = banner.title;
    NSLog(@"goto  %@", key);
    SOSLifeJumpHelper *helper = [[SOSLifeJumpHelper alloc] initWithFromViewController:self];
    [helper jumpTo:key para:banner];
    
}


#pragma mark - Private



@end
