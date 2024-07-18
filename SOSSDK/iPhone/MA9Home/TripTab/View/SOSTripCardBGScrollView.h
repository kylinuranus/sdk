//
//  SOSTripCardBGScrollView.h
//  Onstar
//
//  Created by Coir on 2018/12/18.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSTripCardBGScrollView : UIScrollView

- (void)reloadOliData;

- (void)reloadEnergyData;

- (void)reloadDriveBehiverData;

- (void)reloadFootPrintData;

- (void)reloadTrailCardData;

// 切换时过场动画
- (void)startAnimating;

@property (nonatomic, assign) BOOL shouldReloadOilData;
@property (nonatomic, assign) BOOL shouldReloadEnergyData;
@property (nonatomic, assign) BOOL shouldReloadDriveBehiverData;
@property (nonatomic, assign) BOOL shouldReloadFootPrintData;

@end

NS_ASSUME_NONNULL_END
