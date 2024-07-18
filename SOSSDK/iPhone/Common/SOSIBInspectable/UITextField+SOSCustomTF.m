//
//  UITextField+SOSCustomTF.m
//  Onstar
//
//  Created by Genie Sun on 2017/7/20.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "UITextField+SOSCustomTF.h"

@implementation UITextField (SOSCustomTF)

- (UIColor *)placeholderColor
{
    return [self valueForKeyPath:@"_placeholderLabel.textColor"];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    [self setValue:placeholderColor forKeyPath:@"_placeholderLabel.textColor"];
}

- (CGFloat)leadingSpacing
{
    return CGRectGetWidth(self.leftView.bounds);
}

- (void)setLeadingSpacing:(CGFloat)leadingSpacing
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, leadingSpacing, self.bounds.size.height)];
    self.leftView = view;
    self.leftViewMode = UITextFieldViewModeAlways;
}

- (CGFloat)taillingSpacing
{
    return CGRectGetWidth(self.rightView.bounds);
}

- (void)setTaillingSpacing:(CGFloat)taillingSpacing
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, taillingSpacing, self.bounds.size.height)];
    self.rightView = view;
    self.rightViewMode = UITextFieldViewModeAlways;
}

- (UIImage *)leftImage
{
    return self.leftImage;
}

- (void)setLeftImage:(UIImage *)leftImage
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:leftImage];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.clipsToBounds = YES;
    imageView.frame = CGRectMake(0, 0, leftImage.size.width + 10, leftImage.size.height);
    self.leftViewMode = UITextFieldViewModeAlways;
    self.leftView = imageView;
}

//- (CGFloat)leftviewWidth
//{
//    return self.leftviewWidth;
//}
//
//- (void)setLeftviewWidth:(CGFloat)leftviewWidth
//{
//    self.leftView.frame = CGRectMake(0, 0, 0, self.leftviewHeight);
//}

//- (CGFloat)leftviewHeight
//{
//    return self.leftviewHeight;
//}
//
//- (void)setLeftviewHeight:(CGFloat)leftviewHeight
//{
//    self.leftView.frame = CGRectMake(0, 0, self.leftviewWidth, 0);
//}

- (UIImage *)rightImage
{
    return self.rightImage;
}

- (void)setRightImage:(UIImage *)rightImage
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:rightImage];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.clipsToBounds = YES;
    self.rightViewMode = UITextFieldViewModeAlways;
    imageView.frame = CGRectMake(0, 0, rightImage.size.width + 10, rightImage.size.height);
    self.rightView = imageView;
}


//- (CGFloat)rightviewWidth
//{
//    return self.rightviewWidth;
//}
//
//- (void)setRightviewWidth:(CGFloat)rightviewWidth
//{
//    self.rightView.frame = CGRectMake(0, 0, rightviewWidth, self.rightviewHeight);
//}
//
//- (CGFloat)rightviewHeight
//{
//    return self.rightviewHeight;
//}
//
//- (void)setRightviewHeight:(CGFloat)rightviewHeight
//{
//    self.rightView.frame = CGRectMake(0, 0, self.rightviewWidth, rightviewHeight);
//}


@end
