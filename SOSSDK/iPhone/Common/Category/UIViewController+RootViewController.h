//
//  UIViewController+RootViewController.h
//  abc
//
//  Created by jieke on 2018/10/8.
//  Copyright © 2018年 jieke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (RootViewController)

+ (instancetype)getCurrentViewController;
+ (UINavigationController *)getNavigationController;

@end
