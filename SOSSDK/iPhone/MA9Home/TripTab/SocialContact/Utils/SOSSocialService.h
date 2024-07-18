//
//  SOSSocialService.h
//  Onstar
//
//  Created by onstar on 2019/4/22.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
#define SOSNotificationCarGPSFinish @"SOSNotificationCarGPSFinish"
@interface SOSSocialService : NSObject

@property (nonatomic, strong, nullable) SOSSocialOrderInfoResp *orderInfoResp;
@property (nonatomic, assign) BOOL showingAlert;
+ (instancetype)shareInstance;

//乘客接受
- (void)showAcceptAlert;

//轮询被接人是否接受状态   同意了在主页及waiting页面弹框
- (void)startObserverAcceptStatus;
//停止轮询
- (void)endObserverAcceptStatus;

//直接查询
- (void)selectStatus;

//上报地理位置
- (void)startUploadLocationService;
//上报地理位置 车机需要实施比对距离500m
- (void)startUploadLocationServiceWithPoi:(SOSPOI *)poi;
//停止上报地理位置
- (void)endUploadLocationService;

@end


//api
@interface SOSSocialService ()

//根据idpuserid创建订单
+ (void)createOrderSuccess:(void (^)(SOSSocialOrderShareInfoResp *urlRequest))completion Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion;

//根据idpuserid查询订单
+ (void)selectOrderSuccess:(void (^)(SOSSocialOrderInfoResp *urlRequest))completion Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion;

//更新订单信息 上报地理位置
+ (void)uploadLocationWithParams:(NSDictionary *)params success:(void (^)(void))completion Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion;

//更新订单信息 改变订单状态
+ (void)changeStatusWithParams:(NSDictionary *)params success:(void (^)(void))completion Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion;

//获取星友圈url
+ (void)getUrlWithUrl:(NSString *)url token:(NSString *)token success:(void (^)(NSString *url))completion Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion;

@end



NS_ASSUME_NONNULL_END
