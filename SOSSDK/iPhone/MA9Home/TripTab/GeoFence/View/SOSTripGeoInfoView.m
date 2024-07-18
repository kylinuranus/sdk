//
//  SOSTripGeoInfoView.m
//  Onstar
//
//  Created by Coir on 2019/6/12.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSSwitch.h"
#import "SOSGeoDataTool.h"
#import "SOSTripGeoInfoView.h"
#import "SOSGeoModifyNameVC.h"
#import "SOSGeoModifyAlertTypeVC.h"

@interface SOSTripGeoInfoView () <SOSSwitchDelegate>

@property (weak, nonatomic) IBOutlet SOSSwitch *geoSwitch;
@property (weak, nonatomic) IBOutlet UILabel *geoNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (weak, nonatomic) IBOutlet UILabel *geoReminderLabel;
@property (weak, nonatomic) IBOutlet UILabel *lbsDeviceNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *geoNameEditButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameEditButtonTraiilingGuide;

@end

@implementation SOSTripGeoInfoView

- (void)awakeFromNib	{
    [super awakeFromNib];
    self.geoSwitch.delegate = self;
}

- (void)setGeofence:(NNGeoFence *)geofence	{
    _geofence = [geofence copy];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.geoSwitch.on = [geofence.geoFencingStatus isEqualToString:@"ON"];
        NSString *mobile = geofence.getGeoMobile;
        if (mobile.length) {
            self.geoReminderLabel.textColor = [UIColor colorWithHexString:@"828389"];
            self.geoReminderLabel.text = [geofence.alertType isEqualToString:@"IN"] ? @"进围栏提醒" : @"出围栏提醒";
        }    else    {
            self.geoReminderLabel.textColor = [UIColor colorWithHexString:@"C50000"];
            self.geoReminderLabel.text = @"未设置";
        }
        if (geofence.isLBSMode) {
            self.geoNameLabel.text = @"电子围栏";
            self.geoNameEditButton.hidden = YES;
            self.lbsDeviceNameLabel.hidden = NO;
            self.lbsDeviceNameLabel.text = ((NNLBSGeoFence *)geofence).LBSDeviceName;
        }	else	{
            self.geoNameLabel.text = geofence.geoFencingName;
            self.lbsDeviceNameLabel.hidden = YES;
            self.geoNameEditButton.hidden = NO;
        }
        [self configFinishButton];
    });
}

- (void)configFinishButton	{
    if (self.geofence.isNewToAdd) {
        self.finishButton.hidden = NO;
        self.nameEditButtonTraiilingGuide.constant = 54.f;
        if (self.geofence.isLBSMode) {
            NNLBSGeoFence *lbsGeofence = (NNLBSGeoFence *)self.geofence;
            self.finishButton.enabled = lbsGeofence.mobile.length;
        }    else    {
            self.finishButton.enabled = self.geofence.mobilePhone.length;
        }
    }    else    {
        self.finishButton.hidden = YES;
        self.nameEditButtonTraiilingGuide.constant = 16.f;
    }
    [self layoutIfNeeded];
}

// 返回
- (IBAction)backButtonTapped {
    [self.viewController.navigationController popViewControllerAnimated:YES];
}

// 修改围栏名称
- (IBAction)changeGeoName 	{
    SOSGeoModifyNameVC *vc = [SOSGeoModifyNameVC new];
    vc.geofence = self.geofence;
    [self.viewController.navigationController pushViewController:vc animated:YES];
}

// 完成
- (IBAction)finishButtonTapped {
    if ([SOSGeoDataTool checkGeoInfoWithGeofence:self.geofence] == NO)		return;
    // 完成按钮出现时一定是新建围栏模式
    [Util showHUD];
    [SOSGeoDataTool updateGeoFencingWithGeo:self.geofence isLBSMode:self.geofence.isLBSMode Success:^(SOSNetworkOperation *operation, id responseStr) {
        [Util dismissHUD];
        [Util showSuccessHUDWithStatus:@"围栏添加成功"];
        self.geofence.isNewToAdd = NO;
        [self configFinishButton];
        [[NSNotificationCenter defaultCenter] postNotificationName:SOSNotifacationChangeGeo object:@{@"Type": @(SOSChangeGeoType_Update_Geo), @"Geofence":[self.geofence copy], @"ShouldChangeLocal": @(YES)}];
    } Failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util dismissHUD];
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
    }];
}

// 围栏开关
- (void)sosSwitchValueChanged:(SOSSwitch *)sosSwitch	{
    if (self.geofence.isLBSMode)        [SOSDaapManager sendActionInfo:LBS_setting_geofence_remind];
    // 关闭围栏需弹框确认,打开围栏时直接发请求
    if (sosSwitch.isOn)            [self changeGeoStateWithSwitch:sosSwitch];
    else    {
        [Util showAlertWithTitle:@"确定关闭电子围栏吗？" message:@"关闭后，您将不会收到设备进出围栏的提醒。" completeBlock:^(NSInteger buttonIndex) {
            if (buttonIndex)        [self changeGeoStateWithSwitch:sosSwitch];
            else                    sosSwitch.on = !sosSwitch.isOn;
        } cancleButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    }
}

// 发送关闭/打开围栏 网络请求
- (void)changeGeoStateWithSwitch:(SOSSwitch *)statusSwitch    {
    [Util showHUD];
    self.userInteractionEnabled = NO;
    NNGeoFence *tempGeofence = [self.geofence copy];
    tempGeofence.operationType = @"UPDATE";
    
    if (statusSwitch.on == YES) {
        [SOSDaapManager sendActionInfo:Map_geofence_on];
        tempGeofence.geoFencingStatus = @"ON";
    }   else    {
        [SOSDaapManager sendActionInfo:Map_geofence_off];
        tempGeofence.geoFencingStatus = @"OFF";
    }
    
    [SOSGeoDataTool updateGeoFencingWithGeo:tempGeofence isLBSMode:tempGeofence.isLBSMode Success:^(SOSNetworkOperation *operation, id responseStr) {
        [Util dismissHUD];
        self.userInteractionEnabled = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:SOSNotifacationChangeGeo object:@{@"Type": @(SOSChangeGeoType_Update_Switch), @"Geofence":tempGeofence, @"ShouldChangeLocal": @(YES)}];
        [Util showSuccessHUDWithStatus:@"围栏更新成功"];
    } Failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util dismissHUD];
        self.userInteractionEnabled = YES;
        statusSwitch.on = !statusSwitch.isOn;
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
    }];
}

// 修改围栏中心点和半径
- (IBAction)changeGEOCenterAndRidus {
    if (self.delegate && [self.delegate respondsToSelector:@selector(geoRadiusButtonTapped)]) {
        [self.delegate geoRadiusButtonTapped];
    }
}

// 修改围栏提醒方式和手机号
- (IBAction)changeGeoRemider {
    SOSGeoModifyAlertTypeVC *vc = [SOSGeoModifyAlertTypeVC new];
    vc.geofence = self.geofence;
    [self.viewController.navigationController pushViewController:vc animated:YES];
}

@end
