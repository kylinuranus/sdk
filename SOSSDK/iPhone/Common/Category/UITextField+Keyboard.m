//
//  UITextField+Keyboard.m
//  Onstar
//
//  Created by Joshua on 5/29/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import "UITextField+Keyboard.h"
#import "Util.h"

static const void *KTextFieldOriginText = "KTextFieldOriginText";

@implementation UITextField (Keyboard)
//@dynamic KTextFieldOriginText;

- (void)setSuppressibleKeyboard     {
    // 自定义的view
    UIView *inputAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    inputAccessoryView.backgroundColor = [UIColor clearColor];
    
    UIButton *hiddenBtn = [[UIButton alloc] initWithFrame:CGRectMake(inputAccessoryView.frame.size.width-35, 0, 35, 30)];
    [hiddenBtn setImage:[UIImage imageNamed:@"down_normal.png"] forState:UIControlStateNormal];
    [hiddenBtn setImage:[UIImage imageNamed:@"down_highlight.png"] forState:UIControlStateHighlighted];
    [hiddenBtn setImage:[UIImage imageNamed:@"down_highlight.png"] forState:UIControlStateSelected];
    [hiddenBtn addTarget:self action:@selector(hiddenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [inputAccessoryView addSubview:hiddenBtn];
    
    self.inputAccessoryView = inputAccessoryView;
}

- (void)hiddenButtonClicked:(id)sender     {
    [self endEditing:YES];
}

- (void)setChineseAndCharactorFilter	{
    [self.rac_textSignal subscribeNext:^(NSString *x) {
        UITextRange *selectedRange = self.markedTextRange;
        UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            // 没有高亮选择的字
            // 1. 过滤非汉字、字母、数字字符
            self.text = [self filterCharactor:self.text withRegex:@"[^a-zA-Z0-9\u4e00-\u9fa5]"];
        } else {
            // 有高亮选择的字 不做任何操作
        }
    }];
}

/// 设置电话号码过滤
- (void)setPhoneNumberFilter        {
    [self.rac_textSignal subscribeNext:^(NSString *x) {
        UITextRange *selectedRange = self.markedTextRange;
        UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            // 过滤数字字符
            self.text = [self filterCharactor:self.text withRegex:@"[^0-9]"];
        } else {
            // 有高亮选择的字 不做任何操作
        }
        
        if (x.length > 11) {
            self.text = [x substringToIndex:11];
        }
    }];
}


- (void)setCharactorAndNumberFilter		{
    [self.rac_textSignal subscribeNext:^(NSString *x) {
        UITextRange *selectedRange = self.markedTextRange;
        UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            // 没有高亮选择的字
            // 1. 过滤非汉字、字母、数字字符
            self.text = [self filterCharactor:self.text withRegex:@"[^a-zA-Z0-9]"];
        } else {
            // 有高亮选择的字 不做任何操作
        }
    }];
}


// 过滤字符串中的非汉字、字母、数字
- (NSString *)filterCharactor:(NSString *)string withRegex:(NSString *)regexStr{
    NSString *filterText = string;
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *result = [regex stringByReplacingMatchesInString:filterText options:NSMatchingReportCompletion range:NSMakeRange(0, filterText.length) withTemplate:@""];
    return result;
}

/// 最大输入字节长度,(汉字 * 2, 数字/字母 * 1), 若输入超出,恢复超出前的String
- (void)setMaxInputCStringLength:(int)maxInputCStringLength		{
    objc_setAssociatedObject(self, @selector(maxInputCStringLength), @(maxInputCStringLength), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.rac_textSignal subscribeNext:^(NSString *x) {
        NSUInteger cStringLength = self.text.cStringLength;
        if (maxInputCStringLength > 0 && cStringLength > maxInputCStringLength) {
            NSString *originText = objc_getAssociatedObject(self, KTextFieldOriginText);
            self.text = originText;
        }    else    {
            objc_setAssociatedObject(self, KTextFieldOriginText, self.text, OBJC_ASSOCIATION_COPY_NONATOMIC);
        }
    }];
}

- (int)maxInputCStringLength	{
    NSNumber *maxCLength = objc_getAssociatedObject(self, @selector(maxInputCStringLength));
    return maxCLength ? maxCLength.intValue : 0;
}

/// 最大输入长度,(汉字 * 1, 数字/字母 * 1), 若输入超出,截取到最大输入长度
- (void)setMaxInputLength:(int)maxInputLength   {
    objc_setAssociatedObject(self, @selector(maxInputLength), @(maxInputLength), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.rac_textSignal subscribeNext:^(NSString *x) {
        if (x.length > maxInputLength && maxInputLength > 0) {
            self.text = [x substringToIndex:maxInputLength];
        }
    }];
}

- (int)maxInputLength   {
    NSNumber *maxLength = objc_getAssociatedObject(self, @selector(maxInputLength));
    return maxLength ? maxLength.intValue : 0;
}

@end
