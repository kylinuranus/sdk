//
//  CaclulateDateModel.h
//  Onstar
//
//  Created by 张万强 on 15/4/8.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CaclulateDateModel : NSObject

@property(nonatomic,strong) NSString * caclulateDateTitle;

@property(nonatomic,strong) NSString * caclulateDateSmailTitle;

@property(nonatomic,strong) NSString * caclulateDateAverageDate;

@property(nonatomic,strong) NSString * caclulateDateCount;

@property(nonatomic,strong) NSString * caclulateDateUnit;

- (id)initWithDictionary:(NSDictionary *) dic;

@end
