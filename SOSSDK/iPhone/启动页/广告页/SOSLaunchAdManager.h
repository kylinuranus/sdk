//
//  SOSLaunchAdManager.h
//  Onstar
//
//  Created by Creolophus on 2020/3/6.
//  Copyright © 2020 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSLaunchAdManager : NSObject

+ (instancetype)shareManager;
- (void)setup;

@end

NS_ASSUME_NONNULL_END
