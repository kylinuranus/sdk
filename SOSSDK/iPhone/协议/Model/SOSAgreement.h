//
//  SOSAgreement.h
//  Onstar
//
//  Created by TaoLiang on 19/04/2018.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSAgreementConst.h"

//请求的block回调
typedef void (^SOSAgreementSuccessBlock)(NSDictionary *response);
typedef void (^SOSAgreementFailBlock)(NSInteger statusCode, NSString *responseStr, NSError *error);

@interface SOSAgreement : NSObject
@property (copy, nonatomic) NSString *id;
@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *docTitle;
@property (copy, nonatomic) NSString *revision;
@property (copy, nonatomic) NSString *country;
@property (copy, nonatomic) NSString *language;
@property (copy, nonatomic) NSString *url;
@property (copy, nonatomic) NSString *critical;
@property (copy, nonatomic) NSString *daysToAct;
@property (copy, nonatomic) NSString *status;


/**
 本地NSUserDefault是否有当前用户已签署某协议的记录

 @param agreementType 协议类型
 @return bool
 */
+ (BOOL)didLocalSignedAgreement:(SOSAgreementType)agreementType;

/**
 本地NSUserDefault保存当前用户签署某协议记录

 @param agreementType 协议类型
 */
+ (void)localSignAgreement:(SOSAgreementType)agreementType;
/**
 获取最新的指定协议

 @param type 协议type
 @param successBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)requestAgreementsWithTypes:(NSArray<NSString *> *)types success:(SOSAgreementSuccessBlock)successBlock fail:(SOSAgreementFailBlock)failBlock;


/**
 获取用户需要签署的指定的最新协议， 如果某个协议已经签署的最新的协议，则返回空(用于登录后弹框)

 @param type 协议type
 @param successBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)requestAgreementsWhichNeedSignWithTypes:(NSArray<NSString *> *)types success:(SOSAgreementSuccessBlock)successBlock fail:(SOSAgreementFailBlock)failBlock;


/**
 签署协议

 @param agreements 协议们
 @param successBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)requestSignAgreements:(NSArray<SOSAgreement *> *)agreements success:(SOSAgreementSuccessBlock)successBlock fail:(SOSAgreementFailBlock)failBlock;

@end
