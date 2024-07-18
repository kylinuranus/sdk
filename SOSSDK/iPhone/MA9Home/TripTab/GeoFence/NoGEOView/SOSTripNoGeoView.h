//
//  SOSTripNoGeoView.h
//  Onstar
//
//  Created by Coir on 2019/6/12.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSTripNoGeoView : UIView

/// LBS 设备 POI 点,非 LBS 围栏需赋值为 nil
@property (nonatomic, strong) SOSLBSPOI *lbsPOI;
/// LBS 设备信息,用于获取不到 LBS 设备 POI 点的情况,非 LBS 围栏需赋值为 nil
@property (nonatomic, strong) NNLBSDadaInfo *LBSDataInfo;

- (void)showInView:(UIView *)view;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
