//
//  NSAttributedString+Category.h
//  LBSTest
//
//  Created by jieke on 2019/6/18.
//  Copyright © 2019 jieke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (Category)

+ (instancetype)setAttributedStringTitle:(NSString *)title placeholderColor:(UIColor *)placeholderColor;

+ (instancetype)setAttributedStringTitle:(NSString *)title placeholderColor:(UIColor *)placeholderColor textFieldFont:(UIFont *)textFieldFont;
/** 删除线 */
+ (instancetype)setStrikethroughTitle:(NSString *)title;

@end

