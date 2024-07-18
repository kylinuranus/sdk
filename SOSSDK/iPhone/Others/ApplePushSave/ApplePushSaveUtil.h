//
//  ApplePushSaveUtil.h
//  Onstar
//
//  Created by Apple on 15-4-13.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplePushSaveUtil : NSObject

+ (void)saveDeviceInfoWithIsBind:(NSString *)isBind userID:(NSString *)userID;

+ (void)saveSession;



@end
