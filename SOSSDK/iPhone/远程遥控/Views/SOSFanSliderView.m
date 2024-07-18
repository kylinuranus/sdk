//
//  SOSFanSliderView.m
//  Onstar
//
//  Created by Coir on 2018/4/23.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSFanSliderView.h"

@interface SOSFanSliderView ()	<UIGestureRecognizerDelegate>

@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@property (weak, nonatomic) IBOutlet UISlider *fanSlider;
@property (weak, nonatomic) IBOutlet UIImageView *fanImgView;

@end

@implementation SOSFanSliderView

//- (instancetype)initWithCoder:(NSCoder *)aDecoder    {
//    UIView *bgView = [super initWithCoder:aDecoder];
//    SOSFanSliderView *view = [[NSBundle mainBundle] loadNibNamed:@"SOSFanSliderView" owner:nil options:nil][0];
//    [view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(bgView.mas_top);
//        make.bottom.equalTo(bgView.mas_bottom);
//        make.left.equalTo(bgView.mas_left);
//        make.right.equalTo(bgView.mas_right);
//    }];
//    [bgView addSubview:view];
//}

- (void)awakeFromNib	{
    [super awakeFromNib];
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapGesture:)];
    self.tapGesture.delegate = self;
    [self.fanSlider addGestureRecognizer:self.tapGesture];
}

- (void)setFanValue:(int)fanValue	{
    if (fanValue > 6)		fanValue = 6;
    else if (fanValue < 0)	fanValue = 0;
    _fanValue = fanValue;
    [self.fanSlider setValue:fanValue animated:NO];
    NSString *imgName = [NSString stringWithFormat:@"icon_wind speed_%d_216x22", fanValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.fanImgView.image = [UIImage imageNamed:imgName];
    });
    if (self.delegate && [self.delegate respondsToSelector:@selector(fanValueChangedWithValue:)]) {
        [self.delegate fanValueChangedWithValue:fanValue];
    }
}

- (IBAction)fanSliderValueChanged:(UISlider *)sender {
    int value = roundf(sender.value);
    if (value == self.fanValue) 		return;
    self.fanValue = value;
    NSString *imgName = [NSString stringWithFormat:@"icon_wind speed_%d_216x22", value];
    self.fanImgView.image = [UIImage imageNamed:imgName];
}

- (void)actionTapGesture:(UITapGestureRecognizer *)sender {
    CGPoint touchPoint = [sender locationInView:self.fanSlider];
    CGFloat value = (self.fanSlider.maximumValue - self.fanSlider.minimumValue) * (touchPoint.x / self.fanSlider.frame.size.width );
    [self.fanSlider setValue:value animated:NO];
    self.fanValue = roundf(value);
}

- (IBAction)sliderTouchDown:(UISlider *)sender {
    self.tapGesture.enabled = NO;
}

- (IBAction)sliderTouchUp:(UISlider *)sender {
    self.tapGesture.enabled = YES;
}

@end
