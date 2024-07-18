//
//  UIImageView+Banner.h
//  Onstar
//
//  Created by lizhipan on 16/8/23.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^SingleTapBlock)(NNBanner* selectedBanner);

@interface UIImageView (Banner)<NSCopying>
@property(nonatomic,strong)NNBanner * bannerInfo;
- (void)setSingleTapBlock:(SingleTapBlock)stp_;
- (SingleTapBlock)singleTapBlock ;
@end
