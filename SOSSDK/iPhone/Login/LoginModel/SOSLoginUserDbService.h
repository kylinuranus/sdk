//
//  SOSLoginUserDbService.h
//  Onstar
//
//  Created by Apple on 17/3/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOSLoginUserDbService : NSObject

+ (SOSLoginUserDbService *)sharedInstance;

//插入user信息
- (void)insertUserIdToken:(NSString *)idToken reposeString:(NSString *)res;
//更新user信息
- (void)updateUserIdToken:(NSString *)idToken reposeString:(NSString *)res;
//查询user信息
- (NSString *)searchUserIdToken:(NSString *)idToken;
//查询过期日期
- (NSString *)searchExpireDate:(NSString *)idToken;
//是否过期
- (BOOL)isExpiredIdToken:(NSString *)idToken;
//更新OR插入用户选择的支付方式
- (void)addUser:(NSString *)idpid selectChannelID:(NSString *)channelID channel:(NSString *)channel;
- (NSString *)fetchUserSelectPayChannelIdByIdpid:(NSString *)idpid;
- (void)clearDB;
- (void)delDB ;
@end
