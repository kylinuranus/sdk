//
//  SOSTripBaseMapVC.m
//  Onstar
//
//  Created by Coir on 2019/4/4.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSChangeVehicleViewController.h"
#import "SOSLBSProtocolView.h"
#import "SOSTripBaseMapVC.h"
#import "SOSSearchBarView.h"
#import "SOSUserLocation.h"
#import "SOSNavigateTool.h"
#import "SOSTripNavView.h"
#import "SOSRemoteTool.h"
#import "SOSLBSHeader.h"

#import "NSObject+RACSelectorSignal.h"

extern NSString *KMapVCEnterFullscreenNotify;

@interface SOSTripBaseMapVC () <UIGestureRecognizerDelegate>
/// 初始化时传入的 POI 点
@property (nonatomic, strong, readwrite) SOSPOI *infoPOI;

@property (nonatomic, assign) float originTableViewOffsetY;

@end

@implementation SOSTripBaseMapVC

#pragma mark - Life Cycle

- (id)initWithPOI:(SOSPOI *)poi        {
    self = [self init];
    if (self && poi) {
        self.infoPOI = [poi copy];
        self.selectedPOI = [poi copy];
    }
    return self;
}

- (instancetype)init	{
    return [super initWithNibName:@"SOSTripBaseMapVC" bundle:[NSBundle SOSBundle]];
}

- (void)viewDidLoad     {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    
    [self initSearchOBJ];
    [self configView];
    [self addObserver];
}

- (void)initSearchOBJ  {
    self.searchOBJ = [BaseSearchOBJ new];
    self.searchOBJ.poiDelegate = self;
    self.searchOBJ.geoDelegate = self;
    self.searchOBJ.errorDelegate = self;
    self.searchOBJ.needNoticeError = YES;
}

- (void)setMapType:(MapType)mapType		{
    // 为了调用 ViewDidload 方法,勿删
    self.view.backgroundColor = self.view.backgroundColor;
    _mapType = mapType;
    float statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
//#if SOSSDK_SDK
//    self.topNavTopGuide.constant = 5;
//#else
    self.topNavTopGuide.constant = statusBarHeight + 5;
//#endif
    if (SOS_CD_PRODUCT || SOS_MYCHEVY_PRODUCT) {
        self.cardBGViewTopGuide.constant = 0;
    }else{
        self.cardBGViewTopGuide.constant = 40;
    }
    self.topNavLeadingGuide.constant = 0.f;
    switch (mapType) {
        // Trip 首页
        case MapTypeRootWindow:
            self.topNavHeightGuide.constant = 34.f;
            self.cardBGViewHeightGuide.constant = 160.f;
            self.cardBGViewBottomGuide.constant = 25.f;
            break;
        // 显示 POI 详情
        case MapTypeShowPoiPoint:
        // 经销商详情
        case MapTypeShowDealerPOI:
        // 地图展示Poi点, 从列表模式进入,需显示 "查看更多"
        case MapTypeShowPoiPointFromList:
        // 展示住家地址
        case MapTypeShowHomeAddress:
        // 展示公司地址
        case MapTypeShowCompanyAddress:
        // 选点模式,带有 查看更多 ,用于选择 住家/公司/路线起终点/围栏中心点 等
        case MapTypePickPointFromList:
            self.topNavHeightGuide.constant = 49.f;
            self.cardBGViewHeightGuide.constant = 160.f;
            self.cardBGViewBottomGuide.constant = 12.f;
            break;
        // 加油站详情(第三方油站),带有 查看更多
        case MapTypeOilDetail:
            self.topNavHeightGuide.constant = 49.f;
            self.cardBGViewHeightGuide.constant = 219.f;
            self.cardBGViewBottomGuide.constant = 12.f;
            break;
        // 选点模式,用于选择 住家/公司/路线起终点/围栏中心点 等
        case MapTypePickPoint:
            self.topNavHeightGuide.constant = 34.f;
            self.cardBGViewHeightGuide.constant = 123.f;
            self.cardBGViewBottomGuide.constant = 12.f;
            break;
        // 充电桩详情
        case MapTypeShowChargeStation:
            self.topNavHeightGuide.constant = 49.f;
            self.cardBGViewHeightGuide.constant = 220.f;
            self.cardBGViewBottomGuide.constant = 12.f;
            break;
        // 充电桩列表
        case MapTypeChargeStationList:
            self.topNavHeightGuide.constant = 49.f;
            self.cardBGViewHeightGuide.constant = 290.f;
            self.cardBGViewBottomGuide.constant = 0;
            self.cardBGViewTopGuide.constant = 10.f;
            break;
        // 加油站列表
        case MapTypeOil:
            self.topNavHeightGuide.constant = 49.f;
            self.cardBGViewHeightGuide.constant = 320.f;
            self.cardBGViewBottomGuide.constant = 0;
            break;
        // 搜索结果列表
        case MapTypeShowPoiList:
            self.topNavHeightGuide.constant = 49.f;
            self.cardBGViewHeightGuide.constant = 260.f;
            self.cardBGViewBottomGuide.constant = 0;
            break;
        // 规划路线
        case MapTypeShowRoute:
            self.topNavTopGuide.constant = 0;
            self.cardBGViewTopGuide.constant = 40.f;
            self.topNavHeightGuide.constant = statusBarHeight + 83.f;
            self.cardBGViewHeightGuide.constant = 160.f;
            self.cardBGViewBottomGuide.constant = 12.f;
            break;
        default:
            self.cardBGViewBottomGuide.constant = 12.f;
            break;
    }
    [self.view layoutIfNeeded];
}

- (void)configView  {
    self.funcButtonBGView.funcCloseButtonArray = @[_userLocationCloseButton, _vehicleCloseButton, _lbsCloseButton];
    
    self.mapView = [[BaseMapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.mapView.annotationDelegate = self;
    [self.view layoutIfNeeded];
    [self.mapBGView addSubview:_mapView];
    [_mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.mapBGView);
    }];
}

- (void)viewDidAppear:(BOOL)animated     {
    [super viewDidAppear:animated];
}

- (void)addObserver        {
    __weak __typeof(self) weakSelf = self;
    // 监测登录状态变更
    [[[LoginManage sharedInstance] rac_valuesAndChangesForKeyPath:@"loginState" options:NSKeyValueObservingOptionNew observer:self] subscribeNext:^(RACTwoTuple<id,NSDictionary *> *x) {
        id newValue = x.first;
        if ([newValue isKindOfClass:[NSNumber class]]) {
            LOGIN_STATE_TYPE newState = [newValue intValue];
            switch (newState) {
                    // 用户退出登录
                case LOGIN_STATE_NON:
                    // 移除之前车辆定位点
                    [weakSelf.mapView removePoiPoint:weakSelf.vehiclePOI];
                    weakSelf.vehiclePOI = nil;
                    // 恢复卡片状态
                    for (UIButton *funcButton in @[weakSelf.userLocationButton, weakSelf.vehicleLocationButton, weakSelf.lbsButton]) {
                        if (funcButton.isSelected)        [weakSelf funcCloseButtonTapped:funcButton];
                    }
                    break;
                case LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS:    {
                    SOSPOI *cachedPOI = [[SOSRemoteTool sharedInstance] loadSavedVehicleLocation];
                    if (cachedPOI && cachedPOI.isValidLocation) {
                        cachedPOI.sosPoiType = POI_TYPE_VEHICLE_LOCATION;
                        weakSelf.vehiclePOI = cachedPOI;
                        [weakSelf showPOIInfo:weakSelf.vehiclePOI NeedUpdateMap:NO];
                    }
                    break;
                }
                default:
                    break;
            }
        }
    }];
    // 监测 车辆位置 指令下发状态
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOS_VEHICLE_OPERATE_NOTIFICATION object:nil] subscribeNext:^(NSNotification *noti) {
        //@{@"state":@(RemoteControlStatus_OperateSuccess), @"OperationType" : @(type), @"message": message}
        NSDictionary *info = noti.userInfo;
        if ([info[@"OperationType"] intValue] == SOSRemoteOperationType_VehicleLocation) {
            RemoteControlStatus status = [info[@"state"] intValue];
            switch (status) {
                case RemoteControlStatus_Void:
                    break;
                case RemoteControlStatus_InitSuccess:
                    break;
                case RemoteControlStatus_OperateSuccess:    {
                    NSDictionary *carInfoDic = info[@"CarPOIInfo"];
                    if (carInfoDic.count)     [weakSelf showVehicleLocation:carInfoDic NeedUpdateCard:YES];
                    break;
                }
                case RemoteControlStatus_OperateFail:
                case RemoteControlStatus_OperateTimeout:
					
                    break;
                default:
                    break;
            }
        }
    }];
}

- (BOOL)shouldShowVehicleLocation    {
    return YES;
}

#pragma mark - Map Annotation Delegate
//用户点击地图 POI 点
- (void)mapDidSelectedPoiPoint:(SOSPOI *)poi    {
}

- (void)mapDidRefreshUserLocation:(SOSPOI *)userLocationPoi Success:(BOOL)success        {
    if (success) {
        self.currentPOI = userLocationPoi;
        [self showPOIInfo:userLocationPoi NeedUpdateMap:NO];
    }
}


#pragma mark - Button Action
/// 路况
- (IBAction)trafficButtonTapped:(UIButton *)sender  {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [SOSDaapManager sendActionInfo:Trip_GoWhere_Map_TrafficOn];
        self.mapView.showTraffic = YES;
        double zoomLevel = self.mapView.zoomLevel;
        if (zoomLevel >= 16) {
            self.mapView.zoomLevel = 16;
        }
    }   else    {
        [SOSDaapManager sendActionInfo:Trip_GoWhere_Map_TrafficOff];
        self.mapView.showTraffic = NO;
    }
}

- (void)showVehicleLocation:(NSDictionary *)dic NeedUpdateCard:(BOOL)needUpdate         {
    self.vehiclePOI = [SOSPOI mj_objectWithKeyValues:dic];
    self.vehiclePOI.sosPoiType = POI_TYPE_VEHICLE_LOCATION;
    [self showPOIInfo:self.vehiclePOI NeedUpdateMap:needUpdate];
}

/// 车辆定位
- (IBAction)vehicleLocationButtonTapped     {
    [SOSDaapManager sendActionInfo:Trip_GoWhere_Map_CarLocation];
    [[SOSRemoteTool sharedInstance] startOperationWithOperationType:SOSRemoteOperationType_VehicleLocation];
}

/// 显示当前车辆定位, ShouldResetMap 是否重置地图中心 & 缩放
- (void)showVehiclePOIShouldResetMap:(BOOL)reset	{
    SOSRemoteTool *remoteTool = [SOSRemoteTool sharedInstance];
    [self.mapView removeCarLocationPoint];
    
    if (remoteTool.operationStastus == RemoteControlStatus_InitSuccess && remoteTool.lastOperationType == SOSRemoteOperationType_VehicleLocation) {
        [Util toastWithMessage:@"正在为您连接中,请稍候"];
        return;
    }
    // 优先显示近期获取过的有效车辆位置
    SOSPOI *cachedPOI = [self getValidCachedVehiclePOI];
    if (cachedPOI) {
        [self showPOIInfo:cachedPOI NeedUpdateMap:reset];
    }
}

// 优先显示近期获取过的有效车辆位置
- (SOSPOI *)getValidCachedVehiclePOI		{
    SOSRemoteTool *remoteTool = [SOSRemoteTool sharedInstance];
    SOSPOI *cachedPOI = self.vehiclePOI;
    if (cachedPOI == nil)    cachedPOI = [CustomerInfo sharedInstance].carLocationPoi;
    if (cachedPOI == nil)   cachedPOI = [remoteTool loadSavedVehicleLocation];
    if (cachedPOI && cachedPOI.isValidLocation)	{
        cachedPOI.sosPoiType = POI_TYPE_VEHICLE_LOCATION;
        self.vehiclePOI = cachedPOI;
        return cachedPOI;
    }
	return nil;
}

/// 我的位置
- (IBAction)userLocationButtonTapped     {
    [SOSDaapManager sendActionInfo:Trip_GoWhere_Map_MyLocation];
    [self showUserPOIShouldResetMap:YES];
}

/// 显示当前用户定位, ShouldResetMap 是否重置地图中心 & 缩放
- (void)showUserPOIShouldResetMap:(BOOL)reset	{
    if ([[SOSUserLocation sharedInstance] checkAuthorize] == NO)    return;
    if (self.currentPOI) {
        [self showPOIInfo:self.currentPOI NeedUpdateMap:reset];
    }    else    {
        // 刷新用户定位
        [self.mapView refreshUserLocationPointShouldResetMapCenter:reset];
    }
}

/// LBS
- (IBAction)LBSButtonTapped    {
}

/// 检测用户 登录 / LBS协议 状态
- (BOOL)isUserReadyForUseLBSShouldShowProtocol:(BOOL)shouldShow    {
    return YES;
}

#pragma mark - View Transform
/// 点击滑条上关闭按钮
- (IBAction)funcCloseButtonTapped:(UIButton *)sender {
    [self hideFunBGViewWithFuncButton:sender];
}

/// 关闭左侧按钮滑条
- (void)hideFunBGViewWithFuncButton:(UIButton *)sender	{
    UIButton *funcButton = @[_userLocationButton, _vehicleLocationButton, _lbsButton][sender.tag - 1001];
    UIView *funcBGView = @[_userLocationFuncBGView, _vehicleLocationFuncBGView, _lbsFuncBGView][sender.tag - 1001];
    NSLayoutConstraint *funcGuide = @[_userLocationBGWidthGuide, _vehicleBGWidthGuide, _lbsBGWidthGuide][sender.tag - 1001];
    funcGuide.constant = 34;
    [UIView animateWithDuration:.3 animations:^{
        funcBGView.alpha = 0.3;
        [self.funcButtonBGView layoutIfNeeded];
    } completion:^(BOOL finished) {
        funcBGView.backgroundColor = [UIColor clearColor];
        funcBGView.alpha = 1;
        funcButton.selected = NO;
    }];
}

/// 展开左侧按钮滑条
- (IBAction)showFuncBGView:(UIButton *)sender {
    if (sender == _lbsButton)    {
        if (![self isUserReadyForUseLBSShouldShowProtocol:NO])        return;
    }
    
    if (sender.isSelected)    return;
    NSArray *buttonArray = @[_userLocationButton, _vehicleLocationButton, _lbsButton];
    UIButton *funcButton = buttonArray[sender.tag - 1001];
    for (UIButton *tempButton in buttonArray) {
        if (tempButton.isSelected == YES && tempButton != sender) {
            [self hideFunBGViewWithFuncButton:tempButton];
        }
    }
    UIView *funcBGView = @[_userLocationFuncBGView, _vehicleLocationFuncBGView, _lbsFuncBGView][sender.tag - 1001];
    self.funcButtonBGView.userInteractionEnabled = NO;
    funcBGView.alpha = 0.3;
    if (SOS_CD_PRODUCT) {
        funcBGView.backgroundColor = [UIColor cadiStytle];

    }else{
        funcBGView.backgroundColor = [UIColor colorWithHexString:@"304D8FBF"];
    }
    funcButton.selected = YES;
    NSLayoutConstraint *funcGuide = @[_userLocationBGWidthGuide, _vehicleBGWidthGuide, _lbsBGWidthGuide][sender.tag - 1001];
    funcGuide.constant = 136.5;
    [UIView animateWithDuration:.3 animations:^{
        [self.funcButtonBGView layoutIfNeeded];
        funcBGView.alpha = 1;
    }	completion:^(BOOL finished) {
        self.funcButtonBGView.userInteractionEnabled = YES;
    }];
}

/// 配置地图和卡片上 POI 信息展示
- (void)showPOIInfo:(SOSPOI *)poi NeedUpdateMap:(BOOL)needUpdate    {
    self.selectedPOI = poi;
    switch (poi.sosPoiType) {
        case POI_TYPE_CURRENT_LOCATION:
            // 此处使用高德地图默认定位点,不再额外添加定位点
            break;
        case POI_TYPE_VEHICLE_LOCATION:
            [self.mapView removeCarLocationPoint];
            [self.mapView addPoiPoint:poi];
            if (needUpdate)        [self.mapView showPoiPoints:@[poi]];
            break;
        default:
            break;
    }
}

#pragma mark - 外部调用
/// 显示路况,供外部调用
- (void)showTraffic:(NSNumber *)show    {
    if (!self.mapView.showTraffic) {
        [self trafficButtonTapped:self.trafficButton];
    }
}

/// 将车辆位置显示到地图上,供外部调用
- (void)showVehicleLocation:(NSDictionary *)dict     {
    [self vehicleLocationButtonTapped];
}

#pragma mark - 列表模式手势处理

- (void)setTargetTableView:(UITableView *)targetTableView	{
    _targetTableView = targetTableView;
    if (targetTableView == nil)        return;
    __weak __typeof(self) weakSelf = self;
    targetTableView.bounces = YES;
    targetTableView.decelerationRate = .7;

    [[targetTableView rac_valuesAndChangesForKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew observer:self] subscribeNext:^(RACTwoTuple<id,NSDictionary *> * _Nullable x) {
//        float tableViewOffset = tableView.contentOffset.y;
        if (weakSelf.targetTableView == nil)        return;
        BOOL isTableAtTopState = weakSelf.cardBGView.top == weakSelf.topNavBGView.bottom;
        //  列表不在最上方,不能滑动
        if (isTableAtTopState == NO) {
            targetTableView.scrollEnabled = NO;
            [weakSelf addPanGesForListMode];
        }	else if (isTableAtTopState == YES)	{
            [weakSelf addPanGesForListMode];
        }
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOS_Map_ScrollView_DidEndDecelerating object:nil] subscribeNext:^(NSNotification *x) {
        UITableView *notiTableView = x.object;
        if (notiTableView == weakSelf.targetTableView) {
            if (weakSelf.targetTableView.contentOffset.y == 0) {
                weakSelf.targetTableView.scrollEnabled = NO;
            }
        }
    }];
}

- (void)addPanGesForListMode    {
    if (self.panGesForListView)		return;
    self.panGesForListView = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAtCradBGView:)];
    self.panGesForListView.delegate = self;
    [self.cardBGView addGestureRecognizer:self.panGesForListView];
    
}

- (void)removePanGestureRecognizer	{
    if (self.panGesForListView) {
        [self.cardBGView removeGestureRecognizer:self.panGesForListView];
        self.targetTableView = nil;
        self.panGesForListView = nil;
    }
    self.cardBGViewTopGuideToSafeArea.priority = UILayoutPriorityDefaultLow;
    self.funcButtonBGView.hidden = NO;
    [self.view layoutIfNeeded];
}

- (void)panAtCradBGView:(UIPanGestureRecognizer *)panGes	{
    if (self.panGesForListView == nil) 		return;
    CGPoint point = [panGes translationInView:self. view];
    NSLog(@"%@", @(point.y));
    float originTopGuide = self.cardBGView.bottom - self.topNavBGView.bottom - self.cardBGViewHeightGuide.constant;
    if (panGes.state == UIGestureRecognizerStateBegan) {
        if (point.y > 0)	{
            // 下拉开始时,记录 TableView 初始 Offset
            self.originTableViewOffsetY = self.targetTableView.contentOffset.y;
        }
        
    }	else if (panGes.state == UIGestureRecognizerStateChanged) {
        // 上拉
        if (point.y < 0) {
            if (self.cardBGView.top <= self.topNavBGView.bottom)    	{
                // 已经在最顶部
                return;
            };
            self.funcButtonBGView.hidden = YES;
            self.cardBGViewTopGuideToSafeArea.priority = UILayoutPriorityDefaultHigh;
            
            self.cardBGViewTopGuideToSafeArea.constant = originTopGuide + point.y;
            
            // 下拉
        }    else    {
            // 最底部不能下拉
            if (self.cardBGView.height <= self.cardBGViewHeightGuide.constant)    return;
            self.funcButtonBGView.hidden = YES;
            self.cardBGViewTopGuideToSafeArea.priority = UILayoutPriorityDefaultHigh;
            
            self.cardBGViewTopGuideToSafeArea.constant = point.y;
        }
        [self.view layoutIfNeeded];
    }	else if (panGes.state == UIGestureRecognizerStateEnded) {
        // 下拉操作
        if (point.y > 0) {
            if (ABS(point.y) >= 100)	self.cardBGViewTopGuideToSafeArea.constant = originTopGuide;
        	else						self.cardBGViewTopGuideToSafeArea.constant = 0;
        // 上拉操作
        }    else    {
            if (ABS(point.y) >= 100)   	self.cardBGViewTopGuideToSafeArea.constant = 0;
            else                        self.cardBGViewTopGuideToSafeArea.constant = originTopGuide;
        }
        
        SOSSearchBarView * searchBarView = nil;
        for (UIView *view in self.topNavBGView.subviews) {
            if ([view isKindOfClass:[SOSSearchBarView class]])	{
                searchBarView = (SOSSearchBarView *)view;
                break;
            }
        }
        
        [UIView animateWithDuration:.3 animations:^{
            [self.view layoutIfNeeded];
        }	completion:^(BOOL finished) {
            /// 恢复底部状态, 显示地图
            if (self.cardBGViewTopGuideToSafeArea.constant == originTopGuide) {
                self.funcButtonBGView.hidden = NO;
                if (searchBarView)		searchBarView.viewMode = SOSSearchBarViewMode_Detail;
                self.targetTableView.scrollEnabled = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:KMapVCEnterFullscreenNotify object:@(NO)];
            /// 恢复顶部状态, 遮住地图
            }	else	{
                if (searchBarView)    	searchBarView.viewMode = SOSSearchBarViewMode_List;
                self.targetTableView.scrollEnabled = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:KMapVCEnterFullscreenNotify object:@(YES)];
            }
        }];
    }
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event		{
    
}

@end
