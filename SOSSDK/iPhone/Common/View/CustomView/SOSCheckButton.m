//
//  SOSCheckButton.m
//  Onstar
//
//  Created by TaoLiang on 02/05/2018.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSCheckButton.h"

@implementation SOSCheckButton

+ (instancetype)buttonWithImageNames:(NSArray<NSString *> *)imageNames {
    SOSCheckButton *button = [SOSCheckButton buttonWithType:UIButtonTypeCustom];
    NSAssert(imageNames.count != 1, @"图片数量不能为1，可以为0用默认图片或者大于2取前两个");

    if (imageNames.count <= 0) {
        imageNames = @[@"checkbox_unselect", @"checkbox_select"];
    }
    [button setImage:[UIImage imageNamed:imageNames.firstObject] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:imageNames[1]] forState:UIControlStateSelected];
    [button setAdjustsImageWhenHighlighted:NO];
    [button setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [button setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    return button;
}

@end
