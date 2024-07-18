//
//  TrackConfig.h
//  Onstar
//
//  Created by 梁元 on 2022/12/14.
//  Copyright © 2022 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSTrackConfig : NSObject


@property(nonatomic) bool isDebug;
@property(nonatomic) NSString *aid;
@property(nonatomic) NSString *sid;
@property(nonatomic) NSString *svid;
@property(nonatomic) NSString *projectId;
 
@property(nonatomic) int timePeriod;
@property(nonatomic) int countLimit;

@property(nonatomic) NSString *userAccount;
@property(nonatomic) NSString *pwd;

 
 
@end

NS_ASSUME_NONNULL_END
