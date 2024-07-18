//
//  SOSStatusLoadingView.h
//  Onstar
//
//  Created by Genie Sun on 2017/7/27.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger ,SOSRemoteControlStatus){
    DATA_REFRESH, //刷新数据
    DATA_REFRESH_END, //刷新数据结束
    USER_UPDATE_FAIL, //刷新数据失败
    VEHICLE_UNAUTHORIZED,//车分享未授权
    SOSLOGIN_NEED_REFRESH //登录主数据未加载完全,需重新加载
};

@interface SOSStatusLoadingView : UIView
@property (nonatomic,assign)BOOL autoHide;//自动hide
@property (nonatomic,assign)BOOL removeFromSuperWhenHide;
@property (nonatomic,weak) IBOutlet UIImageView *icon;
@property (nonatomic,weak) IBOutlet UILabel *infoLB;
@property(nonatomic, assign) SOSRemoteControlStatus statusLoading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailLabelTrailingConstrain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailLabelLeadingTrailingConstrain;


@property (weak, nonatomic) IBOutlet UILabel *detailIconLB;

- (void)showStatusLoadingViewWithStatus:(SOSRemoteControlStatus)status message:(NSString *)mes;
- (void)hide;

@end
@interface SOSConvenientStatusLoadingView : NSObject

+(void)showStatusLoadingViewInController:(UIView *)view;
+(void)showStatusLoadingViewInController:(UIView *)view status:(SOSRemoteControlStatus)status message:(NSString *)msg;


/**
 显示 delay秒后消失
 */
+(void)showStatusLoadingViewInController:(UIView *)view
                                  status:(SOSRemoteControlStatus)status
                                 message:(NSString *)msg
                       dismissAfterDelay:(NSTimeInterval)delay;

+(void)hideStatusLoadingViewInController:(UIView *)view ;
@end
