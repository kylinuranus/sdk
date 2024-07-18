//
//  SOSSubscriber.h
//  Onstar
//
//  Created by Onstar on 2018/3/2.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSEmergencyContact.h"
#import "SOSUserPreference.h"

@interface SOSSubscriber : NSObject
@property(nonatomic,copy) NSString * subscriberId;
@property(nonatomic,copy) NSString * guid;
@property(nonatomic,copy) NSString *governmentId;
@property(nonatomic,copy) NSString * givenName;
@property(nonatomic,copy) NSString * familyName;
@property(nonatomic,copy) NSString * title;
@property(nonatomic,copy) NSString * gender;
@property(nonatomic,copy) NSString * mobilePhone;
@property(nonatomic,copy) NSString * emailAddress;
@property(nonatomic,copy) NSString * status;
@property(nonatomic,copy) NSString * subscriberSinceDate;
@property(nonatomic,assign) BOOL subscriberPasswordIndicator;
@property(nonatomic,copy) NSString * iceOptInDate;
@property(nonatomic,assign) BOOL iceOptInIndicator;
@property(nonatomic,strong) SOSEmergencyContact * emergencyContact;
//addition
@property(nonatomic,assign) BOOL isDefaultPin;//是否是默认pin

@end
