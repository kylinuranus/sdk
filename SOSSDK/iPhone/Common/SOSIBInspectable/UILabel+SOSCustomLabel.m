//
//  UILabel+SOSCustomLabel.m
//  Onstar
//
//  Created by Coir on 2018/4/25.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "UILabel+SOSCustomLabel.h"

//static const void *KTextFieldOriginText = "KTextFieldOriginText";

@implementation UILabel (SOSCustomLabel)

//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        Class class = [self class];
//
//        SEL originalSelector = @selector(setHighlighted:);
//        SEL swizzledSelector = @selector(sos_setHighlighted:);
//
//        SEL originalSelector1 = @selector(setText:);
//        SEL swizzledSelector1 = @selector(sos_setText:);
//
//        Method originalMethod = class_getInstanceMethod(class, originalSelector);
//        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
//        Method originalMethod1 = class_getInstanceMethod(class, originalSelector1);
//        Method swizzledMethod1 = class_getInstanceMethod(class, swizzledSelector1);
//
//        BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
//        if (didAddMethod) {
//            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
//        } else {
//            method_exchangeImplementations(originalMethod, swizzledMethod);
//        }
//        BOOL didAddMethod1 = class_addMethod(class, originalSelector1, method_getImplementation(swizzledMethod1), method_getTypeEncoding(swizzledMethod1));
//        if (didAddMethod1) {
//            class_replaceMethod(class, swizzledSelector1, method_getImplementation(originalMethod1), method_getTypeEncoding(originalMethod1));
//        } else {
//            method_exchangeImplementations(originalMethod1, swizzledMethod1);
//        }
//    });
//}
//
//
//
//- (NSString *)sos_highlightedText    {
//    NSString *text = objc_getAssociatedObject(self, @selector(sos_highlightedText));
//    return text.length ? text : @"";
//}
//
//- (void)setSos_highlightedText:(NSString *)sos_highlightedText        {
//    objc_setAssociatedObject(self, @selector(sos_highlightedText), sos_highlightedText, OBJC_ASSOCIATION_COPY_NONATOMIC);
//}
//
//- (void)sos_setHighlighted:(BOOL)highlighted    {
//    //实质上调用系统方法 setHighlighted:
//    [self sos_setHighlighted:highlighted];
//    //屏蔽未赋值 sos_highlightedText 的情况
//    if (self.sos_highlightedText.length == 0)    return;
//    if (highlighted == YES) {
//        //保存正常状态 Text
//        objc_setAssociatedObject(self, KTextFieldOriginText, self.text, OBJC_ASSOCIATION_COPY_NONATOMIC);
//        self.text = self.sos_highlightedText;
//    }    else    {
//        //恢复正常状态 Text
//        NSString *originText = objc_getAssociatedObject(self, KTextFieldOriginText);
//        self.text = originText;
//    }
//}
//
//- (void)sos_setText:(NSString *)text    {
//    //实质上调用系统方法 setText:
//    [self sos_setText:text];
//    //屏蔽未赋值 sos_highlightedText 的情况
//    if (self.sos_highlightedText.length == 0)    return;
//    if (self.highlighted) {
//        self.sos_highlightedText = text;
//    }    else    {
//        objc_setAssociatedObject(self, KTextFieldOriginText, text, OBJC_ASSOCIATION_COPY_NONATOMIC);
//    }
//}

@end
