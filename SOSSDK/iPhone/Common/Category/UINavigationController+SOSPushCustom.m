//
//  UINavigationController+SOSPushCustom.m
//  Onstar
//
//  Created by onstar on 2018/4/26.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "UINavigationController+SOSPushCustom.h"

@implementation UINavigationController (SOSPushCustom)

+ (void)load {
    [self swizzleInstanceMethod:@selector(popViewControllerAnimated:) with:@selector(sos_popViewControllerAnimated:)];
}

- (void)sos_popViewControllerAnimated:(BOOL)animated {
    UIViewController *vc = self.topViewController;
    if (!IsStrEmpty(vc.backRecordFunctionID)) {
        NSString *title = !IsStrEmpty(vc.title)?[NSString stringWithFormat:@"[%@]",vc.title]:@"";
        NSLog(@"%@%@ backRecordFunctionID: %@",[vc class],title, vc.backRecordFunctionID);
        [SOSDaapManager sendActionInfo:vc.backRecordFunctionID];
    }
    //daap
    if (vc.backDaapFunctionID.isNotBlank) {
        NSString *title = !IsStrEmpty(vc.title)?[NSString stringWithFormat:@"[%@]",vc.title]:@"";
        NSLog(@"%@%@ backRecordFunctionID: %@",[vc class],title, vc.backDaapFunctionID);
        [SOSDaapManager sendActionInfo:vc.backDaapFunctionID];
    }
    
    [self sos_popViewControllerAnimated:animated];
}

- (void)pushViewController:(UIViewController *)viewController wantToRemoveViewController:(UIViewController *) childVc animated:(BOOL)animated		{
    [viewController setHidesBottomBarWhenPushed:YES];
   
    [self pushViewController:viewController animated:animated];
    NSMutableArray *controllers = [NSMutableArray arrayWithArray:self.viewControllers];
    if ([controllers containsObject:childVc]) {
        [controllers removeObject:childVc];
    }
    if (![controllers.lastObject isEqual:viewController]) {
        [controllers addObject:viewController];
    }
    [self setViewControllers:controllers animated:animated];

}

- (void)pushViewController:(UIViewController *)viewController
     wantToPopRootAnimated:(BOOL)animated {
    [viewController setHidesBottomBarWhenPushed:YES];

    [self pushViewController:viewController animated:animated];

    [self setViewControllers:@[self.viewControllers.firstObject, viewController] animated:animated];
}



@end
