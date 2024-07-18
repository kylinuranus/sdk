//
//  SOSRegisterInformation.m
//  Onstar
//
//  Created by lizhipan on 2017/8/22.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSRegisterInformation.h"
//NSString * const  jumpBBWCTimes = @"jumpBBWC";


@implementation SOSRegisterInformation
static SOSRegisterInformation *_instance=nil;

+ (instancetype)sharedRegisterInfoSingleton {
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _instance=[[self alloc] init];
        NSLog(@"%@:----注册用户信息创建了",NSStringFromSelector(_cmd));
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (void)destroyRegisterInfoSingleton {
    self.registerWay = SOSRegisterWayUnknown;
    self.mobilePhoneNumer = nil;
    self.enrollInfo = nil;
    self.vin = nil;
    self.inputGovid = nil;
    self.email=nil;
    self.province=nil;
    self.gender=nil;
    self.accountType=nil;
    self.subscriber=nil;
    self.enrollInfo=nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _instance;
}
#pragma mark - 重写A.b的setter方法同步设置A的A.b同名属性
- (void)setEnrollInfo:(SOSEnrollInformation *)enrollInfo
{
    if (_enrollInfo != enrollInfo) {
        _enrollInfo = enrollInfo;
    }
    self.vin = enrollInfo.vin;
    self.mobilePhoneNumer = enrollInfo.mobile;
    self.email = enrollInfo.email;
    self.inputGovid = enrollInfo.inputGovid;
}
- (void)setSubscriber:(NNSubscriber *)subscriber
{
    if (_subscriber != subscriber) {
        _subscriber = subscriber;
    }
    self.vin = subscriber.vin;
    self.mobilePhoneNumer = subscriber.phoneNumber;
    self.email = subscriber.email;
    self.inputGovid = subscriber.governmentID;
}
- (void)dealloc {
    NSLog(@"%@:----注册用户信息释放了",NSStringFromSelector(_cmd));
}
@end

@implementation SOSUserBaseInformation
@end

@implementation SOSRegisterCheckReceiptResponse
@end

@implementation SOSRegisterUploadReceiptPic
@end

@implementation SOSEnrollInformation
@end

@implementation SOSEnrollGaaInformation
@end

@implementation SOSRegisterCheckPINRequest
@end

@implementation SOSRegisterCheckRequest
@end
@implementation SOSScanResult
@end
@implementation SOSRegisterCheckResponseWrapper
@end
@implementation SOSRegisterSubmitWrapper
@end
@implementation SOSBBWCSubmitWrapper
+ (NSDictionary *)objectClassInArray{
    return @{
             @"questions" : @"NNBBWCQuestion"
             };
}
@end
@implementation SOSRegisterCheckRequestWrapper
@end
@implementation SOSRegisterScanIDCardInfoWrapper
@end

