//
//  SOSVisitorRegisterViewController.m
//  Onstar
//
//  Created by lmd on 2017/8/29.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSVisitorRegisterViewController.h"
#import "SOSInputTextField.h"
#import "RegisterUtil.h"
#import "LoadingView.h"
#import "SOSCustomAlertView.h"
#import "ViewControllerLogin.h"
#import "SOSCardUtil.h"
#import "ViewControllerLogin.h"

@interface SOSVisitorRegisterViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet SOSInputTextField *userNameTextField;
@property (weak, nonatomic) IBOutlet SOSRegisterTextField *verCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (nonatomic, assign) BOOL validUserName;
@property (nonatomic, assign) BOOL validVerCode;
///false为手机号已经注册过
@property (assign, nonatomic) BOOL isMobileUnique;
@end

@implementation SOSVisitorRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
}

- (void)configUI {
    self.title = @"非安吉星车主注册";
//    self.title = @"非安吉星车主注册";
    self.userNameTextField.inputStatus = SOSInputViewStatusEditing;
    [self.verCodeTextField setupVerifyCodeRightViewWithDelegate:self Method:@selector(willSendPhoneVerifyCode:)];
    self.verCodeTextField.delegate = self;
    self.userNameTextField.delegate = self;
    [SOSUtil setButtonStateDisableWithButton:self.nextButton];
    [self.verCodeTextField addTarget:self action:@selector(textFieldEditing:) forControlEvents:UIControlEventEditingChanged];
}

#pragma mark textField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.verCodeTextField) {
        if (![self isNumeber:string]) {
            return NO;
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.userNameTextField) {
        if (self.userNameTextField.text.isNotBlank) {
            if (![self checkValidUserName]) {
                [self.userNameTextField showError:@"您输入的手机号码格式有误"];
            }else {
                self.userNameTextField.inputStatus = SOSInputViewStatusSuccess;
                self.validUserName = YES;
                //[self checkUserNameRequest];  addbyWQ 20190301 测试要求不再发请求验证唯一性，只验证合法性,唯一性在注册请求中后台验证
            }
        }else{
             [self.userNameTextField showError:@"手机号不可为空"];
        }
       
    }else if (textField == self.verCodeTextField) {
        self.validVerCode = textField.text.length >= 4;
    }
}

- (void)textFieldEditing:(UITextField *)textField {
    if (textField == self.verCodeTextField) {
        self.validVerCode = textField.text.length >= 4;
    }else if (textField == self.userNameTextField) {
        [self checkValidUserName];
    }
}

#pragma mark action
- (IBAction)nextButtonClicked:(id)sender {
    
    [self registerRequest];
}

- (BOOL)isNumeber:(NSString *)str
{
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}

- (BOOL)checkValidUserName {
    if (![Util isValidatePhone:self.userNameTextField.text] && ![Util isValidateEmail:self.userNameTextField.text]) {
        self.validUserName = NO;
        return NO;
    }
    return YES;
}

- (void)setValidUserName:(BOOL)validUserName {
    _validUserName = validUserName;
    [self enableNextButton];
}

- (void)setValidVerCode:(BOOL)validVerCode {
    _validVerCode = validVerCode;
    [self enableNextButton];
}

- (void)enableNextButton {
    if (self.validUserName && self.validVerCode) {
        [SOSUtil setButtonStateEnableWithButton:self.nextButton];
    }else {
        [SOSUtil setButtonStateDisableWithButton:self.nextButton];
    }
}
- (void)disableInput
{
    self.userNameTextField.userInteractionEnabled = NO;
}
- (void)willSendPhoneVerifyCode:(id)sender {
    [self.verCodeTextField resignFirstResponder];
    if ([self checkValidUserName]) {
        [self didSendPhoneVerifyCode:sender];
    }else {
        NSLog(@"用户名不合法");
    }
}

- (void)didSendPhoneVerifyCode:(id)sender {
    [self sendVerCodeRequest];
    //倒计时
    UIButton * codeButton =(UIButton * )sender;
    __block NSInteger time = 59; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(time <= 0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置按钮的样式
                [codeButton setTitle:@"重新发送" forState:UIControlStateNormal];
                codeButton.userInteractionEnabled = YES;
                self.userNameTextField.userInteractionEnabled = YES;
            });
            
        }else{
            
            int seconds = time % 60;
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置按钮显示读秒效果
                [codeButton setTitle:[NSString stringWithFormat:@"重新发送(%.2d)", seconds] forState:UIControlStateNormal];
                codeButton.userInteractionEnabled = NO;
                self.userNameTextField.userInteractionEnabled = NO;
            });
            time--;
        }
    });
    dispatch_resume(_timer);

}

#pragma mark request
- (void)checkUserNameRequest {
    self.userNameTextField.inputStatus = SOSInputViewStatusChecking;
    NNRegisterRequest *regRequest = [[NNRegisterRequest alloc]init];
    [regRequest setSourceId:[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]];
    __block BOOL isMobile = NO;
    if([Util isValidatePhone:self.userNameTextField.text]) {
        [regRequest setMobilePhoneNumber:[Util trim:self.userNameTextField]];
        isMobile = YES;
    }else if ([Util isValidateEmail:self.userNameTextField.text]) {
        [regRequest setEmailAddress:[Util trim:self.userNameTextField] ];
    }
    NSString *url = [BASE_URL stringByAppendingString:NEW_REGISTER_CHECK_UNIQUE];
    NSString *json = [regRequest mj_JSONString];
    @weakify(self);
    [RegisterUtil registAsVisitor:url paragramString:json successHandler:^(NNRegisterResponse *regRes) {
        @strongify(self);
        if (isMobile) {
            if ([regRes.isMobileUnique boolValue]) {
                self.userNameTextField.inputStatus = SOSInputViewStatusSuccess;
                self.validUserName = YES;
            }else{
                [self.userNameTextField showError:NSLocalizedString(@"MobileEmailExist", nil)];
                self.validUserName = NO;
            }
        }else{
            if ([regRes.isEmailUnique boolValue]) {
                self.userNameTextField.inputStatus = SOSInputViewStatusSuccess;
                self.validUserName = YES;
            }else{
                [self.userNameTextField showError:NSLocalizedString(@"MobileEmailExist", nil)];
                self.validUserName = NO;
            }
        }
    
    } failureHandler:^(NSString *responseStr, NSError *error) {
         @strongify(self);
        [self.userNameTextField showError:[Util visibleErrorMessage:responseStr]];
        self.validUserName = NO;
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
    }];
}

- (void)sendVerCodeRequest {
    [self disableInput];
    NNRegisterRequest *regRequest = [[NNRegisterRequest alloc]init];
    [regRequest setSourceId:[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]];
    if([Util isValidatePhone:self.userNameTextField.text]) {
        [regRequest setMobilePhoneNumber:[Util trim:self.userNameTextField]];
    }else if ([Util isValidateEmail:self.userNameTextField.text]) {
        [regRequest setEmailAddress:[Util trim:self.userNameTextField]];
    }
    [regRequest setSendCodeSenario:@"REG_VISITOR"];
    NSString *url = [BASE_URL stringByAppendingString:INFO3_REGISTER_CODE_GET];//info3 url change
//    [regRequest setPassWord:NONil(self.password)];
    [regRequest setUserName:NONil(self.userName)];
    
    NSString *json = [regRequest mj_JSONString];
    [RegisterUtil registAsVisitor:url paragramString:json successHandler:^(NNRegisterResponse *regRes) {
        
        _isMobileUnique = regRes.isMobileUnique.boolValue;
        [Util toastWithVerifyCode:[NSString stringWithFormat:@"验证码已发送,请注意查收%@",regRes.secCode]];
    } failureHandler:^(NSString *responseStr, NSError *error) {
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
    }];

}

- (void)registerRequest {
    [self.view endEditing:YES];
    self.nextButton.userInteractionEnabled = NO;
     [[LoadingView sharedInstance] startIn:self.view withNavigationBar:NO];
    NNRegisterRequest *regRequest = [[NNRegisterRequest alloc]init];
    [regRequest setSourceId:[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]];
    if([Util isValidatePhone:self.userNameTextField.text]) {
        [regRequest setMobilePhoneNumber:[Util trim:self.userNameTextField]];
    }else if ([Util isValidateEmail:self.userNameTextField.text]) {
        [regRequest setEmailAddress:[Util trim:self.userNameTextField]];
    }
    NSString *url = [BASE_URL stringByAppendingString:INFO3_REGISTER_Visitor];
    [regRequest setPassWord:[[self.password sha256String] uppercaseString]];
    [regRequest setUserName:NONil(self.userName)];
    NSString *secCode = [Util removeWhiteSpaceString:self.verCodeTextField.text];
    [regRequest setSecCode:NONil(secCode)];
    [regRequest setSendCodeSenario:kVerifyCodeVisitorSenario];
    NSString *json = [regRequest mj_JSONString];
    
    [RegisterUtil registAsVisitor:url paragramString:json successHandler:^(NNRegisterResponse *regRes) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self popMessage:NSLocalizedString(@"SB021-28", nil) withTitle:@""];
        });
    } failureHandler:^(NSString *responseStr, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[LoadingView sharedInstance] stop];
            self.nextButton.userInteractionEnabled = YES;
        });
        NNErrorDetail *detail = [NNErrorDetail mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
        if ([detail.code isEqualToString:@"E3343"]) {
            
            
            [Util showAlertWithTitle:@"已注册" message:detail.msg confirmBtn:@"立即登录" completeBlock:^(NSInteger buttonIndex) {
                if ([self.navigationController.viewControllers.firstObject isKindOfClass:ViewControllerLogin.class]) {
                    ViewControllerLogin *loginVC = self.navigationController.viewControllers.firstObject;
                    [loginVC fillCellphoneNumber:[Util trim:_userNameTextField]];
                }
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
            
        }else

        if (detail && [detail.code isEqualToString:@"E3323"]) {
            [SOSUtil showOnstarAlertWithTitle:@"提示" message:detail.msg alertModel:SOSAlertViewModelContent completeBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [SOSDaapManager sendActionInfo:Register_existedmobileemail_resetpassword];
                    [SOSCardUtil routerToForegtPassWord:self];
                }
                else{
                    [SOSDaapManager sendActionInfo:Register_existedmobileemail_Iknow];
                }
            } cancleButtonTitle:@"知道了" otherButtonTitles:@[@"立即修改密码"]];
            
        }else{
            [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
        }
    }];
    [SOSDaapManager sendActionInfo:notowner_register_2step_finish];
}

- (void)popMessage:(NSString *)message withTitle:(NSString *)title {
    [[LoadingView sharedInstance] stop];
    self.nextButton.userInteractionEnabled = YES;
    
    [Util showAlertWithTitle:@"欢迎您!" message:@"你已成功注册安吉星" completeBlock:^(NSInteger buttonIndex) {
        [SOSDaapManager sendActionInfo:notowner_notification_registsuccess_iknow];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:NONil(self.userName) forKey:NN_TEMP_USERNAME];
        [defaults synchronize];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }cancleButtonTitle:nil otherButtonTitles:@"知道了",nil];
}

//#pragma mark SOSAlertViewDelegate
//- (void)sosAlertView:(SOSCustomAlertView *)alertView didClickButtonAtIndex:(NSInteger )buttonIndex {
////    ViewControllerLogin *loginView = nil;
////    loginView = (ViewControllerLogin *)[Util findTopViewControllerOfClass:[ViewControllerLogin class] fromControllers:self.navigationController.viewControllers];
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setObject:NONil(self.userName) forKey:NN_TEMP_USERNAME];
//    [defaults synchronize];
//    [self.navigationController popToRootViewControllerAnimated:YES];
////    [self.navigationController popToViewController:loginView animated:YES];
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
