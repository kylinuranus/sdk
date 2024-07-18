//
//  SOSGeoModifyNameVC.m
//  Onstar
//
//  Created by Coir on 2019/6/20.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSGeoModifyNameVC.h"
#import "SOSGeoDataTool.h"

@interface SOSGeoModifyNameVC ()
@property (weak, nonatomic) IBOutlet UITextField *geoNameTextField;

@end

@implementation SOSGeoModifyNameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = NO;
    self.title = @"更改围栏名称";
    self.geoNameTextField.maxInputLength = 20;
    [self.geoNameTextField setChineseAndCharactorFilter];
    [self.geoNameTextField setSuppressibleKeyboard];
    __weak __typeof(self) weakSelf = self;
    [self setRightBarButtonItemWithTitle:@"保存" AndActionBlock:^(id item) {
        if ([weakSelf checkGeoName]) {
            [weakSelf saveGeofenceChange];
        }
    }];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"common_Nav_Back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
}

- (void)back 	{
    // 输入框不为空且与原本围栏名称不同
    if (self.geoNameTextField.text.length && ![self.geoNameTextField.text isEqualToString:self.geofence.geoFencingName]) {
        [Util showAlertWithTitle:@"是否保存设置？" message:nil completeBlock:^(NSInteger buttonIndex) {
            if (buttonIndex) {
                [self saveGeofenceChange];
            }    else    {
                [self.navigationController popViewControllerAnimated:YES];
            }
        } cancleButtonTitle:@"丢弃" otherButtonTitles:@"保存", nil];
    }    else    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated	{
    [super viewWillAppear:animated];
    self.geoNameTextField.text = self.geofence.geoFencingName;
}

- (IBAction)clearTextInput {
    self.geoNameTextField.text = @"";
    [self.geoNameTextField becomeFirstResponder];
}

- (BOOL)checkGeoName	{
    if ([Util trim:self.geoNameTextField].length < 1) {
        [Util toastWithMessage:@"请输入电子围栏名称"];
        return NO;
    }
    return YES;
}

- (void)saveGeofenceChange	{
    if ([self.geoNameTextField.text isEqualToString:self.geofence.geoFencingName]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    self.geofence.geoFencingName = self.geoNameTextField.text;
    if (self.geofence.isNewToAdd) {
        // 新建围栏时,返回上一级页面保存
        [[NSNotificationCenter defaultCenter] postNotificationName:SOSNotifacationChangeGeo object:@{@"Type": @(SOSChangeGeoType_Update_Name), @"Geofence":[self.geofence copy]}];
        [self.navigationController popViewControllerAnimated:YES];
    }    else    {
        // 编辑围栏时,需实时保存
        [Util showHUD];
        [SOSGeoDataTool updateGeoFencingWithGeo:self.geofence Success:^(SOSNetworkOperation *operation, id responseStr) {
            [Util dismissHUD];
            [Util showSuccessHUDWithStatus:@"围栏更新成功"];
            [[NSNotificationCenter defaultCenter] postNotificationName:SOSNotifacationChangeGeo object:@{@"Type": @(SOSChangeGeoType_Update_Name), @"Geofence":[self.geofence copy], @"ShouldChangeLocal": @(YES)}];
            [self.navigationController popViewControllerAnimated:YES];
        } Failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            [Util dismissHUD];
            [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
        }];
    }
}

- (void)dealloc		{
    [Util dismissHUD];
}

@end
