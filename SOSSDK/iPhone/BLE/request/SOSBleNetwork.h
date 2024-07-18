//
//  SOSBleNetwork.h
//  Onstar
//
//  Created by onstar on 2018/7/20.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSAgreement.h"
#import "SOSAuthorInfo.h"

@interface SOSBleNetwork : NSObject
//获取协议
+ (void)loadBLENeedConfirmTypes:(NSArray *)types
                        success:(void(^)(NSArray <SOSAgreement *>* agreements))complete
                         failed:(void(^)(NSString *responseStr, NSError *error))failCompletion;

//签协议
+ (void)requestSignAgreements:(NSArray<SOSAgreement *> *)agreements
                      success:(void(^)(NSDictionary *))success
                         fail:(SOSAgreementFailBlock)failBlock;

//签协议+绑定
+ (void)requestBleBindOwnerSuccess:(void (^)(NSDictionary *urlRequest))completion
                            Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion;



//获取授权列表
+ (void)getOwnerAuthorizationsListSuccess:(void (^)(SOSAuthorInfo *urlRequest))completion
                                   Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion;
//新增授权
+ (void)bleShareOwnerAuthorizationsParams:(NSDictionary *)params
                                  success:(void (^)(SOSAuthorInfo *urlRequest))completion
                                   Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion ;
//批准或关闭授权
+ (void)bleOwnerOperateAuthorizationsParams:(NSDictionary *)params
                                    success:(void (^)(SOSAuthorInfo *urlRequest))completion
                                     Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion;


//接受授权 被授权列表
+ (void)bleUserAuthorizationsParams:(NSDictionary *)params
                             method:(NSString *)method
                            success:(void (^)(SOSAuthorInfo *urlRequest))completion
                             Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion;


//下载钥匙
+ (void)bleUserDownloadKeysWithParams:(NSDictionary *)params
                              success:(void (^)(id JSONDict))completion
                               Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion;

//查询BLE开关状态
+ (void)bleSwitchStatusSuccess:(void (^)(id JSONDict))completion
                        Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion ;

//变更BLE开关状态
+ (void)bleSwitchStatusWithBleStatus:(NSString *)status
                             Success:(void (^)(id JSONDict))completion
                              Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion;
@end
