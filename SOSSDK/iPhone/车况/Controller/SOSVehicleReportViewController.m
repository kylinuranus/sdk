//
//  SOSVehicleReportViewController.m
//  Onstar
//
//  Created by Genie Sun on 2017/7/28.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSVehicleReportViewController.h"

#import "LoadingView.h"
#import "ErrorPageVC.h"

@interface SOSVehicleReportViewController ()<ErrorBackDelegate,WKNavigationDelegate>
@property (strong, nonatomic)  WKWebView *webView;

@end

@implementation SOSVehicleReportViewController  {
//    __block NNOVDEmailDTO *ovdEmail;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"车况检测报告";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.backRecordFunctionID = CarConditions_OVD;
    self.backDaapFunctionID = OVD_back;
  
    [self setupUI];
   
    [self getOVDList];
    
}

-(void)setupUI{
    if (!self.webView) {
        self.webView = [[WKWebView alloc] init];
        self.webView.navigationDelegate = self;
        [self.view addSubview:self.webView];
        [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.mas_equalTo(self.view);
        }];
    }
}

- (void)getOVDList{
    [[LoadingView sharedInstance] startIn:self.view withNavigationBar:NO];
    NSString *url;
    url = [BASE_URL stringByAppendingFormat:NEW_OVD_EMAIL,[CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
   
    @weakify(self)
    SOSNetworkOperation * sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id returnData) {
        @strongify(self)
        NSLog(@"--------ovd email list response:%@",returnData);
            NSDictionary * result = [Util dictionaryWithJsonString:returnData];
            if (result) {
                if ([[result objectForKey:@"ovdEmailHtml"] isKindOfClass:[NSString class]]) {
                    if (((NSString *)[result objectForKey:@"ovdEmailHtml"]).isNotBlank) {
                        NSURL * url = [[NSURL alloc] initWithString:[result objectForKey:@"ovdEmailHtml"]];
                        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
                        return ;
                    }
                }
                [[LoadingView sharedInstance] stop];

                [self goErrorPage:NSLocalizedString(@"NO_OVD", nil)];
                
            }else{
                [[LoadingView sharedInstance] stop];

                [self goErrorPage:NSLocalizedString(@"NO_OVD", nil)];
            }
        
        
    
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[LoadingView sharedInstance] stop];
            //16-09-23，应要求将返还异常信息统一修改成了没有有效车况报告
            /**
             NNError *e = [NNError mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
             NSString *str =e.desc;
             [self goErrorPage:str];
             **/
            [self goErrorPage:NSLocalizedString(@"NO_OVD", nil)];
        });
    }];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}




- (void)goErrorPage:(NSString *)detail{
    ErrorPageVC *errorPage = [[ErrorPageVC alloc]initWithErrorPage:NSLocalizedString(@"assistantReportStatusTitle", @"") imageName:@"NO_OVD" detail:detail];
    errorPage.delegate = self;
    [errorPage.view setFrame:self.view.bounds];
    [self.view addSubview:errorPage.view];
}
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
    [[LoadingView sharedInstance] stop];

}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    NSLog(@"didFinishNavigation");
    [[LoadingView sharedInstance] stop];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error;
{
    NSLog(@"didFailNavigation");
    [[LoadingView sharedInstance] stop];
}
- (void)errorPageBackTapped{
    [SOSDaapManager sendActionInfo:OVD_back];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
