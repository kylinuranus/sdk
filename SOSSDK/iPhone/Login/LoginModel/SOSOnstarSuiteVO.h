//
//  SOSOnstarSuiteVO.h
//  Onstar
//
//  Created by Onstar on 2018/3/2.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSAccount.h"
#import "SOSVehicle.h"
@interface SOSOnstarSuiteVO : NSObject
@property(nonatomic,strong)SOSAccount * account;
@property(nonatomic,strong)SOSVehicle * vehicle;
@property(nonatomic,copy) NSString * role;
@property(nonatomic,strong) NSDictionary<NSString *,id> *avaliableServices;
@end
