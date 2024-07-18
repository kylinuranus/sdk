//
//  UIViewController+SOSTopPromptView.m
//  Onstar
//
//  Created by onstar on 2019/1/18.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "UIViewController+SOSTopPromptView.h"
#import "SOSHomeTabBarCotroller.h"
#import "SOSTopPromptView.h"

@implementation UIViewController (SOSTopPromptView)

+ (void)load {
    [self swizzleInstanceMethod:@selector(viewWillAppear:) with:@selector(sos_viewWillAppear:)];
}

- (void)sos_viewWillAppear:(BOOL)animated {

    SOSHomeTabBarCotroller *vc = (SOSHomeTabBarCotroller *)SOS_APP_DELEGATE.fetchRootViewController;
    SOSTopPromptView *topView = [KEY_WINDOW viewWithTag:KTOPTAG];
    if (topView && topView.showing && self.tabBarController) {
        if (self.navigationController.childViewControllers.count == 1 ||
            [self isKindOfClass:NSClassFromString(@"SOSCarShareViewController")]) {
            topView.hidden = NO;
        }	else {
            topView.hidden = YES;
        }
    }
    
    if (vc.onstarLinkButtonView &&
        vc.onstarLinkButtonView.tag >= 1000 &&
        self.tabBarController &&
         [self.navigationController isKindOfClass:[CustomNavigationController class]]) {
        if (self.navigationController.childViewControllers.count == 1) {
            if (vc.onstarLinkButtonView.tag == 1001) 	vc.onstarLinkButtonView.hidden = NO;
        }	else {
            vc.onstarLinkButtonView.hidden = YES;
        }
    }
    
    [self sos_viewWillAppear:animated];
}




@end
