//
//  UIButton+FillColor.m
//  Onstar
//
//  Created by Vicky on 16/2/17.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "UIButton+FillColor.h"

@implementation UIButton (FillColor)


- (void)setCommonStyle{
    [self setBackgroundColor:[UIColor colorWithHexString:@"6896ED"] forState:UIControlStateNormal];
    [self setBackgroundColor:[UIColor colorWithHexString:@"1870c3"] forState:UIControlStateSelected];
    [self setBackgroundColor:[UIColor colorWithHexString:@"cfd2d5"] forState:UIControlStateDisabled];
    
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    [self setBackgroundImage:[UIButton imageWithColor:backgroundColor] forState:state];
}


- (void)setTitleForAllState:(NSString *)title    {
    self.titleLabel.text = title;
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateHighlighted];
    [self setTitle:title forState:UIControlStateSelected];
    [self setTitle:title forState:UIControlStateDisabled];
}

- (void)setTitleForNormalState:(NSString *)title    {
    [self setTitle:title forState:UIControlStateNormal];
}

- (void)setTitleForHiglightedState:(NSString *)title    {
    [self setTitle:title forState:UIControlStateHighlighted];
}

- (void)setTitleForSelectedState:(NSString *)title  {
    [self setTitle:title forState:UIControlStateSelected];
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)resetTarget:(nullable id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [self removeTarget:nil action:nil forControlEvents:controlEvents];
    [self addTarget:target action:action forControlEvents:controlEvents];
}

- (void)setRegisterStyle {
    [self setBackgroundColor:[SOSUtil onstarButtonDisableColor] forState:UIControlStateDisabled];
    [self setBackgroundColor:[SOSUtil onstarButtonEnableColor] forState:UIControlStateNormal];

    self.layer.cornerRadius = 3;
    self.layer.masksToBounds = YES;
}
- (void)setNSButtonStyle {
    [self setBackgroundColor: [UIColor colorWithHexString:@"C3CEEC"] forState:UIControlStateDisabled];
    [self setBackgroundColor:[UIColor colorWithHexString:@"6896ED"] forState:UIControlStateNormal];

    self.layer.cornerRadius = 3;
    self.layer.masksToBounds = YES;
}


- (void)addUnderlineTitle	{
    UIFont *font = [self.titleLabel.font copy];
    UIColor *color = [self.titleLabel.textColor copy];
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:self.currentTitle];
    NSRange titleRange = {0, [title length]};
    [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:titleRange];
    
    [self setAttributedTitle:title forState:UIControlStateNormal];
    [self setTitleColor:color forState:UIControlStateNormal];
    [self.titleLabel setFont:font];
    
}

@end
