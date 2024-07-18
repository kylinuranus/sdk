//
//  SOSTrioModule.m
//  Onstar
//
//  Created by Onstar on 2018/11/17.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSTripModule.h"
#import "SOSTripCardView.h"
#import "SOSTripHomeVC.h"

@implementation SOSTripModule

+ (void)load	{
    JSObjectionInjector *injector = [JSObjection defaultInjector];
    injector = injector ? : [JSObjection createInjector];
    injector = [injector withModule:[[self alloc] init]];
    [JSObjection setDefaultInjector:injector];
}

- (void)configure	{
    [self bindClass:[SOSTripHomeVC class] toProtocol:@protocol(SOSHomeTripTabProtocol)];
}

+ (SOSTripHomeVC *)getMainTripVC		{
    NSArray *mainVCs = [SOS_APP_DELEGATE fetchRootViewController].viewControllers;
    if (mainVCs.count > 2) {
        UINavigationController *navVC = mainVCs[1];
        if ([navVC isKindOfClass:[UINavigationController class]]) {
            SOSTripHomeVC *vc = (SOSTripHomeVC *)([navVC.viewControllers objectAtIndex:0]);
            if ([vc isKindOfClass:[SOSTripHomeVC class]]) 	return vc;
        }
    }
    return nil;
}

+ (BOOL)shouldShowCardWithCardType:(int)cardType	{
    SOSTripCardType type = cardType;
    // 未登录, 隐藏能耗
    if ([LoginManage sharedInstance].loginState == LOGIN_STATE_NON)		return (type != SOSTripCardType_EnergyLevel);
    if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
        // 访客, 隐藏能耗
        if ([SOSCheckRoleUtil isVisitor]) 								return (type != SOSTripCardType_EnergyLevel);
        
        BOOL isEVCar = [Util vehicleIsBEV] || [Util vehicleIsPHEV];
        BOOL isDriver = [SOSCheckRoleUtil isDriverOrProxy];
        switch (type) {
            case SOSTripCardType_DriveBehiver:
                if ([Util vehicleIsG9] || isEVCar)				return NO;
                else											return YES;
            case SOSTripCardType_OilLevel:
                if ([Util vehicleIsG9] || isEVCar)  			return NO;
                else                                            return YES;
            case SOSTripCardType_EnergyLevel:
                if ([Util vehicleIsG9] || !isEVCar) 			return NO;
                else                                            return YES;
            case SOSTripCardType_Footprint:
                if (isDriver)									return NO;
                else                                    		return YES;
        }
    }
    return NO;
}

+ (void)refreshFootPrint        {
    SOSTripHomeVC *vc = [SOSTripModule getMainTripVC];
    [vc refreshFootPrint];
}
@end
