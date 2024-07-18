//
//  UIAlertController+Window.m
//  Onstar
//
//  Created by TaoLiang on 2018/4/8.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "UIAlertController+Window.h"

//https://stackoverflow.com/questions/26554894/how-to-present-uialertcontroller-when-not-in-a-view-controller

@interface UIAlertController (Private)

@property (nonatomic, strong) UIWindow *alertWindow;

@end

@implementation UIAlertController (Private)

- (void)setAlertWindow:(UIWindow *)alertWindow {
    objc_setAssociatedObject(self, @selector(alertWindow), alertWindow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIWindow *)alertWindow {
    return objc_getAssociatedObject(self, @selector(alertWindow));
}

@end

@implementation UIAlertController (Window)

- (void)show {
    [self show:YES];
}

- (void)show:(BOOL)animated {
#ifdef SOSSDK_SDK
    [SOS_ONSTAR_WINDOW.rootViewController presentViewController:self animated:animated completion:nil];
#else

    self.alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.alertWindow.rootViewController = [[UIViewController alloc] init];
    
    id<UIApplicationDelegate> delegate = [UIApplication sharedApplication].delegate;
    // Applications that does not load with UIMainStoryboardFile might not have a window property:
    if ([delegate respondsToSelector:@selector(window)]) {
        // we inherit the main window's tintColor
        self.alertWindow.tintColor = delegate.window.tintColor;
    }
    
    // window level is above the top window (this makes the alert, if it's a sheet, show over the keyboard)
    UIWindow *topWindow = [UIApplication sharedApplication].windows.lastObject;
    self.alertWindow.windowLevel = topWindow.windowLevel + 1;
    
    [self.alertWindow makeKeyAndVisible];
    [self.alertWindow.rootViewController presentViewController:self animated:animated completion:nil];
//    dispatch_async_on_main_queue(^{
//        UIViewController *vc = SOS_ONSTAR_WINDOW.rootViewController;
//        while (vc.presentedViewController) {
//            vc = vc.presentedViewController;
//        }
//        [vc presentViewController:self animated:animated completion:nil];
//    });
    #endif

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // precaution to ensure window gets destroyed
    self.alertWindow.hidden = YES;
    self.alertWindow = nil;
}


@end
