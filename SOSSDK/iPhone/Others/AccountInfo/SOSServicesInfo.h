//
//  SOSServicesInfo.h
//  Onstar
//
//  Created by lmd on 2017/9/14.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ResponseDataObject;

@interface SOSServicesInfo : NSObject

@property (nonatomic, strong) NNserviceObject *SmartDrive;
@property (nonatomic, strong) NNserviceObject *CarAssessment;
@property (nonatomic, strong) NNserviceObject *RemoteControlOptStatus;
@property (nonatomic, strong) NNserviceObject *FmvOptStatus;
@property (nonatomic, strong) NNserviceObject *FuelEconomy;
@property (nonatomic, strong) NNserviceObject *EnergyEconomy;
@property (nonatomic, strong) NNserviceObject *ChargeStation;

//代表以下数据都从服务器获取过
@property (nonatomic, assign) BOOL hasResponse;

- (void)getResponseFromSeriverComplete:(void (^)(void))complete ;

- (void)getResponseFromSeriverForce:(BOOL)force complete:(void (^)(void))complete ;

/**
 获取全部设置状态

 @param callback 回调
 */
- (void)getServiceStatusCallback:(void(^)(NSString *optStatus))callback;

/**
 获取单个设置状态

 @param serviceName 服务名
 @param callback 回调
 */
- (void)getServiceStatus:(NSString *)serviceName callback:(void(^)(NSDictionary *result))callback;

- (void)getServiceStatus:(NSString *)serviceName Success:(void(^)(NSDictionary *result))success Failure:(SOSFailureBlock)failure;

- (void)triggerService:(BOOL)status serviceName:(NSString *)serviceName callback:(void (^)(void))callback;
- (void)triggerService:(BOOL)status serviceName:(NSString *)serviceName callback:(void (^)(void))callback failBlock:(void (^)(NSInteger statusCode, NSString *responseStr, NSError *error))failBlock;
@end
