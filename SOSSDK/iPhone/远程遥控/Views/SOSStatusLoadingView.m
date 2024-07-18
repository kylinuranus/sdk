//
//  SOSStatusLoadingView.m
//  Onstar
//
//  Created by Genie Sun on 2017/7/27.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSStatusLoadingView.h"
#import <pop/pop.h>

@implementation SOSStatusLoadingView

- (void)showStatusLoadingViewWithStatus:(SOSRemoteControlStatus)status message:(NSString *)mes	{
    dispatch_async_on_main_queue(^{
        self.hidden = NO;
        POPSpringAnimation *anim = [self.layer pop_animationForKey:@"springRotation"];
        anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
        anim.springSpeed = 20;
        anim.springBounciness = 12;
        anim.dynamicsTension = 500;
        UIViewController *vc = self.viewController;
        if (!vc) {
            anim.toValue = @(STATUSBAR_HEIGHT);
        }else if ([vc isKindOfClass:[UINavigationController class]]) {
            anim.toValue = @(vc.view.sos_safeAreaInsets.top + 25);
        }    else    {
            anim.toValue = @(vc.view.sos_safeAreaInsets.top + 25);
        }
        [self.layer pop_addAnimation:anim forKey:@"springRotation"];
        
        if (mes && _autoHide) {
            [self performSelector:@selector(hide) withObject:nil afterDelay:3];
        }
        
        switch (status) {
            case DATA_REFRESH:
                self.backgroundColor = [UIColor colorWithHexString:@"7ED321"];
                self.icon.hidden = NO;
                self.infoLB.hidden = NO;
                self.detailIconLB.hidden = YES;
                if (mes.length)		self.infoLB.text = mes;
                [SOSUtilConfig transformRotationWithView:self.icon];
                break;
            case DATA_REFRESH_END:    {
                self.icon.hidden = YES;
                self.infoLB.hidden = YES;
                self.detailIconLB.hidden = NO;
                
                [SOSUtilConfig transformIdentityStatusWithView:self.icon];
                self.backgroundColor = [UIColor colorWithHexString:@"7ED321"];
                self.detailIconLB.attributedText = [SOSUtilConfig setLabelAttributedText:mes AttachmentWithView:[UIImage imageNamed:@"icon_ok_fff"] withImagePosition:LEFT_POSITION];
            }
                break;
            case USER_UPDATE_FAIL:    {
                self.icon.hidden = YES;
                self.infoLB.hidden = YES;
                self.detailIconLB.hidden = NO;
                [SOSUtilConfig transformIdentityStatusWithView:self.icon];
                self.backgroundColor = [UIColor colorWithHexString:@"D0011B"];
                self.detailIconLB.attributedText = [SOSUtilConfig setLabelAttributedText:mes AttachmentWithView:[UIImage imageNamed:@"icon_alert_yellow"] withImagePosition:LEFT_POSITION];
            }
                break;
            case VEHICLE_UNAUTHORIZED:    {
                self.icon.hidden = YES;
                self.infoLB.hidden = YES;
                self.detailIconLB.hidden = NO;
                self.backgroundColor = [UIColor colorWithHexString:@"D0011B"];
                self.detailIconLB.attributedText = [SOSUtilConfig setLabelAttributedText:mes AttachmentWithView:[UIImage imageNamed:@"icon_alert_yellow"] withImagePosition:LEFT_POSITION];
            }
                break;
            case SOSLOGIN_NEED_REFRESH:    {
                self.icon.hidden = YES;
                self.infoLB.hidden = YES;
                self.detailIconLB.hidden = NO;
                self.backgroundColor = [UIColor colorWithHexString:@"FFEDCF"];
                self.detailIconLB.adjustsFontSizeToFitWidth=YES;
                self.detailIconLB.minimumScaleFactor=0.5;
                self.detailIconLB.textColor = [UIColor colorWithHexString:@"F79B03"];
                self.detailLabelTrailingConstrain.constant = 30.0f;
                self.detailLabelLeadingTrailingConstrain.constant = 15.0f;
                [self addDismissButton];
                self.detailIconLB.attributedText = [SOSUtilConfig setLabelAttributedText:mes AttachmentWithView:nil withImagePosition:3];
            }
                break;
            default:
                break;
        }
    });
}

- (void)addDismissButton		{
    UIButton * dismiss = [[UIButton alloc] init];
    [dismiss setImage:[UIImage imageNamed:@"sos_icon_close_yellow"] forState:0];
    [dismiss addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:dismiss];
    [dismiss mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.mas_equalTo(-10);
        make.centerY.equalTo(self);
//        make.height.mas_equalTo(20);
//        make.width.mas_equalTo(20);
    }];
}

- (void)hide	{
    if (self.hidden) 	return;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    [UIView animateWithDuration:0.2 animations:^{
        self.layer.position = CGPointMake(self.layer.position.x, self.viewController.view.sos_safeAreaInsets.top);
    } completion:^(BOOL finished) {
        self.hidden = YES;
        if (_removeFromSuperWhenHide) {
            [self removeFromSuperview];
        }
    }];
}

- (void)dealloc
{
    NSLog(@"SOSStatusLoadingView dealloc");
}
@end

@implementation SOSConvenientStatusLoadingView
static NSString * messageStr;
static SOSRemoteControlStatus status;
+(void)showStatusLoadingViewInController:(UIView *)view {
    messageStr = @"连接中...";
    status = DATA_REFRESH;
    [SOSConvenientStatusLoadingView showStatusLoadingViewInController:view status:status message:messageStr];
}
+(void)showStatusLoadingViewInController:(UIView *)view status:(SOSRemoteControlStatus)status message:(NSString *)msg {
    
    if (![view viewWithTag:10001]) {
        SOSStatusLoadingView * loadingV = [SOSStatusLoadingView viewFromXib];
        loadingV.tag = 10001;
        loadingV.removeFromSuperWhenHide = YES;
        [view addSubview:loadingV];
        [loadingV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(view.mas_top);
            make.leading.equalTo(view);
            make.trailing.equalTo(view);
            make.height.mas_equalTo(50);
        }];
        [view bringSubviewToFront:loadingV];
        [loadingV showStatusLoadingViewWithStatus:status  message:msg];
    }else {
        SOSStatusLoadingView * loadingV = [view viewWithTag:10001];
        [loadingV showStatusLoadingViewWithStatus:status  message:msg];
    }
}

+(void)showStatusLoadingViewInController:(UIView *)view
                                  status:(SOSRemoteControlStatus)status
                                 message:(NSString *)msg
                       dismissAfterDelay:(NSTimeInterval)delay
{
    [self showStatusLoadingViewInController:view status:status message:msg];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideStatusLoadingViewInController:view];
    });
}



+(void)hideStatusLoadingViewInController:(UIView *)view {
    if ([view viewWithTag:10001]) {
        SOSStatusLoadingView *loading = [view viewWithTag:10001];
        [loading hide];
    }
}
@end
