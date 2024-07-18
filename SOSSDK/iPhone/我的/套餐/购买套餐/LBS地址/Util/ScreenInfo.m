//
//  ScreenInfo.m
//  UINavigationControllerTest
//
//  Created by admin on 2018/6/1.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "ScreenInfo.h"

@interface ScreenInfo () <NSCopying, NSMutableCopying>

@property (nonatomic, strong) UINavigationController *nav;
@property (nonatomic, strong) UITabBarController *tabBarController;
@end

@implementation ScreenInfo

#pragma mark - 单例实现
implementationSingleton(ScreenInfo)

#pragma mark - Private
#pragma mark - 布局相关属性
- (CGRect)frame {
    return [UIScreen mainScreen].bounds;
}
- (CGRect)currentViewFrame {
    return CGRectMake(0, 0, kScreenWidth, kScreenHeight - self.kNavi_Height);
}
- (CGFloat)kSafeAreaScreenHeight {
    return kScreenHeight - self.kNavi_Height - self.kTabBarBottomHeight;
}
- (CGFloat)kStatusBarHeight {
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}
- (CGFloat)kTabBarBottomHeight {
    if (@available(iOS 11.0, *)) {
        CGFloat height = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
        return height;
    } else {
        // Fallback on earlier versions
        return 0.0;
    }
}
- (CGFloat)kTabbar_Height {
    return self.tabBarController.tabBar.frame.size.height;
}
- (CGFloat)navigationBarHeight {
    return self.nav.navigationBar.frame.size.height;
}
- (CGFloat)kNavi_Height {
    return self.navigationBarHeight + self.kStatusBarHeight;
}
- (CGFloat)scale {
    return kScreenWidth / 375;
}
- (CGFloat)getBorderWidth:(CGFloat)width {
    return (width / [UIScreen mainScreen].scale * 2);
}
- (BOOL)widthUnder375 {
    return kScreenWidth < 375;
}
- (CGFloat)lineViewHeight {
    return [self getBorderWidth:0.5];
}
- (BOOL)compareSystemVersion:(CGFloat)version {
    if (UIDevice.currentDevice.systemVersion.doubleValue < version) {
        return YES;
    }else {
        return NO;
    }
}
#pragma mark - 懒加载
- (UINavigationController *)nav {
    if (!_nav) {
        _nav = [[UINavigationController alloc] init];
    }
    return _nav;
}
- (UITabBarController *)tabBarController {
    if (!_tabBarController) {
        _tabBarController = [[UITabBarController alloc] init];
    }
    return _tabBarController;
}
@end
