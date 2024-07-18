//
//  SOSCarSecretaryPoint.h
//  Onstar
//
//  Created by TaoLiang on 2018/1/29.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSCarSecretaryPoint : UIView
@property (strong, nonatomic) UIColor *color;
@property (assign, nonatomic) CGFloat radius;

+ (instancetype)point;
+ (instancetype)pointWithRadius:(CGFloat)radius;
+ (instancetype)pointWithRadius:(CGFloat)radius color:(UIColor *)color;


@end
