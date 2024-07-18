//
//  CaclulateDateModel.m
//  Onstar
//
//  Created by 张万强 on 15/4/8.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import "CaclulateDateModel.h"

@implementation CaclulateDateModel
- (id)initWithDictionary:(NSDictionary *) dic     {
    if (self = [super init]) {
        self.caclulateDateTitle = [dic objectForKey:@"title"];
        self.caclulateDateSmailTitle = [dic objectForKey:@"titlesmail"];
        self.caclulateDateUnit = [dic objectForKey:@"unit"];
        self.caclulateDateCount = [dic objectForKey:@"percent"];
        self.caclulateDateAverageDate = [dic objectForKey:@"data"];
    }
    return self;
}

@end
