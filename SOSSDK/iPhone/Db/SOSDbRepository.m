//
//  DbRepository.m
//  Onstar
//
//  Created by 梁元 on 2022/12/14.
//  Copyright © 2022 Shanghai Onstar. All rights reserved.
//

#import "SOSDbRepository.h"
#import "FMDB.h"
#import "SOSTrackEvent.h"
 
 

///DB PathFile
#define LOGIN_USER_DB_PATHFILE [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:LOGIN_USER_DB]

static NSString *const USER_TABLE = @"SOSDaap";
static NSString *const LOGIN_USER_DB = @"SOSDaap.sqlite";
static NSString *const LOGIN_USER_DB_SECRETKEY = @"F375AEE7A789FDLSAFJEIOQJR34JRI4JIGR93209T489FR";



@interface SOSDbRepository()
@property(nonatomic, strong) FMDatabaseQueue *queue;
@property(nonatomic, assign) BOOL isEncrypted;
@end


@implementation SOSDbRepository

+ (SOSDbRepository *)sharedInstance
{
    static SOSDbRepository *sharedOBJ = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedOBJ = [[self alloc] init];
        
    });
    return sharedOBJ;
}

-(id) init{
    
    id myself=[super init];
    if(myself){
        
        [self createDbByencrypt:false];
    }
    return  myself;
}



- (instancetype) createDbByencrypt:(BOOL)isEncrypted
{
    self.isEncrypted = isEncrypted;
    return [self initWithPath:LOGIN_USER_DB_PATHFILE];
}

- (instancetype)initWithPath:(NSString *)path{
    
    if (self = [super init]) {
        _queue = [FMDatabaseQueue databaseQueueWithPath:path];
        NSLog(@"埋点数据- DB path: %@",path);
        [self creatTable];
         
    }
    return self;
}

- (BOOL)creatTable
{
    
//    NSString *sql2 = [NSString stringWithFormat:@"DROP TABLE %@",USER_TABLE];
//
//    NSLog(@"creatTablesql=%@",sql2);
//     [self executeUpdate:sql2 param:nil];
//
//    return  true;
    
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id integer primary key,Mid text not null,Did text not null,Aid text not null,Sid text not null,Svid text not null,Ts text not null,D text not null,isImmediately integer not null);",USER_TABLE];

    NSLog(@"埋点数据库创建表-sql=%@",sql);
    
    BOOL ret=[self executeUpdate:sql param:nil];
    
    if (ret) {
        NSLog(@"  Create DB successed!");
    }else{
        NSLog(@" Create DB failed!");
    }
    return ret;
}



- (BOOL)executeUpdate:(NSString *)sql param:(NSArray *)param    {
    __block BOOL result = NO;
    [_queue inDatabase:^(FMDatabase *db) {
         [db open];
        if (self.isEncrypted) {
            [db setKey:LOGIN_USER_DB_SECRETKEY];
 
        }
        if (param && param.count > 0) {
            result = [db executeUpdate:sql withArgumentsInArray:param];
        } else {
            result = [db executeUpdate:sql];
        }
        if (result) {
            //NSLog(@"executeUpdate successed!");
        }else{
           // NSLog(@"executeUpdate failed!");
        }

        [db close];
    }];
    
    return result;
}



- (NSArray*)executeScalar:(NSString *)sql param:(NSArray *)param
{
    NSMutableArray *dataArray=[NSMutableArray new];
    [_queue inDatabase:^(FMDatabase *db) {
        [db open];
        if (self.isEncrypted) {
            [db setKey:LOGIN_USER_DB_SECRETKEY];
        }
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:param];
        
    
        while ([rs next]) {
             
            SOSTrackEvent* model=[[SOSTrackEvent alloc] init];
            model.id2=[rs  intForColumn:@"id"]?[rs  intForColumn:@"id"]:0;
            model.mid=[rs  stringForColumn:@"mid"]?[rs  stringForColumn:@"mid"]:@"";
            model.sid=[rs  stringForColumn:@"Sid"]?[rs  stringForColumn:@"Sid"]:@"";
            model.sVid=[rs  stringForColumn:@"SVid"]?[rs  stringForColumn:@"SVid"]:@"";
            model.aid=[rs  stringForColumn:@"aid"]?[rs  stringForColumn:@"aid"]:@"";
            model.isImmediately=[rs  stringForColumn:@"isImmediately"]?[rs  stringForColumn:@"isImmediately"]:0;
            model.d=[rs  stringForColumn:@"D"]?[rs  stringForColumn:@"D"]:@"";
            model.ts=[rs  stringForColumn:@"ts"]?[rs  stringForColumn:@"ts"]:@"";
            model.did=[rs  stringForColumn:@"did"]?[rs  stringForColumn:@"did"]:@"";
            
            [dataArray addObject:model];
            
        }
    
        [rs close];
        [db close];
    }];
    
    return [dataArray copy];
}




-(BOOL) add:(SOSTrackEvent*) model{
    
    NSString *sql = [NSString stringWithFormat:@"insert into %@(id,Mid,Did,Aid,Sid,Svid,Ts, D,isImmediately) values(?,?,?,?,?,?,?,?,?)",USER_TABLE];
    NSArray *param = @[
                       @(model.id2),
                        model.mid,
                        model.did,
                        model.aid,
                        model.sid,
                         model.sVid,
                         model.ts,
                          model.d,
                         @(model.isImmediately)
                         
                        
                    ];
    

    NSLog(@"埋点数据库添加-sql-param=%@",param);
    
    BOOL ret = [self executeUpdate:sql param:param];
    if (ret) {
        NSLog(@"  insert DB successed!");
    }else{
        NSLog(@" insert DB failed!");
    }
    return ret;
}

 

-(BOOL) deleteData:(NSArray*) dataArray{
    
    NSMutableString *idStr=[NSMutableString new];
    for(SOSTrackEvent* model  in dataArray){
        
        [idStr appendFormat:@"%ld,",  (long)model.id2];
    }
    
    NSString *newIdStr;
    if(idStr.length>0){
        
        newIdStr  = [idStr substringToIndex:[idStr length] - 1];
    }
     
    NSString *sql = [NSString stringWithFormat:@"delete FROM %@  where id in(%@) ",USER_TABLE,newIdStr];
    NSLog(@"埋点数据库删除-sql=%@",sql);
    BOOL ret = [self executeUpdate:sql param:nil];
    
    if (ret) {
        NSLog(@"deleteData successed!");
    }else{
        NSLog(@"deleteDatafailed!");
    }
    
    return  ret;
    
}
 
-(BOOL) updateImmediately:(SOSTrackEvent*) model{
    
    NSString *sql = [NSString stringWithFormat:@"update %@  set isImmediately=%@ where id=%ld",USER_TABLE,@(model.isImmediately),(long)model.id2];
    NSLog(@"埋点数据库修改-sql=%@",sql);
    BOOL ret = [self executeUpdate:sql param:nil];
    if (ret) {
        NSLog(@"updateImmediately successed!");
    }else{
        NSLog(@"updateImmediately failed!");
    }
    return ret;
}

-(NSArray*) query:(int) limit  {
    
    NSString *sql = [NSString stringWithFormat:@"select * from  %@ where isImmediately=0   order by ts limit %d ",USER_TABLE,limit];
    NSLog(@"埋点数据库查询-sql=%@",sql);
    NSArray *ret = [self executeScalar:sql param:nil];
    NSLog(@"查询数据库数据=%@",ret);
    if (ret) {
       // NSLog(@"query successed!");
    }else{
       // NSLog(@"query failed!");
    }
 
    return ret;
}

@end
