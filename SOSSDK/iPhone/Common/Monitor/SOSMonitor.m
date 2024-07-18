//
//  SOSMonitor.m
//  Onstar
//
//  Created by WQ on 2018/12/11.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSMonitor.h"
#import "SOSIPAddress.h"
#import "ClientTraceIdManager.h"
#import "SOSUserLocation.h"

#define NORMALDIC  @[[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin,\
[CustomerInfo sharedInstance].userBasicInfo.idpUserId],\
[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId]


@interface SOSMonitorObject : NSObject
@end

@implementation SOSMonitorObject
@end

@interface SOSMonitor ()
@property(nonatomic,retain)NSArray *test;

@end

@implementation SOSMonitor
{
    dispatch_source_t timer;
    NSString *localIP;
    NSString *lon;
    NSString *lat;
    NSString *uuid;
    double startTime;
    double endTime;
    NSArray *basePara;
    NSArray *baseArr;
    NSArray *noSendArr;           //存放b无需监控的接口数组
    //    NSDictionary *urldic;
    NSMutableDictionary *baseParaDic;
    NSMutableDictionary *monitorDic;
    
}




static SOSMonitor * _instance = nil;

+ (SOSMonitor *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[SOSMonitor alloc] init];
        _instance.method = @"";
        _instance.url = @"";
        _instance.wifi = NO;
        [_instance generateBasePara];
        [_instance addNetWorkObserver];
    });
    return _instance;
}

-(void)generateBasePara
{
    basePara = @[@"{vin}",@"{userId}",@"{accountId}"];
    baseParaDic = [NSMutableDictionary dictionary];
    monitorDic = [NSMutableDictionary dictionary];
    localIP = [SOSIPAddress getIPAddress:YES];
    uuid = [SOSDaapManager getUUID];
    //[_instance getLocation];    //暂不自己获取位置
    //    urldic = @{@"https://api-idt1.shanghaionstar.com":@"1443",
    //               @"https://api.shanghaionstar.com":@"443",
    //               @"https://api-idt4.shanghaionstar.com":@"4443",
    //               @"https://api-pp2.shanghaionstar.com":@"13443",
    //               @"https://api-idt5.shanghaionstar.com":@"7443",
    //               @"https://api-vv2.shanghaionstar.com":@"9443",
    //               @"https://api-pp1.shanghaionstar.com":@"12443",
    //               @"https://api-vv1.shanghaionstar.com":@"6443",
    //               @"https://api-idt7.shanghaionstar.com":@"443",
    //               @"https://api-pp3.shanghaionstar.com":@"34443",
    //               @"https://api-pp4.shanghaionstar.com":@"443",
    //               @"https://api-t.shanghaionstar.com":@"443",
    //               @"https://api-r1.shanghaionstar.com":@"443",
    //               @"https://api-idt10.shanghaionstar.com":@"443",
    //               @"https://api-sit-idt7.shanghaionstar.com":@"20426",
    //               @"https://api-sit-idt10.shanghaionstar.com":@"20426",
    //               @"https://api-pp5.shanghaionstar.com":@"443",
    //               @"https://api-reh.shanghaionstar.com":@"443",
    //               @"https://api-idt8.shanghaionstar.com":@"443",
    //               @"https://api-vv4.shanghaionstar.com":@"443"
    //               };
    noSendArr = @[MA8_2_OLD_DAAP_REPORT,MA8_2_DAAP_CLIENT_INFO,MA8_2_DAAP_ACTION_INFO,MA8_2_DAAP_SYS,SOSMonitorURL,@"10.216.146.58"];
}


-(void)addNetWorkObserver
{
    [[NSNotificationCenter defaultCenter] addObserverForName:@"netWorkWiFi" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        _instance.wifi = [note.object boolValue];
        
    }];
}

-(void)generateBaseArr
{
    baseArr = @[[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin,
                [CustomerInfo sharedInstance].userBasicInfo.idpUserId,
                [CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId];
    baseParaDic[[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin] = @"{vin}";
    baseParaDic[[CustomerInfo sharedInstance].userBasicInfo.idpUserId] = @"{userId}";
    baseParaDic[[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId] = @"{accountId}";
    
}

-(void)generateBaseArrWithNoVin		{
    baseArr = @[[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
    baseParaDic[[CustomerInfo sharedInstance].userBasicInfo.idpUserId] = @"{userId}";
    
}


-(void)startCount
{
    startTime = CACurrentMediaTime();
}


-(void)endCount
{
    endTime = CACurrentMediaTime();
}


-(double)getInterval
{
    _interval = endTime - startTime;
    startTime = 0.0;
    endTime = 0.0;
    return _interval;
}


-(NSString*)getResponeInterval
{
    _interval = endTime - startTime;
    startTime = 0.0;
    endTime = 0.0;
    _interval = _interval *1000000;
    NSInteger n = _interval;
    return [NSString stringWithFormat:@"%ld",(long)n];
}


-(BOOL)needNotToSend:(NSString*)url
{
    __block BOOL flag = NO;
    [noSendArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *s = (NSString*)obj;
        if ([url containsString:s]) {
            flag = YES;
            *stop = YES;
        }
    }];
    return flag;
}


-(void)sendMonitorInfo:(NSString*)urlStr ResultCode:(NSString*)code spanId:(NSString *)spanId responseInterval:(NSString*)rspInterval;
{
    //NSLog(@"sendMonitorInfo  responseId is %ld",rid)
    if ([_instance needNotToSend:urlStr]) {
        //屏蔽高频无意义 Log
        //        NSLog(@"======== no monitor =======%@",urlStr);
        return;
    }
#ifndef DEBUG
#ifdef SOSSDK_SDK
    //SDK去除测试环境的zipKin 直接屏蔽吧
//    if ([SOSEnvConfig config].sos_env != 2) {
        return;
//    }
#endif
    NSArray *arr = [_instance getMonitorDic:urlStr spanID:spanId ResultCode:code interval:rspInterval ];
    NSString *s = [_instance jsonFromArr:arr];
    NSString *url = [SOSEnvConfig config].sos_env == 2 ? @"https://www.onstar.com.cn/zipkin/api/v2/spans" : @"https://idt7.onstar.com.cn/zipkin/api/v2/spans";
    SOSNetworkOperation* sosOperation = [[SOSNetworkOperation alloc] initWithURL:url params:s enableLog:NO needReturnSourceData:NO needSSLPolicyWithCer:YES cacheConfig:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        
        
    }];
    
    [sosOperation setHttpMethod:@"POST"];
    [sosOperation setHttpHeaders:@{@"Channel":@"onstarapp",@"Authorization":@"Basic YXBwbW9uaXRvcjpzb3Ntb2JpbGUxMjM="}];
    [sosOperation start];
#endif
}


-(NSArray*)getMonitorDic:(NSString*)url spanID:(NSString *)spID ResultCode:(NSString*)code interval:(NSString*)responeInterval
{
    //NSLog(@"url is %@",url);
    
    monitorDic[@"traceId"] = spID;
    monitorDic[@"name"] = [url stringByReplacingOccurrencesOfString:[Util getConfigureURL] withString:@""];
    monitorDic[@"id"] = monitorDic[@"traceId"];
    monitorDic[@"kind"] = @"SERVER";
    monitorDic[@"timestamp"] = [_instance getTimestamp];
    monitorDic[@"duration"] = responeInterval;
    monitorDic[@"shared"] = [NSNumber numberWithBool:YES];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"serviceName"] = @"app-ios";
    dic[@"ipv4"] = localIP;
    dic[@"port"] = @"20000";
    monitorDic[@"localEndpoint"] = dic;
    
    NSMutableDictionary *tags = [NSMutableDictionary dictionary];
    tags[@"uuid"] = uuid;
    tags[@"userId"] = [CustomerInfo sharedInstance].userBasicInfo.idpUserId ? [CustomerInfo sharedInstance].userBasicInfo.idpUserId : @"";
    tags[@"http.status_code"] = code;
    tags[@"http.method"] =  _instance.method;
    tags[@"http.path"] = [self getPath:url];
    lon = NONil(((SOSPOI *)[[CustomerInfo sharedInstance] currentPositionPoi]).longitude);
    lat = NONil(((SOSPOI *)[[CustomerInfo sharedInstance] currentPositionPoi]).latitude);
    NSString *locStr = [NSString stringWithFormat:@"%@,%@",lat,lon];
    if (![locStr isEqualToString:@","]) {
        tags[@"location"] = locStr;
    }
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    tags[@"app.version"] = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    //    tags[@"wifi"] = [NSNumber numberWithBool:_instance.wifi];
    tags[@"wifi"] = _instance.wifi ? @"true" : @"false";
    monitorDic[@"tags"] = tags;
    
    return @[monitorDic];
}

-(NSString*)getFullName:(NSString*)url
{
    __block NSString *tempStr = url;
    [baseArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *s = (NSString*)obj;
        if ([url containsString:s]) {
            NSString *paraStr = baseParaDic[s];
            tempStr = [tempStr stringByReplacingOccurrencesOfString:s withString:paraStr];
        }
    }];
    tempStr = [self OtherStep:tempStr];
    if ([tempStr containsString:@"rvm"]) {
        tempStr = [self doWithMirrorUrl:tempStr];
    }
    //屏蔽高频无意义 Log
    //    NSLog(@"tempStr is %@",tempStr);
    return tempStr;
}

-(NSString*)getPath:(NSString*)url
{
    NSString *path = [url stringByReplacingOccurrencesOfString:[Util getConfigureURL] withString:@""];
    NSArray <NSString *>*arr = [path componentsSeparatedByString:@"?"];
    if (arr.count > 0) {
        return arr[0];
    }
    return path;
}


//处理问号之后的参数
-(NSString*)OtherStep:(NSString*)url
{
    NSString *str = url;
    NSArray <NSString*>*arr = [str componentsSeparatedByString:@"?"];
    if (arr.count > 1) {//没问号会将整个字符串放入数组，因此需大于1
        NSString *tempStr = [self doWithOtherPara:arr];
        NSString *lastStr = [NSString stringWithFormat:@"?%@",tempStr];
        return [arr[0] stringByAppendingString:lastStr];
    }else
    {
        return url;
    }
}


-(NSString*)doWithOtherPara:(NSArray*)arr
{
    NSArray <NSString*>*subArr01 = [arr[1] componentsSeparatedByString:@"&"];
    __block NSMutableArray *paraAll = [NSMutableArray array];
    [subArr01 enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *arr = [(NSString*)obj componentsSeparatedByString:@"="];
        NSString *s = [NSString stringWithFormat:@"{%@}",arr[0]];
        NSString *s01 = [NSString stringWithFormat:@"%@=%@",arr[0],s];
        [paraAll addObject:s01];
    }];
    
    __block NSString *tempStr = @"";
    [paraAll enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *s = [NSString stringWithFormat:@"%@&",(NSString*)obj];
        tempStr = [tempStr stringByAppendingString:s];
        //NSLog(@"temp str is %@",tempStr);
    }];
    tempStr = [tempStr substringToIndex:tempStr.length-1];
    //NSLog(@"temp str is %@",tempStr);
    
    //NSString *fullStr = [arr[0] stringByAppendingString:[NSString stringWithFormat:@"?%@",tempStr]];
    //NSLog(@"full str is %@",fullStr);
    return tempStr;
}


-(NSString*)doWithMirrorUrl:(NSString*)url
{
    __block NSMutableArray *tempArr = [NSMutableArray array];
    NSArray <NSString*>*arr = [url componentsSeparatedByString:@"/"];
    [arr enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *s = (NSString*)obj;
        s = [NSString stringWithFormat:@"%@/",s];
        if (![s containsString:@"."] && s.length == 23) {
            s = [s stringByReplacingCharactersInRange:NSMakeRange(0, obj.length) withString:@"{deviceId}"];
        }
        [tempArr addObject:s];
    }];
    
    __block NSString *tempStr = @"";
    [tempArr enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        tempStr = [tempStr stringByAppendingString:obj];
    }];
    //屏蔽高频无意义 Log
    //    NSLog(@" rvm str is %@",tempStr);
    
    return tempStr;
}

-(NSString*)getTimestamp
{
    NSDate *date = [NSDate date];
    long dateTime1 = [date timeIntervalSince1970]*1000*1000;
    NSString *timeSp = [NSString stringWithFormat:@"%ld",dateTime1];
    return timeSp;
}

-(NSString *)getOpenIP
{
    NSError *error;
    NSURL *ipURL = [NSURL URLWithString:@"http://ipof.in/txt"];
    NSString *ip = [NSString stringWithContentsOfURL:ipURL encoding:NSUTF8StringEncoding error:&error];
    return ip;
}



//-(NSString *)getPort:(NSString*)url
//{
//    __block NSString *str = @"443";
//    [urldic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//        NSString *s = (NSString*)key;
//        NSString *v = (NSString *)obj;
//        if ([url containsString:s]) {
//            str = v;
//            *stop = NO;
//        }
//    }];
//    return str;
//}

- (NSString *)jsonFromArr:(NSArray *)arr     {
    NSString *jsonStr;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arr options:NSJSONWritingPrettyPrinted error:&error];
    if (!jsonData) {
        return nil;
    } else {
        jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonStr;
}


-(NSString *)getTraceId
{
    NSString *traceId = [[NSUUID UUID] UUIDString];
    traceId = [traceId lowercaseString];
    traceId = [traceId stringByReplacingOccurrencesOfString:@"-" withString:@""];
    traceId = [traceId substringToIndex:16];
    return traceId;
}

+(NSString *)createTraceId{
    NSInteger random = 0;
    arc4random_buf(&random, sizeof(UInt64));
    NSString *result = [NSString stringWithFormat:@"%llx", (long long)random];
    if (result.length < 16) {
        NSInteger fill = 16 - result.length;
        for (int i=0; i<fill; i++) {
            result = [@"0" stringByAppendingString:result];

        }
    }    
    return result;
}


@end
