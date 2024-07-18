//
//  UIView+iOS11.h
//  Onstar
//
//  Created by TaoLiang on 2017/11/6.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (iOS11)
//用于Frame编写的时候
@property (readonly, assign, nonatomic) UIEdgeInsets sos_safeAreaInsets;

//用于Masonry编写UI的时候
@property (nonatomic, strong, readonly) MASViewAttribute *sos_safeAreaLayoutGuide API_AVAILABLE(ios(11.0),tvos(11.0));
//@property (nonatomic, strong, readonly) MASViewAttribute *sos_edge;
@property (nonatomic, strong, readonly) MASViewAttribute *sos_left;
@property (nonatomic, strong, readonly) MASViewAttribute *sos_top;
@property (nonatomic, strong, readonly) MASViewAttribute *sos_right;
@property (nonatomic, strong, readonly) MASViewAttribute *sos_bottom;
@end
