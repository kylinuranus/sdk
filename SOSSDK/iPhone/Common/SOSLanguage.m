//
//  SOSLanguage.m
//  Onstar
//
//  Created by Joshua on 15/10/19.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import "SOSLanguage.h"


@implementation SOSLanguage

+ (NSString *) getCurrentLanguage     {
    return LANGUAGE_CHINESE;
//    NSString *currentLanguage = UserDefaults_Get_Object(ONSTAR_APP_LANGUAGE);
//    if ([currentLanguage length] == 0 || [currentLanguage isEqualToString:LANGUAGE_SYSTEM]) {
//        currentLanguage = [self get_AppleLanguages];
//    }
//    return currentLanguage;
}

#pragma mark 手机设置语言
+ (NSString *)get_AppleLanguages     {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *language = [languages objectAtIndex:0];
    
    NSString *currentLanguage = LANGUAGE_ENGLISH;
    if ([language isEqualToString:@"zh_CN"] || [language hasPrefix:@"zh-Hans"] || [language hasPrefix:@"zh-Hant"])
        currentLanguage = LANGUAGE_CHINESE;
    
    return currentLanguage;
}
@end
