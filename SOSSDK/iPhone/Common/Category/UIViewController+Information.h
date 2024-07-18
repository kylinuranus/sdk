//
//  UIViewController+Information.h
//  Onstar
//
//  Created by Apple on 16/8/16.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSWebViewController.h"

@interface UIViewController (Information)

@property (nonatomic, copy) NSString *backRecordFunctionID;
@property (nonatomic, copy) NSString *backDaapFunctionID;

@property (nonatomic, retain) UIButton *navigationBackButton;

@property (copy,nonatomic) completedBlock backClickBlock;

/// 在自身 Navigation 的 viewControllers 中 获取 特定类型的 VC
- (UIViewController *)findVCInSelfNavWithClassName:(NSString *)className;

/// 清除自身 Navigation 的 viewControllers 中 特定类型的 VC
- (void)clearNavVCWithClassNameArray:(NSArray <NSString *>*)classNameArray;

- (void)setRightBarButtonItemWithTitle:(NSString *)title AndActionBlock:(void (^)(id item))block;

- (void)setLeftBackBtnCallBack:(dispatch_block_t)callBack;

/** 添加导航栏右上角图片 */
- (void)setRightBarButtonItemWithImageName:(NSString *)imageName callBack:(dispatch_block_t)callBack;
- (UIButton *)addRightButtonTitle:(NSString *)title callBack:(dispatch_block_t)callBack;

- (void)setLeftBarButtonItemWithTitle:(NSString *)title AndActionBlock:(void (^)(id item))block;

- (UIBarButtonItem *)getBarButtonItemImage:(UIImage *)image callBack:(dispatch_block_t)callBack;

@end
