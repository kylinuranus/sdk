//
//  SOSTripHomeVC.h
//  Onstar
//
//  Created by Onstar on 2018/11/17.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSModuleProtocols.h"
#import "SOSTripBaseMapVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface SOSTripHomeVC : SOSTripBaseMapVC <SOSHomeTripTabProtocol>

/// 底部卡片滑动事件处理
- (void)moveTripCardBGScrollViewWithOffset:(float)offset;

/// 底部卡片滑动事件处理
- (void)moveEnded;

/// 隐藏引导按钮
- (void)hideGuideButton;

/// 显示LBS
- (void)showLBS;

- (void)removeLBSPOI;

- (void)setVehicleLocationResultBlockWhenArrear:(completedBlock)block;

-(void)refreshFootPrint;
@end

NS_ASSUME_NONNULL_END
