//
//  DealersUtil.m
//  Onstar
//
//  Created by Vicky on 16/6/30.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "DealersUtil.h"
#import "CustomerInfo.h"

@implementation DealersUtil


+ (void)updateFirstDealerWithPartID:(NSString *)parytyID_ successHandler:(void(^)(SOSNetworkOperation *operation,id responseData))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_
{
    NSString *url = [BASE_URL stringByAppendingString:NEW_GET_PREFERRED_UPDATE_DEALER];
    NSDictionary *d = @{@"partyID":parytyID_?:@"",@"vin":[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin};
    NSString *s = [Util jsonFromDict:d];

    
    SOSNetworkOperation * sosOperation = [SOSNetworkOperation requestWithURL:url params:s successBlock:^(SOSNetworkOperation *operation, id returnData) {
        if (success_) {
            success_(operation , returnData);
        }
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (failure_) {
            failure_(responseStr,error);
        }
    }];
    [sosOperation setHttpMethod:@"PUT"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}

//+ (void)getDealersWithLongitude:(NSString *)longi_ latitude:(NSString *)lati_ successHandler:(void(^)(SOSNetworkOperation *operation,id responseData))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_
//{
//    NSString *urlStr = [BASE_URL stringByAppendingFormat:NEW_GET_DEALERS,[CustomerInfo sharedInstance].userBasicInfo.idpUserId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId, [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
//    NNDealersReserveRequest *requestStr = [[NNDealersReserveRequest alloc] init];
//    [requestStr setLongitude:longi_];
//    [requestStr setLatitude:lati_];
//    NSString * brandType = [[CustomerInfo sharedInstance] currentVehicle].brand;
//    brandType = [SOSUtil brandToMSP:brandType];
//    [requestStr setBrand:brandType];
//    NSString *post = [requestStr mj_JSONString];
//    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:urlStr params:post successBlock:^(SOSNetworkOperation *operation, id responseStr) {
//        if (success_) {
//            success_(operation,responseStr);
//        }
//    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
//        if (failure_) {
//            failure_(responseStr,error);
//        }
//    }];
//    [sosOperation setHttpMethod:@"PUT"];
//    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
//    [sosOperation start];
//}
+ (void)getBookingRecordSuccessHandler:(void(^)(id responseData))success_ failureHandler:(void (^)( NSString *responseStr, NSError *error))failure_
{
     NSString *urlStr= [NSString stringWithFormat:(@"%@" NEW_GETDEALERPREORDERS), BASE_URL, [CustomerInfo sharedInstance].userBasicInfo.idpUserId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
     SOSNetworkOperation *sosOperation =
         [SOSNetworkOperation requestWithURL:urlStr
             params:nil
             successBlock:^(SOSNetworkOperation *operation, id responseStr) {

               if (success_) {
                 success_(responseStr);
               }

             }
             failureBlock:^(NSInteger statusCode, NSString *responseStr,
                            NSError *error) {
               if (failure_) {
                 failure_(responseStr, error);
               }
             }];
     [sosOperation setHttpMethod:@"GET"];
     [sosOperation setHttpHeaders:@{
       @"Authorization" : [LoginManage sharedInstance].authorization
     }];
     [sosOperation start];
}
@end
