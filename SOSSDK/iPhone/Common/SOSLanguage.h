//
//  SOSLanguage.h
//  Onstar
//
//  Created by Joshua on 15/10/19.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LANGUAGE_ENGLISH					@"ENGLISH"
#define LANGUAGE_CHINESE					@"CHINESE"
#define LANGUAGE_SYSTEM                     @"SYSTEM"

#define ONSTAR_APP_LANGUAGE @"OnStarAppLanguage"


@interface SOSLanguage : NSObject
+ (NSString *)getCurrentLanguage;
+ (NSString *)get_AppleLanguages;
@end
