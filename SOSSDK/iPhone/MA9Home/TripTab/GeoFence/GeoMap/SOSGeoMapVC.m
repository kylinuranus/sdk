//
//  SOSGeoMapVC.m
//  Onstar
//
//  Created by Coir on 2019/6/12.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSGeoMapVC.h"
#import "SOSGeoDataTool.h"
#import "SOSAMapSearchTool.h"
#import "SOSTripGeoInfoView.h"
#import "SOSGeoEditRadiusCycleView.h"
#import "SOSGeoCenterAndRadiusView.h"

@interface SOSGeoMapVC () <SOSGeoInfoViewDelegate, SOSGeoCenterAndRadiusDelegate>

/// 当前围栏
@property (nonatomic, strong) NNGeoFence *geofence;
/// 围栏信息卡片
@property (nonatomic, strong) SOSTripGeoInfoView *geoInfoView;
/// 编辑围栏半径背景 View (位于 MapView 上层)
@property (nonatomic, weak) SOSGeoEditRadiusCycleView *editRadiusCycleBGView;
/// 编辑围栏半径/中心卡片
@property (nonatomic, weak) SOSGeoCenterAndRadiusView *editGeoCenterCardView;

@end

@implementation SOSGeoMapVC

@synthesize infoPOI = _infoPOI;

- (instancetype)initWithGeoFence:(NNGeoFence *)geofence	{
    self = [super init];
    if (self) {
        self.geofence = geofence;
        [self configInfoPOI];
    }
    return self;
}

- (void)configInfoPOI	{
    SOSPOI *poi = [[SOSPOI alloc] init];
    poi.x = self.geofence.centerPoiCoordinate.longi;
    poi.y = self.geofence.centerPoiCoordinate.lati;
    poi.name = self.geofence.centerPoiName;
    poi.address = self.geofence.centerPoiAddress;
    poi.sosPoiType = self.geofence.isOpen ? POI_TYPE_GeoCenter_ON : POI_TYPE_GeoCenter_OFF;
    _infoPOI = poi;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.geofence.isNewToAdd) {
        // 新建围栏模式
        [self addEditGeoCenterCardView];
        [self showEditGeoRadiusCycleView];
        self.editGeoCenterCardView.isFirstCard = YES;
    }	else	{
        // 展示围栏模式
        [self addGeoInfoView];
    }
    [self configMapView];
    @weakify(self);
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOSNotifacationChangeGeo object:nil] subscribeNext:^(NSNotification *noti) {
        //@{@"state":@(RemoteControlStatus_OperateSuccess), @"OperationType" : @(type), @"message": message}
        NSDictionary *info = noti.object;
        if ([info[@"Type"] intValue] == SOSChangeGeoType_Update_Fix) {
            NNGeoFence *change = [info objectForKey:@"Geofence"];
            self.geofence.centerPoiName = change.centerPoiName;
            self.geofence.centerPoiAddress = change.centerPoiAddress;
            self.geofence.centerPoiCoordinate = change.centerPoiCoordinate;
            [self setGeofence:_geofence];
        }
    }];
}

/// 添加通知监听
- (void)addObserver		{
    // 监听围栏信息变更
    __weak __typeof(self) weakSelf = self;
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOSNotifacationChangeGeo object:nil] subscribeNext:^(NSNotification *noti) {
        NSDictionary *notiDic = noti.object;
        NNGeoFence *notiGeo = notiDic[@"Geofence"];
        SOSChangeGeoType type = [notiDic[@"Type"] intValue];
        if (type == SOSChangeGeoType_Update_Mobile) 	return;
        if (weakSelf == nil)							return;
        // 新建围栏
        if (notiGeo.isNewToAdd) {
            switch (type) {
                // 修改围栏中心
                case SOSChangeGeoType_Update_CenterAndRadius:
                    weakSelf.editingGeofence = notiGeo;
                    [weakSelf updateGeoCenterCardViewInfoAndMapCenter];
                    break;
                default:
                    weakSelf.editGeoCenterCardView.isFirstCard = NO;
                    weakSelf.geofence = notiGeo;
                    [weakSelf addGeoInfoView];
                    break;
            }
            return;
        }
        // @{@"Type": @(SOSChangeGeoType_Update_Switch), @"Geofence":tempGeofence, @"ShouldChangeLocal": @(YES)}
        
        BOOL shouldChangeLocal = [notiDic[@"ShouldChangeLocal"] boolValue];
        if (shouldChangeLocal) {
            weakSelf.geofence = notiGeo;
        }
        if (type == SOSChangeGeoType_Update_Switch) {
            [weakSelf addGeoCycle];
            return;
        }
        
        if (weakSelf.editingGeofence && type == SOSChangeGeoType_Update_CenterAndRadius) {
            
            weakSelf.editingGeofence.centerPoiName = notiGeo.centerPoiName;
            weakSelf.editingGeofence.centerPoiAddress = notiGeo.centerPoiAddress;
            weakSelf.editingGeofence.centerPoiCoordinate = notiGeo.centerPoiCoordinate;
            [weakSelf updateGeoCenterCardViewInfoAndMapCenter];
        }    else	if (weakSelf.geofence.isEditStatus) {
            weakSelf.editingGeofence = notiGeo;
            [weakSelf updateGeoCenterCardViewInfoAndMapCenter];
        }    else    {
            if (weakSelf.geoInfoView)     weakSelf.geoInfoView.geofence = weakSelf.geofence;
        }
        
    }];
}

- (void)updateGeoCenterCardViewInfoAndMapCenter		{
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(self.editingGeofence.centerPoiCoordinate.lati.doubleValue, self.editingGeofence.centerPoiCoordinate.longi.doubleValue);
    if (self.editRadiusCycleBGView) {
        self.editRadiusCycleBGView.poiName = self.editingGeofence.centerPoiName;
    }
    // 防止逆地理编码的 POI 名称与选择的 POI 名称不同
    self.geofence.isEditStatus = NO;
    [self.mapView setCenterCoordinate:location animated:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.geofence.isEditStatus = YES;
    });
    if (self.editGeoCenterCardView)        {
        self.editGeoCenterCardView.geofence = self.editingGeofence;
    }
}

// 添加围栏信息卡片
- (void)addGeoInfoView 	{
    [self.cardBGView removeAllSubviews];
    [self.editRadiusCycleBGView removeFromSuperview];
    
    if (self.geoInfoView == nil) {
        self.geoInfoView = [SOSTripGeoInfoView viewFromXib];
        self.geoInfoView.delegate = self;
    }
    [self.cardBGView addSubview:self.geoInfoView];
    [self.geoInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cardBGView.mas_top);
        make.bottom.equalTo(self.cardBGView.mas_bottom);
        make.left.equalTo(@(12));
        make.right.equalTo(self.cardBGView.mas_right).offset(-12);
    }];
    [self.mapView addPoiPoint:self.infoPOI];
    self.geofence.isEditStatus = NO;
    self.geoInfoView.geofence = self.geofence;
    [self addGeoCycle];
}

// 添加编辑围栏中心/半径卡片
- (void)addEditGeoCenterCardView 	{
    [self.mapView removePoiPoint:self.infoPOI];
    [self.cardBGView removeAllSubviews];
    if (self.editGeoCenterCardView == nil) {
        self.editGeoCenterCardView = [SOSGeoCenterAndRadiusView viewFromXib];
        [self.cardBGView addSubview:self.editGeoCenterCardView];
        [self.editGeoCenterCardView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.cardBGView.mas_top);
            make.bottom.equalTo(self.cardBGView.mas_bottom);
            make.left.equalTo(@(12));
            make.right.equalTo(self.cardBGView.mas_right).offset(-12);
        }];
        self.editGeoCenterCardView.delegate = self;
        self.editGeoCenterCardView.vc = self;
    }
    self.geofence.isEditStatus = YES;
    self.editGeoCenterCardView.geofence = self.geofence;
    self.editingGeofence = [self.geofence copy];
    [self updateGeoCenterCardViewInfoAndMapCenter];
}

- (void)configMapView		{
    self.topNavBGView.hidden = YES;
    self.trafficButton.hidden = YES;
    self.topStatusBarView.hidden = YES;
    
    // 添加 用户/车辆 定位点
    [self showUserPOIShouldResetMap:NO];
    [self showVehiclePOIShouldResetMap:NO];
}

- (void)addGeoCycle	{
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removePoiPoint:self.infoPOI];
    
    if (self.geofence) {
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(self.geofence.centerPoiCoordinate.lati.doubleValue, self.geofence.centerPoiCoordinate.longi.doubleValue);
        if (CLLocationCoordinate2DIsValid(location)) {
            SOSCircle *circle = [SOSCircle circleWithCenterCoordinate:location radius:self.geofence.range.floatValue * 1000];
            circle.isOpen = self.geofence.isOpen;
            [self.mapView addOverlay:circle];
            [self.mapView showOverlays:@[circle] animated:YES];
            
            [self configInfoPOI];
            [self.mapView addPoiPoint:self.infoPOI];
        }
    }
}

- (void)showEditGeoRadiusCycleView	{
    [self.mapView removeOverlays:self.mapView.overlays];
    if (self.editRadiusCycleBGView == nil) {
        self.editRadiusCycleBGView = [SOSGeoEditRadiusCycleView viewFromXib];
    }
    [self.view insertSubview:self.editRadiusCycleBGView belowSubview:self.cardBGView];
    [self.editRadiusCycleBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.mapView);
    }];
    if (self.editingGeofence) {
        self.editRadiusCycleBGView.poiName = self.editingGeofence.centerPoiName;
        [self updateCycleView];
    }
}



#pragma mark - Geofence Info View Delegate
// 修改围栏中心/半径
- (void)geoRadiusButtonTapped	{
    [self addEditGeoCenterCardView];
    [self showEditGeoRadiusCycleView];
}

#pragma mark - Geofence Center And Radius View Delegate
// 围栏半径 Slider 滑动
- (void)geoRadiusChangedWithGeofence:(NNGeoFence *)geofence		{
    if (self.editGeoCenterCardView) {
        self.editingGeofence.range = geofence.range;
        [self updateCycleView];
    }
}

// 编辑围栏中心/半径卡片点击  返回
- (void)geoCenterAndRadiusViewBackButtonTapped		{
//    BOOL isNewToAdd = self.geofence.isNewToAdd;
    if (self.geofence.isNewToAdd) {
        if (self.editGeoCenterCardView.isFirstCard) {
            [Util showAlertWithTitle:@"确定退出吗？" message:@"电子围栏未完成添加，退出后信息将丢失" completeBlock:^(NSInteger buttonIndex) {
                if (buttonIndex) {
                    // 若存在有效的围栏中心,点击继续添加,等效与点击 保存 ,进入下一步
                    if (self.editingGeofence.centerPoiName.length) {
                        [self.editGeoCenterCardView saveButtonTapped];
                    }
                }    else    {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            } cancleButtonTitle:@"退出" otherButtonTitles:@"继续添加", nil];
        }	else	{
            self.editingGeofence = self.editGeoCenterCardView.geofence;
            [self addGeoInfoView];
        }
    }	else	{
        // 围栏信息有变更
        BOOL isGeoInfoChanged =
        (( [self.editingGeofence.centerPoiCoordinate.longi isEqualToString:self.geofence.centerPoiCoordinate.longi] &&
          [self.editingGeofence.centerPoiCoordinate.lati isEqualToString:self.geofence.centerPoiCoordinate.lati] &&
          [self.editingGeofence.range isEqualToString:self.geofence.range] ) == NO);
        if (isGeoInfoChanged) {
            [Util showAlertWithTitle:@"是否保存设置？" message:nil completeBlock:^(NSInteger buttonIndex) {
                if (buttonIndex) {
                    // 已有围栏,编辑时,立即上传服务器保存信息
                    [Util showHUD];
                    self.editGeoCenterCardView.userInteractionEnabled = NO;
                    [SOSGeoDataTool updateGeoFencingWithGeo:self.editingGeofence Success:^(SOSNetworkOperation *operation, id responseStr) {
                        [Util dismissHUD];
                        [Util showSuccessHUDWithStatus:@"围栏更新成功"];
                        self.editGeoCenterCardView.userInteractionEnabled = YES;
                        [[NSNotificationCenter defaultCenter] postNotificationName:SOSNotifacationChangeGeo object:@{@"Type": @(SOSChangeGeoType_Update_Geo), @"Geofence":[self.editingGeofence copy], @"ShouldChangeLocal": @(YES)}];
                        [self addGeoInfoView];
                    } Failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                        [Util dismissHUD];
                        self.editGeoCenterCardView.userInteractionEnabled = YES;
                        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
                    }];
                }    else    {
                    self.editingGeofence = [self.geofence copy];
                    [self addGeoInfoView];
                }
            } cancleButtonTitle:@"丢弃" otherButtonTitles:@"保存", nil];
        }    else    {
            self.editingGeofence = [self.geofence copy];
            [self addGeoInfoView];
        }
    }
}

#pragma mark - MapView Delegate
// 地图区域将要变化
- (void)mapRegionWillChange		{
    if (!self.geofence.isEditStatus)    return;
    self.editRadiusCycleBGView.poiName = @"--";
}

// 地图区域变化完成
- (void)mapRegionDidChanged		{
    if (!self.geofence.isEditStatus)    return;
    [self updateGeoCycleInfo];
}

// 地图区域正在变化
- (void)mapRegionChanging    {
    if (!self.geofence.isEditStatus)	return;
    // 更新 Cycle View
    [self updateCycleView];
}

/// 更新 Cycle View 信息
- (void)updateGeoCycleInfo	{
    CLLocationCoordinate2D coordinate = self.mapView.centerCoordinate;
    self.editingGeofence.centerPoiCoordinate = [NNCenterPoiCoordinate coordinateWithLongitude:@(coordinate.longitude).stringValue AndLatitude:@(coordinate.latitude).stringValue];
    if (self.editRadiusCycleBGView) {
        self.editRadiusCycleBGView.poiName = @"--";
    }
    // 逆地理编码获取 POI 名称,地址
    [[SOSAMapSearchTool sharedInstance] reGeoSearchWithLon:coordinate.longitude lat:coordinate.latitude Success:^(NSArray<SOSPOI *> * _Nonnull poiArray) {
        if (poiArray.count) {
            SOSPOI *poi = poiArray[0];
            if (self.editRadiusCycleBGView) {
                self.editRadiusCycleBGView.poiName = poi.name;
            }
            self.editingGeofence.centerPoiName = poi.name;
            self.editingGeofence.centerPoiAddress = poi.address;
            self.editGeoCenterCardView.geofence = self.editingGeofence;
        }
    } Failure:^{
        //        if (self.editRadiusCycleBGView) {
        //            self.editRadiusCycleBGView.poiName = @"";
        //        }
    }];
}

/// 更新 Cycle View 圈的大小
- (void)updateCycleView        {
    CLLocationCoordinate2D coordinate = self.mapView.centerCoordinate;
    MACircle *circle = [MACircle circleWithCenterCoordinate:coordinate radius:self.editingGeofence.range.floatValue * 1000];
    float cycleRadius = circle.radius / self.mapView.metersPerPointForCurrentZoom;
    dispatch_async_on_main_queue(^{
        self.editRadiusCycleBGView.cycleViewWidthGuide.constant = cycleRadius * 2;
        self.editRadiusCycleBGView.cycleView.layer.cornerRadius = cycleRadius;
        [self.editRadiusCycleBGView layoutIfNeeded];
    });
}

@end
