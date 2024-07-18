//
//  SOSCardBaseCell.h
//  Onstar
//
//  Created by lmd on 2017/9/21.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSCardContainerView.h"
#import "SOSCellStatusView.h"

@interface SOSCardBaseCell : UITableViewCell
@property (nonatomic, strong) SOSCardContainerView *containerView;

/**
 获取response后赋值
 */
@property (nonatomic, assign) RemoteControlStatus status;


@property (nonatomic, strong) SOSCellStatusView *statusView;

/**
 初始化添加view
 */
- (void)setUpView;

/**
 cell中调用
 */
- (void)refreshWithResp:(id)response;

- (void)showErrorStatusView;

//显示蓝色重试按钮
- (void)showErrorStatusView :(BOOL)blueButton;

- (void)showErrorStatusView :(BOOL)blueButton statusLabelColor:(UIColor *)color;

@property (nonatomic, copy) void(^retryClickBlock)(void);


@end
