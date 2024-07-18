//
//  SOSTripDealerVC.m
//  Onstar
//
//  Created by Coir on 2019/4/30.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSPOIMapVC.h"
#import "SOSDealerTool.h"
#import "SOSTripDealerVC.h"
#import "SOSSearchBarView.h"
#import "SOSTripPOIDetailView.h"
#import "SOSTripDealerContainerVC.h"

@interface SOSTripDealerVC () <SOSTripPOIDetailDelegate>

@property (nonatomic, weak) SOSSearchBarView *searchBarView;
@property (nonatomic, weak) SOSTripPOIDetailView *poiDetailView;
@property (nonatomic, strong) SOSTripDealerContainerVC *dealerContainerVC;

@property (nonatomic, strong) NSMutableArray *dealerPOIArray;

@property (nonatomic, strong) NSMutableArray <NNDealers *>* recommendDealerArray;

@end

@implementation SOSTripDealerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addDealerObserver];
    self.backDaapFunctionID = Trip_GoWhere_AroundDealer_POIdetail_Back;
}

- (void)setDealerArray:(NSArray<NNDealers *> *)dealerArray	{
    _dealerArray = [dealerArray mutableCopy];
    self.dealerPOIArray = [NSMutableArray array];
    self.recommendDealerArray = [NSMutableArray array];
    if (dealerArray.count) {
        self.selectedPOI = dealerArray[0].poi;
        if (self.selectedDealer == nil)		self.selectedDealer = dealerArray[0];
        for (NNDealers *dealer in dealerArray) {
            SOSPOI *poi = dealer.poi;
            poi.sosPoiType = POI_TYPE_List_POI;
            [self.dealerPOIArray addObject:poi];
            // 拆分 推荐/附近 经销商
            if (dealer.isRecommendDealer) {
                [self.dealerArray removeObject:dealer];
                [self.recommendDealerArray addObject:dealer];
            }
        }
    }
}

- (void)addDealerObserver	{
    // 周边经销商 在地图上显示列表
    __weak __typeof(self) weakSelf = self;
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:KNeedShowDealerListMapNotify object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        if (!weakSelf)    return;
        NSDictionary *notiDic = x.object;
        UITableView *tableView = notiDic[@"tableView"];
        [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundDealer_POIdetail_SeeMore_AroundPreferDealerTab];
        if (!weakSelf.fullScreenMode) 	[weakSelf setTargetTableView:tableView];
        [weakSelf.mapView removePoiPoint:weakSelf.selectedPOI];
        [weakSelf.mapView addPoiPoints:weakSelf.dealerPOIArray];
        [weakSelf.mapView showPoiPoints:weakSelf.dealerPOIArray];
        
    }];
    // 首选经销商 在地图上显示
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:KNeedShowFirstDealerMapNotify object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        if (!weakSelf)	return;
        [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundDealer_POIdetail_SeeMore_PreferDealerTab];
        [weakSelf.mapView removePoiPoints:weakSelf.dealerPOIArray];
        weakSelf.selectedPOI.sosPoiType = POI_TYPE_List_POI;
        [weakSelf.mapView addPoiPoint:weakSelf.selectedPOI];
        [weakSelf.mapView showPoiPoints:@[weakSelf.selectedPOI]];
        
    }];
    
    // 经销商列表 Cell 点击事件
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:KDealerMapVCCellTappedNotify object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        if (!weakSelf)    return;
        [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundDealer_POIdetail_SeeMore_AroundPreferDealerTab_POI];
        for (UIViewController *vc in weakSelf.childViewControllers) {
            [vc removeFromParentViewController];
        }
        NSInteger index = [x.object integerValue];
        if (weakSelf.dealerArray.count > index) {
            NNDealers *dealer = weakSelf.dealerArray[index];
            if (weakSelf.fullScreenMode) {
                [weakSelf jumpMapVCWithDealer:dealer];
            }    else    {
                weakSelf.selectedPOI = dealer.poi;
                weakSelf.selectedDealer = dealer;
                weakSelf.mapType = MapTypeShowDealerPOI;
            }
        }
    }];
    
    // 首选经销商点击事件
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:KFirstDealerViewTappedNotify object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        if (!weakSelf)    return;
        [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundDealer_POIdetail_SeeMore_PreferDealerTab_POI];
        [weakSelf.mapView removePoiPoint:weakSelf.selectedPOI];
        NSDictionary *dealerDic = x.object;
        if (dealerDic.count) {
            for (UIViewController *vc in weakSelf.childViewControllers) {
                [vc removeFromParentViewController];
            }
            NNDealers *dealer = [NNDealers mj_objectWithKeyValues:dealerDic];
            if (weakSelf.fullScreenMode) {
                [weakSelf jumpMapVCWithDealer:dealer];
            }	else	{
                weakSelf.selectedPOI = dealer.poi;
                weakSelf.selectedDealer = dealer;
                weakSelf.mapType = MapTypeShowDealerPOI;
            }
        }
    }];
    
    // 地图页面进入/退出全屏模式
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:KMapVCEnterFullscreenNotify object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        if (!weakSelf)    return;
        BOOL enterFullScreenMode = [x.object boolValue];
        if (weakSelf.fullScreenMode) 	return;
        if (enterFullScreenMode) {
            weakSelf.cardBGViewTopGuideToSafeArea.priority = UILayoutPriorityDefaultHigh;
            weakSelf.cardBGViewTopGuideToSafeArea.constant = 0;
            weakSelf.searchBarView.viewMode = SOSLBSBGViewMode_List;
            [UIView animateWithDuration:.1 animations:^{
                [weakSelf.view layoutIfNeeded];
            }];
        }    else    {
            SOSTripAroundDealerVC *aroundDealerVC = weakSelf.dealerContainerVC.aroundDealerVC;
            if (aroundDealerVC) {
                [aroundDealerVC showBrandDataView:NO];
            }
        }
    }];
    
    // 周边经销商更换品牌筛选
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:KAroundDealerChangeBrandNotify object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        if (!weakSelf)    return;
        [weakSelf.mapView removePoiPoints:weakSelf.dealerPOIArray];
        dispatch_async_on_main_queue(^{
            [Util showHUD];
            weakSelf.view.userInteractionEnabled = NO;
        });
        SOSDealerBrandType selectBrand = [x.object intValue];
        [SOSDealerTool requestDealerListWithCenterPOI:weakSelf.infoPOI Brand:selectBrand Success:^(NSArray<NNDealers *> *dealerList) {
            [Util dismissHUD];
            dispatch_async_on_main_queue(^{
                weakSelf.view.userInteractionEnabled = YES;
                weakSelf.dealerArray = dealerList.mutableCopy;
                [weakSelf addDealerListView];
            });
        } Failure:^{
            [Util dismissHUD];
            dispatch_async_on_main_queue(^{
                weakSelf.view.userInteractionEnabled = YES;
                weakSelf.dealerArray = @[].mutableCopy;
                [weakSelf addDealerListView];
            });
        }];
    }];
}

- (void)jumpMapVCWithDealer:(NNDealers *)dealer	{
    SOSPOIMapVC *indexVC = [[SOSPOIMapVC alloc] initWithPoiInfo:dealer.poi];
    indexVC.backDaapFunctionID = Dealeraptmt_Map_back;
    indexVC.dealer = dealer;
    indexVC.mapType = MapTypeShowDealerPOI;
    [CustomerInfo sharedInstance].isInDelear = YES;
    [self.navigationController pushViewController:indexVC animated:YES];
}

- (void)setMapType:(MapType)mapType        {
    [super setMapType:mapType];
    [self addSearchBarView];
    self.cardBottomCoverView.hidden = YES;
    switch (mapType) {
        // 经销商详情
        case MapTypeShowDealerPOI:
            self.searchBarView.title = self.selectedPOI.name;
            self.searchBarView.viewMode = SOSSearchBarViewMode_Detail;
            [self addPoiDetailView];
            break;
        // 经销商列表
        case MapTypeShowPoiList:
            if (self.fullScreenMode)     {
                self.cardBottomCoverView.hidden = NO;
                [self removePanGestureRecognizer];
            }
            self.searchBarView.title = @"经销商";
            self.searchBarView.viewMode = self.fullScreenMode ? SOSSearchBarViewMode_List :  SOSSearchBarViewMode_Detail;
            [self addDealerListView];
            
            
            
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
    if (self.fullScreenMode) {
        __weak __typeof(self) weakSelf = self;
        self.searchBarView.listModeRightButton.hidden = NO;
        [self.searchBarView.listModeRightButton setTitleForAllState:@"预约记录"];
        [self.searchBarView.listModeRightButton setImage:nil forState:UIControlStateNormal];
        [[self.searchBarView.listModeRightButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            // 预约记录
            [SOSDaapManager sendActionInfo:Life_WisdomOil_Entrance_OrderList];
            SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:SOSDEALER_RECORD];
            vc.isDealer = YES;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }];
    }	else	{
        self.searchBarView.listModeRightButton.hidden = YES;
    }
    
    
    
    
    [self.topNavBGView addSubview:self.searchBarView];
}

// 添加 经销商 详情 View
- (void)addPoiDetailView    {
    [self.cardBGView removeAllSubviews];
    [self removePanGestureRecognizer];
    self.poiDetailView = [SOSTripPOIDetailView viewFromXib];
    self.poiDetailView.frame = CGRectMake(12, 0, SCREEN_WIDTH - 24, self.cardBGViewHeightGuide.constant);
    self.poiDetailView.delegate = self;
    self.poiDetailView.mapType = self.mapType;
    self.poiDetailView.poi = [self.selectedPOI copy];
    self.poiDetailView.dealer = self.selectedDealer;
    [self.cardBGView addSubview:self.poiDetailView];
    
    [self.mapView removePoiPoints:self.dealerPOIArray];
    [self.mapView addPoiPoint:self.selectedPOI];
    [self.mapView showPoiPoints:@[self.selectedPOI]];
}

// 添加经销商列表 View
- (void)addDealerListView    {
    [self.cardBGView removeAllSubviews];
    [self.mapView removePoiPoint:self.selectedPOI];
    if (self.dealerContainerVC == nil) {
        self.dealerContainerVC = [SOSTripDealerContainerVC new];
        self.dealerContainerVC.fullScreenMode = self.fullScreenMode;
        [self.cardBGView addSubview:self.dealerContainerVC.view];
        [self.dealerContainerVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.cardBGView);
        }];
        [self addChildViewController:self.dealerContainerVC];
        [self.dealerContainerVC configSelf];
    }	else	{
        [self.cardBGView addSubview:self.dealerContainerVC.view];
        [self.dealerContainerVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.cardBGView);
        }];
    }
    self.dealerContainerVC.dealerArray = [self.dealerArray copy];
    self.dealerContainerVC.recommendDealerArray = self.recommendDealerArray.copy;
    if (self.fullScreenMode) {
        self.cardBGViewTopGuideToSafeArea.priority = UILayoutPriorityDefaultHigh;
        self.cardBGViewTopGuideToSafeArea.constant = 0;
        self.funcButtonBGView.hidden = YES;
    }
}

/// 点击查看更多结果
- (void)showMoreResultsWithPoiArray:(NSArray <SOSPOI *> *)poiArray	{
    [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundDealer_POIdetail_SeeMore];
    [self.mapView removePoiPoint:self.selectedPOI];
    self.mapType = MapTypeShowPoiList;
}



- (void)showDealerHistory 	{
    SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:SOSDEALER_RECORD];
    vc.isDealer = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)dealloc	{
    
}

@end
