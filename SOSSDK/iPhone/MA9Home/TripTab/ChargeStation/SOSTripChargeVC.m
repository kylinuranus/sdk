//
//  SOSTripChargeVC.m
//  Onstar
//
//  Created by Coir on 2019/4/23.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSTripChargeVC.h"
#import "SOSSearchBarView.h"
#import "SOSChargeStationVC.h"
#import "SOSTripChargeDetailView.h"

@interface SOSTripChargeVC () <SOSTripChargeDetailDelegate>

@property (nonatomic, weak) SOSSearchBarView *searchBarView;
@property (nonatomic, weak) SOSTripChargeDetailView *chargeDetailView;
@property (nonatomic, strong) SOSChargeStationVC *chargeListVC;

@property (nonatomic, copy) NSArray<ChargeStationOBJ *> * chargeStationArray;

@property (nonatomic, strong) NSMutableArray *poiArray;

@property (nonatomic, assign) BOOL isAYChargeDetailMode;

@end

@implementation SOSTripChargeVC

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.fd_viewControllerBasedNavigationBarAppearanceEnabled = YES;
}

- (void)viewDidLoad {
    self.isAYChargeDetailMode = YES;
    [super viewDidLoad];
    [self addChargeObserver];
    self.backDaapFunctionID = Trip_GoWhere_AroundChargeStation_POIdetail_Back;
}

- (void)setMapType:(MapType)mapType        {
    [super setMapType:mapType];
    [self addSearchBarView];
    if (self.carConditionPush) {
        self.navigationController.fd_viewControllerBasedNavigationBarAppearanceEnabled = NO;
        [self removePanGestureRecognizer];
    }

    switch (mapType) {
        // 充电桩详情
        case MapTypeShowChargeStation:
            if (_isAYChargeDetailMode)        self.cardBGViewHeightGuide.constant = 220.f;
            else                            self.cardBGViewHeightGuide.constant = 160.f;
            [self.view layoutIfNeeded];
            if (self.carConditionPush) {
                self.searchBarView.title = @"附近充电站";
                self.searchBarView.viewMode = SOSSearchBarViewMode_List;
                self.cardBottomCoverView.hidden = YES;
            }    else    {
                self.searchBarView.title = @"充电站";
                self.searchBarView.viewMode = SOSSearchBarViewMode_Detail;
            }
            [self addChargeStationDetailView];
            break;
        // 充电桩列表
        case MapTypeChargeStationList:
            if (self.carConditionPush) {
                self.searchBarView.title = @"附近充电站";
                self.searchBarView.viewMode = SOSSearchBarViewMode_List;
                [self removePanGestureRecognizer];
                self.cardBGViewTopGuideToSafeArea.priority = UILayoutPriorityDefaultHigh;
                self.cardBGViewTopGuideToSafeArea.constant = 0;
                self.cardBottomCoverView.hidden = NO;
            }    else    {
                self.searchBarView.title = @"充电站";
                self.searchBarView.viewMode = SOSSearchBarViewMode_Detail;
            }
            [self addChargeStationListView];
            
            
            break;
        default:
            self.cardBGViewBottomGuide.constant = 12.f;
            break;
    }
}

- (void)addSearchBarView    {
    [self.topNavBGView removeAllSubviews];
    self.searchBarView = [SOSSearchBarView viewFromXib];
    self.searchBarView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.topNavHeightGuide.constant);
    [self.topNavBGView addSubview:self.searchBarView];
}

- (void)addChargeObserver     {
    __weak __typeof(self) weakSelf = self;
    // 充电桩列表展示,更新地图 通知
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:KNeedShowStationListMapNotify object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSDictionary *notiDic = x.object;
        NSArray *chargeList = notiDic[@"dataArray"];
        UITableView *tableView = notiDic[@"tableView"];
        if (!weakSelf.carConditionPush)		[weakSelf setTargetTableView:tableView];
        if ([chargeList isKindOfClass:[NSArray class]]) {
            if (weakSelf.poiArray)    [weakSelf.mapView removePoiPoints:weakSelf.poiArray];
            weakSelf.poiArray = [NSMutableArray array];
            for (ChargeStationOBJ *chargeObj in chargeList) {
                SOSPOI *poi = [chargeObj transToPoi];
                poi.sosPoiType = POI_TYPE_List_POI;
                [weakSelf.poiArray addObject:poi];
            }
            [weakSelf.mapView removePoiPoint:weakSelf.selectedPOI];
            [weakSelf.mapView addPoiPoints:weakSelf.poiArray];
            [weakSelf.mapView showPoiPoints:weakSelf.poiArray];
        }
    }];
    
    // 安悦充电桩列表 Cell 点击事件
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:KAYChargeListCellTappedNotify object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundChargeStation_POIdetail_SeeMore_AroundChargeStationTab_POI];
        [weakSelf enterChargeDetailModeWithOBJ:x.object IsAYCharge:YES];
    }];
    // 品牌充电桩列表 Cell 点击事件
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:KDealerChargeListCellTappedNotify object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        if ([Util vehicleIsCadillac]) {
            [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundChargeStation_POIdetail_SeeMore_Cadillac4STab_POI];
        }    else if ([Util vehicleIsBuick])        {
            [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundChargeStation_POIdetail_SeeMore_Buick4STab_POI];
        }
        ChargeStationOBJ *station = [ChargeStationOBJ mj_objectWithKeyValues:x.object];
        [weakSelf enterChargeDetailModeWithOBJ:station IsAYCharge:NO];
    }];
}

// 添加充电桩列表 View
- (void)addChargeStationListView    {
    [self.cardBGView removeAllSubviews];
    [self.mapView removePoiPoint:self.selectedPOI];
    if (!self.chargeListVC)     {
        self.chargeListVC = [SOSChargeStationVC new];
        if (self.infoPOI)     self.chargeListVC.selectPOI = [self.infoPOI copy];
        self.chargeListVC.stationArray = self.chargeStationArray;
        [self.cardBGView addSubview:self.chargeListVC.view];
        [self.chargeListVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.cardBGView);
        }];
        [self addChildViewController:self.chargeListVC];
        [self.chargeListVC configSelf];
    }    else    {
        [self.cardBGView addSubview:self.chargeListVC.view];
        [self.chargeListVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.cardBGView);
        }];
    }
    
}

- (void)enterChargeDetailModeWithOBJ:(id)obj IsAYCharge:(BOOL)isAYCharge    {
    [self.mapView removePoiPoint:self.selectedPOI];
    self.isAYChargeDetailMode = isAYCharge;
    self.mapType = MapTypeShowChargeStation;
    if (isAYCharge) {
        int index = [obj intValue];
        if (self.chargeStationArray.count > index) {
            ChargeStationOBJ *station = self.chargeStationArray[index];
            self.chargeDetailView.status = SOSChargeDetailViewStatus_Loading;
            [self getChargeStationDetailWithStation:station];
        }
    }    else    {
        // 品牌充电桩 没有 stationID
        ChargeStationOBJ *station = (ChargeStationOBJ *)obj;        self.chargeDetailView.status = SOSChargeDetailViewStatus_Success;
        self.chargeDetailView.height = 160;
        self.chargeDetailView.isAYChargeDetailMode = isAYCharge;
        
        self.chargeDetailView.chargeStationObj = station;
        self.selectedPOI = [station transToPoi];
        self.searchBarView.title = self.selectedPOI.name;
        self.searchBarView.viewMode = SOSSearchBarViewMode_Detail;
        [self.mapView removePoiPoints:self.poiArray];
        [self.mapView addPoiPoint:self.selectedPOI];
        [self.mapView showPoiPoints:@[self.selectedPOI]];
    }
}

// 添加充电桩详情 View
- (void)addChargeStationDetailView    {
    [self.cardBGView removeAllSubviews];
    [self removePanGestureRecognizer];
    self.chargeDetailView = [SOSTripChargeDetailView viewFromXib];
    self.chargeDetailView.frame = CGRectMake(12, 0, SCREEN_WIDTH - 24, self.cardBGViewHeightGuide.constant);
    self.chargeDetailView.delegate = self;
    [self.cardBGView addSubview:self.chargeDetailView];
    
    if (self.isAYChargeDetailMode)         [self getChargeStationList];
}

- (void)getChargeStationList    {
    self.chargeDetailView.status = SOSChargeDetailViewStatus_Loading;
    if (self.chargeStationArray) {
        [self setUpChargeDetailView];
        return;
    }
    SOSPOI *centerPOI = self.infoPOI ? self.infoPOI : [CustomerInfo sharedInstance].currentPositionPoi;
    [ChargeStationOBJ requestStationListPOIInfo:centerPOI Success:^(NSArray<ChargeStationOBJ *> *stationList) {
        self.chargeStationArray = stationList;
        [self setUpChargeDetailView];
    } Failure:^{
        self.chargeDetailView.status = SOSChargeDetailViewStatus_Fail;
    }];
}

- (void)setUpChargeDetailView    {
    if (self.chargeStationArray.count) {
        self.chargeDetailView.stationArray = self.chargeStationArray;
        self.isAYChargeDetailMode = YES;
        ChargeStationOBJ *firstStation = self.chargeStationArray.firstObject;
        [self getChargeStationDetailWithStation:firstStation];
    }    else    {
        self.chargeDetailView.status = SOSChargeDetailViewStatus_Empty;
    }
}

- (void)getChargeStationDetailWithStation:(ChargeStationOBJ *)oriStation    {
    [ChargeStationOBJ requestStationDetailWithStationId:oriStation.stationID.stringValue successBlock:^(ChargeStationOBJ *station) {
        self.chargeDetailView.status = SOSChargeDetailViewStatus_Success;
        self.chargeDetailView.height = self.isAYChargeDetailMode ? 220 : 160;
        self.chargeDetailView.isAYChargeDetailMode = self.isAYChargeDetailMode;
        
        station.distance = oriStation.distance;
        self.chargeDetailView.chargeStationObj = station;
        self.selectedPOI = [station transToPoi];
        self.searchBarView.title = self.selectedPOI.name;
        self.searchBarView.viewMode = SOSSearchBarViewMode_Detail;
        [self.mapView removePoiPoints:self.poiArray];
        [self.mapView addPoiPoint:self.selectedPOI];
        [self.mapView showPoiPoints:@[self.selectedPOI]];
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        self.chargeDetailView.status = SOSChargeDetailViewStatus_Fail;
    }];
}

#pragma mark - View Delegate
// 充电桩 详情模式点击查看更多结果
- (void)showMoreResultsWithStations:(NSArray<ChargeStationOBJ *> *)stationArray        {
    [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundChargeStation_POIdetail_SeeMore];
    [self.mapView removePoiPoint:self.selectedPOI];
    self.mapType = MapTypeChargeStationList;
}

// 充电桩 详情 点击重新加载
- (void)reloadButtonTapped    {
    [self getChargeStationList];
}

- (void)dealloc    {
}

@end
