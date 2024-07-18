//
//  SOSDateSlider.h
//  Onstar
//
//  Created by Coir on 2020/2/17.
//  Copyright © 2020 Shanghai Onstar. All rights reserved.
//

#import "SOSBaseXibView.h"

NS_ASSUME_NONNULL_BEGIN
@class SOSDateSlider;
@protocol SOSDateSliderDelegate <NSObject>

- (void)sliderValueChanged:(SOSDateSlider *)slider;

@end

@interface SOSDateSlider : UIView

@property (nonatomic, assign) float maxValue;
@property (nonatomic, assign) float minValue;
@property (nonatomic, assign, readonly) float startValue;
@property (nonatomic, assign, readonly) float endtValue;
@property (nonatomic, weak) id <SOSDateSliderDelegate> delegate;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
