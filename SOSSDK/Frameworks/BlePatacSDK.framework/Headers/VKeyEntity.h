//
//  VKeyEntity.h
//  BlePatacSDK
//
//  Created by shudingcai on 25/05/2018.
//  Copyright © 2018 shudingcai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VKeyEntity : NSObject


@property (nullable, nonatomic, copy) NSString * vkno; //VK 编号
@property (nullable, nonatomic, copy) NSString *idpuserid;
@property (nullable, nonatomic, copy) NSString *vin;
@property (nullable, nonatomic, copy) NSString *keyTime;//时端
@property (nullable, nonatomic, copy) NSString *startTime;//时端
@property (nullable, nonatomic, copy) NSString *endTime;//时端
@end
