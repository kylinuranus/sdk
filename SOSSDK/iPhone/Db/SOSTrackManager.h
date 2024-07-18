//
//  TrackManager.h
//  Onstar
//
//  Created by 梁元 on 2022/12/14.
//  Copyright © 2022 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SOSTrackConfig,SOSTrackEvent;
@interface SOSTrackManager : NSObject


+ (SOSTrackManager *)sharedInstance;
-(void) initConfig:(SOSTrackConfig*)config;
-(void) track:(SOSTrackEvent*)model;
@end

NS_ASSUME_NONNULL_END
