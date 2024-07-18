//
//  UITextField+SOSCustomTF.h
//  Onstar
//
//  Created by Genie Sun on 2017/7/20.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (SOSCustomTF)
/**
 placeholder 颜色
 */
@property (strong, nonatomic) IBInspectable UIColor *placeholderColor;
/**
 UITextField 的边框左侧和文字左侧的距离
 */
@property (assign, nonatomic) IBInspectable CGFloat leadingSpacing;
/**
 UITextField 的边框右侧和文字右侧的距离
 */
@property (assign, nonatomic) IBInspectable CGFloat taillingSpacing;

/**
 UITextField 左侧的icon
 */
@property(nonatomic, strong) IBInspectable UIImage *leftImage;

/**
 <#Description#>
 */
//@property(nonatomic, assign) IBInspectable CGFloat leftviewWidth;
//
///**
// <#Description#>
// */
//@property(nonatomic, assign) IBInspectable CGFloat leftviewHeight;

/**
 <#Description#>
 */
@property(nonatomic, strong) IBInspectable UIImage *rightImage;

/**
 <#Description#>
 */
//@property(nonatomic, assign) IBInspectable CGFloat rightviewWidth;
//
///**
// <#Description#>
// */
//@property(nonatomic, assign) IBInspectable CGFloat rightviewHeight;

@end
