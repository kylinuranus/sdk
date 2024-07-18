//
//  IPData.h
//  Onstar
//
//  Created by lizhipan on 17/1/9.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPData : NSObject
@property(nonatomic,copy)NSString * blacklisted;
@property(nonatomic,strong)NSArray * geoip;
@property(nonatomic,copy)NSString * ip;
@property(nonatomic,copy)NSString * time;
@end
