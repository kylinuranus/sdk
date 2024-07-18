//
//  SOSSwitch.h
//  Onstar
//
//  Created by Coir on 2020/1/14.
//  Copyright © 2020 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SOSSwitch;
@protocol SOSSwitchDelegate <NSObject>

- (void)sosSwitchValueChanged:(SOSSwitch *)sosSwitch;

@end

@interface SOSSwitch : UIView

@property (nonatomic,getter=isOn) BOOL on;
@property (nonatomic, weak) id <SOSSwitchDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame;

- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

- (void)setOn:(BOOL)on animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
