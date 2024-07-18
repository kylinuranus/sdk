//
//  SOSTripPOIVC.h
//  Onstar
//
//  Created by Coir on 2019/4/17.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSTripBaseMapVC.h"

NS_ASSUME_NONNULL_BEGIN

/// POI Map VC
@interface SOSTripPOIVC : SOSTripBaseMapVC
@property (nonatomic, assign) BOOL isFromAroundSearch;
@property (nonatomic, assign) MapType mapTypeBeforChange;
@property (nonatomic, assign) SelectPointOperation operationType;
@property (nonatomic, copy) NSArray <SOSPOI *>*poiArray;

@end

NS_ASSUME_NONNULL_END
