//
//  UnderLineLabel.h
//  CustomLabelWithUnderLine
//
//  Created by liuweizhen on 13-4-17.
//  Copyright (c) 2013年 WeiZhen_Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnderLineLabel : UILabel     {
    UIControl *_actionView;
    UIColor *_highlightedColor;
    BOOL _shouldUnderline;
}

@property (nonatomic, strong) UIColor *highlightedColor;
@property (nonatomic, assign) BOOL shouldUnderline;
@property (nonatomic, assign) CGFloat lineWidth;

- (void)setText:(NSString *)text andFrame:(CGRect)frame;

- (void)setText:(NSString *)text andCenter:(CGPoint)center;
- (void)addTarget:(id)target action:(SEL)action;
- (void)setText:(NSString *)text andCustomFrame:(CGRect)frame;
@end
 