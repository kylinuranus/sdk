//
//  UIView+Radius.h
//  LBSTest
//
//  Created by jieke on 2019/6/14.
//  Copyright © 2019 jieke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Radius)

/** 不需要圆角 */
+ (void)setupNoNeedRadius:(UIView *)view;
/** 设置圆角 */
+ (void)setupRadius:(UIView *)view corners:(UIRectCorner)corners;
+ (void)setupAllAroundRadius:(UIView *)view;
+ (void)setupAllAroundRadius:(UIView *)view size:(CGSize)size;
@end

