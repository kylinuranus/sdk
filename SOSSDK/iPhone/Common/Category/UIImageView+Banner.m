//
//  UIImageView+Banner.m
//  Onstar
//
//  Created by lizhipan on 16/8/23.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "UIImageView+Banner.h"
char* const ASSOCIATION_BANNER_INFO = "ASSOCIATION_BANNER_INFO";
char* const ASSOCIATION_BANNER_GES = "ASSOCIATION_BANNER_GES";

@implementation UIImageView (Banner)
@dynamic bannerInfo;
- (void)setBannerInfo:(NNBanner *)bannerInfo
{
    objc_setAssociatedObject(self,ASSOCIATION_BANNER_INFO,bannerInfo,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NNBanner *)bannerInfo
{
    return objc_getAssociatedObject(self,ASSOCIATION_BANNER_INFO);
}

- (void)setSingleTapBlock:(SingleTapBlock)stp_{
    
    objc_setAssociatedObject(self,ASSOCIATION_BANNER_GES,stp_,OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addGesture];
}
- (SingleTapBlock)singleTapBlock {
    
    SingleTapBlock stb =objc_getAssociatedObject(self,ASSOCIATION_BANNER_GES);
    return stb;
    
}
- (void)addGesture
{
    UIGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerTaped)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:gestureRecognizer];
}
- (void)bannerTaped
{
    [self singleTapBlock](self.bannerInfo);
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    UIImageView * copyImage = [[[self class] allocWithZone:zone] init];
    [copyImage setImage:self.image];
    [copyImage setFrame:self.frame];
    [copyImage setUserInteractionEnabled:self.userInteractionEnabled];
    [copyImage setSingleTapBlock:[self singleTapBlock]];
    [copyImage setBannerInfo:[self bannerInfo].copy];
    return copyImage;
}
- (void)dealloc
{
    objc_removeAssociatedObjects(self);
}
@end
