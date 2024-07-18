//
//  SOSOnstarLinkBindPhoneVC.m
//  Onstar
//
//  Created by Coir on 2018/7/30.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//


#import "SOSCustomAlertView.h"
#import "SOSAYChargeManager.h"
#import "AccountInfoUtil.h"
#import "LoadingView.h"
#import "SOSOnstarLinkBindPhoneVC.h"
#ifndef SOSSDK_SDK
#import "SOSSmartHomeEntranceViewController.h"
#import "SOSOnstarLinkSDKTool.h"
#endif
#import "SOSOnstarLinkDataTool.h"

@interface SOSOnstarLinkBindPhoneVC ()	<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTextField;
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *getVerificationButton;
@property (weak, nonatomic) IBOutlet UIButton *bindButton;

@property (strong, nonatomic) dispatch_source_t verifacationTimer;
@property (copy, nonatomic) NSString *userInputPhoneNum;
@property (assign, nonatomic) int timerCount;

@end

@implementation SOSOnstarLinkBindPhoneVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configSelf];
    switch (self.pageType) {
        case OnstarLinkBindPhonePageType_bind:
            self.title = @"绑定服务手机号";
            break;
        case OnstarLinkBindPhonePageType_modify:
            self.title = @"修改服务手机号";
            self.instructionLabel.text = [NSString stringWithFormat:@"原服务手机号 %@", [Util maskMobilePhone:[SOSOnstarLinkDataTool sharedInstance].dataModel.mobile]];
            break;
        case SOSAYBindPhone:
        case SOSBLEBindPhone:
			self.title = @"绑定手机号";
            self.phoneNumTextField.placeholder = @"请输入手机号";
            self.instructionLabel.text = @"您尚未绑定手机号,请先绑定后使用";
            self.backDaapFunctionID = Map_POIdetail_anyocharging_Authorization_Agree_BindPhoneNum_Back;
            break;
        default:
            self.title = @"绑定服务手机号";
            break;
    }
}

- (void)configSelf	{
    [self.bindButton setBackgroundColor:[UIColor colorWithHexString:@"007AFF"] forState:UIControlStateNormal];
    [self.bindButton setBackgroundColor:[UIColor colorWithHexString:@"BFBFBF"] forState:UIControlStateDisabled];
    [self.getVerificationButton setBackgroundColor:[UIColor colorWithHexString:@"DEDEDE"] forState:UIControlStateDisabled];
    self.phoneNumTextField.maxInputLength = 13;
    self.verificationCodeTextField.maxInputLength = 6;
    [self.phoneNumTextField.rac_textSignal subscribeNext:^(NSString *x) {
        // 输入电话号码时在第3位和第8位加空格
        NSMutableString *pureStr = [[self.phoneNumTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] mutableCopy];
        self.userInputPhoneNum = pureStr;
        if (pureStr.length <= 3)	{
            self.phoneNumTextField.text = pureStr;
        }	else if (pureStr.length > 3 && pureStr.length < 8) {
            [pureStr insertString:@" " atIndex:3];
            self.phoneNumTextField.text = pureStr;
        }	else if (pureStr.length >= 8)	{
            [pureStr insertString:@" " atIndex:3];
            [pureStr insertString:@" " atIndex:8];
            self.phoneNumTextField.text = pureStr;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - TextField Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (!string.length)		return YES;
    self.bindButton.enabled = self.phoneNumTextField.text.length && self.verificationCodeTextField.text.length;
    if ([Util isNumeber:[string stringByReplacingOccurrencesOfString:@" " withString:@""]])		return YES;
    else							return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField	{
    if (self.pageType == SOSAYBindPhone || self.pageType == SOSBLEBindPhone ) {
        if (textField == _phoneNumTextField) {
            [SOSDaapManager sendActionInfo:Map_POIdetail_anyocharging_Authorization_Agree_BindPhoneNum_EnterPhoneNum];
        }	else if (textField == _verificationCodeTextField)	{
            [SOSDaapManager sendActionInfo:Map_POIdetail_anyocharging_Authorization_Agree_BindPhoneNum_EnterVerificationCode];
        }
    }
}

/// 获取验证码
- (IBAction)getVerificationCodeButtonTapped 	{
    if ([Util isValidatePhone:self.userInputPhoneNum]) {
        [self.view endEditing:YES];
        [[LoadingView sharedInstance] startIn:self.view];
        // 安悦充电 获取验证码
        if (self.pageType == SOSAYBindPhone || self.pageType == SOSBLEBindPhone) {
            [SOSDaapManager sendActionInfo:Map_POIdetail_anyocharging_Authorization_Agree_BindPhoneNum_GetVerificationCode];
            [SOSAYChargeManager getAYUserVerifyCodeWithMobileNum:self.userInputPhoneNum Success:^(SOSNetworkOperation *operation, id responseStr) {
                [[LoadingView sharedInstance] stop];
                
                if ([responseStr isKindOfClass:[NSString class]] && [responseStr length]) {
                    NSDictionary *resDic = [responseStr mj_JSONObject];
                    if (resDic.count) {
                        NSDictionary *dataDic = resDic[@"data"];
                        if ([dataDic isKindOfClass:[NSDictionary class]] && dataDic.count) {
                            if ([dataDic[@"statusCode"] isEqualToString:@"200"]) {
                                self.getVerificationButton.tag = 999;
#if DEBUG
                                NSString *resultStr = dataDic[@"result"];
                                [Util toastWithMessage:[NSString stringWithFormat:@"验证码发送成功:%@", resultStr]];
#else
                                [Util toastWithMessage:@"验证码发送成功"];
#endif
                                
                                dispatch_async_on_main_queue(^{
                                    [self resetTimer];
                                    [self.verificationCodeTextField becomeFirstResponder];
                                });
                                return;
                            }
                        }
                    }
                }
                [Util toastWithMessage:@"验证码发送失败"];
            } failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                [[LoadingView sharedInstance] stop];
                [Util toastWithMessage:@"验证码发送失败"];
            }];
            return;
        }
        
        [SOSOnstarLinkDataTool sendVerificationCodeWithPhoneNum:self.userInputPhoneNum  Success:^(NSDictionary *result) {
            [[LoadingView sharedInstance] stop];
            if (result.count)	{
                NSDictionary *dataDic = result[@"data"];
                if (dataDic.count)	{
#if DEBUG
                    [Util toastWithMessage:[NSString stringWithFormat:@"验证码发送成功:%@", dataDic[@"result"]]];
#else
                    [Util toastWithMessage:@"验证码发送成功"];
#endif
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self resetTimer];
                [self.verificationCodeTextField becomeFirstResponder];
            });
            
        } Failure:^(NSString *responseStr, NSError *error) {
            [[LoadingView sharedInstance] stop];
            [Util toastWithMessage:@"验证码发送失败"];
        }];
    }    else    {
        if (self.pageType == SOSAYBindPhone || self.pageType == SOSBLEBindPhone)	[Util toastWithMessage:@"手机号输入有误"];
        else									[Util toastWithMessage:@"手机号码格式错误"];
    }
}

/// 配置 Timer
- (void)resetTimer 		{
    self.timerCount = 59;
    self.getVerificationButton.enabled = NO;
    [self.getVerificationButton.layer setBorderColor:[UIColor clearColor].CGColor];
    if (self.verifacationTimer) dispatch_cancel(self.verifacationTimer);
    __weak __typeof(self) weakSelf = self;
    self.verifacationTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(self.verifacationTimer, dispatch_walltime(NULL, 0), 1 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(self.verifacationTimer, ^{
        if (weakSelf.timerCount > 0) {
            NSString *titleStr = [NSString stringWithFormat:@"%@s后重新获取", @(weakSelf.timerCount)];
            weakSelf.getVerificationButton.titleLabel.text = titleStr;
            [weakSelf.getVerificationButton setTitle:titleStr forState:UIControlStateDisabled];
            weakSelf.timerCount --;
        }	else	{
            self.getVerificationButton.enabled = YES;
            [self.getVerificationButton setTitleForNormalState:@"重新发送"];
            [self.getVerificationButton.layer setBorderColor:[UIColor colorWithHexString:@"007AFF"].CGColor];
            dispatch_cancel(weakSelf.verifacationTimer);
        }
    });
    // 启动定时器
    dispatch_resume(self.verifacationTimer);
}

/// 绑定按钮点击
- (IBAction)bindButtonTapped {
    if (self.pageType == OnstarLinkBindPhonePageType_modify)	[SOSDaapManager sendActionInfo:Onstarlink_phoneno_modify_bound];
    if ([Util isValidatePhone:self.userInputPhoneNum]) {
        [self.view endEditing:YES];
        [[LoadingView sharedInstance] startIn:self.view];
        
        // 安悦充电绑定手机号
        if (self.pageType == SOSAYBindPhone || self.pageType == SOSBLEBindPhone) {
            [SOSDaapManager sendActionInfo:Map_POIdetail_anyocharging_Authorization_Agree_BindPhoneNum_Bind];
            [AccountInfoUtil updateMobileEmailWithoutLoadingView:self.userInputPhoneNum withIDpid:[CustomerInfo sharedInstance].userBasicInfo.idpUserId ValidateCode:self.verificationCodeTextField.text needAlertError:NO Success:^(NNRegisterResponse *response) {
                [[LoadingView sharedInstance] stop];
                if ([response.code isEqualToString:@"E3311"]) {
                    [self showAlertViewWithTitle:@"绑定成功" detailText:@"您的手机号绑定操作已完成" cancelButtonTitle:@"知道了" otherButtonTitles:nil ButtonClickHandle:^(NSInteger index) {
                        [SOSDaapManager sendActionInfo:Map_POIdetail_anyocharging_Authorization_Agree_BindPhoneNum_Bind_Success_OK];
                        !self.operationSuccessBlock ? nil : self.operationSuccessBlock(self.userInputPhoneNum);
                    }];
                }	else	{
                    [self showAlertViewWithTitle:@"绑定失败" detailText:@"绑定手机号操作失败,请稍后重试" cancelButtonTitle:@"知道了" otherButtonTitles:nil ButtonClickHandle:^(NSInteger index) {
                        [SOSDaapManager sendActionInfo:Map_POIdetail_anyocharging_Authorization_Agree_BindPhoneNum_Bind_Fail_OK];
                    }];
                }
            } Failed:^(NSString *errorStr){
                [[LoadingView sharedInstance] stop];
                if ([errorStr isKindOfClass:[NSString class]] && errorStr.length) {
                    NSDictionary *errorDic = [errorStr mj_JSONObject];
                    if ([errorDic isKindOfClass:[NSDictionary class]] && errorDic.count) {
                        NSString *code = errorDic[@"errorCode"];
                        if (code.length) {
                            if ([code isEqualToString:@"E3314"]) {
                                [Util toastWithMessage:@"验证码输入有误"];
                                return;
                            }	else if ([code isEqualToString:@"E3323"])	{
                                NSString *message = @"该手机号已被绑定\n请使用其它号码,进行绑定操作";
                                if (self.pageType == SOSBLEBindPhone) {
                                    message = @"该手机号已被其他用户绑定为服务手机号\n请使用其它号码进行绑定操作";
                                }
                                
                                [self showAlertViewWithTitle:@"已被使用" detailText:message cancelButtonTitle:@"知道了" otherButtonTitles:nil ButtonClickHandle:^(NSInteger index) {
                                    [SOSDaapManager sendActionInfo:Map_POIdetail_anyocharging_Authorization_Agree_BindPhoneNum_Bind_Used_OK];
                                }];
                                return;
                            }	else if ([code isEqualToString:@"E3324"]) {
                                [Util toastWithMessage:@"验证码已失效"];
                                return;
                            }
                        }
                    }
                }
                [self showAlertViewWithTitle:@"绑定失败" detailText:@"绑定手机号操作失败,请稍后重试" cancelButtonTitle:@"知道了" otherButtonTitles:nil ButtonClickHandle:nil];
            }];
            return;
        }
        
        // 校验验证码
        [SOSOnstarLinkDataTool checkVerificationCodeWithPhoneNum:self.userInputPhoneNum AndVerificationCode:self.verificationCodeTextField.text Success:^(NSDictionary *responseDic) {
            if (responseDic.count) {
                NSDictionary *dataDic = responseDic[@"data"];
                if (dataDic.count) {
                    NSString *resultStr = dataDic[@"result"];
                    if ([resultStr isEqualToString:@"false"]) {
                        [[LoadingView sharedInstance] stop];
                        [Util toastWithMessage:@"验证码校验失败"];
                    }    else if ([resultStr isEqualToString:@"true"])    {
                        [self bindPhoneNum];
                    }
                }
            }
        } Failure:^(NSString *responseStr, NSError *error) {
            [[LoadingView sharedInstance] stop];
            NSDictionary *errorDic = responseStr.mj_JSONObject;
            if ([errorDic isKindOfClass:[NSDictionary class]]) {
                NSString *message = errorDic[@"errorMessage"];
                if (message.length) {
                    [Util toastWithMessage:message];
                }
            }
        }];
    }    else    {
        if (self.pageType == SOSAYBindPhone || self.pageType == SOSBLEBindPhone )    [Util toastWithMessage:@"手机号输入有误"];
        else                                    [Util toastWithMessage:@"手机号码格式错误"];
    }
}

/// 绑定接口调用与逻辑实现
- (void)bindPhoneNum		{
    [SOSOnstarLinkDataTool bindOnstarInfoWithPhoneNum:self.userInputPhoneNum IsModify:self.pageType == OnstarLinkBindPhonePageType_modify Success:^(NSDictionary *result) {
        [[LoadingView sharedInstance] stop];
//        [SOSOnstarLinkDataTool sharedInstance].dataModel.mobile = self.userInputPhoneNum;
        [Util toastWithMessage:@"绑定成功"];
        !self.operationSuccessBlock?:self.operationSuccessBlock(self.userInputPhoneNum);
    } Failure:^(NSString *responseStr, NSError *error) {
        [[LoadingView sharedInstance] stop];
    }];
}

- (void)showAlertViewWithTitle:(NSString *)title detailText:(NSString *)detailtext cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonsTitles ButtonClickHandle:(void (^)(NSInteger index))buttonClickHandle	{
    SOSCustomAlertView *view = [[SOSCustomAlertView alloc] initWithTitle:title detailText:detailtext cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonsTitles canTapBackgroundHide:YES];
    view.buttonMode = SOSAlertButtonModelHorizontal;
    [view setButtonClickHandle:buttonClickHandle];
    [view show];
}

@end
