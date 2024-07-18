//
//  SOSGreetingRouter.m
//  Onstar
//
//  Created by onstar on 2017/10/13.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSGreetingRouter.h"
#import "SOSGreetingManager.h"
#import "SOSOnstarPackageVC.h"
#import "SOSCardUtil.h"

@implementation SOSGreetingRouter

+ (void)routerWithModel:(SOSGreetingModel *)model	{
    if (model.funcId) {
        [SOSDaapManager sendActionInfo:model.funcId ];
    }
    [self routerWithType:model.linkType key:model.target];
}


+ (void)routerWithType:(NSString *)linkType key:(NSString *)key{
    if (linkType.isNotBlank && key.isNotBlank) {
//        if ([linkType isEqualToString:@"NATIVE"]) {
        [self routerWithNativeKey:key];
//        }
//        else if ([linkType isEqualToString:@"H5"]) {
//            [self routerWithH5Key:key];
//        }
    }
}

+ (void)routerWithNativeKey:(NSString *)key {
    if ([key isEqualToString:@"LOGINREGISTER"]) {
        [[LoginManage sharedInstance] presentLoginNavgationController:[SOS_APP_DELEGATE fetchRootViewController]];
    }else if ([key isEqualToString:@"COREPACKAGEDETAIL"]) {
        //套餐
        SOSOnstarPackageVC *vc = [SOSOnstarPackageVC new];
//        AppDelegate_iPhone *delegate = (AppDelegate_iPhone*)[[UIApplication sharedApplication] delegate];
        [((UINavigationController *)[SOS_APP_DELEGATE fetchMainNavigationController]) pushViewController:vc animated:YES];
    }else if ([key isEqualToString:@"UPGRADESUBSCRIBER"]) {
        [SOSCardUtil routerToUpgradeSubscriber];
        
    }else if ([key isEqualToString:@"BUYDATAPACKAGE"]) {
        [SOSCardUtil routerToBuyOnstarPackage:PackageType_4G];
    }else if ([key isEqualToString:@"BUYCOREPACKAGE"]) {
        [SOSCardUtil routerToBuyOnstarPackage:PackageType_Core];
    }else if ([key isEqualToString:@"SMARTDRIVEHOME"]) {
        //驾驶行为评价
        [SOSCardUtil routerToDrivingScoreH5];
    }else if ([key hasPrefix:@"http"]) {
        [SOSCardUtil routerToH5Url:key];
    }
}

//+ (void)routerWithH5Key:(NSString *)key {
//    if ([key isEqualToString:@"SMARTDRIVEHOME"]) {
//        //驾驶行为评价
//        [SOSCardUtil routerToDrivingScoreH5];
//    }else if ([key hasPrefix:@"http"]) {
//        [SOSCardUtil routerToH5Url:key];
//    }else if ([key isEqualToString:@""]) {
//
//    }
//
//}


@end
