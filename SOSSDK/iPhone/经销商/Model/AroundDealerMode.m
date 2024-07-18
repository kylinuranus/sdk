//
//  AroundDealerMode.m
//  Onstar
//
//  Created by 王健功 on 14-6-24.
//  Copyright (c) 2014年 Shanghai Onstar. All rights reserved.
//

#import "AroundDealerMode.h"
#import "AppPreferences.h"
#import "CustomerInfo.h"
#import "LoadingView.h"
#import "SOSCheckRoleUtil.h"

#define MAX_RETURN_NUMBER 10

static AroundDealerMode *dealerMode = nil;

@implementation AroundDealerMode

- (id)init{
    
    self = [super init];
    
    return self;
}

+ (AroundDealerMode *)shareDealerMode{
    
    if (!dealerMode) {
        
        dealerMode = [[AroundDealerMode alloc] init];
    }
    return dealerMode;
}

+ (void)releaseDealerMode{
    
    if (dealerMode) {
        dealerMode = nil;
    }
}

- (void)sendGetDealerRequest:(NNAroundDealerRequest *)dealerRequest loadPage:(NSInteger)page{

    switch (_requestType) {
        case 0:
        {
            if ([SOSCheckRoleUtil isDriverOrProxy] || [SOSCheckRoleUtil isOwner]) {
                [dealerRequest setReturnPreferredDealer:@"true"];
            }   else    {
                [dealerRequest setReturnPreferredDealer:@"false"];
            }
        }
            break;
        case 1:
            [dealerRequest setReturnPreferredDealer:@"false"];
            break;
        case 2:
            [dealerRequest setReturnPreferredDealer:@"true"];
            break;
        default:
            [dealerRequest setReturnPreferredDealer:@"true"];
            break;
    }
    //这个字段只传false了
    dealerRequest.returnPreferredDealer = @"false";
    
    NSString *postData = [dealerRequest mj_JSONString];
    NSString *url;
    
    if (_requestType == 0) {
        url = [NSString stringWithFormat:(@"%@" NEW_DEALER_GETAROUNDDEALERS), BASE_URL, [CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];

    }   else    {
        
        NSString *s = [NSString stringWithFormat:NEW_DEALER_GET_CITYDEALERS,dealerRequest.cityCode,dealerRequest.currentLocation.longitude,dealerRequest.currentLocation.latitude,dealerRequest.queryType,dealerRequest.dealerBrand];
         url = [BASE_URL stringByAppendingString:s];
        postData = nil;
    }
    
    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:postData successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        [self dealerRequestFinished:responseStr];
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [_delegate requestDidFinish:NO withObject:nil];
        if (failureBlock) {
            failureBlock(error);
        }

    }];
    
    if (_requestType == 0) {
        [sosOperation setHttpMethod:@"PUT"];
    }else
    {
        [sosOperation setHttpMethod:@"GET"];
    }
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}

#pragma mark - response
- (void)setCompletionBlock:(DealerBlock)aCompletionBlock     {
    completionBlock = [aCompletionBlock copy];
}

- (void)setFailedBlock:(DealerBlock)aFailedBlock     {
    failureBlock = [aFailedBlock copy];
}


- (void)dealerRequestFinished:(id)responseData     {
    @try {
        
        [self parseDealerInfo:[Util dictionaryWithJsonString:responseData]];
    }
    @catch (NSException *exception) {
        NSLog(@"XMLEXCEPTION %@",exception);
    }
    
}


- (void)parseDealerInfo:(NSDictionary *)dict{
    
    NNAroundDealerResponse *respone =[NNAroundDealerResponse mj_objectWithKeyValues:dict];
    if ([self.delegate respondsToSelector:@selector(requestDidFinish:withObject:)]) {
        
        [_delegate requestDidFinish:YES withObject:respone];
    }else{
        
#if NS_BLOCKS_AVAILABLE
        if (completionBlock) {
            completionBlock(respone);
        }
#endif
    }
}

@end
