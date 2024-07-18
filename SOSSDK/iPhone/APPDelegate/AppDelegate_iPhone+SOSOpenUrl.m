//
//  AppDelegate_iPhone+SOSOpenUrl.m
//  Onstar
//
//  Created by lizhipan on 2017/9/15.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "AppDelegate_iPhone+SOSOpenUrl.h"
#import "OwnerLifeVehicleDetectionController.h"
//#import "ViewControllerAssistantOVDEmail.h"
#import "AppDelegate_iPhone+SOSService.h"
#import "SOSCarSecretaryViewController.h"
#import "SOSMsgHotActivityController.h"
#import "OwnerLifeRenewalController.h"
#import "HandleDataRefreshDataUtil.h"
#import "SOSLandingViewController.h"
#import "SOSMsgCenterController.h"
#import "CarOperationWaitingVC.h"
#import "NSString+Category.h"

//#import "SOSOMScanManager.h"
#import "SOSTripPOIVC.h"
#import "SOSCardUtil.h"

#ifndef SOSSDK_SDK
#import "SOSDRScanManager.h"
#import "SOSGroupTripInviteTool.h"
#import "SOSRearviewMirrorEnterController.h"
#import "SOSIMTabBarController.h"
#else
#import "SOSPay.h"
#endif

#import "WeiXinManager.h"

#if __has_include("SOSSDK.h")
#import "SOSSDK.h"
#endif

#if __has_include(<BlePatacSDK/BlueToothManager.h>)
#import "SOSBleUtil.h"
#endif


@implementation AppDelegate_iPhone (SOSOpenUrl)

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    NSLog(@"===%@,%@,%@",url,url.scheme,url.host);
    /// 9.3.2后统一跳转规则onstar://[businessName]?param=xxx&param2=xxx
#ifndef SOSSDK_SDK
    if ([url.absoluteString.lowercaseString hasPrefix:@"onstar".lowercaseString]) {
        // onstar://groupTrip?teamId=123;
        if ([url.host.lowercaseString containsString:@"groupTrip".lowercaseString]) {
            NSDictionary *params = [Util parseURLParam:url.absoluteString];
            NSString *teamId = params[@"teamId"] ? : @"";
            [LoginManage sharedInstance].loginSuccessAction = ^{
                [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:[SOS_APP_DELEGATE fetchMainNavigationController] withLoginDependence:[[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin] showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
                    [SOSGroupTripInviteTool tryJoinTeam:teamId result:nil];
                }];
                
            };
            
        }
        else {
            [Util showErrorHUDWithStatus:@"无法识别，请尝试更新最新版安吉星"];
        }
        return YES;
    }
#endif
    if([[url absoluteString] rangeOfString:@"com.onstar.newlink://"].length > 0)	{
        // 里程险we.chat.pay返回回调
        if ([url.host containsString:@"kaikaibao.com"])            {
            NSString *finalURL = [url.absoluteString substringFromIndex:url.scheme.length];
            finalURL = [@"https" stringByAppendingString:finalURL];
            UIViewController *topVC = SOS_APP_DELEGATE.fetchMainNavigationController.topViewController;
            if ([topVC isKindOfClass:NSClassFromString(@"SOSThirdPartyWebVC")]) {
                [topVC performSelector:@selector(loadURL:) withObject:finalURL afterDelay:.5];
            }
            return YES;
        }
        // 短息分享位置的URL com.onstar.newlink://
        [self openShareDestinationURL:url];
    }    else if([[url absoluteString] rangeOfString:@"sos.m://web"].length > 0)	{
        if ([url.absoluteString containsString:@"om="]) {
            if ([url.absoluteString rangeOfString:@"om="].length > 0) { // 一体机
                NSString *imei = url.absoluteString;
                [self openOMVC:imei];
            }
        }else if ([url.absoluteString containsString:@"dc="]) {
            if ([url.absoluteString rangeOfString:@"dc="].length > 0) { // 行车记录仪
                NSString *imei = url.absoluteString;
                [self openDRVC:imei];
            }
        }	else if ([url.absoluteString containsString:@"type=mirror"]) {
            if ([[url absoluteString] rangeOfString:@"type=mirror"].length > 0){  //微信扫码拉起app，进入后视镜
                [self openRVMirror:[self getIMEI:[url absoluteString]]];
            }
        }	else	{
                //短信打开webview sos.m://web
                [self smsOpenWebView:url];
        }
    }
#ifdef SOSSDK_SDK
    else if ([[url absoluteString] rangeOfString:[SOSSDKKeyUtils paySchemeUrl]].length > 0) {
        //跳转支付宝钱包进行支付，需要将支付宝钱包的支付结果回传给SDK
        [SOSPay openURL:url];
    }
#endif
#if __has_include(<BlePatacSDK/BlueToothManager.h>)
    
    else if ([[url absoluteString] rangeOfString:[SOSSDKKeyUtils bleSchemeUrl]].length > 0){
        
        [SOSBleUtil showReceiveAlertControllerWithUrl:[url absoluteString]];
    }
#endif
    else    {
        BOOL retWeixin = [WXApi handleOpenURL:url delegate:self];
        if (retWeixin) {
            NSLog(@"from Weixin url is %@", [url absoluteString]);
            
        }else {
            if ([url.host isEqualToString:@"ovdReport"]) {
                [self openOVD];
            }else {
                NSLog(@"can not be open by url %@", [url absoluteString]);
            }
        }
#ifndef SOSSDK_SDK
        if ([Util isNotEmptyString:[url query]]) {
            [self openShareDestinationURL:url];
        }
#endif
        return YES;//(retWeixin || retWeibo);
    }
    return YES;
}
//短信打开webview

- (NSDictionary *)getUrlParamsWithUrl:(NSURL *)url {
    NSArray * seperateArray=[[url query] componentsSeparatedByString:@"&"];
    NSMutableDictionary * paramDict=[NSMutableDictionary dictionaryWithCapacity:[seperateArray count]];
    for(NSString * str in seperateArray){
        NSArray * keyAndValueArray=[str componentsSeparatedByString:@"="];
        if (keyAndValueArray.count>2) {
            NSString * valueStr=[[keyAndValueArray objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            // GBK convert
            if (!valueStr) {
                NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                valueStr=[[keyAndValueArray objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:gbkEncoding];
            }
            [paramDict setValue:NONil(valueStr) forKey:[keyAndValueArray objectAtIndex:0]];
        }
        
    }
    return paramDict;
}

- (void)smsOpenWebView:(NSURL *)url	{
    NSDictionary *paramDict = [self getUrlParamsWithUrl:url];
    
    BOOL needLogin = NO;
    NSString * link = nil;
    if([paramDict objectForKey:@"login"] && ![[paramDict objectForKey:@"login"] isEqualToString:@""]){
        needLogin=[[paramDict objectForKey:@"login"]  isEqualToString:@"Y"]?YES:NO;
    }
    else{
        needLogin=NO;
    }
    if([paramDict objectForKey:@"url"] && ![[paramDict objectForKey:@"url"] isEqualToString:@""]){
        NSString *embeded=[paramDict objectForKey:@"url"];
        if(embeded.length > 0){
            if([embeded containsString:@"http://"]||[embeded containsString:@"https://"]){
                link = embeded;
            }else
            {
                link =[ NSString stringWithFormat:@"http://%@",embeded];
            }
        }
        if(needLogin){
            [self openWebViewAfterLogin:link];
        }else{
            [self openWebViewNonLogin:link];
        }
    }
    
}

-(NSString*)getIMEI:(NSString*)str
{
    NSRange r = [str rangeOfString:@"tempid="];
    NSInteger start = r.location + r.length;
    if (r.location >0) {
        return [str substringFromIndex:start];
    }else
    {
        return @"";
    }
}
#pragma mark 跳转一体机
- (void)openOMVC:(NSString *)imei {
    if ([LoginManage sharedInstance].loginState == LOGIN_STATE_NON) {
            NSLog(@"---安吉星未登录");
#ifndef SOSSDK_SDK
        [SOSDaapManager sendActionInfo:Rearview_wechatlocationshare_openinapp];
        //已登陆直接跳界面，未登陆跳登陆
        [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:[SOS_APP_DELEGATE fetchMainNavigationController] withLoginDependence:[[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin] showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
            
        }];
#endif
    }else if ([LoginManage sharedInstance].loginState == LOGIN_STATE_LOADINGVEHICLEPRIVILIGESUCCESS) {
//        NSString *omID = [SOSOTempidModel getImid:imei];
//        if ([NSString isBlankString:omID]) {
//            return;
//        }
//        [SOSOMScanManager requestOMBindToken:omID failCallBlock:nil];
    }
}
#pragma mark 跳转行车记录仪
- (void)openDRVC:(NSString *)imei {
    #ifndef SOSSDK_SDK
    if ([LoginManage sharedInstance].loginState == LOGIN_STATE_NON) {
        NSLog(@"---安吉星未登录");

        [SOSDaapManager sendActionInfo:Rearview_wechatlocationshare_openinapp];
        //已登陆直接跳界面，未登陆跳登陆
        [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:[SOS_APP_DELEGATE fetchMainNavigationController] withLoginDependence:[[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin] showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
            
        }];

    }else if ([LoginManage sharedInstance].loginState == LOGIN_STATE_LOADINGVEHICLEPRIVILIGESUCCESS) {
        NSString *encryptedStr = [SOSDRIMEIModel getImid:imei];
        if ([NSString isBlankString:encryptedStr]) {
            return;
        }
        [SOSDRScanManager requestValidityDevicesCheckEncryptedStr:encryptedStr failCallBlock:nil];
    }
    #endif
}
-(void)openRVMirror:(NSString*)imei {
#ifndef SOSSDK_SDK
    [SOSDaapManager sendActionInfo:Rearview_wechatlocationshare_openinapp];
    //已登陆直接跳界面，未登陆跳登陆
    [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:[SOS_APP_DELEGATE fetchMainNavigationController] withLoginDependence:[[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin] showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
        SOSRearviewMirrorEnterController *vc = [[SOSRearviewMirrorEnterController alloc] init];
        vc.fromVC = @"H5";
        [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:vc animated:YES];
        [vc getRvToken:imei];
    }];
#endif
}


#pragma mark - share destination
/**
 *短息分享位置相关处理
 */
- (void)openShareDestinationURL:(NSURL *)url     {
    NSArray * seperateArray=[[url query] componentsSeparatedByString:@"&"];
    NSMutableDictionary * paramDict=[NSMutableDictionary dictionaryWithCapacity:[seperateArray count]];
    for(NSString * str in seperateArray){
        NSArray * keyAndValueArray=[str componentsSeparatedByString:@"="];
        
        NSString * valueStr=[[keyAndValueArray objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        // GBK convert
        if (!valueStr) {
            NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            valueStr=[[keyAndValueArray objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:gbkEncoding];
        }
        [paramDict setValue:NONil(valueStr) forKey:[keyAndValueArray objectAtIndex:0]];
    }
    
    // 当做绑定帐号与分享位置的操作时不需要做后续的处理
    if (paramDict == nil || ![paramDict.allKeys containsObject:@"poiName"]) {
        return;
    }
    
    // from autonavi auto send tbt
    //    if ([AUTONAVI_SCHEME isEqualToString: url.scheme]) {
    //        // record report
    //        //        ReportRecord *record = [[SOSReportService shareInstance]
    //        //                                createRecordWithFunctionID:REPORT_AUTO_SEND_TBT
    //        //                                StartTime:[NSDate date]
    //        //                                EndTime:[NSDate date]
    //        //                                Operation:REPORT_OPPERATION_ACCEPT
    //        //                                Content:AUTONAVI_TBT_REPORT_CONTENT];
    //        //        [[SOSReportService shareInstance] recordAction:record];
    //    }
    
    if(shareDestinationDict){
        [shareDestinationDict removeAllObjects];
    }
    else{
        shareDestinationDict=[[NSMutableDictionary alloc] initWithCapacity:[seperateArray count]];
    }
    NSString * message=nil;
    NSString * poiNameStr=nil;
    NSString * addressStr=nil;
    if([paramDict objectForKey:@"poiName"] && ![[paramDict objectForKey:@"poiName"] isEqualToString:@""]){
        poiNameStr=[paramDict objectForKey:@"poiName"];
    }
    else{
        poiNameStr=NSLocalizedString(@"ShareDestination", nil);
    }
    if([paramDict objectForKey:@"address"] && ![[paramDict objectForKey:@"address"] isEqualToString:@""]){
        addressStr=[paramDict objectForKey:@"address"];
    }
    else{
        addressStr=@"----";
    }
    message=[NSString stringWithFormat:NSLocalizedString(@"ShareDestinationReceivedMessageAlert", nil),poiNameStr,addressStr];
    
    [shareDestinationDict setValue:NONil([paramDict objectForKey:@"city"]) forKey:K_SEARCH_RESULT_CITY_NAME];
    [shareDestinationDict setValue:NONil([paramDict objectForKey:@"province"]) forKey:K_SEARCH_RESULT_PROVINCE_NAME];
    [shareDestinationDict setValue:NONil([paramDict objectForKey:@"phoneNo"]) forKey:K_SEARCH_RESULT_PHONE_NUMBER];
    if([paramDict objectForKey:@"poiName"] && ![[paramDict objectForKey:@"poiName"] isEqualToString:@""]){
        [shareDestinationDict setValue:NONil([paramDict objectForKey:@"poiName"]) forKey:K_SEARCH_RESULT_NAME];
    }
    if([paramDict objectForKey:@"address"] && ![[paramDict objectForKey:@"address"] isEqualToString:@""]){
        [shareDestinationDict setValue:NONil([paramDict objectForKey:@"address"]) forKey:K_SEARCH_RESULT_ADDRESS];
    }
    else if([paramDict objectForKey:@"poiDescription"] && ![[paramDict objectForKey:@"poiDescription"] isEqualToString:@""]){
        [shareDestinationDict setValue:NONil([paramDict objectForKey:@"poiDescription"])
                                forKey:K_SEARCH_RESULT_LOCATION_NAME];
    }
    NSMutableDictionary *coordinateDict = [[NSMutableDictionary alloc] init];
    NSString *latitude = [paramDict objectForKey:@"latitude"];
    [coordinateDict setObject:NONil(latitude) forKey:K_LATITUDE];
    NSString *longitude = [paramDict objectForKey:@"longitude"];
    [coordinateDict setObject:NONil(longitude) forKey:K_LONGITUDE];
    [shareDestinationDict setObject:coordinateDict forKey:K_POI_COORDINATE];
    
    // auto send TBT flag
    if([paramDict objectForKey:@"autoSendToTBT"] &&
       ![[paramDict objectForKey:@"autoSendToTBT"] isEqualToString:@""]){
        [shareDestinationDict setValue:NONil([paramDict objectForKey:@"autoSendToTBT"])
                                forKey:K_AUTO_SEND_TO_TBT];
        [self autoTBT];
        return;
    }
    
    if(shortLinkId){
        shortLinkId=nil;
    }
    shortLinkId=[paramDict objectForKey:@"shortlinkId"];
    
    NSLog(@"share destination dict %@", shareDestinationDict);
#if __has_include("SOSSDK.h")
    [SOSSDK sos_showOnstarModuleWithDismissBlock:nil];
#endif
    
    [Util showAlertWithTitle:nil message:message completeBlock:^(NSInteger buttonIndex) {
        if(buttonIndex==1)    {
            [self doSharePosition];
        } else {
            
        }
        
    } cancleButtonTitle:NSLocalizedString(@"AlertCancelButton", nil) otherButtonTitles:NSLocalizedString(@"AlertOKButton", nil), nil];
    
}
- (void)doSharePosition
{
#if __has_include("SOSSDK.h")
    [SOSSDK sos_showOnstarModuleWithDismissBlock:nil];
#endif
    
    SOSTripPOIVC *mapVCForPoiShow = [[SOSTripPOIVC alloc] initWithPOI:[Util convertToSOSpoiFromDict:shareDestinationDict]];
    mapVCForPoiShow.mapType = MapTypeShowPoiPoint;
    if ([self.window.rootViewController isKindOfClass:[SOSLandingViewController class]])  {
        SOSLandingViewController * landingView =((SOSLandingViewController*)self.window.rootViewController);
        [landingView setCompleteBlock:^{
            [self showHomePage];
            [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:mapVCForPoiShow animated:YES];
        }];
    }else {
        [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:mapVCForPoiShow animated:YES];
    }
}
/*
 *! @brief
 * auto send tbt
 */
- (void)autoTBT
{
#if __has_include("SOSSDK.h")
    [SOSSDK sos_showOnstarModuleWithDismissBlock:nil];
#endif
    
    SOSTripPOIVC *mapVCForPoiShow = [[SOSTripPOIVC alloc] initWithPOI:[Util convertToSOSpoiFromDict:shareDestinationDict]];
    mapVCForPoiShow.mapType = MapTypeShowPoiPoint;
    CarOperationWaitingVC *operationVC = [CarOperationWaitingVC initWithPoi:[Util convertToSOSpoiFromDict:shareDestinationDict] Type:OrderTypeAuto FromVC:nil];
    if ([self.window.rootViewController isKindOfClass:[SOSLandingViewController class]])  {
        SOSLandingViewController * landingView =((SOSLandingViewController*)self.window.rootViewController);
        [landingView setCompleteBlock:^{
            [self showHomePage];
            [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:mapVCForPoiShow animated:YES];
            [operationVC checkAndShowFromVC:mapVCForPoiShow needToastMessage:NO needShowWaitingVC:YES completion:^{ }];
        }];
        
    }   else {
        [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:mapVCForPoiShow animated:YES];
        [operationVC checkAndShowFromVC:mapVCForPoiShow needToastMessage:NO needShowWaitingVC:YES completion:^{ }];
        
    }
}




- (void)openWebView:(NSString *)url {
    void (^completionBlock)(void) = ^(){
#if __has_include("SOSSDK.h")
        [SOSSDK sos_showOnstarModuleWithDismissBlock:nil];
#endif
        
        [[SOS_APP_DELEGATE fetchMainNavigationController] dismissViewControllerAnimated:YES completion:nil];
        if ([url containsString:@"/mweb-main/static/OnStar-MA7.0-h5/html/driving-scores/driving-score.html"]) {
            [HandleDataRefreshDataUtil drivingBehavior:[SOS_APP_DELEGATE fetchMainNavigationController]];
        }    else    {
            SOSWebViewController *webVC = [[SOSWebViewController alloc] initWithUrl:url];
            CustomNavigationController *navi = [[CustomNavigationController alloc] initWithRootViewController:webVC];
            [SOS_ONSTAR_WINDOW.rootViewController presentViewController:navi animated:YES completion:nil];
        }
    };
    if ([[LoginManage sharedInstance] isLoadingMainInterfaceReady]) {    //完整登陆，打开网页
        completionBlock();
    }	else	{
        [[LoginManage sharedInstance] setOncompletion:^(BOOL loginComplete){ //未登陆或非完整登陆，设置回调，下次走登陆后调用
            if (loginComplete) {
                completionBlock();
            }
        }];
        
        //检测是否登陆，未登陆，登陆后走上面block，已登陆但信息获取不完整，走自己的回调打开网页
        [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:[SOS_APP_DELEGATE fetchMainNavigationController] withLoginDependence:[[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin] showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
            completionBlock();
        }];
    }
    
    
    
}

- (void)openWebViewNonLogin:(NSString *)url    {
    if([url length]>0){
#if __has_include("SOSSDK.h")
        [SOSSDK sos_showOnstarModuleWithDismissBlock:nil];
#endif
        
        SOSWebViewController *webVC = [[SOSWebViewController alloc] initWithUrl:url];
        if ([self.window.rootViewController isKindOfClass:[SOSLandingViewController class]]){
            SOSLandingViewController *landingView =((SOSLandingViewController*)self.window.rootViewController);
            [landingView setCompleteBlock:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showHomePageWithComplete:^{
                        CustomNavigationController *navi = [[CustomNavigationController alloc] initWithRootViewController:webVC];
                        [SOS_ONSTAR_WINDOW.rootViewController presentViewController:navi animated:YES completion:nil];
                    }];
                });
            }];
            
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[SOS_APP_DELEGATE fetchMainNavigationController] dismissViewControllerAnimated:YES completion:^{
                    [[SOS_APP_DELEGATE fetchRootViewController] presentViewController:webVC animated:YES completion:nil];
                }];
            });
        }
    }
}


- (void)openWebViewWithHotMsg:(NSString *)url    {
#if __has_include("SOSSDK.h")
    [SOSSDK sos_showOnstarModuleWithDismissBlock:nil];
#endif
    SOSMsgHotActivityController *vc = [[SOSMsgHotActivityController alloc] init];
    vc.isPush = YES;
    vc.pushUrl = url;
    if ([self.window.rootViewController isKindOfClass:[SOSLandingViewController class]]){
        SOSLandingViewController *landingView =((SOSLandingViewController*)self.window.rootViewController);
        [landingView setCompleteBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showHomePage];
                [[SOS_APP_DELEGATE fetchMainNavigationController] dismissViewControllerAnimated:YES completion:nil];
                [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:vc animated:YES];
            });
        }];
        
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[SOS_APP_DELEGATE fetchMainNavigationController] dismissViewControllerAnimated:YES completion:nil];
            [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:vc animated:YES];
        });
    }
}


- (void)jumpToRemoteView
{
    dispatch_async(dispatch_get_main_queue(), ^{
#if __has_include("SOSSDK.h")
        [SOSSDK sos_showOnstarModuleWithDismissBlock:nil];
#endif
        
        [SOSCardUtil routerToRemoteControl];
    });
    
}
- (void)jumpToHomepage{
    dispatch_async(dispatch_get_main_queue(), ^{
#if __has_include("SOSSDK.h")
        [SOSSDK sos_showOnstarModuleWithDismissBlock:nil];
#endif
        
        if ([SOS_APP_DELEGATE fetchMainNavigationController].presentedViewController) {
            [[SOS_APP_DELEGATE fetchMainNavigationController] dismissViewControllerAnimated:YES completion:^(){
            }];
        }
        else
        {
            [[SOS_APP_DELEGATE fetchMainNavigationController] popToRootViewControllerAnimated:NO] ;
        }
    });
}


- (void)openWebViewAfterLogin:(NSString *)url    {
    if ([self.window.rootViewController isKindOfClass:[SOSLandingViewController class]]) {
        SOSLandingViewController *landingView =((SOSLandingViewController*)self.window.rootViewController);
        [landingView setCompleteBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showHomePage];
                [self openWebView:url];
            });
        }];
    }else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self openWebView:url];
        });
    }
}

- (void)openOVD
{
    if ([self.window.rootViewController isKindOfClass:[SOSLandingViewController class]]) {
        @weakify(self);
        SOSLandingViewController * landingView =((SOSLandingViewController*)self.window.rootViewController);
        [landingView setCompleteBlock:^{
            @strongify(self);
            [self showHomePage];
        }];
        
    }   else    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UINavigationController *nav = (UINavigationController *)[SOS_APP_DELEGATE fetchMainNavigationController];
            if (nav.viewControllers.count >1) {
                [nav popToRootViewControllerAnimated:NO];
            }
            [self pushOVDController];
        });
    }
}
#pragma mark---***通过url sheme 打开ovd界面
- (void)pushOVDController
{
    if (![LoginManage sharedInstance].loginNav.presentingViewController) {
        //[[SOSReportService shareInstance] recordActionWithFunctionID:Find_Diagnostics];
        //        ViewControllerAssistantOVDEmail* pushedCon = [[ViewControllerAssistantOVDEmail alloc]initWithNibName:@"ViewControllerAssistantOVDEmail" bundle:nil];
#if __has_include("SOSSDK.h")
        [SOSSDK sos_showOnstarModuleWithDismissBlock:nil];
#endif
        [SOSCardUtil routerToVehicleDetectionReport];
        
    }
}


#pragma mark WeiXin Delegate
/*! @brief 收到一个来自微信的请求，处理完后调用sendResp
 *
 * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
 * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
 * @param req 具体请求内容，是自动释放的
 */
- (void)onReq:(BaseReq*)req     {
    NSLog(@"收到一个来自微信的请求，处理完后调用sendResp");
    
    if([req isKindOfClass:[GetMessageFromWXReq class]])        {
        // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
        [WeiXinManager shareInstance].fromWeixin = YES;
    }     else if([req isKindOfClass:[ShowMessageFromWXReq class]])        {
        //微信通知第三方程序，要求第三方程序显示的消息结构体
    }
}

/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp具体的回应内容，是自动释放的
 */
- (void)onResp:(BaseResp*)resp     {
    NSLog(@"发送一个sendReq后，收到微信的回应");
    NSString *message ;
    switch (resp.errCode) {
            //        case WXSuccess:
            //            message = NSLocalizedString(@"sendSuccess", nil);
            //            break;
        case WXErrCodeSentFail:
            message = NSLocalizedString(@"sendFailed", nil);
            break;
            //        case WXErrCodeUserCancel:
            //            message = NSLocalizedString(@"sendCancel", nil);
        default:
            break;
    }
    if ([resp isKindOfClass:[SendMessageToWXResp class]] && message) {
        [Util showAlertWithTitle:nil message:message completeBlock:nil];
    }
    
}
@end
