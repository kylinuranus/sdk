//
//  SOSAppDelegateBaseModule.h
//  Onstar
//
//  Created by TaoLiang on 2019/3/18.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRDModuleManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface SOSAppDelegateBaseModule : NSObject<FRDModule>
- (UIWindow *)window;
- (void)showHomePage;
@end

NS_ASSUME_NONNULL_END
