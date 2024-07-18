//
//  UIImage+Screenshot.h
//  Onstar
//
//  Created by TaoLiang on 2019/3/8.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Screenshot)
+ (UIImage *)screenshot;
- (UIImage *)bluredImage;
- (UIImage *)blurImage:(CGFloat)blurLevel;

@end

NS_ASSUME_NONNULL_END
