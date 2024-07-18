//
//  OwnerViewController.h
//  Onstar
//
//  Created by Vicky on 13-12-5.
//  Copyright (c) 2013年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSRegisterTextField.h"
#import "SOSRegisterInformation.h"

/**
 界面用于场景：1、未登录进行注册
            2、visitor升级车主 - visitor账户存在gaa|visitor账户不存在gaa
            3、subscirber升级车主
 */
@interface OwnerViewController : SOSBaseViewController<UITextFieldDelegate>
{
    IBOutlet UIButton *buttonCamera;
    NSString *vinID;
    NSString *mobile;
    NSString *email;
    BOOL info3User;
}
@property (assign, nonatomic) SOSRegisterType  currentRegisterType;     //使用何种信息注册
@property (weak, nonatomic) IBOutlet UILabel *errorCaptchaLB;
@property (weak, nonatomic) IBOutlet SOSRegisterTextField *textfieldVIN;//VIN输入框
@property (weak, nonatomic) IBOutlet IBOutlet UILabel *labelVINTip;     //VIN输入框错误信息提示
@property (weak, nonatomic) IBOutlet UILabel *labelContent;             //VIN输入框提示信息
@property (weak, nonatomic) IBOutlet SOSRegisterTextField *captchaText;//验证码输入框
@property (assign, nonatomic) BOOL vinCodeOnly;     //只能输入VIN,subscriber添加车辆
@property (assign,nonatomic )BOOL isOtherGovid;     //是否是其他合法证件号
- (void)getImageCaptcha;

@end
