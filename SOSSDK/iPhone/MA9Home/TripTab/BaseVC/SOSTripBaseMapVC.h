//
//  SOSTripBaseMapVC.h
//  Onstar
//
//  Created by Coir on 2019/4/4.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseMapView.h"
#import "BaseSearchOBJ.h"
#import "SOSSearchResult.h"
#import "SOSLBSBGScrollView.h"
#import "SOSTripCardBGScrollView.h"
#import "SOSTripFuncButtonBGView.h"
#import "SOSTirpUserLocationView.h"
#import "SOSTirpVehicleLocationView.h"

//@class BaseSearchOBJ;

NS_ASSUME_NONNULL_BEGIN

@class BaseSearchOBJ, SOSTripFuncButtonBGView;

@interface SOSTripBaseMapVC : UIViewController <PoiDelegate, GeoDelegate, ErrorDelegate, MAMapViewDelegate, AnnotationDelegate, SOSTirpUserLocationDelegate, SOSTirpVehicleLocationDelegate, SOSLBSBGScrollCardDelegate>

@property (weak, nonatomic) IBOutlet UIView *mapBGView;
@property (weak, nonatomic) IBOutlet UIView *topNavBGView;
@property (weak, nonatomic) IBOutlet UIView *topStatusBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topNavTopGuide;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topNavHeightGuide;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topNavLeadingGuide;

@property (weak, nonatomic) IBOutlet UIButton *trafficButton;

@property (weak, nonatomic) IBOutlet SOSTripFuncButtonBGView *funcButtonBGView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *funcButtonBGViewHeightGuide;

@property (weak, nonatomic) IBOutlet UIButton *userLocationGuideButton;
@property (weak, nonatomic) IBOutlet UIButton *vehicleLocationGuideButton;
@property (weak, nonatomic) IBOutlet UIButton *lbsGuideButton;

@property (weak, nonatomic) IBOutlet UIView *userLocationFuncBGView;
@property (weak, nonatomic) IBOutlet UIButton *userLocationButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userLocationBGWidthGuide;

@property (weak, nonatomic) IBOutlet UIView *vehicleLocationFuncBGView;
@property (weak, nonatomic) IBOutlet UIButton *vehicleLocationButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vehicleBGWidthGuide;

@property (weak, nonatomic) IBOutlet UIView *lbsFuncBGView;
@property (weak, nonatomic) IBOutlet UIButton *lbsButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lbsBGWidthGuide;

@property (weak, nonatomic) IBOutlet UIView *cardBGView;
@property (weak, nonatomic) IBOutlet UIView *cardBottomCoverView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardBGViewHeightGuide;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardBGViewBottomGuide;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardBGViewTopGuide;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardBGViewTopGuideToSafeArea;

@property (weak, nonatomic) IBOutlet UIButton *userLocationCloseButton;
@property (weak, nonatomic) IBOutlet UIButton *vehicleCloseButton;
@property (weak, nonatomic) IBOutlet UIButton *lbsCloseButton;

@property (strong, nonatomic, nullable) UIPanGestureRecognizer *panGesForListView;

/// 初始化时传入的 POI 点
@property (nonatomic, strong, readonly) SOSPOI *infoPOI;

///当前选中的POI点
@property (nonatomic, strong) SOSPOI *selectedPOI;

@property (nonatomic, strong) BaseSearchOBJ *searchOBJ;

/// 用户当前定位点
@property (nonatomic, strong) SOSPOI *currentPOI;
/// 车辆当前定位点
@property (nullable, nonatomic, strong) SOSPOI *vehiclePOI;

@property (nonatomic, strong) BaseMapView *mapView;

/// 地图类型
@property (nonatomic, assign) MapType mapType;

- (instancetype)initWithPOI:(SOSPOI *)poi;

/// 列表模式时,当前呈现的 TableVIew
@property (nonatomic, weak) UITableView *targetTableView;

/// 添加底部卡片列表模式滑动手势
- (void)addPanGesForListMode;
/// 移除底部卡片列表模式滑动手势
- (void)removePanGestureRecognizer;

//交给子类重写及调用
- (void)configView;
- (IBAction)showFuncBGView:(UIButton *)sender;
- (IBAction)trafficButtonTapped:(UIButton *)sender;
- (void)hideFunBGViewWithFuncButton:(UIButton *)sender;

/// 逆地理编码,显示车辆定位,供外部调用
- (void)showVehicleLocation:(nullable NSDictionary *)dict;

/// 显示路况
- (void)showTraffic:(NSNumber *)show;

/// 显示当前用户定位, ShouldResetMap 是否重置地图中心 & 缩放(未获取到定位时,会刷新定位)
- (void)showUserPOIShouldResetMap:(BOOL)reset;

/// 显示缓存的车辆定位, ShouldResetMap 是否重置地图中心 & 缩放(不会调用刷新方法)
- (void)showVehiclePOIShouldResetMap:(BOOL)reset;

@end

NS_ASSUME_NONNULL_END
