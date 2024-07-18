//
//  SOSProvinceService.h
//  Onstar
//
//  Created by Onstar on 2017/10/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^fetchComplete)(NSArray * infoArray);

@interface SOSProvinceService : NSObject
@property(nonatomic,strong) NSArray     * provinceList;
@property(nonatomic,strong) NSArray     * cityList;
- (void)fetchProvincesComplete:(fetchComplete)completeBlock_;
- (void)fetchCityWithProvinceCode:(NSString *)pro Complete:(fetchComplete)completeBlock_;
@end
