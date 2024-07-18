//
//  SOSEmergencyContact.h
//  Onstar
//
//  Created by Onstar on 2018/3/2.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSContact.h"
@interface SOSEmergencyContact : NSObject
@property(nonatomic,copy)NSString * priorityRankingNumeric;
@property(nonatomic,strong)SOSContact * contact;
@end
