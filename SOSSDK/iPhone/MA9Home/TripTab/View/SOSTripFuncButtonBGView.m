//
//  SOSTripFuncButtonBGView.m
//  Onstar
//
//  Created by Coir on 2019/1/18.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSTripFuncButtonBGView.h"
#import "SOSTripHomeVC.h"

@implementation SOSTripFuncButtonBGView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event    {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        CGPoint tempoint = [self convertPoint:point fromView:self];
        for (UIButton *button in self.funcCloseButtonArray) {
            CGRect rect = [button.superview convertRect:button.frame toView:self];
            if (button.superview.width != 34 && CGRectContainsPoint(rect, tempoint))        {
                view = button;
            }
        }
    }
    return view;
}

@end
