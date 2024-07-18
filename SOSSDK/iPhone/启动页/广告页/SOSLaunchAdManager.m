//
//  SOSLaunchAdManager.m
//  Onstar
//
//  Created by Creolophus on 2020/3/6.
//  Copyright © 2020 Shanghai Onstar. All rights reserved.
//

#import "SOSLaunchAdManager.h"
#import "ResponseDataObject.h"
#import <XHLaunchAd/XHLaunchAd.h>
//#import <XHLaunchAd.h>


@interface SOSLaunchAdManager ()<XHLaunchAdDelegate>
@property (strong, nonatomic) UIButton *skipButton;
@property (assign, nonatomic) BOOL didTapAD;
@property (assign, nonatomic) NSTimeInterval adDuration;

@end

@implementation SOSLaunchAdManager

//+(void)load{
//    [SOSLaunchAdManager shareManager];
//}


+ (instancetype)shareManager{
    static SOSLaunchAdManager *instance = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken,^{
        instance = [[SOSLaunchAdManager alloc] init];
    });
    return instance;
}

- (void)setup {
//    return;
    [XHLaunchAd setLaunchSourceType:SourceTypeLaunchScreen];
    [XHLaunchAd setWaitDataDuration:5];
    
    NSString *url = [BASE_URL stringByAppendingString:NEW_GET_LANDING_IMAGE_URL];
    //url = [url stringByAppendingString:[NSString stringWithFormat:@"?OSType=%@",[Util currentDeviceType]]];
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    d[@"osType"] = [Util currentDeviceType];
    NSString *s = [Util jsonFromDict:d];
    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:s successBlock:^(SOSNetworkOperation *operation, id returnData) {
        [self parseLandingPageResponse:returnData];
//        [self configVideo];
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        NNErrorDetail *detail = [NNErrorDetail mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
        if ([[detail code] isEqualToString:@"E2011"]) {
//            [_imageArray removeAllObjects];
//            [self save];
        }
    }];
    [sosOperation setHttpMethod:@"POST"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
//
}

- (void)parseLandingPageResponse:(id)responseData
{
    NNLandingPage *landingResponse = [NNLandingPage mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseData]];
//    LandingImage *landingImgObj = [[LandingImage alloc] initWithLandingResponse:landingResponse];
//    [self addImageToCache:landingImgObj];
//    [self save];
    _adDuration = [Util isValidNumber:landingResponse.duration] ? landingResponse.duration.integerValue / 1000 : 5;
    if (landingResponse.imageURL.length <= 0) {
        [XHLaunchAd removeAndAnimated:YES];
        return;
    }
    if ([landingResponse.pageType.uppercaseString isEqualToString:@"VIDEO"]) {
        [self configVideo:landingResponse];
    }else {
        [self configImage:landingResponse];
    }
    
}

- (void)configVideo:(NNLandingPage *)landingPage {
    XHLaunchVideoAdConfiguration *videoAdconfiguration = [XHLaunchVideoAdConfiguration new];
    videoAdconfiguration.duration = _adDuration;
    //广告frame
    videoAdconfiguration.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    //广告视频URLString/或本地视频名(请带上后缀)
    //注意:视频广告只支持先缓存,下次显示(看效果请二次运行)
    videoAdconfiguration.videoNameOrURLString = landingPage.imageURL;
    videoAdconfiguration.muted = NO;
    videoAdconfiguration.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //是否只循环播放一次
    videoAdconfiguration.videoCycleOnce = NO;
    //广告点击打开页面参数(openModel可为NSString,模型,字典等任意类型)
    videoAdconfiguration.openModel = landingPage;
    //广告显示完成动画
    videoAdconfiguration.showFinishAnimate = ShowFinishAnimateNone;
    videoAdconfiguration.customSkipView = self.skipButton;
    [XHLaunchAd videoAdWithVideoAdConfiguration:videoAdconfiguration delegate:self];
}

- (void)configImage:(NNLandingPage *)landingPage {
    XHLaunchImageAdConfiguration *imageAdconfiguration = [XHLaunchImageAdConfiguration defaultConfiguration];
    imageAdconfiguration.showFinishAnimate = ShowFinishAnimateNone;
    imageAdconfiguration.imageOption = XHLaunchAdImageCacheInBackground;
    imageAdconfiguration.customSkipView = self.skipButton;
    //广告图片URLString/或本地图片名(.jpg/.gif请带上后缀)
    imageAdconfiguration.imageNameOrURLString = landingPage.imageURL;
    //广告点击打开链接
    imageAdconfiguration.openModel = landingPage;;
    imageAdconfiguration.duration = _adDuration;
    //显示图片开屏广告
    [XHLaunchAd imageAdWithImageAdConfiguration:imageAdconfiguration delegate:self];

}

#pragma mark - launchAd delegate
-(void)xhLaunchAd:(XHLaunchAd *)launchAd videoDownLoadFinish:(NSURL *)pathURL {
    
//    _shapeLayer = shapeLayer;
}

- (BOOL)xhLaunchAd:(XHLaunchAd *)launchAd clickAtOpenModel:(id)openModel clickPoint:(CGPoint)clickPoint {
    if (![openModel isKindOfClass:NNLandingPage.class]) {
        return NO;
    }
    NNLandingPage *landingPage = (NNLandingPage *)openModel;
    if (landingPage.url.length <= 0) {
        return NO;
    }

    SOSWebViewController *web = [[SOSWebViewController alloc] initWithUrl:landingPage.url];
    web.shouldDismiss = YES;
    web.isH5Title = landingPage.isTitle.integerValue;
    web.titleStr = landingPage.title;
    //判断是否可以分享
    if ([landingPage.canShare isEqualToString:@"1"])     {
        web.alwaysShareFlg = YES;
        web.shareUrl = landingPage.url;
        web.shareImg = landingPage.thumbnailUrl;
    }
    _didTapAD = YES;
//    [SOS_APP_DELEGATE showHomePageWithComplete:^{
        CustomNavigationController *navi = [[CustomNavigationController alloc] initWithRootViewController:web];
        [SOS_ONSTAR_WINDOW.rootViewController presentViewController:navi animated:YES completion:nil];
//    }];
//    [XHLaunchAd removeAndAnimated:NO];
    return YES;
}

- (void)xhLaunchAd:(XHLaunchAd *)launchAd customSkipView:(UIView *)customSkipView duration:(NSInteger)duration {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CAShapeLayer *shapeLayer = [CAShapeLayer new];
        shapeLayer.frame = CGRectMake(0, 0, 40, 40);
        shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 40, 40) cornerRadius:20].CGPath;
        shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        shapeLayer.lineWidth = 2;
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        [self.skipButton.layer addSublayer:shapeLayer];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        animation.duration = _adDuration;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.fromValue = [NSNumber numberWithFloat:0.0f];
        animation.toValue = [NSNumber numberWithFloat:1.0f];
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        [shapeLayer addAnimation:animation forKey:nil];
    });
}

- (void)xhLaunchAdShowFinish:(XHLaunchAd *)launchAd {
//    if (_didTapAD) {
//        return;
//    }
//    [SOS_APP_DELEGATE showHomePage];
    [self clearCache];
}

- (UIButton *)skipButton {
    if (!_skipButton) {
        UIButton *skipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [skipBtn setTitle:@"跳过" forState:UIControlStateNormal];
        [skipBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        skipBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        skipBtn.backgroundColor = [UIColor colorWithRed:0.00f green:0.00f blue:0.00f alpha:0.30f];
        skipBtn.layer.cornerRadius = 20;
        [skipBtn addTarget:self action:@selector(dismissWithComplete) forControlEvents:UIControlEventTouchUpInside];
        skipBtn.size = CGSizeMake(40, 40);
        skipBtn.top = STATUSBAR_HEIGHT;
        skipBtn.right = SCREEN_WIDTH - 20;
        _skipButton = skipBtn;
    }
    return _skipButton;
}

- (void)dismissWithComplete {
    [XHLaunchAd removeAndAnimated:YES];
//    [SOS_APP_DELEGATE showHomePage];

}

- (void)clearCache {
    if (XHLaunchAd.diskCacheSize >= 20) {
        [XHLaunchAd clearDiskCache];
    }
}

@end
