//
//  SOSSexangleView.m
//  Onstar
//
//  Created by Onstar on 2019/1/7.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSSexangleView.h"
@interface SOSSexangleView(){
    CAShapeLayer *shapeLayer;    //背景layer
    CAShapeLayer *progressLayer; //进度条layer
}
@end

@implementation SOSSexangleView

//- (instancetype)initWithDrawSexangleViewWidth:(CGFloat)width lineWidth:(CGFloat)lineWidth strokeColor:(UIColor *)color;
//    self = [super init];
//    if (self) {
//        [self drawSexangleWithImageViewWidth:width withLineWidth:lineWidth withStrokeColor:color];
//    }
//    return self;
//}

- (void)drawSexangleWithImageViewWidth:(CGFloat)width withLineWidth:(CGFloat)lineWidth withBackgroundStrokeColor:(UIColor *)color progressStrokeColor:(UIColor *)proColor{
    if (!shapeLayer) {
        shapeLayer = [CAShapeLayer layer];
    }
    [self.layer addSublayer:shapeLayer];
    shapeLayer.lineCap = kCALineCapRound;
    self.lineWidth = width;
    self.progressColor = proColor;
    shapeLayer.path = [self getBackgroundCGPath:width];
    shapeLayer.strokeColor = color.CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineWidth = lineWidth;
    //    shapeLayer.path = [self getCGPath:width];
    //    self.layer.mask = shapeLayer;
}

-(void)refreshProgess:(CGFloat)progress appointProgressColor:(nullable UIColor *)apColor{
    if (progressLayer) {
        [progressLayer removeFromSuperlayer];
        progressLayer = nil;
    }
    if (!progressLayer) {
      progressLayer = [CAShapeLayer layer];
    }
    [self.layer addSublayer:progressLayer];
    if (progress && progress>0) {
        progressLayer.lineCap = kCALineCapRound;
        NSLog(@"self.width--:%@...%f",self,self.size.width);
        progressLayer.path = [self getProgressCGPath:self.lineWidth];
        if (apColor) {
            progressLayer.strokeColor = apColor.CGColor;

        }else{
            progressLayer.strokeColor = self.progressColor.CGColor;

        }
        progressLayer.fillColor = [UIColor clearColor].CGColor;
        progressLayer.lineWidth = 3.0f;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        animation.duration = 3.0f;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.fromValue = [NSNumber numberWithFloat:0.0f];
        animation.toValue = [NSNumber numberWithFloat:1.0f - progress];
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        [progressLayer addAnimation:animation forKey:nil];
    }
    //[progressLayer addAnimation:animation forKey:NSStringFromSelector(@selector(strokeEnd))];
}

-(void)startCircleAnimation{
    if (progressLayer) {
        [progressLayer removeFromSuperlayer];
        progressLayer = nil;
    }
    if (!progressLayer) {
        progressLayer = [CAShapeLayer layer];

    }
    [self.layer addSublayer:progressLayer];
    progressLayer.lineCap = kCALineCapRound;
    NSLog(@"self.width--:%@...%f",self,self.size.width);
    progressLayer.path = [self getAnimationCGPath:self.lineWidth];
    progressLayer.strokeColor = self.progressColor.CGColor;
    progressLayer.fillColor = [UIColor clearColor].CGColor;
    progressLayer.lineWidth = 3.0f;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = 3.0f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = [NSNumber numberWithFloat:0.0f];
    animation.toValue = [NSNumber numberWithFloat:1.0f];
    animation.fillMode = kCAFillModeForwards;
    animation.repeatCount = CGFLOAT_MAX;
    animation.removedOnCompletion = NO;
    [progressLayer addAnimation:animation forKey:nil];
    //[progressLayer addAnimation:animation forKey:NSStringFromSelector(@selector(strokeEnd))];
}
-(void)stopCircleAnimation{
    if (progressLayer) {
        [progressLayer removeAllAnimations];
        [progressLayer removeFromSuperlayer];
        progressLayer = nil;
    }
}

/**
 背景路径
 @param width
 @return
 */
- (CGPathRef)getBackgroundCGPath:(CGFloat)width {
    
    CGFloat radius = 7;
    
    CGMutablePathRef path1 = CGPathCreateMutable();
    CGPathMoveToPoint(path1, NULL, (width / 2)+(width/4), (width / 2) + (width / 4)+0.125*width-2);
    CGPathAddArcToPoint(path1, NULL, width - ((sin(M_1_PI / 180 * 60)) * (width / 2)), (width / 2) + (width / 4), width - ((sin(M_1_PI / 180 * 60)) * (width / 2)), (width / 4), radius);

    CGPathAddArcToPoint(path1, NULL, width - ((sin(M_1_PI / 180 * 60)) * (width / 2)),  (width / 4), (width / 2), 0, radius);

    CGPathAddArcToPoint(path1, NULL, (width / 2), 0, (sin(M_1_PI / 180 * 60)) * (width / 2), (width / 4), radius);
    
    CGPathAddArcToPoint(path1, NULL,  (sin(M_1_PI / 180 * 60)) * (width / 2),  (width / 4), (sin(M_1_PI / 180 * 60)) * (width / 2), (width / 2) + (width / 4), radius);
    
    CGPathAddArcToPoint(path1, NULL,  (sin(M_1_PI / 180 * 60)) * (width / 2), (width / 2) + (width / 4), (width / 2), width, radius);
    
    CGPathAddArcToPoint(path1, NULL,  (width / 2), width, width - ((sin(M_1_PI / 180 * 60)) * (width / 2)), (width / 2) + (width / 4), radius);

    
    CGPathCloseSubpath(path1);
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithCGPath:path1];
    bezierPath.lineJoinStyle = kCGLineJoinBevel; //拐点样式

    CGPathRelease(path1);
    return bezierPath.CGPath;
}

/**
 进度条路径
 @param width
 @return
 */
- (CGPathRef)getProgressCGPath:(CGFloat)width {
    
    CGFloat radius = 7;
    CGMutablePathRef path1 = CGPathCreateMutable();
    CGPathMoveToPoint(path1, NULL, (width / 2)+1.2, width-1.25);
    CGPathAddArcToPoint(path1, NULL, width - ((sin(M_1_PI / 180 * 60)) * (width / 2)), (width / 2) + (width / 4), width - ((sin(M_1_PI / 180 * 60)) * (width / 2)), (width / 4), radius);

    CGPathAddArcToPoint(path1, NULL, width - ((sin(M_1_PI / 180 * 60)) * (width / 2)),  (width / 4), (width / 2), 0, radius);

    CGPathAddArcToPoint(path1, NULL, (width / 2), 0, (sin(M_1_PI / 180 * 60)) * (width / 2), (width / 4), radius);

    CGPathAddArcToPoint(path1, NULL,  (sin(M_1_PI / 180 * 60)) * (width / 2),  (width / 4), (sin(M_1_PI / 180 * 60)) * (width / 2), (width / 2) + (width / 4), radius);

    CGPathAddArcToPoint(path1, NULL,  (sin(M_1_PI / 180 * 60)) * (width / 2), (width / 2) + (width / 4), (width / 2), width, radius);

    CGPathAddLineToPoint(path1, NULL,  (width / 2)-1.2, width-1.25);
//    CGPathAddArcToPoint(path1, NULL, , width - ((sin(M_1_PI / 180 * 60)) * (width / 2)), (width / 2) + (width / 4), radius);

//    CGPathCloseSubpath(path1);

    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithCGPath:path1];
    bezierPath.lineJoinStyle = kCGLineJoinBevel; //拐点样式

    CGPathRelease(path1);
    return bezierPath.CGPath;
}

/**
顺时针环形循环动画路径
 @param width
 @return
 */
- (CGPathRef)getAnimationCGPath:(CGFloat)width {
    
    UIBezierPath * path = [UIBezierPath bezierPath];
    path.lineJoinStyle = kCGLineJoinRound; //拐点样式
    
    [path moveToPoint:CGPointMake((sin(M_1_PI / 180 * 60)) * (width / 2), (width / 2) + (width / 4))];//5
    [path addLineToPoint:CGPointMake((sin(M_1_PI / 180 * 60)) * (width / 2), (width / 4))];//4
    [path addLineToPoint:CGPointMake((width / 2), 0)];//3
    [path addLineToPoint:CGPointMake(width - ((sin(M_1_PI / 180 * 60)) * (width / 2)), (width / 4))];//2
    [path addLineToPoint:CGPointMake(width - ((sin(M_1_PI / 180 * 60)) * (width / 2)), (width / 2) + (width / 4))];//1
    [path addLineToPoint:CGPointMake((width / 2), width)];// start
    [path closePath];// end
    return path.CGPath;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
