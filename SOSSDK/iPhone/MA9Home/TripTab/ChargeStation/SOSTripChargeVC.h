//
//  SOSTripChargeVC.h
//  Onstar
//
//  Created by Coir on 2019/4/23.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSTripBaseMapVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface SOSTripChargeVC : SOSTripBaseMapVC
//车况页面进来的不需要展示地图
@property (nonatomic, assign) BOOL carConditionPush;
@end

NS_ASSUME_NONNULL_END
