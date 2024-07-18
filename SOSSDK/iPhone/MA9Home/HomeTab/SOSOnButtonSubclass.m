//
//  SOSOnButtonSubclass.m
//  Onstar
//
//  Created by Onstar on 2018/11/15.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSOnButtonSubclass.h"
#import "CYLTabBarController.h"
#import "SOSHomeTabBarCotroller.h"
#import "SOSMroService.h"
#import "UIImage+SOSSkin.h"
@interface SOSOnButtonSubclass () {
    CGFloat _buttonImageHeight;
}

@end

@implementation SOSOnButtonSubclass

#pragma mark -
#pragma mark - Life Cycle

+ (void)load {
    //请在 `-[AppDelegate application:didFinishLaunchingWithOptions:]` 中进行注册，否则iOS10系统下存在Crash风险。
    //[super registerPlusButton];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.adjustsImageWhenHighlighted = NO;
    }
    return self;
}

//上下结构的 button
//- (void)layoutSubviews {
//    [super layoutSubviews];
//
//    // 控件大小,间距大小
//    // 注意：一定要根据项目中的图片去调整下面的0.7和0.9，Demo之所以这么设置，因为demo中的 plusButton 的 icon 不是正方形。
//    CGFloat const imageViewEdgeWidth   = self.bounds.size.width * 0.7;
//    CGFloat const imageViewEdgeHeight  = imageViewEdgeWidth * 0.9;
//
//    CGFloat const centerOfView    = self.bounds.size.width * 0.5;
//    CGFloat const labelLineHeight = self.titleLabel.font.lineHeight;
//    CGFloat const verticalMargin  = (self.bounds.size.height - labelLineHeight - imageViewEdgeHeight) * 0.5;
//
//    // imageView 和 titleLabel 中心的 Y 值
//    CGFloat const centerOfImageView  = verticalMargin + imageViewEdgeHeight * 0.5;
//    CGFloat const centerOfTitleLabel = imageViewEdgeHeight  + verticalMargin * 2 + labelLineHeight * 0.5 + 5;
//
//    //imageView position 位置
//    self.imageView.bounds = CGRectMake(0, 0, imageViewEdgeWidth, imageViewEdgeHeight);
//    self.imageView.center = CGPointMake(centerOfView, centerOfImageView);
//
//    //title position 位置
//    self.titleLabel.bounds = CGRectMake(0, 0, self.bounds.size.width, labelLineHeight);
//    self.titleLabel.center = CGPointMake(centerOfView, centerOfTitleLabel);
//}

#pragma mark -
#pragma mark - CYLPlusButtonSubclassing Methods

/*
 *
 Create a custom UIButton with title and add it to the center of our tab bar
 *
 */
+ (id)plusButton {
    SOSOnButtonSubclass *button = [SOSOnButtonSubclass buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, 60, 60);
    UIImage *normalButtonImage = [UIImage sossk_imageNamed:@"tab_on_n"];
    UIImage *hlightButtonImage = [UIImage sossk_imageNamed:@"tab_on_p"];
    [button setImage:normalButtonImage forState:UIControlStateNormal];
    [button setImage:hlightButtonImage forState:UIControlStateSelected];
    //    UIImage *normalButtonBackImage = [UIImage imageNamed:@"videoback"];
    //    [button setBackgroundImage:normalButtonBackImage forState:UIControlStateNormal];
    //    [button setBackgroundImage:normalButtonBackImage forState:UIControlStateSelected];
    //    button.imageEdgeInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    //添加长按手势
    UILongPressGestureRecognizer * longPressGesture =[[UILongPressGestureRecognizer alloc]initWithTarget:button action:@selector(cellLongPress:)];
    
    longPressGesture.minimumPressDuration=0.5f;//设置长按 时间
    [button addGestureRecognizer:longPressGesture];

    return button;
    
}

#pragma mark -
-(void)cellLongPress:(UIGestureRecognizer *)gesture{
    if (gesture.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    if ([[LoginManage sharedInstance] isInLoadingMainInterface]) {
        return;
    }
    
    [[LoginManage sharedInstance] checkAndShowLoginViewWithFromViewCtr:[SOS_APP_DELEGATE fetchMainNavigationController].topViewController andTobePushViewCtr:nil completion:^(BOOL finished) {
//        [Util showErrorHUDWithStatus:@"小O正在升级中，敬请期待" subStatus:nil];
        if ([SOSCheckRoleUtil isOwner]) {
            BOOL needShowMrO = [[Util readMrOOpenFlagByidpid:[CustomerInfo sharedInstance].userBasicInfo.idpUserId] boolValue];
            SOSHomeTabBarCotroller *tabBarVC = (SOSHomeTabBarCotroller *)SOS_APP_DELEGATE.fetchRootViewController;
            BOOL onstarLinkShow = tabBarVC.onstarLinkButtonView != nil && tabBarVC.onstarLinkButtonView.hidden == NO;
            if (needShowMrO && !onstarLinkShow) {
                [SOSDaapManager sendActionInfo:MRO_TRAFFICRESTRICTIONS_RESULT_CLICKL8];
                [[SOSMroService sharedMroService] startMroService];
            }
        }else {
            [Util showErrorHUDWithStatus:@"无法调用语音助手" subStatus:@"请升级为车主"];
        }
    }];
    
    
    NSLog(@"cellLongPress");
}
#pragma mark - CYLPlusButtonSubclassing

+ (UIViewController *)plusChildViewController {
    UIViewController *plusChildViewController = [[NSClassFromString(@"SOSOnTabViewController") alloc] init];
    UIViewController *plusChildNavigationController = [[CustomNavigationController alloc]
                                                       initWithRootViewController:plusChildViewController];
    
    return plusChildNavigationController;
}

+ (NSUInteger)indexOfPlusButtonInTabBar {
    return 2;
}

+ (BOOL)shouldSelectPlusChildViewController {
    BOOL isSelected = CYLExternPlusButton.selected;
    if (isSelected) {
        //        HDLLogDebug("🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"PlusButton is selected");
    } else {
        //        HDLLogDebug("🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"PlusButton is not selected");
    }
    [SOSDaapManager sendActionInfo:NAV_ON];
    return YES;
}

+ (CGFloat)multiplierOfTabBarHeight:(CGFloat)tabBarHeight {
    return  0.2;
}

+ (CGFloat)constantOfPlusButtonCenterYOffsetForTabBarHeight:(CGFloat)tabBarHeight {
    return (CYL_IS_IPHONE_X ? - 3 : 4);
}

//+ (NSString *)tabBarContext {
//    return NSStringFromClass([self class]);
//}

@end
