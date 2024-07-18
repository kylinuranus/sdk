//
//  SOSWebView.h
//  Onstar
//
//  Created by lizhipan on 17/2/10.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
typedef NS_ENUM(NSInteger, SOSWebViewNavigationType) {
    SOSWebViewNavigationTypeLinkClicked,
    SOSWebViewNavigationTypeFormSubmitted,
    SOSWebViewNavigationTypeBackForward,
    SOSWebViewNavigationTypeReload,
    SOSWebViewNavigationTypeFormResubmitted,
    SOSWebViewNavigationTypeOther
};

@class SOSWebView;
@protocol SOSWebViewDelegate <NSObject>
@optional
- (void)soswebView:(SOSWebView *)webview didFinishLoadingURL:(NSURL *)URL;
- (void)soswebView:(SOSWebView *)webview didFailToLoadURL:(NSURL *)URL error:(NSError *)error;
- (void)soswebView:(SOSWebView *)webview shouldStartLoadWithURL:(NSURLRequest *)request navigationType:(SOSWebViewNavigationType)navigationType;
- (void)soswebViewDidStartLoad:(SOSWebView *)webview;
@end


@interface SOSWebView : UIView<WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler,UIGestureRecognizerDelegate>
@property (nonatomic, weak) id <SOSWebViewDelegate> delegate;
@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, assign) BOOL canGoBack;
@property (nonatomic, copy) NSString *currentPage;
@property (strong,nonatomic) NSURL *currentURL; 

@property (copy, nonatomic) NSString *dealerName;//经销商名称
@property (copy, nonatomic) NSString *dealerCode;//经销商id

@property (nonatomic, strong) dispatch_semaphore_t signal;


/**
 注册js方法
 */
@property (nonatomic, assign) BOOL forceRegisterJSCore;

- (instancetype)initWithFrame:(CGRect)frame;
- (BOOL)getCurrentCanGoBack;
- (void)loadRequest:(NSURLRequest *)request;
- (void)loadURL:(NSURL *)URL;
- (void)loadURL:(NSURL *)URL shouldAddHeader:(BOOL)shouldAddHeader;
- (void)loadURLString:(NSString *)URLString;
- (void)loadHTMLString:(NSString *)HTMLString;
//baseUrl帮助寻找本地资源
- (void)loadHTMLString:(NSString *)HTMLString baseUrl:(NSString *)baseUrl;
- (void)goBack;
- (void)reload;


/// native调用js方法
/// @param script 方法
/// @param completionHandler 回调
- (void)stringByEvaluatingJavaScriptFromString:(NSString *)script completionHandler:(void (^)( id title, NSError * error))completionHandler;

- (UIScrollView *)getScrollViewOfWebview;
@end
