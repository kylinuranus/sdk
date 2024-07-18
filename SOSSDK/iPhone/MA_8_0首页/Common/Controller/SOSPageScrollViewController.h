//
//  SOSPageScrollViewController.h
//  Onstar
//
//  Created by lizhipan on 2017/7/28.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSPageScrollMainView.h"
#import "SOSPageScrollParaCenter.h"
//多页面滑动跳页+顶部headerview基类
@interface SOSPageScrollViewController : UIViewController
@property(nonatomic,strong)SOSPageScrollMainView * mainView;
@property(nonatomic,strong)UIView * headerMainView;//header内容视图
@property(nonatomic,strong)UIImage * headerbg;     //header背景图
@property(nonatomic,strong)SOSPageScrollParaCenter * scrollPara;
@property(nonatomic,strong)NSArray * pageTitles;
@property(nonatomic,strong)NSArray * pageControllers;
//设置下部滑动与headerview交互
@property (copy ,nonatomic)SOSPageScrollBlock scrollBlock;

//设置header
- (void)configHeaderView:(UIView *)headerV headerBackground:(UIImage *)bgimage;
//设置controller和title
- (void)configScrollControllers:(NSArray *)pageControllers controllerTitles:(NSArray *)titles;
//设置悬浮参数
- (void)configHeaderScrollParameter:(SOSPageScrollParaCenter *)para;
@end
