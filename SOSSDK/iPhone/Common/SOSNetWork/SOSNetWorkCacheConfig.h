//
//  SOSNetWorkCacheConfig.h
//  Onstar
//
//  Created by onstar on 2018/5/28.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger,SOSNetWorkCacheOption) {
    SOSNetWorkCacheOptionReadWrite, //读写
    SOSNetWorkCacheOptionRead       //只读
};

@interface SOSNetWorkCacheConfig : NSObject

/**
 缓存的key 必须
 */
@property (nonatomic, copy) NSString *cacheKey;

/**
 有效截止时间 default:DBL_MAX
 */
@property (nonatomic, assign) NSTimeInterval validTime;


/**
 缓存策略
 default: 读写
 */
@property (nonatomic, assign) SOSNetWorkCacheOption cacheOption;

/**
 取
 */
- (NSString *)getCache;

/**
 存
 */
- (void)saveCache:(NSString *)responseStr;

@end



@interface SOSNetWorkCacheConfig()
/**
 几天后的时间戳
 */
+ (NSTimeInterval)dateByAddDay:(NSInteger)day;

/**
 今晚12点时间戳
 */
+ (NSTimeInterval)todayEnd;

@end
