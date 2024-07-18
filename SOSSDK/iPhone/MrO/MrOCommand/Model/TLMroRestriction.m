//
//  TLMroResctrion.m
//  Onstar
//
//  Created by TaoLiang on 2017/11/21.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "TLMroRestriction.h"


@implementation TLMroRestrictionData

@end

@implementation TLMroRestrictionContent

+ (void)load {
    [TLMroRestrictionContent mj_setupObjectClassInArray:^NSDictionary *{
        return @{@"data": NSStringFromClass([TLMroRestrictionData class])};
    }];

}

@end

@implementation TLMroRestriction

+ (void)load {
    
}

@end


@implementation TLMroRestrictions

+ (void)load {
    [TLMroRestrictions mj_setupObjectClassInArray:^NSDictionary *{
        return @{@"sevenDayDatas": NSStringFromClass([TLMroRestriction class])};
    }];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _selectIndex = NSUIntegerMax;
    }
    return self;
}

- (void)copyFromAnthoerRestrictions:(TLMroRestrictions *)restriction {
    self.sevenDayDatas = restriction.sevenDayDatas;
}

@end
