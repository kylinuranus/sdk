//
//  UIView+iOS11.m
//  Onstar
//
//  Created by TaoLiang on 2017/11/6.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "UIView+iOS11.h"

@implementation UIView (iOS11)


- (UIEdgeInsets)sos_safeAreaInsets{
    if (@available(iOS 11.0, *)) {
        return self.safeAreaInsets;
    }else {
        return UIEdgeInsetsZero;
    }
}

#pragma mark - NSLayoutAttribute properties

- (MASViewAttribute *)sos_safeAreaLayoutGuide {
    return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeNotAnAttribute];
}

//- (MASViewAttribute *)sos_edge {
//    if (@available(iOS 11.0, *)) {
//        return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeNotAnAttribute];
//    }else {
//        return self;
//    }
//}

- (MASViewAttribute *)sos_left {
    if (@available(iOS 11.0, *)) {
        return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeLeft];
    }else {
        return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeft];
    }
}

- (MASViewAttribute *)sos_top {
    if (@available(iOS 11.0, *)) {
        return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeTop];
    }else {
        return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTop];
    }
    
}

- (MASViewAttribute *)sos_right {
    if (@available(iOS 11.0, *)) {
        return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeRight];
    }else {
        return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRight];
    }
    
}

- (MASViewAttribute *)sos_bottom {
    if (@available(iOS 11.0, *)) {
        return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
    }else {
        return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottom];
    }
    
}


@end
