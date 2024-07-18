//
//  SOSServicesInfo.m
//  Onstar
//
//  Created by lmd on 2017/9/14.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSServicesInfo.h"

@interface SOSServicesInfo ()
@end

@implementation SOSServicesInfo


- (void)getResponseFromSeriverComplete:(void (^)(void))complete {
    [self getResponseFromSeriverForce:NO complete:complete];
}

- (void)getResponseFromSeriverForce:(BOOL)force complete:(void (^)(void))complete {
    if (self.hasResponse && !force) {
        if (complete) {
            complete();
        }
        return;
    }
    if (![Util isLoadUserProfileFailure] && [SOSCheckRoleUtil isOwner]) {
        [self getServiceStatusCallback:^(NSString *optStatus) {
            if (!optStatus.isNotBlank) {
                dispatch_async_on_main_queue(^{
                    if (complete) {
                        complete();
                    }
                });
                return ;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *servicesList = [Util arrayWithJsonString:optStatus];
                NNservicesOpt *opt = [[NNservicesOpt alloc] init];
                [opt setServicesList:[NNserviceObject mj_objectArrayWithKeyValuesArray:servicesList]];
                for (NNserviceObject *object in opt.servicesList) {
                    [self handleserviceCallBackWithServiceObj:object];
                }
                self.hasResponse = YES;
                if (complete) {
                    complete();
                }
            });
        }];
    }else {
        dispatch_async_on_main_queue(^{
            if (complete) {
                complete();
            }
        });
        
    }
}

- (void)handleserviceCallBackWithServiceObj:(NNserviceObject *)object	{
    if ([object.serviceName isEqualToString:@"SmartDrive"]) {
        
        self.SmartDrive = object;
        
    }    else if ([object.serviceName isEqualToString:@"CarAssessment"]){
        
        self.CarAssessment = object;
        [[NSUserDefaults standardUserDefaults] setBool:object.optStatus forKey:NEED_REMOTE_CARSTATUSREPORT];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }    else if ([object.serviceName isEqualToString:@"RemoteControlOptStatus"]){
        
        self.RemoteControlOptStatus = object;
        
    }    else if ([object.serviceName isEqualToString:@"FmvOptStatus"]){
        
        self.FmvOptStatus = object;
    }    else if ([object.serviceName isEqualToString:@"FuelEconomy"]){
        self.FuelEconomy = object;
        
    }    else if ([object.serviceName  isEqualToString:@"EnergyEconomy"]){
        self.EnergyEconomy = object;
        [[NSUserDefaults standardUserDefaults] setBool:object.optStatus forKey:NEED_REMOTE_OPTSTATUS];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }    else if ([object.serviceName  isEqualToString:@"ChargeStation"]){
        self.ChargeStation = object;
    }
}


#pragma mark -取后台服务器
- (void)getServiceStatusCallback:(void(^)(NSString *optStatus))callback
{
    NSString *url = [BASE_URL stringByAppendingFormat:get_local_services_URL,  [CustomerInfo sharedInstance].userBasicInfo.idpUserId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin,@""];
    
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        if (callback) {
            callback(responseStr);
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        NSLog(@"error: %@", error);
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];
}

- (void)getServiceStatus:(NSString *)serviceName callback:(void(^)(NSDictionary *result))callback	{
    [self getServiceStatus:serviceName Success:callback Failure:nil];
}

- (void)getServiceStatus:(NSString *)serviceName Success:(void(^)(NSDictionary *result))success Failure:(SOSFailureBlock)failure	{
    NSString *url = [BASE_URL stringByAppendingFormat:get_local_services_URL,  [CustomerInfo sharedInstance].userBasicInfo.idpUserId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin,serviceName];

    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *arr = [Util arrayWithJsonString:responseStr];
            if ([arr[0] isKindOfClass:[NSDictionary class]]) {
                NNserviceObject *serviceObj = [NNserviceObject mj_objectWithKeyValues:arr[0]];
                [self handleserviceCallBackWithServiceObj:serviceObj];
                if (success) success(arr[0]);
            }else{
                if (success) success(@{});
            }
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        NSLog(@"error: %@", error);
        if (failure)	failure(statusCode, responseStr, error);
        else			[Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];

}

#pragma mark - 打开\关闭服务

- (void)triggerService:(BOOL)status serviceName:(NSString *)serviceName callback:(void (^)(void))callback {
    [self triggerService:status serviceName:serviceName callback:callback failBlock:nil];
}
- (void)triggerService:(BOOL)status serviceName:(NSString *)serviceName callback:(void (^)(void))callback failBlock:(void (^)(NSInteger, NSString *, NSError *))failBlock{
    [Util showLoadingView];
    NSString *httpMethod = status ? @"PUT" : @"DELETE";
    NSString *para = nil;
    NSString *url = nil;
    if ([httpMethod isEqualToString:@"PUT"]) {
        url = [BASE_URL stringByAppendingFormat:open_local_service_URL,[CustomerInfo sharedInstance].userBasicInfo.idpUserId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
        NSDictionary *d = @{@"subscriberID":[CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId,
                            @"serviceName":serviceName};
        para = [Util jsonFromDict:d];
    }	else	{
        url = [BASE_URL stringByAppendingFormat:update_local_service_URL,[CustomerInfo sharedInstance].userBasicInfo.idpUserId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin,serviceName];
    }

    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:para successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        [Util hideLoadView];
        NSLog(@"response:%@",responseStr);
        NSDictionary *responseDic = [Util dictionaryWithJsonString:responseStr];
        if ([responseDic[@"code"] isEqualToString:@"E0000"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback();
            });
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async_on_main_queue(^{
            if (failBlock) {
                failBlock(status, responseStr, error);
            }
            [Util hideLoadView];
        });
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:httpMethod];
    [operation start];

}


@end
