//
//  UIViewController+RootViewController.m
//  abc
//
//  Created by jieke on 2018/10/8.
//  Copyright © 2018年 jieke. All rights reserved.
//

#import "UIViewController+RootViewController.h"

@implementation UIViewController (RootViewController)

+ (instancetype)getCurrentViewController {
    UIViewController *rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
    if (rootVC.presentedViewController) {
        rootVC = rootVC.presentedViewController;
    }
    UIViewController *myVC = rootVC.childViewControllers.firstObject;
    if (myVC.presentedViewController) {
        myVC = rootVC.presentedViewController;
    }else {
        if ([rootVC isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)rootVC;
            myVC = nav.topViewController;
        }else {
            myVC = rootVC;
        }
    }
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabbarVC = (UITabBarController *)rootVC;
        return tabbarVC.selectedViewController;
    }
    return myVC;
}
+ (UINavigationController *)getNavigationController {
    UIViewController *currentVC = [self getCurrentViewController];
    if ([currentVC isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *)currentVC;
    }else {
        return nil;
    }
}

@end
