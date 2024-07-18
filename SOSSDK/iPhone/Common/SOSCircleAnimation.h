//
//  SOSCircleAnimation.h
//  Onstar
//
//  Created by Genie Sun on 2017/7/25.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSCircleAnimation : UIView
@property(nonatomic, strong) CAShapeLayer *backgroundLayer;
@property(nonatomic, strong) CAShapeLayer *fillShapeLayer;
@property(nonatomic, assign) CGFloat animationValue;
@property(nonatomic, assign) CGFloat radius;


@property(nonatomic, strong) UIColor *backgroundStrokeColor;
@property(nonatomic, strong) UIColor *fillStrokeColor;

- (instancetype)initWithFrame:(CGRect)frame strokeVaule:(CGFloat)animationValue withRadius:(CGFloat)radius;

- (instancetype)initWithFrame:(CGRect)frame
                  strokeVaule:(CGFloat)animationValue
                   withRadius:(CGFloat)radius
                   startAngle:(CGFloat)startAngle
                     endAngle:(CGFloat)endAngle
                    lineWidth:(CGFloat)lineWidth
                    positionY:(CGFloat) positionY;


@end
