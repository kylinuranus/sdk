//
//  UIViewController+Swizzling.m
//  Onstar
//
//  Created by Apple on 16/12/12.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "UIViewController+Swizzling.h"

@implementation UIViewController (Swizzling)

+ (void)load    {
    Method viewWillAppear = class_getInstanceMethod(self, @selector(viewWillAppear:));
    Method logViewWillAppear = class_getInstanceMethod(self, @selector(logViewWillAppear:));
    method_exchangeImplementations(viewWillAppear, logViewWillAppear);
    
    //AR界面支持横屏,其他界面不支持横屏
    Method shouldAutorotate = class_getInstanceMethod(self, @selector(shouldAutorotate));
    Method arshouldAutorotate = class_getInstanceMethod(self, @selector(arshouldAutorotate));
    method_exchangeImplementations(shouldAutorotate, arshouldAutorotate);
    
    Method supportedInterfaceOrientations = class_getInstanceMethod(self, @selector(supportedInterfaceOrientations));
    Method arsupportedInterfaceOrientations = class_getInstanceMethod(self, @selector(arsupportedInterfaceOrientations));
    method_exchangeImplementations(supportedInterfaceOrientations, arsupportedInterfaceOrientations);

}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
- (BOOL)arshouldAutorotate {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

    if ([self respondsToSelector:@selector(vcWithCar:configPath:)]) {
        return YES;
    } else if ([self respondsToSelector:@selector(sos_supportAutorotate)]) {
        //车友社交聊天中查看图片\视频支持横屏,SOSIMPhotoBrowerNavigationController中使用，建议以后需要横屏的页面都统一响应该方法
        return YES;
    }
    else if (orientation != UIInterfaceOrientationMaskPortrait) 	{
        return YES;
    }	else 	{
        return NO;
    }
}
- (UIInterfaceOrientationMask)arsupportedInterfaceOrientations {

    if ([self respondsToSelector:@selector(vcWithCar:configPath:)]) {
        return UIInterfaceOrientationMaskAll;
    } else if ([self respondsToSelector:@selector(sos_supportAutorotate)]) {
        return UIInterfaceOrientationMaskAll;
    }else	{
        return UIInterfaceOrientationMaskPortrait;
    }
}
#pragma clang diagnostic pop


- (void)logViewWillAppear:(BOOL)animated    {
    #ifdef DEBUG
    NSString *className = NSStringFromClass([self class]);
    if (!([className hasPrefix:@"UI"]
          || [className hasPrefix:@"CustomTabBarController"]
          || [className hasPrefix:@"CustomNavigationController"])) {
        NSLog(@"%@ viewWillAppear >>>",className);
    }
    #endif
    [UIView setAnimationsEnabled:YES];
    [self logViewWillAppear:animated];
}


@end
