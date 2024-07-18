//
//  SOSBleShareDateView.h
//  Onstar
//
//  Created by onstar on 2018/7/24.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSBleShareDateView : UIView

@property (nonatomic, copy) void (^dateButtonTapBlock)(SOSBleShareDateView *dateV,UIButton *button);
@property (nonatomic, copy) void (^shareButtonTapBlock)(SOSBleShareDateView *dateV);


@property (nonatomic, strong, readonly) NSDate *startTime;
@property (nonatomic, strong, readonly) NSDate *endTime;

- (void)equalStartTime;

- (void)dismiss ;

@end
