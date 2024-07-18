//
//  UILabel+DetectLink.m
//  Onstar
//
//  Created by TaoLiang on 02/05/2018.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "UILabel+DetectLink.h"

@implementation UILabel (DetectLink)

- (void)detectRanges:(NSArray<NSValue *> *)ranges tapped:(void (^)(NSInteger))tapped {
    self.userInteractionEnabled = YES;
    //    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedLabel:)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(UITapGestureRecognizer *tap) {
        UILabel *label = (UILabel*)tap.view;
        
        if (!label.attributedText) {
            return;
        }
        
        NSTextStorage *storage = [[NSTextStorage alloc] initWithAttributedString:label.attributedText];
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:label.bounds.size];
        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
        [layoutManager addTextContainer:textContainer];
        [storage addLayoutManager:layoutManager];
        
        textContainer.lineFragmentPadding = 0.0;
        textContainer.lineBreakMode = label.lineBreakMode;
        textContainer.maximumNumberOfLines = 0;
        
        CGPoint location = [tap locationInView:label];
        NSUInteger characterIndex = [layoutManager characterIndexForPoint:location inTextContainer:textContainer fractionOfDistanceBetweenInsertionPoints:NULL];
        
        if (characterIndex < storage.length)
        {
            NSLog(@"Character Index: %i", (int)characterIndex);
            
            NSRange range = NSMakeRange(characterIndex, 1);
            NSString *substring = [label.attributedText.string substringWithRange:range];
            NSLog(@"Character at Index: %@", substring);
            
            [ranges enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (NSIntersectionRange(obj.rangeValue, range).length > 0) {
                    if (tapped) {
                        tapped(idx);
                    }
                    *stop = YES;
                    return;
                }
                
            }];
        }
    }];
    [self addGestureRecognizer:tap];
}

@end
