//
//  SOSSearchResult.m
//  Onstar
//
//  Created by Onstar on 13-6-22.
//  Copyright (c) 2013年 Shanghai Onstar. All rights reserved.
//

#import "SOSSearchResult.h"
#import "SOSDateFormatter.h"

/*!
 @brief POI 信息类，继承自NSObject类。用于存储 POI 的相关信息，例如，地址、名称、类型等。
 */
@implementation SOSPOI

- (id)copyWithZone:(NSZone *)zone     {
    SOSPOI * ppoi = [SOSPOI mj_objectWithKeyValues:self.mj_keyValues];
    return ppoi;
}

- (NSString *)city     {
    if ([_city length] == 0 || [_city caseInsensitiveCompare:@"(Null)"] == NSOrderedSame) {
        return _province;
    } else
        return _city;
}

- (NSString *)keyWords	{
    return _keyWords.length ? _keyWords : self.name;
}

- (NSString *)name  {
    return _name.length ? _name : @" ";
}

- (NSString *)formatDistance	{
    long long l = _distance.longLongValue;
    if (l > 1000) {
        return [NSString stringWithFormat:@"%.1f", @(l / 1000.0).floatValue];
    }   else    {
        return @(l).stringValue;
    }
}

- (NSString *)distanceUnit 		{
    long long length = _distance.longLongValue;
    if (length > 1000) {
        return @"公里";
    }   else    {
        return @"米";
    }
}

- (NSString *)distanceWithUnit	{
    long long length = _distance.longLongValue;
    if (length > 1000) {
        return [NSString stringWithFormat:@"%.1f公里", @(length / 1000.0).floatValue];
    }   else    {
        return [_distance stringByAppendingString:@"米"];
    }
}

- (NSString *)tel	{
    if (_tel && [_tel isKindOfClass:[NSString class]] && ![_tel containsString:@"null"]) {
        if ([_tel containsString:@";"]) {
            NSArray *strArr = [_tel componentsSeparatedByString:@";"];
            if (strArr.count) {
                return strArr[0];
            }
        }
        return _tel;
    }
    return nil;
}

- (NSString *)annotationImgName     {    
    NSString *imgName;
    switch (self.sosPoiType) {
        case POI_TYPE_POI:
        case POI_TYPE_Home:
        case POI_TYPE_Dealer:
        case POI_TYPE_Company:
        case POI_TYPE_ROUTE_END:
        case POI_TYPE_OilStation:
        case POI_TYPE_ChargeStation:
            imgName = @"Trip_POI_Icon";
            break;
        case POI_TYPE_List_POI:
            imgName = @"Trip_POI_List_Icon";
            break;
        case POI_TYPE_CURRENT_LOCATION:
            imgName = @"Trip_User_Location_POI_Annotion_Img";
            break;
        case POI_TYPE_VEHICLE_LOCATION:
            imgName = @"Trip_Vehicle_Location_POI_Annotion_Img";
            if (SOS_CD_PRODUCT) {
             imgName = [imgName stringByAppendingString:@"_sdkcd"];
            }
            break;
        case POI_TYPE_ROUTE_BEGIN:
            imgName = @"Navigate_Route_Begin";
            break;
        case POI_TYPE_FootPrint_OverView:
            imgName = @"icon_large_trip_history";
            break;
        case POI_TYPE_FootPrint_Detail:
            imgName = @"Navigate_Icon_Poi";
            break;
        case POI_TYPE_GeoCenter_ON:
            imgName = @"icon_Geo_Center";
            break;
        case POI_TYPE_GeoCenter_OFF:
            imgName = @"icon_Geo_Center_Gray";
            break;
        case POI_TYPE_LBS:
            imgName = @"icon_LBS_location";
            break;
        case POI_TYPE_LBS_History:
            imgName = @"LBS_icon_travel_map_lbs_tracking_shadow_energy_green_idle_25x25";
            break;
        case POI_TYPE_MIRROR:
            imgName = @"LBS_icon_car_location_shadow_enegy_green_idle_50x50";
            break;
        default:
            imgName = @"Trip_POI_Icon";
            break;
    }
    return imgName;
}

- (NSString *)longitude {
    return self.x;
}

- (void)setLongitude:(NSString *)longitude  {
    _x = longitude;
}

- (NSString *)latitude  {
    return self.y;
}

- (void)setLatitude:(NSString *)latitude    {
    _y = latitude;
}


- (NSDictionary *)toDictionary  {
    NSMutableDictionary *dic = [super mj_keyValues];
//    [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    dic[@"annotion"] = nil;
    dic[@"annotionView"] = nil;
    return dic;
}

+ (NSArray *)mj_ignoredPropertyNames	{
    return @[@"annotion", @"annotionView", @"shouldShowBigAnnotation", @"gapTime", @"isValidLocation", @"LBSMapUpdateTime", @"annotationImg"];
}

- (NSString *)mj_JSONString		{
    return self.mj_keyValues.mj_JSONString;
}

- (NSString *)gapTime	{
    if (!self.operationDateStrValue.length)	return nil;
    else	{
        NSDate *operationDate = [NSDate dateWithISOFormatString:self.operationDateStrValue];
        NSTimeInterval timeInterval = -[operationDate timeIntervalSinceNow];
        if (timeInterval < 120)         return @"刚刚更新";
        else							return [SOSDateFormatter gapTimeStrFromNowWithDate:operationDate];
    }
}

- (BOOL)isValidLocation		{
    
    if (!self.operationDateStrValue.length)    return NO;
    NSTimeInterval timeInterval = -[[NSDate dateWithISOFormatString:self.operationDateStrValue] timeIntervalSinceNow];
    if (timeInterval < (3600 * 24))         return YES;
    return NO;
}

- (BOOL)isEqualToPOI:(SOSPOI *)poi  {
    return [self.name isEqualToString:poi.name] && [self.latitude isEqualToString:poi.latitude] && [self.longitude isEqualToString:poi.longitude];
}

- (CLLocationCoordinate2D)getPOICoordinate2D	{
    return CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue);
}

@end



@implementation SOSLBSPOI

@end



@implementation FootPrintPOI

- (NSNumber *)lastDestLatitude  {
    if (_lastDestLatitude)  return _lastDestLatitude;
    else                    return _destLatitude;
}

- (NSNumber *)lastDestLongitude     {
    if (_lastDestLongitude)     return _lastDestLongitude;
    else                        return _destLongitude;
}

- (SOSPOI *)toPOIPoint  {
    SOSPOI *poi = [SOSPOI new];
    poi.name = self.destStreetName;
    poi.ftID = self.seqId;
    poi.city = self.destCity;
    poi.province = self.destState;
    poi.cityCount = self.cityCount;
    poi.latitude = self.lastDestLatitude.stringValue;
    poi.longitude = self.lastDestLongitude.stringValue;
    poi.sosPoiType = POI_TYPE_FootPrint_OverView;
    return poi;
}

@end

/*!
 @brief POI 查询结果类，继承自NSObject类。用于存储 POI 的查询结果，例如，查询到的 POI 记录数等。
 */
@implementation SOSPoiSearchResult : NSObject
@end

/*!
 @brief 网络导航信息类，继承自NSObject类。
 */
@implementation SOSRoute : NSObject
@end


@implementation SOSMapPath :NSObject
@end

/*!
 @brief 途经城市信息类，继承自NSObject类。用于描述途经城市的信息。
 */
@implementation SOSRouteCity : NSObject
@end

/*!
 @brief 网络导航查询结果类，继承自NSObject类。用于存储网络导航查询的结果信息。
 */
@implementation SOSRouteSearchResult : NSObject
@end

/*!
 @brief 距离查询结果类，继承自NSObject类。用于存储距离查询的结果信息。
 */
@implementation SOSDistanceSearchResult : NSObject
@end




/*!
 @brief 偏移查询结果类，继承自NSObject类。
 */
@implementation SOSRGCItem : NSObject
@end

/*!
 @brief 偏移查询结果数组类，继承自NSObject类。
 */

@implementation SOSRGCSearchResult : NSObject
@end

/*!
 @brief 地理兴趣点信息类，继承自NSObject类。
 */
@implementation SOSGeoPOI : NSObject
@end

/*!
 @brief 地理编码查询结果类，继承自NSObject类。
 */
@implementation SOSGeoCodingSearchResult : NSObject
@end

/*!
 @brief 省信息类，继承自NSObject类。
 */
@implementation SOSProvince : NSObject
@end

/*!
 @brief 城市信息类，继承自NSObject类。
 */
@implementation SOSCity : NSObject
@end

/*!
 @brief 区域信息类，继承自NSObject类。
 */
@implementation SOSDistrict : NSObject
@end

/*!
 @brief 道路信息类，继承自NSObject类。
 */
@implementation SOSRoad : NSObject
@end

/*!
 @brief 道路交叉口信息类，继承自NSObject类。
 */
@implementation SOSCross : NSObject
@end


/*!
 @brief 城市信息类，继承自NSObject类。
 */
@implementation SOSCityGeocodingInfo
@end
