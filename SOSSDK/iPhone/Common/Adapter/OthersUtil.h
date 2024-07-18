//
//  OthersUtil.h
//  Onstar
//
//  Created by Vicky on 16/6/30.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataObject.h"
#import "IPData.h"
#import "SOSRemoteControlShareUser.h"
@interface OthersUtil : NSObject
//Sum:9
//获取公网ip
+ (void)getIP:(NSString *)url SuccessHandle:(void (^)(IPData *ip))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;

//获取Banner
+ (void)getBannerByCategory:(NSString *)category_ SuccessHandle:(void (^)(NSArray *banners))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;
typedef void (^success_)(id responseStr);

+ (void)getBannerByCategory:(NSString *)category_ CarOwnersLiv:(BOOL)living SuccessHandle:(success_)success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;


+ (void)getBannerWithCategory:(NSString *)category_ SuccessHandle:(success_)success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;
//获取LandingPage

//获取省份信息
+ (void)getProvinceInfosuccessHandler:(void(^)(NSArray *responsePro))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;
//获取省份的城市信息
+ (void)getCityInfoByProvince:(NSString *)province successHandler:(void(^)(NSArray *responsePro))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;

//Report
+ (void)sendReportToDAAP:(NSString *)reportUrl_ postParaJsonString:(NSString *)para_ successHandle:(void (^)(NSString *responseStr))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;

//帮助列表

//帮助详情：webview

//指南

//指南详情：webview


//充电通知

//获取Layer7闪灯鸣笛时间

#pragma mark --- 小o查询问题
typedef void (^SOSMroResultSuccessBlock)(SOSNetworkOperation *operation, NSDictionary* resultDic);
typedef void (^SOSMroResultFailureBlock)(SOSNetworkOperation *operation, NNError* definedError,NSString * errorStr);
//天气
//+ (void)asyncRequestForWeather:(NSString *)URL successBlock:(SOSMroResultSuccessBlock)successBlock_ failureBlock:(SOSMroResultFailureBlock)failureBlock_;

//限行
//+ (void)asyncRequestForRestrict:(NSString *)restrictURL successBlock:(SOSMroResultSuccessBlock)successBlock_ failureBlock:(SOSMroResultFailureBlock)failureBlock_;// __attribute((deprecated("MA8.1废弃")));


/**
 MA8.1 限行查询城市接口

 @param successBlock 成功回调
 @param failureBlock 失败回调
 */
+ (void)asyncRequestForRestrictCitysWithSuccessBlock:(SOSMroResultSuccessBlock)successBlock failureBlock:(SOSMroResultFailureBlock)failureBlock;
/**
 MA8.1 限行接口

 @param cityCode 城市编码
 @param time 查询时间
 @param successBlock 成功回调
 @param failureBlock 失败回调
 */
+ (void)asyncRequestForRestrictionWithCityCode:(NSString *)cityCode time:(NSString *)time successBlock:(SOSMroResultSuccessBlock)successBlock failureBlock:(SOSMroResultFailureBlock)failureBlock;

//违章
+ (void)asyncRequestForVolation:(NSString *)URL_ successBlock:(SOSMroResultSuccessBlock)successBlock_ failureBlock:(SOSMroResultFailureBlock)failureBlock_ ;

#pragma mark ---info3
////info3获取最新tcps协议内容
//+ (void)getTCPSProtolSuccessHandler:(void(^)(TCPSResponse * res))success failureHandler:(void(^)(NSString *responseStr, NNError *error))failure;
//info3获取单个个协议内容,比如分别获取tc协议和ps协议
+ (void)getTCPSProtolItem:(NSString *)url SuccessHandler:(void(^)(NSString * res))success failureHandler:(void(^)(NSString *responseStr, NNError *error))failure;
////info3用户同意tcps进行提交
//+ (void)confirmUserAgreeTCPS:(NSString *)guid successHandler:(void(^)(TCPSResponse * res))success failureHandler:(void(^)(NSString *responseStr, NNError *error))failure;
#pragma mark ---车分享
/**
 查询车分享用户列表
 @param success
 @param failure
 */
+ (void)getCarsharingSuccessHandler:(void(^)(SOSRemoteControlShareUserList * res))success failureHandler:(void(^)(NSString *responseStr, NNError *error))failure;
/**
 设置用户车分享权限信息
 @param authUser 授权用户
 @param success
 @param failure failure description
 */
+ (void)setCarsharingAuthorzation:(RemoteControlSharePostUser *)authUser SuccessHandler:(void(^)(NSString * responseStr,NNError * res))success failureHandler:(void(^)(NSString *responseStr, NNError *error))failure;

/**
 查询用户车分享权限信息
 @param success
 @param failure
 */
+ (void)queryCarsharingStatusSuccessHandler:(void(^)(SOSRemoteControlShareUser * res))success failureHandler:(void(^)(NSString *responseStr, NNError *error))failure;
#pragma mark ---bbwc
+ (void)queryBBWCQuestionByGovid:(NSString *)govid successHandler:(void(^)(NSArray * questions))success failureHandler:(void(^)(NSString *responseStr, NNError *error))failure;
//+ (void)queryBBWCInfoGovid:(NSString *)govid andVIN:(NSString * )vin successHandler:(void(^)(NSArray * questions))success failureHandler:(void(^)(NSString *responseStr, NNError *error))failure;
+ (void)queryBBWCInfoByEnrollInfo:(NSString *)para successHandler:(void(^)(NSDictionary * response))success failureHandler:(void(^)(NSString *responseStr, NNError *error))failure;
#pragma mark ---Login(暂放此处)
/**
 登录第二步获取userbasicinfo
 @param idpUserId
 @param success
 @param failure
 */
+ (void)loadUserBasicInfoByidpuserID:(NSString *)idpUserId successHandler:(void(^)(SOSNetworkOperation *operation,NSString * response))success failureHandler:(void(^)(NSInteger statusCode,NSString *responseStr, NNError *error))failure;

/**
 登录第三步获取commands
 @param idpUserId
 @param subId
 @param vin_
 @param success
 @param failure
 */
+ (void)loadUserVehicleCommandsByVin:(NSString *)vin_ successHandler:(void(^)(SOSNetworkOperation *operation,NSString * response))success failureHandler:(void(^)(NSInteger statusCode,NSString *responseStr, NSError *error))failure;
/**
 登录第四步获取privilege
 @param success
 @param failure
 */
+ (void)loadVehiclePrivilegeSuccessHandler:(void(^)(SOSNetworkOperation *operation,NSString * response))success failureHandler:(void(^)(NSInteger statusCode,NSString *responseStr, NNError *error))failure;

/**
 星用户信息修改Pin,需要获取安全Ticket

 @param govid
 @param success
 @param failure
 */
+ (void)loadSecretTicket:(NSString *)govid successHandler:(void(^)(NSString * ticket))success failureHandler:(void(^)(NSString *responseStr, NNError *error))failure;

+ (void)loadAppAllowNotify:(NSString *)status successHandler:(void(^)(NSString * ticket))success failureHandler:(void(^)(NSString *responseStr, NNError *error))failure;

@end
