//
//  SOSWatchModule.m
//  Onstar
//
//  Created by TaoLiang on 2019/3/18.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSWatchModule.h"
#import "AppleWatchProxy.h"
#import <HealthKit/HealthKit.h>

@interface SOSWatchModule ()

@end

@implementation SOSWatchModule

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if ([WCSession isSupported]) {
        [WCSession defaultSession].delegate = self;
        [[WCSession defaultSession] activateSession];
    }
    return YES;
}

//- (void)applicationDidBecomeActive:(UIApplication *)application {
//    if (WCSession.defaultSession.isWatchAppInstalled) {
//        HKHealthStore *healthStore = [HKHealthStore new];
//        NSSet<HKSampleType *> *shareSet = [NSSet setWithObjects:[HKObjectType workoutType],[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate], nil];
//        NSSet<HKObjectType *> *saveSet = [NSSet setWithObject:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate]];
//        [healthStore requestAuthorizationToShareTypes:shareSet readTypes:saveSet completion:^(BOOL success, NSError * _Nullable error) {
//
//        }];
//    }
//}


#pragma mark-- WCSession Delegate

static AppleWatchProxy * yyyproxy = nil;
- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message {
    // 无需返回值使用
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message replyHandler:(void(^)(NSDictionary<NSString *, id> *replyMessage))replyHandler {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (!yyyproxy) {
            yyyproxy = [[AppleWatchProxy alloc] init];
        }
        NSDictionary * dict = [yyyproxy handleAppleWatchRequest:message callBack:replyHandler];
        replyHandler(dict);
    });
}
@end
