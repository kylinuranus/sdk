//
//  TrackManagerUtil.h
//  Onstar
//
//  Created by 梁元 on 2022/12/14.
//  Copyright © 2022 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
 

NS_ASSUME_NONNULL_BEGIN

@interface SOSTrackManagerUtil : NSObject

+ (SOSTrackManagerUtil *)sharedInstance;
 
-(void) track:(NSString*) daapId
selfDefine:(NSDictionary*)  selfDefine
isImmediately:(bool) isImmediately;

@end

NS_ASSUME_NONNULL_END
