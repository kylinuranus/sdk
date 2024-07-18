//
//  RegisterMAViewController.h
//  Onstar
//
//  Created by lizhipan on 2017/8/16.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSRegisterTextField.h"
//车辆已经enroll注册MA(Mobile App)界面
@interface RegisterMAViewController : SOSBaseViewController
@property (weak, nonatomic) IBOutlet UIView *fieldBaseView;
@property (weak, nonatomic) IBOutlet UIButton *nextStepButton;
@property (assign, nonatomic)  BOOL isInfo3User; //是否info3需要补充姓名用户
@property (weak, nonatomic) IBOutlet UIView *info3NameBaseView;
@property (weak, nonatomic) IBOutlet SOSRegisterTextField *info3FirstName;
@property (weak, nonatomic) IBOutlet SOSRegisterTextField *info3LastName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *registerButtonTopConstraint;
@end
