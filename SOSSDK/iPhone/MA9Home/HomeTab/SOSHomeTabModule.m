//
//  SOSTabModule.m
//  Onstar
//
//  Created by Onstar on 2018/11/15.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSHomeTabModule.h"
#import "SOSHomeTabBarCotroller.h"

@implementation SOSHomeTabModule


- (void)configure
{
    [self bindClass:[SOSHomeTabBarCotroller class] toProtocol:@protocol(SOSHomeTabBarControllerProtocol)];
}
@end
