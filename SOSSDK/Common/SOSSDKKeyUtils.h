//
//  SOSSDKKeyUtils.h
//  Onstar
//
//  Created by onstar on 2019/3/26.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSSDKKeyUtils : NSObject
//微信
+ (NSString *)wxKey;
+ (NSString *)universalLink;

//高德
+ (NSString *)mapKey ;

//OCR
+ (NSString *)idCardKey ;

//美的
+ (NSString *)mdAppId ;
+ (NSString *)mdAppKey;
+ (NSInteger)mdAppSrc;



//网易云信
+ (NSString *)nimAppKey ;
+ (NSString *)nimCerName ;

//升级key
+ (NSString *)updateSecret ;





+ (NSString *)versionPrefix;

+ (NSString *)appVersion;

+ (NSString *)onstarVersion;

+ (NSString *)sdkWebSource ;

//需单独配置
+ (NSString *)paySchemeUrl ;
+ (NSString *)bleSchemeUrl ;


//极光
+ (NSString *)jpushAppKey;

+ (NSString *)buglyAppKey;
@end


NS_ASSUME_NONNULL_END
