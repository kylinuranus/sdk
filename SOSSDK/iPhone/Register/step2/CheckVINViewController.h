//
//  CheckVINViewController.h
//  Onstar
//
//  Created by Vicky on 13-12-5.
//  Copyright (c) 2013年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSRegisterTextField.h"
#import "SOSRegisterInformation.h"
#import "SOSAgreement.h"

@interface CheckVINViewController : SOSBaseViewController<UITextFieldDelegate>
{
    IBOutlet UIButton *buttonCamera;
    NSString *vinID;
    NSString *mobile;
    NSString *email;
    BOOL info3User;
}
@property (assign,nonatomic)BOOL govidHaveSubscriber;
@property (weak, nonatomic) IBOutlet UILabel *errorCaptchaLB;
@property (weak, nonatomic) IBOutlet SOSRegisterTextField *textfieldVIN;//VIN输入框
@property (weak, nonatomic) IBOutlet IBOutlet UILabel *labelVINTip;     //VIN输入框错误信息提示
//@property (weak, nonatomic) IBOutlet UILabel *labelContent;             //VIN输入框提示信息
@property (weak, nonatomic) IBOutlet SOSRegisterTextField *captchaText;//验证码输入框

@property (weak, nonatomic) NSMutableArray<SOSAgreement *> *agreements;

- (void)getImageCaptcha;

@end
