//
//  UITextField+Keyboard.h
//  Onstar
//
//  Created by Joshua on 5/29/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (Keyboard)

- (void)setSuppressibleKeyboard;

/// 设置电话号码过滤
- (void)setPhoneNumberFilter;

/// 设置汉字数字字母过滤
- (void)setChineseAndCharactorFilter;

/// 设置数字字母过滤;
- (void)setCharactorAndNumberFilter;

/// 最大输入字节长度,(汉字 * 2, 数字/字母 * 1), 若输入超出,恢复超出前的String
@property (nonatomic, assign) int maxInputCStringLength;

/// 最大输入长度,(汉字 * 1, 数字/字母 * 1), 若输入超出,截取到最大输入长度
@property (nonatomic, assign) int maxInputLength;

@end
