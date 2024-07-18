//
//  SOSEnvConfig.m
//  Onstar
//
//  Created by onstar on 2018/5/4.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSEnvConfig.h"

#define PRODUCT 2

@implementation SOSEnvConfig

+ (instancetype)config
{
    static dispatch_once_t onceToken;
    static SOSEnvConfig *config;
    dispatch_once(&onceToken, ^{
        config = [SOSEnvConfig new];
    });
    return config;
}

#warning 用DEBUG或者TEST运行时，不用动代码，切生产时在设置中切换PRODUCT，除了证书相关，其他均切到生产环境
- (instancetype)init
{
    self = [super init];
    if (self) {//test
        self.enableSslCer = YES;
#if DEBUG
        self.enableNormalLog = YES;
        self.enableSslCer = NO;
        self.showDebugToast = YES;
#elif TEST
        self.enableSslCer = NO;
        self.enableNormalLog = YES;
        self.showDebugToast = YES;
#endif
    }
    return self;
}

- (NSInteger)sos_env {
    
    //若主动设置环境已主动设置的环境为准
    if (_sos_env) {
        return _sos_env;
    }
#if DEBUG || TEST
   return self.settingEnvValue;
#else
    return PRODUCT;
#endif
  
}

- (BOOL)development {
#if DEBUG
    return YES;
#elif TEST
    return self.sos_env != PRODUCT;
#else
    return NO;
#endif
}

- (NSInteger)settingEnvValue {
    return [[NSUserDefaults standardUserDefaults] integerForKey:SERVER_IP_INT_KEY];
}

@end
