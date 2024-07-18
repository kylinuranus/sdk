//
//  SOSTabBarCotroller.m
//  Onstar
//
//  Created by Onstar on 2018/11/15.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSHomeTabBarCotroller.h"
#import <Objection/Objection.h>
#if __has_include(<CYLTabBarController/CYLTabBarController.h>)
#import <CYLTabBarController/CYLTabBarController.h>
#else
#import "CYLTabBarController.h"
#endif

#import "SOSPushNotificationModule.h"
#import "SOSInfoFlowNetworkEngine.h"

#ifndef SOSSDK_SDK
#import "SOSOnstarLinkSDKTool.h"
#import "SOSIMLoginManager.h"
#endif
#import "SOSFullScreenADView.h"

#import "UIImage+SOSSkin.h"

@interface SOSHomeTabBarCotroller()

@end

@implementation SOSHomeTabBarCotroller
- (instancetype)init {
    
    UIEdgeInsets imageInsets = UIEdgeInsetsZero;//UIEdgeInsetsMake(4.5, 0, -4.5, 0);
    UIOffset titlePositionAdjustment;
    if (!SOS_ONSTAR_PRODUCT) {
        titlePositionAdjustment = UIOffsetZero;
    }else{
       titlePositionAdjustment = UIOffsetMake(0, -3.5);
    }
    self = [SOSHomeTabBarCotroller tabBarControllerWithViewControllers:[SOSHomeTabBarCotroller viewControllers]
                                                 tabBarItemsAttributes:[SOSHomeTabBarCotroller tabBarItemsAttributesForController]
                                                           imageInsets:imageInsets
                                               titlePositionAdjustment:titlePositionAdjustment
                                                               context:nil];
    self.delegate = self;
    if (self) {
        //不透明原因:
        //因为首页不显示NavigationBar,scrollView需要设置contentInsetAdjustmentBehavior,让其忽略safeAreaInset置顶显示。
        [UITabBar appearance].translucent = NO;
    }
   
    self.tabBar.backgroundColor = [UIColor whiteColor];
   
    [self customizeTabBarAppearance:self];
    return self;
}
- (void)dropShadowWithOffset:(CGSize)offset
                      radius:(CGFloat)radius
                       color:(UIColor *)color
                     opacity:(CGFloat)opacity {
    
    // Creating shadow path for better performance
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.tabBar.bounds);
    self.tabBar.layer.shadowPath = path;
    CGPathCloseSubpath(path);
    CGPathRelease(path);
    
    self.tabBar.layer.shadowColor = color.CGColor;
    self.tabBar.layer.shadowOffset = offset;
    self.tabBar.layer.shadowRadius = radius;
    self.tabBar.layer.shadowOpacity = opacity;
    
    // Default clipsToBounds is YES, will clip off the shadow, so we disable it.
    self.tabBar.clipsToBounds = NO;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addObserver];
#ifndef SOSSDK_SDK
    [self judgePushNotificationAlert];
#endif
    CAGradientLayer *gradientLayer = [CAGradientLayer new];
    if (SOS_BUICK_PRODUCT) {
        gradientLayer.colors = @[(__bridge id)[UIColor colorWithHexString:@"25272D"].CGColor, (__bridge id)[UIColor colorWithHexString:@"25272D"].CGColor];
    }else{
        gradientLayer.colors = @[(__bridge id)[UIColor sos_skinColorWithKey:@"themeColorPack.bottomBarGradientBean.startColor"].CGColor, (__bridge id)[UIColor sos_skinColorWithKey:@"themeColorPack.bottomBarGradientBean.endColor"].CGColor];
    }
    
    gradientLayer.startPoint = CGPointMake(0.0, 0.0);
    gradientLayer.endPoint = CGPointMake(0.0, 1);
    CGFloat height = IS_IPHONE_XSeries ? 83 : 49;
    gradientLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, height);
    [self.tabBar.layer addSublayer:gradientLayer];
    
   

}

- (void)judgePushNotificationAlert {
    NSString *key = @"pushNotificationTriggerKey";
    NSString *timesKey = @"pushNotificationTriggerTimesKey";
    [SOSPushNotificationModule pushNotificationIsOn:^(BOOL isOn) {
        if (!isOn) {
            NSNumber *timeIntervalNumber = [NSUserDefaults.standardUserDefaults objectForKey:key];
            NSInteger times = [[NSUserDefaults.standardUserDefaults objectForKey:timesKey] integerValue];
            if (timeIntervalNumber) {
                NSTimeInterval timeInterval = timeIntervalNumber.doubleValue;
                NSTimeInterval now = [NSDate date].timeIntervalSince1970;
                //超过三次6个月
                if (times > 3) {
                    if ((now - timeInterval) < (6 * 30 * 24 * 60 * 60.f)) {
                        return;
                    }
                }else {
                    //1个月
                    if ((now - timeInterval) < (30 * 24 * 60 * 60.f)) {
                        return;
                    }
                }
            }
            [NSUserDefaults.standardUserDefaults setObject:@([NSDate date].timeIntervalSince1970) forKey:key];
            [NSUserDefaults.standardUserDefaults setObject:@(times + 1) forKey:timesKey];
            [NSUserDefaults.standardUserDefaults synchronize];
            [Util showAlertWithTitle:@"您尚未开启消息提醒" message:@"开启提醒后便于接收车况及车辆操控信息" completeBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    return;
                }
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            } cancleButtonTitle:@"取消" otherButtonTitles:@"去开启", nil];
        }else {
            [NSUserDefaults.standardUserDefaults setObject:nil forKey:key];
            [NSUserDefaults.standardUserDefaults setInteger:0 forKey:timesKey];
        }
    }];
}

- (void)addObserver {
    @weakify(self);
#ifndef SOSSDK_SDK
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOSOnstarLinkButtonStateShouldChangeNotification object:nil] subscribeNext:^(NSNotification *noti) {
        @strongify(self)
        NSNumber *shouldShow = noti.object;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (shouldShow.boolValue && self.onstarLinkButtonView == nil) {
                self.onstarLinkButtonView = [SOSOnstarLinkSDKTool getOnstarLinkButtonView];
                [self.view addSubview:self.onstarLinkButtonView];
            }
            self.onstarLinkButtonView.hidden = !shouldShow.boolValue;
            self.onstarLinkButtonView.tag = 1000 + shouldShow.boolValue;
        });
    }];
#endif
    [RACObserve([LoginManage sharedInstance] , loginState) subscribeNext:^(NSNumber *state) {
        @strongify(self)
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (state.integerValue == LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS) {
    #ifndef SOSSDK_SDK
                
                //处理星友圈登录
                if ([SOSCheckRoleUtil isOwner] || [SOSCheckRoleUtil isDriverOrProxy] ) {
                    [[SOSIMLoginManager sharedManager] handleLogin];
                }
                //全屏广告
                [self requestFullScreenAD];

    #endif
                
                
            }
            //登录顶部提示条
            if ([[LoginManage sharedInstance] isInLoadingMainInterface]) {
                //是否是relogin
                if (self.promptView.style == SOSTopPromptStyleRefreshing) {
                    return;
                }
                if (self.promptView.style == SOSTopPromptStyleRefreshFailed) {
                    self.promptView.style = SOSTopPromptStyleRefreshing;
                }else {
                    self.promptView.style = SOSTopPromptStyleLogining;
                }
            }else if ([[LoginManage sharedInstance] isLoadingMainInterfaceFail]) {
                self.promptView.style = SOSTopPromptStyleRefreshFailed;
                
    #if DEBUG||TEST
                NSString * errorStage;
                if ([LoginManage sharedInstance].loginState == LOGIN_STATE_LOADINGUSERBASICINFOFAIL) {
                    errorStage = @"suite报错";
                }
                if ([LoginManage sharedInstance].loginState == LOGIN_STATE_LOADINGVEHICLECOMMANDSFAIL) {
                    errorStage = @"command报错";
                }
                if ([LoginManage sharedInstance].loginState == LOGIN_STATE_LOADINGVEHICLEPRIVILIGEFAIL) {
                    errorStage = @"funcs报错";
                }
                if (errorStage) {
                    [Util toastWithMessage:errorStage];
                }
    #endif
            }else if ([[LoginManage sharedInstance] isLoadingMainInterfaceReadyOrUnlogin]) {
                _promptView.style = SOSTopPromptStyleUndefine;
                [_promptView dismiss];
            }
            if (SOS_ONSTAR_PRODUCT) {
                if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin]) {
                    [self updateVehicleIcon];
                }
            }
        });
       
    }];
}

-(void)updateVehicleIcon{
    
    if ([LoginManage sharedInstance].loginState == LOGIN_STATE_NON) {
        [self.viewControllers objectAtIndex:0].tabBarItem.image = [[UIImage sosSDK_imageNamed:@"tab_vehicle_default_n"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [self.viewControllers objectAtIndex:0].tabBarItem.selectedImage = [[UIImage sosSDK_imageNamed:@"tab_vehicle_default_p"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }else{
        UIImage * vehicleIcon = [UIImage sosSDK_imageNamed:[NSString stringWithFormat:@"tab_vehicle_%@_n",[CustomerInfo sharedInstance].currentVehicle.brand.lowercaseString]];
        if (vehicleIcon) {
            [self.viewControllers objectAtIndex:0].tabBarItem.image = [vehicleIcon imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [self.viewControllers objectAtIndex:0].tabBarItem.selectedImage = [[UIImage sosSDK_imageNamed:[NSString stringWithFormat:@"tab_vehicle_%@_p",[CustomerInfo sharedInstance].currentVehicle.brand.lowercaseString]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
    }//vehicle_bottom_car_select_%@
}
- (SOSTopPromptView *)promptView {
    if (!_promptView) {
        _promptView  = [SOSTopPromptView new];
        _promptView.refreshHandler = ^{
            [[LoginManage sharedInstance] reLoadMainInterface];
            [SOSDaapManager sendActionInfo:GETPERSONALINFOR_FAIL_CLICKREFRESH];
        };
    }
    if (!_promptView.superview) {
        dispatch_async_on_main_queue(^{
            [self.view addSubview:_promptView];
            [_promptView mas_makeConstraints:^(MASConstraintMaker *make){
                make.top.equalTo(@(STATUSBAR_HEIGHT));
                make.left.equalTo(@15);
                make.right.equalTo(@-15);
                make.height.equalTo(@34);
            }];
        });
    }
    return _promptView;
}

- (BOOL)promptViewIsShowing {
    return _promptView.showing;
}

/**
 *  更多TabBar自定义设置：比如：tabBarItem 的选中和不选中文字和背景图片属性、tabbar 背景图片属性等等
 */
- (void)customizeTabBarAppearance:(CYLTabBarController *)tabBarController {
    // Customize UITabBar height
    // 自定义 TabBar 高度
    //    tabBarController.tabBarHeight = CYL_IS_IPHONE_X ? 65 : 40;
    
    // set the text color for unselected state
    // 普通状态下的文字属性
    
    // set the text color for selected state
    // 选中状态下的文字属性
    //    NSMutableDictionary *selectedAttrs = [NSMutableDictionary dictionary];
    //    selectedAttrs[NSForegroundColorAttributeName] = [UIColor blackColor];
    
    // set the text Attributes
    // 设置文字属性
    if (@available(iOS 13, *)) {
        UITabBar *tabBar = [UITabBar appearance];
        if (SOS_CD_PRODUCT) {
            [tabBar setTintColor:[UIColor cadiStytle]];
            [tabBar setUnselectedItemTintColor:[UIColor colorWithHexString:@"#787878"]];
        }else{
            if (SOS_BUICK_PRODUCT) {
                [tabBar setTintColor:[UIColor colorWithHexString:@"#FFFFFF"]];
                [tabBar setUnselectedItemTintColor:[UIColor colorWithHexString:@"#66686C"]];
            }else{
                [tabBar setTintColor:[UIColor sos_skinColorWithKey:@"themeColorPack.themeColorBean.bottomBarFontColor"]];
                [tabBar setUnselectedItemTintColor:[UIColor sos_skinColorWithKey:@"themeColorPack.themeColorBean.bottomBarFontColor"]];
            }
        }
    
    } else {
       
        NSMutableDictionary *normalAttrs = [NSMutableDictionary dictionary];
        normalAttrs[NSForegroundColorAttributeName] = [UIColor sos_skinColorWithKey:@"themeColorPack.themeColorBean.bottomBarFontColor"];
        UITabBarItem *tabBar = [UITabBarItem appearance];
        [tabBar setTitleTextAttributes:normalAttrs forState:UIControlStateNormal];
        [tabBar setTitleTextAttributes:normalAttrs forState:UIControlStateSelected];
    }
    
    // Set the dark color to selected tab (the dimmed background)
    // TabBarItem选中后的背景颜色
    //    [self customizeTabBarSelectionIndicatorImage];
    
    // update TabBar when TabBarItem width did update
    // If your app need support UIDeviceOrientationLandscapeLeft or UIDeviceOrientationLandscapeRight，
    // remove the comment '//'
    // 如果你的App需要支持横竖屏，请使用该方法移除注释 '//'
    //    [self updateTabBarCustomizationWhenTabBarItemWidthDidUpdate];
    
    // set the bar shadow image
    // This shadow image attribute is ignored if the tab bar does not also have a custom background image.So at least set somthing.
    
    
    //    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc] init]];
    //    [[UITabBar appearance] setBackgroundColor:[UIColor clearColor]];
    //    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    
    
    //        [[UITabBar appearance] setShadowImage:[UIImage imageNamed:@"tapbar_top_line"]];
    
    // set the bar background image
    // 设置背景图片
    //    UITabBar *tabBarAppearance = [UITabBar appearance];
    //
    //    //FIXED:  https://github.com/ChenYilong/CYLTabBarController/issues/312
    //    [UITabBar appearance].translucent = NO;
    //    //FIXED: https://github.com/ChenYilong/CYLTabBarController/issues/196
    //    NSString *tabBarBackgroundImageName = @"tabbarBg";
    //    UIImage *tabBarBackgroundImage = [UIImage imageNamed:tabBarBackgroundImageName];
    //    UIImage *scanedTabBarBackgroundImage = [[self class] scaleImage:tabBarBackgroundImage];
    //    [tabBarAppearance setBackgroundImage:scanedTabBarBackgroundImage];
    
    // remove the bar system shadow image
    // 去除 TabBar 自带的顶部阴影
    // iOS10 后 需要使用 `-[CYLTabBarController hideTabBadgeBackgroundSeparator]` 见 AppDelegate 类中的演示;
    [[UITabBar appearance] setShadowImage:[UIImage new]];
//    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc]init]];
    [self dropShadowWithOffset:CGSizeMake(0, - 3) radius:5 color:[UIColor grayColor] opacity:0.1];
    
}

+ (NSArray *)viewControllers {
    
    UIViewController <SOSHomeVehicleTabProtocol> *firstViewController = [[JSObjection defaultInjector] getObject:@protocol(SOSHomeVehicleTabProtocol)];
    
    CustomNavigationController *firstNavigationController = [[CustomNavigationController alloc]
                                                             initWithRootViewController:firstViewController];
    
    UIViewController *secondViewController;
    CustomNavigationController *secondNavigationController;
    
    if (!SOS_ONSTAR_PRODUCT) {
        secondViewController = [[NSClassFromString(@"SOSOnTabViewController") alloc] init];
        secondNavigationController = [[CustomNavigationController alloc]
                                                           initWithRootViewController:secondViewController];
    }else{
        UIViewController <SOSHomeTripTabProtocol>*rsecondViewController = [[JSObjection defaultInjector] getObject:@protocol(SOSHomeTripTabProtocol)];
        secondViewController = rsecondViewController;
        secondNavigationController = [[CustomNavigationController alloc]
        initWithRootViewController:secondViewController];
    }
    
    /* **** */
    UIViewController *thirdViewController;
    CustomNavigationController *thirdNavigationController;
    
    if (!SOS_ONSTAR_PRODUCT) {
         //出行
         UIViewController <SOSHomeTripTabProtocol>*rthirdViewController = [[JSObjection defaultInjector] getObject:@protocol(SOSHomeTripTabProtocol)];
          thirdViewController = rthirdViewController;
          thirdNavigationController = [[CustomNavigationController alloc]
                                                              initWithRootViewController:rthirdViewController];
       }else{
           UIViewController <SOSHomeLifeTabProtocol>*rthirdViewController =[[JSObjection defaultInjector] getObject:@protocol(SOSHomeLifeTabProtocol)];
           thirdViewController = rthirdViewController;
           thirdNavigationController = [[CustomNavigationController alloc]
           initWithRootViewController:thirdViewController];
       }
     /* **** */
    
    UIViewController <SOSHomeMeTabProtocol>*fourthViewController =[[JSObjection defaultInjector] getObject:@protocol(SOSHomeMeTabProtocol)];
    CustomNavigationController *fourthNavigationController = [[CustomNavigationController alloc]
                                                              initWithRootViewController:fourthViewController];
    NSArray *viewControllers = @[
        firstNavigationController,
        secondNavigationController,
        thirdNavigationController,
        fourthNavigationController
    ];
    return viewControllers;
}
//  
+ (NSArray *)tabBarItemsAttributesForController {
    
    
    NSMutableDictionary *firstTabBarItemsAttributes = [NSMutableDictionary dictionary];
    [firstTabBarItemsAttributes setValue:@"车辆"  forKey: CYLTabBarItemTitle];
    [firstTabBarItemsAttributes setValue:[UIImage sosSDK_imageNamed:@"tab_vehicle_default_n"]forKey:CYLTabBarItemImage];
    [firstTabBarItemsAttributes setValue:[UIImage sosSDK_imageNamed:@"tab_vehicle_default_p"] forKey:  CYLTabBarItemSelectedImage];
 
    
    NSMutableDictionary *secondTabBarItemsAttributes = [NSMutableDictionary dictionary];
    [secondTabBarItemsAttributes setValue:@"车控"  forKey: CYLTabBarItemTitle];
    [secondTabBarItemsAttributes setValue:  [UIImage sosSDK_imageNamed:@"tab_on_n"] forKey:CYLTabBarItemImage];
    [secondTabBarItemsAttributes setValue:[UIImage sosSDK_imageNamed:@"tab_on_p"] forKey:  CYLTabBarItemSelectedImage];
    

    
    NSMutableDictionary *thirdTabBarItemsAttributes = [NSMutableDictionary dictionary];
    [thirdTabBarItemsAttributes setValue:@"出行"  forKey: CYLTabBarItemTitle];
    [thirdTabBarItemsAttributes setValue:[UIImage sosSDK_imageNamed:@"tab_trip_n"] forKey:CYLTabBarItemImage];
    [thirdTabBarItemsAttributes setValue:[UIImage sosSDK_imageNamed:@"tab_trip_p"] forKey:  CYLTabBarItemSelectedImage];
    
    
    
    NSMutableDictionary *fourthTabBarItemsAttributes = [NSMutableDictionary dictionary];
    [fourthTabBarItemsAttributes setValue:@"我的"  forKey: CYLTabBarItemTitle];
    [fourthTabBarItemsAttributes setValue:[UIImage sosSDK_imageNamed:@"tab_me_n"] forKey:CYLTabBarItemImage];
    [fourthTabBarItemsAttributes setValue:[UIImage sosSDK_imageNamed:@"tab_me_p"] forKey:  CYLTabBarItemSelectedImage];
  
    
    

    NSArray *tabBarItemsAttributes = @[
        firstTabBarItemsAttributes,
        secondTabBarItemsAttributes,
        thirdTabBarItemsAttributes,
        fourthTabBarItemsAttributes
    ];

    return tabBarItemsAttributes;
}

- (void)hideMenuViewController:(id)sender	{
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (SOS_ONSTAR_PRODUCT) {
        switch (self.selectedIndex) {
            case 0:
                [SOSDaapManager sendActionInfo:NAV_VEHICLE];
                break;
            case 1:
                [SOSDaapManager sendActionInfo:NAV_TRIP];
                break;
            case 3:
                [SOSDaapManager sendActionInfo:NAV_LIFE];
                break;
            case 4:
                [SOSDaapManager sendActionInfo:NAV_ME];
                break;
            default:
                break;
        }
    }
    
}

- (void)requestFullScreenAD {
    [OthersUtil getBannerByCategory:BANNER_FULL_SCREEN_AD SuccessHandle:^(NSArray *banners) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (banners.count <= 0) {
                return;
            }
            SOSFullScreenADView *view = SOSFullScreenADView.new;
            view.banners = banners;
            [view show];
            
            __weak __typeof(SOSFullScreenADView) *weakView = view;
            view.selectBlock = ^(NSUInteger index) {
                [weakView dismiss];
                NNBanner *banner = banners[index];
                [SOSDaapManager sendSysBanner:[NSString stringWithFormat:@"%@", banner.bannerID] funcId:index == 0 ? VEHICLE_FLOATINGLAYER_ADVERTISEMENT1_CLICK : VEHICLE_FLOATINGLAYER_ADVERTISEMENT2_CLICK];

                CustomNavigationController * pushedCon = [SOSUtil bannerClickShowController:banner];
                if (pushedCon) {
                    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:pushedCon animated:YES completion:nil];
                }
                
                //                SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:banner.contentUrl?banner.contentUrl:banner.url];
                //                [SOS_APP_DELEGATE.fetchMainNavigationController pushViewController:vc animated:YES];
            };
            view.dismissed = ^{
                [SOSDaapManager sendActionInfo:VEHICLE_FLOATINGLAYER_ADVERTISEMENT_CLOSE];
                [SOSInfoFlowNetworkEngine deleteAdvertisementInfoFlow:@"FLOAT_BANNER" completionBlock:nil errorBlock:nil];
            };
        });
        
    } failureHandler:^(NSString *responseStr, NSError *error) {
        [Util toastWithMessage:responseStr];
    }];
}
@end
