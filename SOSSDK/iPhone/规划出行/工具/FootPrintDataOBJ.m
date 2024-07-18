//
//  FootPrintDataOBJ.m
//  Onstar
//
//  Created by Coir on 16/7/27.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "FootPrintDataOBJ.h"
#import "SOSSearchResult.h"
#import "SOSTripModule.h"
@implementation FootPrintDataOBJ

//#define FootPrintOverViewKey    @"FootPrintOverViewKey"
//#define FootPrintDetailKey      @"FootPrintDetailKey"


//+ (void)deleteCurrentAccountCachedDataByID:(NSNumber *)ID AtCity:(NSString *)city    {
//    NSArray *sourceArray = [FootPrintDataOBJ getCurrentAccountCachedDataIsDetail:YES AtCity:city];
//    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:sourceArray];
//    for (FootPrintPOI *ftPoi in sourceArray) {
//        if (ftPoi.seqId.integerValue == ID.integerValue) {
//            if ([tempArray containsObject:ftPoi])   [tempArray removeObject:ftPoi];
//        }
//    }
//    [FootPrintDataOBJ saveCurrentAccountCachedDataArray:tempArray IsDetail:YES City:city];
//}

//+ (void)saveCurrentAccountCachedDataArray:(NSArray *)dataArray  City:(NSString *)city    {
//        NSMutableDictionary *sourceDic = [NSMutableDictionary dictionaryWithDictionary:[CustomerInfo sharedInstance].footPrintDic];
//        [CustomerInfo sharedInstance].footPrintDic = sourceDic;
//
//}

+ (void)getFootPrintOverViewLoading:(BOOL)showLoading
                            Success:(void (^)(NSMutableDictionary *dataArray))success
                            Failure:(void (^)(NSInteger statusCode, NSString *responseStr, NSError *error))failure {
    NSString *url = [BASE_URL stringByAppendingFormat:(My_FootPrint_OverView_URL)];
    [FootPrintDataOBJ requestWithURL:url showLoading:NO IsDetail:NO AtCity:nil Parameters:nil Success:success Failure:failure];
}

//+ (void)getFootPrintOverViewSuccess:(void (^)(NSMutableDictionary *dataArray))success Failure:(void (^)(NSInteger statusCode, NSString *responseStr, NSError *error))failure {
//    [FootPrintDataOBJ getFootPrintOverViewLoading:YES Success:success Failure:failure];
//}

//+ (void)getFootPrintDetailAtCity:(NSString *)city Success:(void (^)(NSArray *dataArray))success Failure:(void (^)(NSInteger statusCode, NSString *responseStr, NSError *error))failure      {
//    CustomerInfo *cusInfo = [CustomerInfo sharedInstance];
//    NSString *url = [BASE_URL stringByAppendingFormat:(My_FootPrint_Detail_URL),cusInfo.userBasicInfo.currentSuite.vehicle.vin, [city stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//
//    [FootPrintDataOBJ requestWithURL:url IsDetail:YES AtCity:city Parameters:nil Success:success Failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
//        [Util toastWithMessage:responseStr];
//        failure(statusCode, responseStr, error);
//    }];
//}


//+ (void)requestWithURL:(NSString *)url IsDetail:(BOOL)isDetail AtCity:(NSString *)city Parameters:(NSString *)params Success:(void (^)(NSMutableDictionary *dataArray))success Failure:(void (^)(NSInteger statusCode, NSString *responseStr, NSError *error))failure {
//    [FootPrintDataOBJ requestWithURL:url showLoading:YES IsDetail:isDetail AtCity:city Parameters:params Success:success Failure:failure];
//}

+ (void)requestWithURL:(NSString *)url showLoading:(BOOL)showLoading IsDetail:(BOOL)isDetail AtCity:(NSString *)city Parameters:(NSString *)params Success:(void (^)(NSMutableDictionary *dataArray))success Failure:(void (^)(NSInteger statusCode, NSString *responseStr, NSError *error))failure    {
//    NSArray *sourceArray = [FootPrintDataOBJ getCurrentAccountCachedDataIsDetail:isDetail AtCity:city];
//    if ([CustomerInfo sharedInstance].footPrintDic.count) {
//        success([CustomerInfo sharedInstance].footPrintDic);
//        return;
//    }
    if (showLoading) 	[Util showHUD];
    
    SOSNetworkOperation *operation = [[SOSNetworkOperation alloc] initWithURL:url params:@"" successBlock :^(SOSNetworkOperation *operation, id responseStr) {
        BOOL shouldHideLoadingView = YES;
        NSDictionary *sourceDic = [Util dictionaryWithJsonString:responseStr];
       
        [CustomerInfo sharedInstance].footPrintDic = [NSMutableDictionary dictionaryWithDictionary:sourceDic] ;

       
        if (shouldHideLoadingView) {
            if (showLoading) {
                [Util dismissHUD];
            }
            success([CustomerInfo sharedInstance].footPrintDic);
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (showLoading) {
            [Util dismissHUD];
        }
        failure(statusCode, responseStr, error);
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];
}

//+ (void)deleteFootPrintByID:(NSNumber *)footPrintID AtCity:(NSString *)city Success:(void (^)(void))success Failure:(void (^)(NSInteger statusCode, NSString *responseStr, NSError *error))failure      {
//    [Util showHUD];
//    CustomerInfo *cusInfo = [CustomerInfo sharedInstance];
//    NSString *url = [BASE_URL stringByAppendingFormat:(Delete_My_FootPrint_URL),cusInfo.userBasicInfo.currentSuite.vehicle.vin, footPrintID];
//
//    SOSNetworkOperation *operation = [[SOSNetworkOperation alloc] initWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
//        [FootPrintDataOBJ deleteCurrentAccountCachedDataByID:footPrintID AtCity:city];
//        [Util dismissHUD];
//        success();
//    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
//        [Util dismissHUD];
//        failure(statusCode, responseStr, error);
//    }];
//    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
//    [operation setHttpMethod:@"POST"];
//    [operation start];
//}
+ (void)uploadFootPrintByDic:(NSDictionary *)footPrintDic   {
    
    NSString *url = [BASE_URL stringByAppendingFormat:(My_FootPrint_Upload_URL)];
    
    SOSNetworkOperation *operation = [[SOSNetworkOperation alloc] initWithURL:url params:[footPrintDic mj_JSONString] successBlock:^(SOSNetworkOperation *operation, id responseStr) {
//        success();
        [SOSTripModule refreshFootPrint];
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
//        failure(statusCode, responseStr, error);
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"POST"];
    [operation start];
}
@end
