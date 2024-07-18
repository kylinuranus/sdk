//
//  SOSVehicleConditionShareWebController.m
//  Onstar
//
//  Created by TaoLiang on 2018/9/4.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSVehicleConditionShareWebController.h"
#import "SOSPhotoLibrary.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "WeiXinManager.h"
#ifndef SOSSDK_SDK
#import "SOSIMApi.h"
#endif
#import "SOSSocialContactShareView.h"
#import "SOSFlexibleAlertController.h"

@interface SOSVehicleConditionShareWebController ()<UIScrollViewDelegate>
@property (weak, nonatomic) UIButton *shareBtn;
@property (weak, nonatomic) UIButton *downloadBtn;
@property (strong, nonatomic) UIView *bottomPromptView;

@end

@implementation SOSVehicleConditionShareWebController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.fd_prefersNavigationBarHidden = YES;
    self.webView.wkWebView.scrollView.delegate = self;
    if (@available(iOS 11, *)) {
        [self.webView.getScrollViewOfWebview setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    } else {

    }
    UIView *customNavBar = [UIView new];
    customNavBar.backgroundColor = [UIColor clearColor];
//    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
//    gradientLayer.colors = @[(__bridge id)[UIColor colorWithRGB:0x031324 alpha:0.39].CGColor, (__bridge id)[UIColor clearColor].CGColor];
//    gradientLayer.startPoint = CGPointMake(0, 0);
//    gradientLayer.endPoint = CGPointMake(0, 1.0);
//    gradientLayer.frame = CGRectMake(0, -STATUSBAR_HEIGHT, SCREEN_WIDTH, 44 + STATUSBAR_HEIGHT);
//    [customNavBar.layer addSublayer:gradientLayer];
    
    [self.view addSubview:customNavBar];
    [customNavBar mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.view.sos_top);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(44);
    }];

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.tintColor = [UIColor sos_ColorWithHexString:@"828389"];
    [backBtn setImage:[[UIImage imageNamed:@"icon_arrow_left_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [backBtn addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    [customNavBar addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerY.equalTo(customNavBar);
        make.left.equalTo(@15);
        make.size.equalTo(@25);
    }];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.tintColor = [UIColor sos_ColorWithHexString:@"828389"];
    [shareBtn setImage:[[UIImage imageNamed:@"icon_share_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(showShare) forControlEvents:UIControlEventTouchUpInside];
    [customNavBar addSubview:shareBtn];
    shareBtn.hidden = YES;
    [shareBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerY.equalTo(customNavBar);
        make.right.equalTo(@-15);
        make.size.equalTo(@25);
    }];
    _shareBtn = shareBtn;

    UIButton *downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [downloadBtn addTarget:self action:@selector(downloadImage) forControlEvents:UIControlEventTouchUpInside];
    [downloadBtn setImage:[UIImage imageNamed:@"sharecar-icon-download"] forState:UIControlStateNormal];
    [self.view addSubview:downloadBtn];
    downloadBtn.hidden = YES;
    [downloadBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(@-15);
        make.bottom.equalTo(self.view.sos_bottom).offset(-15);
    }];
    _downloadBtn = downloadBtn;
}

#pragma mark - action
- (void)showShare {
    
    [SOSDaapManager sendActionInfo:SMARTVEHICLE_CAR_CONDITION_LONG_GRAPH_SHARE_SHARE];
    UIImage *image = [self webViewSnapshot];
    
    SOSSocialContactShareView *view = [SOSSocialContactShareView viewFromXib];
    view.shareChannels = @[
#ifndef SOSSDK_SDK
                              @{
                                  @"icon":@"onstarFrends",
                                  @"title":@"安吉星好友"
                                  },
#endif
                              @{
                                  @"icon":@"Icon／34x34／icon_share_weixin_34x34",
                                  @"title":@"微信好友"
                                  },
                              @{
                                  @"icon":@"wxfrend",
                                  @"title":@"朋友圈"
                                  },
                              @{
                                  @"icon":@"systemmore",
                                  @"title":@"更多"
                                  },
                              
                              ];
    SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:nil
                                                                                    title:nil
                                                                                  message:nil
                                                                               customView:view
                                                                           preferredStyle:SOSAlertControllerStyleActionSheet];
    @weakify(vc)
    view.shareTapBlock = ^(NSInteger index) {
        @strongify(vc)
        [vc dismissViewControllerAnimated:YES completion:nil];
#ifdef SOSSDK_SDK
        index++;
#endif
        if (index == 0) {
            #ifndef SOSSDK_SDK
            [SOSDaapManager sendActionInfo:SMARTVEHICLE_CAR_CONDITION_LONG_GRAPH_SHARE_SHARE_ONSTARCHAT];
            SOSIMImageObject *imageObj = [SOSIMImageObject object];
            imageObj.imageData = UIImagePNGRepresentation(image);
            
            SOSIMMediaMessage *imMsg = [SOSIMMediaMessage message];
            [imMsg setThumbImage:[Util zoomImage:image WithScale:5]];
            imMsg.mediaObject = imageObj;
            
            SendMessageToSOSIMReq *imReq = [[SendMessageToSOSIMReq alloc] init];
            imReq.messageType = SOSIMMessageTypeImage;
            imReq.message = imMsg;
            imReq.fromNav = self.navigationController;
            imReq.confirmFuncId = SMARTVEHICLE_CAR_CONDITION_LONG_GRAPH_SHARE_SHARE_ONSTARCHAT__SEND_OUT;
            imReq.cancelFuncId = SMARTVEHICLE_CAR_CONDITION_LONG_GRAPH_SHARE_SHARE_ONSTARCHAT__CANCEL;
            [SOSIMApi sendReq:imReq];
#endif
            
        }else if (index == 1) {
            [SOSDaapManager sendActionInfo:SMARTVEHICLE_CAR_CONDITION_LONG_GRAPH_SHARE_SHARE_WECHAT_FRIEND];
            [[WeiXinManager shareInstance] requestWeiXinImage:image Message:nil Scence:WXSceneSession];
            
        }else if (index == 2) {
            [SOSDaapManager sendActionInfo:SMARTVEHICLE_CAR_CONDITION_LONG_GRAPH_SHARE_SHARE_WECHAT_FRIENDS_CIRCLE];
            [[WeiXinManager shareInstance] requestWeiXinImage:image Message:nil Scence:WXSceneTimeline];
        }else if (index == 3) {
            UIActivityViewController *activityVc = [[UIActivityViewController alloc] initWithActivityItems:@[image] applicationActivities:nil];
            [self presentViewController:activityVc animated:YES completion:nil];
        }

    };
    
    SOSAlertAction *action = [SOSAlertAction actionWithTitle:@"取消" style:SOSAlertActionStyleCancel handler:^(SOSAlertAction * _Nonnull action) {
        [SOSDaapManager sendActionInfo:SMARTVEHICLE_CAR_CONDITION_LONG_GRAPH_SHARE_SHARE__CANCEL];
    }];
    [vc addActions:@[action]];
    [vc show];
    
}

- (void)downloadImage {
    [SOSDaapManager sendActionInfo:SMARTVEHICLE_CAR_CONDITION_LONG_GRAPH_SHARE_DOWNLOAD];
    UIImage *image = [self webViewSnapshot];
    [SOSPhotoLibrary saveImage:image assetCollectionName:nil callback:^(BOOL success) {
        if (success) {
//            [Util showSuccessHUDWithStatus:@"图片已保存至手机相册"];
        }
    }];
}

- (UIImage *)webViewSnapshot {
    UIScrollView *scrollView=[self.webView getScrollViewOfWebview];
    [scrollView scrollToBottomAnimated:NO];
    scrollView.frame = scrollView.superview.frame;
    CGRect sourceFrame = scrollView.frame;
    CGRect snapshotFrame = scrollView.frame;
    
    snapshotFrame.size.height = self.webView.wkWebView.scrollView.contentSize.height;
    scrollView.frame = snapshotFrame;
    [scrollView.superview layoutIfNeeded];
    //截屏
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.view.frame.size.width,scrollView.frame.size.height), NO, 0);     //设置截屏大小
    [scrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

//    [scrollView drawViewHierarchyInRect:scrollView.frame afterScreenUpdates:YES];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //重新设置回原frame
    scrollView.frame=sourceFrame;
    [scrollView.superview layoutIfNeeded];
    return image;
}

#pragma mark - delegate

- (void)soswebView:(SOSWebView *)webview didFinishLoadingURL:(NSURL *)URL {
    [super soswebView:webview didFinishLoadingURL:URL];
    _downloadBtn.hidden = NO;
    _shareBtn.hidden = NO;
    self.bottomPromptView.alpha = 1;
    [self.view bringSubviewToFront:_downloadBtn];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [UIView animateWithDuration:0.5 animations:^{
        _bottomPromptView.alpha = 0;
    }];
}


- (UIView *)bottomPromptView {
    if (!_bottomPromptView) {
        _bottomPromptView = [UIView new];
        [self.view addSubview:_bottomPromptView];
        [_bottomPromptView mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.bottom.right.equalTo(self.view);
            make.height.mas_equalTo(87);
        }];
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        
        gradientLayer.colors = @[(__bridge id)[UIColor colorWithRGB:0x031324 alpha:0.39].CGColor, (__bridge id)[UIColor clearColor].CGColor];
        gradientLayer.startPoint = CGPointMake(0, 1.0);
        gradientLayer.endPoint = CGPointMake(0, 0);
        gradientLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, 87);
        [_bottomPromptView.layer addSublayer:gradientLayer];
        
        UIButton *promptBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [promptBtn setImage:[UIImage imageNamed:@"sharecar-icon-arrow-top"] forState:UIControlStateNormal];
        [promptBtn setTitle:@"滑动查看完整图片" forState:UIControlStateNormal];
        [promptBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        promptBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        promptBtn.userInteractionEnabled = NO;
        [_bottomPromptView addSubview:promptBtn];
        [promptBtn mas_makeConstraints:^(MASConstraintMaker *make){
            make.center.equalTo(_bottomPromptView);
        }];

    }
    return _bottomPromptView;
}

- (void)dealloc		{
    self.webView.wkWebView.scrollView.delegate = nil;
}

@end
