//
//  SOSRouteMapVC.m
//  Onstar
//
//  Created by Coir on 23/11/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSRouteMapVC.h"
#import "SOSUserLocation.h"
#import "SOSWalkRemoteControllView.h"
#import "SOSRouteDetailViewController.h"
#import "GPSNaviViewController.h"
#import "SOSGPSWalkNaviViewController.h"
#import "SOSUserLocation.h"
#import "SOSRouteInfoViewController.h"

@interface SOSRouteMapVC ()

///是否需要显示路线
@property (nonatomic, assign) BOOL shouldShowRouteLine;
@property (nonatomic, assign) BOOL shouldAddChildVC;
@property (nonatomic, copy) NSArray *polylinesArray;
//@property (nonatomic, copy) NSArray *routeInfosArray;
@property(nonatomic, strong) SOSRouteInfoViewController *routeInfoVc;

@end

@implementation SOSRouteMapVC

- (id)initWithRoutePolylines:(NSArray *)polylines RouteInfos:(SOSRouteInfo *)routes  {
    self = [super init];
    if (self) {
        self.polylinesArray = polylines;
        self.routeInfo = routes;
        if (!self.routePoisArray)  self.routePoisArray = [[NSMutableArray alloc] init];
        self.mapType = MapTypeShowRoute;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self configRouteView];
    [self configRouteButtonAction];
}

- (void)viewWillAppear:(BOOL)animated     {
    [super viewWillAppear:animated];
    if (self.shouldShowRouteLine) {
        self.mapLocationInfoView.navButtonWidthGuide.constant = 50;
        self.mapLocationInfoView.navButton.hidden = NO;
        self.mapLocationInfoView.navTitleLabel.hidden = NO;
        @weakify(self)
        [self.mapLocationInfoView.navButton setBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            @strongify(self)
            [SOSDaapManager sendActionInfo:MAP_POIDETAIL_NAVIGATION];
            if (![[SOSUserLocation sharedInstance] checkAuthorizeAndShowAlert:YES]) {
                return;
            }
            SOSPOI *startPoi = [CustomerInfo sharedInstance].currentPositionPoi;
            SOSPOI *endPoi = self.routePoisArray.lastObject;
            id vc ;
            if (self.routeType == SOSRouteSearchResultType_Drive_Normal) {
                NSArray *drivingStrategyAry = @[@(AMapNaviDrivingStrategySingleDefault),@(AMapNaviDrivingStrategySinglePrioritiseDistance),@(AMapNaviDrivingStrategySingleAvoidHighway)];
                
                NSInteger drivingStrategy =  [[drivingStrategyAry objectAtIndex:self.routeInfoVc.selectedIndex] integerValue];
                vc = [[GPSNaviViewController alloc] initWithStartPoint:startPoi endPoint:endPoi drivingStrategy:drivingStrategy];
            }else {
                vc = [[SOSGPSWalkNaviViewController alloc] initWithStartPoint:startPoi endPoint:endPoi drivingStrategy:0];
            }
            [self.navigationController pushViewController:vc animated:YES];
        }];
        
        
        [self showRoutePolylines:self.polylinesArray RouteInfos:self.routeInfo];
        if (self.shouldAddChildVC == NO) {
            [self.mapView addPoiPoint:[CustomerInfo sharedInstance].currentPositionPoi];
        }
    }
}

/// 配置 路径 地图页面
- (void)configRouteView     {
    self.shouldAddChildVC = NO;
    self.shouldShowRouteLine = YES;
    
    switch (self.routeType) {
        case SOSRouteSearchResultType_Walk_Near:
            self.shouldShowRouteLine = NO;
        case SOSRouteSearchResultType_Walk_Far:
        case SOSRouteSearchResultType_Walk_Normal:
            self.title = @"步行规划";
            self.shouldAddChildVC = NO;
            
            break;
        case SOSRouteSearchResultType_Drive_Normal:
            self.title = @"路线规划";
            self.shouldAddChildVC = YES;

            break;
    }
    
    SOSPOI *tempPOI = self.routePoisArray[1];
    tempPOI.sosPoiType = POI_TYPE_ROUTE_END;
    self.mapLocationInfoView.poiInfo = tempPOI;
    self.actionNavigation.poi = tempPOI;
    
    self.shouldShowVehicleLocation = YES;
    self.fd_prefersNavigationBarHidden = NO;
    self.mapLocationInfoView.dragEnableFlagImgView.hidden = YES;
    self.mapViewBottomGuide.constant = 260.f;
    
    //车辆路线显示模式
    if (self.shouldAddChildVC) {
//        self.backDaapFunctionID = Map_carlocation_lastmilnavigation_back;
        self.topButtonBGViewHeightGuide.constant = 80.f;
//        self.mapLocationInfoView.smallIcon.image = [UIImage imageNamed:@"Navigate_Icon_Poi"];
        self.routeInfoVc = [[SOSRouteInfoViewController alloc] init];
        self.routeInfoVc.polylines = self.polylinesArray;
        self.routeInfoVc.routeInfo = self.routeInfo;
        self.routeInfoVc.view.frame = self.routeInfoView.bounds;
        [self addChildViewController:self.routeInfoVc];
        [self.routeInfoView addSubview:self.routeInfoVc.view];
        self.mapLocationInfoView.routeBtn.hidden = YES;
        self.mapLocationInfoView.routeTieleLabel.hidden = YES;
        self.infoTableViewHeightGuide.constant = 120;
        self.mapLocationInfoView.titleLabelTrailingGuide.constant = - 50;
    //步行路线显示模式
    }    else    {
        self.backDaapFunctionID = Map_carlocation_lastmilnavigation_back;
        self.topButtonBGViewHeightGuide.constant = 40.f;
        self.mapLocationInfoView.smallIcon.image = [UIImage imageNamed:@"icon_car_location_shadow"];
        self.mapLocationInfoView.titleLabelTrailingGuide.constant = 10;
        //配置车辆遥控 View
        SOSWalkRemoteControllView *remoteView = [[NSBundle SOSBundle] loadNibNamed:@"SOSWalkRemoteControllView" owner:self options:nil][0];
        remoteView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 80);
        [self.actionNavigation addSubview:remoteView];
        remoteView.VC = self;
        self.actionNavHeightGuide.constant = self.routeType == SOSRouteSearchResultType_Walk_Near ? 80 : 0;
        [remoteView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.actionNavigation);
        }];
        //需要显示路线相关信息
        if (self.shouldShowRouteLine) {
            //配置步行路线相关信息
            [SOSDaapManager sendActionInfo:MAP_CARLOCATION_LASTMILNAVIGATION_NAVIGATION];
            SOSRouteDetailViewController *routeDetailVC = [SOSRouteDetailViewController new];
            routeDetailVC.strategy = DriveStrategyWalk;
            routeDetailVC.routeInfo = self.routeInfo;
            self.infoTableViewHeightGuide.constant = 80;
            routeDetailVC.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 80);
            [self.routeInfoView addSubview:routeDetailVC.view];
        }	else	{
            self.infoTableViewHeightGuide.constant = 0;
            [self.mapView addPoiPoints:@[[CustomerInfo sharedInstance].currentPositionPoi, [CustomerInfo sharedInstance].carLocationPoi]];
        }
    }
    
    self.routeInfoView.hidden = NO;
    self.routeInfoVc.arraySelectPOI = self.routePoisArray;
    
    self.zoomButtonBGView.hidden = YES;
    self.navSearchBGView.hidden = YES;
}

/// 车辆遥控 Button 事件	(显示/隐藏 车辆操控 View)
- (void)configRouteButtonAction		{
    __weak __typeof(self) weakSelf = self;
    [SOSDaapManager sendActionInfo:Map_carlocation_lastmilnavigation_RemoteControl];
    [[self.mapLocationInfoView.routeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        if (weakSelf.actionNavHeightGuide.constant == 0) {
            weakSelf.actionNavHeightGuide.constant = 80;
        }	else	{
            weakSelf.actionNavHeightGuide.constant = 0;
        }
        [UIView animateWithDuration:.3 animations:^{
            [weakSelf.view layoutIfNeeded];
        }];
	}];
}

///点击两点生成路线,实现父类方法
- (void)showRoutePolylines:(NSArray *)polylines RouteInfos:(SOSRouteInfo *)routeInfo     {
    if (routeInfo.routeLength == 0) {
        [Util showAlertWithTitle:nil message:@"Data Error" completeBlock:nil];
        return;
    }
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView addOverlays:polylines];
    self.routeline = polylines;
    BOOL isDriveMode = (self.routeType == SOSRouteSearchResultType_Drive_Normal);
    if (self.routePoisArray && self.routePoisArray.count == 2) {
        ((SOSPOI *)[self.routePoisArray objectAtIndex:0]).sosPoiType = POI_TYPE_ROUTE_BEGIN;
        //步行导航模式,终点显示为车辆定位点
        ((SOSPOI *)[self.routePoisArray objectAtIndex:1]).sosPoiType = isDriveMode ? POI_TYPE_ROUTE_END : POI_TYPE_VEHICLE_LOCATION;
    }
    [self.mapView addPoiPoints:self.routePoisArray];
    [self.mapView showPolylines:polylines];
}

/// 路况
- (IBAction)trafficButtonTapped:(UIButton *)sender	{
    [super trafficButtonTapped:sender];
    if (self.routeType != SOSRouteSearchResultType_Drive_Normal) {
        // 步行导航模式
        if (sender.selected) {
            [SOSDaapManager sendActionInfo:Map_carlocation_lastmilnavigation_trafficon];
        }	else	{
            [SOSDaapManager sendActionInfo:Map_carlocation_lastmilnavigation_trafficoff];
        }
    }
}

- (IBAction)buttonLocationTapped     {
    if (self.routeType != SOSRouteSearchResultType_Drive_Normal) {
        [SOSDaapManager sendActionInfo:Map_carlocation_lastmilnavigation_Mylocation];
    }
//    [SOSDaapManager sendActionInfo:Map_mylocation];
    SOSPOI *currentLocationPOI = [CustomerInfo sharedInstance].currentPositionPoi;
    if (currentLocationPOI == nil) {
        [self.mapView refreshUserLocationPoint];
    }   else    {
        [self.mapView addPoiPoint:userLocationPOI];
        [self.mapView showCachedPoiPoints];
    }
    [[SOSUserLocation sharedInstance] getLocationSuccess:^(SOSPOI *userLocationPoi) {
        [self.mapView addPoiPoint:userLocationPOI];
        [self.mapView showCachedPoiPoints];
    } Failure:^(NSError *error) {   }];
}

- (void)zoomInAndZoomOut:(UIButton *)sender		{
    if (self.routeType != SOSRouteSearchResultType_Drive_Normal) {
        if (sender.tag - 2000) {
            ///Zoom Out
            [SOSDaapManager sendActionInfo:Map_carlocation_lastmilnavigation_zoomout];
        }   else    {
            ///Zoom In
            [SOSDaapManager sendActionInfo:Map_carlocation_lastmilnavigation_zoomin];
        }
    }
    [super zoomInAndZoomOut:sender];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc		{
    
}

@end
