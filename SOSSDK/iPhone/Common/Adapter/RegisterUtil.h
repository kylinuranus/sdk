//
//  RegisterUtil.h
//  Onstar
//
//  Created by Vicky on 16/6/30.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RegisterUtil : NSObject
//Sum:9
//0-2:注册为车主
+ (void)registAsOwner:(NSString *)url_ paragramString:(NSString *)params_ successHandler:(void(^)(SOSNetworkOperation *operation ,NSString *responseStr))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;

//0-1：注册为访客
+ (void)registAsVisitor:(NSString *)url_ paragramString:(NSString *)params_ successHandler:(void(^)(NNRegisterResponse * regRes))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;
//1-2：升级车主
//+ (void)updateToOwnerParagramString:(NSString *)params_ successHandler:(void(^)(NNRegisterResponse * regRes))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;

//验证密码邮箱唯一性
//+ (void)updateCheckMobileOrEmailSuccessHandler:(void(^)(SOSNetworkOperation *operation,NNRegisterResponse * regRes))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;
//获取手机/邮箱验证码

//检查手机/邮箱验证码

//是否需要显示图形验证码
+ (void)generateRegisterImageCaptchaGenerate:(NSString *)captchaId_ successHandler:(void(^)(id resp))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;
//获取图形验证码
+ (void)getRegisterImageCodeSuccessHandler:(void(^)(NSDictionary * resDic))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;
//检查图形验证码
+ (void)checkRegisterImageCode:(NSString *)captchaId_ value:(NSString *)captchaValue_ SuccessHandler:(void(^)(NSDictionary * resDic))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;
//发送验证码,短信或者email接受
+ (void)sendVerifyCode:(NSString *)para successHandler:(void(^)(id resp))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;
+ (void)checkVerifyCode:(NSString *)para successHandler:(void(^)(id resp))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;
#pragma mark - 8.0 注册
//查询vin是否enroll或者account 注册状态
//isCheckEnroll: 判断接口是查询vin enroll还是查询账户状态
+ (void)isCheckEnrollState:(BOOL)isCheckEnroll paragramString:(NSString *)params_ successHandler:(void(^)(NSString *responseStr))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;
//查询govid对应信息
+ (void)checkSubscriberByGovid:(NSString *)govid successHandler:(void(^)(NSString *responseStr))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;
//更换govid界面需要请求另外接口获取注册界面元素信息
+ (void)checkNewGovidInfo:(NSString *)para_ successHandler:(void(^)(NSString *responseStr))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;

//上传enroll用户vin、receipt照片
+ (void)uploadSubscriberReceiptPhoto:(NSString *)para_ successHandler:(void(^)(NSString *responseStr))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_  ;

/**
 上传enroll用户身份证正反面、发票照片
 @param uploadArray 包含用户照片信息与照片名称的字典
 @param success_
 @param failure_
 */
+ (void)uploadSubscriberPhotos:(NSArray *)uploadArray successHandler:(void(^)(NSString *responseStr))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;

//查询govid对应信息
+ (void)registSubscriberByEnrollInfo:(NSString *)para successHandler:(void(^)(NSString *responseStr))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;
//注册MA时gaa有用户信息，使用gaa用户信息注册，但是修改部分信息进行注册，需要验证pin码
+ (void)checkPIN:(NSString *)para successHandler:(void(^)(NSString *responseStr))success_ failureHandler:(void(^)(NSString *responseStr))failure_;
//提交bbwc注册信息 OR 更新星用户信息
+ (void)submitBBWCInfoOrOnstarInfo:(BOOL)isBBWC  withEnrollInfo:(NSString *)para successHandler:(void(^)(NSString *responseStr))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;
//查询经销商信息
+ (void)queryDealerInfo:(NNAroundDealerRequest *)dealerReq subscriberID:(NSString *)sub accountId:(NSString *)account vinStr:(NSString *)vin successHandler:(void(^)(NSString *responseStr))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;//NS_DEPRECATED


+ (void)queryDealerInfo:(NNAroundDealerRequest *)dealerReq subscriberID:(NSString *)sub accountId:(NSString *)account vinStr:(NSString *)vin pageSize:(NSString *)pagesize successHandler:(void(^)(NSString *responseStr))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;
//查询Visitor账号是否在
+ (void)queryIsGAAMobileAndEmail:(NNGAAEmailPhoneRequest *)queryReq successHandler:(void(^)(NSString *responseStr))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;
//查询Visitor添加车辆时候状态
+ (void)checkVisitorWithVINOrGovidState:(NSString *)para_ successHandler:(void(^)(NSString *responseStr))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;
@end
