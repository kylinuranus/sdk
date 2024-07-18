//
//  SOSLBSVerifyPasswordView.m
//  Onstar
//
//  Created by Coir on 2019/1/9.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSLBSVerifyPasswordView.h"
#import "SOSLBSAddDeviceVC.h"
#import "SOSLBSDataTool.h"

@interface SOSLBSVerifyPasswordView ()	<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *devicePasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *showPassButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *ensureButton;

@property (copy, nonatomic) completedBlock successBlock;
@property (copy, nonatomic) NNLBSDadaInfo *lbsInfo;

@end

@implementation SOSLBSVerifyPasswordView


#pragma mark - 验证设备密码
- (IBAction)ensureDevicePasswordButtonTapped:(UIButton *)sender {
    [self endEditing:YES];
    if (sender == _ensureButton) {
        [SOSDaapManager sendActionInfo:LBS_list_confirmpassword];
        if (![SOSLBSAddDeviceVC checkPassword:self.devicePasswordTextField.text]) {
            return;
        }
        //用户点击确认,开始验证密码
        [Util showHUD];
        [SOSLBSDataTool loginWithDeviceID:self.lbsInfo.deviceid AndPassword:[SOSLBSDataTool md5withDoubleSalt:self.devicePasswordTextField.text] Success:^(NSDictionary *resultFlagDic) {
            [Util dismissHUD];
            if ([resultFlagDic isKindOfClass:[NSDictionary class]]) {
                NSNumber *flag = resultFlagDic[@"verification"];
                NSString *description = resultFlagDic[@"command"];
                if (flag.boolValue == YES) {
                    // 验证密码成功
                    [SOSLBSDataTool saveDeviceLoginFlag:YES WithDeviceID:self.lbsInfo.deviceid];
                    [SOSLBSDataTool savePassword:[SOSLBSDataTool md5withDoubleSalt:self.devicePasswordTextField.text] WithDeviceID:self.lbsInfo.deviceid];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showPassBGView:NO];
                        if (self.successBlock)		self.successBlock();
                        self.successBlock = nil;
                    });
                }   else    {
                    // 密码错误
                    [SOSLBSDataTool saveDeviceLoginFlag:NO WithDeviceID:self.lbsInfo.deviceid];
                    description = description.length ? description : @"密码错误";
                    [Util toastWithMessage:description];
                }
            }
        } Failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            [Util dismissHUD];
            [SOSLBSDataTool saveDeviceLoginFlag:NO WithDeviceID:self.lbsInfo.deviceid];
            responseStr = responseStr.length ? responseStr : @"验证密码失败";
            [Util toastWithMessage:responseStr];
        }];
    }   else if (sender == _cancelButton)   {
        //用户点击取消
        [SOSDaapManager sendActionInfo:LBS_list_cancelpassword];
        [self showPassBGView:NO];
    }
}

//更改密码输入框 明文/密文 输入
- (IBAction)showPasswordButtonTapped:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.devicePasswordTextField.secureTextEntry = !sender.selected;
    self.devicePasswordTextField.clearsOnBeginEditing = !sender.selected;
}

- (void)showViewWithLBSDataInfo:(NNLBSDadaInfo *)lbsInfo VerifyPassSuccessBlock:(completedBlock)success		{
    [self showPassBGView:YES];
    if (success) 	self.successBlock = success;
    self.lbsInfo = [lbsInfo copy];
}

//显示密码输入 View
- (void)showPassBGView:(BOOL)show   {
    if (self.hidden != show)       return;
    if (show) {
        self.devicePasswordTextField.text = nil;
        self.alpha = .3;
        self.hidden = NO;
        [UIView animateWithDuration:.3 animations:^{
            self.alpha = 1;
        }   completion:^(BOOL finished) {
            [self.devicePasswordTextField becomeFirstResponder];
        }];
    }   else    {
        [UIView animateWithDuration:.3 animations:^{
            self.alpha = .3;
        } completion:^(BOOL finished) {
            self.hidden = YES;
            [self removeFromSuperview];
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField	{
    [self ensureDevicePasswordButtonTapped:self.ensureButton];
    return YES;
}

@end
