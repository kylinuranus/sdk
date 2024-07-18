//
//  SOSWatchModule.h
//  Onstar
//
//  Created by TaoLiang on 2019/3/18.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSAppDelegateBaseModule.h"
#import <WatchConnectivity/WatchConnectivity.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSWatchModule : SOSAppDelegateBaseModule<WCSessionDelegate>

@end

NS_ASSUME_NONNULL_END
