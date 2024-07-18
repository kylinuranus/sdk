//
//  SOSCarSecretaryPoint.m
//  Onstar
//
//  Created by TaoLiang on 2018/1/29.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSCarSecretaryPoint.h"

@interface SOSCarSecretaryPoint ()
@property (weak, nonatomic) UIView *point;

@end

@implementation SOSCarSecretaryPoint

+ (instancetype)point {
    return [SOSCarSecretaryPoint pointWithRadius:CGFLOAT_MAX color:nil];
}

+ (instancetype)pointWithRadius:(CGFloat)radius {
    return [SOSCarSecretaryPoint pointWithRadius:radius color:nil];
}

+ (instancetype)pointWithRadius:(CGFloat)radius color:(UIColor *)color {
    SOSCarSecretaryPoint *view = [[SOSCarSecretaryPoint alloc] initWithRadius:radius == CGFLOAT_MAX ? 3 : radius color:color ? : [UIColor colorWithRed:28/255.f green:128/255.f blue:220/255.f alpha:1]];
    return view;
}

- (instancetype)initWithRadius:(CGFloat)radius color:(UIColor *)color {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIView *point = [UIView new];
        point.layer.masksToBounds = YES;
        point.layer.cornerRadius = radius;
        point.layer.backgroundColor = color.CGColor;
        [self addSubview:point];
        [point mas_makeConstraints:^(MASConstraintMaker *make){
            make.center.equalTo(self);
            make.height.width.mas_equalTo(radius * 2);
        }];
    }
    return self;
}

@end
