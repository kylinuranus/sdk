
//
//  ViewControllerMessagedetail.m
//  Onstar
//
//  Created by Genie Sun on 16/1/21.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "ViewControllerContentDetail.h"
 
#import "LoadingView.h"
#import "ContentUtil.h"

@interface ViewControllerContentDetail ()<WKNavigationDelegate>
@property (retain, nonatomic) WKWebView *webview;
@end

@implementation ViewControllerContentDetail
@synthesize category;

- (void)viewDidLoad {
    [super viewDidLoad];

    _webview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    _webview.navigationDelegate = self;
    [self.view addSubview:_webview];

    if ([self.category isEqualToString:STORY_CALL_ME]) {
        self.title = NSLocalizedString(@"True_Story", nil);
    }else if ([self.category isEqualToString:ASSISTANT_CALL_ME]){
        self.title = NSLocalizedString(@"Operation_Tips", nil);
    }else if ([self.category isEqualToString:ABOUT_INTRODUCTION]){
        self.title = NSLocalizedString(@"Onstar_service_introduction", nil);
    }else if([self.category isEqualToString:BUICK_CARE_JPFW]){
        self.title = NSLocalizedString(@"assistantBuickCareBestService", nil);
    }else if([self.category isEqualToString:BUICK_CARE_HDXX]){
        self.title = NSLocalizedString(@"assistantBuickCareActivities", nil);
    }else if([self.category isEqualToString:BUICK_CARE_YCTS]){
        self.title = NSLocalizedString(@"assistantBuickCareVehicleCareTips", nil);
    }

    [[LoadingView sharedInstance] startIn:self.view];
    
    [ContentUtil getContentDetailByCategory:self.category num:self.contentNUM Success:^(NNContentDeatil *response) {
        NSString *bodyStr = response.content.contentUrl;
        NSURL *url = [NSURL URLWithString:bodyStr];

//        NSURLRequest *request = [NSURLRequest requestWithURL:url];
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            [self.webview loadRequest:request];
//        });

        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString *strUrl = [[NSString alloc]initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.webview loadHTMLString:strUrl baseURL:nil];
            });
        });
    } Failed:^{
        
    }];

}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

@end
