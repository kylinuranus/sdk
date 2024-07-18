//
//  Keyinfo.h
//  BlePatacSDK
//
//  Created by shudingcai on 09/05/2018.
//  Copyright © 2018 shudingcai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Keyinfo : NSObject
@property (nullable, nonatomic, copy) NSString * vkno; //VK 编号
@property (nullable, nonatomic, copy) NSString *vkkey;

@property (nullable, nonatomic, copy) NSString *csk;
@property (nullable, nonatomic, copy) NSString *sha256;
@property (nullable, nonatomic, copy) NSString *idpuserid;
@property (nullable, nonatomic, copy) NSString *vin;
@property (nullable, nonatomic, copy) NSString *keyTime;//时端
@property (nullable, nonatomic, copy) NSString *startTime;//开始
@property (nullable, nonatomic, copy) NSString *endTime;//结束
@end
