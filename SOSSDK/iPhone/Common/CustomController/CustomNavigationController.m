;
//
//  CustomNavigationController.m
//  Onstar
//
//  Created by Apple on 16/6/21.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "CustomNavigationController.h"
#import "UIBarButtonItem+Extension.h"
#import "AppPreferences.h"



@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

+ (void)initialize {
    UINavigationBar *bar = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[CustomNavigationController class]]];
    
    bar.barTintColor = [UIColor whiteColor];
    [bar setTitleTextAttributes:@{
                                  NSForegroundColorAttributeName : SOS_NavigationBar_ForegroundColor,
                                  NSFontAttributeName : SOS_NavigationBar_Font
                                  }];
    bar.shadowImage = [UIImage imageWithColor:[UIColor colorWithWhite:1 alpha:0]];
    
    [UINavigationBar appearance].translucent = NO; //设置不透明
    [UINavigationBar appearance].shadowImage = [UIImage imageWithColor:[UIColor colorWithWhite:1 alpha:0]];
    
    //适配ios15,导航栏毛玻璃的问题
    if (@available(iOS 15.0, *)) {
        
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
          //  appearance.backgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
        appearance.backgroundEffect = nil; //  // 去掉半透明效果
            //设置背景颜色
        appearance.backgroundColor =[UIColor whiteColor];
        
        //普通样式
          bar.standardAppearance = appearance;
        bar.scrollEdgeAppearance = appearance;
     }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    UINavigationBar *bar = self.navigationBar;
    bar.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:bar.bounds cornerRadius:bar.layer.cornerRadius].CGPath;
    [bar.layer setShadowColor: [UIColor colorWithHexString:@"6570B5"].CGColor];
    [bar.layer setShadowOffset:CGSizeMake(0, 5)];
    [bar.layer setShadowRadius:3];
    [bar.layer setShadowOpacity: 0.15];


}


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated   {
//#ifndef SOSSDK_SDK
//    if ([viewController isKindOfClass:[SOSWebViewController class]]) {
//        if (![AFNetworkReachabilityManager sharedManager].reachable) {
//            [SOSUtil showCustomAlertWithTitle:@"提示" message:@"请稍后重试" completeBlock:nil];
//            return;
//        }
//    }
//#endif
    if (self.childViewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"common_Nav_Back"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"common_Nav_Back"] forState:UIControlStateHighlighted];
        button.size = CGSizeMake(30, 44);
        button.backgroundColor = [UIColor clearColor];
        // 让按钮内部的所有内容左对齐
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        //        [button sizeToFit];
        // 让按钮的内容往左边偏移10
        button.contentEdgeInsets = UIEdgeInsetsMake(0, -1, 0, 0);
        [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        // 修改导航栏左边的item
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        viewController.navigationBackButton = button;
    }
    [super pushViewController:viewController animated:animated];
}

- (void)back{
    UIViewController *vc = [self.viewControllers lastObject];
    if (vc.backClickBlock)	vc.backClickBlock();
    [self popViewControllerAnimated:YES];
}

-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    if (![self.viewControllers.firstObject isKindOfClass:SOSWebViewController.class]) {
        [super dismissViewControllerAnimated:flag completion:completion];
        return;
    }
    //只拦截modal-CustomNavigationController-SOSWebViewControllerz这种情况，如果navigationController没有presentedViewController，则不响应dismiss
    if (self.presentedViewController) {
        [super dismissViewControllerAnimated:flag completion:completion];
    }
}

@end
