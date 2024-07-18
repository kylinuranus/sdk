//
//  SOSWebView.m
//  Onstar
//
//  Created by lizhipan on 17/2/10.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSWebView.h"
#import "SOSWebViewController.h"
#ifdef SOSSDK_SDK
#import <SOSSDK/SOSPay.h>
#endif

#import "AppDelegate_iPhone+SOSOpenUrl.h"
#import "UIViewController+errorPage.h"

#import "NavigateShareTool.h"
#import "SOSCustomAlertView.h"
#import "WeiXinManager.h"
#import "SOSPhotoLibrary.h"
#import "SOSFlexibleAlertController.h"
#import "SOSHomeAndCompanyTool.h"
#import "UIImageView+WebCache.h"
#import "SOSCardUtil.h"
#import "SOSLoginDbService.h"
#import "SOSWeakScriptDelegate.h"

#define messageNameIsEq

@interface SOSWebView()
@property (nonatomic, strong) WKUserContentController *userContentController;
@end

@implementation SOSWebView

#pragma mark ---初始化
- (instancetype)initWithFrame:(CGRect)frame	{
    _currentPage = @"";
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.wkWebView];
        [self.wkWebView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    return self;
}

#pragma mark---支持多手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer	{
    return YES;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)sender	{
    if (sender.state != UIGestureRecognizerStateBegan)         return;
    CGPoint touchPoint = [sender locationInView:self];
    // 获取长按位置对应的图片url的JS代码
    NSString *imgJS = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y-64];
    // 执行对应的JS代码 获取url
    [self stringByEvaluatingJavaScriptFromString:imgJS completionHandler:^(id _Nullable imgUrl, NSError * _Nullable error) {
        if (imgUrl) {
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]];
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:nil title:nil message:nil customView:nil preferredStyle:SOSAlertControllerStyleActionSheet];
                SOSAlertAction *ac0 = [SOSAlertAction actionWithTitle:@"保存图片" style:SOSAlertActionStyleActionSheetDefault handler:^(SOSAlertAction * _Nonnull action) {
                    [SOSPhotoLibrary saveImage:image assetCollectionName:nil callback:^(BOOL suc) {
//                        if (!suc) {
//                            [Util showAlertWithTitle:@"保存图片失败!" message:nil completeBlock:nil];
//                        }else {
//                            [Util toastWithMessage:@"保存成功!"];
//                        }
                    }];
                }];
                SOSAlertAction *acCancel = [SOSAlertAction actionWithTitle:@"取消" style:SOSAlertActionStyleCancel handler:nil];
                [vc addActions:@[ac0, acCancel]];
                [vc show];
            }
        }
    } ];
}

#pragma mark ---WKWebViewJavascriptBridge 注册js调用方法***********************
- (WKWebViewConfiguration *)getWebViewConfignation	{
    WKWebViewConfiguration *configuretion = [[WKWebViewConfiguration alloc] init];
    configuretion.preferences.javaScriptEnabled = true;
    configuretion.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    configuretion.userContentController = [[WKUserContentController alloc] init];

    self.userContentController = [[WKUserContentController alloc] init];
    configuretion.userContentController = self.userContentController;
//    self.userContentController = configuretion.userContentController;
    [self registWKBridgeMethos];
    return configuretion;
}

-(void)registWKBridgeMethos{
    

    SOSWeakScriptDelegate *delegte =[[SOSWeakScriptDelegate alloc] initWithDelegate:self];
    
    [self.userContentController  addScriptMessageHandler:delegte name:method_onstarOpenCalendar];
    [self.userContentController  addScriptMessageHandler:delegte name:method_onstarGetToken];
    [self.userContentController  addScriptMessageHandler:delegte name:method_getAppInfo];
    [self.userContentController  addScriptMessageHandler:delegte name:method_close];
    [self.userContentController  addScriptMessageHandler:delegte name:method_getShareUrl];
    [self.userContentController  addScriptMessageHandler:delegte name:method_goHomePage];
    [self.userContentController  addScriptMessageHandler:delegte name:method_onstarOpenCamera];
    [self.userContentController  addScriptMessageHandler:delegte name:method_query];
    [self.userContentController  addScriptMessageHandler:delegte name:method_showDemoShare];
    [self.userContentController  addScriptMessageHandler:delegte name:method_screenshotShare];
    [self.userContentController  addScriptMessageHandler:delegte name:method_hideShareBtn];
    [self.userContentController  addScriptMessageHandler:delegte name:method_shareImage];
    [self.userContentController  addScriptMessageHandler:delegte name:method_goSettingPage];
    [self.userContentController  addScriptMessageHandler:delegte name:method_buyDataPackage];
    [self.userContentController  addScriptMessageHandler:delegte name:method_buyOnstarPackage];
    [self.userContentController  addScriptMessageHandler:delegte name:method_goRemotePage];
    [self.userContentController  addScriptMessageHandler:delegte name:method_goToLoginPage];
    [self.userContentController  addScriptMessageHandler:delegte name:method_setTitle];
    [self.userContentController  addScriptMessageHandler:delegte name:method_showLoading];
    [self.userContentController  addScriptMessageHandler:delegte name:method_toggleAppLoadingForH5];
    [self.userContentController  addScriptMessageHandler:delegte name:method_closeLoading];
    [self.userContentController  addScriptMessageHandler:delegte name:method_registRightBtn];
    [self.userContentController  addScriptMessageHandler:delegte name:method_showLoadingFail];
    [self.userContentController  addScriptMessageHandler:delegte name:method_chooseOnStarImage];
    [self.userContentController  addScriptMessageHandler:delegte name:method_chooseNativeImage];
    [self.userContentController  addScriptMessageHandler:delegte name:method_getPoiId];
    [self.userContentController  addScriptMessageHandler:delegte name:method_refreshFootprint];
    [self.userContentController  addScriptMessageHandler:delegte name:method_goFunPage];
    [self.userContentController  addScriptMessageHandler:delegte name:method_sendClientForH5];
    [self.userContentController  addScriptMessageHandler:delegte name:method_sendClientBannerForH5];
    [self.userContentController  addScriptMessageHandler:delegte name:method_sendClientDurationForH5];
    [self.userContentController  addScriptMessageHandler:delegte name:method_shareLinkForH5];
    [self.userContentController  addScriptMessageHandler:delegte name:method_shareUrlForH5];
    [self.userContentController  addScriptMessageHandler:delegte name:method_showheaderForH5];
    [self.userContentController  addScriptMessageHandler:delegte name:method_coverBottomSafeArea];
    [self.userContentController  addScriptMessageHandler:delegte name:method_changePlateNumber];
    [self.userContentController  addScriptMessageHandler:delegte name:method_carMsgForH5];
    [self.userContentController  addScriptMessageHandler:delegte name:method_getUserInfoForH5];
    [self.userContentController  addScriptMessageHandler:delegte name:method_getUserIdForH5];
    [self.userContentController  addScriptMessageHandler:delegte name:method_userinfoGo];
    [self.userContentController  addScriptMessageHandler:delegte name:method_screencutForh5];
    [self.userContentController  addScriptMessageHandler:delegte name:method_webviewBack];
    [self.userContentController  addScriptMessageHandler:delegte name:method_screenCutShare];
    [self.userContentController  addScriptMessageHandler:delegte name:method_goshareSetPoint];
    [self.userContentController  addScriptMessageHandler:delegte name:method_screencutOtherPage];
    [self.userContentController  addScriptMessageHandler:delegte name:method_callAlertForH5];
    [self.userContentController  addScriptMessageHandler:delegte name:method_getVehicleCondition];
    [self.userContentController  addScriptMessageHandler:delegte name:method_finishShowReport];
    [self.userContentController  addScriptMessageHandler:delegte name:method_H5_IS_READY];
    [self.userContentController  addScriptMessageHandler:delegte name:method_showToastForH5];
    [self.userContentController  addScriptMessageHandler:delegte name:method_dissmissToast];
    [self.userContentController  addScriptMessageHandler:delegte name:method_showDialog];
    [self.userContentController  addScriptMessageHandler:delegte name:method_showForumShare];
    [self.userContentController  addScriptMessageHandler:delegte name:method_goNewPage];
    [self.userContentController  addScriptMessageHandler:delegte name:method_goBannerPage];
    [self.userContentController  addScriptMessageHandler:delegte name:method_checkUserForH5];
    [self.userContentController  addScriptMessageHandler:delegte name:method_goUbiPage];
    [self.userContentController  addScriptMessageHandler:delegte name:method_showShareToast];
    [self.userContentController  addScriptMessageHandler:delegte name:method_toSettingCompanyAddressPage];
    [self.userContentController  addScriptMessageHandler:delegte name:method_savePictureForH5];
    /* ****************   自驾游二期添加   **************** */
    [self.userContentController  addScriptMessageHandler:delegte name:method_createfriendGroupForH5];
    [self.userContentController  addScriptMessageHandler:delegte name:method_enterfriendGroupForH5];
    [self.userContentController  addScriptMessageHandler:delegte name:method_shiftInfriendGroupMemberForH5];
    [self.userContentController  addScriptMessageHandler:delegte name:method_removefriendGroupMemberForH5];
    [self.userContentController  addScriptMessageHandler:delegte name:method_joinfriendGroupForH5];
    [self.userContentController  addScriptMessageHandler:delegte name:method_contactFriendsForH5];
    [self.userContentController  addScriptMessageHandler:delegte name:method_enterPartyTeamForH5];
    [self.userContentController  addScriptMessageHandler:delegte name:method_toDestinationPageForH5];
    [self.userContentController  addScriptMessageHandler:delegte name:method_rotatePictureForH5];
    [self.userContentController  addScriptMessageHandler:delegte name:method_quitTeamForH5];
    //论坛二期个人主页功能
    [self.userContentController  addScriptMessageHandler:delegte name:method_isMyFriendForH5];
    [self.userContentController  addScriptMessageHandler:delegte name:method_addFriendForH5];
    [self.userContentController  addScriptMessageHandler:delegte name:method_startP2PMessageViewForH5];
}

#pragma mark --- 公共方法 ***********************************

- (UIScrollView *)getScrollViewOfWebview	{
    return self.wkWebView.scrollView;
}


- (void)goBack	{
    [self.wkWebView goBack];
}

- (void)reload	{

    [self.wkWebView reload];
}
- (BOOL)getCurrentCanGoBack	{
    return self.wkWebView.canGoBack;
}

- (void)loadRequest:(NSURLRequest *)request	{
    [self.wkWebView loadRequest:request];
}

- (void)loadURL:(NSURL *)URL shouldAddHeader:(BOOL)shouldAddHeader {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:URL];
    if (shouldAddHeader) {
        NSString *HTTP_LOCALE_CHINESE  = @"zh";
        NSString *HTTP_LOCALE_ENGLISH = @"en";
        NSString *authorization = IsStrEmpty([LoginManage sharedInstance].accessToken)?@"Authorization":[LoginManage sharedInstance].accessToken;
        [request addValue:authorization forHTTPHeaderField:@"Authorization"];
        [request setValue:[Util clientInfo] forHTTPHeaderField:@"CLIENT-INFO"];
        NSString *locale = HTTP_LOCALE_CHINESE;
        if ([[SOSLanguage getCurrentLanguage] isEqualToString:LANGUAGE_ENGLISH]) {
            locale = HTTP_LOCALE_ENGLISH;
        }
        [request addValue:locale forHTTPHeaderField:@"locale"];
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        NSLog(@"H5加载URL: %@",request.URL);
        NSLog(@"H5加载Header: %@",request.allHTTPHeaderFields);
    }
    [self.wkWebView loadRequest:request];
}

- (void)loadURL:(NSURL *)URL	{
    [self loadURL:URL shouldAddHeader:NO];
}

- (void)loadURLString:(NSString *)URLString		{
    NSURL *URL = [NSURL URLWithString:URLString];
    [self loadURL:URL];
}

- (void)loadHTMLString:(NSString *)HTMLString	{
    [self loadHTMLString:HTMLString baseUrl:nil];
}

- (void)loadHTMLString:(NSString *)HTMLString baseUrl:(NSString *)mybaseUrl	{
    [self.wkWebView loadHTMLString:HTMLString baseURL:[NSURL URLWithString:mybaseUrl]];
}

- (void)stringByEvaluatingJavaScriptFromString:(NSString *)script completionHandler:(void (^ _Nullable)(_Nullable id title, NSError * _Nullable error))completionHandler	{
    
    [self.wkWebView evaluateJavaScript:script completionHandler:^(id _Nullable title, NSError * _Nullable error) {
        completionHandler ? completionHandler(title,error) : nil;
    }];
}

#pragma mark --- WK Navigation Delegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if(webView == self.wkWebView && [self.delegate respondsToSelector:@selector(soswebViewDidStartLoad:)]) {
        [self.delegate soswebViewDidStartLoad:self];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.currentURL = webView.URL;
    if(webView == self.wkWebView &&[self.delegate respondsToSelector:@selector(soswebView:didFinishLoadingURL:)]) {
        //忽略长按webview系统弹出menu
//        [self.wkWebView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];
//        [self.wkWebView evaluateJavaScript:@"<meta name=\"viewport\" content=\"width=device-width, initial-scale=0.5, maximum-scale=0.5, minimum-scale=0.5, user-scalable=no\" />" completionHandler:nil];
        [self.delegate soswebView:self didFinishLoadingURL:self.wkWebView.URL];
    }
    [((SOSWebViewController *)self.delegate) callHideLoading];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
    if(webView == self.wkWebView && [self.delegate respondsToSelector:@selector(soswebView:didFailToLoadURL:error:)]) {
        [self.delegate soswebView:self didFailToLoadURL:self.wkWebView.URL error:error];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
    if(webView == self.wkWebView) {
        [self.delegate soswebView:self didFailToLoadURL:self.wkWebView.URL error:error];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    #ifdef SOSSDK_SDK
//    NSString *orderInfo = [SOSPay fetchInfoFromUrl:[webView.URL absoluteString]];
//        if (orderInfo.length > 0) {
//            NSLog(@"orderInfo: %@", orderInfo);
//            NSLog(@"[request.URL absoluteString]: %@", [webView.URL absoluteString]);
//            [SOSPay payWithUrlOrder:orderInfo];
//            return;
//        }
    BOOL ret = [SOSPay fetchInfoFromUrl:[webView.URL absoluteString]];
    if (ret) {
        return;
    }
    #endif
    if(webView == self.wkWebView && [self.delegate respondsToSelector:@selector(soswebView:shouldStartLoadWithURL:navigationType:)]) {
        NSURL *URL = navigationAction.request.URL;
        if(!navigationAction.targetFrame) {
            [self loadURL:URL];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
        SOSWebViewNavigationType navigationType ;
        switch (navigationAction.navigationType) {
            case WKNavigationTypeLinkActivated: {
                navigationType = SOSWebViewNavigationTypeLinkClicked;
                break;
            }
            case WKNavigationTypeFormSubmitted: {
                navigationType = SOSWebViewNavigationTypeFormSubmitted;
                break;
            }
            case WKNavigationTypeBackForward: {
                navigationType = SOSWebViewNavigationTypeBackForward;
                break;
            }
            case WKNavigationTypeReload: {
                navigationType = SOSWebViewNavigationTypeReload;
                break;
            }
            case WKNavigationTypeFormResubmitted: {
                navigationType = SOSWebViewNavigationTypeFormResubmitted;
                break;
            }
            case WKNavigationTypeOther: {
                navigationType = SOSWebViewNavigationTypeOther;
                break;
            }
        }
        [self.delegate soswebView:self shouldStartLoadWithURL:navigationAction.request navigationType:navigationType];
    }

    if (![self handledecisionIsAllowWithNavigationAction:navigationAction]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

-(BOOL)handledecisionIsAllowWithNavigationAction:(WKNavigationAction *)navigationAction{
    
    //拨打电话过滤
    BOOL isAllow = YES;
    NSURL *URL = navigationAction.request.URL;
    NSString *scheme = [URL scheme];
    if ([scheme isEqualToString:@"tel"]) {
    
        NSString *resourceSpecifier = [URL resourceSpecifier];
        [SOSUtil callPhoneNumber:resourceSpecifier];
         isAllow = NO;
    }
    return isAllow;
}

#pragma mark --- WKUIDelegate

//- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures	{
//    if (!navigationAction.targetFrame.isMainFrame) {
//        [webView loadRequest:navigationAction.request];
//    }
//    return nil;
//}

-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self.viewController presentViewController:alertVC animated:YES completion:nil];
}

-(void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    
    UIAlertController *alertConfirm = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertConfirm addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alertConfirm addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self.viewController presentViewController:alertConfirm animated:YES completion:^{
        
    }];
}
-(void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    
    UIAlertController *alertTextfield = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertTextfield addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [self.viewController presentViewController:alertTextfield animated:YES completion:nil];
}


#pragma mark --- WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message	{
    NSLog(@"WKMessageName: %@ messageBody:%@", message.name,message.body);
    SOSWeakSelf(weakSelf);
    if ([message.name isEqualToString:method_onstarGetToken]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *accessToken =[LoginManage sharedInstance].accessToken;
            if ([Util isBlankString:accessToken]) {
                accessToken = @"";
            }
            NSString *jsStr = [NSString stringWithFormat:@"%@('%@')",method_callback_onstarGetToken,accessToken];
            [self stringByEvaluatingJavaScriptFromString:jsStr completionHandler:^(id title, NSError *error) {
                
            }];
        });
    }else if([message.name isEqualToString:method_onstarOpenCalendar]){
        //H5调用APP日历
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(openDateWindow)])
            {
                [((SOSWebViewController *)self.delegate) openDateWindow];
            }
        });
    }else if([message.name isEqualToString:method_getAppInfo]){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *jsStr = [NSString stringWithFormat:@"%@('%@')",method_callback_getAppInfo,[self getAppVersionInfo]];
            [self stringByEvaluatingJavaScriptFromString:jsStr completionHandler:^(id title, NSError *error) {
                
            }];
        });
    }else if([message.name isEqualToString:method_close]){
        //关闭WebView
        dispatch_async(dispatch_get_main_queue(), ^{
            [((SOSWebViewController *)self.delegate) closeItemClicked];
        });
    }else if([message.name isEqualToString:method_getShareUrl]){
        //分享地址
        NSArray *args = message.body;
        [((SOSWebViewController *)self.delegate) shareAttribute:args];
    }else if([message.name isEqualToString:method_goHomePage]){
       //完成自动登录进入homepage
        dispatch_async(dispatch_get_main_queue(), ^{
            [((SOSWebViewController *)self.delegate) closeComplete];
        });
    }else if([message.name isEqualToString:method_onstarOpenCamera]){
       //H5调用原生相机
        dispatch_async(dispatch_get_main_queue(), ^{
            [((SOSWebViewController *)self.delegate) onstarOpenCamera];
        });
    }else if([message.name isEqualToString:method_query]){
       //h5交互查询的信息
        NSArray *args = message.body;
        dispatch_async(dispatch_get_main_queue(), ^{
            [((SOSWebViewController *)self.delegate) queryAttribute:args];
        });
    }else if([message.name isEqualToString:method_showDemoShare]){
       //h5显示原生分享
        dispatch_async(dispatch_get_main_queue(), ^{
            [((SOSWebViewController *)self.delegate) showDemoShare];
        });
    }else if([message.name isEqualToString:method_screenshotShare]){
        //h5 添加截屏分享按钮
        dispatch_async(dispatch_get_main_queue(), ^{
            [((SOSWebViewController *)self.delegate) showScreentShotShare];
        });
    }else if([message.name isEqualToString:method_hideShareBtn]){
        //h5隐藏分享按钮
        dispatch_async(dispatch_get_main_queue(), ^{
            [((SOSWebViewController *)self.delegate) hideScreentShotShare];
        });
    }else if([message.name isEqualToString:method_shareImage]){
       //指定url图片分享
        NSArray *args = message.body;
        dispatch_async_on_main_queue(^{
            if ([args isKindOfClass:NSArray.class] && args.count >0) {
                [((SOSWebViewController *)self.delegate) showURLImageShare:args[0]];
            }
        });
    }else if([message.name isEqualToString:method_goSettingPage]){
       //h5跳转到设置
        dispatch_async(dispatch_get_main_queue(), ^{
            [((SOSWebViewController *)self.delegate) goSettingPage];
        });
    }else if([message.name isEqualToString:method_buyDataPackage]){
        //H5进入购买流量包界面
       dispatch_async(dispatch_get_main_queue(), ^{
           [SOSUtil callBuyDataPackageController];
       });
    }else if([message.name isEqualToString:method_buyOnstarPackage]){
       //H5进入购买安吉星套餐包界面
        dispatch_async(dispatch_get_main_queue(), ^{
            [SOSUtil callBuyOnstarPackageController];
        });
    }else if([message.name isEqualToString:method_goRemotePage]){
        //跳转remoteView
       dispatch_async(dispatch_get_main_queue(), ^{
           AppDelegate_iPhone *appDelegate = (AppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
           [appDelegate jumpToRemoteView];
       });
    }else if([message.name isEqualToString:method_goToLoginPage]){
        //回退登录界面并清除用户名密码
        dispatch_async(dispatch_get_main_queue(), ^{
            [((SOSWebViewController *)self.delegate) showLoginViewController];
        });
    }else if([message.name isEqualToString:method_setTitle]){
        //设置nav、标题
        NSArray *args = message.body;
        if ([args isKindOfClass:NSArray.class] && args.count>0) {
           [((SOSWebViewController *)self.delegate) changeCurrentTitle:args[0]];
       }
    }else if([message.name isEqualToString:method_showLoading]){
       //调用native loading
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [((SOSWebViewController *)self.delegate) callShowLoading];
        });
    }else if([message.name isEqualToString:method_toggleAppLoadingForH5]){
        NSArray *args = message.body;
        if ([args isKindOfClass:NSArray.class] &&  args.count > 0 ) {
            
            NSNumber *show = args[0];
            NSLog(@"toggleAppLoadingForH5 %d",show.boolValue);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (show.boolValue) {
                    [((SOSWebViewController *)self.delegate) callShowLoading];
                }else{
                    [((SOSWebViewController *)self.delegate) callHideLoading];
                }
                
            });
        }
    }else if([message.name isEqualToString:method_closeLoading]){
       //屏蔽 安悦充电 相关地址的 closeLoading 方法替换
       //    if (![weakSelf.currentURL.absoluteString containsString:@"anyocharging.com"]) {
       //调用native dismiss loading
        dispatch_async(dispatch_get_main_queue(), ^{
            [((SOSWebViewController *)self.delegate) callHideLoading];
        });
    }else if([message.name isEqualToString:method_registRightBtn]){
        //调用native设置RightBarButtonItem
        NSArray *args = message.body;
       if ([args isKindOfClass:NSArray.class] && args && args.count>1) {
           [((SOSWebViewController *)self.delegate) refreshRightBarButtonItem:args[0] forwardUrl:args[1]];
       }
    }else if([message.name isEqualToString:method_showLoadingFail]){
        //调用native error view
       dispatch_async(dispatch_get_main_queue(), ^{
           [((SOSWebViewController *)self.delegate) goH5ErrorPage:@"加载失败,点击页面重试!" image:@"loading_errorh5" refreshBlock:^{
               [self loadURL:self.currentURL];
           }];
       });
    }else if([message.name isEqualToString:method_chooseOnStarImage]){
       /**********8.1增加新方法*********/
       //调用原生图库\拍照并上传图片
        NSArray *args = message.body;
        if ([args isKindOfClass:NSArray.class] && args.count == 4) {
            //count为保留字段，支持多图选择时候时用
            NSNumber *count = args[0];
            //选图类型，如果album和camara都有则弹出UIActionSheet，只有一个的话直接跳转
            NSArray *type = args[1];
            //funTag
            NSString *funTag = args[2];
            //reqid
            NSString *reqid = args[3];
            NSDictionary *dic = @{@"count": count, @"type": type, @"funTag": funTag, @"reqid": reqid};
            dispatch_async_on_main_queue(^{
                [((SOSWebViewController *)self.delegate) MA_8_1_onstarPickPhoto:dic];
            });
        }else {
            [Util toastWithMessage:@"参数个数错误"];
        }
    }else if([message.name isEqualToString:method_chooseNativeImage]){
        //调用原生图库\拍照并上传多张图片,最多9张图
        NSArray *imageCount = message.body;
       if (imageCount >0) {
           NSNumber *count = imageCount.firstObject;
           dispatch_async_on_main_queue(^{
               [((SOSWebViewController *)self.delegate) MA_9_3_onstarPickPhotos:(9 - count.intValue)];
           });
       }else {
           [Util toastWithMessage:@"参数个数错误"];
       }
    }else if([message.name isEqualToString:method_getPoiId]){
        //提供用户位置
       [((SOSWebViewController *)self.delegate) MA_9_3_onstarGetUserLocationCallback:^(SOSPOI *currentP) {
           if (currentP) {
               NSString *info;
               NSDictionary *dic = @{@"id":NONil(currentP.pguid),@"name":NONil(currentP.name),@"address":NONil(currentP.address),@"latitude":NONil(currentP.latitude),@"longitude":NONil(currentP.longitude)};
               info = dic.jsonStringEncoded;
               NSLog(@"getPoiId000%@",info);
               NSString *textJS = [NSString stringWithFormat:@"%@('%@')",method_getIOSPoiMsgCallback,  info];
               dispatch_async_on_main_queue(^{
                   [self stringByEvaluatingJavaScriptFromString:textJS completionHandler:nil];
               });
           }
           
       }];
    }else if([message.name isEqualToString:method_refreshFootprint]){
        //刷新足迹
        dispatch_sync_on_main_queue(^{
            [((SOSWebViewController *)self.delegate) MA_9_3_onstarRefreshFootPrint];
        });
    }else if([message.name isEqualToString:method_goFunPage]){
        NSArray *args = message.body;
        if ([args isKindOfClass:NSArray.class] &&  args.count > 0) {
            NSString *para = args.firstObject ;
            dispatch_async_on_main_queue(^{
                [((SOSWebViewController *)self.delegate) MA_8_1_goFunPage:para];
            });
        }else if([message.body isKindOfClass:NSString.class]){
            NSString *para = message.body ;
            dispatch_async_on_main_queue(^{
                [((SOSWebViewController *)self.delegate) MA_8_1_goFunPage:para];
            });
        }
    }else if([message.name isEqualToString:method_sendClientForH5]){
       /**********8.2增加新方法*************/
       //H5DAAP埋点调用客户端方法
        NSArray *args = message.body;
        if ([args isKindOfClass:NSArray.class] &&  args.count >= 1) {
            NSString *funcId = args[0];
            dispatch_async_on_main_queue(^{
                [((SOSWebViewController *)self.delegate) MA_8_2_DAAP_sendActionInfo:funcId];
            });
        }else {
            [Util toastWithMessage:@"参数个数错误"];
        }
    }else if([message.name isEqualToString:method_sendClientBannerForH5]){
        //H5DAAP埋点调用客户端方法
        NSArray *args = message.body;
        if ([args isKindOfClass:NSArray.class] &&  args.count >= 2) {
           NSString *funcId = args[0];
           NSString *bannerId = args[1];
           dispatch_async_on_main_queue(^{
               [((SOSWebViewController *)self.delegate) MA_8_2_DAAP_sendSysBanner:funcId bannerId:bannerId];
           });
       }else {
           [Util toastWithMessage:@"参数个数错误"];
       }
    }else if([message.name isEqualToString:method_sendClientDurationForH5]){
        //H5DAAP埋点调用客户端方法
        NSArray *args = message.body;
        if ([args isKindOfClass:NSArray.class] && args.count >= 4) {
           NSString *funcId = args[0] ;
           NSString *startTime = args[1];
           NSString *endTime = args[2] ;
           NSNumber *status = args[3];
           dispatch_async_on_main_queue(^{
               [SOSDaapManager sendSysLayout:startTime.longLongValue / 1000 endTime:endTime.longLongValue / 1000 loadStatus:status.boolValue funcId:funcId];
           });
       }else {
           [Util toastWithMessage:@"参数个数错误"];
       }
    }else if([message.name isEqualToString:method_shareLinkForH5]){
       /**********8.3增加新方法*************/
       //    shareTitle,shareMsg,shareImg,shareUr
       //H5调起分享
        NSArray *args = message.body;
        if ([args isKindOfClass:NSArray.class] && args.count >= 4) {
            NSString *shareTitle = args[0];
            NSString *shareMsg = args[1];
            NSString *shareImg = args[2];
            NSString *shareUrl = args[3];
            dispatch_async_on_main_queue(^{
                [[NavigateShareTool sharedInstance] showShareAlertControllerWithShareSource:@{@"title":shareTitle,@"desc":shareMsg,@"thumbimageurl":shareImg,@"shareurl":shareUrl,@"menu":@[@{@"event":@"shareWchat",@"functionId":[self.currentPage isEqualToString:@"driveScore"] ? RECENT_TRAVEL_TRAVEL_RECORDS_SHARE_WECHAT_FRIENDS : @""},@{@"event":@"shareWchatMoments",@"functionId":[self.currentPage isEqualToString:@"driveScore"] ? RECENT_TRAVEL_TRAVEL_RECORDS_SHARE_WECHAT_MOMENTS : @""}]}
                                                                         screencutShareView:nil];
                //                [[NavigateShareTool sharedInstance] shareWithWeiXinMessageInfo:info];
                
            });
        }else {
            [Util toastWithMessage:@"参数个数错误"];
        }
    }else if([message.name isEqualToString:method_shareUrlForH5]){
       //H5调起分享,9.3.3新定义
        NSArray *args = message.body;
        if ([args isKindOfClass:NSArray.class] && args.count >= 4) {
            NSString *shareTitle = args[0];
            NSString *shareMsg = args[1];
            NSString *shareImg = args[2];
            NSString *shareUrl = args[3] ;
            NSArray  *shareMenu = args[4];
            //todo 940
            //            NSArray * test = [NSArray arrayWithArray:shareMenu];
            dispatch_async_on_main_queue(^{
                [[NavigateShareTool sharedInstance] showShareAlertControllerWithShareSource:@{@"title":shareTitle,
                                                                                              @"desc":shareMsg,
                                                                                              @"thumbimageurl":shareImg,
                                                                                              @"shareurl":shareUrl,@"menu":shareMenu} screencutShareView:[self getScrollViewOfWebview]];
                
            });
        }else {
            [Util toastWithMessage:@"参数个数错误"];
        }
    }else if([message.name isEqualToString:method_showheaderForH5]){
        // H5 隐藏/显示 Navigation Bar
        NSArray *args = message.body;
        if ([args isKindOfClass:NSArray.class] && args.count >= 1) {
           NSNumber *show = args[0];
           dispatch_async_on_main_queue(^{
               [(SOSWebViewController *)self.delegate hideNavBar:!show.boolValue];
           });
       }    else    {
           [Util toastWithMessage:@"参数个数错误"];
       }
    }else if([message.name isEqualToString:method_coverBottomSafeArea]){
       // H5显示/隐藏底部白条
        NSArray *args = message.body;
        if ([args isKindOfClass:NSArray.class] && args.count >= 1) {
            NSNumber *show = args[0];
            dispatch_async_on_main_queue(^{
                [(SOSWebViewController *)self.delegate coverBottomSafeArea:show.boolValue];
            });
        }    else    {
            [Util toastWithMessage:@"参数个数错误"];
        }
    }else if([message.name isEqualToString:method_changePlateNumber]){
       // H5 更改车牌号回调
        NSArray *args = message.body;
        if ([args isKindOfClass:NSArray.class] && args.count >= 1) {
            NSString *plateNumber = args[0];
            if ([plateNumber isKindOfClass:[NSString class]] && plateNumber.length) {
                UserDefaults_Set_Object(plateNumber, @"CarInfoTypeLicenseNum");
            }
        }
    }else if([message.name isEqualToString:method_carMsgForH5]){
       //预约经销商调用
        SOSVehicle *ve = [[CustomerInfo sharedInstance] currentVehicle];
        NSMutableDictionary *dic = @{@"lineName":ve.modelDesc,
                                     @"brandId":[self getBrandId],
                                     @"stationName":NONil(self.dealerName) ,
                                     @"stationNum":NONil(self.dealerCode)}.mutableCopy;
        NSString *info = dic.jsonStringEncoded;
        NSString *callback = [NSString stringWithFormat:@"%@('%@')",method_callback_carMsgForH5,info];
        [self stringByEvaluatingJavaScriptFromString:callback completionHandler:nil];
    }else if([message.name isEqualToString:method_getUserInfoForH5]){
        // 积分公益,获取用户信息
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *dic;
            if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
                CustomerInfo *userInfo = [CustomerInfo sharedInstance];
                dic = @{ @"userId": userInfo.userBasicInfo.idpUserId,
                         @"userName": userInfo.tokenBasicInfo.nickName,
                         @"userIcon": NONil(userInfo.userBasicInfo.preference.avatarUrl),
                         @"userRole": userInfo.userBasicInfo.currentSuite.role,
                         @"userPhone": NONil(userInfo.userBasicInfo.idmUser.mobilePhoneNumber) };
            }    else    {
                dic = @{ @"userId": @"", @"userName": @"", @"userIcon": @"", @"userPhone": @"" };
            }
            NSString *info = dic.jsonStringEncoded;
            //进入公益积分后刷新下主页上捐赠公益积分数量
            [((SOSWebViewController *)self.delegate) exitMyDonateRefresh];
             NSString *callback = [NSString stringWithFormat:@"%@('%@')",method_callback_getUserInfoForH5,info];
             [self stringByEvaluatingJavaScriptFromString:callback completionHandler:nil];
        });
    }else if([message.name isEqualToString:method_getUserIdForH5]){
       // 广告 Banner,小游戏,获取用户ID
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *dic;
            // 用户完成加载 Token
            if ([LoginManage sharedInstance].loginState >= LOGIN_STATE_LOADINGTOKENSUCCESS || [LoginManage sharedInstance].loginState < LOGIN_STATE_LOADINGTOKENFAIL) {
                CustomerInfo *userInfo = [CustomerInfo sharedInstance];
                NSString *uid = [SOSUtil AES128EncryptString:userInfo.userBasicInfo.idpUserId];
                dic = @{ @"userId": uid };
                NSString *callback = [NSString stringWithFormat:@"%@('%@')",method_callback_getUserIdForH5,dic.jsonStringEncoded];
                [self stringByEvaluatingJavaScriptFromString:callback completionHandler:nil];
                return;
            }    else    {
                // 有缓存的 Token 信息
                NSString *reslutStr = [[SOSLoginDbService sharedInstance]searchTokenOnstarAccount];
                if (!IsStrEmpty (reslutStr)) {
                    NNOAuthLoginResponse *oauthResponseObj = [NNOAuthLoginResponse mj_objectWithKeyValues:[Util dictionaryWithJsonString:reslutStr]];
                    if (oauthResponseObj.idpUserId.isNotBlank) {
                        NSString *uid = [SOSUtil AES128EncryptString:oauthResponseObj.idpUserId];
                        dic = @{ @"userId": uid };
                        NSString *callback = [NSString stringWithFormat:@"%@('%@')",method_callback_getUserIdForH5,dic.jsonStringEncoded];
                        [self stringByEvaluatingJavaScriptFromString:callback completionHandler:nil];
                        return;
                    }
                }
            }
            dispatch_async_on_main_queue(^{
                [[LoginManage sharedInstance] presentLoginNavgationController:self.viewController];
            });
            //            [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:weakSelf.viewController withLoginDependence:([LoginManage sharedInstance].loginState >= LOGIN_STATE_LOADINGTOKENSUCCESS || [LoginManage sharedInstance].loginState < LOGIN_STATE_LOADINGTOKENFAIL) showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
            ////                dispatch_semaphore_signal(weakSelf.signal);
            //            }];
            
            self.signal = dispatch_semaphore_create(0);
            //        dispatch_semaphore_wait(weakSelf.signal, DISPATCH_TIME_FOREVER);
            CustomerInfo *userInfo = [CustomerInfo sharedInstance];
            NSString *idpid = userInfo.userBasicInfo.idpUserId;
            NSString *uid = idpid.length ? [SOSUtil AES128EncryptString:idpid] : @"";
            dic = @{ @"userId": uid };
            NSString *callback = [NSString stringWithFormat:@"%@('%@')",method_callback_getUserIdForH5,dic.jsonStringEncoded];
            [self stringByEvaluatingJavaScriptFromString:callback completionHandler:nil];
        });
        
    }else if([message.name isEqualToString:method_userinfoGo]){
       // 积分公益,用户未登录跳转到登录界面，用户为访客跳转到升级车主界面。用户为车主且登录返回true,否则返回false
        BOOL isReady = [((SOSWebViewController *)self.delegate) isUserReadyForDonation];
        NSString *resultStr = [@{@"isDonation": @(isReady)} mj_JSONString];
        NSString *callback = [NSString stringWithFormat:@"%@('%@')",method_callback_userinfoGo,resultStr];
        [self stringByEvaluatingJavaScriptFromString:callback completionHandler:nil];
    }else if([message.name isEqualToString:method_screencutForh5]){
       // H5 直接触发截屏分享
        dispatch_async_on_main_queue(^{
            [((SOSWebViewController *)self.delegate) toShareFullScreen];
        });
    }else if([message.name isEqualToString:method_webviewBack]){
       dispatch_async_on_main_queue(^{
           [((SOSWebViewController *)self.delegate) customBackItemClicked];
       });
    }else if([message.name isEqualToString:method_screenCutShare]){
        NSArray *args = message.body;
       dispatch_async(dispatch_get_main_queue(), ^{
           NSLog(@"screenCutShare=======")
           //TODO940
           //            [[NavigateShareTool sharedInstance] showShareAlertControllerWithShareSource:@{@"title":@"",@"desc":@"",@"thumbimageurl":@"",@"shareurl":@"",@"menu":@[@{@"event":@"shareWchat",@"functionId":@""},@{@"event":@"shareWchatMoments",@"functionId":@""},@{@"event":@"shareOnStarMoments",@"functionId":@""}]}
           //
           // screencutShareView:[weakSelf getScrollViewOfWebview]];
           //
           [((SOSWebViewController *)self.delegate) toScreenCutShare:nil items:args.count > 0 ? args : @[]];
       });
    }else if([message.name isEqualToString:method_goshareSetPoint]){
       // H5 设置分享埋点
        NSArray *args = message.body;
        if ([args isKindOfClass:NSArray.class] && args.count >= 3) {
            NSString *wxFriend = args[0];
            NSString *wxCircle = args[1];
            NSString *wxCancel = args[2];
            [((SOSWebViewController *)self.delegate) configSharePointWithFunIDArray:@[wxFriend, wxCircle, wxCancel]];
        }
    }else if([message.name isEqualToString:method_screencutOtherPage]){
       // H5 直接触发分享传入 URL 指定图片
        NSArray *args = message.body;
        NSString *imgURL = args[0];
        if ([imgURL isKindOfClass:[NSString class]] && imgURL.length) {
            [((SOSWebViewController *)self.delegate) shareImgWithImgURL:imgURL];
        }
    }else if([message.name isEqualToString:method_callAlertForH5]){
        NSArray *args = message.body;
        if ([args isKindOfClass:NSArray.class] && args.count >= 3) {
           NSString *title = args[0];
           NSString *summary = args[1] ;
           NSString *btnTxt = args[2];
           NSLog(@"%@  %@  %@  ",title,summary,btnTxt);
           [self callAlert:title msg:summary];
       }
    }else if([message.name isEqualToString:method_getVehicleCondition]){
        NSString *jsStr = [((SOSWebViewController *)self.delegate) sendVehicleConditionToHTML];
        NSString *callback = [NSString stringWithFormat:@"%@('%@')",method_callback_getVehicleCondition,jsStr];
        [self stringByEvaluatingJavaScriptFromString:callback completionHandler:nil];
    }else if([message.name isEqualToString:method_finishShowReport]){
       [self sendYearReportfinish];
    }else if([message.name isEqualToString:method_H5_IS_READY]){
        NSArray *args = message.body;
       if ([args isKindOfClass:NSArray.class] && args.count > 0) {
           NSString *flag = args[0];
           [self sendH5hasRead:flag];
       }
    }else if([message.name isEqualToString:@"showToastForH5"]){
        NSArray *args = message.body;
        if ([args isKindOfClass:NSArray.class] &&  args.count >= 3) {
           NSString *flag = args[0];
           NSString *text = args[1] == NULL ? nil : args[1];
           NSString *subText = [Util isBlankString:args[2]] ? nil : args[2];
           NSLog(@"flag=%@ text=%@ subTxt= %@", flag, text, subText);
           [((SOSWebViewController *)self.delegate) showToast:flag.unsignedIntegerValue text:text subText:subText];
       }
    }else if([message.name isEqualToString:method_dissmissToast]){
       [((SOSWebViewController *)self.delegate) dismissToast];
    }else if([message.name isEqualToString:method_showDialog]){
        NSArray*args = message.body;;
        if ([args isKindOfClass:NSArray.class] && args.count >= 6) {
            NSString *flag = args[0];
            NSString *title = args[1];
            NSString *message = args[2];
            NSString *cancel = args[3];
            NSString *others = args[4];
            //            JSValue *callback = args[5];
            
            NSLog(@"flag=%@ title=%@ message= %@", flag, title, message);
            
            [((SOSWebViewController *)self.delegate) showAlertWithType:flag.unsignedIntegerValue title:title message:message cancelBtn:cancel otherBtns:others callback:^(NSUInteger buttonIndex) {
                
                NSString *callBackStr = [NSString stringWithFormat:@"%@('%@')",method_callback_showDialog,@(buttonIndex)];
                [self stringByEvaluatingJavaScriptFromString:callBackStr completionHandler:nil];
            }];
        }
    }else if([message.name isEqualToString:method_showForumShare]){
        NSArray *args = message.body;
        if ([args isKindOfClass:NSArray.class] && args.count >= 2) {
            NSString *funcs = args[0];
            NSString *sharedData = args[1];
            NSLog(@"funcs %@", funcs);
            [((SOSWebViewController *)self.delegate) showForumShare:funcs sharedData:sharedData callback:^(NSUInteger buttonIndex) {
                NSString *setTimeoutStr = [NSString stringWithFormat:@"%@('%@')",method_callback_showForumShare,@(buttonIndex)];
                [weakSelf stringByEvaluatingJavaScriptFromString:setTimeoutStr completionHandler:nil];
            }];
        }
    }else if([message.name isEqualToString:method_goNewPage]){
        NSArray *args = message.body;
       if ([args isKindOfClass:NSArray.class] && args.count >= 1) {
           NSString *url = args[0];
           NSLog(@"url %@", url);
           [((SOSWebViewController *)self.delegate) pushNewWebViewControllerWithUrl:url];
       }
    }else if([message.name isEqualToString:method_goBannerPage]){
        NSArray *args = message.body;
       if ([args isKindOfClass:NSArray.class] && args.count > 0) {
           NSString *para = args.firstObject;
           dispatch_async_on_main_queue(^{
               [((SOSWebViewController *)self.delegate) goBannerPage:para];
           });
       }
    }else if([message.name isEqualToString:method_checkUserForH5]){
        NSArray *args = message.body;
        if ([args isKindOfClass:NSArray.class] && args.count > 0) {
            NSNumber *checkVisitor = args.firstObject;
            NSNumber *number = @([((SOSWebViewController *)self.delegate) showLoginVCAndShouldCheckVisitor:checkVisitor.boolValue]);
            NSString *callback = [NSString stringWithFormat:@"%@('%@')",method_callback_checkUserForH5,number];
            [self stringByEvaluatingJavaScriptFromString:callback completionHandler:nil];
            return;

        }
        NSString *callback = [NSString stringWithFormat:@"%@('%@')",method_callback_checkUserForH5,@(NO)];
        [self stringByEvaluatingJavaScriptFromString:callback completionHandler:nil];
    }else if([message.name isEqualToString:method_goUbiPage]){
        // H5 跳转 里程险
        NSArray *args = message.body;
        if ([args isKindOfClass:NSArray.class] && args.count > 1) {    //title:'',url:''
            NSString *title = args[0];
            NSString *url = args[1];
            if ([title containsString:@"里程"]) {
                [SOSCardUtil showMileAgeInsuranceStatementVCWithURL:url FromVC:self.viewController Success:nil];
            }    else if (url.length)    {
                [self loadURLString:url];
            }
        }
    }else if([message.name isEqualToString:method_showShareToast]){
        // 近期行程调起 分享弹窗
        //                   'shareTitle': title,
        //                   'shareMsg': desc,
        //                   'shareImg': imgurl,
        //                   'shareUrl': url,
        //                   'shareType': 'all'
        NSArray *args = message.body;
        if ([args isKindOfClass:NSArray.class] && args.count >= 5) {
            NSString *shareTitle = args[0];
            NSString *shareMsg = args[1];
            NSString *shareImg = args[2];
            NSString *shareUrl = args[3];
            NSString *shareType = args[4];
            dispatch_async_on_main_queue(^{
                [Util showHUD];
                UIImageView *tempImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
                [self addSubview:tempImageView];
                [tempImageView sd_setImageWithURL:[NSURL URLWithString:shareImg] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    [Util dismissHUD];
                    
                    WeiXinMessageInfo *info = [WeiXinMessageInfo mj_objectWithKeyValues:@{@"messageTitle": shareTitle, @"messageDescription": shareMsg, @"messageWebpageUrl": shareUrl}];
                    info.messageThumbImage = image;
                    [tempImageView removeFromSuperview];
                    [((SOSWebViewController *)self.delegate) shareRecentTrailWithMsg:info needShowSaveToPhoto:[shareType.lowercaseString isEqualToString:@"all"]];
                }];
            });
            
        }
    }else if([message.name isEqualToString:method_toSettingCompanyAddressPage]){
        // 近期行程调起 设置家和公司地址
        [[SOSHomeAndCompanyTool sharedInstance] jumpToSetHomeAddressPageWithType:pageTypeCompany];
        [[[NSNotificationCenter defaultCenter] rac_addObserverForName:KHomeAndCompanyChangedNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
            [self reload];
        }];
    }else if([message.name isEqualToString:method_savePictureForH5]){
         // 保存图片至相册
        NSArray *args = message.body;
        if ([args isKindOfClass:NSArray.class] && args.count >= 1) {
            NSString *imgURL = args[0];
            [((SOSWebViewController *)self.delegate) saveImageWithImageURL:imgURL];
        }
    }
    ///自驾游二期添加js交互
//    [self handleJsActionForDriverTripActionWithMethondName:message.name body:message.body];
//    [self handleJsActionForForumWithMethondName:message.name body:message.body];

}

#pragma mark - JS调用NAVTIVE实现***************************************
//H5调用，通知server已查看年度报告
-(void)sendYearReportfinish        {
    [SOSDaapManager sendActionInfo:AnnualReport_PopupWindow];
    NSString *url = [Util getConfigureURL];
    url = [url stringByAppendingFormat:@"%@",LOGINPOPUPACCEPT];
    NSDictionary *d = @{@"operationType": @"CLICK",@"popupCode":@"PERSONAL_ANNUAL_REPORT"};
    NSString *s = [Util jsonFromDict:d];
    SOSNetworkOperation* sosOperation = [SOSNetworkOperation requestWithURL:url params:s successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSLog(@"===========SOSMonitorURL success========= %@",responseStr);
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        NSLog(@"============SOSMonitorURL fail============");
    }];
    [sosOperation setHttpMethod:@"POST"];
    [sosOperation setHttpHeaders:@{@"Channel":@"onstarapp",@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];

}

//H5调用，通知server已查看WEB标记
- (void)sendH5hasRead:(NSString *)key        {
    NSString *url = [Util getConfigureURL];
    url = [url stringByAppendingFormat:@"%@",LOGINPOPUPACCEPT];
    NSDictionary *d = @{@"operationType": @"CLICK",@"popupCode":key};
    NSString *s = [Util jsonFromDict:d];
    SOSNetworkOperation* sosOperation = [SOSNetworkOperation requestWithURL:url params:s successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSLog(@"===========send read flag success========= %@",responseStr);
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        NSLog(@"============send read flag fail============");
    }];
    [sosOperation setHttpMethod:@"POST"];
    [sosOperation setHttpHeaders:@{@"Channel":@"onstarapp",@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}

- (void)callAlert:(NSString*)title msg:(NSString*)msg        {
    dispatch_async_on_main_queue(^{
        SOSCustomAlertView *cusAlertView = [[SOSCustomAlertView alloc] initWithTitle:title detailText:msg cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        cusAlertView.backgroundModel = SOSAlertBackGroundModelStreak;
        cusAlertView.buttonClickHandle = ^(NSInteger clickIndex) {
            if (clickIndex == 1) {
            }
        };
        [cusAlertView show];
    });
}

- (NSString*)getBrandId        {
    SOSVehicle *ve = [[CustomerInfo sharedInstance] currentVehicle];
    if ([ve.brand isEqualToString:@"CADILLAC"]) {
        return @"1";
    }else if ([ve.brand isEqualToString:@"BUICK"])
        return @"2";
    else{
        return @"3";
    }
}

//#pragma mark - 自驾游二期添加js交互
//-(void)handleJsActionForDriverTripActionWithMethondName:(NSString *)methodName body:(id)messageBody{
//
//    /* ****************   自驾游二期添加   **************** */
//    SOSWeakSelf(weakSelf);
//    if([methodName isEqualToString:method_createfriendGroupForH5]){
//        // 创建群聊 createfriendGroupForH5
//        NSArray *param = messageBody;
//        if (param.count>3) {
//            NSString *teamName = param[0];
//            NSString *avatarUrl = param[1];
//            NSString *intro = param[2];
//            NSString *announcement = param[3];
//
//            [SOSIMManager createIMTeam:teamName avatarUrl:avatarUrl intro:intro announcement:announcement completion:^(NSString * _Nonnull teamId) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    NSString *callBack = [NSString stringWithFormat:@"%@('%@')",method_callback_createfriendGroupForH5,teamId];
//                    [weakSelf stringByEvaluatingJavaScriptFromString:callBack completionHandler:nil];
//                });
//            }];
//        }
//    }else if([methodName isEqualToString:method_enterfriendGroupForH5]){
//        // 进入群聊 enterfriendGroupForH5
//        NSArray *param = messageBody;
//        if (param.count>0) {
//            NSString *teamId = param[0];
//            dispatch_async_on_main_queue(^{
//                [SOSIMManager gotoTeamSessionViewController:teamId];
//            });
//        }
//    }else if([methodName isEqualToString:method_shiftInfriendGroupMemberForH5]){
//        // 邀请加入群聊
//        NSArray *param = messageBody;
//        if (param.count >= 3) {
//            NSArray *users = param[0];
//            NSString *teamId = param[1];
//            NSString *postscript = param[2];
//            [SOSIMManager addUsers:users toTeam:teamId postscript:postscript completion:^(NSError * _Nullable error) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    NSString *callBack = [NSString stringWithFormat:@"%@('%@')",method_callback_shiftInfriendGroupMemberForH5,@(!error)];
//                    [weakSelf stringByEvaluatingJavaScriptFromString:callBack completionHandler:nil];
//                });
//            }];
//        }
//    }else if([methodName isEqualToString:method_removefriendGroupMemberForH5]){
//        // 成员移出群聊 removefriendGroupMemberForH5
//        NSArray *param = messageBody;
//        if (param.count >= 2) {
//            NSArray *users = param[0];
//            NSString *teamId = param[1];
//            [SOSIMManager kickUsers:users fromTeam:teamId completion:^(NSError * _Nullable error) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    NSString *callBack = [NSString stringWithFormat:@"%@('%@')",method_callback_removefriendGroupMemberForH5,@(!error)];
//                    [weakSelf stringByEvaluatingJavaScriptFromString:callBack completionHandler:nil];
//                });
//            }];
//        }
//    }else if([methodName isEqualToString:method_joinfriendGroupForH5]){
//        // 成员加入群聊 joinfriendGroupMemberForH5
//        NSArray *param = messageBody;
//        if (param.count > 0) {
//            NSString *teamId = param[0];
//            [SOSIMManager applyJoinTeam:teamId completion:^(NIMTeamApplyStatus applyStatus) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    NSString *callBack = [NSString stringWithFormat:@"%@('%@')",method_callback_joinfriendGroupForH5,@(applyStatus==NIMTeamApplyStatusAlreadyInTeam)];
//                    [weakSelf stringByEvaluatingJavaScriptFromString:callBack completionHandler:nil];
//                });
//            }];
//        }
//    }else if([methodName isEqualToString:method_contactFriendsForH5]){
//        // 联系按钮的作用：非好友提示加好友，好友直接发消息  contactFriendsForH5
//        NSArray *param = messageBody;
//        if (param.count > 0) {
//            NSString *userId = param[0];
//            dispatch_async_on_main_queue(^{
//                [SOSIMManager gotoP2pSessionViewController:userId];
//            });
//        }
//    }else if([methodName isEqualToString:method_enterPartyTeamForH5]){
//        // 进入车队 enterPartyTeamForH5
//        // IMTeamId传了，认为是进入带有对讲机车队
//        // IMTeamId没传，认为是普通车队无对讲机功能（废弃，在车队可以查到IMTeamId=groupId）
//        NSArray *param = messageBody;
//        if (param.count > 0) {
//            NSString *tripTeamId = param[0];
//            dispatch_async_on_main_queue(^{
//                //            if (![NSString isBlankString:IMTeamId]) {
//                //                [SOSTwoWayRadio setTeamId:IMTeamId];
//                //            }
//                [SOSGroupTripInviteTool gotoTeam:tripTeamId completion:^(BOOL success) {}];
//            });
//        }
//    }else if([methodName isEqualToString:method_toDestinationPageForH5]){
//        // 进入目的地详情页面 toDestinationPageForH5
//        NSArray *param = messageBody;
//        if (param.count > 3) {
//            NSString *longitude = param[0];
//            NSString *latitude = param[1];
//            NSString *name = param[2];
//            NSString *address = param[3];
//            dispatch_async_on_main_queue(^{
//                SOSPOI *poi = [SOSPOI new];
//                poi.name = name;
//                poi.address = address;
//                poi.longitude = longitude;
//                poi.latitude = latitude;
//                [SOSDestinationMapVC gotoDestinationMapWithPOI:poi];
//            });
//        }
//    }else if([methodName isEqualToString:method_rotatePictureForH5]){
//        // 旋转图片 rotatePictureForH5(可以传url和base64两种形式,返回base64)
//        NSArray *param = messageBody;
//        if (param.count > 1) {
//            NSString *url = param[0];
//            NSString *base64 = param[1];
//            if (![NSString isBlankString:url]) {
//                [SOSImageManager imageRotateWithUrl:url callbackBase64:^(NSString * _Nonnull image) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        NSString *jsonStr = [@{@"imgType":@"jpg",@"base64File":image} mj_JSONString];
//                        NSString *jsText = [NSString stringWithFormat:@"%@('%@')",method_callback_rotatePictureForH5,jsonStr];
//                        [weakSelf stringByEvaluatingJavaScriptFromString:jsText completionHandler:nil];
//                        //                    if (![callback isUndefined]) {
//                        //                        [callback callWithArguments:@[base64]];
//                        //                    }
//                    });
//                }];
//            }else if(![NSString isBlankString:base64]){
//                [SOSImageManager imageRotateWithBase64:base64 callbackBase64:^(NSString * _Nonnull image) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        NSString *jsonStr = [@{@"imgType":@"jpg",@"base64File":image} mj_JSONString];
//                        NSString *jsText = [NSString stringWithFormat:@"%@('%@')",method_callback_rotatePictureForH5,jsonStr];
//                        [weakSelf stringByEvaluatingJavaScriptFromString:jsText completionHandler:nil];
//                    });
//                    //                if (![callback isUndefined]) {
//                    //                    dispatch_async(dispatch_get_main_queue(), ^{
//                    //                        [callback callWithArguments:@[base64]];
//                    //                    });
//                    //                }
//                }];
//            }
//        }
//    }else if([methodName isEqualToString:method_quitTeamForH5]){
//        // 退出星友圈群聊
//        NSArray *param = messageBody;
//        if (param.count > 0) {
//            NSString *teamId = param[0];
//            [SOSIMManager quitTeam:teamId completion:^(BOOL success) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    NSString *callBack = [NSString stringWithFormat:@"%@('%@')",method_callback_quitTeamForH5,@[@(success)]];
//                    [weakSelf stringByEvaluatingJavaScriptFromString:callBack completionHandler:nil];
//
//                });
//            }];
//        }
//    }
//}
//#pragma mark - 论坛功能交互
//-(void)handleJsActionForForumWithMethondName:(NSString *)methodName body:(id)messageBody{
//
//    SOSWeakSelf(weakSelf);
//    if([methodName isEqualToString:method_isMyFriendForH5]){
//         // 星友圈检测是否为好友
//        NSArray *data = messageBody;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (data.count > 0) {
//                NSDictionary *dict = data.firstObject;
//                NSString *accId = dict[@"accId"];
//                //1：操作成功，是好友 0：操作成功，不是好友， -1：客户端星友圈登录失败 -2：参数错误
//                if (![NIMSDK sharedSDK].loginManager.isLogined) {
//                    //未登录
//                    [SOSIMLoginManager.sharedManager handleLogin:^(void){
//                        //登录成功
//                        NSString *code;
//                        if (![[NIMSDK sharedSDK].userManager isMyFriend:accId]) {
//                            code = @"0";
//                        }else{
//                            code = @"1";
//                        }
//                        NSString *callBack = [NSString stringWithFormat:@"%@('%@')",method_callback_isMyFriendForH5,@{@"code":code}.mj_JSONString];
//                        [weakSelf stringByEvaluatingJavaScriptFromString:callBack completionHandler:nil];
//                    } error:^(NSError *error) {
//                        //未登录成功
//                        NSString *callBack = [NSString stringWithFormat:@"%@('%@')",method_callback_isMyFriendForH5,@{@"code":@"-1"}.mj_JSONString];
//                        [weakSelf stringByEvaluatingJavaScriptFromString:callBack completionHandler:nil];
//                    }];
//                }else{
//                    //已登录
//                    NSString *code;
//                    if (![[NIMSDK sharedSDK].userManager isMyFriend:accId]) {
//                        code = @"0";
//                    }else{
//                        code = @"1";
//                    }
//                    NSString *callBack = [NSString stringWithFormat:@"%@('%@')",method_callback_isMyFriendForH5,@{@"code":code}.mj_JSONString];
//                    [self stringByEvaluatingJavaScriptFromString:callBack completionHandler:^(id title, NSError *error) {
//
//                    }];
//                }
//            }else{
//                [Util toastWithMessage:@"参数错误"];
//            }
//        });
//
//    }else if([methodName isEqualToString:method_addFriendForH5]){
//         // 星友圈添加好友 0：操作成功-1：客户端星友圈登录失败 -2：参数错误 -3:添加失败
//        NSArray *data = messageBody;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (data.count > 0) {
//                NSDictionary *dict = data.firstObject;
//                NSString *accId = dict[@"accId"];
//                if (![NIMSDK sharedSDK].loginManager.isLogined) {
//                    //未登录
//                    [SOSIMLoginManager.sharedManager handleLogin:^(void){
//                        //登录成功
//                        [SOSIMManager addFriend:accId isNeedVerify:YES message:@"添加好友" completion:^(NSError * _Nonnull error) {
//                            NSString *code;
//                            if (!error) {
//                                code = @"0";
//                            }else{
//                                code = @"-3";
//                            }
//                            NSString *callBack = [NSString stringWithFormat:@"%@('%@')",method_callback_addFriendForH5,@{@"code":code}.mj_JSONString];
//                            [weakSelf stringByEvaluatingJavaScriptFromString:callBack completionHandler:nil];
//                        }];
//                    } error:^(NSError *error) {
//                        //未登录成功
//                        NSString *code = @"-1";
//                        NSString *callBack = [NSString stringWithFormat:@"%@('%@')",method_callback_addFriendForH5,@{@"code":code}.mj_JSONString];
//                        [weakSelf stringByEvaluatingJavaScriptFromString:callBack completionHandler:nil];
//                    }];
//                }else{
//                    //已登录
//                    [SOSIMManager addFriend:accId isNeedVerify:YES message:@"添加好友" completion:^(NSError * _Nonnull error) {
//                        NSString *code = @"0";
//                        if (!error) {
//                            code = @"0";
//                        }else{
//                            code = @"-3";
//                        }
//                        NSString *callBack = [NSString stringWithFormat:@"%@('%@')",method_callback_addFriendForH5,@{@"code":code}.mj_JSONString];
//                        [weakSelf stringByEvaluatingJavaScriptFromString:callBack completionHandler:nil];
//                    }];
//                }
//            }else{
//                [Util toastWithMessage:@"参数错误"];
//            }
//        });
//    }else if([methodName isEqualToString:method_startP2PMessageViewForH5]){
//         // 星友圈打开好友界面 0：操作成功，-1：客户端星友圈登录失败 -2：参数错误 -3:当前用户不是好友
//        NSArray *data = messageBody;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (data.count > 0) {
//                NSDictionary *dict = data.firstObject;
//                NSString *accId = dict[@"accId"];
//                if (![NIMSDK sharedSDK].loginManager.isLogined) {
//                    //未登录
//                    [SOSIMLoginManager.sharedManager handleLogin:^(void){
//                        NSString *code = @"0";
//                        //登录成功
//                        if ([[NIMSDK sharedSDK].userManager isMyFriend:accId]) {
//                            code = @"0";
//                            [SOSIMManager gotoP2pSessionViewController:accId];
//                        }else{
//                            code = @"-3";
//                        }
//                        NSString *callBack = [NSString stringWithFormat:@"%@('%@')",method_callback_startP2PMessageViewForH5,@{@"code":code}.mj_JSONString];
//                        [weakSelf stringByEvaluatingJavaScriptFromString:callBack completionHandler:nil];
//                    } error:^(NSError *error) {
//                        //未登录成功
//                        NSString *code = @"-1";
//                        NSString *callBack = [NSString stringWithFormat:@"%@('%@')",method_callback_startP2PMessageViewForH5,@{@"code":code}.mj_JSONString];
//                        [weakSelf stringByEvaluatingJavaScriptFromString:callBack completionHandler:nil];
//                    }];
//                }else{
//                    //已登录
//                    NSString *code = @"0";
//                    if ([[NIMSDK sharedSDK].userManager isMyFriend:accId]) {
//                        code = @"0";
//                        [SOSIMManager gotoP2pSessionViewController:accId];
//                    }else{
//                        code = @"-3";
//                    }
//                    NSString *callBack = [NSString stringWithFormat:@"%@('%@')",method_callback_startP2PMessageViewForH5,@{@"code":code}.mj_JSONString];
//                    [self stringByEvaluatingJavaScriptFromString:callBack completionHandler:nil];
//                }
//            }else{
//                [Util toastWithMessage:@"参数错误"];
//            }
//        });
//    }
//}


#pragma mark - lazy

- (void)dealloc		{
    NSLog(@"--------> SOSwebview dealloc");
    if (_wkWebView) {
        [_wkWebView.configuration.userContentController removeAllUserScripts];
        _wkWebView.navigationDelegate = nil;
        _wkWebView.UIDelegate=nil;
        [_wkWebView stopLoading];
        _wkWebView = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)getAppVersionInfo {
    NSMutableDictionary *dic = @{@"version":SOSSDK_ONSTAR_VERSION,
                                 @"device":@"ios"}.mutableCopy;
    if (!SOS_ONSTAR_PRODUCT) {
        [dic setValue:SOSSDK_WEB_SOURCE forKey:@"source"];
    }
    NSString *versionInfo = dic.jsonStringEncoded;
    return versionInfo;
}

-(WKWebView *)wkWebView{
    if (!_wkWebView) {
        _wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) configuration:[self getWebViewConfignation]];
        [_wkWebView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [_wkWebView setNavigationDelegate:self];
        [_wkWebView setUIDelegate:self];
        [_wkWebView setMultipleTouchEnabled:YES];
        [_wkWebView setAutoresizesSubviews:YES];
        [_wkWebView.scrollView setAlwaysBounceVertical:YES];
        [_wkWebView setAutoresizesSubviews:YES];
        _wkWebView.allowsBackForwardNavigationGestures = YES;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        longPress.minimumPressDuration = 0.5;
        longPress.delegate = self;
        [_wkWebView addGestureRecognizer:longPress];
        _wkWebView.backgroundColor = [UIColor whiteColor];
    }
    return _wkWebView;
}


@end
