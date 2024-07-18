//
//  BaseSearchOBJ.m
//  Onstar
//
//  Created by Coir on 16/2/25.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "BaseSearchOBJ.h"

@implementation BasePoiSearchConfiguration
@end


@interface BaseSearchOBJ ()     <AMapSearchDelegate>  {
    AMapSearchAPI *aMapSearchOBJ;
}

@property (nullable, nonatomic, strong) SOSPOI *reGeoPOI;

@end

@implementation BaseSearchOBJ

- (instancetype)init    {
    self = [super init];
    if (self) {
        [self configAmapSearchData];
    }
    return self;
}

///初始化检索对象
- (void)configAmapSearchData {
//    [AMapSearchServices sharedServices].apiKey = AMapKey;
    aMapSearchOBJ = [[AMapSearchAPI alloc] init];
    aMapSearchOBJ.delegate = self;
}

#pragma mark - AMapSearch Delegate
#pragma mark -- poi搜索相关
/// POI ID搜索请求
- (void)IDSearchWithID:(NSString *)uid      {
    AMapPOIIDSearchRequest *request = [[AMapPOIIDSearchRequest alloc] init];
    if (self.poiSearchConfig) {
        request.page = _poiSearchConfig.page;
        request.types = _poiSearchConfig.types;
        request.offset = _poiSearchConfig.offset;
        request.sortrule = _poiSearchConfig.sortRule;
    }
    request.uid = uid;
    [aMapSearchOBJ AMapPOIIDSearch:request];
}

/// POI关键字搜索
- (void)keyWordSearchWithKeyWords:(NSString *)keyWords City:(NSString *)city  {
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
    if (self.poiSearchConfig) {
        request.page = _poiSearchConfig.page;
        request.types = _poiSearchConfig.types;
        request.offset = _poiSearchConfig.offset;
        request.sortrule = _poiSearchConfig.sortRule;
    }
    request.keywords = keyWords;
    request.city = city;
    request.cityLimit = NO;//修改:16-12-20,不限定搜索当前城市
    [aMapSearchOBJ AMapPOIKeywordsSearch:request];
}

/// POI周边搜索
- (void)aroundSearchWithKeyWords:(NSString *)keyWords Location:(AMapGeoPoint *)location Radius:(NSInteger)radius    {
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    if (self.poiSearchConfig) {
        request.page = _poiSearchConfig.page;
        request.types = _poiSearchConfig.types;
        request.offset = _poiSearchConfig.offset;
        request.sortrule = _poiSearchConfig.sortRule;
    }
    request.keywords = keyWords;
    request.location = location;
    request.radius = radius;
    [aMapSearchOBJ AMapPOIAroundSearch:request];
}

///POI搜索对应的回调函数
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response      {
    //通过 AMapPOISearchResponse 对象处理搜索结果
    NSMutableArray *sosPOIs = [[NSMutableArray alloc] initWithCapacity:response.pois.count];
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI *poi, NSUInteger idx, BOOL *stop) {
        SOSPOI *sosPoi = [[SOSPOI alloc] init];
        [Util copySamePropertyFromObj1:poi ToObj2:sosPoi];
        sosPoi.pguid = poi.uid;
        if ([poi.tel rangeOfString:@";"].location != NSNotFound)  {
            NSArray *telArray = [poi.tel componentsSeparatedByString:@";"];
            sosPoi.tel = telArray[0];
        }
        if ([request isKindOfClass:[AMapPOIKeywordsSearchRequest class]] || [request isKindOfClass:[AMapPOIAroundSearchRequest class]]) {
            sosPoi.keyWords = ((AMapPOIKeywordsSearchRequest*)request).keywords;
        }
    	
        sosPoi.x = [NSString stringWithFormat:@"%lf", poi.location.longitude];
        sosPoi.y = [NSString stringWithFormat:@"%lf", poi.location.latitude];
        sosPoi.distance = @(poi.distance).stringValue;
        [sosPOIs addObject: sosPoi];
    }];
    SOSPoiSearchResult *sosPoisResult = [[SOSPoiSearchResult alloc] init];
    sosPoisResult.total = response.count;
    sosPoisResult.pois = sosPOIs;
    sosPoisResult.record = sosPOIs.count;
    
    if(response.pois.count == 0)    {
        [Util toastWithMessage:@"很抱歉，未搜索到相关数据。"];
    }
    if (_poiDelegate && [_poiDelegate respondsToSelector:@selector(poiSearchResult:)]) {
        [_poiDelegate poiSearchResult:sosPoisResult];
    }
}

#pragma mark -- 地理编码与地理编码 搜索相关
/// 地理编码请求
- (void)geoCodeSearchWithAddress:(NSString *)address City:(NSString *)city   {
    AMapGeocodeSearchRequest *request = [[AMapGeocodeSearchRequest alloc] init];
    request.address = address;
    request.city = city;
    [aMapSearchOBJ AMapGeocodeSearch:request];
}

///地理编码查询回调函数
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response  {
    
}

/// 逆地理编码请求
- (void)reGeoCodeSearchWithLocation:(AMapGeoPoint *)location   {
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location = location;
    regeo.radius = 500;
    regeo.requireExtension = YES;
    [aMapSearchOBJ AMapReGoecodeSearch:regeo];
}

/// 逆地理编码请求
- (void)reGeoCodeSearchWithPOI:(SOSPOI *)poi   {
    self.reGeoPOI = [poi copy];
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location = [AMapGeoPoint locationWithLatitude:poi.latitude.floatValue longitude:poi.longitude.floatValue];
    regeo.radius = 500;
    regeo.requireExtension = YES;
    [aMapSearchOBJ AMapReGoecodeSearch:regeo];
}

///逆地理编码的回调函数
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response    {
    
    AMapReGeocode *regeoCode = response.regeocode;
    if (regeoCode == nil)	{
        // reverse geocoding fialed
        if (_geoDelegate && [_geoDelegate respondsToSelector:@selector(reverseGeocodingResults:)]) {
            [_geoDelegate reverseGeocodingResults:nil];
        }
        return;
    }
    if (self.reGeoPOI) {
        SOSPOI *resultPOI = nil;
        if (regeoCode.pois.count) {
            for (AMapPOI *aMapPOI in regeoCode.pois) {
                if ([aMapPOI.name isEqualToString:self.reGeoPOI.name]) {
                    self.reGeoPOI.address = aMapPOI.address;
                    self.reGeoPOI.pguid = aMapPOI.uid;
                    resultPOI = [self.reGeoPOI copy];
                    break;
                }
            }
            if (resultPOI == nil) {
                AMapPOI *aMapPOI = regeoCode.pois[0];
                self.reGeoPOI.address = aMapPOI.address;
                self.reGeoPOI.pguid = aMapPOI.uid;
                resultPOI = [self.reGeoPOI copy];
            }
        }
        if (resultPOI == nil) {
            self.reGeoPOI = nil;
            [Util dismissHUD];
            return;
        }
        if (_geoDelegate && [_geoDelegate respondsToSelector:@selector(reverseGeocodingResults:)]) {
            [_geoDelegate reverseGeocodingResults:resultPOI ? @[resultPOI] : @[]];
        }
        self.reGeoPOI = nil;
        return;
    }
    
    AMapAddressComponent *responseAddress = regeoCode.addressComponent;
    SOSPOI *poiPoint = [SOSPOI new];
    poiPoint.province = responseAddress.province;
    poiPoint.cityCode = responseAddress.citycode;
    poiPoint.code = responseAddress.adcode;
    poiPoint.city = responseAddress.city;
    AMapGeoPoint *location = request.location;
    poiPoint.longitude = @(location.longitude).stringValue;
    poiPoint.latitude = @(location.latitude).stringValue;

    NSString *nameStr = [NSString stringWithFormat:@"%@%@", NNil(responseAddress.neighborhood), NNil(responseAddress.building)];
    NSString *poiNameStr = @"";
     NSArray *resultPOIsArray = response.regeocode.pois;
    if (!nameStr.length) {
        NSArray *resultAOIsArray = response.regeocode.aois;
        if (resultPOIsArray.count == 1) {
            poiNameStr = ((AMapPOI *)resultPOIsArray[0]).name;
            poiPoint.pguid = ((AMapPOI *)resultPOIsArray[0]).uid;
        }   else if (resultAOIsArray.count == 1)    {
            poiNameStr = ((AMapAOI *)resultAOIsArray[0]).name;
            poiPoint.pguid = ((AMapAOI *)resultAOIsArray[0]).uid;
        }
    }

    if (nameStr.length) {
        poiPoint.name = nameStr;
    }   else if (poiNameStr.length)     {
        poiPoint.name = poiNameStr;
    }   else    {
        poiPoint.name = [NSString stringWithFormat:@"%@%@", NNil(responseAddress.district), NNil(responseAddress.township)];
    }
    poiPoint.address = response.regeocode.formattedAddress;
//    poiPoint.firstShowAddress = poiPoint.address;
//    if (resultPOIsArray.count >0) {
//        poiPoint.firstShowAddress  = ((AMapPOI *)resultPOIsArray[0]).address;
//    }
    
    NSMutableArray * sosResults = [NSMutableArray array];
    [sosResults addObject:poiPoint];
    
    if (_geoDelegate && [_geoDelegate respondsToSelector:@selector(reverseGeocodingResults:)]) {
        [_geoDelegate reverseGeocodingResults:sosResults];
    }
}

#pragma mark -- 路径规划相关
///路径规划搜索
- (void)routeSearchWithStrategy:(DriveStrategy)strategy Origin:(AMapGeoPoint *)origin Destination:(AMapGeoPoint *)destination     {
    if (strategy == DriveStrategyWalk) {
        //步行路线
        AMapWalkingRouteSearchRequest *request = [[AMapWalkingRouteSearchRequest alloc] init];
        request.origin = origin;
        request.destination = destination;
        request.showFieldsType = AMapWalkingRouteShowFieldTypePolyline;
        [aMapSearchOBJ AMapWalkingRouteSearch:request];
    }	else	{
        //驾车路线
        AMapDrivingCalRouteSearchRequest *request = [[AMapDrivingCalRouteSearchRequest alloc] init];
        request.strategy = strategy;
        request.origin = origin;
        request.destination = destination;
        request.showFieldType = AMapDrivingRouteShowFieldTypePolyline;
        [aMapSearchOBJ AMapDrivingV2RouteSearch:request];
    }
}

///路径规划查询回调
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response    {
    if (response.route == nil)			return;
    
    if (response.route == nil || [response.route.paths count] == 0) {
        [Util showAlertWithTitle:nil message:@"路径生成失败" completeBlock:nil];
        
        if (_routeDelegate && [_routeDelegate respondsToSelector:@selector(routePolylines:RouteInfos:)]) {
            [_routeDelegate routePolylines:nil RouteInfos:nil];
        }
        
        return;
    }
    
    CLLocationCoordinate2D startCoor = CLLocationCoordinate2DMake(response.route.origin.latitude, response.route.origin.longitude);
    CLLocationCoordinate2D endCoor = CLLocationCoordinate2DMake(response.route.destination.latitude, response.route.destination.longitude);
    
    AMapPath *path = response.route.paths.firstObject;
    NSString *pathCoors = [[NSString alloc] init];
    NSMutableArray *routeInfoArray = [[NSMutableArray alloc] init];
    
    //NSArray *overlayArray = [CommonUtility polylinesForPath:path];
    
    NSLog(@"========== Route segment count is [%lu]", (unsigned long)path.steps.count);
//    if (path.steps.count > 300) {
//        [self search:nil Error:nil];
//        return;
//    }
    
    
    for (int i = 0; i < path.steps.count; i++) {
        AMapStep *step = [path.steps objectAtIndex:i];
        pathCoors = [pathCoors stringByAppendingFormat:@"%@%@", step.polyline, (i == path.steps.count - 1) ? @"" : @","];
        SOSRoute *sosRoute = [[SOSRoute alloc] init];
        sosRoute.roadName = step.road;
        sosRoute.textInfo = step.instruction;
        sosRoute.roadLength = [NSString stringWithFormat:@"%ld米", (long)step.distance];
        NSInteger driveMinites = 0;
        if (step.duration > 0) {
            driveMinites = step.duration / 60;
        }
        sosRoute.driveTime = [NSString stringWithFormat:@"%ld分钟", (long)driveMinites];
        sosRoute.direction = step.orientation;
        sosRoute.action = step.action;
        [routeInfoArray addObject:sosRoute];
    }
    SOSMapPath *mapPath = [SOSMapPath mj_objectWithKeyValues:path.mj_keyValues];
    mapPath.steps = routeInfoArray;
    
    NSMutableArray *overlayArray2 = [self getRouteOverlaysWithStart:startCoor End:endCoor coorString:pathCoors];
    
    if (_routeDelegate && [_routeDelegate respondsToSelector:@selector(routePolylines:RouteInfos:)]) {
        [_routeDelegate routePolylines:overlayArray2 RouteInfos:mapPath];
    }
}

/**
  * 把路线结果集里的各个点String 转化成CLLocationCoordinate2D数组 暂时不用
  * Parse coordinate string to CLLocationCoordinate2D structure,
  * The caller must be responsible for releasing the result memmory.
  */
- (CLLocationCoordinate2D *)coordinatesForString:(NSString *)string coordinateCount:(NSUInteger *)coordinateCount parseToken:(NSString *)token     {
    if (string == nil) {
        return NULL;
    }
    if (token == nil) {
        token = @",";
    }
    NSString *str = @"";
    if (![token isEqualToString:@","]) {
        str = [string stringByReplacingOccurrencesOfString:token withString:@","];
    }
    else {
        str = [NSString stringWithString:string];
    }
    NSArray *components = [str componentsSeparatedByString:@","];
    NSUInteger count = [components count] / 2;
    if (coordinateCount != NULL) {
        *coordinateCount = count;
    }
    CLLocationCoordinate2D *coordinates = (CLLocationCoordinate2D*)malloc(count * sizeof(CLLocationCoordinate2D));
    
    for (int i = 0; i < count; i++) {
        coordinates[i].longitude = [[components objectAtIndex:2 * i]     doubleValue];
        coordinates[i].latitude  = [[components objectAtIndex:2 * i + 1] doubleValue];
    }
    
    return coordinates;
}
/**
 * 根据 起点 终点 行驶路段坐标串coors 生成 路线集合
 *@param startCoor 起点
 *@param endCoor 终点
 *@parma coors 行驶路段坐标串 格式(x1,y1,x2,y2,x3,y3....)
 */
- (NSMutableArray *)getRouteOverlaysWithStart:(CLLocationCoordinate2D)startCoor
                                          End:(CLLocationCoordinate2D)endCoor
                                   coorString:(NSString *)coors     {
    NSMutableArray *overlayArray = [[NSMutableArray alloc] init];
    
    NSUInteger pathCoordinateCount = 0;
    CLLocationCoordinate2D *pathCoordinates = [self coordinatesForString:coors coordinateCount:&pathCoordinateCount parseToken:@";"];
    if (pathCoordinates == NULL) {
        NSLog(@"%s: path coordinates is invalid. ", __func__);
        return nil;
    }
    
    MAPolyline *routeLine = [MAPolyline polylineWithCoordinates:pathCoordinates count:pathCoordinateCount];
    [overlayArray addObject:routeLine];
    //add the first and last line
    CLLocationCoordinate2D coords1[2];
    coords1[0] = startCoor;
    coords1[1] = pathCoordinates[0];
    MAPolyline *line1 = [MAPolyline polylineWithCoordinates:coords1 count:2];
    [overlayArray addObject:line1];
    CLLocationCoordinate2D coords2[2];
    coords2[0] = pathCoordinates[pathCoordinateCount - 1];
    coords2[1] = endCoor;
    MAPolyline *line2 = [MAPolyline polylineWithCoordinates:coords2 count:2];
    [overlayArray addObject:line2];
    
    free(pathCoordinates);
    pathCoordinates = NULL;
    
    return overlayArray;
}

#pragma mark -- 公交站与公交线路，天气查询 搜索相关
///公交站查询回调函数
- (void)onBusStopSearchDone:(AMapBusStopSearchRequest *)request response:(AMapBusStopSearchResponse *)response  {
    
}

///公交线路关键字查询回调
- (void)onBusLineSearchDone:(AMapBusLineBaseSearchRequest *)request response:(AMapBusLineSearchResponse *)response  {
    
}

///天气查询回调
- (void)onWeatherSearchDone:(AMapWeatherSearchRequest *)request response:(AMapWeatherSearchResponse *)response  {
    
}

#pragma mark -- 请求发生错误
///当请求发生错误时，会调用代理的此方法.
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error     {
    [self search:request Error:@(error.code).stringValue];
}

- (void)search:(id)searchOption Error:(NSString*)errCode     {
    
    NSString *message ;
    NSLog(@"%s: searchOption = %@, errCode = %@", __func__, [searchOption class], errCode);
    if ([searchOption isKindOfClass:[AMapWalkingRouteSearchRequest class]] && [errCode isEqualToString:@"3003"]) {
        message = @"无法步行到达";
    } else if ([errCode isEqualToString:@"000001"]) {
        message = @"无查询结果";
    } else if ([errCode isEqualToString:@"000001"]){
        message = @"调用服务发生异常";
    } else if ([errCode isEqualToString:@"000002"]){
        message = @"调用服务发生异常";
    } else if ([errCode isEqualToString:@"010001"]){
        message = @"非法坐标格式";
    } else if ([errCode isEqualToString:@"010002"]){
        message = @"字符集编码错误";
    } else if ([errCode isEqualToString:@"010003"]){
        message = @"Apikey为空";
    } else if ([errCode isEqualToString:@"020000"]){
        message = @"产品未授权";
    } else if ([errCode isEqualToString:@"020001"]){
        message = @"Apikey不正确";
    } else if ([errCode isEqualToString:@"020002"]){
        message = @"Api账号不存在";
    } else if ([errCode isEqualToString:@"020003"]){
        message = @"没有服务访问权限";
    }else if ([errCode isEqualToString:@"040001"]){
        message = @"查询服务连接异常";
    }else if ([errCode isEqualToString:@"040002"]){
        message = @"查询服务返回格式解析异常";
    }else if ([errCode isEqualToString:@"050001"]){
        message = @"当前请求数据格式不支持";
    } else if ([errCode isEqualToString:@"020008"]) {
        message = @"020008";
        NSLog(@"failed......");
    } else {
        message = NSLocalizedString(@"SOMP-328", nil);
    }
    if (_errorDelegate && [_errorDelegate respondsToSelector:@selector(baseSearch:Error:)]) {
        [_errorDelegate baseSearch:searchOption Error:message];
        return;
    }
    [Util toastWithMessage:message];
}

@end
