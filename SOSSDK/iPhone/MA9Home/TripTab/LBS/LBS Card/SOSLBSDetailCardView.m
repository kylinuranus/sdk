//
//  SOSLBSDetailCardView.m
//  Onstar
//
//  Created by Coir on 2018/12/20.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSFlexibleAlertController.h"
#import "SOSLBSDetailCardView.h"
#import "NavigateShareTool.h"
#import "SOSDateFormatter.h"
#import "SOSNavigateTool.h"
#import "SOSLBSHistoryVC.h"
#import "SOSGeoDataTool.h"
#import "SOSTripHomeVC.h"
#import "SOSLBSHeader.h"

@interface SOSLBSDetailCardView ()

@property (weak, nonatomic) IBOutlet UIImageView *stateImgView;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *successRenewButton;
@property (weak, nonatomic) IBOutlet UIImageView *statusImgView;

@property (weak, nonatomic) IBOutlet UIView *unNormalBGView;
@property (weak, nonatomic) IBOutlet UIButton *reloadButton;
@property (weak, nonatomic) IBOutlet UIImageView *unNormalImgView;
@property (weak, nonatomic) IBOutlet UILabel *unNormalTitleLabel;

@property (weak, nonatomic) IBOutlet UIView *normalBGView;
@property (weak, nonatomic) IBOutlet UILabel *locationTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *batteryLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *updateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *updateTimeUnitLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendToCarButton;

@property (weak, nonatomic) IBOutlet UILabel *stayTimePreLabel;
@property (weak, nonatomic) IBOutlet UILabel *stayTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *stayTimeUnitLabel;

@property (nonatomic, assign) int LBSRefreshCount;
@property (nonatomic, strong) SOSLBSDataTool *LBSDataTool;
@property (nonatomic, strong) dispatch_source_t LBSRefreshTimer;

@end

@implementation SOSLBSDetailCardView

- (void)awakeFromNib	{
    [super awakeFromNib];
    self.stateImgView.highlighted = YES;
    [self addObserver];
}

- (void)setCardStatus:(SOSLBSDetailCardStatus)cardStatus	{
    if (_cardStatus == cardStatus)		return;
    _cardStatus = cardStatus;
    dispatch_async_on_main_queue(^{
        [self configSelfWithCardStatus];
    });
}

- (void)addObserver		{
    __weak __typeof(self) weakSelf = self;
    /// LBS 设备信息变更
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:KSOSLBSInfoChangeNoti object:nil] subscribeNext:^(NSNotification *noti) {
        NNLBSDadaInfo *tempLBSInfo = [noti.object copy];
        weakSelf.LBSInfo = tempLBSInfo;
        weakSelf.shouldRefresh = YES;
        weakSelf.shouldAutoRefresh = YES;
    }];
}

- (void)configSelfWithCardStatus	{
    NSString *imgName = nil;
    NSString *statusStr = @"";
    BOOL loadDataSuccess = NO;
    switch (self.cardStatus) {
        case SOSLBSDetailCardStatus_Loading:
            statusStr = @"加载中..";
            if (self.LBSPOI) {
                imgName = @"Trip_User_Location_Card_Icon_Success";
                self.addressLabel.text = @"";
                [self configPOIInfoWithNoData];
            }    else    {
                // 刚进入未获取到设备详情时,使用整体的 Loading 和 Error UI 样式
                imgName = @"Trip_LBS_List_Loading";
                self.reloadButton.userInteractionEnabled = NO;
            }
            break;
        case SOSLBSDetailCardStatus_Error:
            if (self.LBSPOI) {
                imgName = @"Trip_User_Location_Card_Icon_Fail";
                statusStr = @"点击重新获取定位";
                self.addressLabel.text = @"";
            }    else    {
                // 刚进入未获取到设备详情时,使用整体的 Loading 和 Error UI 样式
                imgName = @"Trip_LBS_List_Reload";
                statusStr = @"点击重新加载";
                self.reloadButton.userInteractionEnabled = YES;
            }
            break;
        case SOSLBSDetailCardStatus_Success:
            loadDataSuccess = YES;
            imgName = @"Trip_User_Location_Card_Icon_Success";
            break;
        default:
            break;
    }
    BOOL isLoading = self.cardStatus == SOSLBSDetailCardStatus_Loading;
    if (self.LBSPOI || loadDataSuccess) {
        self.normalBGView.hidden = NO;
        self.unNormalBGView.hidden = YES;
        self.locationTitleLabel.text = statusStr;
        self.statusImgView.image = [UIImage imageNamed:imgName];
        self.remainTimeLabel.hidden = !loadDataSuccess;
        self.shareButton.userInteractionEnabled = loadDataSuccess;
        self.sendToCarButton.userInteractionEnabled = loadDataSuccess;
        self.successRenewButton.userInteractionEnabled = !isLoading;
        if (isLoading)    	[self.statusImgView startRotating];
        else            	[self.statusImgView endRotating];
    }    else    {
        // 刚进入未获取到设备详情时,使用整体的 Loading 和 Error UI 样式
        self.normalBGView.hidden = YES;
        self.unNormalBGView.hidden = NO;
        self.unNormalImgView.image = [UIImage imageNamed:imgName];
        self.unNormalTitleLabel.text = statusStr;
        if (isLoading)     	[self.unNormalImgView startRotating];
        else              	[self.unNormalImgView endRotating];
    }
}

- (void)setLBSInfo:(NNLBSDadaInfo *)LBSInfo		{
    if (_LBSInfo == LBSInfo)        return;
    _LBSInfo = [LBSInfo copy];
    dispatch_async_on_main_queue(^{
        self.deviceNameLabel.text = self.LBSInfo.devicename;
    });
}

- (void)setLBSPOI:(SOSLBSPOI *)LBSPOI	{
    if (_LBSPOI == LBSPOI)        return;
    _LBSPOI = LBSPOI;
    [self configSelfWithPOIInfo];
    [self configAutoRefresh];
}

- (void)configSelfWithPOIInfo    {
    if (self.cardStatus == SOSLBSDetailCardStatus_Success) {
        SOSLBSPOI *poi = self.LBSPOI;
        dispatch_async_on_main_queue(^{
            self.stateImgView.highlighted = !self.LBSPOI.LBSIsOnline.boolValue;
            self.locationTitleLabel.text = poi.name;
            self.addressLabel.text = poi.address;
            [self configAutoRefresh];
            [self handleLBSBatteryInfo];
            [self handleLBSStayTimeInfo];
            [self handleLBSUpdateTimeInfo];
        });
    }
}

- (void)handleLBSBatteryInfo		{
    NSString *LBSPowerState = [self.LBSPOI.LBSPowerState copy];
    int powNum = 0;
    if ([LBSPowerState containsString:@"电量:"]) {
        NSRange range1 = [LBSPowerState rangeOfString:@"电量:"];
        NSUInteger range_1_Last = range1.location + range1.length;
        LBSPowerState = [LBSPowerState substringWithRange:NSMakeRange(range_1_Last, LBSPowerState.length - range_1_Last)];
        if (LBSPowerState.length)     powNum = [LBSPowerState substringWithRange:NSMakeRange(0, LBSPowerState.length - 1)].intValue;
    }   else    LBSPowerState = @"--";
    self.batteryLevelLabel.text = LBSPowerState;
    if (![LBSPowerState isEqualToString:@"--"]) {
        if (powNum <= 10)    self.batteryLevelLabel.textColor = [UIColor colorWithHexString:@"C50000"];
        else                self.batteryLevelLabel.textColor = [UIColor colorWithHexString:@"9EB0E3"];
    }
}

- (void)handleLBSStayTimeInfo	{
    NSString *stayTime = [self.LBSPOI.LBSStayTime copy];
    self.stayTimePreLabel.text = @"";
    if ([stayTime containsString:@"天"]) {
        NSString *day = [stayTime componentsSeparatedByString:@"天"][0];
        if (day.intValue > 100) {
            day = @"100";
            self.stayTimePreLabel.text = @"> ";
        }
        self.stayTimeLabel.text = day;
        self.stayTimeUnitLabel.text = @" 天";
    }	else if ([stayTime containsString:@"小时"])	{
        NSString *hour = [stayTime componentsSeparatedByString:@"小时"][0];
        self.stayTimeLabel.text = hour;
        self.stayTimeUnitLabel.text = @" 小时";
    }    else if ([stayTime containsString:@"分"])    {
        NSString *min = [stayTime componentsSeparatedByString:@"分"][0];
        self.stayTimeLabel.text = min;
        self.stayTimeUnitLabel.text = @" 分钟";
    }	else		{
        self.stayTimeLabel.text = @"--";
        self.stayTimeUnitLabel.text = @"";
    }
}

- (void)handleLBSUpdateTimeInfo		{
    SOSDateFormatter *formatter = [SOSDateFormatter sharedInstance];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    if (!self.LBSPOI.LBSUpdateTime.length) {
        self.updateTimeLabel.text = @"--";
        self.updateTimeUnitLabel.text = @"";
        return;
    }
    
    self.updateTimeUnitLabel.text = @"";
    NSDate *updateDate = [formatter dateFromString:self.LBSPOI.LBSUpdateTime];
    NSString *newFormatter = nil;
    if ([updateDate isToday])							newFormatter = @"HH:mm";
    else if ([updateDate isYesterday])					self.updateTimeLabel.text = @"昨天";
    else if ([updateDate year] == [[NSDate date] year])	newFormatter = @"MM/dd";
    else	{
        newFormatter = @"yyyy";
        self.updateTimeUnitLabel.text = @" 年";
    }
    
    if (newFormatter.length) {
        NSString * resultDateString = [formatter dateStrWithDateFormat:newFormatter Date:updateDate timeZone:nil];
        resultDateString = resultDateString.length ? resultDateString : @"--";
        self.updateTimeLabel.text = resultDateString;
    }
}

- (void)configPOIInfoWithNoData	{
    if (self.LBSPOI)	return;
    self.batteryLevelLabel.text = @"--";
    self.batteryLevelLabel.textColor = [UIColor colorWithHexString:@"9EB0E3"];
    self.updateTimeLabel.text = @"--";
    self.updateTimeUnitLabel.text = @"";
    
    self.stayTimePreLabel.text = @"";
    self.stayTimeLabel.text = @"--";
    self.stayTimeUnitLabel.text = @"";
}

- (void)configAutoRefresh        {
    self.LBSRefreshCount = 60;
    if (!self.LBSDataTool)       self.LBSDataTool = [SOSLBSDataTool new];
    else    return;
    self.remainTimeLabel.text = @"60 秒后刷新";
    if (self.LBSRefreshTimer)    dispatch_cancel(self.LBSRefreshTimer);
    __weak __typeof(self) weakSelf = self;
    self.LBSRefreshTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(weakSelf.LBSRefreshTimer, dispatch_walltime(NULL, 0), 1 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(weakSelf.LBSRefreshTimer, ^{
        [weakSelf LBSTimerAction];
    });
    //2.启动定时器
    dispatch_resume(self.LBSRefreshTimer);
}

- (void)stopRefreshTimer	{
    if (self.LBSRefreshTimer)    dispatch_cancel(self.LBSRefreshTimer);
    self.remainTimeLabel.text = @"";
}

- (void)LBSTimerAction  {
    _LBSRefreshCount --;
    dispatch_async_on_main_queue(^{
        self.remainTimeLabel.text = [NSString stringWithFormat:@"%d 秒后刷新", self.LBSRefreshCount];
    });
    if (_LBSRefreshCount == 0) {
        [self refreshLBSInfo];
    }
}
/// 自动刷新, 更新 LBS 设备定位点信息
- (void)refreshLBSInfo     {
    self.cardStatus = SOSLBSDetailCardStatus_Loading;
    __weak __typeof(self) weakSelf = self;
    [weakSelf.LBSDataTool getLBSPOIWithLBSDadaInfo:weakSelf.LBSInfo Success:^(SOSLBSPOI *lbsPOI) {
        weakSelf.LBSRefreshCount = 60;
        weakSelf.cardStatus = SOSLBSDetailCardStatus_Success;
        [Util copySamePropertyFromObj1:lbsPOI ToObj2:weakSelf.LBSPOI];
        [weakSelf configSelfWithPOIInfo];
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(LBSDetailCardAutoRefreshedWithLBSPOI:)]) {
            [weakSelf.delegate LBSDetailCardAutoRefreshedWithLBSPOI:[weakSelf.LBSPOI copy]];
        }
    } Failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        weakSelf.LBSRefreshCount = 60;
        weakSelf.cardStatus = SOSLBSDetailCardStatus_Error;
    }];
}

/// 刷新
- (IBAction)reloadButtonTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(LBSDetailRefreshButtonTapped)]) {
        [self.delegate LBSDetailRefreshButtonTapped];
    }
}

/// 弹出菜单 - 车辆定位 -- 点击更多(...)
- (IBAction)moreFuncButtonTapped {
    SOSFlexibleAlertController *actionSheet = [SOSFlexibleAlertController alertControllerWithImage:nil title:[NSString stringWithFormat:@"设备号 %@", self.LBSInfo.deviceid] message:nil customView:nil preferredStyle:SOSAlertControllerStyleActionSheet];
    SOSAlertAction *historyAction = [SOSAlertAction actionWithTitle:@"历史轨迹" style:SOSAlertActionStyleActionSheetDefault handler:^(SOSAlertAction * _Nonnull action) {
        [self showLBSHistoryVC];
    }];
//    SOSAlertAction *geoAction = [SOSAlertAction actionWithTitle:@"电子围栏" style:SOSAlertActionStyleActionSheetDefault handler:^(SOSAlertAction * _Nonnull action) {
//        [self showLBSGeoVC];
//    }];
    SOSAlertAction *settingAction = [SOSAlertAction actionWithTitle:@"设备设置" style:SOSAlertActionStyleActionSheetDefault handler:^(SOSAlertAction * _Nonnull action) {
        [self showLBSSettingVC];
    }];
    SOSAlertAction *cancelAction = [SOSAlertAction actionWithTitle:@"取消" style:SOSAlertActionStyleCancel handler:^(SOSAlertAction * _Nonnull action) { }];
   // [actionSheet addActions:@[historyAction, geoAction, settingAction, cancelAction]];
    [actionSheet addActions:@[historyAction, settingAction, cancelAction]];
    [actionSheet show];
}

- (void)showLBSHistoryVC     {
    [SOSDaapManager sendActionInfo:LBS_list_deviceinfo_history];
    SOSLBSHistoryVC *vc = [SOSLBSHistoryVC new];
    vc.LBSDataInfo = self.LBSInfo;
    [self.viewController.navigationController pushViewController:vc animated:YES];
}

- (void)showLBSGeoVC  	{
    [Util showHUD];
    [SOSDaapManager sendActionInfo:LBS_setting_geofence];
    [SOSGeoDataTool getLBSGeoFencingWithLBSDeviceID:self.LBSInfo.deviceid SuccessHandler:^(NSArray *fences) {
        [Util dismissHUD];
        if (fences.count > 0) {
            NNLBSGeoFence *lbsGeofence = fences[0];
            lbsGeofence.LBSDeviceName = self.LBSInfo.devicename;
            SOSGeoMapVC *geoVC = [[SOSGeoMapVC alloc] initWithGeoFence:lbsGeofence];
//            geoVC.LBSDataInfo = self.LBSInfo;
//            geoVC.selectedLBSPOI = self.LBSPOI;
            geoVC.backDaapFunctionID = LBS_setting_geofence_back;
            [self.viewController.navigationController pushViewController:geoVC animated:YES];
        }   else    {
            SOSTripNoGeoView *noGeoView = [SOSTripNoGeoView viewFromXib];
            noGeoView.lbsPOI = self.LBSPOI;
            noGeoView.LBSDataInfo = self.LBSInfo;
            [noGeoView showInView:self.viewController.view];
        }
    } failureHandler:^(NSString *responseStr, NSError *error)     {
        [Util showErrorHUDWithStatus:responseStr.length ? responseStr : @"获取围栏信息失败"];
    }];
}

- (void)showLBSSettingVC	{
    SOSLBSSettingVC *vc = [SOSLBSSettingVC new];
    vc.lbsInfo = self.LBSInfo;
    vc.lbsPOI = self.LBSPOI;
    [self.viewController.navigationController pushViewController:vc animated:YES];
}

/// 分享
- (IBAction)shareButtonTapped {
    SOSPOI *poi = [self.LBSPOI copy];
    poi.name = [NSString stringWithFormat:@"设备位置(%@)", poi.name];
    [[NavigateShareTool sharedInstance] shareWithNewUIWithPOI:poi];
}

/// 返回
- (IBAction)backButtonTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(LBSDetailBackButtonTapped)]) {
        [self.delegate LBSDetailBackButtonTapped];
    }
}

/// 导航下发  “导航下发” 按钮： 只有车载导航时，点击后即为车载导航； 只有音控领航时，点击后即为音控领航； 二者皆有时，点击后弹出选项。
- (IBAction)sendToCarButtonTapped {
    [SOSNavigateTool sendToCarAutoWithPOI:self.LBSPOI];
}

- (void)dealloc		{
    [self stopRefreshTimer];
    SOSTripHomeVC *vc = (SOSTripHomeVC *)([SOS_APP_DELEGATE fetchMainNavigationController].topViewController);
    if ([vc isKindOfClass:[SOSTripHomeVC class]]) {
        [vc removeLBSPOI];
    }
}

@end
