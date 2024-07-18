//
//  SOSRemindSet.h
//  Onstar
//
//  Created by Genie Sun on 2017/3/15.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSchangePhmailNumber.h"

@interface SOSRemindSet : NSObject

+ (void) notigyConfigInformation:(NSString *)requestType body:(NSString *)body btype:(NSString *)btype Success:(void (^)(NNNotifyConfig *notify))completion Failed:(void (^)(void))failCompletion;
+ (void) validatenotifyConfigWithVinSuccess:(void (^)(BOOL flag))completion Failed:(void (^)(void))failCompletion;

+ (void)sendNOtifyCodewithSubscriberId:(NSString *)subscriberID userTf:(NSString *)newUserTf pageNumber:(pageType)pageType secCode:(NSString *)secCode Success:(void (^)(NNErrorDetail *error))completion Failed:(void (^)(void))failCompletion;

@end
