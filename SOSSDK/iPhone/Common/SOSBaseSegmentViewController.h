//
//  SOSBaseSegmentViewController.h
//  Onstar
//
//  Created by Genie Sun on 2017/8/2.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLSegmentBarVC.h"

@interface SOSBaseSegmentViewController : UIViewController
@property (nonatomic,weak) LLSegmentBarVC * segmentVC;
@property (nonatomic, assign) int selectedIndex;

- (void)setUpWithItems:(NSArray *)items childVCs:(NSArray *)vcArray;
- (void)setUpWithSpecialItems:(NSArray *)items childVCs:(NSArray *)vcArray;

///配置nav默认返回Button
- (void)setUpDefaultNavBackItem;

@end
