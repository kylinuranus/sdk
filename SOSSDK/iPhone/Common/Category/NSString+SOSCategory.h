//
//  NSString+SOSCategory.h
//  Onstar
//
//  Created by TaoLiang on 2017/12/15.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SOSCategory)
+ (NSString *)maskNickName:(NSString *)nickName;
- (NSURL *)makeNSUrlFromString;
/**
 uName敏感隐藏
 
 @param uname
 @return 隐藏后用户uname
 */
- (NSString *)maskedUserName;
/**
 如果字符串是空则返回未登录
 @return 返回处理后字符串
 */
- (NSString *)ifStringNilReturnUnloginString;


/**
 pin码判断

 @return 是否是合法的pin码
 */
- (BOOL)isLegalPinCode;


/**
 合法座机号

 @return
 */
- (BOOL)isValidateTel;


/// 返回常规字符(字母数字英文)
- (NSString *)regularChar;

@end
