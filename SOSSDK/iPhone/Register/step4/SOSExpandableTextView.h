//
//  SOSExpandableTextView.h
//  SelwynFormDemo
//
//  Created by BSW on 2017/6/24.
//  Copyright © 2017年 selwyn. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 SOSExpandableTextView 可高度自适应的UITextView
 */
@interface SOSExpandableTextView : UITextView<UITextViewDelegate>

@property (copy, nonatomic) IBInspectable NSString *placeholder;
@property (copy, nonatomic) NSAttributedString *attributedPlaceholder;

@property (nonatomic) IBInspectable double fadeTime;
@property (retain, nonatomic) UIColor *placeholderTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) int maxInputLength;
@property(nonatomic,copy)NSString * realText;//***代表的实际内容
//输入过滤特殊表情字符
- (void)addAddressTextInputPredicate ;

@end
