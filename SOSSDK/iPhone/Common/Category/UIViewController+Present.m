//
//  UIViewController+Present.m
//  Onstar
//
//  Created by TaoLiang on 2019/9/25.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "UIViewController+Present.h"

//#import <AppKit/AppKit.h>


@implementation UIViewController (Present)
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
+ (void)load {

    if (@available(iOS 13, *)) {
        [self swizzleInstanceMethod:@selector(presentViewController:animated:completion:) with:@selector(sos_presentViewController:animated:completion:)];
    }
}

- (void)sos_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    if (viewControllerToPresent) {
        if (@available(iOS 13.0, *)) {
               if (viewControllerToPresent.modalPresentationStyle == UIModalPresentationAutomatic || viewControllerToPresent.modalPresentationStyle == UIModalPresentationPageSheet) {
                   viewControllerToPresent.modalPresentationStyle = UIModalPresentationFullScreen;
               }
           }
           
           [self sos_presentViewController:viewControllerToPresent animated:flag completion:completion];
    }
   
}
#endif

@end
