//
//  DbRepository.h
//  Onstar
//
//  Created by 梁元 on 2022/12/14.
//  Copyright © 2022 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@class SOSTrackEvent;
@interface SOSDbRepository : NSObject

+ (SOSDbRepository *)sharedInstance;

-(BOOL) add:(SOSTrackEvent*) model;

-(BOOL) deleteData:(NSArray*) model;
 
-(BOOL) updateImmediately:(SOSTrackEvent*) model;

-(NSArray*) query:(int) limit;

@end

NS_ASSUME_NONNULL_END
