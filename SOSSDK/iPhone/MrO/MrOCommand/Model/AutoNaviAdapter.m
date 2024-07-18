//
//  AutoNaviAdapter.m
//  AutoNaviTelematrics
//
//  Created by Joshua on 15-3-31.
//  Copyright (c) 2015年 onstar. All rights reserved.
//

#import "AutoNaviAdapter.h"
#import "ServiceURL.h"
#import "AutoNaviObject.h"
#import "Util.h"
//#import "Weather.h"
#import "ViolationList.h"
//#import "Restrict.h"
#import "OpenUDID.h"
#import "AppPreferences.h"
#import "CustomerInfo.h"

@implementation AutoNaviAdapter




#pragma mark  // 违章请求
- (void)asyncRequestForVolation:(NSString *)URL_ successBlock:(SOSSuccessBlock)successBlock_ failureBlock:(SOSFailureBlock)failureBlock_  {
    SOSNetworkOperation *sosOperation =
    [SOSNetworkOperation requestWithURL:URL_ params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        if (successBlock_) {
            successBlock_(operation, responseStr);
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (failureBlock_) {
            failureBlock_(statusCode,responseStr,error);
        }
        //违章查询失败record
        //[[SOSReportService shareInstance] recordActionWithFunctionID:Violationcheckfailedreport];
    }];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation start];
}

- (void)asyncRequestForRestrict:(NSString *)restrictURL     {
    SOSNetworkOperation *sosOperation =
    [SOSNetworkOperation requestWithURL:restrictURL params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSError *error = nil;
        NSDictionary *restrictDic =[Util dictionaryWithJsonString:responseStr];
        if (!error)
        {
            if(restrictDic!=nil)
            {
                NSDictionary *dictionary = [NSDictionary dictionaryWithObject:restrictDic forKey:@"RestrictInfo"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:SOS_AutoNaviAdapter_GetRestrict object:self userInfo:dictionary];
                    
                });
            }
        }else{
            NSLog(@"http error");
        }
    }failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {

        if (responseStr) {
            NSDictionary *restrictDic =[Util dictionaryWithJsonString:responseStr];
            if (!restrictDic) {
                return;
            }
            NSDictionary *dictionary = [NSDictionary dictionaryWithObject:restrictDic forKey:@"list"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:SOS_AutoNaviAdapter_GetRestrict object:self userInfo:dictionary];
            });
            NSLog(@"http error %@",error);
        }

    }];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation start];
}

@end
