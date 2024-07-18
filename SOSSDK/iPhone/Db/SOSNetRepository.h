//
//  NetRepository.h
//  Onstar
//
//  Created by 梁元 on 2022/12/14.
//  Copyright © 2022 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SOSTrackConfig;
@interface SOSNetRepository : NSObject

+ (SOSNetRepository *)sharedInstance;

 

-(void) setConfig:(SOSTrackConfig*)config;

-(void) upload:(NSArray*)model
      success:(void(^)(void) ) success
       failure:(void(^)(NSInteger statusCode, NSString *responseStr)) failure;
@end

NS_ASSUME_NONNULL_END
