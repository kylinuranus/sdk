//
//  SOSLBSChangePasswordVC.m
//  Onstar
//
//  Created by Coir on 25/10/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSLBSHeader.h"
#import "LoadingView.h"
#import "SOSLBSChangePasswordVC.h"

@interface SOSLBSChangePasswordVC ()    {
    
    __weak IBOutlet UITextField *originPassTextField;
    __weak IBOutlet UITextField *newPassTextField;
    __weak IBOutlet UIButton *ensureButton;
    
}
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;

@end

@implementation SOSLBSChangePasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改设备密码";
    self.backRecordFunctionID = LBS_setting_password_back;
    [ensureButton setBackgroundColor:[UIColor colorWithHexString:@"C4C4C9"] forState:UIControlStateNormal];
    [ensureButton setBackgroundColor:[UIColor colorWithHexString:@"6896ED"] forState:UIControlStateSelected];
    originPassTextField.maxInputLength = 25;
    newPassTextField.maxInputLength = 25;
    self.deviceNameLabel.text = self.lbsInfo.devicename;
    [[originPassTextField rac_textSignal] subscribeNext:^(NSString *x) {
        ensureButton.selected = (originPassTextField.text.length && newPassTextField.text.length);
    }];
    [[newPassTextField rac_textSignal] subscribeNext:^(NSString *x) {
        ensureButton.selected = (originPassTextField.text.length && newPassTextField.text.length);
    }];
}

- (IBAction)ensureButtonTapped {
    if ([SOSLBSAddDeviceVC checkPassword:originPassTextField.text] && [SOSLBSAddDeviceVC checkPassword:newPassTextField.text]) {
        if (![SOSLBSDataTool checkPassword:originPassTextField.text WithDeviceID:self.lbsInfo.deviceid]) {
            [Util toastWithMessage:@"原密码输入错误"];
            return;
        }
        [[LoadingView sharedInstance] startIn:self.view];
        self.lbsInfo.password = [SOSLBSDataTool md5withDoubleSalt:newPassTextField.text];
        [SOSDaapManager sendActionInfo:LBS_setting_password_confirm];
        [SOSLBSDataTool updateDeviceWithLBSDadaInfo:self.lbsInfo Success:^(NNLBSDadaInfo *lbsInfo, NSString *description) {
            [[LoadingView sharedInstance] stop];
            dispatch_async(dispatch_get_main_queue(), ^{
                [Util showSuccessHUDWithStatus:@"修改成功"];
                [[NSNotificationCenter defaultCenter] postNotificationName:KSOSLBSInfoChangeNoti object:lbsInfo];
                [self.navigationController popViewControllerAnimated:YES];
            });
        } Failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            [[LoadingView sharedInstance] stop];
            if (responseStr)    [Util toastWithMessage:responseStr];
        }];
    }
}

@end
