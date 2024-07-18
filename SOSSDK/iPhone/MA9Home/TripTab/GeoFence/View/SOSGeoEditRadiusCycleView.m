//
//  SOSGeoEditRadiusCycleView.m
//  Onstar
//
//  Created by Coir on 2019/6/24.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSGeoEditRadiusCycleView.h"

@interface SOSGeoEditRadiusCycleView ()

@property (weak, nonatomic) IBOutlet UILabel *poiNameLabel;

@end

@implementation SOSGeoEditRadiusCycleView

- (void)setPoiName:(NSString *)poiName	{
    _poiName = poiName;
    dispatch_async_on_main_queue(^{
        self.poiNameLabel.text = poiName;
    });
}

- (void)configCycleViewWithSlider:(UISlider *)slider	{
    dispatch_async_on_main_queue(^{
        self.cycleViewWidthGuide.constant = [self thumbRectForBoundswithSlider:slider] + 5;
    });
}

- (CGFloat)thumbRectForBoundswithSlider:(UISlider *)slider   {
    if (self.isLBSMode) {
        return (slider.width - 25) * slider.value / 5 + 12.5 + 5;
    }	else	{
        return (slider.width - 25) * slider.value / 100 + 12.5 + 5;
    }
}

@end
