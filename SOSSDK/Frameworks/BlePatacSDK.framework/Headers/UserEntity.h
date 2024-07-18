//
//  UserEntity.h
//  BlePatacSDK
//
//  Created by shudingcai on 13/05/2018.
//  Copyright © 2018 shudingcai. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface UserEntity : NSManagedObject
@property (nullable, nonatomic, copy) NSString *iduserid;
@property (nullable, nonatomic, copy) NSString *endtime;
@property (nullable, nonatomic, copy) NSString *starttime;
@property (nullable, nonatomic, copy) NSString *ticket;
@end
