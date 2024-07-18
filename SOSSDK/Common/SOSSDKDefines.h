//
//  SOSSDKDefines.h
//  Onstar
//
//  Created by onstar on 2019/3/26.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#ifndef SOSSDKDefines_h
#define SOSSDKDefines_h

#define SOS_APPLICATION         [UIApplication sharedApplication]
#define SOS_KEY_WINDOW          SOS_APPLICATION.keyWindow
#define SOSSDK_VERSION_PREFIX           [SOSSDKKeyUtils versionPrefix]
#define SOSSDK_ONSTAR_VERSION           APP_VERSION
#define SOSSDK_WEB_SOURCE               [SOSSDKKeyUtils sdkWebSource]



#ifdef SOSSDK_SDK
#import "SOSExtension.h"
 
#if DEBUG
#define SOSSDK_VERSION          @"9.0.0" //内部测试,使用账号密码登录
#else
#define SOSSDK_VERSION          @"9.4.2" //外部测试,使用Ticket来登录
#endif
 
#define SOS_ONSTAR_WINDOW       SOS_APPLICATION.sosWindow
#define SOS_BUICK_WINDOW        SOS_APPLICATION.delegate.window


//10000
#define APP_VERSION                     SOSSDK_VERSION

#else

#define SOS_ONSTAR_WINDOW       SOS_APPLICATION.delegate.window

#define APP_VERSION                        ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"])
#define SOSSDK_VERSION          APP_VERSION

#endif

#endif /* SOSSDKDefines_h */
