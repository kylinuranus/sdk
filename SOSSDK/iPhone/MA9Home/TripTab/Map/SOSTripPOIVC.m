//
//  SOSTripPOIVC.m
//  Onstar
//
//  Created by Coir on 2019/4/17.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSTripPOIVC.h"
#import "SOSSearchBarView.h"
#import "SOSTripPOIListView.h"
#import "SOSTripPOIDetailView.h"
#import "SOSTripHomeDetailView.h"
#import "SOSTripHomeModifyDetailView.h"

@interface SOSTripPOIVC () <SOSTripPOIDetailDelegate, SOSTripHomeModifyDelegate, SOSTripPOIListDelegate>

@property (nonatomic, weak) SOSSearchBarView *searchBarView;
@property (nonatomic, weak) SOSTripPOIListView *poiListView;
@property (nonatomic, weak) SOSTripPOIDetailView *poiDetailView;
@property (nonatomic, weak) SOSTripHomeDetailView *homeDetailView;
@property (nonatomic, weak) SOSTripHomeModifyDetailView *homeSelectView;

@end

@implementation SOSTripPOIVC

@synthesize infoPOI = _infoPOI;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.mapView addPoiPoint:[CustomerInfo sharedInstance].currentPositionPoi];
}

- (void)viewDidAppear:(BOOL)animated	{
    [super viewDidAppear:animated];
    if (self.operationType) {
        self.backDaapFunctionID = Trip_GoWhere_Set_Search_SearchResult_POIdetail_Back;
    }	else	{
        self.backDaapFunctionID = Trip_GoWhere_Search_POIdetailList_Back;
    }
}

- (void)setPoiArray:(NSArray<SOSPOI *> *)poiArray	{
    _poiArray = poiArray;
    if (poiArray.count) {
        self.selectedPOI = poiArray[0];
        if (self.infoPOI == nil)	_infoPOI = self.selectedPOI;
        else						self.infoPOI.keyWords = self.selectedPOI.keyWords;
    }
}

- (void)setMapType:(MapType)mapType		{
    [super setMapType:mapType];
    [self addSearchBarView];
    switch (mapType) {
/*
        // 加油站详情
        case MapTypeOil:
            self.backDaapFunctionID = Trip_GoWhere_AroundGasSation_POIdetail_Back;
            self.searchBarView.title = self.selectedPOI.name;
 			self.searchBarView.viewMode = SOSSearchBarViewMode_Detail;
            self.infoPOI.keyWords = @"加油站";
            [self addPoiDetailView];
            self.poiDetailView.poiArray = self.poiArray;
            break;
 */
        // 显示 POI 详情
        case MapTypeShowPoiPoint:
            self.searchBarView.title = self.selectedPOI.name;
            self.searchBarView.viewMode = SOSSearchBarViewMode_Detail;
            [self addPoiDetailView];
            self.poiDetailView.poiArray = nil;
            break;
        // 地图展示Poi点, 从列表模式进入,需显示 "查看更多"
        case MapTypeShowPoiPointFromList:
            self.searchBarView.title = self.selectedPOI.name;
            self.searchBarView.viewMode = SOSSearchBarViewMode_Detail;
            [self addPoiDetailView];
            self.poiDetailView.poiArray = [self.poiArray copy];
            break;
            
        // 加油站列表
        case MapTypeOil:
            self.searchBarView.title = self.infoPOI.keyWords;
            self.searchBarView.viewMode = SOSSearchBarViewMode_Detail;
            [self addPoiListView];
            break;
        // 搜索结果列表
        case MapTypeShowPoiList:
            self.searchBarView.title = self.infoPOI.keyWords;
            self.searchBarView.viewMode = SOSSearchBarViewMode_Detail;
            [self addPoiListView];
            break;
        // 展示住家地址
        case MapTypeShowHomeAddress:
        // 展示公司地址
        case MapTypeShowCompanyAddress:
            self.searchBarView.title = self.selectedPOI.name;
            self.searchBarView.viewMode = SOSSearchBarViewMode_Detail;
            [self addHomeDetailView];
            break;
        // 选点模式,用于选择 住家/公司/路线起终点/围栏中心点 等
        case MapTypePickPoint:
        // 修改公司地址
        case MapTypePickPointFromList:
            self.searchBarView.title = self.selectedPOI.name;
            self.searchBarView.viewMode = SOSSearchBarViewMode_Detail;
            [self addHomeSelectView];
            break;
        default:
            self.cardBGViewBottomGuide.constant = 12.f;
            break;
    }
}

- (void)addSearchBarView	{
    [self.topNavBGView removeAllSubviews];
    self.searchBarView = [SOSSearchBarView viewFromXib];
    self.searchBarView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.topNavHeightGuide.constant);
    [self.topNavBGView addSubview:self.searchBarView];
}

// 添加 POI/加油站 详情 View
- (void)addPoiDetailView	{
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
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.mapView showPoiPoints:@[self.selectedPOI]];
//    });
}

// 添加 家/公司 展示详情
- (void)addHomeDetailView	{
    [self.cardBGView removeAllSubviews];
    [self removePanGestureRecognizer];
    self.selectedPOI.sosPoiType = (self.mapType == MapTypeShowHomeAddress) ? POI_TYPE_Home : POI_TYPE_Company;
    self.homeDetailView = [SOSTripHomeDetailView viewFromXib];
    self.homeDetailView.frame = CGRectMake(12, 0, SCREEN_WIDTH - 24, self.cardBGViewHeightGuide.constant);
    self.homeDetailView.poi = self.selectedPOI;
    [self.cardBGView addSubview:self.homeDetailView];
    
    [self.mapView addPoiPoint:self.selectedPOI];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.mapView showPoiPoints:@[self.selectedPOI]];
//    });
}

// 添加 家/公司 修改详情
- (void)addHomeSelectView	{
    [self.cardBGView removeAllSubviews];
    [self removePanGestureRecognizer];
    
    self.selectedPOI.sosPoiType = POI_TYPE_POI;
    
    self.homeSelectView = [SOSTripHomeModifyDetailView viewFromXib];
    self.homeSelectView.frame = CGRectMake(12, 0, SCREEN_WIDTH - 24, self.cardBGViewHeightGuide.constant);
    self.homeSelectView.operationType = self.operationType;
    self.homeSelectView.poi = self.selectedPOI;
    self.homeSelectView.poiArray = self.poiArray;
    self.homeSelectView.delegate = self;
    [self.cardBGView addSubview:self.homeSelectView];
    
    [self.mapView addPoiPoint:self.selectedPOI];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.mapView showPoiPoints:@[self.selectedPOI]];
//    });
}

// 添加 POI/加油站 列表 View
- (void)addPoiListView	{
    [self.cardBGView removeAllSubviews];
    self.poiListView = [SOSTripPOIListView viewFromXib];
    
    if (self.operationType) 	{
        self.poiListView.tableType = SOSTripListTableType_selectPoint;
    }	else	{
        if (self.mapTypeBeforChange == MapTypeOil) {
            self.poiListView.tableType = SOSTripListTableType_Oli_List;
        }	else	{
            self.poiListView.tableType = SOSTripListTableType_POI_List;
        }
    }
    
    self.poiListView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.cardBGViewHeightGuide.constant);
    self.poiListView.delegate = self;
    self.poiListView.poiArray = [self.poiArray copy];
    self.poiListView.operationType = self.operationType;
    [self.cardBGView addSubview:self.poiListView];
    [self.poiListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.cardBGView);
    }];
    [self setTargetTableView:self.poiListView.tableView];
    
    [self.poiArray enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(SOSPOI *poi, NSUInteger idx, BOOL *stop) {
        poi.sosPoiType = POI_TYPE_List_POI;
    }];
    
    [self.mapView removePoiPoint:self.selectedPOI];
    [self.mapView addPoiPoints:self.poiArray];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.mapView showPoiPoints:self.poiArray];
//    });
}

#pragma mark - View Delegate
// POI 详情模式点击查看更多结果 (含 加油站)
- (void)showMoreResultsWithPoiArray:(NSArray <SOSPOI *> *)poiArray	{
    if (self.operationType == OperationType_Void) {
        [SOSDaapManager sendActionInfo:Trip_GoWhere_POIdetail_SeeMore];
    }	else	{
       	if (self.mapType == MapTypeOil) {
            [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundGasSation_POIdetail_SeeMore];
        }
    }
    self.mapTypeBeforChange = self.mapType;
    self.mapType = MapTypeShowPoiList;
}

// 设定 家/公司 地址模式 点击查看更多结果
- (void)modifyHomeViewShowMoreResultsWithPoiArray:(NSArray<SOSPOI *> *)poiArray		{
    if (self.operationType == OperationType_Set_GroupTrip_Destination) {
        [SOSDaapManager sendActionInfo:GroupToTravel_Group_SetDestination_POICard_More];
    }
    self.mapType = MapTypeShowPoiList;
}

// POI 列表模式点击列表某项
- (void)didSelectCellWithPOI:(SOSPOI *)poi	{
    if (self.operationType) {
        [SOSDaapManager sendActionInfo:Trip_GoWhere_Set_Search_SearchResult_POI];
    }	else	{
        if (self.mapType == MapTypeOil) {
            [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundGasSation_POIdetail_SeeMore_POI];
        }	else	{
            [SOSDaapManager sendActionInfo:Trip_GoWhere_Search_POIdetailList_POI];
        }
    }
    self.selectedPOI = poi;
    if (self.poiListView.tableType == SOSTripListTableType_POI_List || self.poiListView.tableType == SOSTripListTableType_Oli_List) {
        self.mapType = self.mapTypeBeforChange ? : MapTypeShowPoiPointFromList;
    }	else if (self.poiListView.tableType == SOSTripListTableType_selectPoint)	{
        self.mapType = MapTypePickPointFromList;
    }
}

#pragma mark - Map Annotation Delegate
//用户点击地图 POI 点
- (void)mapDidSelectedPoiPoint:(SOSPOI *)poi    {
    if (self.mapType == MapTypeShowPoiList && poi.sosPoiType != POI_TYPE_CURRENT_LOCATION && poi.sosPoiType != POI_TYPE_VEHICLE_LOCATION) {
        [self didSelectCellWithPOI:poi];
    }
}

- (void)dealloc	{
}


@end
