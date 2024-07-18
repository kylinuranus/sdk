//
//  SOSUrlRequestStatusView.h
//  Onstar
//
//  Created by lizhipan on 17/1/5.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface SOSUrlRequestStatusView : UIView
@property(nonatomic,strong)UIActivityIndicatorView * activity;
@property(nonatomic,strong)UIButton * retryButton;
@property(nonatomic,strong)UIButton * clearTextButton;
@property(nonatomic,weak)UITextField * clearField;
@property(nonatomic,assign)BOOL clearButtonVisiable;
@property(nonatomic,copy)void(^redoBlock)(void);
- (id)initWithFrame:(CGRect)frame;
//进度
- (void)startAnimation;
- (void)stopAnimation;
//删除按钮
- (void)hideClearButton;
- (void)showClearButton;
//进度和重试按钮hidden
- (void)resetRequestStatus;
@end
