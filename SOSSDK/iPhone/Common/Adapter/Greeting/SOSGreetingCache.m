//
//  SOSGreetingCache.m
//  Onstar
//
//  Created by onstar on 2017/10/12.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSGreetingCache.h"
//#import "SOSFlutterDB.h"
#import "SOSGreetingManager.h"

@interface SOSGreetingCache ()
@property (nonatomic, strong) YYCache *greetingCache;
@property (nonatomic, strong) YYCache *cardDataCache;

@end

static NSString *greetingCacheName = @"com.onstar.greetingCache";

NSString * const soskCardDataCacheName    = @"com.onstar.cardDataCache";
NSString * const soskStarTravelCardData   = @"com.onstar.starTravel";
NSString * const soskFuelConsumeCardData  = @"com.onstar.fuelConsume";
NSString * const soskEnergeConsumeCardData= @"com.onstar.energeConsume";
NSString * const soskDrivingScoreCardData = @"com.onstar.drivingScore";
NSString * const soskFootMarkCardData     = @"com.onstar.footMark";
NSString * const soskTrailCardData 		  = @"com.onstar.trailScore";
NSString * const soskUBICardData          = @"com.onstar.UBI";

@implementation SOSGreetingCache

+ (instancetype)shareInstance     {
    static SOSGreetingCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (cache == nil) {
            cache = [[self alloc] init];
        }
    });
    return cache;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _greetingCache= [[YYCache alloc] initWithName:greetingCacheName];
        _cardDataCache = [[YYCache alloc] initWithName:soskCardDataCacheName];
    }
    return self;
}


- (void)cacheGreeting:(NSString *)json role:(NSString *)role {
    
    NSDictionary *dic = @{@"date":[NSDate date],
                          @"json":json
                          };
    
    [self.greetingCache setObject:dic forKey:role];
}


- (NSDictionary *)getGreetingWithRole:(NSString *)role{
//    if ([SOSFlutterManager shareInstance].vehicle_condition_enable) {
//        NSString *today = [[NSDate date] stringWithFormat:@"MM-dd"];
//        NSDictionary *dic = [SOSFlutterDB selectWithKey:[@"greeting_" stringByAppendingString:role]].mj_JSONObject;
//        if ([dic[@"date"] isEqualToString:today]) {
//
//            return [dic[@"json"] mj_JSONObject];
//        }
//    }else {
      NSDictionary *dic = (id)[self.greetingCache objectForKey:role];
      NSDate *date = dic[@"date"];
      if (date.isToday) {
          return [dic[@"json"] mj_JSONObject];
      }
//    }
    return nil;
}

- (void)removeGreetingCacheWithRole:(NSString *)role {
//    SOSFlutterVehicleConditionEnable({
//        [SOSFlutterDB deleteWithKey:[@"greeting_" stringByAppendingString:role]];
//    }, {
        [self.greetingCache removeObjectForKey:role];
//    });
}
////////////////

- (void)cacheCardData:(NSString *)json  withCardName:(NSString *)cardName idpid:(NSString *)idpid {
    idpid = [idpid ifStringNilReturnUnloginString];
    NSMutableDictionary *allDic = [NSMutableDictionary dictionaryWithDictionary:(id)[self.cardDataCache objectForKey:idpid]];
    if (!allDic || allDic.count == 0) {
        //不存在
        allDic = [NSMutableDictionary dictionaryWithDictionary:@{cardName:@{@"date":[NSDate date],
                                                                            @"json":json
                                                                            }
                                                                 }];
    }else{
        //存在
        [allDic setObject:@{@"date":[NSDate date],
                           @"json":json
                           } forKey:cardName];
    }
    [self.cardDataCache setObject:allDic forKey:idpid];
}

- (NSDictionary *)getCardDataByCardName:(NSString *)cardName idpId:(NSString *)idpid {
    idpid = [idpid ifStringNilReturnUnloginString];
    NSDictionary *allDic = (id)[self.cardDataCache objectForKey:idpid];
    if (!allDic) {
        return nil;
    }
    NSDictionary *dic = (id)[allDic objectForKey:cardName];
    NSDate *date = dic[@"date"];
    if (date.isToday) {
        return [dic[@"json"] mj_JSONObject];
    }
    return nil;
}

- (void)removeCardDataByCardName:(NSString *)cardName idpId:(NSString *)idpid {
     idpid = [idpid ifStringNilReturnUnloginString];
    if ([cardName isEqualToString:soskCardDataCacheName]) {
        [self.cardDataCache removeObjectForKey:idpid];
    }else{
        NSMutableDictionary *allDic = [NSMutableDictionary dictionaryWithDictionary:(id)[self.cardDataCache objectForKey:idpid]];
        [allDic removeObjectForKey:cardName];
        [self.cardDataCache setObject:allDic forKey:idpid];
    }
}
@end
