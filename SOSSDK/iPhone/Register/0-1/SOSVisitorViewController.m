//
//  SOSVisitorViewController.m
//  Onstar
//
//  Created by lizhipan on 2017/8/24.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSVisitorViewController.h"
#import "SOSInputTextField.h"
#import "RegisterUtil.h"
#import "SOSVisitorRegisterViewController.h"
#import "SOSAgreementAlertView.h"
#import "SOSAgreement.h"
#import "SOSRegisterAgreementView.h"


@interface SOSVisitorViewController ()
@property (weak, nonatomic) IBOutlet SOSInputTextField *userNameTextField;
@property (weak, nonatomic) IBOutlet SOSInputTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet SOSRegisterAgreementView *agreementView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (nonatomic, assign) BOOL userNameValid; //用户名合法
@property (nonatomic, assign) BOOL passwordValid; //密码输入合法

@property (strong, nonatomic) NSMutableArray<SOSAgreement *> *agreements;

@end

@implementation SOSVisitorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    __weak __typeof(self)weakSelf = self;
    _agreements = @[].mutableCopy;
    NSArray<NSString *> *types = @[agreementName(ONSTAR_TC), agreementName(ONSTAR_PS), agreementName(SGM_TC), agreementName(SGM_PS)];
    [self requestAgreements:types];
    _agreementView.checkState = ^(BOOL allSelected) {
        [weakSelf enableNextButton];
    };
    _agreementView.tapAgreement = ^(NSInteger line, NSInteger index) {
        [weakSelf.view endEditing:YES];
        if ((weakSelf.agreements.count < types.count && weakSelf.agreements.count > 0) || (weakSelf.agreements.count == 0)) {
            [Util toastWithMessage:@"获取协议内容错误"];
            return;
        }
        SOSAgreement *agreement = weakSelf.agreements[line + index];
        SOSAgreementAlertView *view = [[SOSAgreementAlertView alloc] initWithAlertViewStyle:SOSAgreementAlertViewStyleSignUp];
        view.agreements = @[agreement];
        [view show];
    };
}

- (void)configUI {
//    self.title = @"非安吉星车主注册";
    self.title = @"非安吉星车主注册";
    self.userNameTextField.normalText = NSLocalizedString(@"5to203", nil);
    self.userNameTextField.placeholder = NSLocalizedString(@"SB021-55", nil);
    self.edgesForExtendedLayout = UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
    [SOSUtil setButtonStateDisableWithButton:self.nextButton];

    self.userNameTextField.inputStatus = SOSInputViewStatusNormal;
    
    self.passwordTextField.placeholder = NSLocalizedString(@"SB021-56", nil);
    self.passwordTextField.normalText = NSLocalizedString(@"6to20", nil);
    self.passwordTextField.inputStatus = SOSInputViewStatusNormal;
    [self.passwordTextField setupPasswordField];
    
    __weak __typeof(self) weakSelf = self;
    [[self.userNameTextField rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
        if (x.length <= 0) {
            [weakSelf setNextBtnStatuWithTf];
            return;
        }
        
//        weakSelf.userNameValid = NO;
//        if ([weakSelf checkValidUserName]) {
//            weakSelf.userNameTextField.inputStatus = SOSInputViewStatusChecking;
////            //验证服务器
////            [weakSelf checkUserNameRequest];
//        }    else    {
//            weakSelf.userNameTextField.errorText = NSLocalizedString(@"usernameFormat", nil);
//            weakSelf.userNameTextField.inputStatus = SOSInputViewStatusError;
//        }
    }];
    [[self.userNameTextField rac_signalForControlEvents:UIControlEventEditingDidEnd] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [weakSelf checkValid:weakSelf.userNameTextField];
    }];
//    [[self.passwordTextField rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
//        [weakSelf checkValid:weakSelf.passwordTextField];
//    }];
    [[self.passwordTextField rac_signalForControlEvents:UIControlEventEditingDidEnd] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [weakSelf checkValid:weakSelf.passwordTextField];
    }];
}




#pragma mark setter
- (void)setUserNameValid:(BOOL)userNameValid {
    _userNameValid = userNameValid;
    [self enableNextButton];
}

- (void)setPasswordValid:(BOOL)passwordValid {
    _passwordValid = passwordValid;
    [self enableNextButton];
}

#pragma mark request

/**
 获取协议
 
 @param types 协议s
 */
- (void)requestAgreements:(NSArray<NSString *> *)types {
    [SOSAgreement requestAgreementsWithTypes:types success:^(NSDictionary *response) {
        [types enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([response.allKeys containsObject:obj]) {
                SOSAgreement *model = [SOSAgreement mj_objectWithKeyValues:response[obj]];
                [_agreements addObject:model];
            }
        }];
    } fail:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util toastWithMessage:@"获取协议内容失败"];
    }];
}


- (void)checkUserNameRequest {
    NNRegisterRequest *regRequest = [[NNRegisterRequest alloc]init];
    [regRequest setSourceId:[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]];
    [regRequest setUserName:[Util trim:self.userNameTextField]];
    NSString *url = [BASE_URL stringByAppendingString:NEW_REGISTER_CHECK_UNIQUE];
    NSString *json = [regRequest mj_JSONString];
     [RegisterUtil registAsVisitor:url paragramString:json successHandler:^(NNRegisterResponse *regRes) {
         dispatch_async(dispatch_get_main_queue(), ^{
             BOOL isUserNameUnique = [regRes.isUserNameUnique boolValue];
             if (isUserNameUnique) {
                 self.userNameTextField.inputStatus = SOSInputViewStatusSuccess;
                 self.userNameValid = YES;
             }else {
                 [self.userNameTextField showError:NSLocalizedString(@"userExist", nil)];
                 self.userNameValid = NO;
             }
             if ([self isSame]) {
                 [self.passwordTextField showError:NSLocalizedString(@"用户名与密码不能一致", nil)];
             }
         });
         
     } failureHandler:^(NSString *responseStr, NSError *error) {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.userNameTextField showError:@"网络错误"];
             self.userNameValid = NO;
         });
         [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
     }];

}


#pragma mark action
/**
 失去焦点后检测用户名
 */
- (void)checkValid:(UITextField *)textField {
    NSLog(@"%@", textField.text);
    if (textField.text.length <= 0) {
        [self setNextBtnStatuWithTf];
        return;
    }
    //TO DO
    if (textField == self.userNameTextField) {
        if ([self checkValidUserName]) {
            self.userNameTextField.inputStatus = SOSInputViewStatusChecking;
            //验证服务器
            [self checkUserNameRequest];
        }else {
            self.userNameValid = NO;
            self.userNameTextField.errorText = NSLocalizedString(@"usernameFormat", nil);
            self.userNameTextField.inputStatus = SOSInputViewStatusError;
        }
    }else if (textField == self.passwordTextField) {
        self.passwordValid = [self checkValidPassword];
        if (self.passwordValid) {
            if ([self isSame]) {
                [self.passwordTextField showError:NSLocalizedString(@"用户名与密码不能一致", nil)];
            }
        }else {
            [self.passwordTextField showError:NSLocalizedString(@"passwordFormat", nil)];
        }
    }
}


- (BOOL)isSame
{
    return [self.userNameTextField.text isEqualToString:self.passwordTextField.text] ? YES : NO;
}


- (void)setNextBtnStatuWithTf
{
    if (self.userNameTextField.text.length < 1 || self.passwordTextField.text.length < 1 ) {
        [SOSUtil setButtonStateDisableWithButton:self.nextButton];
    }
}

/**
 正则检测用户名是否合法
 */
- (BOOL)checkValidUserName {
    if ([[Util trim:self.userNameTextField] length] < 1) {
        return NO;
    }
    
    return [Util isValidateUserName:self.userNameTextField.text];
}

/**
 正则检测密码是否合法
 */
- (BOOL)checkValidPassword {
    if ([[Util trim:self.passwordTextField] length] < 1) {
        return NO;
    }
    
    return [Util isValidatePassword:self.passwordTextField.text];
}

- (void)enableNextButton {
    if (!_agreementView.isAllSelected) {
        [SOSUtil setButtonStateDisableWithButton:self.nextButton];
        return;
    }
    if (self.passwordValid && self.userNameValid) {
        [SOSUtil setButtonStateEnableWithButton:self.nextButton];
    }else {
        [SOSUtil setButtonStateDisableWithButton:self.nextButton];
    }
}

- (IBAction)nextButtonClicked:(id)sender {
    NSString * uName = [Util trim:self.userNameTextField];
    NSString * pWord = [Util trim:self.passwordTextField];
    if (![uName isEqualToString:pWord]) {
        SOSVisitorRegisterViewController *nextVc = [SOSVisitorRegisterViewController new];
        nextVc.userName = uName;
        nextVc.password = pWord;
        [self.navigationController pushViewController:nextVc animated:YES];
    }
    else
    {
        [Util toastWithMessage:NSLocalizedString(@"SB021_MSG026", nil)];
    }
}



@end
