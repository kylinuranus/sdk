//
//  SOSPoiHistoryDataBase.m
//  Onstar
//
//  Created by TaoLiang on 2019/4/16.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSPoiHistoryDataBase.h"
#import "FMDB.h"



static NSString * const kTableName = @"PoiHistory";
static NSString * const kFileName = @"SOSPoiHistory.db";
static SOSPoiHistoryDataBase *sharedInstance = nil;

@interface SOSPoiHistoryDataBase ()

@property (strong, nonatomic) FMDatabaseQueue *queue;
@property (strong, nonatomic) NSString *keys;

@end

@implementation SOSPoiHistoryDataBase


+ (instancetype)sharedInstance {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Open

- (void)insert:(SOSPOI *)data {
    if ((data.longitude.floatValue && data.latitude.floatValue) == NO)	return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableString *placeholder = @"".mutableCopy;
        for (int i=0; i<[_keys componentsSeparatedByString:@","].count; i++) {
            [placeholder appendString:@"?,"];
        }
        [placeholder deleteCharactersInRange:NSMakeRange(placeholder.length - 1, 1)];
        
        NSString *insertSql = [NSString stringWithFormat:@"insert into %@ (%@) values (%@)", kTableName, _keys, placeholder];
        [_queue inDatabase:^(FMDatabase * _Nonnull db) {
            NSString *delSql;
            if (data.pguid.length) 	delSql = [NSString stringWithFormat:@"delete from %@ where pguid = '%@'", kTableName, data.pguid];
            else					delSql = [NSString stringWithFormat:@"delete from %@ where name = '%@' and longitude = '%@' and latitude = '%@'", kTableName, data.name, data.longitude, data.latitude];
            [db executeUpdate:delSql, nil];
            
            long long timeInterval = [NSDate date].timeIntervalSince1970 * 1000;
            [db executeUpdate:insertSql, data.pguid, data.name, data.address, data.tel, data.city, data.province, data.longitude, data.latitude, @(data.historyPoiType), @([self convertPriorityFromHisType:data.historyPoiType]), @(timeInterval)];
        }];
    });
}

- (void)updateOldVersionPoi:(SOSPOI *)poi {
    [_queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where pguid = '%@'", kTableName, poi.pguid];
        [db executeUpdate:deleteSql];
    }];
    
    [self insert:poi];
    
}

- (void)fetch:(void (^)(NSArray<SOSPOI *> * _Nonnull))results {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray<SOSPOI *> *points = @[].mutableCopy;
        [_queue inDatabase:^(FMDatabase * _Nonnull db) {
            FMResultSet *set = [db executeQuery:@"select * from (select * from PoiHistory order by timeInterval DESC) group by pguid order by timeInterval DESC limit 20"];
            while ([set next]) {
                //    _keys = @"pguid,name,address,tel,cityName,provinceName,lon,lat,hisType,priority,timeInterval";
                SOSPOI * poi = [SOSPOI new];
                poi.pguid = [set stringForColumn:@"pguid"];
                poi.name = [set stringForColumn:@"name"];
                poi.address = [set stringForColumn:@"address"];
                poi.tel = [set stringForColumn:@"tel"];
                poi.city = [set stringForColumn:@"cityName"];
                poi.province = [set stringForColumn:@"provinceName"];
                poi.longitude = [set stringForColumn:@"lon"];
                poi.latitude = [set stringForColumn:@"lat"];
                poi.historyPoiType = [set intForColumn:@"hisType"];
                if (poi.pguid.length <= 4) {
                    //认为是老数据,置为空字符串
                    poi.pguid = @"";
                }
                [points addObject:poi];
            }
            dispatch_async_on_main_queue(^{
                results(points.copy);
            });
        }];
    });
}

- (void)deletePOI:(SOSPOI *)poi		{
    __block BOOL result = NO;
    [_queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *delSql = [NSString stringWithFormat:@"delete from %@ where pguid = '%@'", kTableName, poi.pguid];
        result = [db executeUpdate:delSql, nil];
    }];
}

- (BOOL)deleteAll {
    __block BOOL result = NO;
    [_queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *delSql = [NSString stringWithFormat:@"delete from %@", kTableName];
        result = [db executeUpdate:delSql, nil];
    }];
    return result;
}


#pragma mark - Private

- (instancetype)init {
    self = [super init];
    if (self) {
        _keys = @"pguid,name,address,tel,cityName,provinceName,lon,lat,hisType,priority,timeInterval";
        NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:kFileName];
        _queue = [FMDatabaseQueue databaseQueueWithPath:filePath];
//#warning 测试时候删除原表,方便调整字段
//        NSString *sqlDel = [NSString stringWithFormat:@"drop table if exists %@", kTableName];
//        [self executeUpdate:sqlDel];
        
        NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (uid integer primary key autoincrement,pguid text,name text,address text, tel text, cityName text, provinceName text, lon text, lat text, hisType integer, priority integer, timeInterval bigint);", kTableName];
        [self executeUpdate:sql];
    }
    return self;
}

- (BOOL)executeUpdate:(NSString *)sql {
    __block BOOL result = NO;
    [_queue inDatabase:^(FMDatabase *db) {
//        if (self.isEncrypted) {
//            [db setKey:LOGIN_USER_DB_SECRETKEY];
//        }
        result = [db executeUpdate:sql];
        if (result) {
            NSLog(@"PoiHistoryDB: update success, sql is %@", sql);
        }else{
            NSLog(@"PoiHistoryDB: update failed, sql is %@", sql);
        }
    }];
    return result;
}


//9.1后删除
- (void)transferOldDataIfNeeded {
    BOOL didTransferred = [[NSUserDefaults standardUserDefaults] boolForKey:@"SOSPoiHistoryDidTransferred"];
    if (didTransferred) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //#1.获取老数据库
        NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"NewPoiHistory.sqlite"];
        FMDatabaseQueue *oldDataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:filePath];
        NSMutableArray<NSDictionary<NSString *, NSString *> *> *oldDics = @[].mutableCopy;
        NSArray<NSString *> *oldKeys = @[@"name", @"address", @"tel", @"lon", @"lat", @"isNameSearch", @"cityName", @"provinceName"];
        [oldDataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            //#2.获取老数据,根据name和isNameSearch字段过滤重复数据, isNameSearch数值大的优先级大;
            FMResultSet *set = [db executeQuery:@"select * from (select * from NewPoiHistory order by isNameSearch DESC) group by name limit 100"];
            while ([set next]) {
                NSMutableDictionary *dic = @{}.mutableCopy;
                [oldKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    dic[obj] = [set stringForColumn:obj] ? : @"";
                }];
                [oldDics addObject:dic];
#if DEBUG || TEST
                NSMutableString *log = @"老数据>>>".mutableCopy;
                [oldKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [log appendFormat:@"%@:%@ -", obj, dic[obj]];
                }];
                NSLog(@"%@", log);
#endif
            }
        }];
        //#3.迁入新数据库
        if (oldDics.count <= 0) {
            return;
        }
        NSString *newKey = _keys.copy;
        NSArray<NSString *> *newKeys = [newKey componentsSeparatedByString:@","];
        
        [_queue inDatabase:^(FMDatabase * _Nonnull db) {
            [oldDics enumerateObjectsUsingBlock:^(NSDictionary<NSString *,NSString *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSMutableDictionary<NSString *, NSString *> *newDic = obj.mutableCopy;
                NSInteger isNameSearch = obj[@"isNameSearch"].integerValue;
                HistoryPoiType type = [self convertPoiTypeFromIsNameSearch:isNameSearch];
                newDic[@"hisType"] = [NSString stringWithFormat:@"%@", @(type)];
                newDic[@"priority"] = [NSString stringWithFormat:@"%@", @([self convertPriorityFromHisType:type])];
                newDic[@"pguid"] = [NSString stringWithFormat:@"%@", @(idx)];
                __block NSString *values = newKey.copy;
                //#4.拼接sql语句
                [newKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([key isEqualToString:@"timeInterval"]) {
                        long long timeInterval = [NSDate date].timeIntervalSince1970 * 1000;
                        NSString *time = [NSString stringWithFormat:@"%@",@(timeInterval)];
                        values = [values stringByReplacingOccurrencesOfString:@"timeInterval" withString:time];
                    }else {
                        NSString *value = newDic[key] ? [NSString stringWithFormat:@"'%@'", newDic[key]] : @"''";
                        values = [values stringByReplacingOccurrencesOfString:key withString:value];
                    }
                }];
                NSString *insertSql = [NSString stringWithFormat:@"insert into %@ (%@) values (%@)", kTableName, newKey, values];
                [db executeUpdate:insertSql];
            }];
        }];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SOSPoiHistoryDidTransferred"];
    });
    
}


- (HistoryPoiType)convertPoiTypeFromIsNameSearch:(NSInteger)isNameSearch {
    if (isNameSearch == 0) {
        return HistoryPoiTypeSendToVehicle;
    }else {
        return HistoryPoiTypeSearch;
    }
}


/**
 考虑到以后可能有新的HistoryType，数据库中设置优先级方便扩展

 @param type HistoryType
 @return 优先级
 */
- (NSUInteger)convertPriorityFromHisType:(HistoryPoiType)type {
    switch (type) {
        case HistoryPoiTypeSearch:
            return 250;
        case HistoryPoiTypeDestination:
            return 750;
        case HistoryPoiTypeSendToVehicle:
            return 1000;
        default:
            return 0;
    }
}

@end
