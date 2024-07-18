//
//  SOSEditUserInfoViewController.m
//  Onstar
//
//  Created by lmd on 2017/9/1.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSEditUserInfoViewController.h"
#import "SOSInputTextField.h"
#import "RegisterUtil.h"
#import "NSString+JWT.h"
@interface SOSEditUserInfoViewController ()<UITextFieldDelegate>{
    BOOL defaultPinFlag;
}
@property (weak, nonatomic) IBOutlet UILabel *originalLabel;
@property (weak, nonatomic) IBOutlet SOSInputTextField *topTextField;
@property (weak, nonatomic) IBOutlet SOSRegisterTextField *BottomTextField;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (nonatomic, assign) BOOL isMobileUnique; //手机号是否被占用
@property (nonatomic, assign) BOOL isEmailUnique; //邮箱是否被占用
@property (nonatomic, assign) BOOL isNextButtonDisable; //手机号是否被占用
@property (nonatomic, copy) NSString *tipNormalText;

@end

@implementation SOSEditUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    _isMobileUnique = YES;
    _isEmailUnique = YES;
    self.isNextButtonDisable = NO;
}

#pragma mark UI
- (void)configUI {
    [self.nextButton setRegisterStyle];
    switch (self.editType) {
        case SOSEditUserInfoTypeMail:
        {
            self.originalLabel.text = [NSString stringWithFormat:@"原邮箱 %@",[self.originLabelString stringEmailInterceptionHide]];
            self.title = @"更改邮箱";
            self.tipNormalText = @"更新邮箱后,请用新的邮箱地址进行登录";
            self.topTextField.placeholder = @"请输入新邮箱地址";
            self.BottomTextField.placeholder = @"请输入验证码";
            self.topTextField.keyboardType = UIKeyboardTypeEmailAddress;
            self.topTextField.maxInputLength = 50;
            self.BottomTextField.keyboardType = UIKeyboardTypeNumberPad;
            self.BottomTextField.maxInputLength = 6;
            [self.BottomTextField setupVerifyCodeRightViewWithDelegate:self Method:@selector(didSendPhoneVerifyCode:)];
        }
            break;
        case SOSEditUserInfoTypeMailAdd:
        {
            self.originalLabel.hidden = YES;
            self.title = @"添加邮箱";
            self.tipNormalText = @"更新邮箱后,请用新的邮箱地址进行登录";
            self.topTextField.placeholder = @"请输入新邮箱地址";
            self.BottomTextField.placeholder = @"请输入验证码";
            self.topTextField.keyboardType = UIKeyboardTypeEmailAddress;
            self.topTextField.maxInputLength = 50;
            self.BottomTextField.keyboardType = UIKeyboardTypeNumberPad;
            self.BottomTextField.maxInputLength = 6;
            [self.BottomTextField setupVerifyCodeRightViewWithDelegate:self Method:@selector(didSendPhoneVerifyCode:)];
        }
            break;
        case SOSEditUserInfoTypePhone:
        {
            if (self.originLabelString.isNotBlank) {
                self.title = @"更改手机号";
                NSString *phoneStr = [self.originLabelString stringInterceptionHide];
                self.originalLabel.text = [NSString stringWithFormat:@"原手机号 %@", (phoneStr.length ? phoneStr : @"")];
                self.topTextField.placeholder = @"请输入新的手机号码";
                
            }else{
                self.title = @"添加手机号";
                self.originalLabel.text =nil;
                self.topTextField.placeholder = @"请输入手机号码";
            }
            
            self.tipNormalText = @"更新手机号码后,请用新的手机号码进行登录";
            self.BottomTextField.placeholder = @"请输入验证码";
            self.topTextField.keyboardType = UIKeyboardTypeNumberPad;
            self.topTextField.maxInputLength = 11;
            self.BottomTextField.keyboardType = UIKeyboardTypeNumberPad;
            self.BottomTextField.maxInputLength = 6;
            [self.BottomTextField setupVerifyCodeRightViewWithDelegate:self Method:@selector(didSendPhoneVerifyCode:)];
        }
            break;
        case SOSEditUserInfoTypeCarControlPassword:
        {
            self.title = @"车辆控制密码";
            self.tipNormalText = @"6个字符,由数字或字母组成,区分大小写";
            self.topTextField.placeholder = @"请输入新密码";
            self.topTextField.secureTextEntry = YES;
            self.topTextField.delegate = self;
            self.BottomTextField.secureTextEntry = YES;
            self.BottomTextField.delegate = self;
            self.BottomTextField.placeholder = @"请再次输入新密码";
            self.topTextField.keyboardType = UIKeyboardTypeASCIICapable;
            self.topTextField.maxInputLength = 6;
            self.BottomTextField.keyboardType = UIKeyboardTypeASCIICapable;
            self.BottomTextField.maxInputLength = 6;
            self.originalLabel.hidden = YES;
            if (self.navigationController) {
//                @weakify(self);
                if (self.navigationController.viewControllers.count == 1) {
                    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"common_Nav_Back"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];

                }
            }
        }
            break;
        case SOSEditUserInfoTypeMAPassword:
        {
            self.title = @"手机应用登录密码";
            self.tipNormalText = @"6-25个字符,必须包含数字和字母,区分大小写";
            self.topTextField.placeholder = @"请输入新密码";
            self.BottomTextField.placeholder = @"请再次输入新密码";
            self.topTextField.keyboardType = UIKeyboardTypeASCIICapable;
            self.topTextField.secureTextEntry = YES;
            self.topTextField.maxInputLength = 25;
            self.BottomTextField.keyboardType = UIKeyboardTypeASCIICapable;
            self.BottomTextField.maxInputLength = 25;
            self.BottomTextField.secureTextEntry = YES;
            self.originalLabel.hidden = YES;
        }
            break;
        default:
            break;
    }
    self.tipLabel.text = self.tipNormalText;
    @weakify(self);
    RAC(self.nextButton, enabled) = [RACSignal combineLatest:@[self.topTextField.rac_textSignal,
                                                               self.BottomTextField.rac_textSignal]
                                                      reduce:^(NSString *topText, NSString *bottomText){
                                                          @strongify(self);
                                                                                                        if (!self.isNextButtonDisable) {
                                                          return @([self checkTopTextFieldValidShowError:NO] && [self checkBottomTextFieldValidShowError:NO]);
                                                                                                                    }else{
                                                                                                                        return @(NO);
                                                                                                                    }
                                                      }];
    
    [[self.topTextField rac_signalForControlEvents:UIControlEventEditingDidBegin] subscribeNext:^(id x) {  //addByWQ 20180618  每次开始输入时需检测是否格式异常（）
        @strongify(self);
        [self checkTopTextFieldValidShowError:YES];
        [self checkBottomTextFieldBlank];
    }];
    
    [[self.topTextField rac_signalForControlEvents:UIControlEventEditingDidEnd] subscribeNext:^(id x) {
        @strongify(self);
        [self checkTopTextFieldValidShowError:YES];
        [self checkBottomTextFieldBlank];
    }];
    
    [[self.BottomTextField rac_signalForControlEvents:UIControlEventEditingDidBegin] subscribeNext:^(id x) {  //addByWQ 20180618  每次开始输入时需检测是否格式异常（）
        @strongify(self);
        [self checkBottomTextFieldValidShowError:YES];
        [self checkTopTextFieldBlank];   //再次输入密码时需检测第一次输入密码是否格式正确
    }];
    
    [[self.BottomTextField rac_signalForControlEvents:UIControlEventEditingDidEnd] subscribeNext:^(id x) {
        @strongify(self);
        [self checkBottomTextFieldValidShowError:YES];
        [self checkTopTextFieldBlank];
    }];
}
-(void)goBack{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark request
- (void)didSendPhoneVerifyCode:(id)sender
{
    
    if (![self checkTopTextFieldValidShowError:YES]) {
        if (self.editType == SOSEditUserInfoTypePhone) {
            self.tipLabel.textColor = [UIColor redColor];
            self.tipLabel.text = @"手机号码格式有误";
        }
        return;
    }
    if (self.editType == SOSEditUserInfoTypePhone || self.editType == SOSEditUserInfoTypeMail || self.editType == SOSEditUserInfoTypeMailAdd) {
        self.topTextField.enabled = NO;
    }
    NNRegisterRequest *regRequest = [[NNRegisterRequest alloc] init];
    [regRequest setSourceId:[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]];
    
    [regRequest setSendCodeSenario:@"REG_VISITOR"];
    
    switch (self.editType) {
        case SOSEditUserInfoTypeMailAdd:
        case SOSEditUserInfoTypeMail:
        {
            [regRequest setEmailAddress:NONil(self.topTextField.text)];
            [regRequest setMobilePhoneNumber:@""];
        }
            break;
        case SOSEditUserInfoTypePhone:
        {
            [regRequest setEmailAddress:@""];
            [regRequest setMobilePhoneNumber:NONil(self.topTextField.text)];
        }
            break;
            
        default:
            break;
    }
    
    NSString *json = [regRequest mj_JSONString];
    [RegisterUtil sendVerifyCode:json successHandler:^(NNRegisterResponse * response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.editType == SOSEditUserInfoTypePhone) {
                if (response.isMobileUnique.boolValue) {
                }
                else
                {
                    self.isMobileUnique = NO;
                }
            }
            else
            {
                
                if (response.isEmailUnique.boolValue) {
                    //#ifdef DEBUG
                    ////                        [Util toastWithVerifyCode:[NSString stringWithFormat:@"验证码已发送,请注意查收%@",response.secCode]];
                    //#else
                    //                        [Util toastWithMessage:[NSString stringWithFormat:@"验证码已发送,请注意查收!"]];
                    //#endif
                }
                else
                {
                    //和当前登录邮箱是同一个的话，无需验证是否被占用了
                    if (![NONil(response.emailAddress) isEqualToString:[CustomerInfo sharedInstance].userBasicInfo.idmUser.emailAddress]) {
                        self.isEmailUnique = NO;
                    }
                    else
                    {
#ifdef DEBUG
                        [Util toastWithMessage:[NSString stringWithFormat:@"验证码已发送,请注意查收%@",response.secCode]];
#else
                        [Util toastWithMessage:[NSString stringWithFormat:@"验证码已发送,请注意查收!"]];
#endif
                    }
                }
                
            }
            
        });
        
    } failureHandler:^(NSString *responseStr, NSError *error) {
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
    }];
    
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
            });
            
        }else{
            
            int seconds = time % 60;
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置按钮显示读秒效果
                [codeButton setTitle:[NSString stringWithFormat:@"重新发送(%.2d)", seconds] forState:UIControlStateNormal];
                codeButton.userInteractionEnabled = NO;
            });
            time--;
        }
    });
    dispatch_resume(_timer);
    
}

- (void)verCodeRequest {
    [Util showLoadingView];
    //验证验证码
    NNRegisterRequest *regRequest = [[NNRegisterRequest alloc]init];
    [regRequest setSourceId:[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]];
    switch (self.editType) {
        case SOSEditUserInfoTypeMail:
        case SOSEditUserInfoTypeMailAdd:
        {
            [regRequest setEmailAddress:NONil(self.topTextField.text)];
            [regRequest setMobilePhoneNumber:@""];
        }
            break;
        case SOSEditUserInfoTypePhone:
        {
            [regRequest setEmailAddress:@""];
            [regRequest setMobilePhoneNumber:NONil(self.topTextField.text)];
        }
            break;
            
        default:
            break;
    }
    
    [regRequest setSecCode:self.BottomTextField.text.stringByTrim];
    [regRequest setSendCodeSenario:@"REG_VISITOR"];
    @weakify(self);
    [RegisterUtil checkVerifyCode:[regRequest mj_JSONString] successHandler:^(id resp) {
        @strongify(self);
        dispatch_async_on_main_queue(^(){
            if (![self checkUniqueFalse]) {
                [self complete];
            }
           
        });
        
    } failureHandler:^(NSString *responseStr, NSError *error) {
        [Util hideLoadView];
//        if (![self checkUniqueFalse]) {
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
//        }
    }];
}
-(BOOL)checkUniqueFalse{
    if (self.editType == SOSEditUserInfoTypePhone) {
        if (!self.isMobileUnique) {
            [Util hideLoadView];
            [Util showAlertWithTitle:nil message:@"手机号已经被占用!" completeBlock:nil];
            [SOSUtil setButtonStateDisableWithButton:self.nextButton];
            self.isNextButtonDisable = YES;
            return YES;
        }
    }
    if (self.editType == SOSEditUserInfoTypeMailAdd || SOSEditUserInfoTypeMail) {
        if (!self.isEmailUnique) {
            [Util hideLoadView];
            [Util showAlertWithTitle:nil message:@"邮箱已经被占用!" completeBlock:nil];
            [SOSUtil setButtonStateDisableWithButton:self.nextButton];
            self.isNextButtonDisable = YES;
            return YES;
        }
    }
    return NO;
}

#pragma mark action
- (void)complete {
    [Util hideLoadView];
    if (self.fixOkBlock) {
        self.fixOkBlock(self.topTextField.text);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)checkTopTextFieldValidShowError:(BOOL)showError {
    //NSLog(@"checkTopTextFieldValidShowError  %@",showError);
    if (!self.topTextField.text.isNotBlank) {
        [self checkBothTextfieldBlank:@"top"];
        return NO;
    }
    BOOL ret = NO;
    defaultPinFlag = NO;
    NSString *errorText = @"";
    switch (self.editType) {
        case SOSEditUserInfoTypeMailAdd:
        case SOSEditUserInfoTypeMail:
        {
            ret = [Util isValidateEmail:self.topTextField.text.stringByTrim];
            errorText = @"邮箱格式不正确";
        }
            break;
        case SOSEditUserInfoTypePhone:
        {
            ret = [Util isValidatePhone:self.topTextField.text.stringByTrim];
            errorText = @"手机号码格式有误";
        }
            break;
        case SOSEditUserInfoTypeCarControlPassword:
        {
            ret = [Util isValidateCarControlPassword:self.topTextField.text.stringByTrim];
            errorText = @"密码格式有误";
            if (ret) {
                //检验是否是后六位
                NSInteger fromIdx = self.govid.length - 6;
                if (fromIdx >= 0) {
                    NSString *defaultPin = [self.govid substringFromIndex:fromIdx];
                    if ([self.topTextField.text.stringByTrim isEqualToString:defaultPin]) {
                        ret = NO;
                        errorText = @"安全验证升级，请设置其他六位数密码";
                        defaultPinFlag = YES;
                    }
                }
            }
            
        }
            break;
        case SOSEditUserInfoTypeMAPassword:
        {
            ret = [Util isValidatePassword:self.topTextField.text.stringByTrim];
            errorText = @"密码格式有误";
        }
            break;
        default:
            break;
    }
    
    if (showError) {
        if (!ret) {
            [self setTipErrorText:errorText];
        }else {
            self.topTextField.inputStatus = SOSInputViewStatusSuccess;
            self.tipLabel.textColor = UIColorHex(0x898994);
            self.tipLabel.text = self.tipNormalText;
        }
        
    }
    if (defaultPinFlag) {
        
        [self setTipErrorText:errorText];
    }
    return ret;
}
- (void)setTipErrorText:(NSString *)error{
    self.tipLabel.textColor = [UIColor redColor];
    self.tipLabel.text = error;
    self.topTextField.inputStatus = SOSInputViewStatusError;
}
- (BOOL)checkBottomTextFieldValidShowError:(BOOL)showError {
    if (!self.BottomTextField.text.isNotBlank) {
        [self checkBothTextfieldBlank:@"Bottom"];
        return NO;
    }
    BOOL ret = NO;
    NSString *errorText = @"";
    switch (self.editType) {
        case SOSEditUserInfoTypeMailAdd:
        case SOSEditUserInfoTypeMail:
        {
            ret = [Util isNumeber:self.BottomTextField.text];
            errorText = @"验证码格式不正确";
        }
            break;
        case SOSEditUserInfoTypePhone:
        {
            ret = [Util isNumeber:self.BottomTextField.text];
            errorText = @"验证码格式不正确";
        }
            break;
        case SOSEditUserInfoTypeCarControlPassword:
        {
            ret = [Util isValidateCarControlPassword:self.BottomTextField.text];
            if (!ret) {
                errorText = @"密码格式有误";
            }else {
                ret = [self.topTextField.text isEqualToString:self.BottomTextField.text];
                errorText = @"两次输入内容不一致，请重新输入";
            }
        }
            break;
        case SOSEditUserInfoTypeMAPassword:
        {
            ret = [Util isValidatePassword:self.BottomTextField.text];
            if (!ret) {
                errorText = @"密码格式有误";
            }else {
                ret = [self.topTextField.text isEqualToString:self.BottomTextField.text];
                errorText = @"两次输入内容不一致，请重新输入";
            }
        }
            break;
        default:
            break;
    }
    if (self.editType == SOSEditUserInfoTypeMail || self.editType == SOSEditUserInfoTypeMailAdd) {
    }else if (self.editType == SOSEditUserInfoTypePhone) {
        
    }else if (self.editType == SOSEditUserInfoTypeCarControlPassword) {
        
    }
    if (showError) {
        if (!ret) {
            self.tipLabel.textColor = [UIColor redColor];
            self.tipLabel.text = errorText;
            
        }else {
            self.tipLabel.textColor = UIColorHex(0x898994);
            self.tipLabel.text = self.tipNormalText;
        }
    }
    return ret;
}


- (IBAction)nextButtonClicked:(id)sender {
    [self.view endEditing:YES];
    if (self.editType == SOSEditUserInfoTypeCarControlPassword || self.editType == SOSEditUserInfoTypeMAPassword) {
        [self complete];
    }else{
        [self verCodeRequest];
    }
}
#pragma mark - textField Delegate 限制输入长度
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.editType == SOSEditUserInfoTypeCarControlPassword) {
        if (range.location >= 6)
            return NO;
        return YES;
    }
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)checkBothTextfieldBlank:(NSString*)str
{
    if ([str isEqualToString:@"top"]) {
        if (!self.topTextField.text.isNotBlank)
        {
            [self showTiShi];
        }
    }else
    {
        if (!self.BottomTextField.text.isNotBlank)
        {
            if (!defaultPinFlag) {
                [self showTiShi];
            }
        }
    }
    
}


- (void)showTiShi
{
    switch (self.editType) {
        case SOSEditUserInfoTypeCarControlPassword:
        {
            self.tipLabel.textColor = UIColorHex(0x898994);
            self.tipLabel.text = self.tipNormalText;
        }
            break;
        case SOSEditUserInfoTypeMAPassword:
        {
            self.tipLabel.textColor = UIColorHex(0x898994);
            self.tipLabel.text = self.tipNormalText;
        }
            break;
            
        default:
            break;
    }
    
}

- (void)checkTopTextFieldBlank
{
    if (self.topTextField.text.isNotBlank) {
        BOOL ret = NO;
        switch (self.editType) {
            case SOSEditUserInfoTypeMail:
            {
                ret = YES;
            }
            case SOSEditUserInfoTypeMailAdd:
            {
                ret = YES;
            }
                break;
            case SOSEditUserInfoTypePhone:
            {
                ret = YES;
            }
                break;
            case SOSEditUserInfoTypeCarControlPassword:
            {
                ret = [Util isValidateCarControlPassword:self.topTextField.text];
            }
                break;
            case SOSEditUserInfoTypeMAPassword:
            {
                ret = [Util isValidatePassword:self.topTextField.text];
            }
                break;
            default:
                break;
        }
        if (!ret) {
            self.tipLabel.textColor = [UIColor redColor];
            self.tipLabel.text = @"密码格式有误";
        }
    }
}

- (void)checkBottomTextFieldBlank
{
    if (self.BottomTextField.text.isNotBlank) {
        BOOL ret = NO;
        switch (self.editType) {
            case SOSEditUserInfoTypeMail:
            {
                ret = YES;
            }
            case SOSEditUserInfoTypeMailAdd:
            {
                ret = YES;
            }
                break;
            case SOSEditUserInfoTypePhone:
            {
                ret = YES;
            }
                break;
            case SOSEditUserInfoTypeCarControlPassword:
            {
                ret = [Util isValidateCarControlPassword:self.topTextField.text];
            }
                break;
            case SOSEditUserInfoTypeMAPassword:
            {
                ret = [Util isValidatePassword:self.topTextField.text];
            }
                break;
            default:
                break;
        }
        if (!ret) {
            self.tipLabel.textColor = [UIColor redColor];
            self.tipLabel.text = @"密码格式有误";
        }
    }
    
}


@end


/*
 if (!self.topTextField.text.isNotBlank && !self.BottomTextField.text.isNotBlank) {
 switch (self.editType) {
 case SOSEditUserInfoTypeMailAdd:
 case SOSEditUserInfoTypeMail:
 case SOSEditUserInfoTypePhone:
 case SOSEditUserInfoTypeCarControlPassword:
 {
 self.tipLabel.textColor = UIColorHex(0x898994);
 self.tipLabel.text = self.tipNormalText;
 }
 break;
 case SOSEditUserInfoTypeMAPassword:
 {
 self.tipLabel.textColor = UIColorHex(0x898994);
 self.tipLabel.text = self.tipNormalText;
 
 }
 break;
 default:
 break;
 }
 }
 
 */
