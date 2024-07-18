//
//  SOSLoginDbService.m
//  Onstar
//
//  Created by Genie Sun on 2016/10/27.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//
#import <sqlite3.h>
//#import "SOSFlutterDB.h"

#import "SOSLoginDbService.h"
@implementation SOSLoginDbService

NSString *const VEHICLECOMMANDS_TABLE = @"VehicleCommands";
NSString *const VEHICLEPRIVILEGE_TABLE = @"VehiclePrivilege";
NSString *const TOKENONSTARACCOUNT_TABLE = @"TokenOnstarAccount";

NSString *const LOGIN_DB = @"LoginVehicleDB.db";
NSString *const LOGIN_DB_SECRETKEY = @"F375AEE7A789FDLSAFJEIOQJR34JRI4JIGR93209T489FR";

static SOSLoginDbService *sharedOBJ = nil;
static dispatch_once_t predicate;


+ (SOSLoginDbService *)sharedInstance    {
    dispatch_once(&predicate, ^{
        sharedOBJ = [[self alloc] createDbByencrypt:YES]; //yes加密 ，no 不加密
    });
    return sharedOBJ;
}

- (instancetype) createDbByencrypt:(BOOL)isEncrypted    {
    self.isEncrypted = isEncrypted;
    return [self initWithPath:LOGIN_DB_PATHFILE];
}

/**
 初始化多线程数据库

 @param path        数据库路径

 @return db
 */
- (instancetype)initWithPath:(NSString *)path    {
    if (self = [super init]) {
        
        _queue = [FMDatabaseQueue databaseQueueWithPath:path];

        BOOL createTableResult = [self creatTable];
        BOOL createPrivilegeTableResult  = [self creatPrivilegeTable];
        BOOL createTokenOnstarTableResult  = [self creatTokenOnstarAccountTable];

        if (createTableResult && createPrivilegeTableResult && createTokenOnstarTableResult) {
            NSLog(@"Login DB create successed!");
        }	else	{
            NSLog(@"Login DB create failed!")
        }
    }
    
    return self;
}

/**
 创建name = VEHICLEPRIVILEGE_TABLE table
  */
- (BOOL)creatPrivilegeTable    {
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement,idpidvin text,responseStr text);",VEHICLEPRIVILEGE_TABLE];
    return [self executeUpdate:sql param:nil];
}

/**
 创建name = VEHICLEPRIVILEGE_TABLE table
 */
- (BOOL)creatTokenOnstarAccountTable    {
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement,responseStr text);",TOKENONSTARACCOUNT_TABLE];
    return [self executeUpdate:sql param:nil];
}
/**
 创建name = VehicleCommands table

 @return VehicleCommands table
 */
- (BOOL) creatTable    {
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement,vin text,responseStr text);",VEHICLECOMMANDS_TABLE];
    return [self executeUpdate:sql param:nil];
}


/**
 写入db

 @param sql   sql
 @param param 数据

 @return bool
 */
- (BOOL)executeUpdate:(NSString *)sql param:(NSArray *)param    {
    __block BOOL result = NO;
    [_queue inDatabase:^(FMDatabase *db) {
        BOOL open = [db open];
//        if(![db goodConnection])	{ //无效连接
//            [self upgradeDatabase:LOGIN_DB_PATHFILE];
//        }
        if (self.isEncrypted) {
            [db setKey:LOGIN_DB_SECRETKEY];
//             [SOSFlutterDB setKey:LOGIN_DB_SECRETKEY withDB:db];
        }
        
        if (param && param.count > 0) {
            result = [db executeUpdate:sql withArgumentsInArray:param];
        } else {
            result = [db executeUpdate:sql];
        }
        if (result) {
            NSLog(@"login DB write successed!")
        }else{
            NSLog(@"login DB write failed!")
        }

        [db close];
    }];
    
    return result;
}

- (void)insertVehicleCommands:(NSString *)vin andReposeString:(NSString *)res	{
    if (!vin.length)		return;
    NSString *sql = [NSString stringWithFormat:@"insert into %@(vin, responseStr) values(?,?)",VEHICLECOMMANDS_TABLE];
    NSArray *param = @[vin,res];
    BOOL ret = [self executeUpdate:sql param:param];
    if (ret) {
        NSLog(@"login DB insert successed!");
    }else{
        NSLog(@"login DB insert failed!");
    }
}


- (NSString *) searchVehicleCommands:(NSString *)vin    {
    if (!vin.length)    return @"";
    NSString *sql = [NSString stringWithFormat:@"select responseStr from %@ where vin=?", VEHICLECOMMANDS_TABLE];
    NSArray *param = @[vin];
    return [self executeScalar:sql param:param];
}

#pragma mark - Vehicle Privilege
- (void)insertVehiclePrivilege:(NSString *)idpidvin andReposeString:(NSString *)res    {
    NSString *sql = [NSString stringWithFormat:@"insert into %@(idpidvin, responseStr) values(?,?)",VEHICLEPRIVILEGE_TABLE];
    NSArray *param = @[idpidvin,res];
    BOOL ret = [self executeUpdate:sql param:param];
    if (ret) {
        NSLog(@"Privilege Table insert successed!");
    }else{
        NSLog(@"Privilege Table insert failed!");
    }
}

- (NSString *)searchVehiclePrivilege:(NSString *)idpidvin    {
    NSString *sql = [NSString stringWithFormat:@"select responseStr from %@ where idpidvin=?", VEHICLEPRIVILEGE_TABLE];
    NSArray *param = @[idpidvin];
    return [self executeScalar:sql param:param];
}

- (void)UpdateVehiclePrivilege:(NSString *)idpidvin andReposeString:(NSString *)res    {
    NSString *sql = [NSString stringWithFormat:@"update %@ set responseStr=? where idpidvin=?",VEHICLEPRIVILEGE_TABLE];
    NSArray *param = @[res,idpidvin];
    
    BOOL ret = [self executeUpdate:sql param:param];
    if (ret) {
        NSLog(@"Privilege Table update successed!");
    }else{
        NSLog(@"Privilege Table update failed!");
    }
}

#pragma mark - Token OnstarAccount
- (void)insertTokenOnstarAccountReposeString:(NSString *)res    {
    NSString *sql = [NSString stringWithFormat:@"insert into %@(responseStr) values(?)",TOKENONSTARACCOUNT_TABLE];
    NSArray *param = @[res];
    BOOL ret = [self executeUpdate:sql param:param];
    if (ret) {
        NSLog(@"Token Account Table insert successed!");
    }else{
        NSLog(@"Token Account Table insert failed!");
    }
}

- (NSString *)searchTokenOnstarAccount    {
    NSString *sql = [NSString stringWithFormat:@"select responseStr from %@", TOKENONSTARACCOUNT_TABLE];
    return [self executeScalar:sql param:nil];
}

- (void)UpdateTokenOnstarAccountReposeString:(NSString *)res    {
    NSString *sql = [NSString stringWithFormat:@"update %@ set responseStr=?",TOKENONSTARACCOUNT_TABLE];
    NSArray *param = @[res];
    
    BOOL ret = [self executeUpdate:sql param:param];
    if (ret) {
        NSLog(@"Token Account Table update successed!");
    }else{
        NSLog(@"Token Account Tablee update failed!");
    }
}
/**
 search from db

 @param sql   sql
 @param param param

 @return data
 */
- (id)executeScalar:(NSString *)sql param:(NSArray *)param    {
    __block id result;
    
    [_queue inDatabase:^(FMDatabase *db) {
        [db open];
        if (self.isEncrypted) {
            [db setKey:LOGIN_DB_SECRETKEY];
//            [SOSFlutterDB setKey:LOGIN_DB_SECRETKEY withDB:db];
        }
        
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:param];
        if ([rs next]) {
            result = rs[0];
        } else {
            result = 0;
        }
        [rs close];
        [db close];
    }];
    return result;
}

- (void)UpdateVehicleCommands:(NSString *)vin andReposeString:(NSString *)res    {
    NSString *sql = [NSString stringWithFormat:@"update %@ set responseStr=? where vin=?",VEHICLECOMMANDS_TABLE];
    NSArray *param = @[res,vin];

    BOOL ret = [self executeUpdate:sql param:param];
    if (ret) {
        NSLog(@"login DB update successed!");
    }else{
        NSLog(@"login DB update failed!");
    }
}

- (void)clearDB    {
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:LOGIN_DB_PATHFILE error:&error];
    if (error) {
        NSLog(@"%@", [NSString stringWithFormat:@"%@ DB 删除失败",VEHICLECOMMANDS_TABLE]);
    }    else    {
        predicate = 0;
        sharedOBJ = nil;
    }
}

#pragma mark - 升级数据库
- (void)upgradeDatabase:(NSString *)path    {
    NSString *tmppath = [self changeDatabasePath:path];
    if(tmppath){
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:LOGIN_DB_PATHFILE error:&error];
//        _queue = [FMDatabaseQueue databaseQueueWithPath:path];
//        BOOL createTableResult = [self creatTable];
//        BOOL createPrivilegeTableResult  = [self creatPrivilegeTable];
//        BOOL createTokenOnstarTableResult  = [self creatTokenOnstarAccountTable];

        const char* sqlQ = [[NSString stringWithFormat:@"ATTACH DATABASE '%@' AS encrypted KEY '%@';",path,LOGIN_DB_SECRETKEY] UTF8String];
        sqlite3 *unencrypted_DB;
        if (sqlite3_open([tmppath UTF8String], &unencrypted_DB) == SQLITE_OK) {

            // Attach empty encrypted database to unencrypted database
            sqlite3_exec(unencrypted_DB, sqlQ, NULL, NULL, NULL);

            // export database
            sqlite3_exec(unencrypted_DB, "SELECT sqlcipher_export('encrypted');", NULL, NULL, NULL);

            // Detach encrypted database
            sqlite3_exec(unencrypted_DB, "DETACH DATABASE encrypted;", NULL, NULL, NULL);

            sqlite3_close(unencrypted_DB);

            //delete tmp database
            NSError *error;
            [[NSFileManager defaultManager] removeItemAtPath:tmppath error:&error];
        }
        else {
            sqlite3_close(unencrypted_DB);
            NSAssert1(NO, @"Failed to open database with message '%s'.", sqlite3_errmsg(unencrypted_DB));
        }
    }
}

- (NSString *)changeDatabasePath:(NSString *)path{
    NSError * err = NULL;
    NSFileManager * fm = [[NSFileManager alloc] init];
    NSString *tmppath = [NSString stringWithFormat:@"%@.tmp",path];
    BOOL result = [fm moveItemAtPath:path toPath:tmppath error:&err];
    if(!result){
        NSLog(@"Error: %@", err);
        return nil;
    }else{
        return tmppath;
    }
}

@end
