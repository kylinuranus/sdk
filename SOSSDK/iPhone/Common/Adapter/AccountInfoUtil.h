//
//  AccountInfoUtil.h
//  Onstar
//
//  Created by Vicky on 16/6/30.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseDataObject.h"
#import "RequestDataObject.h"

@interface AccountInfoUtil : NSObject
//Sum:6
/**
 *  获取用户信息
 *
 *  @param popError       是否报错
 *  @param completion     成功block
 *  @param failCompletion 失败block
 */

+ (void)getAccountInfo:(BOOL)popError Success:(void (^)(NNExtendedSubscriber *subscriber))completion Failed:(void (^)(void))failCompletion;
/**
 *  获取用户头像
 *
 *  @param completion     成功block
 *  @param failCompletion 失败block
 */
//+ (void)getHeadPhoto:(void(^)(NNHeadPhotoResponse * headPhoto))completion Failed:(void(^)(void)) failCompletion;

/**
 *  更新用户头像
 *
 *  @param headPhoto      头像对象
 *  @param completion     成功block
 *  @param failCompletion 失败block
 */
+ (void)updateHeadPhoto:(NSString *) headPhotoStr Suffix:(NSString *)suffix Success:(void(^)(NSDictionary *response))completion Failed:(void (^)(void)) failCompletion;

/**
 *  修改密码
 *
 *  @param password       密码对象
 *  @param completion     成功block
 *  @param failCompletion 失败block
 */
+ (void)updatePassword:(NSString *) newpassword OldPassword:(NSString *)oldPassword  Success:(void(^)(NSString *response))completion Failed:(void(^)(NSString *failResponse))failCompletion;

/**
 *  修改联系方式：手机/邮箱
 *
 *  @param mobileEmail    手机/邮箱对象
 *  @param completion     成功block
 *  @param failCompletion 失败block
 */
+ (void)updateMobileEmail:(NSString *) mobileEmail ValidateCode:(NSString *) validateCode Success:(void(^)(NNRegisterResponse *response))completion Failed:(void(^)(void))failCompletion;

/**
 *  修改联系方式：手机/邮箱，获取验证码
 *
 *  @param mobileEmail    mobileEmail description
 *  @param completion     成功block
 *  @param failCompletion 失败block
 */
+ (void)getmobileEmailVerifyCode:(NSString *)mobileEmail Success:(void(^)(NNRegisterResponse *response))completion Failed:(void(^)(void))failCompletion;

/**
 *  修改通信地址
 *
 *  @param address    NNChangeAddressRequest 通信地址对象
 *  @param completion     成功block
 *  @param failCompletion 失败block
 */
+ (void)updateContactAddress:(NNChangeAddressRequest *)address  Success:(void(^)(NSString *response))completion Failed:(void(^)(void))failCompletion;

+ (void)updateMobileEmailWithoutLoadingView:(NSString *) mobileEmail withIDpid:(NSString *)idpid ValidateCode:(NSString *) validateCode needAlertError:(BOOL)needAlert Success:(void(^)(NNRegisterResponse *response))completion Failed:(void (^)(NSString *errorStr))failCompletion;

/**
 更新用户昵称

 @param nickName nickName description
 @param completion completion description
 @param failCompletion failCompletion description
 */
+ (void)updateUserNickName:(NSString *)nickName  successBlock:(void(^)(NNRegisterResponse *response))completion failedBlock:(void (^)(void))failCompletion;

#pragma mark---强制补充手机号界面部分参数需要指定
//未调用loading界面的修改联系方式method，因强制手机号录入界面要控制loading界面,该方法体内不再弹出loading
+ (void)updateMobileEmailWithoutLoadingView:(NSString *) mobileEmail withIDpid:(NSString *)idpid ValidateCode:(NSString *) validateCode Success:(void(^)(NNRegisterResponse *response))completion Failed:(void (^)(void))failCompletion;

+ (void)getmobileEmailVerifyCode:(NSString *)mobileEmail withIDpid:(NSString *)idpid Success:(void(^)(NNRegisterResponse *response))completion Failed:(void (^)(void))failCompletion;

/**
 上传快捷键

 @param qsStr
 @param completion
 @param failCompletion
 */
+ (void)upLoadUserCustomizeQuickStart:(NSString *)qsStr  successBlock:(void(^)(NSString *response))completion failedBlock:(void(^)(void))failCompletion;

/**
 获取用户日程

 */
+ (void)getUserOnstarSchedulesWithIdpid:(NSString *)mobile andDate:(NSString *)date  successBlock:(void(^)(NSString *response))completion failedBlock:(void(^)(void))failCompletion;

/**
 绑定客户端日程与后端日程id

 */
+ (void)bindClientScheduleIds:(NSArray *)schArr successBlock:(void(^)(NSString *response))completion failedBlock:(void(^)(void))failCompletion;

+ (void)updateInfoReadStatusWithNotifyId:(NSString *)nId isDelete:(BOOL)isDel;


+ (void)queryUserWechatBindStatusHandler:(void(^)(BOOL hasBind))complete;
+ (void)unBindUserWechatHandler:(void(^)(BOOL unBindResult))complete;


+ (void)cheeckNeedVerifyPersionInfoBlock:(void (^)(bool needVerify,NSString * verUrl, NSString *verifyTip))complete;

@end
