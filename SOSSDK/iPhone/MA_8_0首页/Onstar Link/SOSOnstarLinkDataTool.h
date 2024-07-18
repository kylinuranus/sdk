//
//  SOSOnstarLinkDataTool.h
//  Onstar
//
//  Created by Coir on 2018/7/31.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOSOnstarLinkDataModel : NSObject

//@property (nonatomic, assign) NSUInteger createDate;
//@property (nonatomic, copy) NSString *idpUserId;
//@property (nonatomic, assign) NSUInteger lastUpdateDate;
@property (nonatomic, copy) NSString *mobile;

@end

@interface SOSOnstarLinkDataTool : NSObject

@property (nonatomic, strong) SOSOnstarLinkDataModel *dataModel;

+ (SOSOnstarLinkDataTool *)sharedInstance;

/// 获取绑定信息
+ (void)getOnstarLinkInfoSuccess:(void (^)(NSDictionary *result))success Failure:(void(^)(NSString *responseStr, NSError *error))failure;

/// 绑定用户信息
+ (void)bindOnstarInfoWithPhoneNum:(NSString *)phoneNum IsModify:(BOOL)isModifyMode Success:(void (^)(NSDictionary *result))success Failure:(void(^)(NSString *responseStr, NSError *error))failure;

/// 发送验证码
+ (void)sendVerificationCodeWithPhoneNum:(NSString *)phoneNum Success:(void (^)(NSDictionary *result))success Failure:(void(^)(NSString *responseStr, NSError *error))failure;

/// 校验验证码
+ (void)checkVerificationCodeWithPhoneNum:(NSString *)phoneNum AndVerificationCode:(NSString *)code Success:(void (^)(NSDictionary *result))success Failure:(void(^)(NSString *responseStr, NSError *error))failure;

/// 根据数据进行OnstarLink下一步操作
- (void)enterOnstarLink;

/// 弹出协议弹框
+ (void)showagreementVC;

@end
