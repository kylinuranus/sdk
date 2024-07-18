//
//  SOSAppDelegateBaseModule.m
//  Onstar
//
//  Created by TaoLiang on 2019/3/18.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSAppDelegateBaseModule.h"

@implementation SOSAppDelegateBaseModule

- (UIWindow *)window {
    return SOS_APP_DELEGATE.window;
}

- (void)showHomePage {
    [SOS_APP_DELEGATE showHomePage];
}

@end
