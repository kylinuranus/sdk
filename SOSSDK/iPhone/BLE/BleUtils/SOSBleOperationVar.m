//
//  SOSBleOperationVar.m
//  Onstar
//
//  Created by onstar on 2018/10/30.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSBleOperationVar.h"

@interface SOSBleOperationVar ()

@end

@implementation SOSBleOperationVar


- (instancetype)init
{
    self = [super init];
    if (self) {
        _seconds = 600;
    }
    return self;
}

- (void)startTimer {
    
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_timer, ^{
        _seconds--;
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SOSBleTimerNotificationName object:nil];
            NSLog(@"xxx%d",_seconds);
            if (_seconds <= 0) {
                [self stopTiming];
            }
        });
    });
    dispatch_resume(_timer);
}

/** 结束定时器 */
- (void)stopTiming{
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
    _seconds = 600;
}

@end
