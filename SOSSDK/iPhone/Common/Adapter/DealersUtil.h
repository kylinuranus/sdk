//
//  DealersUtil.h
//  Onstar
//
//  Created by Vicky on 16/6/30.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DealersUtil : NSObject
//Sum:5

//获取首选经销商（已完成）

//修改首选经销商
+ (void)updateFirstDealerWithPartID:(NSString *)parytyID_ successHandler:(void(^)(SOSNetworkOperation *operation,id responseData))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;
//获取周边经销商City（已完成）

//获取周边经销商Around:经纬度（已完成）

////获取预约经销商列表
//+ (void)getDealersWithLongitude:(NSString *)longi_ latitude:(NSString *)lati_ successHandler:(void(^)(SOSNetworkOperation *operation,id responseData))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;
//创建维修/保养预约

//获取维修/保养预约列表
+ (void)getBookingRecordSuccessHandler:(void(^)(id responseData))success_ failureHandler:(void (^)( NSString *responseStr, NSError *error))failure_;
//获取某一条维修/保养预约记录

@end
