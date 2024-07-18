//
//  SOSOnstarLinkGuideVC.m
//  Onstar
//
//  Created by Coir on 2018/7/27.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "LoadingView.h"
#import "AccountInfoUtil.h"
#import "SOSOnstarLinkSDKTool.h"
#import "SOSOnstarLinkGuideVC.h"
#import "SOSOnstarLinkDataTool.h"
#import "SOSOnstarLinkBindPhoneVC.h"

@interface SOSOnstarLinkGuideVC ()
@property (weak, nonatomic) IBOutlet UIView *lineView_1;
@property (weak, nonatomic) IBOutlet UIView *lineView_2;
@property (weak, nonatomic) IBOutlet UIButton *experienceNowButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomButtonHeightGuide;

@property (weak, nonatomic) IBOutlet UIView *bindServicePhoneBGView;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumLabel;

@property (nonatomic, assign) BOOL shouldRetryRequest;
@property (nonatomic, copy)   NSString *originPhoneNum;

@end

@implementation SOSOnstarLinkGuideVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"安吉星智联映射";
    if (self.isFirstEnter) {
        [self requestUserPhoneNumNeedshowLoading:NO Success:nil];
    }    else    {
        self.experienceNowButton.hidden = YES;
        self.bottomButtonHeightGuide.constant = 0;
    }
    self.backDaapFunctionID = Onstarlink_Introduce_back;
}

- (void)viewDidLayoutSubviews	{
    [super viewDidLayoutSubviews];
    [self drawLineOnLineView:self.lineView_1];
    [self drawLineOnLineView:self.lineView_2];
}

- (void)drawLineOnLineView:(UIView *)lineView		{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:lineView.bounds];
    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2, CGRectGetHeight(lineView.frame)/2)];
    
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    //  设置虚线颜色
    [shapeLayer setStrokeColor:[UIColor colorWithHexString:@"007AFF"].CGColor];

    [shapeLayer setLineWidth:CGRectGetWidth(lineView.frame)];
    [shapeLayer setLineJoin:kCALineJoinRound];
    //  设置线宽，线间距
    float lineWidth = 1, lineGap = 2.0;
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:@(lineWidth), @(lineGap), nil]];
    //  设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, 0, CGRectGetHeight(lineView.frame));
    
    [shapeLayer setPath:path];
    CGPathRelease(path);
    
    [lineView.layer addSublayer:shapeLayer];
}

- (void)requestUserPhoneNumNeedshowLoading:(BOOL)needShowLoading Success:(void (^)(void))success       {
    if (needShowLoading)	[[LoadingView sharedInstance] startIn:self.view];
    [AccountInfoUtil getAccountInfo:NO Success:^(NNExtendedSubscriber *subscriber) {
        self.shouldRetryRequest = NO;
        [[LoadingView sharedInstance] stop];
        if (subscriber.mobile.length) 		self.originPhoneNum = subscriber.mobile;
        else									self.originPhoneNum = nil;
        if (success)	success();
    } Failed:^{
        self.shouldRetryRequest = YES;
        [[LoadingView sharedInstance] stop];
    }];
}

/// 立即体验
- (IBAction)experienceNowButtonTapped {
    [SOSDaapManager sendActionInfo:Onstarlink_Introduce];
    if (self.shouldRetryRequest) {
        [self requestUserPhoneNumNeedshowLoading:YES Success:^{
            [self nextStep];
        }];
    }	else 	[self nextStep];
}

- (IBAction)hideBindBGViewButtonTapped 	{
    [self showBindServicePhoneView:NO];
}

- (void)nextStep	{
    if (self.originPhoneNum.length) {
        [self showBindServicePhoneView:YES];
    }    else    {
        [self showBindPhoneVC];
    }
}

- (void)showBindPhoneVC		{
    SOSOnstarLinkBindPhoneVC *vc = [SOSOnstarLinkBindPhoneVC new];
    vc.pageType = OnstarLinkBindPhonePageType_bind;
    @weakify(self)
    vc.operationSuccessBlock = ^(NSString *mobilePhoneNum) {
        @strongify(self)
        [SOSOnstarLinkDataTool sharedInstance].dataModel.mobile = mobilePhoneNum;
        [SOSOnstarLinkSDKTool configOnstarLinkSDK];
        [SOSOnstarLinkSDKTool enterOnstarLink];
        UIViewController *targetVC;
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:NSClassFromString(@"SOSSmartHomeEntranceViewController")])    targetVC = vc;
        }
        
        if (targetVC) [self.navigationController popToViewController:targetVC animated:YES];
    };

    [self.navigationController pushViewController:vc animated:YES];
}

/// 使用其他手机号
- (IBAction)bindOtherPhoneNumButtonTapped     {
    [SOSDaapManager sendActionInfo:Onstarlink_phoneno_new];
    [self showBindServicePhoneView:NO];
    [self showBindPhoneVC];
}

/// 使用此手机号
- (IBAction)usePhoneNumButtonTapped 	{
    [self showBindServicePhoneView:NO];
    [SOSOnstarLinkDataTool bindOnstarInfoWithPhoneNum:self.originPhoneNum IsModify:NO Success:^(NSDictionary *result) {
        [Util toastWithMessage:@"绑定成功"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
            [SOSOnstarLinkSDKTool configOnstarLinkSDK];
            [SOSOnstarLinkSDKTool enterOnstarLink];
        });
    } Failure:^(NSString *responseStr, NSError *error) {
        
    }];
}

- (void)showBindServicePhoneView:(BOOL)show		{
    if (show)	{
        self.bindServicePhoneBGView.alpha = .3;
        self.bindServicePhoneBGView.hidden = NO;
        NSMutableString *phoneStr = [NSMutableString stringWithString:self.originPhoneNum];
        [phoneStr insertString:@" " atIndex:3];
        [phoneStr insertString:@" " atIndex:8];
        self.phoneNumLabel.text = [NSString stringWithFormat:@"\"%@\"", phoneStr];
    }
    [UIView animateWithDuration:.3 animations:^{
        self.bindServicePhoneBGView.alpha = show ? 1.0 : .5;
    } completion:^(BOOL finished) {
        if (!show)	self.bindServicePhoneBGView.hidden = YES;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
