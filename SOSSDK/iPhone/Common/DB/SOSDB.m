//
//  SOSDB.m
//  Onstar
//
//  Created by lizhipan on 16/11/7.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "SOSDB.h"
//#import "SOSFlutterDB.h"
@implementation SOSDB

NSString *const DB_SECRETKEY = @"F375AEE7A789FDLSAFJEIOQJR34JRI4JIGR93209T489FR";

+ (SOSDB *)sharedInstance
{
    static SOSDB *sharedOBJ = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedOBJ = [[self alloc] init];
        
    });
    return sharedOBJ;
}

- (id)init
{
    if (self = [super init]) {
        _queueDic = [NSMutableDictionary dictionaryWithCapacity:0];
        return self;
    }
    return nil;
}

- (void)setQueue:(NSString *)dbPath forKey:(NSString *)keyIdentify
{
    if (![_queueDic.allKeys containsObject:keyIdentify]) {
        
//        if (sqlite3_open(oldDBPath, &db) == SQLITE_OK) {
//
//            if sqlite3_exec(db, "PRAGMA key = '\(sqlCipherKey)';", nil, nil, nil) == SQLITE_OK {
//
//                if sqlite3_exec(db, "PRAGMA cipher_migrate;", nil, nil, nil) == SQLITE_OK {
//                    debugPrint("Everything ok")
//                }
//            }
//        }
        
//        NSString *databasePath = [self databaseFilePath:dbPath];
//        sqlite3 *db;
//        sqlite3_stmt *stmt;
//        bool sqlcipher_valid = NO;
//
//        if (sqlite3_open([databasePath UTF8String], &db) == SQLITE_OK) {
//
//            if (sqlite3_exec(db, "key = 'F375AEE7A789FDLSAFJEIOQJR34JRI4JIGR93209T489FR';", nil, nil, nil) == SQLITE_OK) {
//
//                if (sqlite3_exec(db, "cipher_compatibility = 3;", nil, nil, nil) == SQLITE_OK) {
//                    NSLog(@"Everything ok");
//                }
//            }
//        }
        
        FMDatabaseQueue * queue = [FMDatabaseQueue databaseQueueWithPath:[self databaseFilePath:dbPath]];
        [self.queueDic setObject:queue forKey:keyIdentify];
    }
}
-(NSString *)databaseFilePath:(NSString *)dbPath{
 
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:dbPath];
}
- (FMDatabaseQueue *)getQueueForKey:(NSString *)keyIdentify
{
    return [self.queueDic objectForKey:keyIdentify]? [self.queueDic objectForKey:keyIdentify] : nil;
}

- (BOOL)createTableFromQueue:(NSString *)keyIdentify sqlString:(NSString *)sql
{
    return [self executeUpdate:sql queueIdentify:keyIdentify param:nil];
}

- (BOOL)executeUpdate:(NSString *)sql queueIdentify:(NSString *)keyIdentify param:(NSArray *)param
{
    __block BOOL result = NO;
    [[_queueDic objectForKey:keyIdentify] inDatabase:^(FMDatabase *db) {
        [db open];
        [db setKey:DB_SECRETKEY];
//        [SOSFlutterDB setKey:DB_SECRETKEY withDB:db];
        if (param && param.count > 0) {
            result = [db executeUpdate:sql withArgumentsInArray:param];
        } else {
            result = [db executeUpdate:sql];
        }
        [db close];
    }];
    
    return result;
}

- (BOOL)executeSomeUpdates:(NSArray *)sqls queueIdentify:(NSString *)keyIdentify complete:(void(^)(BOOL complete))completeBlock
{
    __block BOOL success = YES;
    
    [[_queueDic objectForKey:keyIdentify] inDatabase:^(FMDatabase *db) {
        [db open];
        [db setKey:DB_SECRETKEY];
//        [SOSFlutterDB setKey:DB_SECRETKEY withDB:db];
        [db beginTransaction];
        @try {
            for (NSString * sql in sqls) {
                if (![db executeUpdate:sql]) {
                    success = NO;
                } ;
            }
        } @catch (NSException *exception) {
            success = NO;
            [db rollback];
            
        } @finally {
            if (success) {
                [db commit];
            }
        }
        [db close];
        if (completeBlock) {
            completeBlock(success);
        }
    }];
    return success;
}

- (void )executeQuery:(NSString *)sql queueIdentify:(NSString *)keyIdentify param:(NSArray *)param completeBlock:(sqlExecCompleteBlock)complete
{
    [[_queueDic objectForKey:keyIdentify] inDatabase:^(FMDatabase *db) {
        [db open];
       
        [db setKey:DB_SECRETKEY];
//        [SOSFlutterDB setKey:DB_SECRETKEY withDB:db];
        FMResultSet *rs;
        if (param && param.count >0) {
            rs = [db executeQuery:sql withArgumentsInArray:param];
        }
        else
        {
            rs = [db executeQuery:sql];
        }
        if (complete) {
            complete(db,rs);
        }
        [rs close];
        [db close];
    }];
}
@end

