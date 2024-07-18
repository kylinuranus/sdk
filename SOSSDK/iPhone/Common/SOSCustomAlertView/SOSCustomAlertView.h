//
//  SOSCustomAlertView.h
//  SOSCustomAlertView
//
//  Created by Genie Sun on 2017/7/13.
//  Copyright © 2017年 Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSAlertViewConst.h"
#import "SOSAlertViewDelegate.h"
#import "Util.h"

@interface SOSCustomAlertView : UIView

/**
 title
 */
@property(nonatomic, strong) NSString *title;

@property(nonatomic, copy ) NSString *iconImageName;

/**
 detail
 */
@property(nonatomic, strong) NSString *detailText;
/**
 拨打电话alert subtitle修改
 */
@property(nonatomic, strong) NSString *phoneCallDetailText;
@property(nonatomic, copy) NSString   *phoneFunctionID;
/**
 拨打电话alert subtitle修改
 */
@property(nonatomic, strong) NSString *notificationDetailText;

/**
 cancel btn
 */
@property (nonatomic, strong) NSString  *cancelButtonTitle;

/**
 custom background view
 */
@property(nonatomic, strong) UIView *customView;

/**
 view radius
 */
@property(nonatomic, assign) CGFloat radius;


/**
 page style
 */
@property(nonatomic, assign) AlertPageMode pageModel;

/**
 select btn hor or ver
 */
@property(nonatomic, assign) AlertButtonMode buttonMode;

/**
 backgroundview streak or white
 */
@property(nonatomic, assign) AlertViewBackGroundMode backgroundModel;

@property (nonatomic,copy) void (^completeHandle)(NSString *inputPwd,BOOL flashSelected,BOOL hornSelected);
@property (nonatomic,copy) void (^buttonClickHandle)(NSInteger clickIndex);
@property (nonatomic,copy) void (^tapGesDismissHandle)(void);
///用于点击背景隐藏时候回调

/**
 other button array , set to nil if have not other buttons
 */
@property(nonatomic, strong) NSArray *otherButtonTitles;

- (instancetype)initWithTitle:(NSString *)title
                   detailText:(NSString *)detailtext
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSArray *)otherButtonsTitles;

///原来的代码里,可以点击背景消失,在设置里会有问题,现在加一个初始化方法,可以设置是否支持点击背景消失,上面的方法canTapBackgroundHide默认传Yes,功能不变
- (instancetype)initWithTitle:(NSString *)title
                   detailText:(NSString *)detailtext
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSArray *)otherButtonsTitles
         canTapBackgroundHide:(BOOL)canTapBackgroundHide;

@property (nonatomic, weak)  id<SOSAlertViewDelegate> delegate;

/**
 show the alert
 */
- (void)show;

/**
 dismiss the alert
 */
- (void)hide;

@end
