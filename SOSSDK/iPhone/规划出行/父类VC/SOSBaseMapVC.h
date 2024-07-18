//
//  SOSBaseMapVC.h
//  Onstar
//
//  Created by Shoujun Xue on 10/23/12.
//  Copyright (c) 2012 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AudioToolbox/AudioToolbox.h>
#import "BaseMapView.h"
#import "SOSSearchResult.h"
#import "SOSNavigateHeader.h"

#import "ChargeStationOBJ.h"
#import "SOSTravelMapView.h"
#import "SOSInfoTableView.h"
#import "SOSActionNavigation.h"

@class BaseSearchOBJ;

@interface SOSBaseMapVC : UIViewController <UIAlertViewDelegate>     {
    ///长按地图相应位置的Poi点
    SOSPOI *longPressPointPoi;
    
    ///我的足迹POI点数组,概览模式 ， 数组内元素为 SOSPOI
    NSMutableArray <SOSPOI *>*footPrintOverViewPoisArray;
    ///我的足迹POI点数组,详情模式 ， 数组内元素为 SOSPOI
    NSMutableArray <SOSPOI *>*footPrintDetailPoisArray;
    
    BOOL    showtraffic;
    UserOperation           lastOperation;
    
    BOOL shouldShowSearchBar;
    
    SOSPOI * userLocationPOI;
    SOSPOI * vehicleLocationPOI;
    
    BaseSearchOBJ *searchOBJ;
    
    
    UIPanGestureRecognizer *panGR;
}

@property (weak, nonatomic) IBOutlet UIView      *contentMapView;
@property (weak, nonatomic) IBOutlet UIButton    *buttonVehicleLocation;

@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIView *routeInfoView;
@property (weak, nonatomic) IBOutlet SOSInfoTableView *infoTableView;
@property (weak, nonatomic) IBOutlet SOSTravelMapView *mapLocationInfoView;
@property (weak, nonatomic) IBOutlet UIView *topButtonBGView;
@property (weak, nonatomic) IBOutlet UIView *zoomButtonBGView;
@property (weak, nonatomic) IBOutlet UIButton *trafficButton;
@property (weak, nonatomic) IBOutlet SOSActionNavigation *actionNavigation;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topButtonBGViewHeightGuide;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topButtonBGViewTopGuide;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomButtomBGViewHeightGuide;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionNavHeightGuide;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapLocationInfoViewHeightGuide;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapInfoViewButtomGuide;

@property (weak, nonatomic) IBOutlet UIView *LBSLocationButtonBGView;
@property (weak, nonatomic) IBOutlet UILabel *LBSRefreshCounterLabel;

@property (weak, nonatomic) IBOutlet SOSCustomView *navSearchBGView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoTableViewHeightGuide;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *zoomButtonBGViewBottomGuide;

@property(nonatomic, assign) BOOL showRouteView;

@property (nonatomic, strong) NNLBSDadaInfo *LBSDataInfo;

@property (nonatomic, strong) ChargeStationOBJ *chargeStation;

@property (nonatomic, strong) NNDealers *dealer;



@property (nonatomic, assign)   SearchType              searchType;
@property (nonatomic, assign)   BOOL                    shouldResponseToLongPress;
@property (nonatomic, strong)   NSArray                 *routeline;
@property (nonatomic, strong)   SOSCityGeocodingInfo    *cityInfo;
@property (nonatomic, strong)   BaseMapView             *mapView;
/// 用户当前定位点
@property (nonatomic, strong)   SOSPOI                  *currentPOI;

/// 地图上需要显示信息的 POI 点,如搜索结果,收藏夹,家或公司地址,LBS定位点等
@property (nonatomic, strong)   SOSPOI                  *infoPOI;

///当前选中的 LBS POI点
@property (nonatomic, strong)   SOSLBSPOI               *selectedLBSPOI;
///当前选中的POI点
@property (nonatomic, strong)   SOSPOI                  *selectedPOI;

@property (weak, nonatomic)  NSLayoutConstraint *mapViewBottomGuide;
///地图显示类型
@property (nonatomic, assign) MapType mapType;
/// 需要在地图上显示的POI数组
@property (nonatomic, copy) NSArray <SOSPOI *>* poisShowingOnMap;

///路径起点和终点,值为SOSAnnotionView组成的数组
@property (nonatomic, strong) NSMutableArray *routePoisArray;

/// 获取到车辆定位后,是否需要在当前VC显示
@property (nonatomic, assign) BOOL shouldShowVehicleLocation;

- (void)initShowOnMapAnnotations:(SOSPOI *)poiInfo;


/// 显示车辆定位,供外部调用
- (void)showVehicleLocation:(NSDictionary *)dict;


- (IBAction)zoomInAndZoomOut:(UIButton *)sender;
- (IBAction)buttonVehicleLocationTapped;
/// 路况
- (IBAction)trafficButtonTapped:(UIButton *)sender;
- (IBAction)buttonLocationTapped;
- (void)showLocationPoiPoint;
/// 规划路径
- (void)configRouteButtonAction;

- (void)showFootPrintPoiPoints:(NSArray *)poiPointsArray;

//显示所选 POI 的相关信息,父类仅声明,需在子类实现
- (void)showPositionInfoViewWithPoiInfo:(SOSPOI *)poi;
- (void)reverseCurrentLocation:(CLLocationCoordinate2D)coordinate;

#pragma mark - 上划手势处理
- (void)dragScrollview:(UIPanGestureRecognizer *)recognizer;


- (void)showTraffic:(NSNumber *)show;

- (id)initWithPoiInfo:(SOSPOI *)poiInfo;

@end
