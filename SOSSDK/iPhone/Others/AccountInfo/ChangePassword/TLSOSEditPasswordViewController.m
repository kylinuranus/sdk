//
//  TLSOSEditPasswordViewController.m
//  Onstar
//
//  Created by TaoLiang on 2017/11/2.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "TLSOSEditPasswordViewController.h"
//todofix
//#import "SOSBangcleKBTextField.h"
#import "AccountInfoUtil.h"
#import "SOSKeyChainManager.h"
#import "SOSInputTextField.h"
@interface TLSOSEditPasswordViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) SOSInputTextField *originTextField;
@property (strong, nonatomic) SOSInputTextField *updateTextField;
@property (strong, nonatomic) UIButton *doneButton;
@property (strong, nonatomic) UILabel *promptLabel;

@end

@implementation TLSOSEditPasswordViewController

- (void)initView{
    self.navigationItem.title = @"更改密码";
    self.view.backgroundColor = [UIColor colorWithHexString:@"E8EBEF"];
    
    CGFloat width = 250.f;
    
    _originTextField = [self configTextFieldWithPlaceholder:@"请输入原密码"];
    _originTextField.returnKeyType = UIReturnKeyNext;
    _originTextField.maxInputLength = 25;
    [_originTextField mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(width, 50));
        make.top.equalTo(@150);
    }];
    
    _updateTextField = [self configTextFieldWithPlaceholder:@"请输入新密码"];
    _updateTextField.returnKeyType = UIReturnKeyDone;
    _updateTextField.maxInputLength = 25;
    [_updateTextField mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(width, 50));
        make.top.equalTo(_originTextField.mas_bottom).offset(20);
    }];
    
    [self.originTextField addTarget:self action:@selector(checkValid) forControlEvents:UIControlEventEditingDidEnd];
    [self.updateTextField addTarget:self action:@selector(checkValid) forControlEvents:UIControlEventEditingDidEnd];
    
    _promptLabel = [UILabel new];
    _promptLabel.text = @"6-25个字符，必须包含数字与字母，区分大小写";
    _promptLabel.textColor = [UIColor grayColor];
    _promptLabel.font = [UIFont systemFontOfSize:11];
    [self.view addSubview:_promptLabel];
    [_promptLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(self.view);
        make.left.equalTo(_originTextField);
        make.top.equalTo(_updateTextField.mas_bottom).offset(15);
    }];
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _doneButton.layer.cornerRadius = 5;
    _doneButton.layer.masksToBounds = YES;
    [_doneButton setTitle:@"确认" forState:UIControlStateNormal];
    //_doneButton.backgroundColor = [UIColor colorWithHexString:@"007AFF"];
    _doneButton.backgroundColor = [UIColor Gray185];
    
    _doneButton.tintColor = [UIColor whiteColor];
    [_doneButton addTarget:self action:@selector(doneButtonClcked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_doneButton];
    [_doneButton mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(width, 50));
        make.top.equalTo(_promptLabel.mas_bottom).offset(5);
    }];
}

- (void)checkValid
{
    if (self.originTextField.text.length > 0 && self.updateTextField.text.length > 0) {
        _doneButton.backgroundColor = [UIColor colorWithHexString:@"007AFF"];
    }else
    {
        _doneButton.backgroundColor = [UIColor Gray185];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
}

- (void)doneButtonClcked:(id)sender{
    [self.view endEditing:YES];
    NSString *originPWD = [Util trim:_originTextField];
    NSString *updatePWD = [Util trim:_updateTextField];
    if (originPWD.length <= 0) {
        [Util toastWithMessage:@"原密码不能为空"];
        return;
    }else {
        if(![Util isValidatePassword:originPWD]) {
            [Util toastWithMessage:@"原密码格式有误"];
            return;
        }
    }
    if (updatePWD.length <= 0) {
        [Util toastWithMessage:@"新密码不能为空"];
        return;
    }else {
        if(![Util isValidatePassword:updatePWD]) {
            [Util toastWithMessage:@"新密码格式有误"];
            return;
        }
        if([originPWD isEqualToString:updatePWD]) {
            [Util toastWithMessage:@"新密码与原密码不能相同"];
            return;
        }
    }
    [self requestUpdatePassword];
}

#pragma mark - http request
- (void)requestUpdatePassword{
    NSString *originPWD = [Util trim:_originTextField];
    NSString *updatePWD = [Util trim:_updateTextField];
    [SOSDaapManager sendActionInfo:Password_confirm];
    NSString *new = [SOSUtil AES128EncryptString:updatePWD];
    NSString *old = [SOSUtil AES128EncryptString:originPWD];
    //NSLog(@"加密后新密码：%@  老密码：%@",new,old);
    [AccountInfoUtil updatePassword:new OldPassword:old Success:^(NSString *response){
        [Util showAlertWithTitle:nil message:response completeBlock:^(NSInteger buttonIndex) {
            [self.navigationController popToRootViewControllerAnimated:NO];
            [[LoginManage sharedInstance] doLogout];
        }];
        
        [SOSKeyChainManager clearLoginuserNameAndPassword];
        [SOSDaapManager sendActionInfo:Password_changesucce];
        
    }Failed:^(NSString *failResponse){
        
        [Util showAlertWithTitle:nil message:failResponse completeBlock:nil];
    }];
    
}

#pragma mark - text field delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        if (textField == _originTextField) {
            [_updateTextField becomeFirstResponder];
        }else if (textField == _updateTextField) {
            [self.view endEditing:YES];
        }
        return YES;
    }
    return YES;
}

- (SOSInputTextField *)configTextFieldWithPlaceholder:(NSString *)placeholder{

    SOSInputTextField * passwordTf  = [[SOSInputTextField alloc] init];
    [passwordTf setupPasswordField];
//    [passwordTf setMaxTextLength:25];
    passwordTf.layer.masksToBounds=YES;
    passwordTf.layer.cornerRadius=4;
    passwordTf.layer.borderColor=[UIColor grayColor].CGColor;
    passwordTf.layer.borderWidth=0.5;
    passwordTf.secureTextEntry = YES;
    passwordTf.clearButtonMode=UITextFieldViewModeWhileEditing;
    //            cell.userNameTf.delegateKB=self;
    //            cell.userNameTf.maxTextLength=11;
//    passwordTf.btnPopAnimation=YES;
//    passwordTf.keyboardTypeKB=BangcleKeyboardViewTypeLetter;
    //            cell.userNameTf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    //            tempIndexPath_second = indexPath;
    passwordTf.attributedPlaceholder =[[NSAttributedString alloc] initWithString:placeholder attributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFang SC" size:16.0f],
                                                                                                                                  NSForegroundColorAttributeName:[UIColor colorWithHexString:@"C7CFD8"]}];

    passwordTf.returnKeyType = UIReturnKeyGo;
    [self.view addSubview:passwordTf];

    return passwordTf;
}
//- (SOSInputTextField *)configTextFieldWithPlaceholder:(NSString *)placeholder{
//    SOSInputTextField *textField = [SOSInputTextField new];
//    textField.delegate = self;
//    //    textField.secureTextEntry = YES;
//    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
//    textField.placeholder = placeholder;
//    textField.backgroundColor = [UIColor whiteColor];
//    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 50)];
//    paddingView.backgroundColor = [UIColor whiteColor];
//    textField.leftView = paddingView;
//    textField.leftViewMode = UITextFieldViewModeAlways;
//    CGFloat cornerRadius = 5.f;
//    UIColor *borderColor = [UIColor grayColor];
//    textField.layer.cornerRadius = cornerRadius;
//    textField.layer.borderWidth = 0.5;
//    textField.layer.borderColor = borderColor.CGColor;
//    textField.layer.masksToBounds = YES;
//    [self.view addSubview:textField];
//    [textField setupPasswordField];
//    return textField;
//}

@end
