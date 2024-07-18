//
//  SQCEntity.h
//  TestCoreData
//
//  Created by shudingcai on 11/3/16.
//  Copyright © 2016 eamon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SQCEntity : NSManagedObject

@property (nonatomic) int32_t key_Id;
@property (nullable, nonatomic, copy) NSString *vkno; //VK 编号
@property (nullable, nonatomic, copy) NSString *vkkey;

@property (nullable, nonatomic, copy) NSString *csk;
@property (nullable, nonatomic, copy) NSString *sha256;
@property (nullable, nonatomic, copy) NSString *idpuserid;
@property (nullable, nonatomic, copy) NSString *vin;
@property (nullable, nonatomic, copy) NSString *keyTime;//时端
@property (nullable, nonatomic, copy) NSString *startTime;
@property (nullable, nonatomic, copy) NSString *endTime;
@property (nonatomic) BOOL key_IsInUsing;
//+ (NSFetchedResultsController *)fetchedResultsController:(NSString *)username;


@end
