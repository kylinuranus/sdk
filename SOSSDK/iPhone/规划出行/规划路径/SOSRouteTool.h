//
//  SOSRouteTool.h
//  Onstar
//
//  Created by Coir on 31/01/2018.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

///路径搜索结果
typedef enum {
    ///步行规划-太近
    SOSRouteSearchResultType_Walk_Near = 1,
    ///步行规划-正常
    SOSRouteSearchResultType_Walk_Normal,
    ///步行规划-太远
    SOSRouteSearchResultType_Walk_Far,
    ///驾车规划-正常
    SOSRouteSearchResultType_Drive_Normal
} 	SOSRouteSearchResultType;

@interface SOSRouteInfo : NSObject

@property (nonatomic, assign) DriveStrategy strategy;
/// 路程长度 (单位: 米)
@property (nonatomic, assign) NSInteger routeLength;
/// 预计耗时（单位：分钟）
@property (nonatomic, assign) NSInteger routeTime;

+ (instancetype)initWithLength:(NSInteger)length Time:(NSInteger)time;

@end

@interface SOSRouteTool : NSObject

/// 修改规划路线起终点完毕
+ (void)changeRoutePOIDoneFromVC:(UIViewController *)fromVC WithType:(SelectPointOperation)type ResultPOI:(SOSPOI *)poi;

+ (SOSRouteInfo *)getRouteInfoWithRoutes:(SOSMapPath *)mapPath;

- (void)handleWalkingRouteError:(NSString *)errCode;

/// 搜索路径
- (void)searchWithBeginPOI:(SOSPOI *)beginPOI AndDestinationPoi:(SOSPOI *)destinationPoi WithStrategy:(DriveStrategy)strategy Success:(void(^)(SOSRouteSearchResultType resultType, SOSRouteInfo *routeInfo, NSArray *polylines, NSArray *routes))success failure:(void(^)(NSString *errorCode))failure;

/// 添加参数 是否需要弹框 needAlert
- (void)searchWithBeginPOI:(SOSPOI *)beginPOI AndDestinationPoi:(SOSPOI *)destinationPoi WithStrategy:(DriveStrategy)strategy NeedAlertError:(BOOL)needAlert Success:(void(^)(SOSRouteSearchResultType resultType, SOSRouteInfo *routeInfo, NSArray *polylines, NSArray *routes))success failure:(void (^)(NSString *))failure;

@end
