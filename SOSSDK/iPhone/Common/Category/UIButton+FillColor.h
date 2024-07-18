//
//  UIButton+FillColor.h
//  Onstar
//
//  Created by Vicky on 16/2/17.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (FillColor)

- (void)setCommonStyle;

- (void)setRegisterStyle;
- (void)setNSButtonStyle;//修改pin码CR新样式(9.4CR) NewStytle

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;

- (void)setTitleForAllState:(NSString *)title;

- (void)setTitleForNormalState:(NSString *)title;

- (void)setTitleForHiglightedState:(NSString *)title;

- (void)setTitleForSelectedState:(NSString *)title;

- (void)resetTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

- (void)addUnderlineTitle;

@end
