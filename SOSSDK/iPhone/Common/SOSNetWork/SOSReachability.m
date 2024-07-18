//
//  SOSReachability.m
//  Onstar
//
//  Created by Gennie Sun on 15/11/24.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import "SOSReachability.h"

@implementation SOSReachability

+ (void)SOSNetworkStatuswithSuccessBlock:(statusBlock)success     {
    [[self sharedManager]startMonitoring];
    
    /*
     AFNetworkReachabilityStatusUnknown          = -1,
     AFNetworkReachabilityStatusNotReachable     = 0,
     AFNetworkReachabilityStatusReachableViaWWAN = 1,
     AFNetworkReachabilityStatusReachableViaWiFi = 2,
     */
    
    [[self sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        success(status);
    }];
}

+ (void)networkStatusReachabilityBlock:(successBlock)success     {
	[[self sharedManager]startMonitoring];
	
	/*
	 AFNetworkReachabilityStatusUnknown          = -1,
	 AFNetworkReachabilityStatusNotReachable     = 0,
	 AFNetworkReachabilityStatusReachableViaWWAN = 1,
	 AFNetworkReachabilityStatusReachableViaWiFi = 2,
	 */
	
	[[self sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
		
		if (status == -1)
		{
			success(@"NO");
		}
		else if (status == 0)
		{
			success(@"NO");
		}
		else if (status == 1)
		{
			success(@"YES");
		}
		else if (status == 2)
		{
			success(@"YES");
		}
	}];
	
}
@end
