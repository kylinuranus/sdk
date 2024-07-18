//
//  SOSDateSlider.m
//  Onstar
//
//  Created by Coir on 2020/2/17.
//  Copyright © 2020 Shanghai Onstar. All rights reserved.
//

#import "SOSDateSlider.h"

@interface SOSDateSlider ()

@property (weak, nonatomic) IBOutlet UIView *sliderBGView;
@property (weak, nonatomic) IBOutlet UIImageView *startImgView;
@property (weak, nonatomic) IBOutlet UIImageView *endImgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startImgLeadingGuide;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endImgTrailingGuide;

@property (strong, nonatomic) CALayer *sliderCoverLayer;

@property (strong, nonatomic) UIPanGestureRecognizer *startPanGes;
@property (strong, nonatomic) UIPanGestureRecognizer *endtPanGes;

@end

@implementation SOSDateSlider

- (void)awakeFromNib	{
    [super awakeFromNib];
    self.startPanGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGes:)];
    self.endtPanGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGes:)];
    [self.startImgView addGestureRecognizer:self.startPanGes];
    [self.endImgView addGestureRecognizer:self.endtPanGes];
    self.sliderCoverLayer = [CALayer layer];
    [self.sliderBGView.layer addSublayer:self.sliderCoverLayer];
    self.sliderCoverLayer.backgroundColor = [UIColor colorWithHexString:@"6CCA46"].CGColor;
    self.sliderCoverLayer.frame = CGRectMake(0, 0, self.sliderBGView.width, 4);
    self.sliderCoverLayer.masksToBounds = YES;
    self.sliderCoverLayer.cornerRadius = 2;
}

- (void)handlePanGes:(UIPanGestureRecognizer *)panGes	{
    if (panGes.state == UIGestureRecognizerStateBegan) 	{
        
    } else if (panGes.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGes translationInView:self];
        NSLog(@"%@", @(translation.x));
        float newCenterX = panGes.view.center.x + translation.x;
        if (panGes == self.startPanGes) {
            if (newCenterX <= self.sliderBGView.left + 1) 		return;
            if (newCenterX + 16 >= self.endImgView.centerX) 	return;
        }	else if (panGes == self.endtPanGes)	{
            if (newCenterX >= self.sliderBGView.right - 1)		return;
            if (newCenterX - 16 <= self.startImgView.centerX)	return;
        }
        panGes.view.center = CGPointMake(newCenterX, self.startImgView.centerY);
        [panGes setTranslation:CGPointZero inView:self];
        [self updateValuesAndFrameWithGes:panGes];
    } else if (panGes.state == UIGestureRecognizerStateEnded || panGes.state == UIGestureRecognizerStateCancelled) {
        CGPoint translation = [panGes translationInView:self];
        float newCenterX = panGes.view.center.x + translation.x;
        if (panGes == self.startPanGes && (newCenterX - self.sliderBGView.left < 3)) {
                self.startImgView.centerX = self.sliderBGView.left + 1;
        }    else if (panGes == self.endtPanGes && (self.sliderBGView.right - newCenterX < 3))    {
                self.endImgView.centerX = self.sliderBGView.right - 1;
        }
        [self updateValuesAndFrameWithGes:panGes];
    }
}

- (void)updateValuesAndFrameWithGes:(UIPanGestureRecognizer *)panGes	{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.sliderCoverLayer.frame = CGRectMake(self.startImgView.centerX - self.sliderBGView.left - 1, 0,
                                             self.endImgView.centerX - self.startImgView.centerX + 2, 4);
    [CATransaction commit];
    
    if (panGes == self.startPanGes)        {
        _startValue = (self.startImgView.centerX - self.sliderBGView.left - 1) / self.sliderBGView.width
                    * (self.maxValue - self.minValue) + self.minValue;
    }    else if (panGes == self.endtPanGes)    {
        _endtValue = (self.endImgView.centerX - self.sliderBGView.left + 1) / self.sliderBGView.width
                    * (self.maxValue - self.minValue) + self.minValue;
    }
    __weak __typeof(self) weakSelf = self;
    if (self.delegate && [self.delegate respondsToSelector:@selector(sliderValueChanged:)]) {
        [self.delegate sliderValueChanged:weakSelf];
    }
}

- (void)reset	{
    self.startImgView.centerX = self.sliderBGView.left + 1;
    self.endImgView.centerX = self.sliderBGView.right - 1;
    self.sliderCoverLayer.frame = CGRectMake(self.startImgView.centerX - self.sliderBGView.left - 1, 0,
                                             self.endImgView.centerX - self.startImgView.centerX + 2, 4);
    _startValue = self.minValue;
    _endtValue = self.maxValue;
    __weak __typeof(self) weakSelf = self;
    if (self.delegate && [self.delegate respondsToSelector:@selector(sliderValueChanged:)]) {
        [self.delegate sliderValueChanged:weakSelf];
    }
}


@end
