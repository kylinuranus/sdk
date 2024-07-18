//
//  SOSProgressBar.m
//  Onstar
//
//  Created by Onstar on 2019/1/21.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSProgressBar.h"

////
@interface SOSProgressBarBackground : UIView
@property (nonatomic, strong) UIColor *tintColor;
@end
@implementation SOSProgressBarBackground
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor blueColor]];
    }
    return self;
}

//-(void)drawRect:(CGRect)rect{
//
//    UIBezierPath* progressCanvasPath = [UIBezierPath bezierPathWithRoundedRect: rect cornerRadius: rect.size.height/2];
//    [_tintColor setFill];
//    [progressCanvasPath fill];
//
//}
@end

@interface SOSProgressBarActiveBackground : UIView
@property (nonatomic, strong) UIColor *tintColor;
@end
@implementation SOSProgressBarActiveBackground

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor redColor]];
    }
    return self;
}

//-(void)drawRect:(CGRect)rect{
//    UIBezierPath* progressCanvasPath = [UIBezierPath bezierPathWithRoundedRect: rect cornerRadius: rect.size.height/2];
//    [[UIColor redColor] setFill];
//    [progressCanvasPath fill];
//}

//-(void)layoutSubviews{
//    [self setNeedsDisplayInRect:self.frame];
//}
@end
#pragma mark - progress
@interface SOSProgressBar()

@property (nonatomic, strong) UIView *activeBar;
@property (nonatomic, strong) UIView *barBackground;
@end
@implementation SOSProgressBar
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self setUp];
}

-(void)setUp{
    _barBackground = [[UIView alloc] initWithFrame:self.bounds];
    _barBackground.layer.cornerRadius = self.frame.size.height/2;
//    _barBackground.backgroundColor = [UIColor redColor];
    [self addSubview:_barBackground];
    
    _activeBar = [[UIView alloc] initWithFrame:CGRectMake(1, 1, self.bounds.size.width-2, self.bounds.size.height -2)];
//     _activeBar.backgroundColor = [UIColor blueColor];
    _activeBar.layer.cornerRadius = _activeBar.frame.size.height/2;
//    _activeBar.contentMode = UIViewContentModeRedraw;
    [_barBackground addSubview:_activeBar];

}

-(void)setTintColor:(UIColor *)tintColor {
    _barBackground.backgroundColor = _backgroundColor;
    _activeBar.backgroundColor = tintColor;
}

-(void)setProgress:(float)progress{
    if (progress < 0) {
        progress = 0;
    }
    if (progress > 1) {
        progress = 1;
    }
    _progress = progress;
    if (_progress<= 0.1f) {
        [_activeBar setBackgroundColor:[UIColor colorWithHexString:@"FF4949"]];
    }else{
        if (_progress>0.1f && _progress<=0.3f) {
            [_activeBar setBackgroundColor:[UIColor colorWithHexString:@"F18F19"]];
        }
    }
    NSLog(@"progress : %f",progress);
    float fullWidth = self.bounds.size.width -2; //min size of active bar
    [_activeBar setFrame:CGRectMake(1, 1,  (fullWidth * _progress), self.activeBar.bounds.size.height)];
}

@end
