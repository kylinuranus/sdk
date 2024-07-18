//
//  SOSVehicleModule.m
//  Onstar
//
//  Created by Onstar on 2018/11/17.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSVehicleModule.h"
#import "SOSVehicleTabViewController.h"
@implementation SOSVehicleModule
+ (void)load
{
    JSObjectionInjector *injector = [JSObjection defaultInjector];
    injector = injector ? : [JSObjection createInjector];
    injector = [injector withModule:[[self alloc] init]];
    [JSObjection setDefaultInjector:injector];
}
- (void)configure
{
    [self bindClass:[SOSVehicleTabViewController class] toProtocol:@protocol(SOSHomeVehicleTabProtocol)];

}
@end
