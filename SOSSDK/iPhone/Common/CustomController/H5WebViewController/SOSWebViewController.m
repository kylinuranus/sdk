//
//  SOSWebViewController.m
//  Onstar
//
//  Created by Apple on 16/7/6.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "SOSWebViewController.h"
#import "LoadingView.h"
//#import "TFHpple.h"
#import <SDWebImage/SDImageCache.h>

#import "NavigateShareTool.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "CustomCover.h"
#import "DatePickerView.h"
#import "CustomerInfo.h"
#import "SOSCheckRoleUtil.h"
#import "Util.h"
#import "SOSCarAssessmentView.h"
#import "DispatchUtil.h"
#include <AssetsLibrary/AssetsLibrary.h>
#import "AccountInfoUtil.h"
#import "PurchaseCommonDefination.h"
#import "SOSUserLocation.h"
#import "SOSSearchResult.h"
#import "SOSSettingViewController.h"
#import "AppDelegate_iPhone+SOSService.h"
#import "UIViewController+errorPage.h"
#import "SOSWebViewControllerHelper.h"
#import "RegisterUtil.h"
#import "SOSRegisterInformation.h"
#import "SOSLoginUserDbService.h"
#import "SDWebImageManager.h"
#import "SOSAgreement.h"

#import "SOSPhotoLibrary.h"

#import "WeiXinManager.h"
#ifndef SOSSDK_SDK
#import "SOSIMApiObject.h"
#import "SOSIMApi.h"
#else
#import <SOSSDK/SOSPay.h>
#endif


#define boundsWidth self.view.bounds.size.width
#define boundsHeight self.view.bounds.size.height

@interface SOSWebViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    SOSCarAssessmentView *carAssess;
    UIActionSheet *sheet;
}
@property (nonatomic)UIBarButtonItem* customBackBarItem;
@property (nonatomic)UIBarButtonItem* customRightBarItem;
@property (nonatomic)UIBarButtonItem* closeButtonItem;
@property (nonatomic)UIBarButtonItem* shareButtonItem;
@property (nonatomic, copy)NSString *shareTitle;
@property (nonatomic, copy)NSString *shareDescription;
@property (nonatomic,copy)NSString *dicStr;
@property (nonatomic,copy)NSString *method;
@property (nonatomic,copy)NSString *contentType;

/**
 *  array that hold snapshots
 */
@property (nonatomic)NSMutableArray* snapShotsArray;

/**
 *  current snapshotview displaying on screen when start swiping
 */
@property (nonatomic)UIView* currentSnapShotView;

/**
 *  previous view
 */
@property (nonatomic)UIView* prevSnapShotView;

/**
 *  background alpha black view
 */
@property (nonatomic)UIView* swipingBackgoundView;

/**
 *  left pan ges
 */
@property (nonatomic)UIPanGestureRecognizer* swipePanGesture;

/**
 *  if is swiping now
 */
@property (nonatomic)BOOL isSwipingBack;

@property (nonatomic, retain) CustomCover *cover;
@property (nonatomic, retain) DatePickerView *datePickerView;

@property (strong, nonatomic) SOSWebViewControllerHelper *helper;

@property (nonatomic, assign) NSTimeInterval loadingStartTime;
@property (nonatomic, copy) NSString *loadingSuccessFuncID;
@property (nonatomic, copy) NSString *loadingFailFuncID;

@end

@implementation SOSWebViewController

- (UIStatusBarStyle) preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

#pragma mark - init
- (id)initWithUrl:(NSString *)url{
    self = [super init];
    if (self) {
        self.url = [url mj_url];
        self.isH5Title = -1;
    }
    return self;
}

- (id)initWithTitle:(NSString *)title withUrl:(NSString *)url withBannerType:(NSInteger)typeId isH5Title:(NSInteger)h5Title{
    self = [super init];
    if (self)	{
        self.titleStr = title;
        self.url = [url mj_url];
        self.scalesPage = typeId;
        self.isH5Title = h5Title;
    }
    return self;
}

- (id)initWithUrl:(NSString *)url params:(NSString *)dic httpMethod:(NSString *)method contentType:(NSString *) contentType;{
    self = [super init];
    if (self) {
        self.url = [url mj_url];
        self.method = method;
        self.dicStr = dic;
        self.contentType = contentType;
        
    }
    return self;
}

- (id)initWithDispatcher:(NNDispatcherReq *)dispatcherRequest{
    self = [super init];
    if (self) {
        _dispatcherRequest = dispatcherRequest;
    }
    return self;
}

- (id)initWithBrocastID:(NSString *)brocastid{
    self = [super init];
    if (self) {
        _brocastID = brocastid;
    }
    return self;
}

- (id)initWithURLRequest:(NNURLRequest *)urlRequest{
    self = [super init];
    if (self) {
        self.url = [urlRequest.url mj_url];
        self.method= urlRequest.method;
        self.contentType = urlRequest.contenType;
        self.dicStr = urlRequest.jsonStr;
    }
    return self;
}

- (void)setDriveScoreFlg:(BOOL)driveScoreFlg	{
    _driveScoreFlg = driveScoreFlg;
}

- (void)viewDidLoad		{
    [super viewDidLoad];
    _currentShareType = ShareTypeNone;
//    self.extendedLayoutIncludesOpaqueBars = YES;
#ifdef SOSSDK_SDK
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observePayResponse:) name:SOSpayH5SuccessNotification object:nil];
#endif
    self.title = @"";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    [_webView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self.view);
    }];
    if (_isDealer) {
        self.webView.dealerName = _dealerName;
        self.webView.dealerCode = _dealerCode;
    }
    
    if (_driveScoreFlg)		self.webView.currentPage = @"driveScore";
    else					self.webView.currentPage = @"";
    
    [self updateNavigationItems];
    
    [self initDatePickerView];
    if (self.HTMLString != nil) {
        [self webLoadHTMLString];
    }
    else
    {
        //mock
        if(self.isDemo){
            [self loadThirdPartyDemo];
            self.isDemo = NO;
        }	else	{
            if (_dispatcherRequest)
                [self handleDispatcherRequest];
            else
            {
                if (_brocastID)
                    [self handleBroadcastRequest];
                else
                    [self loadThirdParty];
            }
        }
    }
//    [self coverBottomSafeArea:YES];

}

- (void)addTopCoverView	{
    float statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, statusBarHeight)];
    coverView.backgroundColor = [UIColor whiteColor];
    [self.view insertSubview:coverView aboveSubview:self.webView];
    __weak __typeof(self) weakSelf = self;
    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view);
        make.left.equalTo(weakSelf.view);
        make.right.equalTo(weakSelf.view);
        make.height.equalTo(@(statusBarHeight));
    }];
}

- (void)viewWillAppear:(BOOL)animated    {
    [super viewWillAppear:animated];
    if ([CustomerInfo sharedInstance].showCarAlert_H5 && carAssess) {
        [CustomerInfo sharedInstance].showCarAlert_H5 = NO;
        [carAssess showShareReportView];
    }
    if (self.webView.signal) {
        dispatch_semaphore_signal(self.webView.signal);
        [self.webView reload];
        self.webView.signal = nil;
    }
}

-(void)stopLoadingState{
    [[LoadingView sharedInstance] stop];
       //隐藏网络活动标志
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}
- (void)handleBroadcastRequest		{
    NSString *url = [NSString stringWithFormat:(@"%@" NEW_GET_BROADCAST_DETAIL), BASE_URL, [NSString stringWithFormat:@"%@",_brocastID]];
    [[LoadingView sharedInstance] startIn:self.view withNavigationBar:NO];
    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id returnData) {
        [[LoadingView sharedInstance] stop];
        BroadcastDetail *detail = [BroadcastDetail mj_objectWithKeyValues:returnData];
        NNErrorDetail *errorInfo = detail.errorInfo;
        if ([errorInfo.msg length] >= 1) {
            [Util showAlertWithTitle:nil message:errorInfo.msg completeBlock:^(NSInteger buttonIndex) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }    else    {
            self.url = [NSURL URLWithString:[detail.contentUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            //                            self.method= urlRequest.method;
            //                            self.contentType = urlRequest.contenType;
            //                            self.dicStr = urlRequest.jsonStr;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadThirdParty];
            });
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [[LoadingView sharedInstance] stop];
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
    }];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}

- (void)handleDispatcherRequest		{
    [[LoadingView sharedInstance] startIn:self.view withNavigationBar:NO];
    [DispatchUtil getDispatcher:_dispatcherRequest Success:^(NNURLRequest *urlRequest) {
        //                    self.url = [NSURL URLWithString:[urlRequest.url mj_url]];
        self.url = [urlRequest.url mj_url];
        self.method= urlRequest.method;
        self.contentType = urlRequest.contenType;
        self.dicStr = urlRequest.jsonStr;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadThirdParty];
        });
    } Failed:^{
        //获取dispatcher失败
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadErrorPage];
            [[LoadingView sharedInstance] stop];
        });
    }];
}

/**
 懒加载helper,本类专门处理8.1后的业务逻辑
 
 @return SOSWebViewControllerHelper实例
 */
- (SOSWebViewControllerHelper *)helper {
    if (!_helper) {
        _helper = [[SOSWebViewControllerHelper alloc] initWithCustomeH5WebViewController:self];
    }
    return _helper;
}

- (void)observePayResponse:(NSNotification *)notification	{
    NSString* urlStr = [notification userInfo][@"returnUrl"];
    NSLog(@"第三方App需要跳转的成功页URL: %@", urlStr);
    self.url = urlStr.mj_url;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadThirdParty];
    });
}

- (void)loadErrorPage	{
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:ERROR_500_URL]]];
}

- (void)webLoadHTMLString	{
    [_webView loadHTMLString:self.HTMLString];
}

#pragma mark - logic of push and pop snap shot views
- (void)pushCurrentSnapshotViewWithRequest:(NSURLRequest*)request{
    NSURLRequest* lastRequest = (NSURLRequest*)[[self.snapShotsArray lastObject] objectForKey:@"request"];
    //如果url是很奇怪的就不push, 如果url一样就不进行push
    if ([request.URL.absoluteString isEqualToString:@"about:blank"] || [lastRequest.URL.absoluteString isEqualToString:request.URL.absoluteString] || request == nil) 	return;
    UIView* currentSnapShotView = [self.webView snapshotViewAfterScreenUpdates:YES];
    [self.snapShotsArray addObject:@{@"request":request,@"snapShotView":currentSnapShotView}];
}

#pragma mark - events handler
- (void)swipePanGestureHandler:(UIPanGestureRecognizer*)panGesture{
    CGPoint translation = [panGesture translationInView:self.webView];
    CGPoint location = [panGesture locationInView:self.webView];
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        if (location.x <= 50 && translation.x > 0) {  //开始动画
            [self startPopSnapshotView];
        }
    }	else if (panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateEnded){
        [self endPopSnapShotView];
    }	else if (panGesture.state == UIGestureRecognizerStateChanged){
        [self popSnapShotViewWithPanGestureDistance:translation.x];
    }
}

- (void)startPopSnapshotView{
    if (self.isSwipingBack)		return;
    if (![self.webView getCurrentCanGoBack]) {
        self.isSwipingBack = YES;
        return;
    }	else	self.isSwipingBack = YES;
    
    //create a center of scrren
    CGPoint center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    
    self.currentSnapShotView = [self.webView snapshotViewAfterScreenUpdates:YES];
    
    //add shadows just like UINavigationController
    self.currentSnapShotView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.currentSnapShotView.layer.shadowOffset = CGSizeMake(3, 3);
    self.currentSnapShotView.layer.shadowRadius = 5;
    self.currentSnapShotView.layer.shadowOpacity = 0.75;
    
    //move to center of screen
    self.currentSnapShotView.center = center;
    
    self.prevSnapShotView = (UIView*)[[self.snapShotsArray lastObject] objectForKey:@"snapShotView"];
    center.x -= 60;
    self.prevSnapShotView.center = center;
    self.prevSnapShotView.alpha = 1;
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.prevSnapShotView];
    [self.view addSubview:self.swipingBackgoundView];
    [self.view addSubview:self.currentSnapShotView];
}

- (void)endPopSnapShotView{
    if (!self.isSwipingBack)	return;
    
    //prevent the user touch for now
    self.view.userInteractionEnabled = NO;
    
    if (self.currentSnapShotView.center.x >= boundsWidth) {
        // pop success
        [UIView animateWithDuration:0.2 animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            
            self.currentSnapShotView.center = CGPointMake(boundsWidth*3/2, boundsHeight/2);
            self.prevSnapShotView.center = CGPointMake(boundsWidth/2, boundsHeight/2);
            self.swipingBackgoundView.alpha = 0;
        }	completion:^(BOOL finished) {
            [self.prevSnapShotView removeFromSuperview];
            [self.swipingBackgoundView removeFromSuperview];
            [self.currentSnapShotView removeFromSuperview];
            
            if ([self.webView getCurrentCanGoBack]) {
                [self.webView goBack];
            }else{
                [self closeItemClicked];
            }
            [self.snapShotsArray removeLastObject];
            self.view.userInteractionEnabled = YES;
            
            self.isSwipingBack = YES;
        }];
    }	else	{
        //pop fail
        [UIView animateWithDuration:0.2 animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            
            self.currentSnapShotView.center = CGPointMake(boundsWidth/2, boundsHeight/2);
            self.prevSnapShotView.center = CGPointMake(boundsWidth/2-60, boundsHeight/2);
            self.prevSnapShotView.alpha = 1;
        }	completion:^(BOOL finished) {
            [self.prevSnapShotView removeFromSuperview];
            [self.swipingBackgoundView removeFromSuperview];
            [self.currentSnapShotView removeFromSuperview];
            self.view.userInteractionEnabled = YES;
            
            self.isSwipingBack = NO;
        }];
    }
}

- (void)popSnapShotViewWithPanGestureDistance:(CGFloat)distance{
    if ( ! self.isSwipingBack || distance <= 0)		return;
    
    CGPoint currentSnapshotViewCenter = CGPointMake(boundsWidth/2, boundsHeight/2);
    currentSnapshotViewCenter.x += distance;
    CGPoint prevSnapshotViewCenter = CGPointMake(boundsWidth/2, boundsHeight/2);
    prevSnapshotViewCenter.x -= (boundsWidth - distance)*60/boundsWidth;
    //    NSLog(@"prev center x%f",prevSnapshotViewCenter.x);
    
    self.currentSnapShotView.center = currentSnapshotViewCenter;
    self.prevSnapShotView.center = prevSnapshotViewCenter;
    self.swipingBackgoundView.alpha = (boundsWidth - distance)/boundsWidth;
}

#pragma mark - 更新导航栏按钮
- (void)updateNavigationItems	{
    if (!self.navigationController) {
        return;
    }
    //如果h5是单个画面且没有画面跳转，通过push出来的。则显示返回按钮
    if (self.singlePageFlg) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[[UIImage imageNamed:@"common_Nav_Back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        button.size = CGSizeMake(30, 44);
        button.backgroundColor = [UIColor clearColor];
        // 让按钮内部的所有内容左对齐
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        //        [button sizeToFit];
        // 让按钮的内容往左边偏移10
        button.contentEdgeInsets = UIEdgeInsetsMake(0, -1, 0, 0);
        [button addTarget:self action:@selector(customBackItemClicked) forControlEvents:UIControlEventTouchUpInside];
        // 修改导航栏左边的item
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationBackButton = button;
        return;
    }
    if (self.shouldShowCloseButton) {
        
        UIButton* closeButton = [[UIButton alloc] init];
        [closeButton setTitle:@"   关闭" forState:UIControlStateNormal];
        [closeButton setTitleColor:self.navigationController.navigationBar.tintColor forState:UIControlStateNormal];
        [closeButton setTitleColor:[self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [closeButton setImage:[UIImage imageNamed:@"insurance_dia_close"] forState:UIControlStateNormal];
        [closeButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [closeButton sizeToFit];
        [closeButton addTarget:self action:@selector(closeItemClicked) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *closeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
        
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        [self.navigationItem setLeftBarButtonItems:@[closeButtonItem] animated:NO];
        return;
    }
    if (self.shouldDismiss || !self.singlePageFlg) {
        UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceButtonItem.width = -5;
        if ([self.webView getCurrentCanGoBack]) {
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
            [self.navigationItem setLeftBarButtonItems:@[spaceButtonItem,self.customBackBarItem,self.closeButtonItem] animated:NO];
        }	else 	{
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
            [self.navigationItem setLeftBarButtonItems:nil];
            [self.navigationItem setLeftBarButtonItems:@[spaceButtonItem,self.customBackBarItem] animated:NO];
        }
    }
}

#pragma mark - 完成自动登录进入homepage
- (void)closeComplete	{
    [self closeItemClicked];
    if (_closeCompleteBlock) {
        _closeCompleteBlock();
    }
}

#pragma mark - 返回
- (void)customBackItemClicked	{
    [self checkBackFunId];
    //检查back标签是否存在
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('functionId').value" completionHandler:^(id  _Nullable title, NSError * _Nullable error)	{
         if (title && ![title isEqualToString:@""])	[SOSDaapManager sendActionInfo:title];
     }];
    
    NSString *query = self.webView.wkWebView.URL.query;
    if (!IsStrEmpty(query)) {
        NSArray *seperateArray=[query componentsSeparatedByString:@"&"];
        for(NSString * str in seperateArray){
            NSArray *keyAndValueArray=[str componentsSeparatedByString:@"="];
            if (keyAndValueArray.count < 2) 	continue;
            NSString *key= [keyAndValueArray objectAtIndex:0];
            NSString *value= [[keyAndValueArray objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            //h5弹窗
            if ([key isEqualToString:@"onstarNativeBack"] && [value.uppercaseString isEqualToString:@"YES"]) {
                //[self closeItemClicked];
                [self.webView stringByEvaluatingJavaScriptFromString:@"onstarShowDialog()" completionHandler:^(id  _Nullable title, NSError * _Nullable error) {
                }];
                return;
            }
            //直接关闭webview
            if ([key isEqualToString:@"onstarCloseView"] && [value.uppercaseString isEqualToString:@"YES"]) {
                [self closeItemClicked];
                return;
            }
            //H5页面是中间页面跳转过去的，跳过跳转页面，需要回退2次
            if([key isEqualToString:@"onstarGoBack2"]&& [value.uppercaseString isEqualToString:@"YES"]){
                if ([self.webView getCurrentCanGoBack]) {
                    [self.webView goBack];
                }
                if ([self.webView getCurrentCanGoBack]) {
                    [self.webView goBack];
                }
                return;
            }
        }
    }
    if ([self.webView getCurrentCanGoBack]) {
        [self.webView goBack];
    }	else	{
        [self closeItemClicked];
    }
}

- (void)checkBackFunId
{
    if ([self.backDaapFunctionID isEqualToString:Dealeraptm_appointment_back]) {
        [SOSDaapManager sendActionInfo:Dealeraptm_appointment_back];
    }
}

#pragma mark - 关闭
- (void)closeItemClicked{
    [[LoadingView sharedInstance] stop];
    if (!IsStrEmpty(self.backRecordFunctionID)) {
        [SOSDaapManager sendActionInfo:self.backRecordFunctionID];
    }
    
    NSArray *viewcontrollers = self.navigationController.viewControllers;
    if (viewcontrollers.count > 1)  {
        if (viewcontrollers[viewcontrollers.count - 1] == self)  {
            //push方式
            [self.navigationController popViewControllerAnimated:YES];
        }
    }   else    {
        //present方式
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    if (_backClickCompleteBlock) {
        _backClickCompleteBlock();
    }
}

- (void)shareAttribute:(NSArray *)args	{
    //参数数组内参数个数>=4个
    if (args.count > 3) {
        __unsafe_unretained __typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            _shareTitle = args[0];
            _shareDescription = args[1];
            _shareImg = args[2];
            _shareUrl = args[3] ;
            _tempShareUrl = args[3];
            if (!IsStrEmpty(_tempShareUrl)) {
                weakSelf.navigationItem.rightBarButtonItem = weakSelf.shareButtonItem;
            }
        });
    }
}

#pragma mark - WebView Delegate
- (void)soswebViewDidStartLoad:(SOSWebView *)webview	{
    if (self.loadingSuccessFuncID.length) {
        if (self.loadingStartTime == 0) 	self.loadingStartTime = [[NSDate date] timeIntervalSince1970] ;
    }
    _tempShowDemoShareFlg = NO;
    _showDemoShareFlg = NO;
    _currentShareType = ShareTypeNone;
    if (_shareImageUrl != nil) {
        _shareImageUrl = nil;
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)soswebView:(SOSWebView *)webview shouldStartLoadWithURL:(NSURLRequest *)request navigationType:(SOSWebViewNavigationType)navigationType	{
    switch (navigationType) {
        case SOSWebViewNavigationTypeLinkClicked: {
            [self pushCurrentSnapshotViewWithRequest:request];
            break;
        }
        case SOSWebViewNavigationTypeFormSubmitted: {
            [self pushCurrentSnapshotViewWithRequest:request];
            break;
        }
        case SOSWebViewNavigationTypeBackForward: {
            break;
        }
        case SOSWebViewNavigationTypeReload: {
            break;
        }
        case SOSWebViewNavigationTypeFormResubmitted: {
            break;
        }
        case SOSWebViewNavigationTypeOther: {
            [self pushCurrentSnapshotViewWithRequest:request];
            break;
        }
        default: {
            break;
        }
    }
    [self updateNavigationItems];
    
}

- (void)soswebView:(SOSWebView *)webview didFinishLoadingURL:(NSURL *)URL	{
    if (self.loadingSuccessFuncID.length) {
        if (_isForNewDAAP) {
            [SOSDaapManager sendSysLayout:self.loadingStartTime endTime:[[NSDate date] timeIntervalSince1970]  loadStatus:YES  funcId:self.loadingSuccessFuncID];

        }else{
            [SOSDaapManager sendSysLayout:self.loadingStartTime endTime:[[NSDate date] timeIntervalSince1970]  funcId:self.loadingSuccessFuncID];
        }
    }
    BOOL dontCloseLoading = NO;
    if ([[URL absoluteString] containsString:@"forbidCloseAppLoading"]) {
        dontCloseLoading = YES;
    }
    if (![[URL absoluteString] containsString:@"ctrlLoading=Y"]) {
        if (!dontCloseLoading) {
            [self stopLoadingState];
        }
    }
    
    [self updateNavigationItems];
    [webview.wkWebView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable theTitle, NSError * _Nullable error) {
        _shareTitle = theTitle;
        if ([theTitle isKindOfClass:[NSString class]]) {
            if (((NSString *)theTitle).length > 12) {
                theTitle = [[theTitle substringToIndex:11] stringByAppendingString:@"…"];
            }
        }
        if (_isH5Title==0) {
            theTitle =self.titleStr;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.title = theTitle;
            
            if (_alwaysShareFlg) {
                //一直显示分享
                self.navigationItem.rightBarButtonItem = self.shareButtonItem;
            }
            else if (_tempShowDemoShareFlg) {
                self.navigationItem.rightBarButtonItem = self.shareButtonItem;
            }	else	{
                if (_currentShareType != ShareTypeNone) {
                    self.navigationItem.rightBarButtonItem = self.shareButtonItem;
                }	else	{
                    if(!_hideShareFlg)	{
                        if (IsStrEmpty(_tempShareUrl)) {
                            //客户服务页面会调两次webViewDidFinishLoad,如果设置按钮的动作夹在中间,会导致按钮消失
                            if (![theTitle isEqualToString:@"客户服务"]) {
                                self.navigationItem.rightBarButtonItem = nil;
                            }
                        }	else	{
                            self.navigationItem.rightBarButtonItem = self.shareButtonItem;
                            _tempShareUrl=nil;
                        }
                    }	else	{
                        self.navigationItem.rightBarButtonItem = nil;
                    }
                }
            }
            
            [self.navigationController.navigationBar layoutIfNeeded];
        });
        
    }];
    //bbwc教育页面置为yes
    NSString *bbwcURL = [NSString stringWithFormat:BBWC_EDUCATION,@""];
    if ([URL.absoluteString containsString:bbwcURL]) {
        [self changeBBWCStatus];
    }
}

- (void)soswebView:(SOSWebView *)webview didFailToLoadURL:(NSURL *)URL error:(NSError *)error	{
    if (self.loadingFailFuncID.length) {
        if (_isForNewDAAP) {
            [SOSDaapManager sendSysLayout:self.loadingStartTime endTime:[[NSDate date] timeIntervalSince1970]  loadStatus:NO  funcId:self.loadingFailFuncID];

        }else{
            [SOSDaapManager sendSysLayout:self.loadingStartTime endTime:[[NSDate date] timeIntervalSince1970]  funcId:self.loadingFailFuncID];

        }
    }
    [self stopLoadingState];

}


#pragma mark -业务 更新bbwc状态
- (void)changeBBWCStatus {
    SOSBBWCSubmitWrapper * scr = [[SOSBBWCSubmitWrapper alloc] init];
    scr.isBbwcDone = YES;
    scr.bbwcDone = YES;
    [RegisterUtil submitBBWCInfoOrOnstarInfo:NO	withEnrollInfo:[scr mj_JSONString]	successHandler:^(NSString *responseStr) {
        NNBBWCResponse * resp = [NNBBWCResponse mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (resp /*&& resp.vehicleType*/)	{
                //                //更新成功
                ////                [CustomerInfo sharedInstance].bbwcDone = YES;
                //                CustomerInfo *userInfo = [CustomerInfo sharedInstance];
                //
                //                //更新缓存中 BBWC 状态信息
                //                NSString *cachedProfileString = [[SOSLoginUserDbService sharedInstance] searchUserIdToken:[LoginManage sharedInstance].idToken];
                ////                NNSubscriber *profile = [NNSubscriber mj_objectWithKeyValues:[Util dictionaryWithJsonString:cachedProfileString]];
                //                SOSLoginUserDefaultVehicleVO* newProfile = [SOSLoginUserDefaultVehicleVO mj_objectWithKeyValues:[Util dictionaryWithJsonString:cachedProfileString]];
                //                newProfile.currentSuite.vehicle.bbwc = YES;
                ////                NSString *currentAccountID = [profile defaultAccountID];
                ////
                ////                for (NNAccount *account in [profile accounts]) {
                ////                    if ([[account accountID] isEqualToString:currentAccountID]) {
                ////                        // 默认的Account
                ////                        for (NNVehicle *vehicle in [account vehicles]) {
                ////                            if ([[vehicle vin] isEqualToString:[userInfo userBasicInfo].currentSuite.vehicle.vin]) {
                ////                                vehicle.bbwc = YES;
                ////                            }
                ////                        }
                ////                    }
                ////                }
                [CustomerInfo sharedInstance].currentVehicle.bbwc = YES;
                ////                userInfo.bbwcDone = YES;
                //                NSString *newProfileString = [newProfile mj_JSONString];
                //                [[SOSLoginUserDbService sharedInstance] updateUserIdToken:[LoginManage sharedInstance].idToken reposeString:newProfileString];
            }
            
        });
    } failureHandler:^(NSString *responseStr, NSError *error) {
    }];
}

#pragma mark - 懒加载
- (SOSWebView*)webView{
    if (!_webView) {
        _webView = [[SOSWebView alloc] initWithFrame:self.view.bounds];
        _webView.delegate = self;
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.opaque = NO;

    }
    return _webView;
}

- (UIBarButtonItem*)customBackBarItem{
    if (!_customBackBarItem) {
        UIImage* backItemImage = [[UIImage imageNamed:@"common_Nav_Back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage* backItemHlImage = [[UIImage imageNamed:@"common_Nav_Back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UIButton* backButton = [[UIButton alloc] init];
        [backButton setTitle:[NSString stringWithFormat:@" %@",NSLocalizedString(@"infoPageButtonBackTitle",nil)] forState:UIControlStateNormal];
        [backButton setTitleColor:self.navigationController.navigationBar.tintColor forState:UIControlStateNormal];
        [backButton setTitleColor:[self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [backButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [backButton setImage:backItemImage forState:UIControlStateNormal];
        [backButton setImage:backItemHlImage forState:UIControlStateHighlighted];
        [backButton sizeToFit];
        
        [backButton addTarget:self action:@selector(customBackItemClicked) forControlEvents:UIControlEventTouchUpInside];
        _customBackBarItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
    return _customBackBarItem;
}

- (UIBarButtonItem*)closeButtonItem{
    if (!_closeButtonItem) {
        UIButton* closeButton = [[UIButton alloc] init];
        [closeButton setTitle:NSLocalizedString(@"Close_Btn",nil) forState:UIControlStateNormal];
        [closeButton setTitleColor:self.navigationController.navigationBar.tintColor forState:UIControlStateNormal];
        [closeButton setTitleColor:[self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [closeButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [closeButton sizeToFit];
        [closeButton addTarget:self action:@selector(closeItemClicked) forControlEvents:UIControlEventTouchUpInside];
        _closeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    }
    return _closeButtonItem;
}

- (UIBarButtonItem*)shareButtonItem{
    if (!_shareButtonItem) {
        _shareButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(shareClick)];
    }
    return _shareButtonItem;
}

#pragma mark 微信分享url
- (void)forwardClick	{
    [self.webView loadURL:[NSURL URLWithString:self.forwardUrl]];
}

- (void)shareClick	{
    //7.3驾驶行为demo,点击分享调用JS方法
    if (_showDemoShareFlg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *textJS = [NSString stringWithFormat:@"showOnstarDemoDialog()"];
            [self.webView stringByEvaluatingJavaScriptFromString:textJS completionHandler:^(id  _Nullable title, NSError * _Nullable error) {
            }];
        });
        return;
    }
    //如果是爱车评估，在弹出分享窗口之前需要做其它验证
    if (self.vehicleEvaluateFlg) {
        [SOSDaapManager sendActionInfo:CarValuation_share];
        if ([SOSCheckRoleUtil isOwner]) {
            [self showAgreementView];
        }
        return;
    }
    switch (_currentShareType) {
        case ShareTypeURlImage:
            [self toShareUrlImage];
            break;
        case ShareTypeScreenShoot:
            [self toShareFullScreen];
            break;
        case ShareTypeNone:
            [self Toshare];
            break;
        default:
            [self Toshare];
            break;
    }
}

- (void)setShareFunId:(WeiXinMessageInfo*)messageInfo
{
    if ([self.title isEqualToString:@"爱车评估"]) {
        messageInfo.shareCancelRecordFunctionID = CV0027;
        messageInfo.shareWechatRecordFunctionID = CarValuation_share_wechat;
        messageInfo.shareMomentsRecordFunctionID = CarValuation_share_moments;
    }
}

- (void)Toshare		{
    WeiXinMessageInfo *messageInfo = [[WeiXinMessageInfo alloc] init];
    messageInfo.messageTitle = _shareTitle;
    messageInfo.messageDescription = _shareDescription;
    messageInfo.messageWebpageUrl = _shareUrl;
    [self setShareFunId:messageInfo];
    
    if (!IsStrEmpty(self.shareClickRecordFunctionID)) {
        //[[SOSReportService shareInstance] recordActionWithFunctionID:self.shareClickRecordFunctionID];
        messageInfo.shareClickRecordFunctionID = self.shareClickRecordFunctionID;
        messageInfo.shareCancelRecordFunctionID = self.shareCancelRecordFunctionID;
        messageInfo.shareWechatRecordFunctionID = self.shareWechatRecordFunctionID;
        messageInfo.shareMomentsRecordFunctionID = self.shareMomentsRecordFunctionID;
    }
    
    if (_vehicleEvaluateFlg) {
        messageInfo.shareWechatRecordFunctionID = CarValuation_share_moments;
        messageInfo.shareMomentsRecordFunctionID = CarValuation_share_wechat;
    }
    
    messageInfo.messageThumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[_shareImg stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]]];
    [[NavigateShareTool sharedInstance] shareWithWeiXinMessageInfo:messageInfo];
}

- (void)toShareUrlImage	{
    WeiXinMessageInfo *messageInfo = [[WeiXinMessageInfo alloc] init];
    messageInfo.messageTitle = _shareTitle;
    messageInfo.messageDescription = _shareDescription;
    messageInfo.messageWebpageUrl = _shareUrl;
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_shareImageUrl]];
    messageInfo.media = [Util zipImageDataLessthan10MB:imageData];
    if (!IsStrEmpty(self.shareClickRecordFunctionID)) {
        //[[SOSReportService shareInstance] recordActionWithFunctionID:self.shareClickRecordFunctionID];
        messageInfo.shareClickRecordFunctionID = self.shareClickRecordFunctionID;
        messageInfo.shareCancelRecordFunctionID = self.shareCancelRecordFunctionID;
        messageInfo.shareWechatRecordFunctionID = self.shareWechatRecordFunctionID;
        messageInfo.shareMomentsRecordFunctionID = self.shareMomentsRecordFunctionID;
    }
    
    messageInfo.messageThumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[_shareImg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    [[NavigateShareTool sharedInstance] shareWithWeiXinMessageInfo:messageInfo];
}

- (void)toShareFullScreen    {
    //先改变frame，将其全部展开
    UIScrollView*rt=[self.webView getScrollViewOfWebview];
    rt.frame=rt.superview.frame;
    CGRect sourceFrame = rt.frame;
    CGRect frm=rt.frame;
    //webview的scrollerView有64的偏移
    frm.size.height=self.webView.wkWebView.scrollView.contentSize.height + IOS7_NAVIGATION_BAR_HEIGHT;
    rt.frame=frm;
    [rt.superview layoutIfNeeded];
    //截屏
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.view.frame.size.width,rt.frame.size.height -IOS7_NAVIGATION_BAR_HEIGHT), YES, 0);     //设置截屏大小
    [rt.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef imageRef = viewImage.CGImage;
    UIImage *sendImage = [[UIImage alloc] initWithCGImage:imageRef];
    //重新设置回原frame
    rt.frame=sourceFrame;
    [rt.superview layoutIfNeeded];
    WeiXinMessageInfo *messageInfo = [[WeiXinMessageInfo alloc] init];
    messageInfo.messageTitle = _shareTitle;
    messageInfo.messageDescription = _shareDescription;
    messageInfo.messageWebpageUrl = _shareUrl;
    //分享图片,图片超过10MB使用jpg格式压缩上传
//    NSData * imageData = UIImagePNGRepresentation(sendImage);
    messageInfo.media = [Util compressedImageFiles:sendImage imageKB:10000];
    if (!IsStrEmpty(self.shareWechatRecordFunctionID)) {
        messageInfo.shareClickRecordFunctionID = self.shareClickRecordFunctionID;
        messageInfo.shareCancelRecordFunctionID = self.shareCancelRecordFunctionID;
        messageInfo.shareWechatRecordFunctionID = self.shareWechatRecordFunctionID;
        messageInfo.shareMomentsRecordFunctionID = self.shareMomentsRecordFunctionID;
    }
    
    messageInfo.messageThumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[_shareImg stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]]];
    [[NavigateShareTool sharedInstance] shareWithWeiXinMessageInfo:messageInfo];
}


- (void)toScreenCutShare:(UIImage*)imageg items:(NSArray*)items {
    if (items.count <= 0) {
        return;
    }
    
    UIScrollView *scrollView=[self.webView getScrollViewOfWebview];
    UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, NO, 0);     //设置截屏大小
    [scrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    NSString *para = items.firstObject;
    NSArray<NSString *> *arr = [para componentsSeparatedByString:@","];
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [arr enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<NSString*> *temp = [obj componentsSeparatedByString:@"="];
        UIAlertAction *act = nil;
        NSString *key = temp.firstObject;
        NSString *funcId = temp.count > 1 ? temp[1] : nil;
        if ([key isEqualToString:@"shareWchat"]) {
            act = [UIAlertAction actionWithTitle:@"微信好友" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                funcId ? [SOSDaapManager sendActionInfo:funcId] : nil;
                [[WeiXinManager shareInstance] requestWeiXinImage:image Message:nil Scence:WXSceneSession];
            }];
        }else if ([key isEqualToString:@"shareWchatMoments"]) {
            act = [UIAlertAction actionWithTitle:@"微信朋友圈" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                funcId ? [SOSDaapManager sendActionInfo:funcId] : nil;
                [[WeiXinManager shareInstance] requestWeiXinImage:image Message:nil Scence:WXSceneTimeline];
                
            }];
        }else if ([key isEqualToString:@"shareOnStarMoments"]) {
#ifndef SOSSDK_SDK
            act = [UIAlertAction actionWithTitle:@"安吉星聊天" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                {
                    [[LoginManage sharedInstance] checkAndShowLoginViewWithFromViewCtr:self andTobePushViewCtr:nil completion:^(BOOL finished) {
                        if (finished) {
                            funcId ? [SOSDaapManager sendActionInfo:funcId] : nil;
                            SOSIMImageObject *imageObj = [SOSIMImageObject object];
                            imageObj.imageData = UIImagePNGRepresentation(image);
                            
                            SOSIMMediaMessage *imMsg = [SOSIMMediaMessage message];
                            [imMsg setThumbImage:[Util zoomImage:image WithScale:5]];
                            imMsg.mediaObject = imageObj;
                            
                            SendMessageToSOSIMReq *imReq = [[SendMessageToSOSIMReq alloc] init];
                            //                imReq.bText = NO;
                            imReq.messageType = SOSIMMessageTypeImage;
                            imReq.message = imMsg;
                            imReq.fromNav = self.navigationController;
                            
                            [SOSIMApi sendReq:imReq];
                        }
                    }];
                }
                
                
            }];
#endif
        }else if ([key isEqualToString:@"cancelshare"]) {
             act = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                 funcId ? [SOSDaapManager sendActionInfo:funcId] : nil;
            }];
        }
        act ? [ac addAction:act] : nil;
    }];

    [ac show];
}

/// 近期行程分享方法 (saveToPhoto: 是否需要显示保存到系统相册)
- (void)shareRecentTrailWithMsg:(WeiXinMessageInfo *)wechatMsg needShowSaveToPhoto:(BOOL)saveToPhoto     {
    SOSSocialContactShareView *view = [SOSSocialContactShareView viewFromXib];
    NSMutableArray *channels = [NSMutableArray arrayWithArray:@[
#ifndef SOSSDK_SDK
        @{ @"icon":@"onstarFrends",
           @"title":@"星友圈好友" },
#endif
        @{ @"icon":@"Icon／34x34／icon_share_weixin_34x34",
           @"title":@"微信好友" },
        @{ @"icon":@"wxfrend",
           @"title":@"微信朋友圈" },
    ]];
    UIImage *image = nil;
    if (saveToPhoto) {
        UIScrollView *scrollView=[self.webView getScrollViewOfWebview];
        CGRect oriRect = scrollView.frame;
        scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
        UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, NO, 0);     //设置截屏大小

        [scrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [channels addObject:  @{ @"icon":@"share_save_Photo", @"title":@"保存图片" }];
        scrollView.frame = oriRect;
    }
    
    view.shareChannels = channels;
    SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:nil title:nil message:nil customView:view preferredStyle:SOSAlertControllerStyleActionSheet];
    @weakify(vc)
    view.shareTapBlock = ^(NSInteger index) {
        @strongify(vc)
        if (index != 3) 	[vc dismissViewControllerAnimated:YES completion:nil];
#ifdef SOSSDK_SDK
        index++;
#endif
        if (index == 0) {
#ifndef SOSSDK_SDK
            [SOSDaapManager sendActionInfo:RecentTrip_CommuteList_Turtle_Share_OnstarFriend];
            ///*
             SOSIMMediaMessage *msg = [SOSIMMediaMessage message];
             msg.title = wechatMsg.messageTitle;
//             msg.des = wechatMsg.messageDescription;
            msg.mediaObject = [SOSIMWebPageObject objectWithTitle:wechatMsg.messageTitle shareImg:wechatMsg.messageThumbImageUrl  Msg:wechatMsg.messageDescription AndLinkURL:wechatMsg.messageWebpageUrl];
             
             SendMessageToSOSIMReq *imReq = [[SendMessageToSOSIMReq alloc] init];
             imReq.messageType = SOSIMMessageTypeWebPage;
             imReq.bText = NO;
             imReq.message = msg;
             imReq.fromNav = self.navigationController;
             [SOSIMApi sendReq:imReq];
             //*/
//            SOSIMMediaMessage *media = [SOSIMMediaMessage new];
//            media.title = wechatMsg.messageTitle;
//            media.des = wechatMsg.messageDescription;
//
//            SendMessageToSOSIMReq *imReq = [[SendMessageToSOSIMReq alloc] init];
//            imReq.messageType = SOSIMMessageTypeText;
//            imReq.bText = YES;
//            imReq.text = wechatMsg.messageWebpageUrl;
//            imReq.message = media;
//            imReq.fromNav = self.navigationController;
//            [SOSIMApi sendReq:imReq];
#endif
            
        }	else if (index == 1) {
            [SOSDaapManager sendActionInfo:RecentTrip_CommuteList_Turtle_Share_WechatFriend];
            wechatMsg.scene = WXSceneSession;
            [[WeiXinManager shareInstance] shareWebPageContent:wechatMsg];
            
        }	else if (index == 2) {
            [SOSDaapManager sendActionInfo:RecentTrip_CommuteList_Turtle_Share_WechatCircle];
            wechatMsg.scene = WXSceneTimeline;
            [[WeiXinManager shareInstance] shareWebPageContent:wechatMsg];
        }	else if (index == 3) {
            [SOSDaapManager sendActionInfo:RecentTrip_CommuteList_Turtle_Share_SavePicture];
            [vc dismissViewControllerAnimated:YES completion:^{
                [SOSPhotoLibrary saveImage:image assetCollectionName:nil callback:^(BOOL success) {
//                    if (success)     [Util showSuccessHUDWithStatus:@"图片成功保存至'安吉星'相册"];
                }];
            }];
        }
        
    };
    
    SOSAlertAction *action = [SOSAlertAction actionWithTitle:@"取消" style:SOSAlertActionStyleCancel handler:^(SOSAlertAction * _Nonnull action) {	}];
    [vc addActions:@[action]];
    [vc show];
}

- (void)saveImageWithImageURL:(NSString *)imgURL	{
    [Util showHUD];
    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:imgURL] options:SDWebImageHandleCookies progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        [Util dismissHUD];
        if (error)             [Util showErrorHUDWithStatus:@"图片下载失败，请稍后再试"];
        else if (image)        {
            [SOSPhotoLibrary saveImage:image assetCollectionName:nil callback:^(BOOL success) {
//                if (success)     [Util showSuccessHUDWithStatus:@"图片成功保存至'安吉星'相册"];
            }];
        }
    }];
}

/// H5 设置分享埋点
- (void)configSharePointWithFunIDArray:(NSArray <NSString *>*)funIDArray	{
    self.shareWechatRecordFunctionID = funIDArray[0];
    self.shareMomentsRecordFunctionID = funIDArray[1];
    self.shareCancelRecordFunctionID = funIDArray[2];
    self.shareFunIDArray = funIDArray;
}

/// H5 设置 Loading 加载时间埋点
- (void)configLoadingFuncIDWithStartTime:(NSTimeInterval)startTime AndSuccessFuncID:(NSString *)successFuncID FailureFuncID:(NSString *)failFuncID	{
    self.loadingStartTime = startTime;
    self.loadingSuccessFuncID = successFuncID;
    self.loadingFailFuncID = failFuncID;
}

- (void)shareImgWithImgURL:(NSString *)url	{
    
    if ([[SDImageCache sharedImageCache] diskImageDataExistsWithKey:url]) {
        UIImage *img = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:url];
        [[NavigateShareTool sharedInstance] shareWithImg:img andFunIDArray:self.shareFunIDArray];
        return;
    }
    [[LoadingView sharedInstance] startIn:self.view];
    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:url] options:SDWebImageHandleCookies progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        [[LoadingView sharedInstance] stop];
        if (error)             [Util toastWithMessage:@"获取分享信息失败"];
        else if (image)        {
            [[SDImageCache sharedImageCache] storeImage:image forKey:url toDisk:YES completion:nil];
            [[NavigateShareTool sharedInstance] shareWithImg:image andFunIDArray:self.shareFunIDArray];
        }
    }];
}

- (void)showAgreementView	{
    //获取显示状态并设置开关状态
    [Util getVehicleReportCallback:^(NSString *VehicleOptStatus) {
        NSString *serviceStatus = VehicleOptStatus;
        if([serviceStatus isEqualToString:@"3"]){
            serviceStatus = @"0";
        }
        if ([serviceStatus isEqualToString:@"0"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 弹框
                carAssess = [[SOSCarAssessmentView alloc] initWithFrame:CGRectMake(60, 250, self.view.width - 120, 165.f)];
                carAssess.carEnum = ShareCarReport;
                [carAssess initView];
                __block SOSCarAssessmentView *carA= carAssess;
                __weak __typeof(self)weakSelf = self;
                [carAssess setAgreementUrl:^{
                    [Util showLoadingView];
                    [SOSAgreement requestAgreementsWithTypes:@[agreementName(ONSTAR_CARDATA_SHARE_TC)] success:^(NSDictionary *response) {
                        [Util hideLoadView];
                        NSDictionary *dic = response[agreementName(ONSTAR_CARDATA_SHARE_TC)];
                        SOSAgreement *agreement = [SOSAgreement mj_objectWithKeyValues:dic];
                        [CustomerInfo sharedInstance].showCarAlert_H5 = YES;
                        SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:agreement.url];
                        [carA dismissShareReportView];
                        [weakSelf.navigationController pushViewController:vc animated:YES];
                    } fail:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                        [Util hideLoadView];
                        [Util toastWithMessage:@"获取协议内容失败"];
                    }];
                }];
                [carAssess setAgreeGoInAction:^(BOOL flag) {
                    if (flag) {
                        [Util openVehicleService:^{
                            [CustomerInfo sharedInstance].servicesInfo.hasResponse = NO;
                            [weakSelf Toshare];
                        } httpMethod:@"PUT"];
                    }
                }];
                [carAssess showShareReportView];
            });
        }
        if ([serviceStatus isEqualToString:@"1"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self Toshare];
            });
        }
        if ([serviceStatus isEqualToString:@"2"]) {
            [Util showAlertWithTitle:nil message:@"服务正在开通中，请耐心等待。" completeBlock:nil];
        }
    }];
}


- (UIView*)swipingBackgoundView{
    if (!_swipingBackgoundView) {
        _swipingBackgoundView = [[UIView alloc] initWithFrame:self.view.bounds];
        _swipingBackgoundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }
    return _swipingBackgoundView;
}

- (NSMutableArray*)snapShotsArray{
    if (!_snapShotsArray) {
        _snapShotsArray = [NSMutableArray array];
    }
    return _snapShotsArray;
}

- (BOOL)isSwipingBack{
    if (!_isSwipingBack) {
        _isSwipingBack = NO;
    }
    return _isSwipingBack;
}

- (UIPanGestureRecognizer*)swipePanGesture{
    if (!_swipePanGesture) {
        _swipePanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipePanGestureHandler:)];
    }
    return _swipePanGesture;
}

#pragma mark - dealloc
- (void)dealloc	{
    NSLog(@"customH5WebView Dealloc");
    [self stopLoadingState];
    if (_isBBWC) {
        NSDictionary *dic = @{@"BBWC_Edu_End": @YES};
        [[NSNotificationCenter defaultCenter] postNotificationName:SOS_PresentTouchID_Notification object:dic];
        
    }
    [[LoginManage sharedInstance] nextPopViewAction];
    if (_webView) {
        self.webView.delegate = nil;
        self.webView = nil;
    }
    self.mirrorSimRecharge = NO;
#ifdef SOSSDK_SDK
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SOSpayH5SuccessNotification object:nil];
#endif
}

#pragma mark - 初始化日期选择
- (void)initDatePickerView	{
    _datePickerView = [[DatePickerView alloc] init];
    _datePickerView.top = SCREEN_HEIGHT;
    __unsafe_unretained __typeof(self) weakSelf = self;
    [_datePickerView setExitCallback:^{
        [weakSelf closeDateWindow];
    }];
    [_datePickerView setOkCallback:^{
        [weakSelf selectDate];
    }];
}

#pragma mark 弹出日期窗口
- (void)openDateWindow{
    if (!_cover) {
        _cover = [CustomCover coverWithTarget:self action:@selector(closeDateWindow) coverAlpha:0.35];
        _cover.frame = [[UIScreen mainScreen] bounds];
    }
    [[[UIApplication sharedApplication] keyWindow] addSubview:_cover];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_datePickerView];
    
    //设置datePicker默认日期
    [_datePickerView.datePicker setDate:[NSDate date] animated:NO];
    [UIView animateWithDuration:.3 animations:^{
        [_cover reset];
        _datePickerView.bottom = self.view.bottom;
    }];
}

#pragma mark 关闭日期窗口
- (void)closeDateWindow{
    [UIView animateWithDuration:.3 animations:^{
        _cover.alpha = 0.0;
        _datePickerView.top = self.view.bottom;
    } completion:^(BOOL finished) {
        [_cover removeFromSuperview];
        [_datePickerView removeFromSuperview];
    }];
}

#pragma mark 选择日期
- (void)selectDate{
    _cover.alpha = 0.0;
    _datePickerView.top = self.view.bottom;
    [_cover removeFromSuperview];
    [_datePickerView removeFromSuperview];
    NSString *dt = [[DatePickerView dateFormatter] stringFromDate:_datePickerView.datePicker.date];
    //APP返回日历
    NSString *textJS = [NSString stringWithFormat:@"resultDate('%@')",dt];
    [self.webView stringByEvaluatingJavaScriptFromString:textJS completionHandler:^(id  _Nullable title, NSError * _Nullable error) {
        
    }];
}


- (void)loadThirdParty{
    //H5各类测试接口页面地址，需要时打开
//    NSString *temp = @"http://idt7.onstar.com.cn/mweb/ma80/checkApp.html";
//    NSURL *tempUrl = [NSURL URLWithString:temp];
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:tempUrl];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: self.url];
    [[LoadingView sharedInstance] startIn:self.view withNavigationBar:NO];
    NSString *HTTP_LOCALE_CHINESE  = @"zh";
    NSString *HTTP_LOCALE_ENGLISH = @"en";
//    NSString *authorization = IsStrEmpty([LoginManage sharedInstance].accessToken)?@"Authorization":[LoginManage sharedInstance].accessToken;
    [request addValue:LoginManage.sharedInstance.authorization ? : @"Authorization" forHTTPHeaderField:@"Authorization"];
    [request setValue:[Util clientInfo] forHTTPHeaderField:@"CLIENT-INFO"];
    if (_mirrorSimRecharge) {
        [request setValue:@"http://www.cm-dt.com/" forHTTPHeaderField:@"Referer"];
    }
    NSString *locale = HTTP_LOCALE_CHINESE;
    if ([[SOSLanguage getCurrentLanguage] isEqualToString:LANGUAGE_ENGLISH]) {
        locale = HTTP_LOCALE_ENGLISH;
    }
    [request addValue:locale forHTTPHeaderField:@"locale"];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    if(self.dicStr){
        NSString *json = self.dicStr;
        NSString *body = [NSString stringWithFormat: @"%@", [json mj_JSONString]];
        [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
    }
    if([self.contentType isEqualToString:@"JSON"]){
        [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    }
    if(self.method)		[request setHTTPMethod:self.method];
    
    NSLog(@"H5加载URL: %@", request.URL);
    NSLog(@"H5加载Header: %@", request.allHTTPHeaderFields);
    NSLog(@"H5加载Method: %@", self.method ? : @"none");
    NSLog(@"H5加载Body: %@", self.dicStr ? : @"none");

    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.webView loadRequest: request];
    });
}


- (void)loadThirdPartyDemo{
    NSString *json = nil;
    NSDictionary *dic = @{
                          @"userName": @"ONSTAR0001904426",
                          @"vehicleID": @"LSGAR55L4GH000660",
                          @"licensePlate": @"沪A12345",
                          @"engineNumber": @"NT12345",
                          @"mobilePhoneNumber": @"1311111111",
                          @"emailAddress": @"test@shanghaionstar.com",
                          @"firstName": @"三",
                          @"lastName": @"张",
                          @"location": @{ @"longitude": @"121.609824",
                                          @"latitude": @"31.253207" },
                          @"timestamp": @"1462432102976",
                          @"extensions": @[ @{ @"code": @"Make",
                                               @"value": @"Buick" },
                                            @{ @"code": @"Model",
                                               @"value": @"Enclave" }  ]
                          };
    json = [dic toJson];
    NSString *body = [NSString stringWithFormat: @"%@", [json mj_JSONString]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:self.url];
    [request setHTTPMethod: @"POST"];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
    [self.webView loadRequest: request];
}

/// load user image
- (void)onstarOpenCamera	{
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])	{
        sheet  = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select_image", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Take_photo", nil),NSLocalizedString(@"Choose_from_photos", nil), nil];
    }	else	{
        sheet  = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select_image", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Choose_from_photos", nil), nil];
    }
    [sheet showInView:self.view];
}

#pragma mark - action sheet delegte
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex	{
    NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])		{
        switch (buttonIndex)	{
            case 2:
                return;
            case 1: //相册
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
            case 0: //相机
                sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
        }
    }	else	{
        if (buttonIndex == 0)	sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  		else					return;
    }
    
    // 跳转到相机或相册页面
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    [[picker navigationBar] setTintColor:[UIColor colorWithHexString:@"131329"]];
    [picker navigationBar].translucent = NO;
    NSDictionary *dict = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"131329"],
                           NSFontAttributeName:[UIFont systemFontOfSize:17]};
    [[picker navigationBar] setTitleTextAttributes:dict];
    picker.view.backgroundColor = [UIColor whiteColor];
    picker.delegate = self;
    picker.sourceType = sourceType;
    [self presentViewController:picker animated:YES completion:nil];
}


#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info		{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)		{
        [[LoadingView sharedInstance] startIn:self.view];
        SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:H5_updateFile_URL params:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            NSString *fileName = [NSString stringWithFormat:@"%@.jpg", @([[NSDate date] timeIntervalSince1970]*1000)];
            NSData *data = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerEditedImage],1);
            [formData appendPartWithFileData:data name:@"imageFile" fileName:fileName mimeType:@"image/jpeg"];
        } successBlock:^(SOSNetworkOperation *operation, id responseStr) {
            [Util hideLoadView];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *dict = [Util dictionaryWithJsonString:responseStr];
                NSString *textJS = [NSString stringWithFormat:@"resultCamera('%@')",dict[@"url"]];
                [self.webView stringByEvaluatingJavaScriptFromString:textJS completionHandler:^(id  _Nullable title, NSError * _Nullable error) {
                }];
            });
        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            [Util hideLoadView];
            [Util showAlertWithTitle:nil message:NSLocalizedString(@"Upload_failed", nil) completeBlock:nil];
        }];
        [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
        [operation setHttpMethod:@"POST"];
        [operation startUploadTask];
    };
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:imageURL resultBlock:resultblock failureBlock:nil];
}

#pragma mark - h5交互查询的信息
- (void)queryAttribute:(NSArray *)args{
    if (args.count >0) {
        NSString *query = args[0];
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
        
        NSArray *queryArray = [query.uppercaseString componentsSeparatedByString:@","];
        
        dispatch_group_t group = dispatch_group_create();
        
        //用户信息
        if ([queryArray containsObject:[@"userInfo" uppercaseString]]) {
            NSDictionary *userInfo = @{@"idpid":[self returnSafeString:[CustomerInfo sharedInstance].userBasicInfo.idpUserId],
                                       @"role": [self returnSafeString:[[CustomerInfo sharedInstance].userBasicInfo.currentSuite.role lowercaseString]],
                                       @"isLogin":([[LoginManage sharedInstance] isLoadingUserBasicInfoReady])?@"1":@"0"};
            [resultDict setObject:userInfo forKey:@"userInfo"];
        }
        
        //车辆信息
        if ([queryArray containsObject:[@"vehicleInfo" uppercaseString]] &&
            [[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
            NSString *licensePlate = [self returnSafeString:UserDefaults_Get_Object(@"CarInfoTypeLicenseNum")];
            NSString *engineNumber = [self returnSafeString:UserDefaults_Get_Object(@"CarInfoTypeEngineNum")];
            NSString *brand = [[CustomerInfo sharedInstance] currentVehicle].brand;
            NSString *isGen10 = [CustomerInfo sharedInstance].currentVehicle.gen10?@"1":@"0";
            NSString *isEV = [Util vehicleIsEV]?@"1":@"0";
            NSString *isPHEV = [Util vehicleIsPHEV]?@"1":@"0";
            NSArray *vehicleUnitFeatures = [SOSUtil vehicleSupportCommandArray];
            NSDictionary *vehicleInfo = @{@"VIN": [self returnSafeString:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin],
                                          @"licensePlate": licensePlate?:@"",
                                          @"engineNumber": engineNumber?:@"",
                                          @"brand": brand?:@"",
                                          @"isGen10": isGen10,
                                          @"isEV": isEV,
                                          @"isPHEV":isPHEV,
                                          @"vehicleUnitFeatures":vehicleUnitFeatures?:@"",
                                          };
            [resultDict setObject:vehicleInfo forKey:@"vehicleInfo"];
        }
        
        //用户位置信息
        if ([queryArray containsObject:[@"userLocation" uppercaseString]]) {
            dispatch_group_enter(group);
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [[SOSUserLocation sharedInstance] getLocationSuccess:^(SOSPOI *poi) {
                    if (poi!=nil) {
                        NSDictionary *userLocation = @{@"latitude": poi.latitude,
                                                       @"longitude": poi.longitude,
                                                       @"province": poi.province,
                                                       @"city": poi.city,
                                                       @"cityCode": poi.cityCode};
                        [resultDict setObject:userLocation forKey:@"userLocation"];
                    }
                    dispatch_group_leave(group);
                } Failure:^(NSError *error) {
                    dispatch_group_leave(group);
                }];
            });
        }
        
        //服务信息
        if ([queryArray containsObject:[@"serviceInfo" uppercaseString]] &&
            [[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
            dispatch_group_enter(group);
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self getServiceStatusCallback:^(NSString *optStatus) {
                    NSMutableArray *serviceInfo = [NSMutableArray array];
                    NSArray *servicesList = [Util arrayWithJsonString:optStatus];
                    NNservicesOpt *opt = [[NNservicesOpt alloc] init];
                    [opt setServicesList:[NNserviceObject mj_objectArrayWithKeyValuesArray:servicesList]];
                    
                    for (NNserviceObject *object in opt.servicesList) {
                        if (!object.serviceName.length)		continue;
                        NSDictionary *serviceDict = @{@"serviceName":object.serviceName,
                                                      @"availability":@(object.availability).stringValue,
                                                      @"optStatus":@(object.optStatus).stringValue};
                        [serviceInfo addObject:serviceDict];
                    }
                    [resultDict setObject:serviceInfo forKey:@"serviceInfo"];
                    dispatch_group_leave(group);
                } error:^(NSString *responseStr) {
                    dispatch_group_leave(group);
                }];
            });
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            NSString *textJS = [NSString stringWithFormat:@"resultQuery('%@')",resultDict.toJson];
            [self.webView stringByEvaluatingJavaScriptFromString:textJS completionHandler:^(id  _Nullable title, NSError * _Nullable error) {
            }];
        });
        
    }
}

- (NSString *)returnSafeString:(NSString *)str	{
    return IsStrEmpty(str)?@"":str;
}

- (void)getServiceStatusCallback:(void(^)(NSString *optStatus))callback error:(void(^)(NSString *responseStr))errorCallback		{
    
    NSString *url = [BASE_URL stringByAppendingFormat:get_local_services_URL,  [CustomerInfo sharedInstance].userBasicInfo.idpUserId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin,@""];
    
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        callback(responseStr);
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        errorCallback(responseStr);
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"POST"];
    [operation start];
}

- (void)showDemoShare	{
    _showDemoShareFlg = YES;
    _tempShowDemoShareFlg = YES;
    self.navigationItem.rightBarButtonItem = self.shareButtonItem;
}

- (void)showScreentShotShare	{
    _currentShareType = ShareTypeScreenShoot;
    self.navigationItem.rightBarButtonItem = self.shareButtonItem;
}

- (void)hideScreentShotShare	{
    _currentShareType = ShareTypeNone;
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)showURLImageShare:(NSString *)shareImageUrl		{
    _currentShareType = ShareTypeURlImage;
    _shareImageUrl = shareImageUrl;
    self.navigationItem.rightBarButtonItem = self.shareButtonItem;
}

#pragma mark -- MA 8.0 Method
- (void)changeCurrentTitle:(NSString *)title_	{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.title = title_;
    });
}

- (void)changeBackFunId:(NSString*)title		{
    if ([title isEqualToString:@"经销商预约"]) {
        self.backDaapFunctionID = Dealeraptm_appointment_back;
    }
}

- (void)callShowLoading	{
    [[LoadingView sharedInstance] startIn:self.view];
}

- (void)callHideLoading		{
    [[LoadingView sharedInstance] stop];
}

- (void)refreshRightBarButtonItem:(NSString *)title forwardUrl:(NSString *)forward		{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.forwardUrl = forward;
        if (!_customRightBarItem) {
            _customRightBarItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(forwardClick)];
        }
        self.navigationItem.rightBarButtonItem = self.customRightBarItem;
    });
}

- (void)goSettingPage	{
    SOSSettingViewController *settingVc = [[SOSSettingViewController alloc] init];
    settingVc.fromVC = @"smartDrive";
    settingVc.refreshH5Block = ^{
        dispatch_async_on_main_queue(^{
            [self.webView removeFromSuperview];
            self.webView = nil;
            [self.view addSubview:self.webView];
            [self loadThirdParty];
        });
    };
    [SOSUtil presentLoginFromViewController:((UINavigationController *)[SOS_APP_DELEGATE fetchMainNavigationController]).topViewController toViewController:settingVc];
}

- (void)showLoginViewController	{
    //忘记密码页面需dismiss
    [[SOS_APP_DELEGATE fetchRootViewController] dismissViewControllerAnimated:NO completion:^{
         [SOSUtil presentLoginFromViewController:((UINavigationController *)[SOS_APP_DELEGATE fetchMainNavigationController]).topViewController toViewController:nil];
    }];
    
   
}

#pragma mark - MA8.1 新增方法
- (void)MA_8_1_onstarPickPhoto:(NSDictionary *)para {
    [self.helper pickPhoto:para];
    
}
- (void)MA_9_3_onstarPickPhotos:(NSInteger)maxPhontoNum {
    [self.helper pickPhotos:maxPhontoNum];
}

- (void)MA_9_3_onstarGetUserLocationCallback:(void(^)(SOSPOI * currentP))callback{
    [self.helper getUserLocationCallback:callback];
}

- (void)MA_9_3_onstarRefreshFootPrint{
     [self.helper onstarRefreshFootPrint];
    
}

- (void)MA_8_1_goFunPage:(NSString *)para {
    [self.helper goFunPage:para];
}

#pragma mark - MA8.2 新增方法
- (void)MA_8_2_DAAP_sendActionInfo:(NSString *)funcId {
    [SOSDaapManager sendActionInfo:funcId];
}

- (void)MA_8_2_DAAP_sendSysBanner:(NSString *)funcId bannerId:(NSString *)bannerId {
    [SOSDaapManager sendSysBanner:bannerId funcId:funcId];
}

- (void)hideNavBar:(BOOL)hide	{
    [self.helper hideNavBar:hide];
}
//


- (void)coverBottomSafeArea:(BOOL)show {
    if (!IS_IPHONE_XSeries) {
        return;
    }
    NSUInteger tag = NSUIntegerMax - 22;
    UIView *view = [self.view viewWithTag:tag];
    if (!view) {
        view = [UIView new];
        view.backgroundColor = [UIColor whiteColor];
        view.tag = tag;
        [self.view addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.bottom.right.equalTo(self.view);
            make.height.mas_equalTo(34);
        }];
    }
    view.hidden = !show;
}

- (NSString *)sendVehicleConditionToHTML {
    return [self.helper sendVehicleConditionToHTML];
}
- (void)exitMyDonateRefresh {
    @weakify(self);
    [self setBackClickCompleteBlock:^{
        @strongify(self);
        [self.helper helperExitMyDonateRefresh];
    }];
}
#pragma mark - MA 8.4.1 新增方法
// 积分公益,用户未登录跳转到登录界面，用户为访客跳转到升级车主界面。用户为车主/司机/代理 且登录返回true,否则返回false
- (BOOL)isUserReadyForDonation		{
    // 调用 suit 成功
    if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
        // 用户是车主/司机/代理
        if ([SOSCheckRoleUtil isOwner] || [SOSCheckRoleUtil isDriverOrProxy]) {
            return YES;
            // 用户是访客
        }    else if ([SOSCheckRoleUtil isVisitor])     {
            [SOSCheckRoleUtil checkVisitorInPage:self];
        }
    // 登录中
    }    else if ([LoginManage sharedInstance].loginState > LOGIN_STATE_NON && [LoginManage sharedInstance].loginState < LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS)    {
        [Util toastWithMessage:@"登录中..."];
    // 获取 Suit 失败
    }    else if ([LoginManage sharedInstance].loginState == LOGIN_STATE_LOADINGUSERBASICINFOFAIL)    {
        [Util toastWithMessage:@"获取用户信息失败,请至首页下拉刷新"];
    }    else    {
        [[LoginManage sharedInstance] setDependenceIllegal:[[LoginManage sharedInstance] isLoadingUserBasicInfoReady]];
        [[LoginManage sharedInstance] checkAndShowLoginViewWithFromViewCtr:self andTobePushViewCtr:nil completion:^(BOOL finished) {
            if (finished) {
                [self.webView reload];
//                self.
            }
        }];
    }
    return NO;
}

#pragma mark - 9.0
- (void)showToast:(NSUInteger)flag text:(NSString *)text subText:(NSString *)subText {
    dispatch_sync_on_main_queue(^{
        [self.helper showToast:flag text:text subText:subText];
    });
}

- (void)dismissToast {
    [self.helper dismissToast];
}

- (void)showAlertWithType:(NSUInteger)flag title:(NSString *)title message:(NSString *)message cancelBtn:(NSString *)cancelBtn otherBtns:(NSString *)otherBtns callback:(void (^)(NSUInteger))callback {
    [self.helper showAlertWithType:flag title:title message:message cancelBtn:cancelBtn otherBtns:otherBtns callback:callback];
}

- (void)showForumShare:(NSString *)funcs sharedData:(NSString *)sharedData callback:(void (^)(NSUInteger))callback {
    [self.helper showForumShare:funcs sharedData:sharedData callback:callback];
}

- (void)pushNewWebViewControllerWithUrl:(NSString *)urlString {
    [self.helper pushNewWebViewControllerWithUrl:urlString];
}

- (void)goBannerPage:(NSString *)para {
    [self.helper goBannerPage:para];
}

- (BOOL)showLoginVCAndShouldCheckVisitor:(BOOL)shouldCheckVisitor {
    return [self.helper showLoginVCAndShouldCheckVisitor:shouldCheckVisitor];
}
@end
