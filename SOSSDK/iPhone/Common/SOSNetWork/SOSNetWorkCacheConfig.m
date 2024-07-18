//
//  SOSNetWorkCacheConfig.m
//  Onstar
//
//  Created by onstar on 2018/5/28.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSNetWorkCacheConfig.h"
#import <DateTools/DateTools.h>

NSString * const soskCardDataCacheName1    = @"com.onstar.cardDataCache";

@interface SOSNetWorkCacheConfig ()
@property (nonatomic, strong) YYCache *cache;
@end

@implementation SOSNetWorkCacheConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cache = [[YYCache alloc] initWithName:soskCardDataCacheName1];
    }
    return self;
}

- (void)setValidTime:(NSTimeInterval)validTime {
    _validTime = validTime;
    _cache.diskCache.ageLimit = validTime;
}

- (NSString *)getCache
{
    NSAssert(self.cacheKey.isNotBlank, @"请设置缓存的key");
    return (id)[_cache objectForKey:self.cacheKey];
}

- (void)saveCache:(NSString *)responseStr
{
    NSAssert(self.cacheKey.isNotBlank, @"请设置缓存的key");
    NSAssert(responseStr.isNotBlank, @"保存的数据为空服务器返回数据有问题");
    if (!responseStr.isNotBlank || !self.cacheKey.isNotBlank) {
        return;
    }
    if (self.cacheOption == SOSNetWorkCacheOptionReadWrite) {
        [_cache setObject:responseStr forKey:self.cacheKey];
    }
}


/**
 几天后的时间戳
 */
+ (NSTimeInterval)dateByAddDay:(NSInteger)day
{
    NSDate *date = [[NSDate date] dateByAddingDays:day];
    return date.timeIntervalSince1970;
}

/**
 今晚12点时间戳
 */
+ (NSTimeInterval)todayEnd
{
    NSDate *date = [[NSDate date] dateByAddingDays:1];
    date = [NSDate dateWithYear:date.year month:date.month day:date.day];
    return date.timeIntervalSince1970;
}


@end
