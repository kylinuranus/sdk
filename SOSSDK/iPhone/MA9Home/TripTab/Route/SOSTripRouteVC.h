//
//  SOSTripRouteVC.h
//  Onstar
//
//  Created by Coir on 2019/4/17.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSTripBaseMapVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface SOSTripRouteVC : SOSTripBaseMapVC

/// 起点可传 nil , 为空时默认以当前定位为起点
- (instancetype)initWithRouteBeginPOI:(SOSPOI *)beginPOI AndEndPOI:(SOSPOI *)endPOI;

- (instancetype)initWithRouteBeginPOI:(SOSPOI *)beginPOI AndEndPOI:(SOSPOI *)endPOI IsFindCarMode:(BOOL)isFindCarMode;

/// 页面出现后,可以调用此方法变更路线起终点, 起终点传入 nil 时不做变更
- (void)routePOIChangedWithBeginPOI:(nullable SOSPOI *)beginPOI AndEndPOI:(nullable SOSPOI *)endPOI;

/// 开始导航
- (void)beginGPSWithStrategy:(DriveStrategy)strategy;

@end

NS_ASSUME_NONNULL_END
