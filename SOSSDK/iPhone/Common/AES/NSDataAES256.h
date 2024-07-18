//
//  NSDataAES256.h
//  Onstar
//
//  Created by Alfred Jin on 3/5/11.
//  Copyright 2011 plenware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSData (AESAdditions)
- (NSData *)AES256EncryptWithKey:(NSString *)key;
- (NSData*)AES256DecryptWithKey:(NSString*)key;
+ (id)dataWithBase64EncodedString:(NSString *)string;
- (NSString *)base64Encoding;


/**
 *  加密
 *
 *  @param key 公钥
 *  @param iv  偏移量
 *
 *  @return 加密之后的NSData
 */
- (NSData *)AES128EncryptWithKey:(NSString *)key iv:(NSString *)iv;
/**
 *  解密
 *
 *  @param key 公钥
 *  @param iv  偏移量
 *
 *  @return 解密之后的NSData
 */
- (NSData *)AES128DecryptWithKey:(NSString *)key iv:(NSString *)iv;
@end
