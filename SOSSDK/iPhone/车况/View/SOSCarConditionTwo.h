//
//  SOSCarConditionTwo.h
//  Onstar
//
//  Created by Genie Sun on 2017/7/28.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSBaseXibView.h"

@interface SOSCarConditionTwo : SOSBaseXibView
@property (weak, nonatomic) IBOutlet UILabel *FuelLb;
@property (weak, nonatomic) IBOutlet UILabel *meter;
@property (weak, nonatomic) IBOutlet UILabel *oilLb;

- (void)configView;

/**
 车辆检测报告刷新
 */
- (void)configViewForDectViewWidth:(NNOVDEmailDTO *)ovdEmail;

@end
