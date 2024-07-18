//
//  UIWindow+DCLog.m
//  DCLogViewDemo
//
//  Created by DarielChen on 17/1/4.
//  Copyright © 2017年 DarielChen. All rights reserved.
//

#import "UIWindow+DCLog.h"
#import "HDWindowLogger.h"

@implementation UIWindow (DCLog)

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
#ifndef SOSSDK_SDK
#if DEBUG || TEST
    if (event.type == UIEventSubtypeMotionShake) {
        [HDWindowLogger changeVisible];
    }
#endif
#endif
}


@end
