//
//  AppDelegate_iPhone+SOSRotate.h
//  Onstar
//
//  Created by jieke on 2019/11/21.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//
#import "AppDelegate_iPhone.h"

@interface AppDelegate_iPhone (SOSRotate)

/** 横屏 */
+ (void)setupHorizontalScreen;
/** 竖屏 */
+ (void)setupVerticalScreen;
@end
