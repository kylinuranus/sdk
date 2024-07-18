//
//  SOSTripRouteVC.m
//  Onstar
//
//  Created by Coir on 2019/4/17.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSRouteTool.h"
#import "SOSTripRouteVC.h"
#import "SOSUserLocation.h"
#import "SOSTripCarRemoteView.h"
#import "SOSTripRouteDetailView.h"
#import "SOSTripRouteNavBarView.h"
#import "GPSNaviViewController.h"
#import "SOSGPSWalkNaviViewController.h"

@interface SOSRouteMapInfoOBJ : NSObject

@property (nonatomic, assign) DriveStrategy strategy;
@property (nonatomic, strong) SOSRouteInfo *routeInfo;
@property (nonatomic, copy) NSArray *polyLines;

+ (instancetype)newInfoWithDriveStrategy:(DriveStrategy)strategy RouteInfo:(SOSRouteInfo *)routeInfo Polylines:(NSArray *)polylines;

@end

@implementation SOSRouteMapInfoOBJ

+ (instancetype)newInfoWithDriveStrategy:(DriveStrategy)strategy RouteInfo:(SOSRouteInfo *)routeInfo Polylines:(NSArray *)polylines		{
    SOSRouteMapInfoOBJ *obj = [SOSRouteMapInfoOBJ new];
    obj.strategy = strategy;
    obj.routeInfo = routeInfo;
    obj.polyLines = polylines;
    return obj;
}

@end

@interface SOSTripRouteVC () <SOSTripRouteNavDelegate, SOSRouteDetailViewDelegate>

@property (nonatomic, strong) SOSPOI *beginPOI;
@property (nonatomic, strong) SOSPOI *endPOI;

@property (nonatomic, strong) SOSTripRouteDetailView *detailView;
@property (nonatomic, strong) SOSTripCarRemoteView *carRemoteView;
@property (nonatomic, weak) SOSTripRouteNavBarView *navBar;

@property (nonatomic, assign) BOOL isWalkingMode;

@property (nonatomic, strong) SOSRouteTool *routeTool;
@property (nonatomic, strong) SOSRouteTool *routeTool_1;

@property(nonatomic, strong) NSMutableArray  <SOSRouteMapInfoOBJ *>* routeInfoArray;

/// 仅用于 导航找车 功能
@property (nonatomic, assign) BOOL isFindCarMode;

@end

@implementation SOSTripRouteVC

- (instancetype)initWithRouteBeginPOI:(SOSPOI *)beginPOI AndEndPOI:(SOSPOI *)endPOI	{
    return [self initWithRouteBeginPOI:beginPOI AndEndPOI:endPOI IsFindCarMode:NO];
}

- (instancetype)initWithRouteBeginPOI:(SOSPOI *)beginPOI AndEndPOI:(SOSPOI *)endPOI IsFindCarMode:(BOOL)isFindCarMode        {
    self = [super init];
    if (self) {
        self.beginPOI = [beginPOI copy];
        if (beginPOI.sosPoiType == POI_TYPE_CURRENT_LOCATION)     {
            self.beginPOI.nickName = @"我的位置";
        }
        self.beginPOI.sosPoiType = POI_TYPE_ROUTE_BEGIN;
        self.endPOI = [endPOI copy];
        self.endPOI.sosPoiType = POI_TYPE_ROUTE_END;
        self.isFindCarMode = isFindCarMode;
        self.mapType = MapTypeShowRoute;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavBarView];
    [self addRouteDetailView];
    
    [self fixBeginPOISuccess:^{
        [self getRouteLines];
    } Fail:^{
        [Util showAlertWithTitle:@"无法获取您的位置" message:@"可尝试移动您的位置，或稍后重试" completeBlock:nil cancleButtonTitle:nil otherButtonTitles:@"知道了", nil];
        self.detailView.cardStatus = SOSRouteCardStatus_Fail;
    }];
}

- (void)viewWillAppear:(BOOL)animated	{
    [super viewWillAppear:animated];
    [self.mapView refreshUserLocationPointShouldResetMapCenter:NO];
}

- (void)addNavBarView	{
    self.navBar = [SOSTripRouteNavBarView viewFromXib];
    self.navBar.frame = CGRectMake(0, 20, SCREEN_WIDTH, [UIApplication sharedApplication].statusBarFrame.size.height + 83);
    self.navBar.delegate = self;
    self.navBar.beginPOI = self.beginPOI;
    self.navBar.endPOI = self.endPOI;
    self.navBar.vc = self;
    self.navBar.isFindCarMode = self.isFindCarMode;
    [self.topNavBGView addSubview:self.navBar];
}

- (void)addRouteDetailView	{
    self.detailView = [SOSTripRouteDetailView viewFromXib];
    self.detailView.frame = CGRectMake(12, 0, SCREEN_WIDTH - 24, 160);
    self.detailView.cardStatus = SOSRouteCardStatus_Loading;
    self.detailView.isFindCarMode = self.isFindCarMode;
    self.detailView.delegate = self;
    [self.cardBGView addSubview:self.detailView];
    [self.detailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.cardBGView.mas_bottom);
        make.left.mas_offset(@(12));
        make.height.mas_equalTo(@(160));
        make.right.mas_equalTo(self.cardBGView.mas_right).offset(-12);
    }];
}

- (void)fixBeginPOISuccess:(void (^)(void))success Fail:(void (^)(void))failure 		{
    if (self.beginPOI == nil) {
        if ([CustomerInfo sharedInstance].currentPositionPoi) {
            self.beginPOI = [CustomerInfo sharedInstance].currentPositionPoi;
            self.navBar.beginPOI = self.beginPOI;
            if (success)	success();
        }    else    {
            [[SOSUserLocation sharedInstance] getLocationWithAccuarcy:kCLLocationAccuracyHundredMeters NeedReGeocode:YES isForceRequest:NO NeedShowAuthorizeFailAlert:NO success:^(SOSPOI *poi) {
                self.beginPOI = poi;
                self.navBar.beginPOI = self.beginPOI;
                if (success)    success();
            } Failure:^(NSError *error) {
                if (failure)    failure();
            }];
        }
    }	else	{
        if (success)    success();
    }
}

- (void)getRouteLines	{
    if (!self.routeTool)	self.routeTool = [SOSRouteTool new];
    MAMapPoint point1 = MAMapPointForCoordinate(CLLocationCoordinate2DMake(self.beginPOI.latitude.doubleValue, self.beginPOI.longitude.doubleValue));
    MAMapPoint point2 = MAMapPointForCoordinate(CLLocationCoordinate2DMake(self.endPOI.latitude.doubleValue, self.endPOI.longitude.doubleValue));
    CLLocationDistance distance = MAMetersBetweenMapPoints(point1, point2);
    
    if (distance == 0) {
        [Util toastWithMessage:@"请选择不同的起点与终点地址"];
        self.detailView.cardStatus = SOSRouteCardStatus_UnReachable;
        return;
    }
    
    [[SOSPoiHistoryDataBase sharedInstance] insert:self.endPOI];
    [Util showHUD];
    
    self.isWalkingMode = (distance < 1000);
    self.routeInfoArray = [NSMutableArray array];
    __weak __typeof(self) weakSelf = self;
    // 导航找车模式, 或规划路线模式 距离小于 1km ,优先获取步行路线
    if (self.isFindCarMode || distance < 1000) {
        // 1km 以内,优先搜索步行方案
        [self.routeTool searchWithBeginPOI:self.beginPOI AndDestinationPoi:self.endPOI WithStrategy:DriveStrategyWalk NeedAlertError:NO Success:^(SOSRouteSearchResultType resultType, SOSRouteInfo *routeInfo, NSArray *polylines, NSArray *routes) {
            [Util dismissHUD];
            
            SOSRouteMapInfoOBJ *obj = [SOSRouteMapInfoOBJ newInfoWithDriveStrategy:DriveStrategyWalk RouteInfo:routeInfo Polylines:polylines];
            [weakSelf.routeInfoArray addObject:obj];
            [weakSelf showPolyLines:polylines WithSelectedState:YES];
            // 导航找车模式, 步行方案距离小于 1km,不需要搜索驾车路线
            if (weakSelf.isFindCarMode && routeInfo.routeLength <= 1000) {
                weakSelf.detailView.cardStatus = SOSRouteCardStatus_Success_Walk_Only;
                [weakSelf.detailView configViewWithStrategy:DriveStrategyWalk AndRouteInfo:routeInfo];
                return;
            }
            weakSelf.detailView.cardStatus = SOSRouteCardStatus_Success_Walk;
            [weakSelf.detailView configViewWithStrategy:DriveStrategyWalk AndRouteInfo:routeInfo];
            [weakSelf getExtraRouteLinesIsWalkMode:YES IsFindCarMode:weakSelf.isFindCarMode];
        } failure:^(NSString *errorCode) {
            // 导航找车模式, 步行规划失败,仍索搜驾车路线
            if (weakSelf.isFindCarMode) {
                [weakSelf getExtraRouteLinesIsWalkMode:NO IsFindCarMode:YES];
            }	else	{
                [Util dismissHUD];
                weakSelf.detailView.cardStatus = SOSRouteCardStatus_UnReachable;
            }
        }];
    }	else	{
        // 规划路线模式大于 1km 时 , 不展示步行方案
        [self.routeTool searchWithBeginPOI:self.beginPOI AndDestinationPoi:self.endPOI WithStrategy:DriveStrategyTimeFirst NeedAlertError:NO Success:^(SOSRouteSearchResultType resultType, SOSRouteInfo *routeInfo, NSArray *polylines, NSArray *routes) {
            [Util dismissHUD];
            weakSelf.detailView.cardStatus = SOSRouteCardStatus_Success_Drive;
            [weakSelf.detailView configViewWithStrategy:DriveStrategyTimeFirst AndRouteInfo:routeInfo];
            
            SOSRouteMapInfoOBJ *obj = [SOSRouteMapInfoOBJ newInfoWithDriveStrategy:DriveStrategyTimeFirst RouteInfo:routeInfo Polylines:polylines];
            [weakSelf.routeInfoArray addObject:obj];
            [weakSelf showPolyLines:polylines WithSelectedState:YES];
            [weakSelf getExtraRouteLinesIsWalkMode:NO IsFindCarMode:NO];
        } failure:^(NSString *errorCode) {
            [Util dismissHUD];
            weakSelf.detailView.cardStatus = SOSRouteCardStatus_UnReachable;
        }];
    }
}

- (void)getExtraRouteLinesIsWalkMode:(BOOL)walkMode	IsFindCarMode:(BOOL)isFindCarMode	{
    __weak __typeof(self) weakSelf = self;
    if (isFindCarMode) {
        // 导航找车,获取驾车 最快 方案, 此时 walkMode 用来标记是否成功获取步行路线
        [self.routeTool searchWithBeginPOI:self.beginPOI AndDestinationPoi:self.endPOI WithStrategy:DriveStrategyTimeFirst NeedAlertError:NO Success:^(SOSRouteSearchResultType resultType, SOSRouteInfo *routeInfo, NSArray *polylines, NSArray *routes) {
            if (walkMode == NO) {
                [Util dismissHUD];
                weakSelf.detailView.cardStatus = SOSRouteCardStatus_Success_Walk;
                // 传 nil 时 为不可达
                [weakSelf.detailView configViewWithStrategy:DriveStrategyWalk AndRouteInfo:nil];
            }
            SOSRouteMapInfoOBJ *obj = [SOSRouteMapInfoOBJ newInfoWithDriveStrategy:DriveStrategyTimeFirst RouteInfo:routeInfo Polylines:polylines];
            [weakSelf.routeInfoArray addObject:obj];
            [weakSelf showPolyLines:polylines WithSelectedState:!walkMode];
            [weakSelf.detailView configViewWithStrategy:DriveStrategyTimeFirst AndRouteInfo:routeInfo shouldHighlighted:!walkMode];
        } failure:^(NSString *errorCode) {
            if (walkMode == NO) [Util dismissHUD];
            weakSelf.detailView.cardStatus = SOSRouteCardStatus_UnReachable;
        }];
        return;
    }
    
    if (walkMode) {
        // 正常路径规划,获取步行方案
        [self.routeTool searchWithBeginPOI:self.beginPOI AndDestinationPoi:self.endPOI WithStrategy:DriveStrategyTimeFirst NeedAlertError:NO Success:^(SOSRouteSearchResultType resultType, SOSRouteInfo *routeInfo, NSArray *polylines, NSArray *routes) {
            
            SOSRouteMapInfoOBJ *obj = [SOSRouteMapInfoOBJ newInfoWithDriveStrategy:DriveStrategyTimeFirst RouteInfo:routeInfo Polylines:polylines];
            [weakSelf.routeInfoArray addObject:obj];
            [weakSelf showPolyLines:polylines WithSelectedState:NO];
            [weakSelf.detailView configViewWithStrategy:DriveStrategyTimeFirst AndRouteInfo:routeInfo];
        } failure:^(NSString *errorCode) { }];
        
    }	else	{
        // 正常路径规划,获取驾车 最近/不走高速 方案
        [self.routeTool searchWithBeginPOI:self.beginPOI AndDestinationPoi:self.endPOI WithStrategy:DriveStrategyDestanceFirst NeedAlertError:NO Success:^(SOSRouteSearchResultType resultType, SOSRouteInfo *routeInfo, NSArray *polylines, NSArray *routes) {
            SOSRouteMapInfoOBJ *obj = [SOSRouteMapInfoOBJ newInfoWithDriveStrategy:DriveStrategyDestanceFirst RouteInfo:routeInfo Polylines:polylines];
            [weakSelf.routeInfoArray addObject:obj];
            [weakSelf showPolyLines:polylines WithSelectedState:NO];
            [weakSelf.detailView configViewWithStrategy:DriveStrategyDestanceFirst AndRouteInfo:routeInfo];
        } failure:^(NSString *errorCode) { }];
        
        if (!self.routeTool_1)    self.routeTool_1 = [SOSRouteTool new];
        [self.routeTool_1 searchWithBeginPOI:self.beginPOI AndDestinationPoi:self.endPOI WithStrategy:DriveStrategyNoExpressWay NeedAlertError:NO Success:^(SOSRouteSearchResultType resultType, SOSRouteInfo *routeInfo, NSArray *polylines, NSArray *routes) {
            SOSRouteMapInfoOBJ *obj = [SOSRouteMapInfoOBJ newInfoWithDriveStrategy:DriveStrategyNoExpressWay RouteInfo:routeInfo Polylines:polylines];
            [weakSelf.routeInfoArray addObject:obj];
            [weakSelf showPolyLines:polylines WithSelectedState:NO];
            [weakSelf.detailView configViewWithStrategy:DriveStrategyNoExpressWay AndRouteInfo:routeInfo];
        } failure:^(NSString *errorCode) { }];
    }
}

#pragma mark - View Delegate
// 起终点变更
- (void)routePOIChangedWithBeginPOI:(SOSPOI *)beginPOI AndEndPOI:(SOSPOI *)endPOI	{
    if (beginPOI)    	{
        if ([beginPOI isEqualToPOI:self.beginPOI]) 		return;
        [self.mapView removePoiPoint:self.beginPOI];
        beginPOI.sosPoiType = POI_TYPE_ROUTE_BEGIN;
        self.beginPOI = [beginPOI copy];
        self.navBar.beginPOI = [beginPOI copy];
    }
    if (endPOI)        {
        if ([endPOI isEqualToPOI:self.endPOI])         return;
        [self.mapView removePoiPoint:self.endPOI];
        endPOI.sosPoiType = POI_TYPE_ROUTE_END;
        self.endPOI = [endPOI copy];
        self.navBar.endPOI = [endPOI copy];
    }
    if (beginPOI || endPOI)        {
        dispatch_async_on_main_queue(^{
            [self.mapView removeOverlays:self.mapView.overlays];
        });
        [self getRouteLines];
    }
}

// 导航策略变更
- (void)routeChangedWithStrategy:(DriveStrategy)strategy	{
    NSString *daapStr = @"";
    switch (strategy) {
        case DriveStrategyWalk:
            if (self.isFindCarMode) {
                [SOSDaapManager sendActionInfo:Trip_VehicleLocation_FindMyCar_POIdetail_Walk];
            }	else	{
                daapStr = Trip_GoWhere_POIdetail_GoHere_Walk;
            }
            break;
        case DriveStrategyTimeFirst:
            if (self.isFindCarMode) {
                daapStr = Trip_VehicleLocation_FindMyCar_POIdetail_Drive;
            }	else	{
                if (self.isWalkingMode) {
                    daapStr = Trip_GoWhere_POIdetail_GoHere_Drive;
                }    else    {
                    daapStr = Trip_GoWhere_POIdetail_GoHere_QuickRoute;
                }
            }
            break;
        case DriveStrategyNoExpressWay:
            daapStr = Trip_GoWhere_POIdetail_GoHere_AvoidToll;
            break;
        case DriveStrategyDestanceFirst:
            daapStr = Trip_GoWhere_POIdetail_GoHere_ShortRoute;
            break;
    }
    [SOSDaapManager sendActionInfo:daapStr];
    // 获取选中路线
    SOSRouteMapInfoOBJ *selectedObj = nil;
    for (SOSRouteMapInfoOBJ *obj in self.routeInfoArray) {
        if (obj.strategy == strategy) {
            selectedObj = obj;
            break;
        }
    }
    if (selectedObj) {
        // 获取其余路线
        NSMutableArray *otherInfoArray = self.routeInfoArray.mutableCopy;
        [otherInfoArray removeObject:selectedObj];
        [self.mapView removeOverlays:self.mapView.overlays];
        [self showPolyLines:selectedObj.polyLines WithSelectedState:YES];
        for (SOSRouteMapInfoOBJ *obj in otherInfoArray) {
            [self showPolyLines:obj.polyLines WithSelectedState:NO];
        }
    }
}

// 请求失败时,重新加载
- (void)failReloadButtonTapped	{
    self.detailView.cardStatus = SOSRouteCardStatus_Loading;
    [self fixBeginPOISuccess:^{
        [self getRouteLines];
    } Fail:^{
        [Util showAlertWithTitle:@"无法获取您的位置" message:@"可尝试移动您的位置，或稍后重试" completeBlock:nil];
        self.detailView.cardStatus = SOSRouteCardStatus_Fail;
    }];
}

// 车辆遥控
- (void)showCarRemoteView:(BOOL)show	{
    [SOSDaapManager sendActionInfo:Trip_VehicleLocation_FindMyCar_POIdetail_RemoteControl];
    if (show) {
        [self configCarRemoteView];
        self.cardBGViewHeightGuide.constant = 160 + 108.f;
        [UIView animateWithDuration:.3 animations:^{
            [self.view layoutIfNeeded];
        }];
    }	else	{
        self.cardBGViewHeightGuide.constant = 160.f;
        [UIView animateWithDuration:.3 animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.carRemoteView removeFromSuperview];
        }];
    }
}

- (void)configCarRemoteView	{
    if (self.carRemoteView == nil) {
        self.carRemoteView = [SOSTripCarRemoteView viewFromXib];
        self.carRemoteView.frame = CGRectMake(12, 0, SCREEN_WIDTH - 24, 98);
    }
    [self.cardBGView insertSubview:self.carRemoteView belowSubview:self.detailView];
    [self.carRemoteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.cardBGView.mas_top);
        make.left.mas_offset(@(12));
        make.height.mas_equalTo(@(98));
        make.right.mas_equalTo(self.cardBGView.mas_right).mas_offset(@(-12));
    }];
}

// 开始导航
- (void)beginGPSWithStrategy:(DriveStrategy)strategy    {
    if (self.isFindCarMode) {
        [SOSDaapManager sendActionInfo:Trip_VehicleLocation_FindMyCar_POIdetail_Navigation];
    }	else	{
        [SOSDaapManager sendActionInfo:Trip_GoWhere_POIdetail_GoHere_Navigation];
    }
    if (![[SOSUserLocation sharedInstance] checkAuthorizeAndShowAlert:YES]) 	return;
    id vc ;
    if (strategy != DriveStrategyWalk) {
        vc = [[[self getGPSVcClass] alloc] initWithStartPoint:self.beginPOI endPoint:self.endPOI drivingStrategy:strategy];
    }	else {
        vc = [[SOSGPSWalkNaviViewController alloc] initWithStartPoint:self.beginPOI endPoint:self.endPOI drivingStrategy:0];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (Class)getGPSVcClass {
    return GPSNaviViewController.class;
}
    
- (void)showPolyLines:(NSArray *)polylines WithSelectedState:(BOOL)isSelected     {
    
    NSArray *newLines = [self fixOverlayArrayData:polylines WithSelectedState:isSelected];
    [self.mapView addOverlays:newLines level:isSelected ? MAOverlayLevelAboveLabels : MAOverlayLevelAboveRoads];
    if (isSelected)        {
        [self.mapView addPoiPoint:self.beginPOI];
        [self.mapView addPoiPoint:self.endPOI];
        self.mapView.showsUserLocation = NO;
        self.mapView.showsUserLocation = YES;
        
        [self.mapView showPolylines:newLines];
    }
}

- (NSArray *)fixOverlayArrayData:(NSArray *)polylines WithSelectedState:(BOOL)isSelected	{
    if (polylines.count) {
        NSMutableArray *newArray = [NSMutableArray array];
        for (MAPolyline *line in polylines) {
            SOSPolyline *newLine = [SOSPolyline polylineWithPoints:line.points count:line.pointCount];
            newLine.isSelected = isSelected;
            [newArray addObject:newLine];
        }
        return newArray;
    }
    return nil;
}

- (void)dealloc    {
    [Util dismissHUD];
}

@end
