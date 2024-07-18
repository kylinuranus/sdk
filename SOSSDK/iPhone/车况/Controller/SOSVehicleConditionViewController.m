//
//  SOSVehicleConditionViewController.m
//  Onstar
//
//  Created by Genie Sun on 2017/7/25.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSVehicleConditionViewController.h"
#import "SOSCircleAnimation.h"
#import "SOSPDView.h"
#import "SOSBEVView.h"
#import "SOSCarConditionView.h"
#import "CarStatusDetailViewController.h"
#import "SOSTripChargeVC.h"
#import "SOSRemindsetVc.h"
#import "SOSSettingViewController.h"
#import "SOSVehicleVariousStatus.h"
#import "SOSVehicleInfoUtil.h"
#import "SOSGreetingManager.h"
#import "TLSOSRefreshHeader.h"
#import "ServiceController.h"
#import "ChargeModeViewController.h"
#import "SOSVehicleConditionShareWebController.h"
#import "SOSCardUtil.h"
#import "SOSFVView.h"
#import "SOSDateFormatter.h"
#import "UIImage+SOSSkin.h"

@interface SOSVehicleConditionViewController ()<SOSBEVViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *evHeight;//电
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fvHeight;//油
@property (weak, nonatomic) IBOutlet SOSCarConditionView *fvView;
@property (weak, nonatomic) IBOutlet SOSCarConditionView *evView;
@property (weak, nonatomic) IBOutlet SOSBEVView *evCarStatusView;
@property (weak, nonatomic) IBOutlet SOSFVView *fvCarStatusView;

@property (weak, nonatomic) IBOutlet UILabel *updateLabel;

@property (weak, nonatomic) IBOutlet UIButton *bottomBtn;
@property (weak, nonatomic) IBOutlet UIButton *bottomLeftBtn;
//@property (nonatomic, strong) SOSCircleAnimation * circleView;

@property (strong, nonatomic) UIButton *shareBtn;

@end

@implementation SOSVehicleConditionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"我的车况";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _bottomBtn.enabled = NO;
    _bottomBtn.backgroundColor = [SOSUtil onstarButtonDisableColor];
    _bottomLeftBtn.backgroundColor = [UIColor cadiStytle];// UIColorHex(0x6896ED);
    self.backRecordFunctionID = CARCONDITIONS_BACK;
    self.backDaapFunctionID = CARCONDITIONS_BACK;
    
    self.backScrollView.mj_header = [TLSOSRefreshHeader headerWithRefreshingBlock:^{
        @weakify(self)
        NSTimeInterval start =  [[NSDate date] timeIntervalSince1970];
        [SOSVehicleInfoUtil requestVehicleInfoSuccess:^(id result) {
            @strongify(self)
            [self.backScrollView.mj_header endRefreshing];
            [SOSDaapManager sendSysLayout:start endTime:[[NSDate date] timeIntervalSince1970]  loadStatus:YES  funcId:VehicleDia_Refresh_Loadtime];
            
        } Failure:^(id result) {
            @strongify(self)
            [self.backScrollView.mj_header endRefreshing];
            // 排除因登录状态,重复操作导致的车况刷新操作未能开始的场景
            if (result) {
                [SOSDaapManager sendSysLayout:start endTime:[[NSDate date] timeIntervalSince1970]  loadStatus:NO  funcId:VehicleDia_Refresh_Loadtime];
            }

        }];
    }];
    
    self.evCarStatusView.delegate = self;
    [SOSUtilConfig setNavigationBarItemTitle:@"车辆设置" target:self selector:@selector(routerToCarSetting)];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor cadiStytle]];
    [self configUI];
    @weakify(self)
    [RACObserve([SOSGreetingManager shareInstance], vehicleStatus) subscribeNext:^(id x) {
        @strongify(self);
        dispatch_async_on_main_queue(^{
            if ([x integerValue] != RemoteControlStatus_InitSuccess) {
                [self configUI];
            }
            self.shareBtn.hidden = [x integerValue] != RemoteControlStatus_OperateSuccess;
        });
    }];
    
    [[RACSignal combineLatest:@[
                                RACObserve([SOSGreetingManager shareInstance], roleGreeting),
                                RACObserve([SOSGreetingManager shareInstance], vehicleStatus)
                                ] reduce:^(id x, NSNumber *z){
                                    if ([SOSCheckRoleUtil isOwner] || [SOSCheckRoleUtil isDriverOrProxy]) {
                                        if ([x isKindOfClass:[NSDictionary class]] && z.integerValue == RemoteControlStatus_OperateSuccess) {
                                            return @(RemoteControlStatus_OperateSuccess);
                                        }else if([x isEqual:@NO] || z.integerValue == RemoteControlStatus_OperateFail) {
                                            return @(RemoteControlStatus_OperateFail);
                                        }
                                        
                                        return @(z.integerValue);
                                    }else {
                                        if ([x isKindOfClass:[NSDictionary class]]) {
                                            return @(RemoteControlStatus_OperateSuccess);
                                        }else if([x isKindOfClass:[NSNumber class]] && [x integerValue] == 0) {
                                            return @(RemoteControlStatus_OperateFail);
                                        }
                                        return @(RemoteControlStatus_InitSuccess);
                                    }
                                    
                                    return @(RemoteControlStatus_InitSuccess);
                                }] subscribeNext:^(id x) {
                                    dispatch_async_on_main_queue(^{
                                        [self refreshHeaderWithStatus:[x integerValue]];
                                    });
                                    
                                }] ;

    [self loadVehicleData];
}

- (void)loadVehicleData {
    if (![SOSCheckRoleUtil checkPackageServiceAvailable:PP_DataRefresh andNeedPopError:NO]) {
        [SOSGreetingManager shareInstance].vehicleStatus = RemoteControlStatus_OperateFail;
        return;
    }
    if (![CustomerInfo sharedInstance].timeYear.isNotBlank && [SOSGreetingManager shareInstance].vehicleStatus != RemoteControlStatus_InitSuccess) {
        [self.backScrollView.mj_header beginRefreshing];
    }
}

- (UIButton *)shareBtn {
    if (!_shareBtn) {
        _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareBtn setBackgroundImage:[UIImage sosSDK_imageNamed:@"icon_share_72x72 (1)"] forState:UIControlStateNormal];
        [_shareBtn addTarget:self action:@selector(shareVehicleCondition) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_shareBtn];
        [_shareBtn mas_makeConstraints:^(MASConstraintMaker *make){
            make.right.mas_equalTo(-16);
            make.width.height.mas_equalTo(72);
            make.bottom.equalTo(self.view.sos_bottom).offset(-80);
        }];
    }
    return _shareBtn;
}

- (void)shareVehicleCondition {
    [SOSDaapManager sendActionInfo:SMARTVEHICLE_CAR_CONDITION_LONG_GRAPH_SHARE];
    NSString *url = [Util getStaticConfigureURL:SOS_Vehicle_Condition_Share_URL];
    SOSVehicleConditionShareWebController *vc = [[SOSVehicleConditionShareWebController alloc] initWithUrl:url];
    vc.backDaapFunctionID = SMARTVEHICLE_CAR_CONDITION_LONG_GRAPH_SHARE_BACK;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addLeftBarButtonItem {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"common_Nav_Back"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"common_Nav_Back"] forState:UIControlStateHighlighted];
    button.size = CGSizeMake(30, 44);
    button.backgroundColor = [UIColor clearColor];
    // 让按钮内部的所有内容左对齐
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //        [button sizeToFit];
    // 让按钮的内容往左边偏移10
    button.contentEdgeInsets = UIEdgeInsetsMake(0, -1, 0, 0);
    [button addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    // 修改导航栏左边的item
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationBackButton = button;
}

- (void)dismiss {
    [SOSDaapManager sendActionInfo:CARCONDITIONS_BACK];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)refreshHeaderWithStatus:(RemoteControlStatus)status {
    _bottomBtn.enabled = status==RemoteControlStatus_OperateSuccess;
    _bottomBtn.backgroundColor = status==RemoteControlStatus_OperateSuccess?[UIColor cadiStytle] /*UIColorHex(0x6896ED)*/:[SOSUtil onstarButtonDisableColor];
    switch (status) {
        case RemoteControlStatus_OperateSuccess:
        case RemoteControlStatus_OperateFail:
        {
            SOSGreetingModel *model = [[SOSGreetingManager shareInstance] getGreetingModelWithType:SOSGreetingTypeVehicleCondition];
            if ([model.condition isEqualToString:@"TIERPRESUREBAD"] ||
                [model.condition isEqualToString:@"FUELNOTENOUGH"] ||
                [model.condition isEqualToString:@"OILNOTENOUGH"] ||
                [model.condition isEqualToString:@"BETTERYNOTENOUGH"] ||
                [model.condition isEqualToString:@"MORETHAN1BAD"] ||
                [model.condition isEqualToString:@"CHARGINGABORTED"] ||
                [model.condition isEqualToString:@"BRAKEPADSLOW"]) {
                self.titleLb.textColor = [UIColor colorWithHexString:STATUS_RED];
            }else {
                self.titleLb.textColor = UIColorHex(#28292F);
            }
            self.titleLb.text = model.greetings;
            self.timeLB.text = model.subGreetings;
            self.statusImgView.image = [UIImage imageNamed:model.icon];
            [self setupUpdateTime];
        }
            break;
            
        case RemoteControlStatus_InitSuccess:
            self.titleLb.text = @"正在刷新..";
            self.titleLb.textColor = UIColorHex(#28292F);
            self.timeLB.text = @"请稍后";
            self.statusImgView.image = [UIImage imageNamed:@"Icon／22x22／OnStar_icon_fail_22x22-2"];
            self.updateLabel.hidden = YES;
//             [self setupUpdateTime];
            break;
        default:
            break;
    }
}

- (void)configUI {
    if ([Util vehicleIsBEV]) {
        //电动车
        self.fvCarStatusView.hidden = YES;
        self.evCarStatusView.hidden = NO;
        self.fvHeight.constant = 0;
        self.fvView.hidden = YES;
        self.evHeight.constant = 120;
        [self.evView configEVView];
        [self.evCarStatusView configView];
    } else if ([Util vehicleIsPHEV]){
        //混动车
        self.fvCarStatusView.hidden = YES;
        self.evCarStatusView.hidden = NO;
        self.fvHeight.constant = 120;
        self.evHeight.constant = 120;
        [self.evView configPHEVView1];
        [self.fvView configPHEVView2];
         [self.evCarStatusView configView];
    }else{
        //油耗车
        self.evCarStatusView.hidden = YES;
        self.fvCarStatusView.hidden = NO;
        [self.fvCarStatusView configView];
//        NSInteger fuelLevel = [[CustomerInfo sharedInstance].fuelLavel floatValue];
//        if ([SOSVehicleVariousStatus gasStatus] == GAS_YELLOW) {
//            self.circleView.fillStrokeColor = [UIColor colorWithHexString:STATUS_YELLOW];
//
//        }else if ([SOSVehicleVariousStatus gasStatus] == GAS_RED)
//        {
//            self.circleView.fillStrokeColor = [UIColor colorWithHexString:STATUS_RED];
//
//        }else{
//            self.circleView.fillStrokeColor = [UIColor colorWithHexString:STATUS_GREEN];
//        }
//
//        self.circleView.animationValue = fuelLevel;
        self.fvHeight.constant = 120;
        self.evHeight.constant = 0;
        self.evView.hidden = YES;
        [self.fvView configFVView];
    }
    [self.PDView configView];
    [self.view layoutIfNeeded];
}

//- (SOSCircleAnimation *)circleView {
//    if (!_circleView) {
//        _circleView = [[SOSCircleAnimation alloc] initWithFrame:self.fuelOilCircleView.bounds strokeVaule:0 withRadius:85.f];
//        self.circleView.backgroundStrokeColor = [UIColor colorWithHexString:@"E2E6EA"];
//        [self.fuelOilCircleView addSubview:self.circleView];
//    }
//    return _circleView;
//}


- (void)setupUpdateTime
{
    self.updateLabel.hidden = NO;
    
    if ([[CustomerInfo sharedInstance].timeYear length] <= 0)
    {
        self.updateLabel.text = [NSString stringWithFormat:@"%@%@",@"",@""];
    }
    else
    {
        NSString *month = [CustomerInfo sharedInstance].timeMonth;
        NSString *day = [CustomerInfo sharedInstance].timeDay;
        NSString *hour = [CustomerInfo sharedInstance].timeHour;
        NSString *minute = [CustomerInfo sharedInstance].timeMinute;
        NSString *timeSecond = [CustomerInfo sharedInstance].timeSecond;
        NSString *timeYear = [CustomerInfo sharedInstance].timeYear;
        NSString *completTime = [NSString stringWithFormat:@"%@年%@月%@日 %@:%@:%@" , timeYear, month, day, hour, minute,timeSecond];
        NSString *dateStringFormat = @"YYYY年MM月dd日 HH:mm:ss";
        NSDate *date = [NSDate dateWithString:completTime format:dateStringFormat];
        
        
        NSString *time = [SOSDateFormatter gapTimeStrFromNowWithDate:date];
        if ([time isEqualToString:@"刚刚"]) {
            time = @"刚刚更新";
            self.updateLabel.text = [NSString stringWithFormat:@"%@",time];
        }else{
            self.updateLabel.text = [NSString stringWithFormat:@"%@%@",@"更新于",time];
        }
    }
}

#pragma mark 设置Lable的text
- (void)setLable:(NSArray *)infos     {
    if([infos count] < 2) return;
    [(UILabel *)[infos objectAtIndex:0] setText:[infos objectAtIndex:1]];
}

- (IBAction)repairAdvices:(id)sender {
    [SOSDaapManager sendActionInfo:CarConditions_maintainsuggest];

    CarStatusDetailViewController *statusViewController = [[CarStatusDetailViewController alloc] initWithNibName:@"CarStatusDetailViewController" bundle:nil];
    statusViewController.gasStatus = [SOSVehicleVariousStatus gasStatus];
    statusViewController.oilStatus = [SOSVehicleVariousStatus oilStatus];
    statusViewController.pressureStatus = [SOSVehicleVariousStatus tirePressureStatus];
    statusViewController.mileage = [[CustomerInfo sharedInstance].oDoMeter floatValue];
    statusViewController.batteryStatus = [SOSVehicleVariousStatus batteryStatus];
    [self.navigationController pushViewController:statusViewController animated:YES];
}

- (IBAction)pushVehicleReportVc:(id)sender
{
    [SOSDaapManager sendActionInfo:CarConditions_OVD];
    [SOSCardUtil routerToVehicleDetectionReport];
}

- (void)routerToCarSetting {
    [SOSDaapManager sendActionInfo:VEHICLE_CAR_CONDITION_VEHICLE_SETTING];
    [SOSCardUtil routerToVehicleInfo];
}

//- (void)monthlyReportTapped{
//    //[[SOSReportService shareInstance] recordActionWithFunctionID:CarConditions_Diagnostics];
//    ViewControllerAssistantOVDEmail *detail = [[ViewControllerAssistantOVDEmail alloc]initWithNibName:@"ViewControllerAssistantOVDEmail" bundle:nil];
//    [self.navigationController pushViewController:detail animated:YES];
//
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SOSBEVViewDelegate
- (void)pushChargeStationVc		{
    [SOSDaapManager sendActionInfo:CarConditions_searchnearbycharger];

    //[[SOSReportService shareInstance] recordActionWithFunctionID:CarConditions_ChargeStations];
    SOSTripChargeVC *chargeStationVC = [[SOSTripChargeVC alloc] init];
    chargeStationVC.carConditionPush = YES;
    chargeStationVC.mapType = MapTypeChargeStationList;
    [self.navigationController pushViewController:chargeStationVC animated:YES];
}

- (void)pushSettingVc		{
    [SOSDaapManager sendActionInfo:CarConditions_chargesetting];
//
//    SOSSettingViewController *remindsetVc = [[SOSSettingViewController alloc] init];
//    remindsetVc.segmentVC.segmentBar.selectIndex = 1;
//    [self.navigationController pushViewController:remindsetVc animated:YES];
//
    [self chargeModeTapped];
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
@end
