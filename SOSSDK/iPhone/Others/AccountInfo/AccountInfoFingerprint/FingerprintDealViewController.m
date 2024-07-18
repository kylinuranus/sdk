//
//  FingerprintDealViewController.m
//  Onstar
//
//  Created by Apple on 15/7/14.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import "FingerprintDealViewController.h"
#import "SOSAgreement.h"
#import "AppPreferences.h"
#import "SOSBiometricsManager.h"


@interface FingerprintDealViewController ()<WKNavigationDelegate>
@property (strong, nonatomic) WKWebView *myWebView;
@end

@implementation FingerprintDealViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [SOSBiometricsManager isSupportFaceId] ? @"面容服务协议" : @"指纹服务协议";
    self.myWebView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    self.myWebView.navigationDelegate = self;
    self.myWebView.backgroundColor = [UIColor whiteColor];
    self.myWebView.opaque = NO;
//    self.myWebView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0);
    [self.view addSubview:self.myWebView];
    [_myWebView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self.view);
    }];

    
    for (UIView *subView in [self.myWebView subviews]) {
        if ([subView isKindOfClass:[UIScrollView class]]) {
            for (UIView *shadowView in [subView subviews]) {
                if ([shadowView isKindOfClass:[UIImageView class]]) {
                    shadowView.hidden = YES;
                }
            }
        }
    }
    NSString *agreementType = [SOSBiometricsManager isSupportFaceId] ? agreementName(ONSTAR_FACE_TC) : agreementName(ONSTAR_FINGERPRINT_TC);
    [Util showLoadingView];
    [SOSAgreement requestAgreementsWithTypes:@[agreementType] success:^(NSDictionary *response) {
        [Util hideLoadView];
        NSDictionary *dic = response[agreementType];
        SOSAgreement *agreement = [SOSAgreement mj_objectWithKeyValues:dic];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:agreement.url]];
        [self.myWebView loadRequest:request];

    } fail:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util hideLoadView];
        [Util toastWithMessage:@"获取协议内容失败"];

    }];

}

@end
