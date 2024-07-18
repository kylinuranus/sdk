//
//  SOSBEVView.h
//  Onstar
//
//  Created by Genie Sun on 2017/7/26.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSBaseXibView.h"

@protocol SOSBEVViewDelegate <NSObject>

- (void)pushChargeStationVc;
- (void)pushSettingVc;

@end

@interface SOSBEVView : SOSBaseXibView

@property(nonatomic, assign) id<SOSBEVViewDelegate> delegate;
- (void)configView;

@end
