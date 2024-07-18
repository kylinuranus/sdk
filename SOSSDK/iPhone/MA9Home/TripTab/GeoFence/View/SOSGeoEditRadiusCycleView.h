//
//  SOSGeoEditRadiusCycleView.h
//  Onstar
//
//  Created by Coir on 2019/6/24.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSGeoEditRadiusCycleView : UIView

/// POI 名称
@property (nonatomic, copy) NSString *poiName;
@property (nonatomic, assign) BOOL isLBSMode;
@property (weak, nonatomic) IBOutlet UIView *cycleView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cycleViewWidthGuide;

- (void)configCycleViewWithSlider:(UISlider *)slider;

@end

NS_ASSUME_NONNULL_END
