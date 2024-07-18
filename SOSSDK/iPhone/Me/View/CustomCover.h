//
//  CustomCover.h
//  Onstar
//
//  Created by Apple on 16/7/26.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCover : UIView

@property (nonatomic, assign) CGFloat coverAlpha;
+ (instancetype)cover;
+ (instancetype)coverWithTarget:(id)target action:(SEL)action coverAlpha:(CGFloat)coverAlpha;

- (void)reset;

@end
