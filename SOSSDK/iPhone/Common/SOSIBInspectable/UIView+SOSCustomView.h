//
//  UIView+SOSCustomView.h
//  Onstar
//
//  Created by Genie Sun on 2017/7/20.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

//IB_DESIGNABLE
@interface UIView (SOSCustomView)
/**
 设置超过子图层的部分裁减掉
 */
@property (assign, nonatomic) IBInspectable BOOL masksToBounds;

/**
 设置边框宽度
 */
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;

/**
 设置边框颜色
 */
@property (nonatomic, assign) IBInspectable UIColor *borderColor;

/**
 根据十六进制颜色值设置边框颜色
 */
@property (nonatomic, assign) IBInspectable NSString *borderHexColor;

/**
 设置圆角半径
 */
@property (nonatomic, assign) IBInspectable CGFloat cornerRedius;

/**
 设置背景色
 */
@property (nonatomic, assign) IBInspectable NSString *hexBgColor;

/**
 阴影颜色
 */
@property (strong, nonatomic) IBInspectable UIColor *shadowColor;
/**
 阴影透明度
 */
@property (assign, nonatomic) IBInspectable CGFloat shadowOpacity;
/**
 阴影偏移
 */
@property (assign, nonatomic) IBInspectable CGSize shadowOffset;
/**
 阴影圆角
 */
@property (assign, nonatomic) IBInspectable CGFloat shadowRadius;

@end


