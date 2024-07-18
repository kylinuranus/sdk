//
//  SOSOilMapVC.h
//  Onstar
//
//  Created by Coir on 2019/8/25.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSTripBaseMapVC.h"

NS_ASSUME_NONNULL_BEGIN

/// 加油站地图页面
@interface SOSOilMapVC : SOSTripBaseMapVC

@property (nonatomic, assign) BOOL isFromAroundSearch;
@property (nonatomic, assign) BOOL isFromLifePage;
@property (nonatomic, copy) NSArray <SOSPOI *>*poiArray;
@property (nonatomic, copy) NSArray<SOSOilInfoObj *> *oilInfoList;
@property (nonatomic, copy) NSArray<SOSOilStation *> *stationList;

@end

NS_ASSUME_NONNULL_END
