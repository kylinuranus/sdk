//
//  NetRepository.m
//  Onstar
//
//  Created by 梁元 on 2022/12/14.
//  Copyright © 2022 Shanghai Onstar. All rights reserved.
//

#import "SOSNetRepository.h"
#import "SOSTrackEvent.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "SOSNetworkOperation.h"
#import "SOSTrackConfig.h"
#import <MJExtension/MJExtension.h>
#import <YYKit/YYKit.h>
#import "NSData+YYAdd.h"

 

@interface SOSNetRepository(){
    
    SOSTrackConfig *_configRef;
}

 

@end

@implementation SOSNetRepository

+ (SOSNetRepository *)sharedInstance
{
    static SOSNetRepository *sharedOBJ = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedOBJ = [[self alloc] init];
        
    });
    return sharedOBJ;
}

-(NSString *)getNetType
{
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    NSString *currentStatus = info.currentRadioAccessTechnology;
    NSString *currentNet = @"5G";
    
    if ([currentStatus isEqualToString:CTRadioAccessTechnologyGPRS]) {
        currentNet = @"GPRS";
    }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyEdge]) {
        currentNet = @"2.75G EDGE";
    }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyWCDMA]){
        currentNet = @"3G";
    }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyHSDPA]){
        currentNet = @"3.5G HSDPA";
    }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyHSUPA]){
        currentNet = @"3.5G HSUPA";
    }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMA1x]){
        currentNet = @"2G";
    }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]){
        currentNet = @"3G";
    }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]){
        currentNet = @"3G";
    }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]){
        currentNet = @"3G";
    }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyeHRPD]){
        currentNet = @"HRPD";
    }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyLTE]){
        currentNet = @"4G";
    }else {
        currentNet = @"5G";
    }
    return currentNet;

}
 


-(void) setConfig:(SOSTrackConfig*)config{
    
    _configRef=config;
    
}
 

-(void)upload:(NSArray*)dataArray
      success:(void(^)(void) ) success
       failure:(void(^)(NSInteger statusCode, NSString *responseStr)) failure{
    
    
    
    
    
    NSMutableArray *recordsArray=[NSMutableArray new];
    
    for (SOSTrackEvent *model in  dataArray) {
        
     
        if(model){
            
            NSMutableDictionary *valueDic=[NSMutableDictionary new];
            [valueDic setObject:model.d.mj_JSONObject?model.d.mj_JSONObject:@"" forKey:@"d"];
            [valueDic setObject:model.mid forKey:@"mid"];
            [valueDic setObject:model.did forKey:@"did"];
            [valueDic setObject:model.aid forKey:@"aid"];
            [valueDic setObject:model.sid forKey:@"sid"];
            [valueDic setObject:model.sVid  forKey:@"svid"];
            [valueDic setObject:model.ts forKey:@"ts"];
            
            NSMutableDictionary *records=[NSMutableDictionary new];
            [records setObject:valueDic forKey:@"value"];
            
            [recordsArray addObject:records];
            
        }
        
        
    }
 
    
    NSString *url =@"https://sosmapp.collector.sgmlink.com:8443/dcp/v1/message";
    if(_configRef.isDebug){
     
        url = [NSString stringWithFormat:@"%@", @"https://qa-default.collector.sgmlink.com:8443/dcp/v1/message"];
      // url = [NSString stringWithFormat:@"%@", @"https://collector-qa.sgmlink.com:8443/dcp/v1/message"];
    }

 
    NSMutableDictionary *rootDic=[NSMutableDictionary new];
    [rootDic setObject:recordsArray forKey:@"records"];
    
 
     NSData *jsonDataGzip =[[rootDic mj_JSONData] gzipDeflate];
 

    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url
                                                                  params:rootDic.mj_JSONString
                                                            successBlock:^(SOSNetworkOperation *operation, id responseStr) {
      
      
        
      NSDictionary *dic=[responseStr mj_JSONObject];
        if([dic[@"status"] isEqualToString:@"20000"]){
            
            NSLog(@"埋点接口成功=%@",responseStr);
            success();
            
        }else{
            
            NSLog(@"埋点接口失败=%@",responseStr);
            failure([dic[@"status"] intValue],dic[@"statusMessage"]);
        }
      
      
        
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        
        NSLog(@"埋点接口失败=%@",responseStr);
        failure(statusCode,responseStr);
    }];
    
    NSData *base64Data= [[NSString stringWithFormat:@"%@:%@",_configRef.userAccount,_configRef.pwd]  dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Str = [base64Data base64EncodedStringWithOptions:0];
    
    NSString *authorization=[NSString stringWithFormat:@"Basic %@",base64Str];
    

    NSLog(@"埋点接口-body=%@",  [[NSString alloc] initWithData:[jsonDataGzip gzipInflate] encoding:NSUTF8StringEncoding]);

    NSString *did= recordsArray[0][@"value"][@"did"];
 
    
   NSDictionary *head= @{
        
        @"Authorization": authorization,
        @"RequestId":[self getUUid],
        @"Content-md5": rootDic.mj_JSONString.md5String?rootDic.mj_JSONString.md5String:@"",
        @"x-user-param2":_configRef.projectId,
        @"x-user-param1":did?did:@"",
        @"Content-Type":@"application/json",
        @"Content-Encoding":@"gzip",
        @"Accept":@"application/vnd.kafka.v2+json"
        
   };
    [operation setHttpHeaders:head];
    
    NSLog(@"埋点接口-头部=%@", head);

    
    [operation setHttpbody2:jsonDataGzip];
   // [operation setHttpbody:rootDic];
    
    [operation setHttpMethod:@"POST"];
    [operation start];
    

}

-(NSString*)getUUid {
    
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);

    NSString *  deviceID = (__bridge NSString*)string;
    return deviceID;
}
 
@end
