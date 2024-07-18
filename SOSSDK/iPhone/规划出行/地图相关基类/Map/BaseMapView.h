//
//  BaseMapView.h
//  Onstar
//
//  Created by Coir on 16/2/23.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "SOSMapHeader.h"
#import "BaseAnnotationView.h"
#import "MAAnnotationView+Visible.h"
#import "SOSGroupTripAnnotionView.h"

@protocol AnnotationDelegate <NSObject>

@optional

- (void)mapRegionChanging;
- (void)mapRegionWillChange;
- (void)mapRegionDidChanged;

- (void)mapDidRefreshUserLocation:(SOSPOI *)poi Success:(BOOL)success;

- (void)mapDidSelectedPoiPoint:(SOSPOI *)poi;

- (void)mapWillMoveByUser:(BOOL)wasUserAction;

- (void)mapWillZoomByUser:(BOOL)wasUserAction;

- (void)mapDidMoveByUser:(BOOL)wasUserAction;

- (void)mapDidZoomByUser:(BOOL)wasUserAction;

- (void)mapDidSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate;

- (void)mapDidLongPressedAtCoordinate:(CLLocationCoordinate2D)coordinate;

- (void)userDidSelectCalloutViewRightButton;

@end

@interface BaseMapView : MAMapView  <MAMapViewDelegate>

@property (nonatomic, assign) BOOL isLBSMapMode;
@property (nonatomic, assign) BOOL isGPSEndMapMode;

/// 是否为组队出行模式
@property (nonatomic, assign) BOOL isGroupTripMode;
/// 组队模式 我的位置 图标
@property (nonatomic, strong) UIImage *locationAvatarImg;
/// 组队模式 我 的队员状态
@property (nonatomic, assign) SOSGroupTripTeamMemberStatus userLocationMemberStatus;
/// 组队模式 我的队员 ID
@property (nonatomic, copy) NSString *userLocationTeamID;

@property (nonatomic, assign) BOOL isLBSGeofenceMapMode;

@property (nonatomic, weak) id <AnnotationDelegate> annotationDelegate;

///刷新用户定位点
- (void)refreshUserLocationPoint;
///刷新用户定位点, ShouldResetMapCenter 是否重置地图中心以及缩放
- (void)refreshUserLocationPointShouldResetMapCenter:(BOOL)shouldReset;

///移除之前车辆定位POI点
- (void)removeCarLocationPoint;

///添加POI点
- (void)addPoiPoint:(SOSPOI *)poi;

///添加POI点数组
- (void)addPoiPoints:(NSArray *)pois;

///移除POI点
- (void)removePoiPoint:(SOSPOI *)poi;

///移除POI点数组
- (void)removePoiPoints:(NSArray *)pois;

///显示路线
- (void)showPolylines:(NSArray *)polylins;

///取得当前地图上可见的指定类型的POI点,数组中为SOSPOI对象
- (NSArray *)getVisiableFootPrintPOIPointsArrayByType:(POIType)type;

///显示地图上数组中POI点,使其显示在同一页面,必须先调用addPoiPoint添加
- (void)showPoiPoints:(NSArray *)poiPoints;

///显示地图上数组中POI点,使其显示在同一页面,必须先调用addPoiPoint添加
- (void)showPoiPoints:(NSArray *)poiPoints animated:(BOOL)animated;

///显示地图上数组中POI点,使其显示在同一页面,needResetMap 是否重新设定地图缩放,必须先调用addPoiPoint添加
- (void)showPoiPoints:(NSArray *)poiPoints animated:(BOOL)animated NeedResetMap:(BOOL)needResetMap;

///显示地图上所有POI点,使其显示在同一页面
- (void)showCachedPoiPoints;

///取得 MapView 上特定 Annotation 对应的 POI 点
- (SOSPOI *)annotationToPOIPoint:(BaseAnnotation *)annotation;

@end
