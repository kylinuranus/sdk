//
//  SOSCarAssessmentView.h
//  Onstar
//
//  Created by Genie Sun on 2016/11/10.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    GOInCarReport = 0,
    ShareCarReport,
} CARREPORT;

@interface SOSCarAssessmentView : UIView

@property(nonatomic, strong) UIButton *titleBtn;
@property(nonatomic, strong) UIImageView *bgImageView;
@property(nonatomic, strong) UIView *maskView;
@property(nonatomic, strong) UILabel *tipLabel;
@property(nonatomic, strong) UIButton *selBtn;
@property(nonatomic, strong) UIButton *agreeBtnLb;
@property(nonatomic, assign) BOOL Flag;
@property (copy, nonatomic) void (^agreeGoInAction)(BOOL flag); //回调 Block
@property (copy, nonatomic) void (^agreementUrl)(void);

@property(nonatomic, assign) CARREPORT carEnum;


@property(nonatomic, strong) UIImageView *tipImage;
@property(nonatomic, strong) UILabel *tipLb;
@property(nonatomic, strong) UIButton *selectButton;
@property(nonatomic, strong) UIButton *agreementBtn;
@property(nonatomic, strong) UIButton *shareBtn;

- (void)initView ;
- (void)showShareReportView;
- (void)dismissShareReportView;

@end
