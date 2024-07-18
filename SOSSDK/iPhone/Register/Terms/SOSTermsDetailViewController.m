//
//  SOSTermsDetailViewController.m
//  Onstar
//
//  Created by Onstar on 2020/2/13.
//  Copyright © 2020 Shanghai Onstar. All rights reserved.
//

#import "SOSTermsDetailViewController.h"

@interface SOSTermsDetailViewController ()<WKNavigationDelegate>
@property(nonatomic,strong)WKWebView * web ;
@end

@implementation SOSTermsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.agreement.docTitle;
    // Do any additional setup after loading the view.
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    wkWebConfig.userContentController = wkUController;
    // 自适应屏幕宽度js

    NSString *jSString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";

    WKUserScript *wkUserScript = [[WKUserScript alloc] initWithSource:jSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];

    // 添加自适应屏幕宽度js调用的方法

    [wkUController addUserScript:wkUserScript];

    _web = [[WKWebView alloc] initWithFrame:CGRectZero configuration:wkWebConfig];
    _web.navigationDelegate = self;
    _web.contentScaleFactor = 1;
    [self.view addSubview:_web];
    [_web mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    if (self.agreement) {
        NSString *urlString = self.agreement.url;
        [_web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if ([webView.URL.absoluteString.lowercaseString containsString:@"gspServer".lowercaseString]) {
        NSString *pStr = @"var objs = document.getElementsByTagName('p');\n"
        "for(var i=0; i<objs.length; i++) {\n"
        "objs[i].style.setProperty('font-size','15px','important');objs[i].style.margin = 15;} \n";
        [webView evaluateJavaScript:pStr completionHandler:nil];
    }
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
