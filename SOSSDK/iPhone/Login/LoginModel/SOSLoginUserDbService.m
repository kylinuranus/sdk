//
//  SOSLoginUserDbService.m
//  Onstar
//
//  Created by Apple on 17/3/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSLoginUserDbService.h"
#import "FMDB.h"
//#import "SOSFlutterDB.h"

///DB PathFile
#define LOGIN_USER_DB_PATHFILE [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:LOGIN_USER_DB]

static NSString *const USER_TABLE = @"User";
static NSString *const USER_SELECT_PAYCHANNEL_TABLE = @"t_userSelectChannel";
static NSString *const LOGIN_USER_DB = @"LoginUserDB.db";
static NSString *const LOGIN_USER_DB_SECRETKEY = @"F375AEE7A789FDLSAFJEIOQJR34JRI4JIGR93209T489FR";

@interface SOSLoginUserDbService()
@property(nonatomic, strong) FMDatabaseQueue *queue;
@property(nonatomic, assign) BOOL isEncrypted;
@end

@implementation SOSLoginUserDbService
static SOSLoginUserDbService *sharedOBJ1 = nil;
static dispatch_once_t predicate1;
+ (SOSLoginUserDbService *)sharedInstance
{
    dispatch_once(&predicate1, ^{
        sharedOBJ1 = [[self alloc] createDbByencrypt:YES];
    });
    return sharedOBJ1;
}

- (instancetype) createDbByencrypt:(BOOL)isEncrypted
{
    self.isEncrypted = isEncrypted;
    return [self initWithPath:LOGIN_USER_DB_PATHFILE];
}

//static FMDatabaseQueue * _Nullable extracted(NSString *path) {
//    return [FMDatabaseQueue databaseQueueWithPath:path];
//}

- (instancetype)initWithPath:(NSString *)path
{
    if (self = [super init]) {
        _queue = [FMDatabaseQueue databaseQueueWithPath:path];
        NSLog(@"Login User DB path: %@",path);
        BOOL createTableResult = [self creatTable];
//        BOOL createselectPayChannelResult = [self createSelectPayChannelTable];
        if (createTableResult) {
            NSLog(@"Login User DB create successed!");
        }else{
            NSLog(@"Login User DB create failed!");
        }
    }
    return self;
}
- (BOOL)creatTable
{
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement,idToken text,responseStr text,expireDate text);",USER_TABLE];
    return [self executeUpdate:sql param:nil];
}
- (BOOL)createSelectPayChannelTable
{
    //TODO 7.4
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement,idPid text,channelID text,channel text);",USER_SELECT_PAYCHANNEL_TABLE];
    return [self executeUpdate:sql param:nil];
}

- (BOOL)executeUpdate:(NSString *)sql param:(NSArray *)param
{
    __block BOOL result = NO;
    [_queue inDatabase:^(FMDatabase *db) {
//        [db open];
        if (self.isEncrypted) {
            [db setKey:LOGIN_USER_DB_SECRETKEY];
//            [SOSFlutterDB setKey:LOGIN_USER_DB_SECRETKEY withDB:db];
        }
        
        if (param && param.count > 0) {
            result = [db executeUpdate:sql withArgumentsInArray:param];
        } else {
            result = [db executeUpdate:sql];
        }
        if (result) {
            NSLog(@"login User DB write successed!")
        }else{
            NSLog(@"login User DB write failed!")
        }
//        [db close];
    }];
    return result;
}

- (void)insertUserIdToken:(NSString *)idToken reposeString:(NSString *)res
{
    NSString *sql = [NSString stringWithFormat:@"insert into %@(idToken, responseStr,expireDate) values(?,?,?)",USER_TABLE];
    idToken = idToken?idToken:@"";
    NSArray *param = @[idToken,res,[self expireDate]];
    BOOL ret = [self executeUpdate:sql param:param];
    if (ret) {
        NSLog(@"login User DB insert successed!")
    }else{
        NSLog(@"login User DB insert failed!")
    }
}
- (void)addUser:(NSString *)idpid selectChannelID:(NSString *)channelID channel:(NSString *)channel
{
    NSString *querySql = [NSString stringWithFormat:@"select channel from %@ where idPid=?",USER_SELECT_PAYCHANNEL_TABLE];
    NSArray *param = @[idpid];

    if ([self executeScalar:querySql param:param] != nil) {
        NSString *sql = [NSString stringWithFormat:@"update %@ set channelID=?,channel=? where idPid=?",USER_SELECT_PAYCHANNEL_TABLE];
        NSArray *param = @[channelID,channel,idpid];
        BOOL ret = [self executeUpdate:sql param:param];
        if (ret) {
            NSLog(@"selectChannel update successed!");
        }else{
            NSLog(@"selectChannel update failed!");
        }
    }
    else
    {
        NSString *insertSql = [NSString stringWithFormat:@"insert into %@(idPid, channelID,channel) values(?,?,?)",USER_SELECT_PAYCHANNEL_TABLE];
        NSArray *param = @[idpid,channelID,channel];
        BOOL ret = [self executeUpdate:insertSql param:param];
        if (ret) {
            NSLog(@"selectChannel insert successed!");
        }else{
            NSLog(@"selectChannel insert failed!");
        }
    }
    
}
- (NSString *)fetchUserSelectPayChannelIdByIdpid:(NSString *)idpid
{
    NSString *sql = [NSString stringWithFormat:@"select channel from %@ where idPid=?",USER_SELECT_PAYCHANNEL_TABLE];
    NSArray *param = @[idpid];
    return [self executeScalar:sql param:param];
}
- (void)updateUserIdToken:(NSString *)idToken reposeString:(NSString *)res
{
    NSString *sql = [NSString stringWithFormat:@"update %@ set responseStr=?,expireDate=? where idToken=?",USER_TABLE];
    idToken = idToken?idToken:@"";
    NSArray *param = @[res,[self expireDate],idToken];
    BOOL ret = [self executeUpdate:sql param:param];
    if (ret) {
//        NSLog(@"login DB update successed!")
    }else{
//        NSLog(@"login DB update failed!")
    }
}

- (NSString *)searchUserIdToken:(NSString *)idToken
{
    NSString *sql = [NSString stringWithFormat:@"select responseStr from %@ where idToken=?", USER_TABLE];
    NSArray *param = @[idToken?:@""];
    return [self executeScalar:sql param:param];
    
}

- (NSString *)searchExpireDate:(NSString *)idToken
{
    NSString *sql = [NSString stringWithFormat:@"select expireDate from %@ where idToken=?",USER_TABLE];
    NSArray *param = @[idToken?:@""];
    return [self executeScalar:sql param:param];
}

- (id)executeScalar:(NSString *)sql param:(NSArray *)param
{
    __block id result;
    
    [_queue inDatabase:^(FMDatabase *db) {
//        [db open];
        if (self.isEncrypted) {
            [db setKey:LOGIN_USER_DB_SECRETKEY];
//             [SOSFlutterDB setKey:LOGIN_USER_DB_SECRETKEY withDB:db];
        }
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:param];
        if ([rs next]) {
            result = rs[0];
        } else {
            result = 0;
        }
//        [rs close];
//        [db close];
    }];
    return result;
}

- (BOOL)isExpiredIdToken:(NSString *)idToken
{
    NSString *expireDate = [self searchExpireDate:idToken];
    return [expireDate doubleValue] <= [[NSDate date] timeIntervalSince1970];
}

- (void)clearDB
{
    //清除表的所有记录，防止记录过多占用磁盘空间
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ ",USER_TABLE];
    [self executeScalar:sql param:nil];
}

- (void)delDB    {
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:LOGIN_USER_DB_PATHFILE error:&error];
    if (error) {
        NSLog(@"%@", [NSString stringWithFormat:@"%@ DB 删除失败",LOGIN_USER_DB_PATHFILE]);
    }    else    {
        predicate1 = 0;
        sharedOBJ1 = nil;
    }
}


- (NSString *)expireDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *com = [calendar components:NSCalendarUnitDay fromDate:[NSDate date]];
    [com  setDay:3];
    //默认过期时间为3天，为了测试，会设置过期时间为分钟级别
//    NSDateComponents *com = [calendar components:NSCalendarUnitMinute fromDate:[NSDate date]];
//    [com  setMinute:10];

    NSDate *dt = [calendar dateByAddingComponents:com toDate:[NSDate date] options:0];
    NSLog(@"用户信息过期时间: %@",dt);
    NSTimeInterval expired = [dt timeIntervalSince1970];
    return [@(expired) stringValue];
}

@end
