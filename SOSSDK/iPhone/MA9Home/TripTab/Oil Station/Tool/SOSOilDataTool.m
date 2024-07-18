//
//  SOSOilDataTool.m
//  Onstar
//
//  Created by Coir on 2019/8/21.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSOilDataTool.h"

@implementation SOSOilDataTool
/**		获取根据经纬度查询 50KM 内 优惠加油 加油站信息
* gasType    	String    油站类型（1 中石油，2 中石化，3 壳牌，4 其他）
* oilName 		String    油号（90#、92#、95#、98#、101#）默认92#
* sortColumn    String    distance（距离）,price(优惠加油价格)默认距离排序
 */
+ (void)requestOilStationListWithCenterPOI:(SOSPOI*)centerPOI GasType:(nullable NSString *)gasType OilName:(nullable NSString *)oilName AndSortColumn:(nullable NSString *)sortColumn Success:(void (^)(NSArray <SOSOilStation *>* stationList))success Failure:(void (^)(void))failure       {
    NSString *url = [BASE_URL stringByAppendingFormat:SOSOilStationListURL];
    url = [url stringByAppendingFormat:@"?longitude=%@&latitude=%@&sortColumn=%@", centerPOI.longitude, centerPOI.latitude, sortColumn.length ? sortColumn : @"distance"];
    if (gasType.length) url = [url stringByAppendingFormat:@"&gasType=%@", gasType];
    if (oilName.length) url = [url stringByAppendingFormat:@"&oilName=%@", oilName.stringByURLEncode];
    SOSNetworkOperation* sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        if (operation.statusCode == 200) {
            NSMutableArray *datas = [NSMutableArray array];
            if ([responseStr isKindOfClass:[NSString class]] && [responseStr length]) {
                NSArray *dicArr = [responseStr mj_JSONObject];
                if ([dicArr isKindOfClass:[NSArray class]]) {
                    for (NSDictionary *dic in dicArr) {
                        if ([dic isKindOfClass:[NSDictionary class]]) {
                            SOSOilStation *station = [SOSOilStation mj_objectWithKeyValues:dic];
                            [datas addObject:station];
                        }
                    }
                }
            }
            if (success)    success(datas);
        }	else	{
            if (failure)    failure();
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util toastWithMessage:responseStr];
        if (failure)    failure();
    }];
    [sosOperation setHttpMethod:@"GET"];
    NSString *idpid = [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
    [sosOperation setHttpHeaders:@{@"client-user-id": (idpid ? idpid : @"")}];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}

/// 获取油号列表
+ (void)requestOilInfoListSuccess:(void (^)(NSArray <SOSOilInfoObj *>* oilInfoList))success Failure:(void (^)(void))failure       {
    NSString *url = [BASE_URL stringByAppendingFormat:SOSOilInfoListURL];
    SOSNetworkOperation* sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        if (operation.statusCode == 200) {
            NSMutableArray *datas = [NSMutableArray array];
            if ([responseStr isKindOfClass:[NSString class]] && [responseStr length]) {
                NSArray *dicArr = [responseStr mj_JSONObject];
                if ([dicArr isKindOfClass:[NSArray class]]) {
                    for (NSDictionary *dic in dicArr) {
                        if ([dic isKindOfClass:[NSDictionary class]]) {
                            SOSOilInfoObj *station = [SOSOilInfoObj mj_objectWithKeyValues:dic];
                            [datas addObject:station];
                        }
                    }
                }
            }
            if (success)    success(datas);
        }    else    {
            if (failure)    failure();
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util toastWithMessage:responseStr];
        if (failure)    failure();
    }];
    [sosOperation setHttpMethod:@"GET"];
    NSString *idpid = [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
    [sosOperation setHttpHeaders:@{@"client-user-id": (idpid ? idpid : @"")}];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}

/// 获取指定油枪的可用油号列表
+ (void)requestOilGunNumListWithStationId:(NSString *)stationId OilName:(nullable NSString *)oilName Success:(void (^)(NSArray <NSString *>* gunNumList))success Failure:(void (^)(void))failure       {
    NSString *url = [BASE_URL stringByAppendingFormat:SOSOilGunInfoListURL];
    oilName = oilName.length ? oilName : @"";
//    url = [url stringByAppendingFormat:@"?gasId=%@&oilName=%@", @"DF123456789", oilName.stringByURLEncode];
    url = [url stringByAppendingFormat:@"?gasId=%@", stationId];
    if (oilName.length) url = [url stringByAppendingFormat:@"&oilName=%@", oilName.stringByURLEncode];
    SOSNetworkOperation* sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        if (operation.statusCode == 200) {
            NSMutableArray *datas = [NSMutableArray array];
            if ([responseStr isKindOfClass:[NSString class]] && [responseStr length]) {
                NSArray *dicArr = [responseStr mj_JSONObject];
                if ([dicArr isKindOfClass:[NSArray class]]) {
                    for (NSDictionary *dic in dicArr) {
                        if ([dic isKindOfClass:[NSDictionary class]]) {
                            NSString *gunNum = dic[@"gunNo"];
                            if(gunNum.length) 	[datas addObject:gunNum];
                        }
                    }
                }
            }
            if (success)    success(datas);
        }    else    {
            if (failure)    failure();
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util toastWithMessage:responseStr];
        if (failure)    failure();
    }];
    [sosOperation setHttpMethod:@"GET"];
    NSString *idpid = [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
    [sosOperation setHttpHeaders:@{@"client-user-id": (idpid ? idpid : @"")}];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}

/// 获取订单列表
+ (void)requestOilOrderListWithPageNum:(int)pageNum PageSize:(int)pageSize Success:(void (^)(NSArray < SOSOilOrder *>* orderList))success Failure:(void (^)(void))failure       {
    NSString *url = [BASE_URL stringByAppendingFormat:SOSOilOrderListURL];
    url = [url stringByAppendingFormat:@"?pageNumber=%d&pageSize=%d", pageNum, pageSize ? pageSize : 20];
    SOSNetworkOperation* sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        if (operation.statusCode == 200) {
            NSMutableArray *datas = [NSMutableArray array];
            if ([responseStr isKindOfClass:[NSString class]] && [responseStr length]) {
                NSArray *dicArr = [responseStr mj_JSONObject];
                if ([dicArr isKindOfClass:[NSArray class]]) {
                    for (NSDictionary *dic in dicArr) {
                        if ([dic isKindOfClass:[NSDictionary class]]) {
                            SOSOilOrder *station = [SOSOilOrder mj_objectWithKeyValues:dic];
                            [datas addObject:station];
                        }
                    }
                }
            }
            if (success)    success(datas);
        }    else    {
            if (failure)    failure();
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util toastWithMessage:responseStr];
        if (failure)    failure();
    }];
    [sosOperation setHttpMethod:@"GET"];
    NSString *idpid = [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
    [sosOperation setHttpHeaders:@{@"client-user-id": (idpid ? idpid : @"")}];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}

/// 获取油站所有油号信息
+ (void)requestStationOilInfoListWithStationID:(NSString *)stationID Success:(void (^)(NSArray <SOSOilStation *>* stationList))success Failure:(void (^)(void))failure       {
    NSString *url = [BASE_URL stringByAppendingFormat:SOSStationOilInfoListURL];
    url = [url stringByAppendingFormat:@"?gasId=%@", stationID];
    SOSNetworkOperation* sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        if (operation.statusCode == 200) {
            NSMutableArray *datas = [NSMutableArray array];
            if ([responseStr isKindOfClass:[NSString class]] && [responseStr length]) {
                NSArray *dicArr = [responseStr mj_JSONObject];
                if ([dicArr isKindOfClass:[NSArray class]]) {
                    for (NSDictionary *dic in dicArr) {
                        if ([dic isKindOfClass:[NSDictionary class]]) {
                            SOSOilStation *station = [SOSOilStation mj_objectWithKeyValues:dic];
                            [datas addObject:station];
                        }
                    }
                }
            }
            if (success)    success(datas);
        }    else    {
            if (failure)    failure();
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util toastWithMessage:responseStr];
        if (failure)    failure();
    }];
    [sosOperation setHttpMethod:@"GET"];
    NSString *idpid = [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
    [sosOperation setHttpHeaders:@{@"client-user-id": (idpid ? idpid : @"")}];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}

@end
