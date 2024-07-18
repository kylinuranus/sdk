//
//  AppDelegate_iPhone+SOSRotate.m
//  Onstar
//
//  Created by jieke on 2019/11/21.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "AppDelegate_iPhone+SOSRotate.h"

@implementation AppDelegate_iPhone (SOSRotate)


#pragma mark - Private
#pragma mark 横屏
+ (void)setupHorizontalScreen {
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
       //让屏幕方向与设备方向统一
    [UIViewController attemptRotationToDeviceOrientation];
}
#pragma mark 竖屏
+ (void)setupVerticalScreen {
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
       //让屏幕方向与设备方向统一
    [UIViewController attemptRotationToDeviceOrientation];    
}
@end
