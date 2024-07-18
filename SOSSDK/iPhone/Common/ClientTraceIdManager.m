//
//  ClientTraceIdManager.m
//  Onstar
//
//  Created by Apple on 17/3/8.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "ClientTraceIdManager.h"

@implementation ClientTraceIdManager

+ (ClientTraceIdManager *)sharedInstance
{
    static ClientTraceIdManager *sharedOBJ = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedOBJ = [self new];
        [sharedOBJ resetClientTraceId];
    });
    return sharedOBJ;
}

//客户端trace_id，用于http header字段：CLIENT-TRACE-ID
- (void)resetClientTraceId
{
    // idpid为登录用户id，如果用户未登录，取值为“blank”
    NSString *idpid = @"blank";
    if ([[LoginManage sharedInstance] isLoadingTokenReady] && !IsStrEmpty([CustomerInfo sharedInstance].userBasicInfo.idpUserId))
    {
        idpid = [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
    }
    _UUIDidpid = [NSString stringWithFormat:@"%@|%@",[NSUUID UUID].UUIDString, idpid];
}

- (NSString *)clientTraceId
{
    //timestamp为时间戳，采用unix时间的十六进制表示
    NSString *timestamp = [self hexConversionFrom10To16:[NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]*1000].longLongValue];
    return [NSString stringWithFormat:@"%@|%@",_UUIDidpid, timestamp];
}

//十进制---->十六进制
- (NSString *)hexConversionFrom10To16:(long long int) num
{
    NSString * result = [NSString stringWithFormat:@"%llx",num];
    //NSLog(@"十进制: %@ , 十六进制: %@", @(num),result.uppercaseString);
    return [result uppercaseString];
}

@end
