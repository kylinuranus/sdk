//
//  NSString+JWT.m
//  Onstar
//
//  Created by Joshua on 15/10/8.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import "NSString+JWT.h"
#import "Base64.h"

#import <CommonCrypto/CommonHMAC.h>

#import <Foundation/Foundation.h>

@implementation NSString (JWT)

//- (void)jwt
//{
//    
//    [self jwtEncode];
//    
//    
//    NSString *responseString = @"eyJ0eXAiOiJKV1QiLA0KICJhbGciOiJIUzI1NiJ9.ew0KImFjY2Vzc190b2tlbiI6ImZkYTExMzg3LWNlZDgtNGFjYi1hZTBiLTBiYWYxZDkyNjYwMyIsDQogICJ0b2tlbl90eXBlIjoiQmVhcmVyIiwNCiAgImV4cGlyZXNfaW4iOjE4MDAsDQogICJzY29wZSI6Im9uc3RhciBtc3NvIHJvbGVfb3duZXIiLA0KICAib25zdGFyX2FjY291bnRfaW5mbyI6eyJhY2NvdW50X25vIjoiMTIwMTc2MTQzMCIsDQogICAgICAiY291bnRyeV9jb2RlIjogIkNOIn0NCn0.LBXjKVfjQJZtHEP1y4XcIRUQYszyUSB0nhQF2tCXIfY";
//    
//    NSString *tmpStr = [NSString jwtDecode:responseString];
//    
//}


+ (NSString *)jwtDecode :(NSString *)response     {
    
    NSString *result = NULL;
    
    NSArray *base64StringArray = [response componentsSeparatedByString:@"."];
    
    if ([base64StringArray count] >= 2) {
        
//        NSLog(@"decode body %@", base64StringArray[1]);
        
        NSData *resultData = [Base64 webSafeDecodeString:base64StringArray[1]];
        
        result = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
        
//        NSLog(@"jwt decode string %@", result);
        
    }
    return result;
    
}

+ (NSString *)jwtEncode:(NSString *)inputString     {
    
    NSString * sourceHeader = @"{\"alg\":\"HS256\",\"typ\":\"JWT\"}";
    
    NSString * sourceBody = inputString;
    
    NSData *dataHeader = [sourceHeader dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *dataBody = [sourceBody mj_JSONData];
    
    NSString * base64Header = [Base64 stringByWebSafeEncodingData:dataHeader padded:NO];
    
    NSString * base64Body = [Base64 stringByWebSafeEncodingData:dataBody padded:NO];
    
    NSString *key = @"54LykSZ69KkCfaYHCxJu";
    
    NSString *data = [NSString stringWithFormat:@"%@.%@", base64Header, base64Body];
    
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
                    
                                          length:sizeof(cHMAC)];
    
    //    NSString *hash = [HMAC base64Encoding]; //This line doesn´t make sense
    
    NSString *hash = [Base64 stringByWebSafeEncodingData:HMAC padded:NO]; //This line doesn´t make sense
    
    //    NSLog(@"hash, %@", hash);
    
    NSString *result = [NSString stringWithFormat:@"%@.%@.%@", base64Header, base64Body, hash];
    
    //    NSLog(@"jwt encode string : %@", result);
    
    return result;
}

- (BOOL)myContainsString:(NSString*)other {
    NSRange range = [self rangeOfString:other];
    return range.length != 0;
}

#pragma mark 对用户敏感信息进行截断处理: 规则---前3****后4
- (NSString *)stringInterceptionHide    {
    if (self.length<=7) return self;

    NSMutableString *result = [NSMutableString string];
    [result appendString:[self substringToIndex:3]];

    NSInteger starNum = self.length-7;
    for (NSInteger i=0; i<starNum; i++) {
        [result appendString:@"*"];
    }
    [result appendString:[self substringFromIndex:self.length-4]];
    return result;
}

- (NSString *)stringInterceptionHideSix    {
    if (self.length<=7) return self;
    
    NSMutableString *result = [NSMutableString string];
    [result appendString:[self substringToIndex:3]];
    
    NSInteger starNum = 6;
    for (NSInteger i=0; i<starNum; i++) {
        [result appendString:@"*"];
    }
    [result appendString:[self substringFromIndex:self.length-4]];
    return result;
}

#pragma mark - 对身份证信息隐藏：规则--隐藏前6位和后4位
- (NSString *)govidStringInterceptionHide;
{
    if (self.length<=10){
        NSMutableString *result = [NSMutableString string];
        NSInteger starNum = self.length;
        for (NSInteger i=0; i<starNum; i++) {
            [result appendString:@"*"];
        }
        return result;
        
    }
    else{
        NSMutableString *result = [NSMutableString stringWithString:self];
        
        [result replaceCharactersInRange:NSMakeRange(0, 6) withString:@"******"];
        
        [result replaceCharactersInRange:NSMakeRange(self.length - 4, 4) withString:@"****"];
        return result;
    }
}
#pragma mark - 对地址信息隐藏：地址中的数字隐藏
- (NSString *)addressStringInterceptionHide;
{
    
    NSString *strippedBbox = [self stringByReplacingOccurrencesOfString:@"[0-9]" withString:@"*" options:NSRegularExpressionSearch range:NSMakeRange(0, [self length])];
    return strippedBbox;
}
//若邮箱中“@”之前的字符数大于3位，则隐藏“@”的前3位。如Aa***@126.com
//若邮箱中“@”之前的字符数小于等于3位，则隐藏“@”的前1位。如 *@126.com / A*@126.com / Aa*@126.com
- (NSString *)stringEmailInterceptionHide
{
    if(![self myContainsString:@"@"])return self;

    NSMutableString *result = [NSMutableString string];
    NSRange range = [self rangeOfString:@"@"];
    NSInteger location = range.location;

    if (location<=3)
    {
        NSInteger starNum = location-1;
        [result appendString:[self substringToIndex:starNum]];
        [result appendString:@"*"];
    }
    else
    {
        NSInteger starNum = location-3;
        [result appendString:[self substringToIndex:starNum]];
        [result appendString:@"***"];
    }
    [result appendString:[self substringFromIndex:location]];
    return result;
}
- (NSString *)stringSepFirstName;
{
    //姓名取出姓
    switch (self.length) {
        case 2:
            return [self substringToIndex:1];
            break;
        case 3:
            return [self substringToIndex:1];
            break;
        case 4:
            return [self substringToIndex:2];
            break;

        default:
            return self;
            break;
    }
}
- (NSString *)stringSepLastName;
{
    //姓名取出名
    switch (self.length) {
        case 2:
            return [self substringFromIndex:1];
            break;
        case 3:
            return [self substringFromIndex:1];
            break;
        case 4:
            return [self substringFromIndex:2];
            break;
            
        default:
            return self;
            break;
    }
}

//如果输入少于6位，或大于25位，则提示xxx――需要BO提示话术
//话术：“输入的值与正确表达不匹配”
//如果输入6位至14位，或以汉字开头，则认为是其他证件号，引导去注册手机应用
//如果输入15位至24位，前10位都是数字则认为是身份证，如果是其他，则按照VIN号的逻辑处理
/**
 6-25位， 用于注册的证件号
 @return
 */
- (BOOL)isValidateRegisterIdentification
{
    return self.length >= 6 && self.length < 26;
    //可支持6~25位数字、字母或汉字，但不支持特殊字符
}

/**
15-24位,VIN或idcard
 @return
 */
- (BOOL)isValidateRegisterVINOrIDCard
{
    NSString * regex = @"[^\u4e00-\u9fa5]+";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        return self.length>14 && self.length<26 && [pred evaluateWithObject:self];
}

- (BOOL)isValidateIDCard    {
    NSString * regex = @"^[0-9]{10}.{5,15}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:self];
}
- (BOOL)isValidateVIN       {
    return [self isValidateRegisterVINOrIDCard]&&![self isValidateIDCard];
}


@end
