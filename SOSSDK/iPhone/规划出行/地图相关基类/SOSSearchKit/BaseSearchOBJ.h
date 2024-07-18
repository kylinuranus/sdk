//
//  BaseSearchOBJ.h
//  Onstar
//
//  Created by Coir on 16/2/25.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "SOSSearchResult.h"
#import <Foundation/Foundation.h>
#import "SOSMapHeader.h"

@protocol PoiDelegate  <NSObject>
@optional
- (void)poiSearchResult:(SOSPoiSearchResult *)results;
@end

@protocol GeoDelegate <NSObject>
@optional
- (void)geocodingResults:(SOSGeoCodingSearchResult *)result;
- (void)reverseGeocodingResults:(NSArray *)results;
@end

@protocol RouteDelegate <NSObject>
@optional
- (void)routePolylines:(NSArray *)polylines RouteInfos:(SOSMapPath *)routes;
@end

@protocol ErrorDelegate <NSObject>
@optional
- (void)baseSearch:(id)searchOption Error:(NSString*)errCode;
@end

@interface BasePoiSearchConfiguration : NSObject

///类型，多个类型用“|”分割 可选值:文本分类、分类代码
@property (nonatomic, copy)   NSString  *types;

///排序规则, 0-距离排序；1-综合排序, 默认1
@property (nonatomic, assign) NSInteger  sortRule;

///每页记录数, 范围1-50, [default = 20]
@property (nonatomic, assign) NSInteger  offset;

///当前页数, 范围1-100, [default = 1]
@property (nonatomic, assign) NSInteger  page;

///是否返回扩展信息，默认为 NO。
@property (nonatomic, assign) BOOL requireExtension;

///是否返回扩展 POI ，默认为 NO。
@property (nonatomic, assign) BOOL requireSubPOIs;

@end


///特别要注意对象的作用域问题，作为临时变量时，可能因为变量被销毁而导致不走回调方法
@interface BaseSearchOBJ : NSObject

///poi搜索配置项
@property (nonatomic, strong) BasePoiSearchConfiguration *poiSearchConfig;

@property (nonatomic, assign) BOOL needNoticeError;

///POI搜索代理
@property (nonatomic, weak) id<PoiDelegate> poiDelegate;

///地理编码与逆地理编码规划代理
@property (nonatomic, weak) id<GeoDelegate> geoDelegate;

///路径规划代理
@property (nonatomic, weak) id<RouteDelegate> routeDelegate;

///错误回调代理
@property (nonatomic, weak) id<ErrorDelegate> errorDelegate;

/// POI ID搜索请求
- (void)IDSearchWithID:(NSString *)uid;

/// POI关键字搜索
- (void)keyWordSearchWithKeyWords:(NSString *)keyWords City:(NSString *)city;

/// POI周边搜索
- (void)aroundSearchWithKeyWords:(NSString *)keyWords Location:(AMapGeoPoint *)location Radius:(NSInteger)radius;

/// 地理编码请求
- (void)geoCodeSearchWithAddress:(NSString *)address City:(NSString *)city;

/// 逆地理编码请求
- (void)reGeoCodeSearchWithLocation:(AMapGeoPoint *)location;
/// 逆地理编码请求
- (void)reGeoCodeSearchWithPOI:(SOSPOI *)poi;

///驾车路径规划
- (void)routeSearchWithStrategy:(DriveStrategy)strategy Origin:(AMapGeoPoint *)origin Destination:(AMapGeoPoint *)destination;


@end
