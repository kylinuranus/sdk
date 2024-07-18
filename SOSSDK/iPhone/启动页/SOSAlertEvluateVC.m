//
//  SOSAlertEvluateVC.m
//  Onstar
//
//  Created by Coir on 2019/2/27.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSAlertEvluateVC.h"

@interface SOSAlertEvluateVC ()

@property (nonatomic, strong) UIWindow *alertWindow;

@end

@implementation SOSAlertEvluateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)show     {
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
    [self.alertWindow.rootViewController presentViewController:self animated:YES completion:nil];
}

- (IBAction)remindLater {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.alertWindow setHidden:YES];
        self.alertWindow = nil;
        [Util refuseRating];
    }];
}

- (IBAction)evluateNow {
    [self dismissViewControllerAnimated:YES completion:^{
        [Util showSuccessHUDWithStatus:@"感谢您的支持"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.alertWindow setHidden:YES];
            self.alertWindow = nil;
            [Util goodRating];
        });
    }];
}

@end
