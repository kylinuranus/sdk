//
//  SOSKeyChainManager.h
//  keyChain
//
//  Created by Gennie Sun on 15/6/30.
//  Copyright (c) 2015年 Gennie Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSkeyChain.h"

static NSString * const KEY_LOGIN_ID_TOKEN          = @"com.shanghaionstar.onstar.login.idtoken";
static NSString * const KEY_LOGIN_SCOPE             = @"com.shanghaionstar.onstar.login.scope";

@interface SOSKeyChainManager : NSObject

/**
 *  @brief 根据idpid存储指纹状态
 */
+ (void) saveFingerprintOpenByidpid:(NSString *)idpid withSwitch:(BOOL)switchValue;

/**
 *   @brief 根据idpid读取指纹状态
 */
+ (id) readFingerPrint:(NSString *)idpid;

/**
 *  删除应用后第一次开启app，清除指纹
 */
+ (void) clearFingerPrint;

/**
 *   @brief 保存登录的id_token
 */
+ (void)saveIdToken:(NSString *)idToken withScope:(NSString *)scope;

/**
 *   @brief 读取id_token
 */
+ (NSDictionary *)readLoginTokenScope;
+ (void)clearLoginTokenScop;

+ (void)savePinCode:(NSString *)pincode forIdpid:(NSString *)idpid;
+ (NSString *)loadCachedPinCode:(NSString *)idpid;


///保存密码 用户名 idpid eamail 到keychain
+ (void) saveLoginUserName:(NSString *)phoneNo andPassword:(NSString *)pwd withEamil:(NSString *)eamil withIdpid:(NSString *)idpid owner:(BOOL)flg;
///根据用户名读取idpid
+ (NSString *) readidpid:(NSString *)userName;
///根据用户名读取密码
+ (NSString *) readPassword:(NSString *)userName;
///根据用户名读取是否是车主
+ (BOOL) readUserWithOwner:(NSString *)userName;
///清除登录密码用户名相关信息
+ (void) clearLoginuserNameAndPassword;
@end
