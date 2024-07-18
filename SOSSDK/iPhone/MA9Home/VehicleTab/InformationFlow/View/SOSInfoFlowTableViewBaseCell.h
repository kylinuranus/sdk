//
//  SOSInfoFlowTableViewBaseCell.h
//  Onstar
//
//  Created by TaoLiang on 2018/12/12.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSInfoFlowFuncButton.h"
#import "SOSInfoFlow.h"
#import "UILabel+HTML.h"

NS_ASSUME_NONNULL_BEGIN

//请勿直接使用SOSInfoFlowTableViewBaseCell，使用子类。
@interface SOSInfoFlowTableViewBaseCell : UITableViewCell
//暴露给子类调用
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIImageView *leftImageView;
@property (strong, nonatomic) UIView *rightPartView;
@property (strong, nonatomic) SOSInfoFlowFuncButton *funcBtn;
@property (strong, nonatomic) UILabel *hrefLabel;
@property (readonly, strong, nonatomic) NSIndexPath *indexPath;
@property (readonly, strong, nonatomic) SOSInfoFlow *infoFlow;
@property (weak, nonatomic) UILabel *label0;
@property (weak, nonatomic) UILabel *label1;
@property (nonatomic, strong, nullable) MASConstraint *label1RightConstraint;
@property (weak, nonatomic) UILabel *label2;
- (UILabel *)fetchLabel;

//填充数据
- (void)fillData:(SOSInfoFlow *)infoFlow atIndexPath:(NSIndexPath *)indexPath;

//用户交互行为
@property (copy, nonatomic) void (^funcBtnHandler)(NSIndexPath *indexPath);
@property (copy, nonatomic) void (^hrefHandler)(NSIndexPath *indexPath);


@end

NS_ASSUME_NONNULL_END
