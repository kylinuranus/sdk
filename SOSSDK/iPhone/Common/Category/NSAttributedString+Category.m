//
//  NSAttributedString+Category.m
//  LBSTest
//
//  Created by jieke on 2019/6/18.
//  Copyright © 2019 jieke. All rights reserved.
//

#import "NSAttributedString+Category.h"

@implementation NSAttributedString (Category)

#pragma mark - Private
+ (instancetype)setAttributedStringTitle:(NSString *)title placeholderColor:(UIColor *)placeholderColor {
    NSDictionary *dict = @{NSForegroundColorAttributeName:placeholderColor};
    NSAttributedString *attri = [[NSAttributedString alloc] initWithString:title attributes:dict];
    return attri;
}
+ (instancetype)setAttributedStringTitle:(NSString *)title placeholderColor:(UIColor *)placeholderColor textFieldFont:(UIFont *)textFieldFont {
    NSDictionary *dict = @{NSForegroundColorAttributeName:placeholderColor, NSFontAttributeName:textFieldFont};
    NSAttributedString *attri = [[NSAttributedString alloc] initWithString:title attributes:dict];
    return attri;
}
#pragma mark 删除线
+ (instancetype)setStrikethroughTitle:(NSString *)title {
    //中划线
    NSDictionary *attribtDic = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    NSAttributedString *attribtStr = [[NSAttributedString alloc] initWithString:title attributes:attribtDic];
    return attribtStr;
}
@end
