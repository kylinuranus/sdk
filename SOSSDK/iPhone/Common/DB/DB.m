//
//  OpenDB.m
//  HNMeeting
//
//  Created by 毛 炜 on 12-5-22.
//  Copyright (c) 2012年 派吉事. All rights reserved.
//

#import "DB.h"

static sqlite3 *db = nil;
@implementation DB
+ (sqlite3 *)openDB     {
    if(db)  {
        return db;
    }
    //bundle里面文件是只读的，不能修改，一旦修改程序就会损坏，导致打不开。
    //所以我们把数据库文件从bundle中copy到document文件夹里面。程序第一次启动的时候copy过去，以后就先看看document里面是否有数据库，如果有直接打开。
    //原文件路径
    NSString *originFilePath = [[NSBundle SOSBundle] pathForResource:@"NewPoiHistory" ofType:@"sqlite"];
    
    //目的路径
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *targetFilePath = [docPath stringByAppendingPathComponent:@"NewPoiHistory.sqlite"];
    
    //创建文件管理器，对文件进行copy操作
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if([fm fileExistsAtPath:targetFilePath] == NO)//document下面没有数据库文件
    {
        [fm copyItemAtPath:originFilePath toPath:targetFilePath error:nil];
    }
    //打开数据库，将数据库地址赋值给指针db
    int openStatus = -1;
    openStatus = sqlite3_open([targetFilePath UTF8String], &db);
    if (openStatus != SQLITE_OK) {
        db = nil;
    }
    return db;
}

+ (sqlite3 *)openSQLiteDB:(NSString *)dbfile_ {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    NSString *dbPath = [documentPath stringByAppendingPathComponent:dbfile_];
    sqlite3 *db;
    if(sqlite3_open([dbPath UTF8String], &db) != SQLITE_OK)
    {
        sqlite3_close(db);
        return nil;
    }
    return db;
}

//+ (sqlite3 *)closeopenSQLiteDB:(NSString *)dbfile_ {
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//
//    NSString *documentPath = [paths objectAtIndex:0];
//    NSString *dbPath = [documentPath stringByAppendingPathComponent:dbfile_];
//    sqlite3 *db;
////    if(sqlite3_close([dbPath UTF8String], &db) != SQLITE_OK)
////    {
////        sqlite3_close(db);
////        return nil;
////    }
//    return db;
//}


//如果关闭，会导致再次调用数据库失败
+ (void)closeDB     {
    if (db) 
    {
        sqlite3_close(db); 
    }
    
}@end
