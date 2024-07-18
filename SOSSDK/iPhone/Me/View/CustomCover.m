//
//  CustomCover.m
//  Onstar
//
//  Created by Apple on 16/7/26.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "CustomCover.h"

@interface CustomCover()
{
    CGFloat _coverAlpha;
}
@end

@implementation CustomCover

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 1.背景色
        self.backgroundColor = [UIColor blackColor];
        
        // 2.自动伸缩
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        // 3.透明度
        self.alpha = _coverAlpha;
    }
    return self;
}

- (void)reset
{
    self.alpha = _coverAlpha;
}


+ (instancetype)cover
{
    return [[self alloc] init];
}

+ (instancetype)coverWithTarget:(id)target action:(SEL)action coverAlpha:(CGFloat)coverAlpha
{
    CustomCover *cover = [self cover];
    cover.coverAlpha = coverAlpha;
    [cover addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:target action:action]];
    return cover;
}

@end

