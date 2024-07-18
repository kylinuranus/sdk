//
//  SOSLBSSettingVC.m
//  Onstar
//
//  Created by Coir on 25/10/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSLBSHeader.h"
#import "SOSLBSSettingVC.h"
#import "SOSCustomAlertView.h"
#import "SOSLBSChangePasswordVC.h"

@interface SOSLBSSettingVC () <SOSAlertViewDelegate>

@property (strong, nonatomic) SOSLBSDataTool *dataTool;
@property (weak, nonatomic) IBOutlet UITextField *deviceNameTextField;

@end

@implementation SOSLBSSettingVC

- (void)viewDidLoad     {
    [super viewDidLoad];
    self.title = @"设备设置";
    _dataTool = [SOSLBSDataTool new];
    _deviceNameTextField.text = self.lbsInfo.devicename;
    [_deviceNameTextField setChineseAndCharactorFilter];
    _deviceNameTextField.maxInputCStringLength = 40;
    self.backRecordFunctionID = LBS_list_deviceinfo_setting_back;
    __weak __typeof(self) weakSelf = self;
    [self setRightBarButtonItemWithTitle:@"保存" AndActionBlock:^(id item) {
        [weakSelf ensureDeviceNameChange];
    }];
    
    //同步密码修改
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:KSOSLBSInfoChangeNoti object:nil] subscribeNext:^(NSNotification *noti) {
        self.lbsInfo = noti.object;
    }];
}

- (void)ensureDeviceNameChange      {
    [self.view endEditing:YES];
    //无修改直接返回
    if ([self.lbsInfo.devicename isEqualToString:self.deviceNameTextField.text]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    //检测输入用户名
    if (![SOSLBSAddDeviceVC checkDeviceName:self.deviceNameTextField.text]) {
        return;
    }
    [SOSDaapManager sendActionInfo:LBS_list_deviceinfo_setting_removedevice];
    [Util showAlertWithTitle:@"是否保存设置？" message:nil completeBlock:^(NSInteger buttonIndex) {
        if (buttonIndex) {
            //确认修改设备名
            self.lbsInfo.devicename = self.deviceNameTextField.text;
            [Util showHUD];
            [SOSLBSDataTool updateDeviceWithLBSDadaInfo:self.lbsInfo Success:^(NNLBSDadaInfo *lbsInfo, NSString *description) {
                [Util dismissHUD];
                //通知地图页 LBS 信息变更
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:KSOSLBSInfoChangeNoti object:lbsInfo];
                    [self.navigationController popViewControllerAnimated:YES];
                });
            } Failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                [Util showErrorHUDWithStatus:responseStr];
            }];
        }   else    {
            //        [self.navigationController popViewControllerAnimated:YES];
        }
    } cancleButtonTitle:@"取消" otherButtonTitles:@"保存", nil];
}

- (IBAction)changePassword:(UITapGestureRecognizer *)sender {
    [SOSDaapManager sendActionInfo:LBS_list_deviceinfo_setting_password];
    //修改密码
    SOSLBSChangePasswordVC *vc = [SOSLBSChangePasswordVC new];
    vc.lbsInfo = self.lbsInfo;
    vc.lbsPOI = self.lbsPOI;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)deleteDeviceButtonTapped {
    NNLBSDadaInfo *lbsInfo = self.lbsInfo;
    
    [Util showAlertWithTitle:[NSString stringWithFormat:@"确定要解绑“%@”设备吗？", lbsInfo.devicename] message:nil completeBlock:^(NSInteger buttonIndex) {
        if (buttonIndex) {
            [SOSDaapManager sendActionInfo:LBS_setting_removedevice_confirm];
            [Util showHUD];
            lbsInfo.status = @"0";
            //删除 LBS 设备
            [SOSLBSDataTool updateDeviceWithLBSDadaInfo:lbsInfo Success:^(NNLBSDadaInfo *lbsInfo, NSString *description) {
                [Util dismissHUD];
                
                //通知地图页 LBS 信息变更
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:KSOSLBSInfoDeleteNoti object:lbsInfo];
                    [self.navigationController popViewControllerAnimated:YES];
                });
                
            } Failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                if (responseStr)    [Util showErrorHUDWithStatus:responseStr];
            }];
        }	else	{
            [SOSDaapManager sendActionInfo:LBS_setting_removedevice_cancel];
        }
    } cancleButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
}

@end
