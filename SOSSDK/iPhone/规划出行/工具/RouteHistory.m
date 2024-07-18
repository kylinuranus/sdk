//
//  RouteHistory.m
//  Onstar
//
//  Created by Vicky on 13-10-29.
//  Copyright (c) 2013年 Shanghai Onstar. All rights reserved.
//
#import "DB.h"
#import "RouteHistory.h"
#import "SOSSearchResult.h"

@implementation RouteHistory
@synthesize originName,destinateName,x1,y1,x2,y2,ID,originAddr,destinateAddr;

- (void)setBeginPoi:(SOSPOI *)beginPoi  {
    self.originName = beginPoi.name;
    self.x1 = beginPoi.x;
    self.y1 = beginPoi.y;
    self.originAddr = beginPoi.address;
}

- (void)setDestinationPoi:(SOSPOI *)destinationPoi  {
    self.destinateName = destinationPoi.name;
    self.x2 = destinationPoi.x;
    self.y2 = destinationPoi.y;
    self.destinateAddr = destinationPoi.address;
}

- (SOSPOI *)beginPoi    {
    SOSPOI *poi = [[SOSPOI alloc] init];
    poi.name = self.originName;
    poi.x = self.x1;
    poi.y = self.y1;
    poi.address = self.originAddr;
    return poi;
}

- (SOSPOI *)destinationPoi      {
    SOSPOI *poi = [[SOSPOI alloc] init];
    poi.name = self.destinateName;
    poi.x = self.x2;
    poi.y = self.y2;
    poi.address = self.destinateAddr;
    return poi;
}

- (id)initWithOriginName:(NSString *)originname x1:(NSString *)ax1 y1:(NSString *)ay1 destinateName:(NSString *)destinatename  x2:(NSString *) ax2 y2:(NSString *)ay2 ID:(int) aID originAddr:(NSString *)aoriginAddr destinateAddr:(NSString *)adestinateAddr     {
    if (!(self = [super init])) return nil;
    
    if (self)
    {
        self.originName = originname;
        self.destinateName = destinatename;
        self.x1  = ax1;
        self.y1 = ay1;
        self.x2 = ax2;
        self.y2 = ay2;
        self.ID = aID;
        self.originAddr =aoriginAddr;
        self.destinateAddr = adestinateAddr;
    }
    return self;
}

- (id)initWithBeginPoi:(SOSPOI *)beginPoi DestinationPoi:(SOSPOI *)destinationPoi  ID:(int)aID    {
    self = [super init];
    if (self) {
        self.originName = beginPoi.name;
        self.destinateName = destinationPoi.name;
        self.x1  = beginPoi.x;
        self.y1 = beginPoi.y;
        self.x2 = destinationPoi.x;
        self.y2 = destinationPoi.y;
        self.ID = aID;
        self.originAddr = beginPoi.address;
        self.destinateAddr = destinationPoi.address;
    }
    return self;
}

+ (NSMutableArray *)findAll     {
    sqlite3 *db = [DB openDB];
    
    sqlite3_stmt *stmt = nil;//创建一个声明对象
    
    int result = sqlite3_prepare_v2(db, "select * from NewRouteHistory order by ID desc limit 0,10", -1, &stmt, nil);
    NSMutableArray *RouteHistorys = nil;
    
    if (result == SQLITE_OK)
    {
        
        RouteHistorys = [[NSMutableArray alloc]init];
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            int ID = sqlite3_column_int(stmt, 0);
            
            const unsigned char *originName = sqlite3_column_text(stmt, 1);
            const unsigned char *x1 = sqlite3_column_text(stmt, 2);
            const unsigned char *y1 = sqlite3_column_text(stmt, 3);
            const unsigned char *destinateName = sqlite3_column_text(stmt, 4);
            const unsigned char *x2 = sqlite3_column_text(stmt, 5);
            const unsigned char *y2 = sqlite3_column_text(stmt, 6);
            const unsigned char *originAddr = sqlite3_column_text(stmt, 7);
            const unsigned char *destinateAddr = sqlite3_column_text(stmt, 8);
            RouteHistory *r = [[RouteHistory alloc]initWithOriginName:[NSString stringWithUTF8String:(const char *)originName]
                                                                   x1:[NSString stringWithUTF8String:(const char *)x1]
                                                                   y1:[NSString stringWithUTF8String:(const char *)y1]
                                                        destinateName:[NSString stringWithUTF8String:(const char *)destinateName]
                                                                   x2:[NSString stringWithUTF8String:(const char *)x2]
                                                                   y2:[NSString stringWithUTF8String:(const char *)y2]
                                                                   ID:ID
                                      originAddr:[NSString stringWithUTF8String:(const char *)originAddr] destinateAddr:[NSString stringWithUTF8String:(const char *)destinateAddr]];
            [RouteHistorys addObject:r];
        }
    }
    else
    {
        [RouteHistory createRouteHistoryTable];
        RouteHistorys = [[NSMutableArray alloc]init];
    }
    sqlite3_finalize(stmt);
    return RouteHistorys;
}

+ (void)addWithBeginPoi:(SOSPOI *)beginPoi DestinationPoi:(SOSPOI *)destinationPoi  {
    [RouteHistory addOriginName:beginPoi.name x1:beginPoi.x y1:beginPoi.y destinateName:destinationPoi.name x2:destinationPoi.x y2:destinationPoi.y originAddr:beginPoi.address destinateAddr:destinationPoi.address];
}

//+ (RouteHistory *)findByID:(int)ID;
+ (void)addOriginName:(NSString *)originname x1:(NSString *)ax1 y1:(NSString *)ay1 destinateName:(NSString *)destinatename x2:(NSString *) ax2 y2:(NSString *)ay2 originAddr:(NSString *)aoriginAddr destinateAddr:(NSString *)adestinateAddr     {
    NSString *str = [NSString stringWithFormat:@"insert into NewRouteHistory(originName,x1,y1,destinateName,x2,y2,originAddr,destinateAddr) values('%@','%@','%@','%@','%@','%@','%@','%@')",originname,ax1,ay1,destinatename,ax2,ay2,aoriginAddr,adestinateAddr];
    
    sqlite3 *db = [DB openDB];
    sqlite3_stmt *stmt = nil;
    
    int result = sqlite3_prepare_v2(db, [str UTF8String],-1 ,&stmt , nil);
    if (result == SQLITE_OK)
    {
        sqlite3_step(stmt);
    }
    sqlite3_finalize(stmt);
}
+ (void)deleteAll     {
    NSString *str = [NSString stringWithFormat:@"delete from NewRouteHistory"];
    sqlite3 *db = [DB openDB];
    sqlite3_stmt *stmt = nil;
    
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    
    if (result == SQLITE_OK)
    {
        sqlite3_step(stmt);
    }
    sqlite3_finalize(stmt);
}
+ (void)createRouteHistoryTable     {
    //不带参数的sql语句
    const char* sql="create table if not exists  NewRouteHistory  (id integer primary key autoincrement,originName text,x1 text,y1 text,destinateName text, x2 text, y2 text,originAddr text, destinateAddr text);";
    sqlite3 *db = [DB openDB];
    char *error;
    //sqlite3_exec可以执行一切不带参数的SQL语句。如果是带参数最好不用，防止SQL注入漏洞攻击
    
    int result= sqlite3_exec(db, sql, NULL, NULL, &error);
    if(result==SQLITE_OK){
        NSLog(@"创建路径表成功");
    }
    else{
        NSLog(@"创建路径表失败－－》%s",error);
    }

}

+ (int)count     {
    sqlite3 *db = [DB openDB];
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, "select count(ID) from NewRouteHistory", -1, &stmt, nil);
    
    if (result == SQLITE_OK)
    {
        int count = 0;
        if (sqlite3_step(stmt))
        {
            count = sqlite3_column_int(stmt, 0);
        }
        sqlite3_finalize(stmt);
        return count;
    }
    else
    {
        sqlite3_finalize(stmt);
        return 0;
    }
}
//删除最后一条信息
+ (void)deleteLast     {
    NSString *str = [NSString stringWithFormat:@"delete from NewRouteHistory where ID IN(SELECT ID FROM NewRouteHistory ORDER BY ID LIMIT 0,1)"];
    sqlite3 *db = [DB openDB];
    sqlite3_stmt *stmt = nil;
    
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    
    if (result == SQLITE_OK)
    {
        sqlite3_step(stmt);
    }
    sqlite3_finalize(stmt);
}


@end
