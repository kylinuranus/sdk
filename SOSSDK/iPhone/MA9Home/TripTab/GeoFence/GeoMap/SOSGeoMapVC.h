//
//  SOSGeoMapVC.h
//  Onstar
//
//  Created by Coir on 2019/6/12.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSTripBaseMapVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface SOSGeoMapVC : SOSTripBaseMapVC

/// 正在编辑的围栏
@property (nonatomic, strong) NNGeoFence *editingGeofence;

- (instancetype)initWithGeoFence:(NNGeoFence *)geoFence;

@end

NS_ASSUME_NONNULL_END
