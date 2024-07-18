
//
//  SOSKeyChainManager.m
//  keyChain
//
//  Created by Gennie Sun on 15/6/30.
//  Copyright (c) 2015年 Gennie Sun. All rights reserved.
//

#import "SOSKeyChainManager.h"

@implementation SOSKeyChainManager

static NSString * const KEY_SAVEFINGER_IDPID        = @"saveFingerPrintOpenByidpid";
static NSString * const KEY_SAVE_ID_TOKEN           = @"com.shanghaionstar.onstar.saveidtoken";
static NSString * const KEY_SAVE_PIN_CODE           = @"com.shanghaionstar.onstar.pincode";
static NSString * const KEY_SAVE_UserName_password  = @"com.shanghaionstar.onstar.Login";


+ (void)saveFingerprintOpenByidpid:(NSString *)idpid withSwitch:(BOOL)switchValue {
    NSMutableDictionary *dic = (NSMutableDictionary *)[SOSkeyChain load:KEY_SAVEFINGER_IDPID];
    dic = dic ? dic : [NSMutableDictionary dictionary];
    NSMutableDictionary *sourceDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    [sourceDic setObject:@(switchValue) forKey:idpid];
    [SOSkeyChain save:KEY_SAVEFINGER_IDPID data:sourceDic];
}

+ (id)readFingerPrint:(NSString *)idpid {
    NSMutableDictionary *readFingerPrint = (NSMutableDictionary *)[SOSkeyChain load:KEY_SAVEFINGER_IDPID];
    return [readFingerPrint objectForKey:idpid];
}

+ (void)clearFingerPrint {
    [SOSkeyChain delete:KEY_SAVEFINGER_IDPID];
}

+ (void)saveIdToken:(NSString *)idToken withScope:(NSString *)scope {
    NSMutableDictionary *loginDict = [NSMutableDictionary dictionary];
    [loginDict setObject:idToken forKey:KEY_LOGIN_ID_TOKEN];
    [loginDict setObject:scope forKey:KEY_LOGIN_SCOPE];
    [SOSkeyChain save:KEY_SAVE_ID_TOKEN data:loginDict];
}

+ (NSDictionary *)readLoginTokenScope     {
    NSDictionary *tokenDict = (NSDictionary *)[SOSkeyChain load:KEY_SAVE_ID_TOKEN];
    return tokenDict;
}

+ (void)clearLoginTokenScop     {
    NSLog(@"warnning --------------------/ ///////// clearLoginTokenScop");
    [SOSkeyChain delete:KEY_SAVE_ID_TOKEN];
}

+ (void)savePinCode:(NSString *)pincode forIdpid:(NSString *)idpid     {
    if (pincode == nil || idpid == nil) {
        return;
    }
    NSMutableDictionary *dic = (NSMutableDictionary *)[SOSkeyChain load:KEY_SAVE_PIN_CODE];
    dic = dic ? dic : [NSMutableDictionary dictionary];
    NSMutableDictionary *sourceDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    [sourceDic setObject:pincode forKey:idpid];
    [SOSkeyChain save:KEY_SAVE_PIN_CODE data:sourceDic];
}

+ (NSString *)loadCachedPinCode:(NSString *)idpid     {
    NSMutableDictionary *pinCodeDict = (NSMutableDictionary *)[SOSkeyChain load:KEY_SAVE_PIN_CODE];
    return [pinCodeDict objectForKey:idpid];
}

+ (void) saveLoginUserName:(NSString *)phoneNo andPassword:(NSString *)pwd withEamil:(NSString *)eamil withIdpid:(NSString *)idpid owner:(BOOL)flg
{
    NSMutableDictionary *dic = (NSMutableDictionary *)[SOSkeyChain load:KEY_SAVE_PIN_CODE];
    dic = dic ? dic : [NSMutableDictionary dictionary];

    NSMutableDictionary *sourceDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    NSMutableArray *muArr = [[NSMutableArray alloc] init];
    [muArr addObject:pwd];
    [muArr addObject:idpid];
    [muArr addObject:[NSNumber numberWithBool:flg]];
    
    if (![Util isBlankString:phoneNo]) {
        [sourceDic setObject:muArr forKey:phoneNo];
    }
    if (![Util isBlankString:eamil]) {
        [sourceDic setObject:muArr forKey:[eamil uppercaseString]];
    }
    
    if (![Util isBlankString:idpid]) {
        [sourceDic setObject:muArr forKey:[idpid uppercaseString]];
    }
    NSString *aesString = [SOSUtil AES128EncryptString:sourceDic.mj_JSONString];
    [SOSkeyChain save:KEY_SAVE_UserName_password data:aesString];
}

+ (NSDictionary *)readAesDic {
    NSString *obj = [SOSkeyChain loadOriginalObject:KEY_SAVE_UserName_password];
    if (!obj) {
        return @{};
    }
    id jsonDic = obj.mj_JSONObject;
    if (jsonDic) {
        return jsonDic;
    }
    NSString *dicJson = [SOSUtil AES128DecryptString:obj];
    if (dicJson) {
        return dicJson.mj_JSONObject;
    }
    return @{};
}



+ (NSString *) readidpid:(NSString *)userName
{
    NSMutableDictionary *loginDict = [self readAesDic];
    return [loginDict objectForKey:[userName uppercaseString]][1];
}

+ (NSString *) readPassword:(NSString *)userName
{
    NSMutableDictionary *loginDict = [self readAesDic];
    return [loginDict objectForKey:[userName uppercaseString]][0];
}

+ (BOOL) readUserWithOwner:(NSString *)userName
{
    NSMutableDictionary *loginDict = [self readAesDic];
    return [[loginDict objectForKey:[userName uppercaseString]][2] boolValue];
}

+ (void) clearLoginuserNameAndPassword
{
    [SOSkeyChain delete:KEY_SAVE_UserName_password];
}
@end
