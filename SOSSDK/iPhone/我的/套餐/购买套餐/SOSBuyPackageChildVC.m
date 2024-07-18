//
//  SOSBuyPackageChildVC.m
//  Onstar
//
//  Created by Coir on 7/9/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSBuyPackageChildVC.h"
#import "SOSPackageInfoView.h"

@interface SOSBuyPackageChildVC ()  <UIScrollViewDelegate>   {
    
    __weak IBOutlet UIScrollView *contentScrollView;
    __weak IBOutlet UIView *packageInfoBGView;
    WKWebView *contentWebView;
    
    __weak IBOutlet UIView *webViewBGView;
    SOSPackageInfoView *packageInfoView;
//    __weak IBOutlet NSLayoutConstraint *webViewConst;
    
//    __weak IBOutlet NSLayoutConstraint *webViewConst;
}

@end

@implementation SOSBuyPackageChildVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configSelf];
}

- (void)configSelf  {
//    webViewConst.constant = SCREEN_WIDTH;
    packageInfoView = [[NSBundle SOSBundle] loadNibNamed:@"SOSPackageInfoView" owner:nil options:nil][0];
    packageInfoView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 170);
    packageInfoView.package = self.selectedPackage;
    [packageInfoBGView addSubview:packageInfoView];
    
    contentWebView = [[WKWebView alloc] initWithFrame:webViewBGView.bounds];
    
    [webViewBGView addSubview:contentWebView];
    [contentWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(webViewBGView);
    }];
    contentWebView.scrollView.scrollEnabled = NO;
    contentWebView.scrollView.bounces = YES;
    contentWebView.scrollView.delegate = self;
    contentWebView.scrollView.alwaysBounceVertical = YES;
    contentWebView.scrollView.alwaysBounceHorizontal = NO;
    contentWebView.backgroundColor = [UIColor clearColor];
    contentWebView.opaque = NO;
    [contentWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.selectedPackage.descUrl]]];
}

- (void)setSelectedPackage:(PackageInfos *)selectedPackage    {
    if (!selectedPackage.descUrl.isNotBlank) {
        [contentWebView loadHTMLString:@"" baseURL:nil];
    }else {
        if (![selectedPackage.descUrl isEqualToString:_selectedPackage.descUrl]) {
            [contentWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:selectedPackage.descUrl]]];
        }
    }
    _selectedPackage = selectedPackage;
    packageInfoView.package = selectedPackage;
    
}

- (void)viewWillAppear:(BOOL)animated   {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - ScrollView & WebView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView  {
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate    {
    if (scrollView == contentScrollView) {
        if (scrollView.contentOffset.y >= packageInfoBGView.height / 2) {
            [contentScrollView setContentOffset:CGPointMake(0, packageInfoBGView.bottom) animated:YES];
            contentWebView.scrollView.scrollEnabled = YES;
            contentScrollView.scrollEnabled = NO;
        }   else    {
            [contentScrollView scrollToTopAnimated:YES];
            contentWebView.scrollView.scrollEnabled = NO;
            contentScrollView.scrollEnabled = YES;
        }
    }   else if (scrollView == contentWebView.scrollView)    {
        if (scrollView.contentOffset.y <= 0) {
            [contentScrollView scrollToTopAnimated:YES];
            contentWebView.scrollView.scrollEnabled = NO;
            contentScrollView.scrollEnabled = YES;
        }   else    {
            
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView     {
    if (scrollView == contentScrollView) {
        if (scrollView.contentOffset.y >= packageInfoBGView.height / 2) {
            [contentScrollView setContentOffset:CGPointMake(0, packageInfoBGView.bottom) animated:YES];
            contentWebView.scrollView.scrollEnabled = YES;
            contentScrollView.scrollEnabled = NO;
        }   else    {
            [contentScrollView scrollToTopAnimated:YES];
            contentWebView.scrollView.scrollEnabled = NO;
            contentScrollView.scrollEnabled = YES;
        }
    }
}

- (void)dealloc		{
    contentWebView.scrollView.delegate = nil;
}

@end
