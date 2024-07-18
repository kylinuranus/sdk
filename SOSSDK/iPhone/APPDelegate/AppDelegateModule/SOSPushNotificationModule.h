//
//  SOSPushNotificationModule.h
//  Onstar
//
//  Created by TaoLiang on 2019/3/15.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSAppDelegateBaseModule.h"
#import "FRDModuleManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface SOSPushNotificationModule : SOSAppDelegateBaseModule
+ (void)pushNotificationIsOn:(void (^)(BOOL))isOn;
@end

NS_ASSUME_NONNULL_END
