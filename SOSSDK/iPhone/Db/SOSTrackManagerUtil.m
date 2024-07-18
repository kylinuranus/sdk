//
//  TrackManagerUtil.m
//  Onstar
//
//  Created by 梁元 on 2022/12/14.
//  Copyright © 2022 Shanghai Onstar. All rights reserved.
//

#import "SOSTrackManagerUtil.h"
#import "SOSTrackManager.h"
#import "SOSTrackConfig.h"
#import "SOSTrackEvent.h"
#import <UIKit/UIKit.h>
#import <MJExtension/MJExtension.h>
#import "SOSDaapManager.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "SOSIPAddress.h"
#import "SOSSDK.h"

static   NSString* MA_AID=@"A00000005";
static   NSString* MA_SID=@"S00000004";
static   NSString* MA_SVID=@"SV00000004";
static   NSString* MA_PASSWORD=@"e?T#3n*+";
static   NSString* MA_PROJECT_ID=@"SAAP_C0I56E94";


static   NSString*  MA_SELF_DEFINE_SID=@"S00000029";
static   NSString*  MA_SELF_DEFINE_SVID=@"SV00000043";


static   NSString*  MA_SELF_DEFINE_SID_TEST=@"S00000149";
static   NSString*  MA_SELF_DEFINE_SVID_TEST=@"SV00000216";


static   NSString *   MA_AID_TEST=@"A00000066";
static   NSString *   MA_SID_TEST=@"S00000048";
static   NSString *   MA_SVID_TEST=@"SV00000062";
static   NSString *   MA_PASSWORD_TEST=@"iZWylftC";
static   NSString *   MA_PROJECT_ID_TEST=@"SAAP_7GI8KH2O";

 


typedef NS_ENUM(NSInteger,UserType)
{
    idpuserId = 1,
    deviceId = 2,
    vin = 3,
    phoneNumber = 4,
};



@interface SOSTrackManagerUtil(){
    
    SOSTrackManager *_trackManagerRef;
    SOSTrackConfig *_configRef;
}
@end
@implementation SOSTrackManagerUtil

 
+ (SOSTrackManagerUtil *)sharedInstance
{
    static SOSTrackManagerUtil *sharedOBJ = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedOBJ = [[self alloc] init];
        
    });
    return sharedOBJ;
}

-(id) init{
    
 
    id myself=[super init];
    if(myself){
        
        _configRef=[[SOSTrackConfig alloc] init];
        
   
        if([SOSEnvConfig config].sos_env==SOSEnvDeveloperment){
            
            _configRef.isDebug=true;
        }else{
            
            _configRef.isDebug=false;
        }
    
        
    
        if(_configRef.isDebug){
            
            _configRef.aid=MA_AID_TEST;
            _configRef.sid=MA_SID_TEST;
            _configRef.svid=MA_SVID_TEST;
            _configRef.projectId=MA_PROJECT_ID_TEST;
            _configRef.userAccount= _configRef.aid;
            _configRef.pwd=MA_PASSWORD_TEST;
            
     
           
        }else{
            
            _configRef.aid=MA_AID;
            _configRef.sid=MA_SID;
            _configRef.svid=MA_SVID;
            _configRef.projectId=MA_PROJECT_ID;
            _configRef.userAccount=_configRef.aid;
            _configRef.pwd=MA_PASSWORD;
        }
        
        _configRef.countLimit=200;
        _configRef.timePeriod=3;
        
    
        _trackManagerRef = [SOSTrackManager sharedInstance];
       [_trackManagerRef initConfig:_configRef];
     
       
    }
    return  myself;
}

 

-(void) track:(NSString*) daapId
selfDefine:(NSDictionary*)  selfDefine
isImmediately:(bool) isImmediately{
    
 
    NSString *brandName=@"";
    if(SOS_BUICK_PRODUCT){

        brandName=@"oneapp_sdk_buick_";
    }
  else  if(SOS_CD_PRODUCT){

      brandName=@"oneapp_sdk_cd_";
    }
  else  if(SOS_MYCHEVY_PRODUCT){

      brandName=@"oneapp_sdk_xfl_";
  }
    
    NSLog(@"埋点brandName=%@",brandName);
    
    NSString *idpUserId= [CustomerInfo sharedInstance].userBasicInfo.idpUserId?[CustomerInfo sharedInstance].userBasicInfo.idpUserId:@"";
   // NSString *accountId= [CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId;
    
    NSDictionary *params = @{@"G1":[self getUUid],
                             @"G2": @"idpuserId",
                             @"G3": idpUserId,
                             @"G4":_configRef.projectId,
                             @"G5":@"ma",
                             @"G6":@"ios",
                             @"G7":@"oneapp",
                             @"G8":@"0.0.1",
                             @"G9":[UIApplication sharedApplication].appBundleID,
                             @"G10":APP_VERSION,
                             @"G11":@"ios",
                             @"G12": [UIDevice currentDevice].systemVersion,
                             @"G13":[Util getDevicePlatform],
                             @"G14":@"APP",
                             @"G15":@"0",
                             @"G16": [SOSDaapManager getScrrenResolution],
                             @"G17":[self getNetType],
                             @"G18":@"", //当前页面
                             @"G19":@"",//上一个页面
                             @"G20":@"",//目标页页面
                             @"G21":@"",//停留时长
                             @"G22":[NSString stringWithFormat:@"%@%@",brandName,daapId],
                             @"G23":@"act",
                             @"G24": [Util getPublicIP],
                             @"G25": [SOSIPAddress getIpv6],
                             };
    
    
    
    
   
    
    
    SOSTrackEvent *model=[[SOSTrackEvent alloc] init];
    model.id2=[self getId];
    model.isImmediately=isImmediately;
    model.mid=[self getUUid];
    model.did=   [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    model.aid=_configRef.aid;
    model.sid=_configRef.sid;
    model.sVid=_configRef.svid;
    model.ts= [self convertTimeInterval:[NSDate date].timeIntervalSince1970];
    model.d= params.mj_JSONString;
    [_trackManagerRef  track:model];
    
    
    //判断是否有参数
    if(selfDefine&&selfDefine.count>0){ //有参数就是自定义模板
            
        
        NSMutableDictionary *selfDefineMutable=[selfDefine mutableCopy];
        selfDefineMutable[@"G1"]= params[@"G1"];
        selfDefineMutable[@"G2"]=_configRef.projectId;
        selfDefineMutable[@"G111"]=[NSString stringWithFormat:@"%@%@",brandName,daapId];
        
        [selfDefineMutable removeObjectForKey:@"triggerPointId"];
  
        
        SOSTrackEvent *modelCustom=[[SOSTrackEvent alloc] init];
        modelCustom.id2=[self getId];
        modelCustom.isImmediately=isImmediately;
        modelCustom.mid=[self getUUid];
        modelCustom.did=   [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        modelCustom.aid=_configRef.aid;
        modelCustom.sid=_configRef.isDebug?MA_SELF_DEFINE_SID_TEST:MA_SELF_DEFINE_SID;
        modelCustom.sVid=_configRef.isDebug?MA_SELF_DEFINE_SVID_TEST:MA_SELF_DEFINE_SVID;
        modelCustom.ts= [self convertTimeInterval:[NSDate date].timeIntervalSince1970];
        modelCustom.d= selfDefineMutable.mj_JSONString;
        [_trackManagerRef  track:modelCustom];
    }
 
    
    
    
 
}


-(NSInteger) getId{
    
    //判断本地是否有这个id,没有这个id写入这个id值为1, 有这个id值+1
     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSInteger dataId;
    if( [defaults integerForKey:@"sos_daap_id"]){//从本地读取id
        
        NSInteger sos_daap_id =[defaults integerForKey:@"sos_daap_id"];
        dataId =sos_daap_id+1;
        [defaults setInteger:dataId forKey:@"sos_daap_id"];
        [defaults synchronize];
        
    }else{//本地没有 ,默认为1
        
        dataId=1;
        [defaults setInteger:1 forKey:@"sos_daap_id"];// 默认值为1
        [defaults synchronize];
    }
    
    return  dataId;
    
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

- (NSString *)convertTimeInterval:(NSTimeInterval)timeInterval {
    return [NSString stringWithFormat:@"%@", @((long long)(timeInterval * 1000))];
}


-(NSString*)getUUid {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    NSString *  deviceID = (__bridge NSString*)string;
    return deviceID;
}

 
 

@end
