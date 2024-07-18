//
//  SOSAccount.h
//  Onstar
//
//  Created by Onstar on 2018/3/2.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOSAccount : NSObject
@property(nonatomic,copy)NSString * accountId;
@property(nonatomic,copy)NSString * startDate;
@property(nonatomic,copy)NSString * createDate;
@property(nonatomic,copy)NSString * accountType;
@property(nonatomic,copy)NSString * accoutStatus;

@property(nonatomic,copy)NSString * country;
@property(nonatomic,copy)NSString * province;
@property(nonatomic,copy)NSString * city;
@property(nonatomic,copy)NSString * address1;
@property(nonatomic,copy)NSString * address2;
@property(nonatomic,copy)NSString * postCode;
@end
