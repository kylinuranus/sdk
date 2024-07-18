//
//  SOSGreetingCache.h
//  Onstar
//
//  Created by onstar on 2017/10/12.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOSGreetingCache : NSObject
extern  NSString * const soskStarTravelCardData;
extern  NSString * const soskFuelConsumeCardData;
extern  NSString * const soskEnergeConsumeCardData;
extern  NSString * const soskDrivingScoreCardData;
extern  NSString * const soskFootMarkCardData;
extern  NSString * const soskUBICardData;
extern  NSString * const soskAllCardData;
extern  NSString * const soskCardDataCacheName;

+ (instancetype)shareInstance;

- (void)cacheGreeting:(NSString *)json role:(NSString *)role ;

- (NSDictionary *)getGreetingWithRole:(NSString *)role;

- (void)removeGreetingCacheWithRole:(NSString *)role;
///
- (void)cacheCardData:(NSString *)json  withCardName:(NSString *)cardName idpid:(NSString *)idpid ;
- (void)removeCardDataByCardName:(NSString *)cardName idpId:(NSString *)idpid ;
- (NSDictionary *)getCardDataByCardName:(NSString *)cardName idpId:(NSString *)idpid ;
@end
