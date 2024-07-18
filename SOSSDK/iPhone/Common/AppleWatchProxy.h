//
//  AppleWatchProxy.h
//  Onstar
//
//  Created by Joshua on 15/6/3.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppGroupHeader.h"

@interface AppleWatchProxy : NSObject     {
    NSString *inputPinCode;
}

- (NSDictionary *)handleAppleWatchRequest:(NSDictionary *)userInfo callBack:(void (^)(NSDictionary *))reply;
+ (AppleWatchOperationResultStatus)handleLoginRequest;
+ (AppleWatchOperationResultStatus)handleLoginRequestWithtimeout:(id)isloginOut;
@end
