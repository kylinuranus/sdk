//
//  SOSBaseMapVC.m
//  Onstar
//
//  Created by Shoujun Xue on 10/23/12.
//  Copyright (c) 2012 Shanghai Onstar. All rights reserved.
//
#import "SOSCheckRoleUtil.h"
#import "SOSUserLocation.h"
#import "SOSNavigateTool.h"
#import "BaseSearchOBJ.h"
#import "SOSTripRouteVC.h"
#import "SOSRemoteTool.h"
#import "CustomerInfo.h"
#import "SOSTripPOIVC.h"
#import "SOSBaseMapVC.h"

#define TAG_DO_NOTHING              0
#define TAG_NEED_RELOGIN            1
#define TAG_NEED_POP                2
#define CANCEL_SELECT_POINT_TIME    80
#define Limit_Error_Distance       	200

@interface SOSBaseMapVC () <PoiDelegate, RouteDelegate, GeoDelegate, ErrorDelegate, MAMapViewDelegate, AnnotationDelegate>
@end

@implementation SOSBaseMapVC

#pragma mark 标注当前位置
- (void)initShowOnMapAnnotations:(SOSPOI *)poiInfo     {
    NSLog(@"poix %@, poiy %@", poiInfo.x, poiInfo.y);
    // add poi location annotion
    poiInfo.sosPoiType = poiInfo.sosPoiType ?  poiInfo.sosPoiType : POI_TYPE_POI;
    if (poiInfo.sosPoiType != POI_TYPE_CURRENT_LOCATION
        && poiInfo.sosPoiType != POI_TYPE_VEHICLE_LOCATION) {
        [self.mapView refreshUserLocationPoint];
    }
}

- (id)initWithPoiInfo:(SOSPOI *)poiInfo		{
    self = [super initWithNibName:[self className] bundle:[NSBundle SOSBundle]];
    if (self) {
        if (poiInfo) {
            [self initShowOnMapAnnotations:poiInfo];
            self.mapType = MapTypeShowPoiPoint;
            self.selectedPOI = poiInfo;
            self.infoPOI = poiInfo;
        }
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil    {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.mapType = MapTypeRootWindow;
    }
    return self;
}

/// 获取当前需要在地图上显示的 POI 点
- (NSArray *)poisShowingOnMap    {
    NSMutableArray *poisShowingOnMap = [NSMutableArray array];
    SOSPOI *locationPOI = [CustomerInfo sharedInstance].currentPositionPoi;
    if (locationPOI)            [poisShowingOnMap addObject:locationPOI];
    SOSPOI *carLocatonPOI = [CustomerInfo sharedInstance].carLocationPoi;
    if (carLocatonPOI)          {
        carLocatonPOI.sosPoiType = POI_TYPE_VEHICLE_LOCATION;
        [poisShowingOnMap addObject:carLocatonPOI];
    }
    if (self.mapType == MapTypeShowRoute) {
        [poisShowingOnMap addObjectsFromArray:_routePoisArray];
    }   else    {
        if (self.infoPOI)               [poisShowingOnMap addObject:self.infoPOI];
    }
    if (self.mapType == MapTypeShowRVMirror) {
        if (poisShowingOnMap.count>1) {
            [poisShowingOnMap removeObjectAtIndex:0];
        }
    }
    NSLog(@"poisShowingOnMap count %lu",(unsigned long)poisShowingOnMap.count);
    return poisShowingOnMap;
}

#pragma mark - view
- (void)viewDidLoad     {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    
    [self initSearchOBJ];
    [self configView];
    
    // add subview map
    CGFloat KMapHeight = SCREEN_HEIGHT - (self.fd_prefersNavigationBarHidden == NO) * 64 - self.mapViewBottomGuide.constant;
    CGRect mapViewFrame = CGRectMake(0, 0, SCREEN_WIDTH, KMapHeight);
    self.mapView = [[BaseMapView alloc] initWithFrame:mapViewFrame];
//    self.mapView.autoresizingMask = UIViewAutoresizingNone;
    self.mapView.annotationDelegate = self;
    [self.view layoutIfNeeded];
    [self.contentMapView addSubview:_mapView];
    [_mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentMapView);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountVehicleHasChanged) name:SOS_ACCOUNT_VEHICLE_HAS_CHANGED object:nil];
}

- (void)initSearchOBJ  {
    searchOBJ = [BaseSearchOBJ new];
    searchOBJ.poiDelegate = self;
    searchOBJ.routeDelegate = self;
    searchOBJ.geoDelegate = self;
    searchOBJ.errorDelegate = self;
    searchOBJ.needNoticeError = YES;
}

/// 配置不同地图类型显示,交由子类实现
- (void)configView  {
}

- (void)viewWillAppear:(BOOL)animated     {
    [super viewWillAppear:animated];
    BOOL shouldShowCachePopits = YES;
    BOOL shouldShowCarPOI = YES;
    switch (self.mapType) {
        case MapTypeShowPoiPoint:
        case MapTypeShowChargeStation:
            return;
        case MapTypeShowFootPrintPoiPointsOverViewMode:
        case MapTypeShowFootPrintPoiPointsDetailMode:
        case MapTypeLBSHistoryLocation:
            break;
        case MapTypeShowGeoCycle:
            shouldShowCachePopits = NO;
            break;
//        case MapTypeShowAndModifyCompanyAddress:
//        case MapTypeShowAndModifyHomeAddress:
        case MapTypeShowRVMirror:
            //shouldShowCarPOI = NO;
        case MapTypeShowRoute:
            shouldShowCarPOI = NO;
            break;
        default:
            [self.mapView refreshUserLocationPoint];
            break;
    }
    if (shouldShowCachePopits)    {
        [self.mapView showCachedPoiPoints];
    }
//    if (shouldShowCarPOI && [CustomerInfo sharedInstance].carLocationDic.allKeys.count)    {
//        [self showVehicleLocation:[CustomerInfo sharedInstance].carLocationDic];
//    }
}

- (void)viewDidAppear:(BOOL)animated     {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated   {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CREATE_ROUTE_LINE object:nil];
}

- (void)dealloc     {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SOS_ACCOUNT_VEHICLE_HAS_CHANGED object:nil];
}

#pragma mark - account
- (void)accountVehicleHasChanged    {
    [CustomerInfo sharedInstance].carLocationPoi = nil;
}

- (void)reverseCurrentLocation:(CLLocationCoordinate2D)coordinate     {
    [self.mapView refreshUserLocationPoint];
}

#pragma mark - 地图长按
- (void)mapDidLongPressedAtCoordinate:(CLLocationCoordinate2D)coordinate  {
}

#pragma mark - Map Annotation Delegate
//用户点击地图 POI 点
- (void)mapDidSelectedPoiPoint:(SOSPOI *)poi    {
    if (self.mapType == MapTypeShowRoute || self.mapType == MapTypeShowDealerPOI ||
        self.mapType == MapTypeOil || self.mapType == MapTypeShowChargeStation ||
        (self.mapType == MapTypeLBSCurrentLocation && poi.sosPoiType == POI_TYPE_VEHICLE_LOCATION))   return;
    _selectedPOI = poi;
    [self showPositionInfoViewWithPoiInfo:poi];
}

- (void)addCurrentLocationAnnotation:(SOSPOI *)currentLocationPOI   {
    currentLocationPOI.sosPoiType = POI_TYPE_CURRENT_LOCATION;
    if (_currentPOI) {
        if ([_currentPOI.x isEqualToString:currentLocationPOI.x]
            && [_currentPOI.y isEqualToString:currentLocationPOI.y]) {
            // 原当前位置poi name为空 并且现在poi name不为空时 add poi.
            if ([Util isNotEmptyString:_currentPOI.name]) {
            } else {
                if ([Util isNotEmptyString:currentLocationPOI.name]) {
                    [self.mapView removePoiPoint:_currentPOI];
                    _currentPOI = currentLocationPOI;
                }
            }
        } else {
            [self.mapView removePoiPoint:_currentPOI];
            _currentPOI = currentLocationPOI;
        }
        
    }   else    {
        _currentPOI = currentLocationPOI;
    }
    [self.mapView addPoiPoint:_currentPOI];
    [self.mapView showCachedPoiPoints];
    if (showtraffic) {
        double zoomLevel = self.mapView.zoomLevel;
        if (zoomLevel >= 16) {
            [self.mapView setZoomLevel:16 animated:YES];
        }
    }
}

- (void)addVehicleLocationAnnotation:(SOSPOI *)vehiclePOIPoint     {
    [CustomerInfo sharedInstance].carLocationPoi = vehicleLocationPOI;
    // make poi show in one map
    [self.mapView addPoiPoint:vehicleLocationPOI];
    [self.mapView setZoomLevel:19 animated:YES];
    [self.mapView showPoiPoints:@[vehicleLocationPOI]];
}

#pragma mark - Search Delegate
- (void)poiSearchResult:(SOSPoiSearchResult *)results   {
    NSArray *resultsArray = results.pois;
    //    [SOSSearchController sharedInstance].delegate = nil;
    if (results && results.count>0) {
        switch (_searchType) {
            case SearchType_Current_Location:
                break;
            case SearchType_Vehicle_Location:
                break;
            case SearchType_Pois:
                break;
            default:
                break;
        }
    } else {
        [Util showAlertWithTitle:nil message:NSLocalizedString(@"navigateNoSearchResultTitle", @"") completeBlock:nil];
    }
}

- (void)baseSearch:(id)searchOption Error:(NSString *)errCode   {
    switch (self.searchType) {
        case SearchType_Current_Location:
        case SearchType_City_Center:
            break;
        case SearchType_Vehicle_Location:{
            if (vehicleLocationPOI) {
                [self addVehicleLocationAnnotation:vehicleLocationPOI];
                lastOperation = OPERATION_VEHICLE_LOCATING;
                CLLocationDegrees longitude = [vehicleLocationPOI.x doubleValue];
                CLLocationDegrees latitude = [vehicleLocationPOI.y doubleValue];
                CLLocationCoordinate2D location = CLLocationCoordinate2DMake(latitude, longitude);
                [self reverseCurrentLocation:location];
            }
            break;
        }
        default:{
            [Util showAlertWithTitle:nil message:NSLocalizedString(@"navigateNoSearchResultTitle", @"") completeBlock:nil];
            break;
        }
    }
}

//逆地理编码搜索结果
- (void)reverseGeocodingResults:(NSArray *)results  {
    if (results == nil || results.count == 0) {
        [Util showAlertWithTitle:nil message:NSLocalizedString(@"MapGeoCodingError", nil) completeBlock:nil];
        return;
    }
    SOSPOI *resultPOI = results[0];
    
    NSString *cityName = @"";
    if ([Util isNotEmptyString:resultPOI.city] ) {
        cityName = resultPOI.city;
        self.cityInfo.city = resultPOI.city;
    } else {
        cityName = resultPOI.province;
        self.cityInfo.province = resultPOI.province;
    }
    NSString *cityCode = @"";
    if ([Util isNotEmptyString:resultPOI.cityCode] ) {
        cityCode = resultPOI.cityCode;
        self.cityInfo.code = resultPOI.cityCode;
    } else {
        cityCode = resultPOI.code;
        self.cityInfo.code = resultPOI.code;
    }
    
    switch (lastOperation) {
        // 设置POI的城市名
        case OPERATION_LOCATING:
            break;
        // 车辆定位
        case OPERATION_VEHICLE_LOCATING:
            break;
        // 长按地图
        case OPERATION_LONGPRESS:
            longPressPointPoi.city = cityName;
            longPressPointPoi.province = resultPOI.province;
            longPressPointPoi.address = resultPOI.address;
            longPressPointPoi.name = resultPOI.name;
            [self.mapView addPoiPoint:longPressPointPoi];
            [self.mapView showCachedPoiPoints];
            [self showPositionInfoViewWithPoiInfo:longPressPointPoi];
            break;
        default:
            _currentPOI.city = cityName;
            _currentPOI.province = resultPOI.province;
            break;
    }
}

- (void)showFootPrintPoiPoints:(NSArray *)poiPointsArray    {
    [self.mapView addPoiPoints:poiPointsArray];
    [self.mapView showCachedPoiPoints];
}

#pragma mark Button Tapped
- (void)showTraffic:(NSNumber *)show    {
    if (!self.mapView.showTraffic) {
        [self trafficButtonTapped:self.trafficButton];
    }
}

/// 规划路径/步行导航
- (void)configRouteButtonAction     {
    __weak __typeof(self) weakSelf = self;
    [[weakSelf.mapLocationInfoView.routeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        if (weakSelf.selectedPOI.sosPoiType == POI_TYPE_VEHICLE_LOCATION) {
            //选中车辆点,执行步行导航
            [SOSDaapManager sendActionInfo:Map_carlocation_lastmilnavigation];
            [weakSelf configWalkNavAction];
        }	else	{
            // 去这里(规划路线)
            if ([CustomerInfo sharedInstance].isInDelear) [SOSDaapManager sendActionInfo:Dealeraptmt_Map_POIdetail_Flag];
            [SOSDaapManager sendActionInfo:Map_POIdetail_routeplan];
            CustomerInfo *customerInfo = [CustomerInfo sharedInstance];
            SOSTripRouteVC *vc = [[SOSTripRouteVC alloc] initWithRouteBeginPOI:customerInfo.currentPositionPoi AndEndPOI:self.selectedPOI];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}

/// 步行导航路径规划
- (void)configWalkNavAction		{
    __weak __typeof(self) weakSelf = self;
    CustomerInfo *customerInfo = [CustomerInfo sharedInstance];
    /// 未获取到定位
    if (customerInfo.currentPositionPoi == nil) {
        // 未开启定位权限
        if ([[SOSUserLocation sharedInstance] checkAuthorizeAndShowAlert:NO] == NO)    {
            [Util toastWithMessage:@"检测到未开启GPS定位。需开启GPS定位功能才可以使用该功能。"];
            return;
        }
    }
    [[LoadingView sharedInstance] startIn:self.view];
    SOSTripRouteVC *vc = [[SOSTripRouteVC alloc] initWithRouteBeginPOI:customerInfo.currentPositionPoi AndEndPOI:self.selectedPOI];
    [self.navigationController pushViewController:vc animated:YES];;
}

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

///电子围栏
- (IBAction)buttonGeoFencingTapped:(id)sender {
    [SOSNavigateTool showGeoPageFromVC:self];
}

- (IBAction)zoomInAndZoomOut:(UIButton *)sender {
    MAMapView *mapView = self.mapView;
    if (sender.tag - 2000) {
        ///Zoom Out
        //[[SOSReportService shareInstance] recordActionWithFunctionID:NavigationSmall];
        [mapView setZoomLevel:mapView.zoomLevel - (mapView.maxZoomLevel - mapView.minZoomLevel) / 9 animated:YES];
    }   else    {
        ///Zoom In
        //[[SOSReportService shareInstance] recordActionWithFunctionID:NavigationEnlarge];
        [mapView setZoomLevel:mapView.zoomLevel + (mapView.maxZoomLevel - mapView.minZoomLevel) / 9 animated:YES];
    }
}

- (IBAction) buttonVehicleLocationTapped     {
    if (self.selectedLBSPOI) {
        [SOSDaapManager sendActionInfo:LBS_list_deviceinfo_carlocation];
    }   else    {
        [SOSDaapManager sendActionInfo:Trip_GoWhere_Map_CarLocation];
    }
    [self.mapView removeCarLocationPoint];
    
    [[SOSRemoteTool sharedInstance] startOperationWithOperationType:SOSRemoteOperationType_VehicleLocation];
}

- (IBAction) buttonLocationTapped     {
    __weak __typeof(self) weakSelf = self;
    [SOSDaapManager sendActionInfo:Trip_GoWhere_Map_MyLocation];
    SOSPOI *currentLocationPOI = [CustomerInfo sharedInstance].currentPositionPoi;
    if (currentLocationPOI == nil) {
        [weakSelf.mapView refreshUserLocationPoint];
    }   else    {
        [weakSelf.mapView addPoiPoints:self.poisShowingOnMap];
        [weakSelf.mapView showCachedPoiPoints];
        _selectedPOI = currentLocationPOI;
        [weakSelf showPositionInfoViewWithPoiInfo:currentLocationPOI];
    }
    [[SOSUserLocation sharedInstance] getLocationSuccess:^(SOSPOI *userLocationPoi) {
        _selectedPOI = userLocationPoi;
        [weakSelf showPositionInfoViewWithPoiInfo:weakSelf.selectedPOI];
        [weakSelf.mapView addPoiPoints:weakSelf.poisShowingOnMap];
        [weakSelf.mapView showCachedPoiPoints];
    } Failure:^(NSError *error) {   }];
}

- (void)showLocationPoiPoint       {
    __weak __typeof(self) weakSelf = self;
    SOSPOI *currentLocationPOI = [CustomerInfo sharedInstance].currentPositionPoi;
    if (currentLocationPOI != nil) {
        [weakSelf.mapView addPoiPoints:self.poisShowingOnMap];
        [weakSelf.mapView showCachedPoiPoints];
    }
    [[SOSUserLocation sharedInstance] getLocationSuccess:^(SOSPOI *userLocationPoi) {
        [weakSelf.mapView addPoiPoints:weakSelf.poisShowingOnMap];
        [weakSelf.mapView showCachedPoiPoints];
    } Failure:^(NSError *error) {   }];
}

/**
 *将车辆位置显示到地图上
 */
- (void)showVehicleLocation:(NSDictionary *)dict     {
    vehicleLocationPOI = [SOSPOI mj_objectWithKeyValues:dict];
    [self addVehicleLocationAnnotation:vehicleLocationPOI];
}

- (void)showResultAlert:(NSDictionary *)errorinfo     {
    NSString * errorMessage = @"操作失败(unkown reason)";
    int tag = 0;
    if (errorinfo.allKeys.count > 0) {
        errorMessage= errorinfo[@"BASESEARCH_ALERT_MESSAGE"];
        tag = [errorinfo[@"BASESEARCH_ALERT_TAG"] intValue];
        NSLog(@"showResultAlert errorMessage %@", errorMessage);
        [Util showAlertWithTitle:nil message:errorMessage completeBlock:^(NSInteger buttonIndex) {
            if (tag == 2)  {
                [self.navigationController popViewControllerAnimated:YES];
            }	else if (tag == 1){
                AppDelegate_iPhone *delegate = (AppDelegate_iPhone*)[[UIApplication sharedApplication] delegate];
                [delegate switchLoginView];
            }
        }];
    }
}

//显示所选 POI 的相关信息,父类仅声明,需在子类实现
- (void)showPositionInfoViewWithPoiInfo:(SOSPOI *)poi   {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.mapLocationInfoView.hidden) {
            self.actionNavigation.hidden = NO;
            self.mapLocationInfoView.hidden = NO;
            [UIView animateWithDuration:.2 animations:^{
                self.mapInfoViewButtomGuide.constant = 0;
            }];
        }
        //显示车辆定位点
        if (poi.sosPoiType == POI_TYPE_VEHICLE_LOCATION) {
            //隐藏下发按钮
            self.actionNavHeightGuide.constant = 0;
        }   else    {
            self.actionNavHeightGuide.constant = 50;
        }
        [UIView animateWithDuration:.2 animations:^{
            [self.view layoutIfNeeded];
        }];
        self.infoTableView.poi = poi;
        self.mapLocationInfoView.poiInfo = poi;
        
        if (self.mapType == MapTypeLBSCurrentLocation)      {
            self.actionNavigation.poi = self.selectedLBSPOI;
            if (poi.sosPoiType == POI_TYPE_LBS) {
                [self.mapLocationInfoView configView:MapTypeLBSCurrentLocation];
            }   else    {
                [self.mapLocationInfoView configView:MapTypeLBSUserLocation];
            }
        }   else                                                {
            self.actionNavigation.poi = poi;
        }
    });
}

#pragma mark UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex     {
    if (TAG_NEED_POP == alertView.tag)  {
        [self.navigationController popViewControllerAnimated:YES];
    }else if (TAG_NEED_RELOGIN == alertView.tag){
        AppDelegate_iPhone *delegate = (AppDelegate_iPhone*)[[UIApplication sharedApplication] delegate];
        [delegate switchLoginView];
    }
}

#pragma mark - 上划手势处理
- (void)dragScrollview:(UIPanGestureRecognizer *)recognizer {
    float KTableHeight = (SCREEN_HEIGHT == 640) ? 200 : 300.f;
    NSLayoutConstraint *constraint = self.infoTableViewHeightGuide;
    if (self.mapType == MapTypeLBSCurrentLocation)      {
        KTableHeight = 120.f;
    }
    
    //手势滑动过程中
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [recognizer locationInView:self.view];
        // CGPoint translation = [recognizer translationInView:self.view];
        CGPoint velocity = [recognizer velocityInView:self.view];
        // 在最大位置
        if (constraint.constant == KTableHeight)    {
            //屏蔽继续上滑
            if (velocity.y < 0)  return;
            //在底部
        }   else if (constraint.constant == 0)      {
            //屏蔽继续下滑
            if (velocity.y > 0)  return;
        }
        
        float gesH = 0.f;
        //上滑
        gesH = (SCREEN_HEIGHT - 50 - 64 - point.y - self.view.sos_safeAreaInsets.bottom);
        //        if (velocity.y < 0){
        //            gesH = - translation.y;
        ////            gesH = fabs(translation.y);
        //        }else{
        //            gesH = KTableHeight - translation.y;
        ////            gesH = KTableHeight - fabs(translation.y);
        //        }
        if (gesH < KTableHeight) {
            constraint.constant = gesH;
            [self.view setNeedsLayout];
        }   else    {
            //手势滑动距离大于预设最大高度
            constraint.constant = KTableHeight;
            [self.view setNeedsLayout];
        }
        //手势滑动停止
    }   else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (constraint.constant >= KTableHeight / 2) {
            self.mapLocationInfoView.dragEnableFlagImgView.highlighted = NO;
            [UIView animateWithDuration:.5 animations:^{
                constraint.constant = KTableHeight;
                if (self.mapType == MapTypeShowRoute) self.navSearchBGView.alpha = .3;
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.mapLocationInfoView.dragEnableFlagImgView.highlighted = YES;
                if (self.mapType == MapTypeShowRoute) self.navSearchBGView.hidden = YES;
            }];
        }   else    {
            self.mapLocationInfoView.dragEnableFlagImgView.highlighted = YES;
            if (self.mapType == MapTypeShowRoute)   self.navSearchBGView.hidden = NO;
            [UIView animateWithDuration:.5 animations:^{
                constraint.constant = 0;
                if (self.mapType == MapTypeShowRoute) self.navSearchBGView.alpha = 1;
                [self.view layoutIfNeeded];
            }   completion:^(BOOL finished) {
                self.mapLocationInfoView.dragEnableFlagImgView.highlighted = NO;
            }];
        }
    }
}

@end
