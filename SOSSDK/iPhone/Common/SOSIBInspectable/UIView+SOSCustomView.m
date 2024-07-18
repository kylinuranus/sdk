//
//  UIView+SOSCustomView.m
//  Onstar
//
//  Created by Genie Sun on 2017/7/20.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "UIView+SOSCustomView.h"
#import "Util.h"

@implementation UIView (SOSCustomView)

- (BOOL)masksToBounds	{
    return self.layer.masksToBounds;
}

- (void)setMasksToBounds:(BOOL)masksToBounds	{
    self.layer.masksToBounds = masksToBounds;
}

- (void)setBorderWidth:(CGFloat)borderWidth    {
    [self.layer setBorderWidth:borderWidth];
}

- (CGFloat)borderWidth    {
    return  self.layer.borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor {
    [self.layer setBorderColor:borderColor.CGColor];
}

- (UIColor *)borderColor {
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (void)setBorderHexColor:(NSString *)borderHexColor {
    UIColor *color = [UIColor colorWithHexString:borderHexColor];
    [self.layer setBorderColor:[color CGColor]];
}

- (NSString *)borderHexColor {
    return @"FFFFFF";
}

- (void)setCornerRedius:(CGFloat)cornerRedius    {
    self.layer.masksToBounds = YES;
    [self.layer setCornerRadius:cornerRedius];
}

- (CGFloat)cornerRedius    {
    return [self.layer cornerRadius];
}

- (void)setHexBgColor:(NSString *)hexStr {
    UIColor *color = [UIColor colorWithHexString:hexStr];
    [self setBackgroundColor:color];
}

- (NSString *)hexBgColor {
    return @"FFFFFF";
}

- (UIColor *)shadowColor {
    return [UIColor colorWithCGColor:self.layer.shadowColor];
}

- (void)setShadowColor:(UIColor *)shadowColor {
    self.layer.shadowColor = shadowColor.CGColor;
}

- (CGFloat)shadowOpacity {
    return self.layer.shadowOpacity;
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity {
    self.layer.shadowOpacity = shadowOpacity;
}

- (CGSize)shadowOffset {
    return self.layer.shadowOffset;
}

- (void)setShadowOffset:(CGSize)shadowOffset {
    self.layer.shadowOffset = shadowOffset;
}

- (CGFloat)shadowRadius {
    return self.layer.shadowRadius;
}

- (void)setShadowRadius:(CGFloat)shadowRadius {
    self.layer.shadowRadius = shadowRadius;
}


@end


