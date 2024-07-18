//
//  TLServiceSettingViewModel.m
//  Onstar
//
//  Created by TaoLiang on 2017/10/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "TLServiceSettingViewModel.h"
#import "HandleDataRefreshDataUtil.h"
#import "MeSystemSettingsViewCell.h"
#import "SOSCheckRoleUtil.h"
#import "SOSCustomAlertView.h"
#import "PushNotificationManager.h"
#import "ClientTraceIdManager.h"
#import "SOSLoginUserDbService.h"
#import "TBTOrODDSettingVC.h"
#import "SDImageCache.h"
#import "SOSRemindsetVc.h"
//屏蔽 Undeclared selector 'doSomething' 警告
#pragma clang diagnostic ignored "-Wundeclared-selector"

@interface TLServiceSettingViewModel ()
@property (weak, nonatomic) SOSServicesInfo *serviceInfo;
@property (weak, nonatomic) SOSServiceSettingViewController *vc;
@end

@implementation TLServiceSettingViewModel

- (instancetype)initWithVC:(SOSServiceSettingViewController *)vc{
    self = [super init];
    if (self) {
        _vc = vc;
        _serviceInfo = [CustomerInfo sharedInstance].servicesInfo;
        _sectionOneArray = @[].mutableCopy;
        _sectionTwoArray = @[].mutableCopy;
        _sectionThreeArray = @[].mutableCopy;

    }
    return self;
}

- (NSArray<NSMutableArray *> *)cookData{
    NSArray *tableData = @[_sectionOneArray, _sectionTwoArray, _sectionThreeArray];
    //section 1
    //驾驶行为评价服务:已登录 && gen10 && owner && 非PHEV && 非ICM && 非BEV
    //8.3 开放ICM
    if ([HandleDataRefreshDataUtil showDriveScore]){
        if (![Util isLoadUserProfileFailure] && _serviceInfo.SmartDrive.availability) {
            SystemSettingCellData *behaviorSettingData = [[SystemSettingCellData alloc] init];
            [behaviorSettingData setTitleText:NSLocalizedString(@"Smart_Driver_Service", @"驾驶行为评价服务")];
            //如果加载“驾驶行为评价服务”状态成功，显示开关
            [behaviorSettingData setCellStyle:CellStyleSwitch];
            [behaviorSettingData setSwitchStyleStatus:_serviceInfo.SmartDrive.optStatus];
            [behaviorSettingData setCellTarget:_vc];
            [behaviorSettingData setCellSelector:@selector(behaviorTapped:)];
            [_sectionOneArray addObject:behaviorSettingData];
        }
    }
    
//		8.3 改动
//    	ICM1.0和ICM2.0均支持DA、油耗、能耗；
    
    //油耗水平排名服务:gen10 owner  ICM1.0 放开 油耗
    if (([Util vehicleIsG10] || [Util vehicleIsICM2]) &&
         [SOSCheckRoleUtil isOwner] && ![Util isLoadUserProfileFailure] &&
        !([Util vehicleIsPHEV] || [Util vehicleIsBEV]) &&
        _serviceInfo.FuelEconomy.availability) {
        SystemSettingCellData *vehicleSettingData = [[SystemSettingCellData alloc] init];
        [vehicleSettingData setTitleText:@"油耗水平排名服务"];
        [vehicleSettingData setCellStyle:CellStyleSwitch];
        [vehicleSettingData setSwitchStyleStatus:_serviceInfo.FuelEconomy.optStatus];
        [vehicleSettingData setCellTarget:_vc];
        [vehicleSettingData setCellSelector:@selector(fuelEconomyTapped:)];
        [_sectionOneArray addObject:vehicleSettingData];
    }
    
    //能耗水平排名服务:gen10 owner phev/ev     ICM1.0 放开 能耗
    if (([Util vehicleIsG10] || [Util vehicleIsICM2]) &&
         [SOSCheckRoleUtil isOwner] && ![Util isLoadUserProfileFailure] &&
        ([Util vehicleIsEV] || [Util vehicleIsPHEV]) &&
        _serviceInfo.EnergyEconomy.availability) {
        SystemSettingCellData *vehicleSettingData = [[SystemSettingCellData alloc] init];
        [vehicleSettingData setTitleText:@"能耗水平排名服务"];
        [vehicleSettingData setCellStyle:CellStyleSwitch];
        [vehicleSettingData setSwitchStyleStatus:_serviceInfo.EnergyEconomy.optStatus];
        [vehicleSettingData setCellTarget:_vc];
        [vehicleSettingData setCellSelector:@selector(energyEconomyTapped:)];
        [_sectionOneArray addObject:vehicleSettingData];
    }
    
    
    //最新要求owner就显示
    if ([SOSCheckRoleUtil isOwner]) {
        if (![Util isLoadUserProfileFailure]) {
            //车辆鉴定报告 服务
            SystemSettingCellData *vehicleSettingData = [[SystemSettingCellData alloc] init];
            [vehicleSettingData setTitleText:@"车况鉴定报告分享协议"];
            [vehicleSettingData setCellStyle:CellStyleSwitch];
            [vehicleSettingData setSwitchStyleStatus:_serviceInfo.CarAssessment.optStatus];
            [vehicleSettingData setCellTarget:_vc];
            [vehicleSettingData setCellSelector:@selector(vehicleReportTapped:)];
            [_sectionOneArray addObject:vehicleSettingData];
        }
    }
    
    //首页消息卡片设置
    if (![SOSCheckRoleUtil isVisitor]){
        SystemSettingCellData *infoFlowSettingData = [[SystemSettingCellData alloc] init];
        [infoFlowSettingData setTitleText:NSLocalizedString(@"InfoflowSetting", nil)];
        [infoFlowSettingData setCellStyle:CellStyleDisclosureIndicator];
        [infoFlowSettingData setCellTarget:_vc];
        [infoFlowSettingData setCellSelector:NSSelectorFromString(@"infoFlowSettingTapped")];
        [_sectionOneArray addObject:infoFlowSettingData];

    }

    //BLE开关
    if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.ble &&
        (self.bleSwitchStatus==SOSBleSwitchStatusOn||self.bleSwitchStatus==SOSBleSwitchStatusOff)) {
        SystemSettingCellData *serttingData = [[SystemSettingCellData alloc] init];
        [serttingData setTitleText:@"蓝牙钥匙"];
        [serttingData setCellStyle:CellStyleSwitch];
        [serttingData setCellTarget:_vc];
        [serttingData setSwitchStyleStatus:self.bleSwitchStatus==SOSBleSwitchStatusOn];
        [serttingData setCellSelector:@selector(bleSettingTapped:)];
        [_sectionOneArray addObject:serttingData];
    }
    //9.2小O下架
    //小O语音助手:owner
#ifndef SOSSDK_SDK
    if ([SOSCheckRoleUtil isOwner] && ![Util isLoadUserProfileFailure]) {
        SystemSettingCellData *mrOSerttingData = [[SystemSettingCellData alloc] init];
        [mrOSerttingData setTitleText:NSLocalizedString(@"SettingVC_MrOName", @"小O语音助手")];
        [mrOSerttingData setCellStyle:CellStyleDisclosureIndicator];
        //        [mrOSerttingData setSwitchStyleStatus:[[Util readMrOOpenFlagByidpid:[CustomerInfo sharedInstance].userBasicInfo.idpUserId] boolValue]];
        //        [mrOSerttingData setCellTarget:_vc];
        [mrOSerttingData setCellTarget:_vc];
        [mrOSerttingData setCellSelector:@selector(mrOSettingTapped)];
        [_sectionOneArray addObject:mrOSerttingData];
    }
#endif
    
    //声音
    SystemSettingCellData *remoteSettingData = [[SystemSettingCellData alloc] init];
    [remoteSettingData setTitleText:NSLocalizedString(@"RemoteAudioVibrate", nil)];
    [remoteSettingData setCellStyle:CellStyleSwitch];
    [remoteSettingData setSwitchStyleStatus:[[NSUserDefaults standardUserDefaults] boolForKey:NEED_REMOTE_AUDIO]];
    [remoteSettingData setCellTarget:_vc];
    [remoteSettingData setCellSelector:@selector(remoteAudioTapped:)];
    [_sectionOneArray addObject:remoteSettingData];
    
    //振动
    SystemSettingCellData *remoteVSettingData = [[SystemSettingCellData alloc] init];
    [remoteVSettingData setTitleText:NSLocalizedString(@"RemoteAudioVibrate2", nil)];
    [remoteVSettingData setCellStyle:CellStyleSwitch];
    [remoteVSettingData setSwitchStyleStatus:[[NSUserDefaults standardUserDefaults] boolForKey:NEED_REMOTE_Viberate]];
    [remoteVSettingData setCellTarget:_vc];
    [remoteVSettingData setCellSelector:@selector(remoteAudio2Tapped:)];
    [_sectionOneArray addObject:remoteVSettingData];
    /** 7.4 上
     if (![Util isLoadUserProfileFailure] && [SOSCheckRoleUtil isOwner]) {
     SystemSettingCellData *RemoteControlSettingData = [[SystemSettingCellData alloc] init];
     [RemoteControlSettingData setTitleText:@"远程控制功能"];
     [RemoteControlSettingData setCellStyle:CellStyleSwitch];
     [RemoteControlSettingData setSwitchStyleStatus: RemoteControlOptStatus];
     [RemoteControlSettingData setCellTarget:self];
     [RemoteControlSettingData setCellSelector:@selector(RemoteControlSettingTapped:)];
     [_sectionOneArray addObject:RemoteControlSettingData];
     
     SystemSettingCellData *FmvOptSettingData = [[SystemSettingCellData alloc] init];
     [FmvOptSettingData setTitleText:@"我的车辆位置"];
     [FmvOptSettingData setCellStyle:CellStyleSwitch];
     [FmvOptSettingData setSwitchStyleStatus: FmvOptStatus];
     [FmvOptSettingData setCellTarget:self];
     [FmvOptSettingData setCellSelector:@selector(FmvOptSettingTapped:)];
     [_sectionOneArray addObject:FmvOptSettingData];
     }
     **/
    
    //下发首选(ICM车不显示)
    if ([[LoginManage sharedInstance] isLoadingMainInterfaceReady] &&
        [CustomerInfo sharedInstance].currentVehicle.sendToTBTSupported &&
        [CustomerInfo sharedInstance].currentVehicle.sendToNAVSupport  &&
        ![SOSCheckRoleUtil isVisitor] &&
        ![Util isLoadUserProfileFailure]) {
        BOOL status = UserDefaults_Get_Bool(IS_SENDING_ODD_First_REQUEST);
        SystemSettingCellData *sendFristSet = [[SystemSettingCellData alloc] init];
        [sendFristSet setTitleText:NSLocalizedString(@"sendFristVehicleSet", @"下发首选")];
        [sendFristSet setSubtitleText:status ? NSLocalizedString(@"Send_ODD", nil) : NSLocalizedString(@"Send_TBT", nil)];
        [sendFristSet setCellTarget:_vc];
        [sendFristSet setCellStyle:CellStyleDisclosureIndicator];
        [sendFristSet setCellSelector:@selector(sendFirstVehicleSet)];
        [_sectionOneArray addObject:sendFristSet];
    }
    
    //登录时自动更新车况数据
    SystemSettingCellData *dataRefreshData = [[SystemSettingCellData alloc] init];
    [dataRefreshData setTitleText:NSLocalizedString(@"vehicleUpdatePageUpdateTitle", @"登录时自动更新车况数据")];
    [dataRefreshData setCellStyle:CellStyleSwitch];
    [dataRefreshData setSwitchStyleStatus:[[NSUserDefaults standardUserDefaults] boolForKey:NEED_AUTO_REFRESH]];
    [dataRefreshData setCellTarget:_vc];
    [dataRefreshData setCellSelector:@selector(dataRefreshTapped:)];
    [_sectionOneArray addObject: dataRefreshData];
    
    //WIFI   ICM 1.0 Wifi 屏蔽
    if (([SOSCheckRoleUtil isOwner] || [SOSCheckRoleUtil isDriverOrProxy]) &&
        ![Util isLoadUserProfileFailure] &&
        [CustomerInfo sharedInstance].currentVehicle.wifiSupported &&
        ![Util vehicleIsIcm]) {
        SystemSettingCellData *carLoadWifi = [[SystemSettingCellData alloc] init];
        [carLoadWifi setTitleText:@"车载Wi-Fi"];
        [carLoadWifi setCellTarget:_vc];
        [carLoadWifi setCellStyle:CellStyleDisclosureIndicator];
        [carLoadWifi setCellSelector:@selector(carWiFiTapped)];
        [_sectionOneArray addObject:carLoadWifi];    //addByWQ 20180906 暂时隐去车载Wifit入口
    }


    //section 2
    //充电模式
    if (([SOSCheckRoleUtil isOwner] || [SOSCheckRoleUtil isDriverOrProxy]) &&
        ![Util isLoadUserProfileFailure] &&
        ([Util vehicleIsPHEV])) {
        SystemSettingCellData *chargeMode = [[SystemSettingCellData alloc] init];
        [chargeMode setTitleText:@"充电设置"];
        [chargeMode setCellTarget:_vc];
        [chargeMode setCellStyle:CellStyleDisclosureIndicator];
        [chargeMode setCellSelector:@selector(chargeModeTapped)];
        [_sectionTwoArray addObject:chargeMode];
    }
    
    //section 3
    //清除缓存数据
    SystemSettingCellData *clearCache = [[SystemSettingCellData alloc] init];
    [clearCache setTitleText:NSLocalizedString(@"Clear_Cache", nil)];
    [clearCache setCellTarget:_vc];
    [clearCache setCellStyle:CellStyleNone];
    [clearCache setCellSelector:@selector(clearCacheTapped)];
    [_sectionThreeArray addObject:clearCache];
    
    //    //提醒设置  仅车主可见”提醒设置“
    //    if ([SOSCheckRoleUtil isOwner] && ![Util isLoadUserProfileFailure]) {
    //        SystemSettingCellData *tipSet = [[SystemSettingCellData alloc] init];
    //        [tipSet setTitleText:@"提醒设置"];
    //        [tipSet setCellTarget:self];
    //        [tipSet setCellStyle:CellStyleDisclosureIndicator];
    //        [tipSet setCellSelector:@selector(tipSetVc)];
    //        [_sectionOneArray addObject:tipSet];
    //    }
    return tableData;
}


- (UIView *)getTableFooterView{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 34 + 44 + 30)];
    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [footerView addSubview:logoutBtn];
    [logoutBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.right.equalTo(footerView);
        make.height.mas_equalTo(44);
        make.bottom.equalTo(@-30);
    }];
    logoutBtn.backgroundColor = [UIColor whiteColor];
    [logoutBtn setTitle:NSLocalizedString(@"settingButtonLogoutTitle", @"退出") forState:UIControlStateNormal];
    [logoutBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    logoutBtn.titleLabel.font = [UIFont systemFontOfSize:19];
    [logoutBtn addTarget:_vc action:@selector(logoutClick) forControlEvents:UIControlEventTouchUpInside];
    return footerView;
}

- (NSDateFormatter *)dateFormatter{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy年MM月dd日";
    }
    return _dateFormatter;
}

- (void)clearData{
    [_sectionOneArray removeAllObjects];
    [_sectionTwoArray removeAllObjects];
    [_sectionThreeArray removeAllObjects];
}

@end
