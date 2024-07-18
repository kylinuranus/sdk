//
//  SOSTripNavView.m
//  Onstar
//
//  Created by Coir on 2018/12/17.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSFlexibleAlertController.h"
#import "SOSHomeAndCompanyTool.h"
#import "NavigateSearchVC.h"
#import "SOSTripNavView.h"
#import "SOSRemoteTool.h"
#import "UIImage+SOSSkin.h"

typedef enum {
    SOSTripNavViewType_Normal = 1,
    SOSTripNavViewType_Company,
    SOSTripNavViewType_Home
}	SOSTripNavViewType;

@interface SOSTripNavView ()
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@property (weak, nonatomic) IBOutlet UIView *actionBGView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *comLabel;
@property (weak, nonatomic) IBOutlet UILabel *homeLabel;

@property (weak, nonatomic) IBOutlet UIImageView *leftArrowImgView;
@property (weak, nonatomic) IBOutlet UIImageView *rightArrowImgView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionBGViewWidthGuide;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionBGViewLeadingGuide;

@property (weak, nonatomic) IBOutlet UIView *loadingBGView;
@property (weak, nonatomic) IBOutlet UILabel *loadingTextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *loadingIconImgView;

@property (nonatomic, assign) SOSTripNavViewType viewType;
@property (strong, nonatomic) CAGradientLayer *centerGradientLayer;

@end

@implementation SOSTripNavView

- (void)awakeFromNib	{
    [super awakeFromNib];
    [self.titleLabel setTextColor:[UIColor sos_skinColorWithKey:@"themeColorPack.themeColorBean.tripCenterFontColor"]];
    [self.comLabel setTextColor:[UIColor sos_skinColorWithKey:@"themeColorPack.themeColorBean.tripSideFontColor"]];
    [self.homeLabel setTextColor:[UIColor sos_skinColorWithKey:@"themeColorPack.themeColorBean.tripSideFontColor"]];

    //渐变
     CAGradientLayer *gradientLayer = [CAGradientLayer new];
     gradientLayer.colors = @[(__bridge id)[UIColor sos_skinColorWithKey:@"themeColorPack.tripBarGradientBean.startColor"].CGColor, (__bridge id)[UIColor sos_skinColorWithKey:@"themeColorPack.tripBarGradientBean.endColor"].CGColor];
        gradientLayer.startPoint = CGPointMake(0.0, 0.0);
        gradientLayer.endPoint = CGPointMake(0.0, 1);
        gradientLayer.frame = CGRectMake(0, 0, self.backgroundView.width, self.backgroundView.height);
        [self.backgroundView.layer addSublayer:gradientLayer];
    //
    self.actionBGViewWidthGuide.constant = (SCREEN_WIDTH - 40) / 3.f;
    self.actionBGViewLeadingGuide.constant = (SCREEN_WIDTH - 40) / 2.f - self.actionBGViewWidthGuide.constant / 2.f;
    
    self.clipsToBounds = NO;
    self.viewType = SOSTripNavViewType_Normal;
    
    self.leftArrowImgView.image = [UIImage imageWithSmallGIFData:[NSData dataWithContentsOfFile: [[NSBundle SOSBundle] pathForResource:@"icon_trip_arrow_left" ofType:@"gif"]] scale:1];
    self.rightArrowImgView.image = [UIImage imageWithSmallGIFData:[NSData dataWithContentsOfFile: [[NSBundle SOSBundle] pathForResource:@"icon_trip_arrow_right" ofType:@"gif"]] scale:1];
    
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.actionBGView addGestureRecognizer:panGes];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        [SOSDaapManager sendActionInfo:TRIP_GOWHERE];
        NavigateSearchVC *searchVC = [NavigateSearchVC new];
        [self.viewController.navigationController pushViewController:searchVC animated:YES];
    }];
    [self.actionBGView addGestureRecognizer:tapGes];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOS_VEHICLE_OPERATE_NOTIFICATION object:nil] subscribeNext:^(NSNotification *x) {
        NSDictionary *userInfo = x.userInfo;
//        @{@"state":@(RemoteControlStatus_InitSuccess), @"OperationType" : @(type) , @"message": message}
        SOSRemoteOperationType operationType = [userInfo[@"OperationType"] intValue];
        if ([SOSRemoteTool isSendPOIOperation:operationType]) {
            RemoteControlStatus state = [userInfo[@"state"] intValue];
            
            [self configLoadingViewWithRemoteControlStatus:state AndType:operationType];
            // LBS 点发送成功后要求有特殊的提示页面
            if ([userInfo[@"isSendingLBSPOI"] boolValue]) {
                if (state == RemoteControlStatus_OperateSuccess) {
                    SOSFlexibleAlertController *alert = [SOSFlexibleAlertController alertControllerWithImage:[UIImage imageNamed:@"Trip_LBS_SendPOI_Success"] title:@"导航下发成功" message:@"由于对方位置可能发生变化，请注意查看位置变化，更新导航下发" customView:[self getCustomView] preferredStyle:SOSAlertControllerStyleAlert];
                    
                    SOSAlertAction *cancelAction = [SOSAlertAction actionWithTitle:@"知道了" style:SOSAlertActionStyleDefault handler:^(SOSAlertAction * _Nonnull action) { }];
                    [alert addActions:@[cancelAction]];
                    [alert show];
                }
            }
            switch (state) {
                case RemoteControlStatus_InitSuccess:

                    break;
                case RemoteControlStatus_OperateSuccess:

                    break;
                case RemoteControlStatus_OperateTimeout:
                case RemoteControlStatus_OperateFail:
                    [SOSDaapManager sendActionInfo:TRIP_NAVIGATIONFAIL_KNOW];
                    break;
                default:
                    break;
            }
        }
    }];
}

- (UIView *)getCustomView	{
    UIView *cusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 255, 113)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(55, 31, 150, 17)];
    [cusView addSubview:label];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"如需帮助，请拨打客服电话"attributes: @{NSFontAttributeName: [UIFont systemFontOfSize: 12],NSForegroundColorAttributeName: [UIColor colorWithHexString:@"828389"]}];
    label.attributedText = string;
    label.textAlignment = NSTextAlignmentCenter;
    
    UIButton *phoneButton = [[UIButton alloc] initWithFrame:CGRectMake(79, 54, 103, 21)];
    [cusView addSubview:phoneButton];
    NSMutableAttributedString *phone = [[NSMutableAttributedString alloc] initWithString:@"400-820-1188"attributes: @{NSFontAttributeName: [UIFont fontWithName:@"DINNextLTPro-BoldCondensed" size: 22],NSForegroundColorAttributeName: [UIColor colorWithHexString:@"9EB0E3"]}];
    [phoneButton setAttributedTitle:phone forState:UIControlStateNormal];
    [[phoneButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl *x) {
        [SOSUtil callPhoneNumber:@"400-820-1188"];
    }];
    
    return cusView;
}

- (void)hideSelf:(BOOL)hide		{
    dispatch_async_on_main_queue(^{
        for (UIView *view in self.subviews) {
            if (view != _loadingBGView) 	view.hidden = hide;
        }
    });
}

- (void)configLoadingViewWithRemoteControlStatus:(RemoteControlStatus)status AndType:(SOSRemoteOperationType)type	{
    if (status == RemoteControlStatus_InitSuccess) {
        dispatch_async_on_main_queue(^{
            if (type == SOSRemoteOperationType_SendPOI_TBT) {
                self.loadingTextLabel.text = @"路线正在下发,大概需要1-3分钟";
            }	else if (type == SOSRemoteOperationType_SendPOI_ODD)	{
                self.loadingTextLabel.text = @"目的地正在下发,大概需要1-3分钟";
            }
            [self.loadingIconImgView startRotating];
            self.loadingBGView.hidden = NO;
        });
    }	else	{
        dispatch_async_on_main_queue(^{
            self.loadingBGView.hidden = YES;
            [self.loadingIconImgView endRotating];
        });
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.leftArrowImgView.hidden = YES;
        self.rightArrowImgView.hidden = YES;
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        
        float newCenterX = recognizer.view.center.x + translation.x;
        if (newCenterX > self.width - self.actionBGView.width / 2)	{
            self.viewType = SOSTripNavViewType_Home;
            return;
        }
        if (newCenterX < self.actionBGView.width / 2)    {
            self.viewType = SOSTripNavViewType_Company;
            return;
        }
        self.viewType = SOSTripNavViewType_Normal;
        recognizer.view.center = CGPointMake(newCenterX, self.centerY);
        [recognizer setTranslation:CGPointZero inView:self];
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        self.leftArrowImgView.hidden = NO;
        self.rightArrowImgView.hidden = NO;
        CGPoint location = [recognizer locationInView:self];
        
        if (location.x <= 0) {
            [SOSDaapManager sendActionInfo:TRIP_COMPANY];
            [[SOSHomeAndCompanyTool sharedInstance] EasyGoHomeFromVC:self.viewController WithType:pageTypeEasyBackCompany needShowWaitingVC:NO needShowToast:NO];
        }	else if (location.x >= self.width)	{
            [SOSDaapManager sendActionInfo:TRIP_HOME];
            [[SOSHomeAndCompanyTool sharedInstance] EasyGoHomeFromVC:self.viewController WithType:pageTypeEasyBackHome needShowWaitingVC:NO needShowToast:NO];
        }
        self.viewType = SOSTripNavViewType_Normal;
        [UIView animateWithDuration:.3 animations:^{
            recognizer.view.center = CGPointMake(self.width / 2, self.height / 2);
            [recognizer setTranslation:CGPointZero inView:self];
        }	completion:^(BOOL finished) {   }];
    }
}

- (void)setViewType:(SOSTripNavViewType)viewType	{
    if (_viewType == viewType)		return;
    _viewType = viewType;
    NSString *titleStr = nil;
    NSString *imgName = nil;
    switch (viewType) {
        case SOSTripNavViewType_Normal:
            titleStr = @"去哪里";
            imgName = @"trip_bar_icon";
            break;
        case SOSTripNavViewType_Home:
            titleStr = @"回家";
            imgName = @"trip_bar_icon_r";
            break;
        case SOSTripNavViewType_Company:
            titleStr = @"公司";
            imgName = @"trip_bar_icon_l";
            break;
        default:
            break;
    }
    self.titleLabel.text = titleStr;
    self.iconImgView.image = [UIImage sossk_imageNamed:imgName];
    
    if (SOS_APP_DELEGATE.useSkin) {
            if (!_centerGradientLayer) {
               _centerGradientLayer = [CAGradientLayer new];
                _centerGradientLayer.colors = @[(__bridge id)[UIColor sos_skinColorWithKey:@"themeColorPack.tripCenterGradientBean.startColor"].CGColor, (__bridge id)[UIColor sos_skinColorWithKey:@"themeColorPack.tripCenterGradientBean.endColor"].CGColor];
                       _centerGradientLayer.startPoint = CGPointMake(0.0, 0.0);
                       _centerGradientLayer.endPoint = CGPointMake(1.0, 0);
                       _centerGradientLayer.frame = CGRectMake(0, 0, self.actionBGViewWidthGuide.constant, self.actionBGView.height);
                       [self.actionBGView.layer insertSublayer:_centerGradientLayer atIndex:0];
                [self.actionBGView.layer setBorderColor:[UIColor clearColor].CGColor];
        
            }
    }else{
        self.actionBGView.backgroundColor = [UIColor colorWithHexString:viewType == SOSTripNavViewType_Normal ? @"6896ed" : @"3a81ff"];

    }
    if (SOS_BUICK_PRODUCT) {
        
                   self.actionBGView.backgroundColor = [UIColor colorWithHexString:@"004E90"];
           }
}

@end
