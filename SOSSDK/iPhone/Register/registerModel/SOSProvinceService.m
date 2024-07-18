//
//  SOSProvinceService.m
//  Onstar
//
//  Created by Onstar on 2017/10/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSProvinceService.h"
#import "OthersUtil.h"
@implementation SOSProvinceService
- (id)init
{
    if (self = [super init]) {
        
    }
    return self;
}
- (void)fetchProvincesComplete:(fetchComplete)completeBlock_
{
    SOSWeakSelf(weakSelf);
    [OthersUtil getProvinceInfosuccessHandler:^(NSArray *responsePro) {
        if (responsePro) {
            weakSelf.provinceList = responsePro;
        }
        completeBlock_(responsePro);
        
    } failureHandler:^(NSString *responseStr, NSError *error) {
        completeBlock_(nil);
    }];
}
- (void)fetchCityWithProvinceCode:(NSString *)pro Complete:(fetchComplete)completeBlock_
{
    SOSWeakSelf(weakSelf);
    [OthersUtil getCityInfoByProvince:pro successHandler:^(NSArray *responsePro) {
        weakSelf.cityList = responsePro;
        completeBlock_(responsePro);
        
    } failureHandler:^(NSString *responseStr, NSError *error) {
        completeBlock_(nil);
    }];
}

@end
