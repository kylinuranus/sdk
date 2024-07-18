//
//  SOSSegmentView.h
//  Onstar
//
//  Created by lizhipan on 2017/7/18.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
//segment形式选择bar
@interface SOSSegmentView : UIView
//传入title数组
@property (nonatomic,strong) NSArray *title;
@property (nonatomic,strong) NSArray *childrensVC;
@property (nonatomic,strong) UIViewController *fatherVC;
@property (nonatomic,strong) UIViewController *selectVC;

- (void)setupViewControllerWithFatherVC:(UIViewController *)fatherVC childVC:(NSArray<UIViewController *>*)childVC;
@end
