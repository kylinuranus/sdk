//
//  FootPrintDataOBJ.h
//  Onstar
//
//  Created by Coir on 16/7/27.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "CustomerInfo.h"
#import <Foundation/Foundation.h>

@interface FootPrintDataOBJ : NSObject

+ (void)getFootPrintOverViewLoading:(BOOL)showLoading
                            Success:(void (^)(NSMutableDictionary *dataArray))success
                            Failure:(void (^)(NSInteger statusCode, NSString *responseStr, NSError *error))failure ;

//+ (void)getFootPrintOverViewSuccess:(void (^)(NSMutableDictionary *dataArray))success Failure:(void (^)(NSInteger statusCode, NSString *responseStr, NSError *error))failure;

//+ (void)getFootPrintDetailAtCity:(NSString *)city Success:(void (^)(NSArray *dataArray))success Failure:(void (^)(NSInteger statusCode, NSString *responseStr, NSError *error))failure;

//+ (void)deleteFootPrintByID:(NSNumber *)footPrintID AtCity:(NSString *)city Success:(void (^)(void))success Failure:(void (^)(NSInteger statusCode, NSString *responseStr, NSError *error))failure;
+ (void)uploadFootPrintByDic:(NSDictionary *)footPrintDic;

@end
