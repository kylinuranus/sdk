//
//  SOSOilMapVC.m
//  Onstar
//
//  Created by Coir on 2019/8/25.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSOilMapVC.h"
#import "SOSOilDataTool.h"
#import "SOSSearchBarView.h"
#import "SOSOilGanSelectVC.h"
#import "SOSOilOrderListVC.h"
#import "SOSTripPOIDetailView.h"
#import "SOSGeomodifyMobileVC.h"
#import "SOSStationDetailView.h"
#import "SOSTripOilStationListView.h"

extern NSString *KMapVCEnterFullscreenNotify;

@interface SOSOilMapVC () <SOSTripPOIDetailDelegate, SOSOilStationListDelegate, SOSStationDetailDelegate>

@property (nonatomic, weak) SOSSearchBarView *searchBarView;
@property (nonatomic, weak) SOSTripPOIDetailView *poiDetailView;
@property (nonatomic, weak) SOSStationDetailView *stationDetailView;
@property (nonatomic, weak) SOSTripOilStationListView *stationListView;

@property (nonatomic, strong) SOSOilStation *selectedOilStastion;

@end

@implementation SOSOilMapVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addOilObserver];
    [self.mapView addPoiPoint:[CustomerInfo sharedInstance].currentPositionPoi];
    if ([LoginManage sharedInstance].loginState == LOGIN_STATE_NON)     return;
    // 检查手机号,强制补充
    if ([CustomerInfo sharedInstance].userBasicInfo.idmUser.mobilePhoneNumber.length == 0) {
        [Util showAlertWithTitle:@"绑定手机号" message:@"设置服务手机号，享受优惠加油提供的优惠价格" completeBlock:^(NSInteger buttonIndex) {
            if (buttonIndex) {
                SOSGeoModifyMobileVC *vc = [SOSGeoModifyMobileVC new];
                vc.isReplenishMobile = YES;
                __weak __typeof(self) weakSelf = self;
                vc.completeHandler = ^{
                    [weakSelf requestOilInfo];
                };
                [self.navigationController pushViewController:vc animated:YES];
            }
        } cancleButtonTitle:@"放弃优惠" otherButtonTitles:@"确定", nil];
        return;
    }    else    {
        [self requestOilInfo];
    }
}

- (void)viewWillAppear:(BOOL)animated    {
    [super viewWillAppear:animated];
}

- (void)addOilObserver 	{
    __weak __typeof(self) weakSelf = self;
    // 地图页面进入/退出全屏模式
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:KMapVCEnterFullscreenNotify object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        if (!weakSelf)    return;
        BOOL enterFullScreenMode = [x.object boolValue];
        if (enterFullScreenMode) {
            weakSelf.cardBGViewTopGuideToSafeArea.priority = UILayoutPriorityDefaultHigh;
            weakSelf.cardBGViewTopGuideToSafeArea.constant = 0;
            weakSelf.searchBarView.viewMode = SOSLBSBGViewMode_List;
            [UIView animateWithDuration:.1 animations:^{
                [weakSelf.view layoutIfNeeded];
                weakSelf.cardBottomCoverView.hidden = NO;
            }];
        }    else    {
            SOSOilStationFilterView *filterView = weakSelf.stationListView.filterView;
            if (filterView) {
                [filterView dismissTableView];
            }
            weakSelf.cardBottomCoverView.hidden = YES;
        }
    }];
}

- (void)requestOilInfo	{
    [Util showHUD];
    // 获取油号信息
    [SOSOilDataTool requestOilInfoListSuccess:^(NSArray<SOSOilInfoObj *> * _Nonnull oilInfoList) {
        NSString *defaultOilName = nil;
        for (SOSOilInfoObj *oilInfo in oilInfoList) {
            if (oilInfo.defaultShow) {
                defaultOilName = oilInfo.oilName;
                break;
            }
        }
        // 获取油站列表
        [SOSOilDataTool requestOilStationListWithCenterPOI:self.infoPOI GasType:nil OilName:defaultOilName AndSortColumn:nil Success:^(NSArray<SOSOilStation *> * _Nonnull stationList) {
            [Util dismissHUD];
            self.oilInfoList = oilInfoList;
            self.stationList = stationList;
            self.stationListView.oilInfoList = oilInfoList;
            self.stationListView.stationArray = stationList;
        } Failure:^{
            [Util dismissHUD];
            [Util toastWithMessage:@"获取油站信息失败"];
            
        }];
    } Failure:^{
        [Util dismissHUD];
        [Util toastWithMessage:@"获取油号信息失败"];
    }];
}

- (void)setStationList:(NSArray<SOSOilStation *> *)stationList	{
    _stationList = stationList;
}

- (void)setPoiArray:(NSArray<SOSPOI *> *)poiArray    {
    _poiArray = poiArray;
    if (poiArray.count) {
        self.selectedPOI = poiArray[0];
    }
}

- (void)setOilInfoList:(NSArray<SOSOilInfoObj *> *)oilInfoList	{
    _oilInfoList = [oilInfoList copy];
    dispatch_async_on_main_queue(^{
        
    });
}

- (void)setMapType:(MapType)mapType        {
    [super setMapType:mapType];
    self.cardBottomCoverView.hidden = YES;
    switch (mapType) {
        // 加油站列表
        case MapTypeOil:
            [self addSearchBarView];
            self.searchBarView.title = _isFromLifePage ? @"优惠加油" : @"加油站";
            self.searchBarView.viewMode = _isFromLifePage ? SOSSearchBarViewMode_List :  SOSSearchBarViewMode_Detail;
            if (_isFromLifePage)     {
                [self.searchBarView lockStateChange:YES];
                self.cardBottomCoverView.hidden = NO;
            }
            self.searchBarView.listModeRightButton.hidden = !_isFromLifePage;
            [self addPoiListView];
            break;
        // 加油站详情 (第三方油站)
        case MapTypeOilDetail:
            self.searchBarView.title = _isFromLifePage ? @"加油站详情" : self.selectedPOI.name;
            self.searchBarView.viewMode = _isFromLifePage ? SOSSearchBarViewMode_List :  SOSSearchBarViewMode_Detail;
            self.searchBarView.listModeRightButton.hidden = YES;
            [self addStationDetailView];
            break;
        // 加油站详情 (高德地图加油站)
        case MapTypeShowPoiPointFromList:
            self.searchBarView.title = self.selectedPOI.name;
            self.searchBarView.viewMode = SOSSearchBarViewMode_Detail;
            [self addPoiDetailView];
            self.poiDetailView.poiArray = [self.poiArray copy];
            break;
        default:
            break;
    }
}

- (void)addSearchBarView    {
    [self.topNavBGView removeAllSubviews];
    self.searchBarView = [SOSSearchBarView viewFromXib];
    self.searchBarView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.topNavHeightGuide.constant);
    self.searchBarView.listModeRightButton.hidden = !_isFromLifePage;
    __weak __typeof(self) weakSelf = self;
    [[self.searchBarView.listModeRightButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        // 订单记录
        [SOSDaapManager sendActionInfo:Life_WisdomOil_Entrance_OrderList];
        SOSOilOrderListVC *vc = [SOSOilOrderListVC new];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
    [self.topNavBGView addSubview:self.searchBarView];
}

// 添加 高德加油站 详情 View
- (void)addPoiDetailView    {
    [self.cardBGView removeAllSubviews];
    [self removePanGestureRecognizer];
    self.selectedPOI.sosPoiType = POI_TYPE_POI;
    self.poiDetailView = [SOSTripPOIDetailView viewFromXib];
    self.poiDetailView.frame = CGRectMake(12, 0, SCREEN_WIDTH - 24, self.cardBGViewHeightGuide.constant);
    self.poiDetailView.delegate = self;
    self.poiDetailView.mapType = self.mapType;
    self.poiDetailView.poi = [self.selectedPOI copy];
    self.poiDetailView.isFromAroundSearch = self.isFromAroundSearch;
    [self.cardBGView addSubview:self.poiDetailView];
    
    [[SOSPoiHistoryDataBase sharedInstance] insert:self.selectedPOI];
    
    [self.mapView removePoiPoints:self.poiArray];
    [self.mapView addPoiPoint:self.selectedPOI];
    [self.mapView showPoiPoints:@[self.selectedPOI]];
}

// 添加 第三方加油站 详情 View
- (void)addStationDetailView 	{
    [self.cardBGView removeAllSubviews];
    [self removePanGestureRecognizer];
    self.selectedPOI.sosPoiType = POI_TYPE_POI;
    self.stationDetailView = [SOSStationDetailView viewFromXib];
    self.stationDetailView.frame = CGRectMake(12, 0, SCREEN_WIDTH - 24, self.cardBGViewHeightGuide.constant);
    self.stationDetailView.delegate = self;
    self.stationDetailView.station = self.selectedOilStastion;
    [self.cardBGView addSubview:self.stationDetailView];
    
    [[SOSPoiHistoryDataBase sharedInstance] insert:self.selectedPOI];
    
    [self.mapView removePoiPoints:self.poiArray];
    [self.mapView addPoiPoint:self.selectedPOI];
    [self.mapView showPoiPoints:@[self.selectedPOI]];
}

// 添加 加油站 列表 View
- (void)addPoiListView    {
    [self.cardBGView removeAllSubviews];
    
    self.stationListView = [SOSTripOilStationListView viewFromXib];
    
    self.stationListView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.cardBGViewHeightGuide.constant);
    self.stationListView.delegate = self;
    self.stationListView.centerPOI = self.infoPOI;
    self.stationListView.oilInfoList = self.oilInfoList;
    self.stationListView.poiArray = [self.poiArray copy];
    self.stationListView.stationArray = [self.stationList copy];
    [self.cardBGView addSubview:self.stationListView];
    [self.stationListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.cardBGView);
    }];
    if (self.isFromLifePage) {
        self.cardBGViewTopGuideToSafeArea.priority = UILayoutPriorityDefaultHigh;
        self.cardBGViewTopGuideToSafeArea.constant = 0;
        self.funcButtonBGView.hidden = YES;
    }	else	{
        [self setTargetTableView:self.stationListView.tableView];
    }
    [self.poiArray enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(SOSPOI * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.sosPoiType = POI_TYPE_List_POI;
    }];
    
    [self.mapView removePoiPoint:self.selectedPOI];
    [self.mapView addPoiPoints:self.poiArray];
    [self.mapView showPoiPoints:self.poiArray];
}

#pragma mark - View Delegate
// 高德加油站 详情模式点击查看更多结果
- (void)showMoreResultsWithPoiArray:(NSArray <SOSPOI *> *)poiArray    {
    [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundGasSation_POIdetail_SeeMore];
    self.mapType = MapTypeOil;
}

// 三方加油站 详情模式点击查看更多结果
- (void)showMoreResults	{
    [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundGasSation_POIdetail_SeeMore];
    self.mapType = MapTypeOil;
}

// POI 列表模式点击第三方加油站
-(void)didSelectCellWithStation:(SOSOilStation *)station	{
    [SOSDaapManager sendActionInfo:Trip_WisdomOil_DiscountOil];
    SOSPOI *poi = station.transToPOI;
    self.selectedPOI = poi;
    self.selectedOilStastion = [station copy];
    self.mapType = MapTypeOilDetail;
}

// POI 列表模式点击高德加油站
- (void)didSelectCellWithPOI:(SOSPOI *)poi    {
    [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundGasSation_POIdetail_SeeMore_POI];
    self.selectedPOI = poi;
    self.mapType = MapTypeShowPoiPointFromList;
}

// 付油费
- (void)payOilButtonTappedWithPriceInfoArray:(NSArray <SOSOilStation *>*)priceInfo	{
    [SOSDaapManager sendActionInfo:Trip_WisdomOil_DiscountOil_PayFee];
    [self showGunSelectVCWithPriceInfoArray:priceInfo];
}

- (void)showGunSelectVCWithPriceInfoArray:(NSArray <SOSOilStation *>*)priceInfo		{
    SOSOilGanSelectVC *vc = [SOSOilGanSelectVC new];
    vc.station = self.stationDetailView.station;
//    vc.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    navVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:navVC animated:YES completion:^{
        vc.oilInfoArray = priceInfo;
    }];
}

#pragma mark - Map Annotation Delegate
//用户点击地图 POI 点
- (void)mapDidSelectedPoiPoint:(SOSPOI *)poi    {
    if (self.mapType == MapTypeShowPoiList && poi.sosPoiType != POI_TYPE_CURRENT_LOCATION && poi.sosPoiType != POI_TYPE_VEHICLE_LOCATION) {
        [self didSelectCellWithPOI:poi];
    }
}

- (void)dealloc    {
    [Util dismissHUD];
}

@end
