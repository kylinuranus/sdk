//
//  ChargeStationOBJ.m
//  Onstar
//
//  Created by Coir on 16/6/16.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "ChargeStationOBJ.h"
#import "SOSUserLocation.h"

NSString *const KAYChargeListCellTappedNotify = @"KAYChargeListCellTappedNotify";
NSString *const KDealerChargeListCellTappedNotify = @"KDealerChargeListCellTappedNotify";
NSString *const KNeedShowStationListMapNotify = @"KNeedShowStationListMapNotify";

@implementation ChargeStationOBJ

- (SOSPOI *)transToPoi	{
    SOSPOI *poi = [SOSPOI mj_objectWithKeyValues:[self mj_keyValues]];
    poi.name = self.stationName;
    poi.nickName = self.stationName;
    poi.sosPoiType = POI_TYPE_ChargeStation;
    return poi;
}

+ (void)requestStationDetailWithStationId:(NSString *)stationId successBlock:(void (^)(ChargeStationOBJ * obj))successBlock failureBlock:(SOSFailureBlock)failureBlock   {
    
    
    NSString *url = [NSString stringWithFormat:(@"%@"Charge_Station_Detail_URL), BASE_URL, stationId];
    
    SOSNetworkOperation *operation = [[SOSNetworkOperation alloc] initWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        [Util hideLoadView];
        if (operation.statusCode == 200) {
            
            NSDictionary *sourceDic = [Util dictionaryWithJsonString:responseStr];
            ChargeStationOBJ *obj = [ChargeStationOBJ mj_objectWithKeyValues:sourceDic];
            if (successBlock) {
                successBlock(obj);
            }
        }
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        //        [Util hideLoadView];
        //        [Util toastWithMessage:responseStr];
        if (failureBlock) {
            failureBlock(statusCode, responseStr, error);
        }
    }];
    [operation setHttpHeaders:@{@"Authorization": [LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];
}

+ (void)requestBrandStationListPOIInfo:(SOSPOI *)poi Success:(void (^)(NSArray <ChargeStationOBJ *> * stationList))successBlock Failure:(void (^)(void))failure      {
    [SOSUserLocation handleLocationPOIInfoDone:poi Success:^(BOOL done, SOSPOI *resultPOI) {
        if (done) 	[self requestStationListPOIInfo:resultPOI IsBrandMode:YES Success:successBlock Failure:failure];
    }];
}

+ (void)requestStationListPOIInfo:(SOSPOI *)poi Success:(void (^)(NSArray <ChargeStationOBJ *> * stationList))successBlock Failure:(void (^)(void))failure      {
    [SOSUserLocation handleLocationPOIInfoDone:poi Success:^(BOOL done, SOSPOI *resultPOI) {
        if (done)	[self requestStationListPOIInfo:poi IsBrandMode:NO Success:successBlock Failure:failure];
    }];
}

+ (void)requestStationListPOIInfo:(SOSPOI *)poi IsBrandMode:(BOOL)isbrandMode Success:(void (^)(NSArray <ChargeStationOBJ *> * stationList))successBlock Failure:(void (^)(void))failure      {
    
    NSString *url = [NSString stringWithFormat:(@"%@"Charge_Station_List_URL), BASE_URL];
    url  = [url stringByAppendingFormat:@"?pageNum=0&pageSize=1000"];
    NSString *keyWords = @"";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"query": keyWords, @"longitude":poi ? poi.longitude : @"", @"latitude": poi ? poi.latitude : @""}];
    if (isbrandMode)	{
        parameters[@"city"] = NONil(poi.city);
        parameters[@"supplier"] = NONil([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.brand);
	}
    
    SOSNetworkOperation *operation = [[SOSNetworkOperation alloc] initWithURL:url params:[parameters toJson] successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSMutableArray *stationListArray = [NSMutableArray array];
        if (operation.statusCode == 200) {
            NSDictionary *sourceDic = [Util dictionaryWithJsonString:responseStr];
//            BOOL isLastPage = [sourceDic[@"isLastPage"] boolValue];
            NSArray *stationDicArray = sourceDic[@"stations"];
            if (stationDicArray.count) {
                for (NSDictionary *dic in stationDicArray) {
                    ChargeStationOBJ *obj = [ChargeStationOBJ mj_objectWithKeyValues:dic];
                    [stationListArray addObject:obj];
                }
            }
            dispatch_async_on_main_queue(^{
                if (successBlock)    successBlock(stationListArray);
            });
            return;
        }
        dispatch_async_on_main_queue(^{
            if (failure)    failure();
        });
        [Util toastWithMessage:[Util visibleErrorMessage:responseStr]];
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async_on_main_queue(^{
            if (failure)    failure();
        });
        [Util toastWithMessage:[Util visibleErrorMessage:responseStr]];
    }];
    [operation setHttpHeaders:@{@"Authorization": [LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"PUT"];
    [operation start];
}
@end
