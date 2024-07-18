//
//  SOSCircleAnimation.m
//  Onstar
//
//  Created by Genie Sun on 2017/7/25.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSCircleAnimation.h"


@interface SOSCircleAnimation ()

@property (nonatomic, assign) CGFloat startAngle;
@property (nonatomic, assign) CGFloat endAngle;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat positionY;
@end

@implementation SOSCircleAnimation

- (instancetype)initWithFrame:(CGRect)frame strokeVaule:(CGFloat)animationValue withRadius:(CGFloat)radius
{
    return [self initWithFrame:frame strokeVaule:animationValue withRadius:radius startAngle:M_PI * 2 / 2.5 endAngle:M_PI * 2 / 10 lineWidth:10 positionY:6];
}

- (instancetype)initWithFrame:(CGRect)frame
                  strokeVaule:(CGFloat)animationValue
                   withRadius:(CGFloat)radius
                   startAngle:(CGFloat)startAngle
                     endAngle:(CGFloat)endAngle
                    lineWidth:(CGFloat)lineWidth
                    positionY:(CGFloat) positionY
{
    self = [super initWithFrame:frame];
    if (self) {
        self.animationValue = animationValue;
        self.radius = radius;
        self.startAngle = startAngle;
        self.endAngle = endAngle;
        self.lineWidth = lineWidth;
        self.positionY = positionY;
        [self createBackgroundLayer];
        [self createCricleLayer];
        [self createCricleAnimation];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
    
}


- (void)createBackgroundLayer
{
    self.backgroundLayer = [[CAShapeLayer alloc] init];
    self.backgroundLayer.strokeColor = [UIColor colorWithHexString:@"7DB9EC"].CGColor;
    self.backgroundLayer.fillColor = [UIColor clearColor].CGColor;
    self.backgroundLayer.lineWidth = self.lineWidth;
    
    self.backgroundLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.centerX, self.centerY + self.positionY) radius:self.radius startAngle:self.startAngle endAngle:self.endAngle clockwise:YES].CGPath;
    self.backgroundLayer.lineCap = kCALineCapRound;
    [self.layer addSublayer:self.backgroundLayer];
}

- (void)createCricleLayer
{
    self.fillShapeLayer = [[CAShapeLayer alloc]init];
    self.fillShapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.fillShapeLayer.fillColor = [UIColor clearColor].CGColor;
    self.fillShapeLayer.lineWidth = self.lineWidth;
    
    self.fillShapeLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.centerX, self.centerY  + self.positionY) radius:self.radius startAngle:self.startAngle endAngle:self.endAngle clockwise:YES].CGPath;
    self.fillShapeLayer.strokeStart = 0;
    self.fillShapeLayer.strokeEnd = self.animationValue;
    self.fillShapeLayer.lineCap = kCALineCapRound;
    
    [self.layer addSublayer:self.fillShapeLayer];
}

- (void)createCricleAnimation
{
    CABasicAnimation * strokeEndAnimate = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeEndAnimate.fromValue = [NSNumber numberWithFloat:0.0];
    strokeEndAnimate.toValue = [NSNumber numberWithFloat:self.animationValue];
    
    CAAnimationGroup *strokeAnimateGroup = [CAAnimationGroup animation];
    strokeAnimateGroup.duration = 1.5;
    strokeAnimateGroup.repeatCount = 1;
    strokeAnimateGroup.animations = @[strokeEndAnimate];
    
    [self.fillShapeLayer addAnimation:strokeAnimateGroup forKey:nil];
}

- (void)setBackgroundStrokeColor:(UIColor *)backgroundStrokeColor
{
    self.backgroundLayer.strokeColor = backgroundStrokeColor.CGColor;
}

- (void)setFillStrokeColor:(UIColor *)fillStrokeColor
{
    self.fillShapeLayer.strokeColor = fillStrokeColor.CGColor;
}

- (void)setAnimationValue:(CGFloat)animationValue {
    if (animationValue > 1) {
        animationValue = animationValue/100.0;
    }
    _animationValue = animationValue;
    self.fillShapeLayer.strokeEnd = self.animationValue;
    [self createCricleAnimation];
}

@end
