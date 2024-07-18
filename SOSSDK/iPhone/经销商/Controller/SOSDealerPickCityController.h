//
//  SOSDealerPickCityController.h
//  Onstar
//
//  Created by TaoLiang on 2018/1/24.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//


@interface SOSDealerPickCityController : SOSBaseViewController
@property (strong, nonatomic) SOSCityGeocodingInfo *currentCity;
@property (copy, nonatomic) void (^pickedCity)(SOSCityGeocodingInfo *city);
@end
