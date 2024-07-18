//
//  SOSLifeModule.m
//  Onstar
//
//  Created by Onstar on 2018/11/17.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSLifeModule.h"
#import "SOSLifeTabViewController.h"
@implementation SOSLifeModule
+ (void)load
{
    JSObjectionInjector *injector = [JSObjection defaultInjector];
    injector = injector ? : [JSObjection createInjector];
    injector = [injector withModule:[[self alloc] init]];
    [JSObjection setDefaultInjector:injector];
}
- (void)configure
{
    [self bindClass:[SOSLifeTabViewController class] toProtocol:@protocol(SOSHomeLifeTabProtocol)];
}
@end
