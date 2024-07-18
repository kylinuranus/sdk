//
//  SOSFanSliderView.h
//  Onstar
//
//  Created by Coir on 2018/4/23.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSBaseXibView.h"

@protocol SOSFanSliderDelegate	<NSObject>

- (void)fanValueChangedWithValue:(int)fanValue;

@end

@interface SOSFanSliderView : SOSBaseXibView

@property (weak, nonatomic) id <SOSFanSliderDelegate> delegate;
/// 风力大小 ( 0 - 15 )
@property (assign, nonatomic) int fanValue;

@end
