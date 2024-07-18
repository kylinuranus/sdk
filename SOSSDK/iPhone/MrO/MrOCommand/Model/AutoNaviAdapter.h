//
//  AutoNaviAdapter.h
//  AutoNaviTelematrics
//
//  Created by Joshua on 15-3-31.
//  Copyright (c) 2015年 onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "Weather.h"
//#import "Restrict.h"
#import "ViolationList.h"
@interface AutoNaviAdapter : NSObject

@property(nonatomic, strong)NSString *restrictInfo;


- (void)asyncRequestForWeather:(NSString *)URL __deprecated_msg("移动至OtherUtil.m");

- (void)asyncRequestForVolation:(NSString *)URL_ successBlock:(SOSSuccessBlock)successBlock_ failureBlock:(SOSFailureBlock)failureBlock_ ;

- (void)asyncRequestForRestrict:(NSString *)restrictURL;

@end
