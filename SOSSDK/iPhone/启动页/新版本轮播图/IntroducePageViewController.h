//
//  IntroducePageViewController.h
//  Onstar
//
//  Created by Apple on 16/7/4.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroducePageViewController : UIViewController

@property (nonatomic, copy) void(^preOver)(void);

@property (nonatomic, assign) BOOL isPageGuideMode;

/**
 目前内部默认隐藏 8.0
 */
@property (nonatomic, assign) BOOL showDot;

@end
