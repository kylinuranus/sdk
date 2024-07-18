//
//  SOSTripHomeVC.m
//  Onstar
//
//  Created by Onstar on 2018/11/17.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSChangeVehicleViewController.h"
#import "SOSSocialContactViewController.h"
#import "SOSTirpVehicleLocationView.h"
#import "SOSTripCardBGScrollView.h"
#import "SOSTripFuncButtonBGView.h"
#import "SOSTirpUserLocationView.h"
#import "SOSLBSBGScrollView.h"
#import "SOSLBSProtocolView.h"
#import "SOSUserLocation.h"
#import "SOSNavigateTool.h"
#import "SOSTripNavView.h"
#import "SOSRemoteTool.h"
#import "BaseSearchOBJ.h"
#import "SOSTripHomeVC.h"
#import "SOSLBSHeader.h"
#import "SOSCardUtil.h"


#ifndef SOSSDK_SDK
#import "SOSGroupTripNetworkEngine.h"
#import "SOSGroupTripCreateTeamController.h"
#import "SOSGroupTripTeam.h"
#import "SOSGroupTripMapVC.h"
#else
#import "SOSSDK.h"
#endif

extern NSString *kSOSServiceOptState;

extern NSString * const kSOSServiceSmartDriveOptState;
extern NSString * const kSOSServiceFuelDriveOptState;
extern NSString * const kSOSServiceEnergyDriveOptState;

/// 底部卡片位置 (仅针对 驾驶行为/油耗/能耗/足迹  卡片背景 Scroll View)
typedef enum {
    SOSTripCardPositionState_Non = 0,
    SOSTripCardPositionState_Bottom,
    SOSTripCardPositionState_Top
}   SOSTripCardPositionState;

/// 底部卡片展示类型
typedef enum {
    /// 驾驶行为/油耗/能耗/足迹  卡片背景 Scroll View
    SOSTripShowType_Cards = 1,
    /// 我的位置
    SOSTripShowType_UserLocation,
    /// 车辆位置
    SOSTripShowType_VehicleLocation,
    /// LBS 卡片背景 Scroll View
    SOSTripShowType_LBS
}   SOSTripShowType;

@interface SOSTripHomeVC ()

/// 顶部自定义 Nav
@property (nonatomic, strong) SOSTripNavView *tripNavView;

/// 我的位置卡片
@property (nonatomic, strong) SOSTirpUserLocationView *userLocationView;
/// 车辆位置卡片
@property (nonatomic, strong) SOSTirpVehicleLocationView *vehicleLocationView;
/// LBS 卡片背景 Scroll View
@property (nonatomic, strong) SOSLBSBGScrollView *LBSBGScrollView;
/// 驾驶行为/油耗/能耗/足迹  卡片背景 Scroll View
@property (nonatomic, strong) SOSTripCardBGScrollView *tripCardBGScrollView;
/// 底部卡片位置 (仅针对 驾驶行为/油耗/能耗/足迹  卡片背景 Scroll View)
@property (nonatomic, assign) SOSTripCardPositionState cardPositionState;
/// 底部卡片展示类型
@property (nonatomic, assign) SOSTripShowType cardShowType;

@property (nonatomic, copy) completedBlock vehicleResultBlock;

@property (nonatomic, strong) SOSLBSPOI *lbsPOI;

@end

@implementation SOSTripHomeVC


#pragma mark - Life Cycle

- (instancetype)init    {
    self = [self initWithNibName:@"SOSTripBaseMapVC" bundle:[NSBundle SOSBundle]];
    if (self) {
        //todofix
//        self.mapType = MapTypeRootWindow;
    }
    return self;
}

- (void)viewDidLoad     {
    [super viewDidLoad];
    self.mapType = MapTypeRootWindow;
    #if SOSSDK_SDK
        self.fd_prefersNavigationBarHidden = NO;
        self.navigationItem.title = @"安吉星";
        UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [button1 setImage:[[UIImage imageNamed:@"common_Nav_Back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        button1.size = CGSizeMake(30, 44);
        [button1 addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            [SOSSDK sos_dismissOnstarModule];
        }];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button1];
        
    #else
        self.fd_prefersNavigationBarHidden = YES;
    #endif
}

- (void)configView  {
    [super configView];
    self.topStatusBarView.hidden = YES;
    self.funcButtonBGViewHeightGuide.constant = 134.f;
    self.cardBGViewBottomGuide.constant = 25.f;
    if (SOS_CD_PRODUCT || SOS_MYCHEVY_PRODUCT) {
        self.trafficButton.hidden = YES;
        self.lbsFuncBGView.hidden = YES;
        self.lbsButton.hidden = YES;
        self.userLocationFuncBGView.hidden = YES;
        self.userLocationButton.hidden = YES;
        if (SOS_CD_PRODUCT) {
            [self.vehicleLocationButton setImage:[UIImage imageNamed:@"Trip_car_location_Normal_sdkcd"] forState:UIControlStateNormal];
            [self.vehicleLocationButton setImage:[UIImage imageNamed:@"Trip_car_location_Normal_sdkcd"] forState:UIControlStateSelected];
        }

    }else{
        self.lbsFuncBGView.hidden = NO;
        self.lbsButton.hidden = NO;
    }
    if (SOS_BUICK_PRODUCT) {
        [self.lbsButton setImage:[UIImage imageNamed:@"Trip_LBS_Button_sdkbuick"] forState:0];
        [self.vehicleLocationButton setImage:[UIImage imageNamed:@"Trip_car_location_Normal_sdkbuick"] forState:0];
        [self.userLocationButton setImage:[UIImage imageNamed:@"Trip_location_sdkbuick"] forState:0];
        [self.trafficButton setImage:[UIImage imageNamed:@"Trip_Traffic_light_sdkbuick"] forState:0];
    }
    if (! (SOS_CD_PRODUCT || SOS_MYCHEVY_PRODUCT)) {
        self.tripNavView = [SOSTripNavView viewFromXib];
           self.tripNavView.frame = CGRectMake(20, 0, SCREEN_WIDTH - 40, 34);
           [self.topNavBGView addSubview:self.tripNavView];
    }
    
    if (SOS_CD_PRODUCT || SOS_MYCHEVY_PRODUCT) {
        for (UIButton *button in @[ self.vehicleLocationGuideButton]) {
               UIImage *img = [UIImage imageNamed:@"Trip_Card_Button_Instruction_BG"];
               img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
               [button setBackgroundImage:img forState:UIControlStateNormal];
               button.hidden = NO;
           }
    }else{
       for (UIButton *button in @[self.userLocationGuideButton, self.vehicleLocationGuideButton, self.lbsGuideButton]) {
            UIImage *img = [UIImage imageNamed:@"Trip_Card_Button_Instruction_BG"];
            img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
            [button setBackgroundImage:img forState:UIControlStateNormal];
            button.hidden = NO;
        }
    }
    
    self.tripCardBGScrollView = [SOSTripCardBGScrollView viewFromXib];
    self.tripCardBGScrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 160);
    [self.cardBGView addSubview:self.tripCardBGScrollView];
    self.userLocationView = [SOSTirpUserLocationView viewFromXib];
    self.userLocationView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 160);
    self.userLocationView.delegate = self;
    
    self.vehicleLocationView = [SOSTirpVehicleLocationView viewFromXib];
    
    self.vehicleLocationView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 160);
    self.vehicleLocationView.delegate = self;
    
    self.LBSBGScrollView = [SOSLBSBGScrollView viewFromXib];
    self.LBSBGScrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 160);
    self.LBSBGScrollView.cardDelegate = self;
    if (@available(iOS 11.0, *)) {
        self.LBSBGScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
#ifndef SOSSDK_SDK
    __weak __typeof(self) weakSelf = self;
    /// 添加社交接人 Button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"icon_trip_function_meet_def"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(ridButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    button.layer.shadowColor = [UIColor colorWithHexString:@"6570B5"].CGColor;
    button.layer.shadowOpacity = .2f;
    button.layer.shadowOffset = CGSizeMake(0, 3);
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.right.mas_equalTo(weakSelf.trafficButton);
        make.top.mas_equalTo(weakSelf.trafficButton.mas_bottom).mas_offset(30);
    }];


    // 添加组队出行 Button
    UIButton *groupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [groupButton setImage:[UIImage imageNamed:@"Group_Trip_icon_entrance"] forState:UIControlStateNormal];
    // 组队出行入口
    [[groupButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [weakSelf enterGroupTripVC];
    }];
    [self.view addSubview:groupButton];
    groupButton.layer.shadowColor = [UIColor colorWithHexString:@"6570B5"].CGColor;
    groupButton.layer.shadowOpacity = .2f;
    groupButton.layer.shadowOffset = CGSizeMake(0, 3);
    [groupButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.right.mas_equalTo(button);
        make.top.mas_equalTo(button.mas_bottom).mas_offset(30);
    }];
#endif

    [self.view layoutIfNeeded];
    //    [self.mapView refreshUserLocationPoint];
}

- (void)setVehicleLocationResultBlockWhenArrear:(completedBlock)block	{
    self.vehicleResultBlock = block;
}

- (void)viewDidAppear:(BOOL)animated     {
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self.cardShowType) {
            [self.tripCardBGScrollView startAnimating];
            self.cardShowType = SOSTripShowType_Cards;
            [self.mapView refreshUserLocationPoint];
        }
    });
    if (self.vehicleResultBlock)	{
        self.vehicleResultBlock();
        self.vehicleResultBlock = nil;
    }
    if (self.tripCardBGScrollView.shouldReloadOilData) {
        [self.tripCardBGScrollView reloadOliData];
        self.tripCardBGScrollView.shouldReloadOilData = NO;
    }
    if (self.tripCardBGScrollView.shouldReloadEnergyData) {
        [self.tripCardBGScrollView reloadEnergyData];
        self.tripCardBGScrollView.shouldReloadEnergyData = NO;
    }
    if (self.tripCardBGScrollView.shouldReloadDriveBehiverData) {
        [self.tripCardBGScrollView reloadDriveBehiverData];
        [self.tripCardBGScrollView reloadTrailCardData];
        self.tripCardBGScrollView.shouldReloadDriveBehiverData = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated	{
    [super viewWillDisappear:animated];
    [Util dismissHUD];
}

- (void)setCardShowType:(SOSTripShowType)cardShowType	{
    _cardShowType = cardShowType;
    [self hideTopNavView:@(NO)];
}

- (void)addObserver		{
    __weak __typeof(self) weakSelf = self;
    // 监测设置页面开关状态变化
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kSOSServiceOptState object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSDictionary *dic = x.object;
        if (dic.count == 0)        return;
        if ([dic objectForKey:kSOSServiceSmartDriveOptState]) {
            weakSelf.tripCardBGScrollView.shouldReloadDriveBehiverData = YES;
        }
        
        if ([dic objectForKey:kSOSServiceFuelDriveOptState]) {
            weakSelf.tripCardBGScrollView.shouldReloadOilData = YES;
        }
        
        if ([dic objectForKey:kSOSServiceEnergyDriveOptState]) {
            weakSelf.tripCardBGScrollView.shouldReloadEnergyData = YES;
        }
    }];
    // 监测登录状态变更
    [[[LoginManage sharedInstance] rac_valuesAndChangesForKeyPath:@"loginState" options:NSKeyValueObservingOptionNew observer:self] subscribeNext:^(RACTwoTuple<id,NSDictionary *> *x) {
        id newValue = x.first;
        if ([newValue isKindOfClass:[NSNumber class]]) {
            LOGIN_STATE_TYPE newState = [newValue intValue];
            dispatch_async_on_main_queue(^{
                switch (newState) {
                        // 用户退出登录
                    case LOGIN_STATE_NON:
                        // 移除之前车辆定位点
                        [self.mapView removePoiPoint:self.vehiclePOI];
                        self.vehiclePOI = nil;
                        // 恢复卡片状态
                        for (UIButton *funcButton in @[self.userLocationButton, self.vehicleLocationButton, self.lbsButton]) {
                            if (funcButton.isSelected)        [self funcCloseButtonTapped:funcButton];
                        }
                        break;
                    case LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS:    {
                        SOSPOI *cachedPOI = [[SOSRemoteTool sharedInstance] loadSavedVehicleLocation];
                        if (cachedPOI && cachedPOI.isValidLocation) {
                            cachedPOI.sosPoiType = POI_TYPE_VEHICLE_LOCATION;
                            self.vehiclePOI = cachedPOI;
                            [self showPOIInfo:self.vehiclePOI NeedUpdateMap:YES];
                        }
                        break;
                    }
                    default:
                        break;
                }
            });
        }
    }];
    // 监测车辆位置指令下发状态
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOS_VEHICLE_OPERATE_NOTIFICATION object:nil] subscribeNext:^(NSNotification *noti) {
        //@{@"state":@(RemoteControlStatus_OperateSuccess), @"OperationType" : @(type), @"message": message}
        NSDictionary *info = noti.userInfo;
        if ([info[@"OperationType"] intValue] == SOSRemoteOperationType_VehicleLocation) {
            RemoteControlStatus status = [info[@"state"] intValue];
            dispatch_async_on_main_queue(^{
                switch (status) {
                    case RemoteControlStatus_Void:
                        break;
                    case RemoteControlStatus_InitSuccess:
                        [self showFuncBGView:self.vehicleLocationButton];
                        self.vehicleLocationView.cardStatus = SOSVehicleLocationCardStatus_loading;
                        [self showCardView:self.vehicleLocationView];
                        self.cardShowType = SOSTripShowType_VehicleLocation;
                        break;
                    case RemoteControlStatus_OperateSuccess:    {
                        NSDictionary *carInfoDic = info[@"CarPOIInfo"];
                        if (carInfoDic.count)     [self showVehicleLocation:carInfoDic NeedUpdateCard:(self.cardShowType == SOSTripShowType_VehicleLocation)];
                        break;
                    }
                    case RemoteControlStatus_OperateFail:
                    case RemoteControlStatus_OperateTimeout:
                        self.vehicleLocationView.cardStatus = SOSVehicleLocationCardStatus_fail;
                        break;
                    default:
                        break;
                }
            });
        }
    }];
}

- (BOOL)shouldShowVehicleLocation	{
    return YES;
}

#pragma mark - Map Annotation Delegate
//用户点击地图 POI 点
- (void)mapDidSelectedPoiPoint:(SOSPOI *)poi    {
    switch (poi.sosPoiType) {
        case POI_TYPE_CURRENT_LOCATION:
            [self showFuncBGView:self.userLocationButton];
            [self.userLocationView refreshTimeLabel];
            [self showCardView:self.userLocationView];
            break;
        case POI_TYPE_VEHICLE_LOCATION:
            [self showFuncBGView:self.vehicleLocationButton];
            [self.vehicleLocationView refreshTimeLabel];
            [self showCardView:self.vehicleLocationView];
            break;
        default:
            break;
    }
}

- (void)mapDidRefreshUserLocation:(SOSPOI *)userLocationPoi Success:(BOOL)success		{
    if (success) {
        self.currentPOI = userLocationPoi;
        self.userLocationView.cardStatus = SOSUserLocationCardStatus_success;
        self.userLocationView.userLocationPOI = userLocationPoi;
        [self showPOIInfo:userLocationPoi NeedUpdateMap:(self.cardShowType == SOSTripShowType_UserLocation)];
    }	else	{
        self.userLocationView.cardStatus = SOSUserLocationCardStatus_fail;
    }
}

#pragma mark - Button Action
/// 路况
- (IBAction)trafficButtonTapped:(UIButton *)sender  {
    [self hideGuideButton];
    [super trafficButtonTapped:sender];
}

/// 路况
- (void)ridButtonTapped:(UIButton *)sender  {
    NSLog(@"rid");
    [SOSDaapManager sendActionInfo:Map_Pickup];
    SOSSocialContactViewController *vc = [[SOSSocialContactViewController alloc] initWithNibName:@"SOSSocialContactViewController" bundle:nil];
    [SOSCardUtil routerToVc:vc checkAuth:YES checkLogin:YES];
}

- (void)showVehicleLocation:(NSDictionary *)dic NeedUpdateCard:(BOOL)needUpdate 		{
    [self hideGuideButton];
    self.vehiclePOI = [SOSPOI mj_objectWithKeyValues:dic];
    self.vehiclePOI.sosPoiType = POI_TYPE_VEHICLE_LOCATION;
    [self showPOIInfo:self.vehiclePOI NeedUpdateMap:needUpdate];
    self.vehicleLocationView.cardStatus = SOSVehicleLocationCardStatus_success;
    self.vehicleLocationView.vehicleLocationPOI = self.vehiclePOI;
    if (needUpdate)		[self showCardView:self.vehicleLocationView];
}

/// 车辆定位
- (IBAction)vehicleLocationButtonTapped     {
    [self hideGuideButton];
    [SOSDaapManager sendActionInfo:TRIP_VEHICLELOCATION];
    SOSRemoteTool *remoteTool = [SOSRemoteTool sharedInstance];
    [self.mapView removeCarLocationPoint];
    
    if (remoteTool.operationStastus == RemoteControlStatus_InitSuccess && remoteTool.lastOperationType == SOSRemoteOperationType_VehicleLocation) {
        [self showFuncBGView:self.vehicleLocationButton];
        self.vehicleLocationView.cardStatus = SOSVehicleLocationCardStatus_loading;
        [self showCardView:self.vehicleLocationView];
        self.cardShowType = SOSTripShowType_VehicleLocation;
        return;
    }
    // 优先显示近期获取过的有效车辆位置
    SOSPOI *cachedPOI = self.vehiclePOI;
    if (cachedPOI == nil)    cachedPOI = [CustomerInfo sharedInstance].carLocationPoi;
    if (cachedPOI == nil)   cachedPOI = [remoteTool loadSavedVehicleLocation];
    if (cachedPOI && cachedPOI.isValidLocation) {
        cachedPOI.sosPoiType = POI_TYPE_VEHICLE_LOCATION;
        self.vehiclePOI = cachedPOI;
        [self showPOIInfo:self.vehiclePOI NeedUpdateMap:YES];
        [self showFuncBGView:self.vehicleLocationButton];
        self.vehicleLocationView.cardStatus = SOSVehicleLocationCardStatus_success;
        self.vehicleLocationView.vehicleLocationPOI = cachedPOI;
        [self showCardView:self.vehicleLocationView];
        self.cardShowType = SOSTripShowType_VehicleLocation;
    }    else    {
        [[SOSRemoteTool sharedInstance] startOperationWithOperationType:SOSRemoteOperationType_VehicleLocation];
    }
}

//- (void)hideGlobleVehicleOperationToast    {}

/// 我的位置
- (IBAction)userLocationButtonTapped     {
    [SOSDaapManager sendActionInfo:TRIP_MYLOCATION];
    if ([[SOSUserLocation sharedInstance] checkAuthorize] == NO)	return;
    [self showFuncBGView:self.userLocationButton];
    self.cardShowType = SOSTripShowType_UserLocation;
    if (self.currentPOI) {
        [self.mapView setZoomLevel:19];
        [self showPOIInfo:self.currentPOI NeedUpdateMap:YES];
        [self showCardView:self.userLocationView];
    }	else	{
        [self forceRequestUserLocation];
    }
}

/// 强制重新请求用户定位
- (void)forceRequestUserLocation       {
    self.userLocationView.cardStatus = SOSUserLocationCardStatus_loading;
    [self showCardView:self.userLocationView];
    [self.mapView refreshUserLocationPoint];
}

/// LBS
- (IBAction)LBSButtonTapped	{
    [SOSDaapManager sendActionInfo:TRIP_LBS];
    if ([self isUserReadyForUseLBSShouldShowProtocol:YES]) {
        self.cardShowType = SOSTripShowType_LBS;
        self.LBSBGScrollView.viewMode = SOSLBSBGViewMode_List;
        [self showCardView:self.LBSBGScrollView];
    }
}

/// 检测用户 登录 / LBS协议 状态
- (BOOL)isUserReadyForUseLBSShouldShowProtocol:(BOOL)shouldShow    {
    // 检测登录状态
    if (![[LoginManage sharedInstance] isLoadingUserBasicInfoReady])    {
        [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:self withLoginDependence:[[LoginManage sharedInstance] isLoadingUserBasicInfoReady] showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {	}];
        return NO;
    }
    SOSLBSProtocolSavedStatus status = [SOSLBSDataTool getSavedUserProtocolSavedStatus];
    switch (status) {
        case SOSLBSProtocolSavedStatus_Unknnow:    {
            if (!shouldShow)	return NO;
            //协议状态未知,请求协议状态
            [SOSLBSDataTool getUserProtocolSavedStatusSuccess:^(BOOL protocolStatus) {
                // 用户已同意协议
                if (protocolStatus) {
                    [self showFuncBGView:self.lbsButton];
                    self.LBSBGScrollView.viewMode = SOSLBSBGViewMode_List;
                    [self showCardView:self.LBSBGScrollView];
                    // 用户未同意协议
                }    else       {
                    [SOSLBSDataTool showLBSProtocolViewWithCompleteHanlder:^(BOOL agreeStatus) {
                        if (agreeStatus) 	{
                            [SOSDaapManager sendActionInfo:TRIP_LBS_AGREE];
                            [self showLBSCardView];
                        }	else	{
                            [SOSDaapManager sendActionInfo:TRIP_LBS_THINKMORE];
                        }
                    }];
                }
            } Failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {    }];
            return NO;
        }
        case SOSLBSProtocolSavedStatus_Accepted:
            return YES;
        case SOSLBSProtocolSavedStatus_Rejected:
            if (shouldShow) 	{
                [SOSLBSDataTool showLBSProtocolViewWithCompleteHanlder:^(BOOL agreeStatus) {
                    if (agreeStatus)     {
                        [SOSDaapManager sendActionInfo:TRIP_LBS_AGREE];
                        [self showLBSCardView];
                    }    else    {
                        [SOSDaapManager sendActionInfo:TRIP_LBS_THINKMORE];
                    }
                }];
            };
            return NO;
        default:
            break;
    }
}

- (void)enterGroupTripVC	{
#ifndef SOSSDK_SDK
    [SOSDaapManager sendActionInfo:Vehicle_GroupToTravel];
    // 检测定位权限
    if (![[SOSUserLocation sharedInstance] checkAuthorize])    {
        return;
    }
    __weak __typeof(self) weakSelf = self;
    // 检测登录状态
    [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:weakSelf withLoginDependence:[[LoginManage sharedInstance] isLoadingUserBasicInfoReady] showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
        [Util showLoadingView];
        //1.先获取teamid
        //2.再获取team详情
        //3.获取不到则进入创建队伍界面
        [SOSGroupTripNetworkEngine fetchTeamIDWithCompletionBlock:^(NSString * _Nonnull data) {
            NSString *teamId = data;
            if (teamId.length > 0) {
                //有车队了
                [SOSGroupTripNetworkEngine fetchTeamWithTeamID:teamId CompletionBlock:^(id  _Nonnull data) {
                    [Util hideLoadView];
                    SOSGroupTripTeam *team = data;
                    
                    SOSGroupTripMapVC *vc = [SOSGroupTripMapVC new];
                    vc.teamInfo = team;
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                    
                } errorBlock:^(NSInteger statusCode, NSString * _Nonnull responseStr, NSError * _Nonnull error) {
                    [Util hideLoadView];
                    [Util showErrorHUDWithStatus:@"出错了,请重试"];
                }];
            }else {
                [Util hideLoadView];
                //无车队
                if (![SOSCheckRoleUtil checkVisitorInPage:self]) {
                    return;
                }
                SOSGroupTripCreateTeamController *vc = SOSGroupTripCreateTeamController.new;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
        } errorBlock:^(NSInteger statusCode, NSString * _Nonnull responseStr, NSError * _Nonnull error) {
            [Util hideLoadView];
            [Util showErrorHUDWithStatus:@"出错了,请重试"];
        }];
        
    }];
#endif
}

#pragma mark - Card Delegate
// UserLocation Card Delegate
- (void)refreshLocationButtonTapped		{
    [self forceRequestUserLocation];
}

// 车辆卡片点击刷新
- (void)refreshVehicleLocationButtonTapped	{
    [self.mapView removeCarLocationPoint];
    [[SOSRemoteTool sharedInstance] startOperationWithOperationType:SOSRemoteOperationType_VehicleLocation];
}

// 车辆卡片点击 切车
- (void)vehicleSwitchCarButtonTapped	{
    SOSChangeVehicleViewController *changeVc = [[SOSChangeVehicleViewController alloc] initWithNibName:@"SOSChangeVehicleViewController" bundle:nil];
    [self.navigationController pushViewController:changeVc animated:YES];
}

// LBS 卡片数据刷新
- (void)showDetailCardWithLBSPOI:(SOSLBSPOI *)lbsPOI shouldUpdateMapView:(BOOL)shouldUpdate		{
    self.lbsPOI = lbsPOI;
    [self.mapView addPoiPoint:self.lbsPOI];
    if (shouldUpdate)	[self.mapView showPoiPoints:@[self.lbsPOI]];
}

- (void)removeLBSPOI	{
    [self.mapView removePoiPoint:self.lbsPOI];
    [self.mapView showCachedPoiPoints];
    self.lbsPOI = nil;
}

#pragma mark - View Transform
/// 点击滑条上关闭按钮
- (IBAction)funcCloseButtonTapped:(UIButton *)sender {
    self.cardShowType = SOSTripShowType_Cards;
    [self showCardView:self.tripCardBGScrollView];
    [self.tripCardBGScrollView startAnimating];
    [self hideFunBGViewWithFuncButton:sender];
}

/// 关闭左侧按钮滑条
- (void)hideFunBGViewWithFuncButton:(UIButton *)sender{
    [super hideFunBGViewWithFuncButton:sender];
}

/// 展开左侧按钮滑条
- (IBAction)showFuncBGView:(UIButton *)sender {
    [self hideGuideButton];
    [super showFuncBGView:sender];
}

/// 切换底部卡片显示
- (void)showCardView:(UIView *)viewToAdd		{
    if (viewToAdd == nil)            		return;
    UIView *viewToRemove = nil;
    if (self.cardBGView.subviews.count)    viewToRemove = self.cardBGView.subviews[0];
    // 若viewToAdd 已在显示,不做操作
    if (viewToAdd == viewToRemove)			return;
    BOOL isCloseAction = (viewToAdd == self.tripCardBGScrollView);
    if (viewToRemove == self.LBSBGScrollView) {
        self.LBSBGScrollView.viewMode = SOSLBSBGViewMode_List;
    }
    dispatch_async_on_main_queue(^{
        // 若底部卡片在隐藏状态,则拉起
        [self moveCardToState:SOSTripCardPositionState_Top];
        
        isCloseAction ? [viewToAdd setLeft:SCREEN_WIDTH] : [viewToAdd setRight:0];
        viewToAdd.alpha = .3;
        [self.cardBGView addSubview:viewToAdd];
        self.funcButtonBGView.userInteractionEnabled = NO;
        [UIView animateWithDuration:.5 animations:^{
            if (viewToRemove)    {
                viewToRemove.alpha = .3;
                viewToRemove.top = 160;
            }
            viewToAdd.alpha = 1;
            viewToAdd.left = 0;
        }    completion:^(BOOL finished) {
            viewToRemove.alpha = 1;
            viewToRemove.top = 0;
            [viewToRemove removeFromSuperview];
            self.funcButtonBGView.userInteractionEnabled = YES;
        }];
    });
    
}

/// 显示 LBS 卡片
- (void)showLBSCardView        {
    [self showFuncBGView:self.lbsButton];
    self.LBSBGScrollView.viewMode = SOSLBSBGViewMode_List;
    [self showCardView:self.LBSBGScrollView];
}

/// 配置地图和卡片上 POI 信息展示
- (void)showPOIInfo:(SOSPOI *)poi NeedUpdateMap:(BOOL)needUpdate	{
    self.selectedPOI = poi;
    switch (poi.sosPoiType) {
        case POI_TYPE_CURRENT_LOCATION:
            self.userLocationView.userLocationPOI = poi;
            if (needUpdate)		{
                [self.mapView setCenterCoordinate:[poi getPOICoordinate2D] animated:YES];
                [self.mapView setZoomLevel:19 animated:YES];
            }
            break;
        case POI_TYPE_VEHICLE_LOCATION:
            self.vehicleLocationView.vehicleLocationPOI = poi;
            [self.mapView removeCarLocationPoint];
            [self.mapView addPoiPoint:poi];
            if (needUpdate)		[self.mapView showPoiPoints:@[poi]];
            break;
        default:
            break;
    }
}

/// 隐藏顶部自定义导航
- (void)hideTopNavView:(NSNumber *)hide					{
    if (self.tripNavView) {
        [self.tripNavView hideSelf:hide.boolValue];
    }
}

#pragma mark - 底部卡片滑动手势处理
- (void)moveTripCardBGScrollViewWithOffset:(float)offset	{
    if (self.cardPositionState == SOSTripCardPositionState_Top) {
        if (offset < 0)        return;
        if (self.cardBGViewBottomGuide.constant <= -110)         return;
        self.cardBGViewBottomGuide.constant = 25 - offset;
        [self.view layoutIfNeeded];
    }    else if (self.cardPositionState == SOSTripCardPositionState_Bottom)        {
        if (offset > 0)        return;
        if (self.cardBGViewBottomGuide.constant >= 25)         return;
        self.cardBGViewBottomGuide.constant = -110 - offset;
        [self.view layoutIfNeeded];
    }
}

- (void)moveEnded 	{
    if (self.cardBGViewBottomGuide.constant >= (- 110 + 25) / 2.f) 		[self moveCardToState:SOSTripCardPositionState_Top];
    else	[self moveCardToState:SOSTripCardPositionState_Bottom];
}

- (void)moveCardToState:(SOSTripCardPositionState)state		{
    //    if (self.cardPositionState == state)     return;
    float resultConstant = (state == SOSTripCardPositionState_Top) ? 25 : - 110;
    self.cardBGViewBottomGuide.constant = resultConstant;
    [UIView animateWithDuration:.2 animations:^{
        [self.view layoutIfNeeded];
    }    completion:^(BOOL finished) {
        self.tripCardBGScrollView.scrollEnabled = (state == SOSTripCardPositionState_Top);
        self.cardPositionState = state;
    }];
}

#pragma mark - 外部调用

- (void)showLBS     {
    [self showFuncBGView:self.lbsButton];
    [self LBSButtonTapped];
}
-(void)refreshFootPrint{
    [self.tripCardBGScrollView reloadFootPrintData];
}
#pragma mark - 隐藏引导按钮
- (void)hideGuideButton        {
    if (SOS_CD_PRODUCT || SOS_MYCHEVY_PRODUCT) {
        if ( self.vehicleLocationGuideButton == nil)     return;
        for (UIButton *button in @[ self.vehicleLocationGuideButton]) {
            button.hidden = YES;
        }
    }else{
        if (self.userLocationGuideButton.hidden || self.userLocationGuideButton == nil || self.vehicleLocationGuideButton == nil || self.lbsGuideButton == nil )     return;
        for (UIButton *button in @[self.userLocationGuideButton, self.vehicleLocationGuideButton, self.lbsGuideButton]) {
            button.hidden = YES;
        }
    }
   
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event    {
    [super touchesBegan:touches withEvent:event];
    [self hideGuideButton];
    UITouch *touch = touches.anyObject;
    if (touch.view == self.mapView || [touch.view isKindOfClass:NSClassFromString(@"MAAnnotationContainerView")]) {
        if (self.cardShowType == SOSTripShowType_Cards) {
            [self moveCardToState:SOSTripCardPositionState_Bottom];
        }
    }
}

@end
