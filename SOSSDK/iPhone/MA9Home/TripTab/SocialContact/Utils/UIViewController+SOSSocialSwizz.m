//
//  UIViewController+SOSSocialSwizz.m
//  Onstar
//
//  Created by onstar on 2019/4/22.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "UIViewController+SOSSocialSwizz.h"
#import "SOSSocialService.h"
#import "SOSSocialWaitingViewController.h"
#import "SOSSocialLocationViewController.h"

@implementation UIViewController (SOSSocialSwizz)

+ (void)load {
    [self swizzleInstanceMethod:@selector(viewWillAppear:) with:@selector(sos_socialViewWillAppear:)];
}

- (void)sos_socialViewWillAppear:(BOOL)animated {

    if (self.tabBarController &&[SOSSocialService shareInstance].orderInfoResp) {
        if (self.navigationController.childViewControllers.count == 1 ||
            [self isKindOfClass:NSClassFromString(@"SOSSocialWaitingViewController")]) {
            //show alert
            [[SOSSocialService shareInstance] showAcceptAlert];
        }
    }
    
    [self sos_socialViewWillAppear:animated];
}

@end
