//
//  SOSLBSAddDeviceVC.m
//  Onstar
//
//  Created by Coir on 19/9/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSLBSAddDeviceVC.h"

typedef void(^finishBlock)(NNLBSDadaInfo *newDevice);

@interface SOSLBSAddDeviceVC ()  <UITextFieldDelegate>   {
  
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *detailLabel;
    __weak IBOutlet UITextField *IMEITextField;
    __weak IBOutlet UITextField *passwordTextField;
    __weak IBOutlet UITextField *deviceNameTextField;
    __weak IBOutlet UIButton *showPasswordButton;
    __weak IBOutlet UIButton *showPasswordButton_new;
    
    
    
}

@property (assign, nonatomic) BOOL needNotice;
@property (strong, nonatomic) UIButton *rightButton;
@property (copy, nonatomic) finishBlock finishBlock;
@property (strong, nonatomic) NNLBSDadaInfo *dataInfo;
@property (weak, nonatomic) IBOutlet UILabel *firstStepLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondStepLabel;
@property (weak, nonatomic) IBOutlet UIButton *jumpNextButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordTextFieldTopGuide;

@end

@implementation SOSLBSAddDeviceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configSelf];
    [self addRACSignal];
}

- (void)configSelf  {
    BOOL isAtFirstStep = (self.stepType == SOSLBSAddDeviceStep_First);
    self.title = @"绑定新设备";
    __weak __typeof(self) weakSelf = self;
    self.rightButton = [[UIButton alloc] init];
    [self.rightButton setTitleForNormalState:@"下一步"];
    self.rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.rightButton setTitleColor:[UIColor colorWithHexString:@"067FE0"] forState:UIControlStateNormal];
    [self.rightButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self.rightButton sizeToFit];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    [[self.rightButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [weakSelf nextStepButtonTapped];
    }];
    self.rightButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = item;
    [self setNavigationBackButton:nil];
    
    [self setBackClickBlock:^{
        if (isAtFirstStep) {
            [SOSDaapManager sendActionInfo:LBS_Adddevices_back];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }   else    {
            [SOSDaapManager sendActionInfo:LBS_Adddevices_2stpback];
            if (weakSelf.finishBlock)     weakSelf.finishBlock([weakSelf.lbsDataInfo copy]);
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
    
    if (self.lbsDataInfo)       self.dataInfo = self.lbsDataInfo;
    else                        self.dataInfo = [NNLBSDadaInfo new];
    
    self.firstStepLabel.hidden = isAtFirstStep;
    self.secondStepLabel.hidden = !isAtFirstStep;
    IMEITextField.hidden = !isAtFirstStep;
    deviceNameTextField.secureTextEntry = !isAtFirstStep;
    showPasswordButton_new.hidden = isAtFirstStep;
    self.jumpNextButton.hidden = isAtFirstStep;
    titleLabel.text = isAtFirstStep ? @"第 1 步" : @"第 2 步";
    detailLabel.text = isAtFirstStep ? @"请输入设备IMEI编号及初始密码" : @"已成功连接到设备，您可以修改初始密码";
    passwordTextField.placeholder = isAtFirstStep ? @"请输入初始密码" : @"请输入新密码";
    deviceNameTextField.placeholder = isAtFirstStep ? @"请为设备命名" : @"请重复输入新密码";
    deviceNameTextField.keyboardType = isAtFirstStep ? UIKeyboardTypeDefault : UIKeyboardTypeASCIICapable;
    IMEITextField.maxInputLength = 10;
    passwordTextField.maxInputLength = 25;
    if (isAtFirstStep) {
        [deviceNameTextField setChineseAndCharactorFilter];
        deviceNameTextField.maxInputCStringLength = 40;
    }    else    {
        self.passwordTextFieldTopGuide.constant = 48.f;
        deviceNameTextField.maxInputLength = 25;
    }
    
    /** 调整页面 TextField 的左间距  */
    for (UITextField *textField in @[IMEITextField, passwordTextField, deviceNameTextField]) {
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        textField.leftView = leftView;
        textField.leftViewMode = UITextFieldViewModeAlways;
    }
}

- (void)setCompleteHanlder:(void (^)(NNLBSDadaInfo *))completion    {
    self.finishBlock = completion;
}

- (void)addRACSignal    {
    __weak __typeof(self) weakSelf = self;
    [[IMEITextField rac_signalForControlEvents:UIControlEventEditingDidEnd] subscribeNext:^(UITextField *textField) {
        if (weakSelf.needNotice && [self checkIMEI:textField.text])  {
            weakSelf.dataInfo.deviceid = textField.text;
        }
    }];
    
    [[passwordTextField rac_signalForControlEvents:UIControlEventEditingDidEnd] subscribeNext:^(UITextField *textField) {
        if (weakSelf.needNotice && [SOSLBSAddDeviceVC checkPassword:textField.text]) {
            weakSelf.dataInfo.password = textField.text;
        }
    }];

    [[deviceNameTextField rac_signalForControlEvents:UIControlEventEditingDidEnd] subscribeNext:^(UITextField *textField) {
        if (weakSelf.needNotice && self.stepType == SOSLBSAddDeviceStep_First) {
            if ([SOSLBSAddDeviceVC checkDeviceName:textField.text]) {
                weakSelf.dataInfo.devicename = textField.text;
            }
        }   else    {
            if (weakSelf.needNotice && [SOSLBSAddDeviceVC checkPassword:textField.text]) {
                if ([textField.text isEqualToString:passwordTextField.text]) {
                    weakSelf.dataInfo.password = textField.text;
                }   else    {
                    [Util toastWithMessage:@"两次输入密码不一致"];
                }
            }
        }
    }];
    
    BOOL isAtFirstStep = (self.stepType == SOSLBSAddDeviceStep_First);
    [[IMEITextField rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
        weakSelf.rightButton.enabled = x.length && passwordTextField.text.length && deviceNameTextField.text.length;
    }];
    [[passwordTextField rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
        weakSelf.rightButton.enabled = x.length && deviceNameTextField.text.length && (isAtFirstStep ? IMEITextField.text.length : 1);
    }];
    [[deviceNameTextField rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
        weakSelf.rightButton.enabled = x.length && passwordTextField.text.length && (isAtFirstStep ? IMEITextField.text.length : 1);
    }];
}

- (void)viewDidAppear:(BOOL)animated       {
    [super viewDidAppear:animated];
    self.needNotice = YES;
}

- (void)viewWillDisappear:(BOOL)animated    {
    [super viewWillDisappear:animated];
    self.needNotice = NO;
}

#pragma mark - Button Action
/** 打开/关闭 密码输入模式 */
- (IBAction)showPasswordButtonTapped:(UIButton *)sender     {
    sender.selected = !sender.selected;
    if (sender == showPasswordButton) {
        passwordTextField.secureTextEntry = !sender.selected;
    }   else if (sender == showPasswordButton_new)  {
        deviceNameTextField.secureTextEntry = !sender.selected;
    }
}

/** 下一步 */
- (IBAction)nextStepButtonTapped    {
    [self.view endEditing:YES];
    if (![self checkInputInfo])      return;
    if (self.stepType == SOSLBSAddDeviceStep_First) {
        //初始密码必须为 123456
        if (![passwordTextField.text isEqualToString:@"123456"])    {
            [Util toastWithMessage:@"初始密码错误"];
            return;
        }
        [Util showHUD];
        [SOSDaapManager sendActionInfo:LBS_Adddevices_1stpnext];
    }   else    {
        [Util showHUD];
        [SOSDaapManager sendActionInfo:LBS_Adddevices_2stpnext];
    }
    
    [self fixDataInfo];
    self.dataInfo.password = [SOSLBSDataTool md5withDoubleSalt:self.dataInfo.password];
    [SOSLBSDataTool updateDeviceWithLBSDadaInfo:self.dataInfo Success:^(NNLBSDadaInfo *lbsInfo, NSString *description) {
        [Util dismissHUD];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.stepType == SOSLBSAddDeviceStep_First) {
                SOSLBSAddDeviceVC *vc = [SOSLBSAddDeviceVC new];
                vc.stepType = SOSLBSAddDeviceStep_Last;
                if (self.finishBlock)		vc.finishBlock = self.finishBlock;
                vc.lbsDataInfo = lbsInfo;
                [SOSLBSDataTool saveDeviceLoginFlag:YES WithDeviceID:lbsInfo.deviceid];
                [self.navigationController pushViewController:vc animated:YES];
            }   else    {
                [Util showSuccessHUDWithStatus:@"设备绑定成功"];
                if (self.finishBlock)     self.finishBlock(lbsInfo);
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        });
            
    } Failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util dismissHUD];
        if (responseStr.length)     [Util toastWithMessage:responseStr];
    }];
}

- (void)fixDataInfo   {
    if (self.stepType == SOSLBSAddDeviceStep_First) {
        [self.dataInfo setCreatesWithDate:[NSDate date]];
        self.dataInfo.status = @"1";
        self.dataInfo.updatets = self.dataInfo.createts;
        self.dataInfo.devicetype = @"LBS";
        self.dataInfo.platform = @"gps902";
    }
}

/// 跳过
- (IBAction)jumpNext {
    [SOSDaapManager sendActionInfo:LBS_Adddevices_2stpskip];
    if (self.finishBlock)     self.finishBlock([self.lbsDataInfo copy]);
    [self.navigationController popToRootViewControllerAnimated:YES];
}

///校验用户输入
- (BOOL)checkInputInfo  {
    BOOL isRightIMEI = [self checkIMEI:self.dataInfo.deviceid];
    if (!isRightIMEI)   return NO;
    BOOL isRightPassWord = [SOSLBSAddDeviceVC checkPassword:passwordTextField.text];
    if (!isRightPassWord)   return NO;
    BOOL isDeviceNameRight = [SOSLBSAddDeviceVC checkDeviceName:deviceNameTextField.text];
    if (!isDeviceNameRight)     return NO;
    
    if (self.stepType == SOSLBSAddDeviceStep_Last) {
        if (![deviceNameTextField.text isEqualToString:passwordTextField.text]) {
            [Util toastWithMessage:@"两次输入密码不一致"];
            return NO;
        }
    }
    return YES;
}

///校验 IMEI
- (BOOL)checkIMEI:(NSString *)IMEIString    {
    if (![Util trimString:IMEIString].length)   {
        [Util toastWithMessage:@"IMEI不能为空"];
        return NO;
    }
    if (IMEIString.length != 10) {
        [Util toastWithMessage:@"IMEI编号格式错误"];
        return NO;
    }
    return YES;
}

/// 校验密码
+ (BOOL)checkPassword:(NSString *)passWord      {
    if (![Util trimString:passWord].length)   {
        [Util toastWithMessage:@"密码不能为空"];
        return NO;
    }
    NSString *regex = @"^[0-9A-Za-z]{6,25}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValid = [predicate evaluateWithObject:passWord];
    if (!isValid)       [Util toastWithMessage:@"密码格式错误"];
    return isValid;
}

/// 校验用户名
+ (BOOL)checkDeviceName:(NSString *)deviceName  {
    if (![Util trimString:deviceName].length)   {
        [Util toastWithMessage:@"设备名称不能为空"];
        return NO;
    }
    if (deviceName.length < 2) {
        [Util toastWithMessage:@"设备名称过短"];
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
