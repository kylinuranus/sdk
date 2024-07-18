//
//  SOSCircleProgressView.m
//  Onstar
//
//  Created by Onstar on 2019/1/2.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSCircleProgressView.h"

@implementation SOSCircleProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _trackLayer = [[CAShapeLayer alloc]init];
        [self.layer addSublayer:_trackLayer];
        _trackLayer.fillColor = nil;
        _trackLayer.frame = self.bounds;
        
        _progressLayer = [[CAShapeLayer alloc]init];
        [self.layer addSublayer:_progressLayer];
        _progressLayer.fillColor = nil;
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.frame = self.bounds;
        
        self.progress = 4.f;
    }
    return self;
}


- (void)setTrack
{
    _trackPath = [UIBezierPath bezierPathWithArcCenter:self.center
                                                radius:(self.bounds.size.width - _progressWidth)/2
                                            startAngle:0
                                              endAngle:M_PI*2
                                             clockwise:YES];
    _trackLayer.path = _trackPath.CGPath;
}

- (void)setProgress
{
    _progressPath = [UIBezierPath bezierPathWithArcCenter:self.center
                                                   radius:(self.bounds.size.width - _progressWidth)/2
                                               startAngle:-M_PI_2 endAngle:(M_PI * 2)* _progress - M_PI_2
                                                clockwise:YES];
    _progressLayer.path = _progressPath.CGPath;
}

- (void)setProgressWidth:(float)progressWidth
{
    _progressWidth = progressWidth;
    _trackLayer.lineWidth = _progressWidth;
    _progressLayer.lineWidth = _progressWidth;
    
    [self setTrack];
    
    [self setProgress];
}


- (void)setTrackColor:(UIColor *)trackColor
{
    _trackLayer.strokeColor = trackColor.CGColor;
}

- (void)setProgressColor:(UIColor *)progressColor
{
    _progressLayer.strokeColor = progressColor.CGColor;
}

- (void)setProgress:(float)progress
{
    _progress = progress;
    
    [self setProgress];
}
@end

