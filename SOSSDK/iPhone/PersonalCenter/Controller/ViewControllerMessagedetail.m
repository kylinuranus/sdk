
//
//  ViewControllerMessagedetail.m
//  Onstar
//
//  Created by Genie Sun on 16/1/21.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "ViewControllerMessagedetail.h"
 
#import "LoadingView.h"

@interface ViewControllerMessagedetail ()
@property (retain, nonatomic) WKWebView *webview;
@end

@implementation ViewControllerMessagedetail

- (void)viewDidLoad {
    [super viewDidLoad];

    _webview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
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
//    NSString *url = [NSString stringWithFormat:(@"%@" NEW_GET_CONTENT_DETAIL), BASE_URL, self.contentNUM,[Util getAppVersionCode],self.category];
    NSString *url = [BASE_URL stringByAppendingString:NEW_GET_CONTENT_DETAIL];
    NSDictionary *d = @{@"contentNUM":self.contentNUM,@"versionCode":[Util getAppVersionCode],@"category":self.category};
    NSString *s = [Util jsonFromDict:d];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:s successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        [self requestFinished:responseStr];
        [[LoadingView sharedInstance] stop];
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
        [[LoadingView sharedInstance] stop];
    }];
    [operation setHttpMethod:@"POST"];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation start];
}

- (void)requestFinished:(NSString *)responseString     {
    NSDictionary *dic = [Util dictionaryWithJsonString:responseString];
    NSString *bodyStr = [[dic objectForKey:@"content"] objectForKey:@"contentUrl"];
    NSURL *url = [NSURL URLWithString:bodyStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.webview loadRequest:request];
//     });
}


@end
