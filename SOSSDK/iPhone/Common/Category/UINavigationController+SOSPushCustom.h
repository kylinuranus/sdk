//
//  UINavigationController+SOSPushCustom.h
//  Onstar
//
//  Created by onstar on 2018/4/26.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (SOSPushCustom)

- (void)pushViewController:(UIViewController *)viewController
wantToRemoveViewController:(UIViewController *) childVc
                  animated:(BOOL)animated;

- (void)pushViewController:(UIViewController *)viewController
     wantToPopRootAnimated:(BOOL)animated;

@end
