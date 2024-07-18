//
//  TrackEvent.h
//  Onstar
//
//  Created by 梁元 on 2022/12/14.
//  Copyright © 2022 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSTrackEvent : NSObject

 
 
@property(nonatomic) bool isImmediately;
@property(nonatomic)  NSInteger id2;
@property(nonatomic,copy)  NSString *mid;
@property(nonatomic,copy)  NSString *did;
@property(nonatomic,copy)  NSString *aid;
@property(nonatomic,copy)  NSString *sid;
@property(nonatomic,copy)  NSString *sVid;
@property(nonatomic,copy)  NSString *ts;
@property(nonatomic,copy)  NSString *d;
 
 
@end

NS_ASSUME_NONNULL_END
