//
//  SOSServiceSettingViewController.m
//  Onstar
//
//  Created by lizhipan on 2017/8/2.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSServiceSettingViewController.h"
#import "HandleDataRefreshDataUtil.h"
#import "MeSystemSettingsViewCell.h"
#import "SystemSettingCellData.h"
#import "SOSCheckRoleUtil.h"
#import "SOSCustomAlertView.h"
#import "PushNotificationManager.h"
#import "ClientTraceIdManager.h"
#import "SOSLoginUserDbService.h"
#import "TBTOrODDSettingVC.h"
#import "SDImageCache.h"
#import "SOSRemindsetVc.h"
#import "TLServiceSettingViewModel.h"
#import "ServiceController.h"
#import "SOSAlertView.h"
#import "ChargeModeViewController.h"
#import "SOSCardUtil.h"

#ifndef SOSSDK_SDK
#import "SOSMusicPlayer.h"
#endif

#import "SOSAgreement.h"
#import "SOSMroSettingViewController.h"
#if __has_include(<BlePatacSDK/BlueToothManager.h>)
#import "SOSBleNetwork.h"
#endif
#import "SOSInfoFlowSettingViewController.h"
#import "SOSGreetingCache.h"

static NSString * const kLastClearCacheUnixTime = @"kLastClearCacheUnixTime";

@interface SOSServiceSettingViewController ()
@property (strong, nonatomic) TLServiceSettingViewModel *viewModel;
@property (weak, nonatomic) SOSServicesInfo *serviceInfo;
@property (strong, nonatomic) NSArray <NSMutableArray *>*tableData;
@property (weak, nonatomic) UILabel *clearCacheLabel;
@end

@implementation SOSServiceSettingViewController

- (void)initData{
    _serviceInfo = [CustomerInfo sharedInstance].servicesInfo;
    _viewModel = [[TLServiceSettingViewModel alloc] initWithVC:self];
}

- (void)initView{
    self.table.rowHeight = 45.f;
    [self.table registerNib:[UINib nibWithNibName:@"MeSystemSettingsViewCell" bundle:nil] forCellReuseIdentifier:MeSystemSettings_CellID];
//    self.table.estimatedSectionHeaderHeight = CGFLOAT_MIN;
//    self.table.estimatedSectionFooterHeight = CGFLOAT_MIN;
    if(SOS_ONSTAR_PRODUCT){
        UIView *footerView = [_viewModel getTableFooterView];
        self.table.tableFooterView = footerView;
        [self.table mas_makeConstraints:^(MASConstraintMaker *make){
            make.edges.equalTo(self.view);
        }];
    }


}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
    [self refreshData];

    [[CustomerInfo sharedInstance].servicesInfo getResponseFromSeriverForce:YES complete:^{
        [self refreshData];
    }];
    //ble
    #if __has_include(<BlePatacSDK/BlueToothManager.h>)
    if ([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.ble) {
        [SOSBleNetwork bleSwitchStatusSuccess:^(id JSONDict) {
            if ([[JSONDict objectForKey:@"statusCode"] isEqualToString:@"0000"]) {
                NSDictionary *dic =[JSONDict objectForKey:@"resultData"];
                if ([dic isKindOfClass:[NSDictionary class]]) {
                    BOOL switchOn = [[dic objectForKey:@"ble"] isEqualToString:@"ON"];
                    if (switchOn) {
                        _viewModel.bleSwitchStatus = SOSBleSwitchStatusOn;
                    }else {
                        _viewModel.bleSwitchStatus = SOSBleSwitchStatusOff;
                    }
                    
                    [self refreshData];
                }
            }else {
//                if ([[JSONDict objectForKey:@"statusCode"] isEqualToString:@"5001"]) {
//                    //未绑定车
//                    _viewModel.bleSwitchStatus = SOSBleSwitchStatusUnBind;
//
//                }else
                {
                    _viewModel.bleSwitchStatus = SOSBleSwitchStatusUnknow;
//                    NSString *msg = [JSONDict objectForKey:@"message"];
//                    [Util toastWithMessage:msg];
                }
                
            }
            [self refreshData];
        } Failed:^(NSString *responseStr, NSError *error) {
            
        }];
    }
#endif
}

- (void)refreshData{
    [_viewModel clearData];
    _tableData = [_viewModel cookData];
    [self.table reloadData];
}

#pragma mark - 功能点击部分
//驾驶行为评价
- (void)behaviorTapped:(id)sender{
    UISwitch *switcher = (UISwitch *)sender;
    __weak __typeof(self)weakSelf = self;
    //当前服务状态为开启
    if (_serviceInfo.SmartDrive.optStatus) {
        [SOSDaapManager sendActionInfo:SS_Smartdriver_opentoclose];
        SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"提示" detailText:@"亲，您确定要关闭服务？关闭期间，您的驾驶积分和驾驶行为报告生成会受到影响。亲，留着我给您攒积分吧~~" cancelButtonTitle:@"算了,不关了" otherButtonTitles:@[@"忍痛关闭"] canTapBackgroundHide:NO];
        [alert setButtonMode:SOSAlertButtonModelHorizontal];
        [alert setButtonClickHandle:^(NSInteger index){
            // 确定关闭服务
            if (index == 1) {
                [SOSDaapManager sendActionInfo:SS_Smartdriver_popwinclose];
                [weakSelf.serviceInfo triggerService:NO serviceName:@"SmartDrive" callback:^{
                    switcher.on = NO;
                    NSString *key = [NSString stringWithFormat:@"drivingScoreReopen_%@",[Util md5:[CustomerInfo sharedInstance].userBasicInfo.idpUserId]];
                    UserDefaults_Set_Bool(NO, key);
                    //关闭驾驶行为评价服务
                    [[SOSGreetingCache shareInstance] removeCardDataByCardName:soskDrivingScoreCardData idpId:[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
                    weakSelf.serviceInfo.SmartDrive.optStatus = NO;
                    [[NSNotificationCenter defaultCenter] postNotificationName:kSOSServiceOptState object:@{kSOSServiceSmartDriveOptState:@(NO)}];
                } failBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                    switcher.on = YES;
                }];
            }	else	{
                [SOSDaapManager sendActionInfo:SS_Smartdriver_popwincancel];
                switcher.on = YES;
                [Util toastWithMessage:@"谢谢亲不关之恩~~"];
            }
        }];
        [alert show];
    //当前状态关闭
    }	else	{
        [SOSDaapManager sendActionInfo:SS_Smartdriver_closetoopen];
        [Util showLoadingView];
        [SOSAgreement requestAgreementsWithTypes:@[agreementName(ONSTAR_DRIVINGSCORE_TC)] success:^(NSDictionary *response) {
            [Util hideLoadView];
            NSDictionary *dic = response[agreementName(ONSTAR_DRIVINGSCORE_TC)];
            SOSAgreement *agreement = [SOSAgreement mj_objectWithKeyValues:dic];
            SOSAlertView *alert = [[SOSAlertView alloc] init];
            alert.title = @"驾驶行为评价协议";
            alert.cancelStr = @"拒绝";
            alert.submitStr = @"同意";
            [alert loadURL_No_header:agreement.url];
            alert.agreeAction = ^(BOOL flag)    {
                if (flag) {
                    //add report v7.02
                    [SOSDaapManager sendActionInfo:SS_Smartdriver_agreeprotocol];
                    //同意,上传服务器开关状态
                    [weakSelf.serviceInfo triggerService:YES serviceName:@"SmartDrive" callback:^{
                        switcher.on = YES;
                        NSString *key = [NSString stringWithFormat:@"drivingScoreReopen_%@", [Util md5:[CustomerInfo sharedInstance].userBasicInfo.idpUserId]];
                        UserDefaults_Set_Bool(YES, key);
                        [[SOSGreetingCache shareInstance] removeCardDataByCardName:soskDrivingScoreCardData idpId:[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
                        weakSelf.serviceInfo.SmartDrive.optStatus = YES;
                        if (self.refreshH5Block) {
                            self.refreshH5Block();
                            if (_goBack)	[self.navigationController popViewControllerAnimated:YES];
                        }
                        [[NSNotificationCenter defaultCenter] postNotificationName:kSOSServiceOptState object:@{kSOSServiceSmartDriveOptState:@(YES)}];
                    } failBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                        switcher.on = NO;
                    }];
                }    else    {
                    [SOSDaapManager sendActionInfo:SS_Smartdriver_rejectprotocol];
                    
                    switcher.on = NO;
                }
            };
            [alert showAlertView];

        } fail:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            [Util hideLoadView];
            switcher.on = NO;
            [Util toastWithMessage:@"获取协议失败"];
        }];

    }
}

//小O语音助手
- (void)mrOSettingTapped     {
    SOSMroSettingViewController * mroSet = [[SOSMroSettingViewController alloc] init];
    [self.navigationController pushViewController:mroSet animated:YES];
    
}

//设置ble开关
- (void)bleSettingTapped:(id)sender {
    
    if (_viewModel.bleSwitchStatus == SOSBleSwitchStatusOn) {
        [SOSDaapManager sendActionInfo:BLEOwner_Setup_Close];
        SOSCustomAlertView *cusAlertView = [[SOSCustomAlertView alloc] initWithTitle:@"关闭服务" detailText:@"关闭蓝牙钥匙功能您将无法使用钥匙和共享功能,已共享授权将全部失效\n您确定要这样做吗?" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"]];
        cusAlertView.backgroundModel = SOSAlertBackGroundModelStreak;
        cusAlertView.buttonMode = SOSAlertButtonModelHorizontal;
        @weakify(self)
        [cusAlertView setButtonClickHandle:^(NSInteger clickIndex) {
            if (clickIndex == 1) {
                //去设置页面
                @strongify(self)
                [self switchBleWithSender:sender];
            }else {
                UISwitch *switcher = (UISwitch *)sender;
                switcher.on = _viewModel.bleSwitchStatus==SOSBleSwitchStatusOn;
            }
        }];
        [cusAlertView show];
    }else {
        //打开开关
        [SOSDaapManager sendActionInfo:BLEOwner_Setup_Open];
        [self switchBleWithSender:sender];
    }
    
}
- (void)switchBleWithSender:(id)sender {
#if __has_include(<BlePatacSDK/BlueToothManager.h>)
    UISwitch *switcher = (UISwitch *)sender;
    [SOSBleNetwork bleSwitchStatusWithBleStatus:_viewModel.bleSwitchStatus == SOSBleSwitchStatusOn?@"OFF":@"ON" Success:^(id JSONDict) {
        if ([[JSONDict objectForKey:@"statusCode"] isEqualToString:@"0000"]) {
            NSDictionary *dic =[JSONDict objectForKey:@"resultData"];
            if ([dic isKindOfClass:[NSDictionary class]]) {
                BOOL switchOn = [[dic objectForKey:@"ble"] isEqualToString:@"ON"];
                _viewModel.bleSwitchStatus = switchOn?SOSBleSwitchStatusOn:SOSBleSwitchStatusOff;
                switcher.on = switchOn;
                !self.bleSwitchBlock?:self.bleSwitchBlock(switchOn);
            }
        }else {
            NSString *msg = [JSONDict objectForKey:@"message"];
            [Util toastWithMessage:msg];
            switcher.on = _viewModel.bleSwitchStatus == SOSBleSwitchStatusOn;
        }
    } Failed:^(NSString *responseStr, NSError *error) {
        switcher.on = _viewModel.bleSwitchStatus == SOSBleSwitchStatusOn;
    }];
#endif
}

//声音
- (void)remoteAudioTapped:(id)sender
{
    UISwitch *controller = (UISwitch *)sender;
    UserDefaults_Set_Bool(controller.on, NEED_REMOTE_AUDIO);
    //[[SOSReportService shareInstance] recordActionWithFunctionID:controller.on ? Setting_VoiceOn : Setting_VoiceOff];
    [SOSDaapManager sendActionInfo:controller.on ? SS_Sounds_closetoopen : SS_Sounds_opentoclose];

}

//车况鉴定
- (void)vehicleReportTapped:(id)sender{
    UISwitch *switcher = (UISwitch *)sender;
    __weak __typeof(self)weakSelf = self;
    NSString *funcId = _serviceInfo.CarAssessment.optStatus ? SS_Carassessment_closetoopen : SS_Carassessment_opentoclose;
    BOOL goalStatus = !_serviceInfo.CarAssessment.optStatus;
//    //[[SOSReportService shareInstance] recordActionWithFunctionID:funcId];
    [SOSDaapManager sendActionInfo:funcId];

    [_serviceInfo triggerService:goalStatus serviceName:@"CarAssessment" callback:^{
        weakSelf.serviceInfo.CarAssessment.optStatus = goalStatus;
        switcher.on = goalStatus;
    } failBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        switcher.on = !goalStatus;
    }];
}

//清除缓存
- (void)clearCacheTapped{
    [SOSDaapManager sendActionInfo:SS_ClearCache];
    //[[SOSReportService shareInstance] recordActionWithFunctionID:Setting_ClearCache];
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
        [Util toastWithMessage:NSLocalizedString(@"Clear_Cache_SucessMessage", nil)];
        NSNumber *currentUnixTime = @([NSDate date].timeIntervalSince1970);
        [[NSUserDefaults standardUserDefaults] setObject:currentUnixTime forKey:kLastClearCacheUnixTime];
        [[NSUserDefaults standardUserDefaults] synchronize];
        _clearCacheLabel.text = [self getTimeWithUnixTime:currentUnixTime];
    }];
}

//振动
- (void)remoteAudio2Tapped:(id)sender     {
    UISwitch *controller = (UISwitch *)sender;
    UserDefaults_Set_Bool(controller.on, NEED_REMOTE_Viberate);
    //[[SOSReportService shareInstance] recordActionWithFunctionID:controller.on ? Setting_VibrateOn : Setting_VibrateOff];
    [SOSDaapManager sendActionInfo:controller.on ? SS_Vibration_closetoopen : SS_Vibration_opentoclose];

}

//下发首选
- (void)sendFirstVehicleSet{
//    UITableViewCell *cell = sender;
    ////[[SOSReportService shareInstance] recordActionWithFunctionID:REPORT_ChooseDefalt];

    [SOSDaapManager sendActionInfo:SS_sendtocarpreference];
    __weak __typeof(self)weakSelf = self;
    TBTOrODDSettingVC *tbtVC = [[UIStoryboard storyboardWithName:@"PersonalCenter" bundle:nil] instantiateViewControllerWithIdentifier:@"TBTOrODDSettingVC"];
    tbtVC.saveSuccess = ^{
//        [weakSelf.table reloadSection:0 withRowAnimation:UITableViewRowAnimationNone];
        [weakSelf refreshData];
    };
    [self.navigationController pushViewController:tbtVC animated:YES];
    
}

//自动更新车况数据
- (void)dataRefreshTapped:(id)sender     {
    UISwitch *controller = (UISwitch *)sender;
    UserDefaults_Set_Bool(controller.on, NEED_AUTO_REFRESH);
    //[[SOSReportService shareInstance] recordActionWithFunctionID:controller.on ? Setting_LoginRefreshOn : Setting_LoginRefreshOff];
    [SOSDaapManager sendActionInfo:controller.on ? SS_logindatarefresh_closetoopen : SS_logindatarefresh_opentoclose];

}


//车载Wi-Fi
- (void)carWiFiTapped{
    [SOSDaapManager sendActionInfo:SS_Wifi];
    [SOSCardUtil routerToWifiSetting];

}
- (void)infoFlowSettingTapped{
    SOSInfoFlowSettingViewController *infoSetting = [[SOSInfoFlowSettingViewController alloc] init];
    [self.navigationController pushViewController:infoSetting animated:YES];
    [SOSDaapManager sendActionInfo:ME_SS_HOMEMESSAGECARD_SETTING];
}
//油耗排名
- (void)fuelEconomyTapped:(id)sender{
    UISwitch *switcher = (UISwitch *)sender;
    __weak __typeof(self)weakSelf = self;
    if (_serviceInfo.FuelEconomy.optStatus) {
        [SOSDaapManager sendActionInfo:SS_OilConsumption_opentoclose];

        SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"提示" detailText:@"亲，您确定要关闭服务？关闭期间，您油耗相关服务将无法使用。亲，留着我给您算油耗吧 ~~" cancelButtonTitle:@"算了，不关了" otherButtonTitles:@[@"忍痛关闭"] canTapBackgroundHide:NO];
        [alert setButtonMode:SOSAlertButtonModelHorizontal];
        [alert setButtonClickHandle:^(NSInteger index){
            if (index == 1) {
                //同意,上传服务器开关状态
                [weakSelf.serviceInfo triggerService:NO serviceName:@"FuelEconomy" callback:^{
                    switcher.on = NO;
                    weakSelf.serviceInfo.FuelEconomy.optStatus = NO;
                    [[SOSGreetingCache shareInstance] removeCardDataByCardName:soskFuelConsumeCardData idpId:[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kSOSServiceOptState object:@{kSOSServiceFuelDriveOptState:@(NO)}];
                } failBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                    switcher.on = YES;
                }];
            }else{
                //[[SOSReportService shareInstance] recordActionWithFunctionID:Setting_FuelEconomyOff_ppwOff];
                switcher.on = YES;
                [Util toastWithMessage:@"谢谢亲不关之恩~~"];
            }
        }];
        [alert show];
    }else{
        [SOSDaapManager sendActionInfo:SS_OilConsumption_closetoopen];
        SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"提示" detailText:@"油耗水平排名服务，需要收集您的车辆使用数据（主要包括但不限于，车辆油耗、车辆里程数据）" cancelButtonTitle:@"确定" otherButtonTitles:nil canTapBackgroundHide:NO];
        [alert setButtonMode:SOSAlertButtonModelHorizontal];
        [alert setButtonClickHandle:^(NSInteger index){
            if (index == 0) {
                //同意,上传服务器开关状态
                //[[SOSReportService shareInstance] recordActionWithFunctionID:Setting_FuelEconomyOn_ppwIknow];
                [weakSelf.serviceInfo triggerService:YES serviceName:@"FuelEconomy" callback:^{
                    switcher.on = YES;
                    weakSelf.serviceInfo.FuelEconomy.optStatus = YES;
                    NSString *key = [NSString stringWithFormat:@"FuelEconomyFirstInfo_%@",[Util md5:[CustomerInfo sharedInstance].userBasicInfo.idpUserId]];
                    UserDefaults_Set_Object(@"N", key);
                    [[SOSGreetingCache shareInstance] removeCardDataByCardName:soskFuelConsumeCardData idpId:[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
                    if (self.refreshH5Block)     self.refreshH5Block();
                    [[NSNotificationCenter defaultCenter] postNotificationName:kSOSServiceOptState object:@{kSOSServiceFuelDriveOptState:@(YES)}];
                } failBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                    switcher.on = NO;
                }];
            }
            
        }];
        [alert show];
    }
}

//能耗排名
- (void)energyEconomyTapped:(id)sender{
    UISwitch *switcher = (UISwitch *)sender;
    __weak __typeof(self)weakSelf = self;
    if (_serviceInfo.EnergyEconomy.optStatus) {
        [SOSDaapManager sendActionInfo:SS_EngConsumption_opentoclose];

        SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"提示" detailText:@"亲，您确定要关闭服务？关闭期间，您能耗相关服务将无法使用。亲，留着我给您算能耗吧 ~~" cancelButtonTitle:@"算了，不关了" otherButtonTitles:@[@"忍痛关闭"] canTapBackgroundHide:NO];
        [alert setButtonMode:SOSAlertButtonModelHorizontal];
        [alert setButtonClickHandle:^(NSInteger index){
            if (index == 1) {

                //同意,上传服务器开关状态
                [weakSelf.serviceInfo triggerService:NO serviceName:@"EnergyEconomy" callback:^{
                    switcher.on = NO;
                    weakSelf.serviceInfo.EnergyEconomy.optStatus = NO;
                    [[SOSGreetingCache shareInstance] removeCardDataByCardName:soskEnergeConsumeCardData idpId:[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kSOSServiceOptState object:@{kSOSServiceEnergyDriveOptState:@(NO)}];
                } failBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                    switcher.on = YES;
                }];
            }else{
                switcher.on = YES;
                [Util toastWithMessage:@"谢谢亲不关之恩~~"];
            }
        }];
        [alert show];
    }else{
        [SOSDaapManager sendActionInfo:SS_EngConsumption_closetoopen];
        SOSCustomAlertView * alert = [[SOSCustomAlertView alloc] initWithTitle:@"提示" detailText:@"能耗水平排名服务，需要收集您的车辆使用数据（主要包括但不限于，车辆能耗、车辆里程数据）" cancelButtonTitle:@"确定" otherButtonTitles:nil canTapBackgroundHide:NO];
        [alert setButtonMode:SOSAlertButtonModelHorizontal];
        [alert setButtonClickHandle:^(NSInteger index){
            if (index == 0) {
              
                [weakSelf.serviceInfo triggerService:YES serviceName:@"EnergyEconomy" callback:^{
                    switcher.on = YES;
                    weakSelf.serviceInfo.EnergyEconomy.optStatus = YES;
                     NSString *key = [NSString stringWithFormat:@"energyRankFirstInfo_%@",[Util md5:[CustomerInfo sharedInstance].userBasicInfo.idpUserId]];
                    UserDefaults_Set_Object(@"N", key);
                    [[SOSGreetingCache shareInstance] removeCardDataByCardName:soskEnergeConsumeCardData idpId:[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
                    if (self.refreshH5Block) 	self.refreshH5Block();
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kSOSServiceOptState object:@{kSOSServiceEnergyDriveOptState:@(YES)}];
                   
                } failBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                    switcher.on = NO;
                }];
            }
            
        }];
        [alert show];
    }
}

- (void)chargeModeTapped{
    [SOSDaapManager sendActionInfo:SS_chargeoption];

    if (![[ServiceController sharedInstance] canPerformRequest:GET_CHARGE_PROFILE_REQUEST]) {
        return;
    }
//    if ([SOSCheckRoleUtil isDriverOrProxy]) {
//        // 司机或者代理
//        [Util showAlertMessage:NSLocalizedString(@"SB00001_MSG001", nil) withDelegate:nil];
//        return;
//    }else{
        ChargeModeViewController *chargeMode = [ChargeModeViewController new];
        [self.navigationController pushViewController:chargeMode animated:YES];
//    }

}

- (void)departTimeTapped{
    
}

- (void)logoutClick{
    [Util showAlertWithTitle:@"提示" message:NSLocalizedString(@"logoutTipInfo", nil) completeBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [[SOS_APP_DELEGATE fetchMainNavigationController] popToRootViewControllerAnimated:NO];
            [SOSDaapManager sendActionInfo:SS_logout];
            //            //[[SOSReportService shareInstance] recordActionWithFunctionID:Setting_Logoff];
            //            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:NEED_REMEMBER_ME];
            //            [[NSUserDefaults standardUserDefaults] removeObjectForKey: PREFERENCE_PASSWORD];
            //            [[NSUserDefaults standardUserDefaults] synchronize];
            [[LoginManage sharedInstance] doLogout];
            //            [PushNotificationManager cancelLicenseBusinessInsuranceNotification];
            //            [PushNotificationManager cancelCarDetectionNotification];
            //退出登录重置ClientTraceId
            [[ClientTraceIdManager sharedInstance] resetClientTraceId];
            [[SOSLoginUserDbService sharedInstance] clearDB];
        }
    } cancleButtonTitle:@"取消" otherButtonTitles:@"确定",  nil];
}

#pragma mark - table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _tableData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tableData[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    __kindof UITableViewCell *theCell = nil;
    switch (indexPath.section) {
        case 0:{
            MeSystemSettingsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MeSystemSettings_CellID];
            cell.cellData = _viewModel.sectionOneArray[indexPath.row];
            theCell = cell;
            break;
        }
        case 1:{
            MeSystemSettingsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MeSystemSettings_CellID];
            cell.cellData = _viewModel.sectionTwoArray[indexPath.row];
            theCell = cell;
            break;
        }
        case 2:{
            MeSystemSettingsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MeSystemSettings_CellID];
            cell.cellData = _viewModel.sectionThreeArray[indexPath.row];
            cell.titleTextLabel.textColor = [UIColor colorWithHexString:@"1D81DD"];
            theCell = cell;
            break;
        }
        default:
            break;
    }
    return theCell;
}


#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    if (section == 1) {
//        return _viewModel.sectionTwoArray.count > 0 ? 30.f : CGFLOAT_MIN;
//    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    if (section == 1) {
//        UIView *view = [UIView new];
//        UILabel *label = [UILabel new];
//        label.textColor = [UIColor colorWithHexString:@"4e4e5f"];
//        label.font = [UIFont systemFontOfSize:12];
//        label.text = @"充电设置";
//        [view addSubview:label];
//        [label mas_makeConstraints:^(MASConstraintMaker *make){
//            make.left.equalTo(@15);
//            make.centerY.equalTo(view);
//        }];
//        return view;
//    }
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return _tableData[section].count > 0 ? 30.f : CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 2) {
        NSNumber *unixTime = [[NSUserDefaults standardUserDefaults] objectForKey:kLastClearCacheUnixTime];
        UIView *view = [UIView new];
        if (!unixTime) {
            return view;
        }
        UILabel *label = [UILabel new];
        label.textColor = [UIColor colorWithHexString:@"4e4e5f"];
        label.font = [UIFont systemFontOfSize:12];
        label.text = [self getTimeWithUnixTime:unixTime];
        [view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(@15);
            make.centerY.equalTo(view);
        }];
        _clearCacheLabel = label;
        return view;
    }
    return [UIView new];
}

- (NSString *)getTimeWithUnixTime:(NSNumber *)unixTime{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixTime.longLongValue];
    NSString *dateString = [_viewModel.dateFormatter stringFromDate:date];
    return [NSString stringWithFormat:@"上次清除时间:%@", dateString];

}

- (void)dealloc{
    
}
@end
