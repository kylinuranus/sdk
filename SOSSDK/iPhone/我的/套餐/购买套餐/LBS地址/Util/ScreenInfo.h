//
//  ScreenInfo.h
//  UINavigationControllerTest
//
//  Created by admin on 2018/6/1.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SingleHeader.h"

@interface ScreenInfo : NSObject

interfaceSingleton()

- (CGRect)frame;
- (CGRect)currentViewFrame;
- (CGFloat)kSafeAreaScreenHeight;
- (CGFloat)kStatusBarHeight;
- (CGFloat)kTabBarBottomHeight;
- (CGFloat)kTabbar_Height;
- (CGFloat)navigationBarHeight;
- (CGFloat)kNavi_Height;
- (CGFloat)scale;
- (CGFloat)getBorderWidth:(CGFloat)width;
- (BOOL)widthUnder375;
- (BOOL)compareSystemVersion:(CGFloat)version;
- (CGFloat)lineViewHeight;

@end
