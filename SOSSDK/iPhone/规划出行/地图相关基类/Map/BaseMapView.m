//
//  BaseMapView.m
//  Onstar
//
//  Created by Coir on 16/2/23.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "BaseMapView.h"
#import "CustomerInfo.h"
#import "BaseSearchOBJ.h"
#import "SOSSearchResult.h"
#import "SOSUserLocation.h"
#import "CustomGeoAnnotationView.h"
#import "MAAnnotationView+Visible.h"

@interface BaseMapView ()   <GeoDelegate, ErrorDelegate>  {
    int locationCount;
    SOSPOI *carLocationPOI;
    BaseSearchOBJ *searchOBJ;
    SOSPOI *currentLocationPOI;
    NSMutableArray *poiPointsArray;
    NSMutableArray *annotationsArray;
}

@property (nonatomic, strong) MAAnnotationView *userLocationAnnotationView;
@property (nonatomic, assign) BOOL shouldUpdateMapCenter;

@end

@implementation BaseMapView

#define DefaultSpan         0.004
#define SpanOffsetRatio     1.8
#define CenterRatio         (0.02/11.5)
#define Annotion_Commen_Resue_ID  @"Annotion_Commen_Resue_ID"


- (instancetype)init    {
    self = [super init];
    if (self) {
        [self configSelf];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame     {
    self = [super initWithFrame:frame];
    if (self) {
        [self configSelf];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self configSelf];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self configSelf];
}

- (void)configSelf  {
//    self.language = 0;//[[SOSLanguage getCurrentLanguage] isEqualToString:LANGUAGE_ENGLISH];
    annotationsArray = [NSMutableArray array];
    poiPointsArray = [NSMutableArray array];
    self.showsScale = NO;
    self.delegate = self;
    self.showsCompass = NO;
    self.userTrackingMode = MAUserTrackingModeNone;
    SOSPOI *poi = [CustomerInfo sharedInstance].currentPositionPoi;
    if (poi) {
        self.centerCoordinate = CLLocationCoordinate2DMake(poi.latitude.doubleValue, poi.longitude.doubleValue);
    }
}

- (void)refreshUserLocationPoint	{
    [self refreshUserLocationPointShouldResetMapCenter:YES];
}

- (void)refreshUserLocationPointShouldResetMapCenter:(BOOL)shouldReset     {
    if ([[SOSUserLocation sharedInstance] checkAuthorize] == NO)    return;
    if (!searchOBJ) {
        searchOBJ = [[BaseSearchOBJ alloc] init];
        searchOBJ.geoDelegate = self;
        searchOBJ.errorDelegate = self;
    }
    
    locationCount = 0;
    self.shouldUpdateMapCenter = shouldReset;
    self.showsUserLocation = YES;
    self.pausesLocationUpdatesAutomatically = NO;
}

- (void)removeCarLocationPoint      {
    if (carLocationPOI) {
        [self removePoiPoint:carLocationPOI];
    }
}

- (void)addPoiPoint:(SOSPOI *)poi   {
    if (!poi)       return;
    NSArray *tempPoiArray = [NSArray arrayWithArray:poiPointsArray];
    
    //    if (poi.sosPoiType == POI_TYPE_GEOFECING) {
    //        [self removePoiPoints:poiPointsArray];
    //    }    else    {
    for (SOSPOI *tempPoi in tempPoiArray) {
        ///过滤重复点
        if (poi.x.doubleValue == tempPoi.x.doubleValue && poi.y.doubleValue == tempPoi.y.doubleValue && tempPoi.sosPoiType == poi.sosPoiType && poi.sosPoiType!=POI_TYPE_MIRROR) {
            return;
        }
        // 若要添加的 POI 点 与当前地图上某个点类型相同
        NSLog(@"tempPoi = %p poi= %p",tempPoi,poi);
        if (poi.sosPoiType == tempPoi.sosPoiType) {
            switch (poi.sosPoiType) {
                // 避免重复添加车辆定位点
                case POI_TYPE_VEHICLE_LOCATION:
                    carLocationPOI = poi;
                    [self removePoiPoint:tempPoi];
                    break;
                // 避免重复添加用户定位点
                case POI_TYPE_CURRENT_LOCATION:
                    currentLocationPOI = poi;
//                    [self removePoiPoint:tempPoi];
                    return;
//                    break;
                // 避免重复添加 家 POI点
                case POI_TYPE_Home:
                // 避免重复添加 公司 POI点
                case POI_TYPE_Company:
                // 避免重复添加 LBS POI点
                case POI_TYPE_LBS:
                case POI_TYPE_GeoCenter_ON:
                case POI_TYPE_GeoCenter_OFF:
                case POI_TYPE_MIRROR:
                    [self removePoiPoint:tempPoi];
                    break;
                default:
                    break;
            }
        }
    }
    //    }
    BaseAnnotation *annotation = [[BaseAnnotation alloc] initWithLocation:CLLocationCoordinate2DMake(poi.latitude.doubleValue, poi.longitude.doubleValue)];
    annotation.annotationType = poi.sosPoiType;
    annotation.name = poi.name;
    poi.annotion = annotation;
    [poiPointsArray addObject:poi];
    [annotationsArray addObject:annotation];
    [self addAnnotation:annotation];
}

- (void)addPoiPoints:(NSArray *)pois    {
    for (SOSPOI *poi in pois) {
        [self addPoiPoint:poi];
    }
}

- (void)removePoiPoint:(SOSPOI *)poi    {
    BaseAnnotation *annotation;
    if (poi.annotion) {
        annotation = poi.annotion;
    }   else    {
        annotation = [[BaseAnnotation alloc] initWithLocation:CLLocationCoordinate2DMake(poi.latitude.doubleValue, poi.longitude.doubleValue)];
        annotation.annotationType = poi.sosPoiType;
        poi.annotion = annotation;
    }
    [poiPointsArray removeObject:poi];
    [annotationsArray removeObject:annotation];
    [self removeAnnotation:annotation];
}

- (void)removePoiPoints:(NSArray *)pois     {
    for (int i = 0; i < pois.count; i++) {
        SOSPOI *poi = pois[i];
        [self removePoiPoint:poi];
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation   {
    SOSPOI *tempPOI = [self annotationToPOIPoint:(BaseAnnotation *)annotation];
    UIImage *annotationImg = [UIImage imageNamed:tempPOI.annotationImgName];
    
    if (self.isGroupTripMode) {
        if (tempPOI.annotationImg)         annotationImg = tempPOI.annotationImg;
        SOSGroupTripAnnotionView *annoView = (SOSGroupTripAnnotionView *)[self dequeueReusableAnnotationViewWithIdentifier:@"GroupTripLocationReuseIndetifier"];
        if (annoView == nil) {
            annoView = [[SOSGroupTripAnnotionView alloc] initWithAnnotation:annotation reuseIdentifier:Annotion_Commen_Resue_ID];
        }
        if ([annotation isKindOfClass:[MAUserLocation class]])		{
            annoView.image = self.locationAvatarImg;
            self.userLocationAnnotationView = annoView;
            annoView.memberStatus = self.userLocationMemberStatus;
            annoView.memberID = self.userLocationTeamID;
        }	else	{
            annoView.image = annotationImg;
            // 此处使用 locationName 标记用户状态
            annoView.memberStatus = tempPOI.locationName.intValue;
            // 此处使用 locationAddress 标记用户ID
            annoView.memberID = tempPOI.locationAddress;
        }
        // 组队出行地图
        CGSize imgSize = annoView.image.size;
        annoView.size = CGSizeMake(imgSize.width / 2, imgSize.height / 2);
        return annoView;
    }
    
    if ([annotation isKindOfClass:[MAUserLocation class]]) {
        static NSString *userLocationID = @"userLocationStyleReuseIndetifier";
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:userLocationID];
        if (!annotationView)     annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:userLocationID];
        annotationView.image = [UIImage imageNamed:@"Trip_User_Location_POI_Annotion_Img"];
        self.userLocationAnnotationView = annotationView;
        return annotationView;
    }
    if (![annotation isKindOfClass:[BaseAnnotation class]]) 	 return nil;
    
    BaseAnnotation *anno = (BaseAnnotation *)annotation;
    if (tempPOI.annotationImg) 		annotationImg = tempPOI.annotationImg;
    
    if (self.isLBSGeofenceMapMode) {
        //LBS 电子围栏
        MAAnnotationView *view = [[MAAnnotationView alloc] initWithAnnotation:anno reuseIdentifier:Annotion_Commen_Resue_ID];
        view.image = annotationImg;
        return view;
    }
    
    // 电子围栏
    if (anno.annotationType == POI_TYPE_GeoCenter_ON || anno.annotationType == POI_TYPE_GeoCenter_OFF) {
        // 车辆/LBS 电子围栏
        if ([annotation isKindOfClass:[MAPointAnnotation class]])   {
            static NSString *customReuseIndetifier = @"customReuseIndetifier";
            
            CustomGeoAnnotationView *annotationView = (CustomGeoAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:customReuseIndetifier];
            
            if (annotationView == nil)  {
                annotationView = [[CustomGeoAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:customReuseIndetifier];
                
                annotationView.canShowCallout = NO;
                annotationView.draggable = YES;
                annotationView.selected = YES;
            }
            annotationView.calloutView.laLb.text = @"围栏中心";
            annotationView.calloutView.lonLb.text = tempPOI.name;
            annotationView.portrait = annotationImg;
            return annotationView;
        }
    }
    
    /// 点击后是否应该显示气泡
    BOOL shouldShowCalloutView = self.isLBSMapMode || self.isGPSEndMapMode;
    switch (anno.annotationType) {
        case POI_TYPE_CURRENT_LOCATION:
            return [[MAAnnotationView alloc] initWithFrame:CGRectZero];
        // 车辆定位
        case POI_TYPE_VEHICLE_LOCATION:
            shouldShowCalloutView = YES;
            break;
        // LBS设备定位点
        case POI_TYPE_LBS:
        // 足迹概览
        case POI_TYPE_FootPrint_OverView:
        // 足迹详情
        case POI_TYPE_FootPrint_Detail:
            shouldShowCalloutView = YES;
            break;
        default:
            break;
    }
    
    // 应该在点击后显示气泡,返回自定义 Base Annotation View
    if (shouldShowCalloutView) {
        BaseAnnotationView *view = [[BaseAnnotationView alloc] initWithAnnotation:anno reuseIdentifier:Annotion_Commen_Resue_ID];
        view.isLBSMapMode = self.isLBSMapMode||self.isGPSEndMapMode;
        view.type = anno.annotationType;
        view.image = annotationImg;
        // 足迹详情
        if ((anno.annotationType == POI_TYPE_FootPrint_Detail))	{
            view.name = tempPOI.name;
            view.cityCount = tempPOI.cityCount;
        // 足迹概览
        }   else if (anno.annotationType == POI_TYPE_FootPrint_OverView)    {
            view.name = tempPOI.city;
            view.cityCount = tempPOI.cityCount;
            // 若当前城市为 用户足迹点最多的城市,或只有一个城市,显示大气泡
            // 大气泡上显示城市名以及足迹点个数
            if (tempPOI.shouldShowBigAnnotation) {
                view.frame = CGRectMake(0, 0, 100, 100);
                [view configView:tempPOI.city footInfoCount:[tempPOI.cityCount integerValue]];
            // 只显示小气泡
            }   else    {
                view.frame = CGRectMake(0, 0, 50, 50);
            }
        }
        
        // LBS 地图模式,显示 POI 经纬度
        if (self.isLBSMapMode && anno.annotationType) {
            view.name = [NSString stringWithFormat:@"经度 : %.6f\n 纬度 : %.6f", anno.longitude, anno.latitude];
            tempPOI.annotionView = view;
        }
        
        if (self.isGPSEndMapMode && anno.annotationType) {
            view.name = anno.name;
            tempPOI.annotionView = view;
        }
        return view;
    }   else    {
    //不需要显示气泡,返回默认 MA Annotation View
        MAAnnotationView *view = [[MAAnnotationView alloc] initWithAnnotation:anno reuseIdentifier:Annotion_Commen_Resue_ID];
        view.image = annotationImg;
                
        return view;
    }
}

- (void)showCachedPoiPoints     {
    if (!annotationsArray.count)    return;
    [self showAnnotations:annotationsArray animated:YES];
}

- (void)showPoiPoints:(NSArray *)poiPoints animated:(BOOL)animated NeedResetMap:(BOOL)needResetMap	{
    if (!poiPoints.count) {
        return;
    }
    if (poiPoints.count == 1) {
        [self setZoomLevel:19 animated:NO];
    }
    NSMutableArray *tempAnnotationArray = [NSMutableArray array];
    for (SOSPOI *poi in poiPoints) {
        if (poi.annotion)   [tempAnnotationArray addObject:poi.annotion];
    }
    if (tempAnnotationArray.count) {
        [self showAnnotations:tempAnnotationArray animated:animated NeedResetMap:needResetMap];
    }
}

- (void)showPoiPoints:(NSArray *)poiPoints      {
    [self showPoiPoints:poiPoints animated:YES];
}

- (void)showPoiPoints:(NSArray *)poiPoints animated:(BOOL)animated        {
    [self showPoiPoints:poiPoints animated:animated NeedResetMap:NO];
}

- (void)showAnnotations:(NSArray *)annotations animated:(BOOL)animated      {
    [self showAnnotations:annotations animated:animated NeedResetMap:NO];
}

- (void)showAnnotations:(NSArray *)annotations animated:(BOOL)animated NeedResetMap:(BOOL)needResetMap          {
    if (needResetMap == NO) 	{
        [super showAnnotations:annotations animated:animated];
        return;
    }

 if (!annotations.count)        return;
    NSMutableArray *locationArray = [NSMutableArray array];
    for (BaseAnnotation *annotation in annotations) {
        [locationArray addObject:annotation.location];
    }
    [self setMapRectWithCoordinates:locationArray animated:animated];
}


- (void)setMapRectWithCoordinates:(NSArray*)multiCoor animated:(BOOL)animated     {
    CLLocationDegrees center_longitude = 116.2400, center_latitude = 39.5548, span_longitude = DefaultSpan, span_latitude = DefaultSpan;
    double flag = 0, max_x = 0, max_y = 0, min_x = 10000, min_y = 10000;
    BOOL goout = NO;
    for (CLLocation *location in multiCoor) {
        double poiX = location.coordinate.longitude, poiY = location.coordinate.latitude;
        center_longitude = poiX;
        center_latitude = poiY;
        // 我国位于北纬4°至北纬53°31′,东经73°40′至东经135°5′之间
        if (poiX > 135 || poiX < 73.4 ||
            poiY > 53.31 || poiY < 4) {
            goout = YES;
        }
        max_x = MAX(max_x, poiX);
        max_y = MAX(max_y, poiY);
        min_x = MIN(min_x, poiX);
        min_y = MIN(min_y, poiY);
    }
    // 用来判断是不是同一个点
    if (multiCoor.count > 1) {
        flag = (max_x - min_x) + (max_y - min_y);
        span_longitude = (flag == 0? DefaultSpan : (max_x - min_x) * SpanOffsetRatio);
        span_latitude = (flag == 0? DefaultSpan : (max_y - min_y) * SpanOffsetRatio);
        
        double centerOffset = 1.0- (span_latitude * CenterRatio);
        center_longitude = (flag == 0? max_x : (max_x + min_x)/2);
        center_latitude = (flag == 0? max_y : (max_y + min_y)/2* centerOffset);
        
        // 有的时候领导会拿中国的高德地图去北美测试车辆定位，这个时候就无法使两个点同时显示在一个屏幕里
        if (goout) {
            span_longitude = 500;
            span_latitude = 50;
        }
    } else {
        if (goout) {
            span_longitude = 100;
            span_latitude = 50;
        }
    }

    [annotationsArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(BaseAnnotation *annotation, NSUInteger idx, BOOL *stop) {
        if (annotation.annotationType == POI_TYPE_FootPrint_OverView) {
            MACoordinateSpan span = MACoordinateSpanMake(span_latitude, span_longitude);
            CLLocationCoordinate2D center = CLLocationCoordinate2DMake(center_latitude, center_longitude);
            MACoordinateRegion region = MACoordinateRegionMake(center, span);
            [self setRegion:region animated:animated];
            float zoom = self.zoomLevel;
            self.zoomLevel = zoom - 1.0;
            if (annotationsArray.count == 1) {
                self.zoomLevel = 5;
            }
            *stop = YES;
            return ;
        }
        MACoordinateSpan span = MACoordinateSpanMake(span_latitude, span_longitude);
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake(center_latitude, center_longitude);
        MACoordinateRegion region = MACoordinateRegionMake(center, span);
        [self setRegion:region animated:animated];
        *stop = YES;
    }];
}

- (void)showPolylines:(NSArray *)polylins   {
    [self showOverlays:polylins animated:NO];
}

///添加路线对应的图层
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay     {
    if ([overlay isKindOfClass:[MAPolyline class]]) {
        MAPolylineRenderer *polyLineRender = [[MAPolylineRenderer alloc] initWithPolyline:(MAPolyline *)overlay];
        polyLineRender.lineWidth = 12;
        if ([overlay isKindOfClass:[SOSPolyline class]]) {
            // 路线规划图层
            UIColor *color = ((SOSPolyline *)overlay).isSelected ? [UIColor colorWithHexString:@"5EB63C"] : [UIColor colorWithHexString:@"CFCFCF"];
            polyLineRender.fillColor = color;
            polyLineRender.strokeColor = color;
        }	else	{
            polyLineRender.strokeColor = [UIColor colorWithHexString:@"7ED321"];
            polyLineRender.fillColor = [UIColor colorWithHexString:@"7ED321"];
        }
        /// 3D map 支持
//        [polyLineRender loadStrokeTextureImage:[UIImage imageNamed:@"arrowTexture"]];
        return polyLineRender;
    }
    if ([overlay isKindOfClass:[SOSCircle class]])   {
        SOSCircle *circle = (SOSCircle *)overlay;
        MACircleRenderer *circleRenderer = [[MACircleRenderer alloc] initWithCircle:circle];
        circleRenderer.lineWidth   = 1.5f;
        if (circle.isOpen) {
            circleRenderer.strokeColor = [UIColor colorWithHexString:@"6896ED"];
            circleRenderer.fillColor   = [UIColor colorWithRed:104/255.0 green:150/255.0 blue:237/255.0 alpha:0.1];
        }    else    {
            circleRenderer.strokeColor = [UIColor clearColor];
            circleRenderer.fillColor   = [UIColor colorWithWhite:0 alpha:.05];
        }
        return circleRenderer;
    }
    
    if ([overlay isKindOfClass:[MACircle class]])   {
        MACircleRenderer *circleRenderer = [[MACircleRenderer alloc] initWithCircle:(MACircle *)overlay];
        circleRenderer.lineWidth   = 1.5f;
        circleRenderer.strokeColor = [UIColor colorWithRGB:0x107FE0];
        circleRenderer.fillColor   = [UIColor colorWithRGB:0xD0E2F2 alpha:0.3];
        return circleRenderer;
    }
    return nil;
}

- (SOSPOI *)annotationToPOIPoint:(BaseAnnotation *)annotation   {
    NSInteger index = [annotationsArray indexOfObject:annotation];
    if (poiPointsArray.count <= index)   return [SOSPOI new];
    return poiPointsArray[index];
}

- (NSArray *)getVisiableFootPrintPOIPointsArrayByType:(POIType)type    {
    NSSet *set = [self annotationsInMapRect:self.visibleMapRect];
    NSMutableArray *tempArray = [NSMutableArray array];
    for (BaseAnnotation *annotation in set.allObjects) {
        if (annotation.annotationType == type) {
            [tempArray addObject:[self annotationToPOIPoint:annotation]];
        }
    }
    return tempArray;
}

- (NSArray *)getVisiableFootPrintPOIPointsArray    {
    NSSet *set = [self annotationsInMapRect:self.visibleMapRect];
    NSMutableArray *tempArray = [NSMutableArray array];
    for (BaseAnnotation *annotation in set.allObjects) {
        if (annotation.annotationType == POI_TYPE_FootPrint_OverView || annotation.annotationType == POI_TYPE_FootPrint_Detail) {
            [tempArray addObject:[self annotationToPOIPoint:annotation]];
        }
    }
    return tempArray;
}

- (NSArray *)getVisiableFootPrintAnnotationArray   {
    NSSet *set = [self annotationsInMapRect:self.visibleMapRect];
    NSMutableArray *tempArray = [NSMutableArray array];
    for (BaseAnnotation *annotation in set.allObjects) {
        if (annotation.annotationType == POI_TYPE_FootPrint_OverView || annotation.annotationType == POI_TYPE_FootPrint_Detail) {
            [tempArray addObject:annotation];
        }
    }
    return tempArray;
}

#pragma mark - MapView Delegate
- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views		{
    MAAnnotationView *view = views[0];
    if ([view.annotation isKindOfClass:[MAUserLocation class]])	{
        MAUserLocationRepresentation *representation = [[MAUserLocationRepresentation alloc] init];
        representation.showsAccuracyRing = NO;
        representation.showsHeadingIndicator = NO;
        [self updateUserLocationRepresentation:representation];
    }
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation   {
    // 组队出行地图页面 不需要旋转
    if (!updatingLocation && self.userLocationAnnotationView != nil && self.isGroupTripMode == NO) {
        [UIView animateWithDuration:0.1 animations:^{
            double degree = userLocation.heading.trueHeading - self.rotationDegree;
            self.userLocationAnnotationView.transform = CGAffineTransformMakeRotation(degree * M_PI / 180.f );
        }];
    }
    // 进一步获取我的位置详细信息
    if (userLocation.location.coordinate.latitude && userLocation.location.coordinate.longitude)  {
        SOSPOI *userPoi = [CustomerInfo sharedInstance].currentPositionPoi;
        userPoi = userPoi ? userPoi : [SOSPOI new];
        userPoi.sosPoiType = POI_TYPE_CURRENT_LOCATION;
        userPoi.x = @(userLocation.location.coordinate.longitude).stringValue;
        userPoi.y = @(userLocation.location.coordinate.latitude).stringValue;
        
        if ((currentLocationPOI.x.floatValue == userPoi.x.floatValue && currentLocationPOI.y.floatValue == userPoi.y.floatValue)
            && self.shouldUpdateMapCenter == NO)	{
            return;
        }
//        [Util toastWithMessage:@"Updating UserLocation"];
        if (self.isGroupTripMode == NO) 	[self addPoiPoint:userPoi];
        //生成当前定位 POI 点,并记录其经纬度
        currentLocationPOI = userPoi;
        if (self.shouldUpdateMapCenter) {
            [searchOBJ reGeoCodeSearchWithLocation:[AMapGeoPoint locationWithLatitude:userLocation.location.coordinate.latitude longitude:userLocation.location.coordinate.longitude]];
        }
    }
}

- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error	{
    if (!self.annotationDelegate || ![self.annotationDelegate respondsToSelector:@selector(mapDidRefreshUserLocation:Success:)])      return;
    [self.annotationDelegate mapDidRefreshUserLocation:nil Success:NO];
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view   {
    if (!self.annotationDelegate  || ![self.annotationDelegate respondsToSelector:@selector(mapDidSelectedPoiPoint:)])      return;
    [self.annotationDelegate mapDidSelectedPoiPoint:[self annotationToPOIPoint:(BaseAnnotation *)view.annotation]];
    
    if ([view isKindOfClass:[BaseAnnotationView class]]) {
        [((BaseAnnotationView *)view).calloutView.rightButton addTarget:self.annotationDelegate action:@selector(userDidSelectCalloutViewRightButton) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)mapView:(MAMapView *)mapView mapWillMoveByUser:(BOOL)wasUserAction		{
    if (!self.annotationDelegate || ![self.annotationDelegate respondsToSelector:@selector(mapWillMoveByUser:)])      return;
    [self.annotationDelegate mapWillMoveByUser:wasUserAction];
}

- (void)mapView:(MAMapView *)mapView mapWillZoomByUser:(BOOL)wasUserAction		{
    if (!self.annotationDelegate || ![self.annotationDelegate respondsToSelector:@selector(mapWillZoomByUser:)])      return;
    [self.annotationDelegate mapWillZoomByUser:wasUserAction];
}

- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction   {
    if (!self.annotationDelegate || ![self.annotationDelegate respondsToSelector:@selector(mapDidMoveByUser:)])      return;
    [self.annotationDelegate mapDidMoveByUser:wasUserAction];
}

- (void)mapView:(MAMapView *)mapView mapDidZoomByUser:(BOOL)wasUserAction   {
    if (!self.annotationDelegate || ![self.annotationDelegate respondsToSelector:@selector(mapDidZoomByUser:)])      return;
    [self.annotationDelegate mapDidZoomByUser:wasUserAction];
}

- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate     {
    if (!self.annotationDelegate || ![self.annotationDelegate respondsToSelector:@selector(mapDidSingleTappedAtCoordinate:)])      return;
    [self.annotationDelegate mapDidSingleTappedAtCoordinate:coordinate];
}

- (void)mapView:(MAMapView *)mapView didLongPressedAtCoordinate:(CLLocationCoordinate2D)coordinate      {
    if (!self.annotationDelegate || ![self.annotationDelegate respondsToSelector:@selector(mapDidLongPressedAtCoordinate:)])      return;
    [self.annotationDelegate mapDidLongPressedAtCoordinate:coordinate];
}

- (void)mapView:(MAMapView *)mapView regionWillChangeAnimated:(BOOL)animated		{
    if (!self.annotationDelegate || ![self.annotationDelegate respondsToSelector:@selector(mapRegionWillChange)])      return;
    [self.annotationDelegate mapRegionWillChange];
}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated			{
    if (!self.annotationDelegate || ![self.annotationDelegate respondsToSelector:@selector(mapRegionDidChanged)])      return;
    [self.annotationDelegate mapRegionDidChanged];
}

- (void)mapViewRegionChanged:(MAMapView *)mapView	{
    if (!self.annotationDelegate || ![self.annotationDelegate respondsToSelector:@selector(mapRegionChanging)])      return;
    [self.annotationDelegate mapRegionChanging];
}

#pragma mark - SearchDelegate
- (void)reverseGeocodingResults:(NSArray *)results  {
    SOSPOI *resultPOI = results[0];
    SOSPOI *userPoi = currentLocationPOI;
    userPoi.province = resultPOI.province;
    userPoi.cityCode = resultPOI.cityCode;
    userPoi.address = resultPOI.address;
    userPoi.code = resultPOI.code;
    userPoi.city = resultPOI.city;
    userPoi.name = resultPOI.name;//[NSString stringWithFormat:@"我的位置 (%@)", resultPOI.name];
    userPoi.operationDateStrValue = [[NSDate date] stringWithISOFormat];

    [CustomerInfo sharedInstance].currentPositionPoi = userPoi;
//    [self addPoiPoint:userPoi];
    
    // 重置地图中心 & 缩放比
    if (!self.shouldUpdateMapCenter)         return;
    [self setCenterCoordinate:userPoi.getPOICoordinate2D animated:YES];
    [self setZoomLevel:19 animated:YES];
    self.shouldUpdateMapCenter = NO;
    
    if (!self.annotationDelegate || ![self.annotationDelegate respondsToSelector:@selector(mapDidRefreshUserLocation:Success:)])      return;
    [self.annotationDelegate mapDidRefreshUserLocation:userPoi Success:YES];
}

- (void)baseSearch:(id)searchOption Error:(NSString *)errCode	{
    if (!self.annotationDelegate || ![self.annotationDelegate respondsToSelector:@selector(mapDidRefreshUserLocation:Success:)])      return;
    [self.annotationDelegate mapDidRefreshUserLocation:nil Success:NO];
}

@end
