//
//  AutoNaviObject.m
//  AutoNaviTelematrics
//
//  Created by Joshua on 15-3-31.
//  Copyright (c) 2015年 onstar. All rights reserved.
//

#import "AutoNaviObject.h"

@implementation AutoNaviObject
@synthesize paramDict;

- (void)saveParam:(NSString *)value forKey:(NSString *)key     {
    if (!paramDict) {
        paramDict = [[NSMutableDictionary alloc] init];
    }
    if (value) {
        [paramDict setObject:value forKey:key];
    }
    }

- (NSString *)valueJointStringForArray:(NSArray *)keyArray     {
    NSMutableString *jointStr = [[NSMutableString alloc] init];
    for (NSString *key in keyArray) {
        NSString *value = [paramDict objectForKey:key];
        if ([value length] > 0) {
            [jointStr appendFormat:@"%@", value];
        }
    }
    return jointStr;
}

- (NSString *)objToString     {
    NSMutableString *retStr = [[NSMutableString alloc] init];
    for (int i = 0; i < paramDict.allKeys.count; i++) {
        NSString *key = paramDict.allKeys[i];
        NSString *value = paramDict[key];
        if ([value length] > 0) {
            if (i < paramDict.allKeys.count - 1) {
                [retStr appendFormat:@"%@=%@&", key, value];
            }   else    {
                [retStr appendFormat:@"%@=%@", key, value];
            }
        }
    }
    return retStr;
}
@end
