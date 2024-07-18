//
//  SOSOilDataTool.h
//  Onstar
//
//  Created by Coir on 2019/8/21.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSOilDataTool : NSObject


/**  获取根据经纬度查询 50KM 内 优惠加油 加油站信息
 * gasType        String    油站类型（1 中石油，2 中石化，3 壳牌，4 其他）
 * oilName         String    油号（90#、92#、95#、98#、101#）默认92#
 * sortColumn    String    distance（距离）,price(优惠加油价格)默认距离排序
 */
+ (void)requestOilStationListWithCenterPOI:(SOSPOI*)centerPOI GasType:(nullable NSString *)gasType OilName:(nullable NSString *)oilName AndSortColumn:(nullable NSString *)sortColumn Success:(void (^)(NSArray <SOSOilStation *>* stationList))success Failure:(void (^)(void))failure;

/// 获取油号列表
+ (void)requestOilInfoListSuccess:(void (^)(NSArray <SOSOilInfoObj *>* oilInfoList))success Failure:(void (^)(void))failure;

/// 获取指定油枪的可用油号列表
+ (void)requestOilGunNumListWithStationId:(NSString *)stationId OilName:(nullable NSString *)oilName Success:(void (^)(NSArray <NSString *>* gunNunList))success Failure:(void (^)(void))failure;

/// 获取指定油站的所有油号信息
+ (void)requestStationOilInfoListWithStationID:(NSString *)stationID Success:(void (^)(NSArray <SOSOilStation *>* stationList))success Failure:(void (^)(void))failure;

/// 获取订单列表
+ (void)requestOilOrderListWithPageNum:(int)pageNum PageSize:(int)pageSize Success:(void (^)(NSArray < SOSOilOrder *>* orderList))success Failure:(void (^)(void))failure;

@end

NS_ASSUME_NONNULL_END
