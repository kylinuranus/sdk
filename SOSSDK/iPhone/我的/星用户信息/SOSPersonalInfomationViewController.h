//
//  SOSPersonalInfomationViewController.h
//  Onstar
//
//  Created by lizhipan on 2017/8/3.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+JWT.h"
#import "SOSPersonInfoItem.h"
#import "SOSRegisterInformation.h"
#import "SOSPersonalInformationTableViewCell.h"

//extern NSString * const SOSPersonalInfomationViewControllerDealloc;

typedef NS_ENUM(NSInteger ,CurrentUserRoleType) {
    RoleTypeOwner,    //车主
    RoleTypeVisitor,   //访客
    RoleTypeDriverOrProxy,   //
};

typedef NS_ENUM(NSInteger ,SubmitPersonalInfoType)  {
    SubmitPersonalInfoRegister,  //注册界面
    SubmitPersonalInfoBBWC       //完善bbwc界面
};

typedef void(^BackToMainBlock)(void);

//星用户信息
@interface SOSPersonalInfomationViewController : UIViewController
@property(nonatomic,copy)NSString *verifyTip;

@property(nonatomic,assign)BOOL isInvokeFromLogin; //是否是登录后弹出的BBWC界面(业务是说登录后弹出的，教育页面返回至主界面，用户信息界面返回用户信息界面)
@property(nonatomic,assign)SubmitPersonalInfoType submitType;
@property(nonatomic,copy)BackToMainBlock backToMain; 

#pragma mark - 检查pin码
- (void)checkPINWithCompleteBlock:(void (^)(void))pinComplete;

@end
