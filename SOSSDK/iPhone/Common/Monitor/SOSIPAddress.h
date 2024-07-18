//
//  SOSIPAddress.h
//  Onstar
//
//  Created by WQ on 2018/12/17.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface SOSIPAddress : NSObject

+ (NSString *)getIPAddress:(BOOL)preferIPv4;
+ (NSDictionary *)getIPAddresses;
+ (NSString *)getIPAddressWithWIFi;
+ (NSString *)getIpv6;

@end

NS_ASSUME_NONNULL_END

