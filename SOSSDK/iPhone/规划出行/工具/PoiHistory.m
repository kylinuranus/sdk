//
//  PoiHistory.m
//  Onstar
//
//  Created by Vicky on 13-10-22.
//  Copyright (c) 2013年 Shanghai Onstar. All rights reserved.
//

#import "PoiHistory.h"
#import "SOSSearchResult.h"
#import <sqlite3.h>
#import "DB.h"

@implementation PoiHistory

+ (NSString *)getRightValue:(NSString *)key       {
    if (![key isKindOfClass:[NSString class]]) {
        return key;
    }
    NSString *tempStr = NONil(key);
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@"\'" withString:@"''"];
    return tempStr;
}

//@synthesize name,address,cityName,provinceName,tel,lon,lat,ID;
- (id)initWithPoi:(SOSPOI *)poi ID:(int)ID_  {
    self = [super init];
    
    if (self)	{
        self.name = poi.name;
        self.address = poi.address;
        self.tel = poi.tel;
        self.lon = poi.x;
        self.lat = poi.y;
        self.ID = ID_;
        self.pguid = poi.pguid;
        self.isNameSearch = 1;
    }
    return self;

}

- (SOSPOI *)poi  {
    if (!_poi) {
        SOSPOI *temPoi = [SOSPOI new];
        temPoi.x = self.lon;
        temPoi.y = self.lat;
        temPoi.tel = self.tel;
        temPoi.name = self.name;
        temPoi.pguid = self.pguid;
        temPoi.city = self.cityName;
        temPoi.address = self.address;
        temPoi.province = self.provinceName;
        _poi = temPoi;
    }
    
    return _poi;
}

- (id)initWithName:(NSString *)name address:(NSString *)address tel:(NSString *)tel lon:(NSString *)lon lat:(NSString *)lat ID:(int)ID isNameSearch:(int)isNameSearch   {
    return [self initWithName:name address:address tel:tel lon:lon lat:lat ID:ID isNameSearch:isNameSearch city:@"" Province:@""];
}

- (id)initWithName:(NSString *)aName address:(NSString *)aAddress tel:(NSString *)aTel lon:(NSString *)aLon lat:(NSString *) aLat  ID:(int) aID isNameSearch:(int)aisNameSearch city:(NSString *)city_Name Province:(NSString *)province_Name   {
    if (!(self = [super init])) return nil;
    
    if (self)	{
        self.name = aName;
        self.address = aAddress;
        self.tel = aTel;
        self.lon = aLon;
        self.lat = aLat;
        self.ID = aID;
        self.isNameSearch = aisNameSearch;
        self.cityName = city_Name;
        self.provinceName = province_Name;
    }
    return self;
}

///得到从传入值“from”开始的前20条历史记录，isSearchHistory 传入“1”表示搜索历史，“0”表示下发历史
+ (NSMutableArray *)findHistorysFrom:(int)from IsSearchHistory:(int) isSearchHistory  {
    sqlite3 *db = [DB openDB];
    
    sqlite3_stmt *stmt = nil;//创建一个声明对象
    NSString *temStr;
    if (isSearchHistory == 0) {
        temStr = [NSString stringWithFormat:@"select * from NewPoiHistory where isNameSearch = 0 order by ID desc limit %d,20", from];
    }   else if (isSearchHistory == 1)  {
        temStr = [NSString stringWithFormat:@"select * from NewPoiHistory where isNameSearch = 1 order by ID desc limit %d,20", from];
    }   else    {
        temStr = [NSString stringWithFormat:@"select * from NewPoiHistory order by ID desc limit %d,20", from];
    }
    const char *temChar = [temStr UTF8String];
    
    int result = sqlite3_prepare_v2(db, temChar, -1, &stmt, nil);
    NSMutableArray *PoiHistorys = nil;
    
    if (result == SQLITE_OK)
    {
        PoiHistorys = [[NSMutableArray alloc]init];
        while (sqlite3_step(stmt) == SQLITE_ROW)    {
            int ID = sqlite3_column_int(stmt, 0);
            
            const unsigned char *name = sqlite3_column_text(stmt, 1);
            const unsigned char *address = sqlite3_column_text(stmt, 2);
            const unsigned char *tel = sqlite3_column_text(stmt, 3);
            const unsigned char *lon = sqlite3_column_text(stmt, 4);
            const unsigned char *lat = sqlite3_column_text(stmt, 5);
            int isNameSearch = sqlite3_column_int(stmt, 6);
            const unsigned char *cityName = sqlite3_column_text(stmt, 7);
            const unsigned char *provinceName  = sqlite3_column_text(stmt, 8);
            PoiHistory *p = [[PoiHistory alloc]initWithName:[NSString stringWithUTF8String:(const char *)name]
                                                    address:[NSString stringWithUTF8String:(const char *)address]
                                                        tel:[NSString stringWithUTF8String:(const char *)tel]
                                                        lon:[NSString stringWithUTF8String:(const char *)lon]
                                                        lat:[NSString stringWithUTF8String:(const char *)lat]
                                                         ID:ID
                                               isNameSearch:isNameSearch
                                                       city:[NSString stringWithUTF8String:(const char *)cityName]
                                                   Province:[NSString stringWithUTF8String:(const char *)provinceName]];
            [PoiHistorys addObject:p];
        }
    }
    else    {
        PoiHistorys = [[NSMutableArray alloc] init];
    }
    sqlite3_finalize(stmt);
    return PoiHistorys;
}

+ (NSMutableArray *)findAll:(int) isNameSearch   {
    sqlite3 *db = [DB openDB];
    
    sqlite3_stmt *stmt = nil;//创建一个声明对象
    //查询前10条poi记录
    int result = sqlite3_prepare_v2(db, "select * from NewPoiHistory where isNameSearch = ?order by ID desc limit 0,10", -1, &stmt, nil);
    NSMutableArray *PoiHistorys = nil;
    
    if (result == SQLITE_OK)	{
        sqlite3_bind_int(stmt, 1, isNameSearch);
        PoiHistorys = [[NSMutableArray alloc]init];
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            int ID = sqlite3_column_int(stmt, 0);
            
            const unsigned char *name = sqlite3_column_text(stmt, 1);
            const unsigned char *address = sqlite3_column_text(stmt, 2);
            const unsigned char *tel = sqlite3_column_text(stmt, 3);
            const unsigned char *lon = sqlite3_column_text(stmt, 4);
            const unsigned char *lat = sqlite3_column_text(stmt, 5);
            int isNameSearch = sqlite3_column_int(stmt, 6);
            const unsigned char *cityName = sqlite3_column_text(stmt, 7);
            const unsigned char *provinceName  = sqlite3_column_text(stmt, 8);
            PoiHistory *p = [[PoiHistory alloc]initWithName:[NSString stringWithUTF8String:(const char *)name]
                                                    address:[NSString stringWithUTF8String:(const char *)address]
                                                        tel:[NSString stringWithUTF8String:(const char *)tel]
                                                        lon:[NSString stringWithUTF8String:(const char *)lon]
                                                        lat:[NSString stringWithUTF8String:(const char *)lat]
                                                         ID:ID
                                               isNameSearch:isNameSearch
                                                       city:[NSString stringWithUTF8String:(const char *)cityName]
                                                   Province:[NSString stringWithUTF8String:(const char *)provinceName]];
            [PoiHistorys addObject:p];
        }
    }	else	{
        PoiHistorys = [[NSMutableArray alloc]init];
    }
    sqlite3_finalize(stmt);
    return PoiHistorys;
}

+ (int)count     {
    sqlite3 *db = [DB openDB];
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, "select count(ID) from NewPoiHistory", -1, &stmt, nil);
    
    if (result == SQLITE_OK)	{
        int count = 0;
        if (sqlite3_step(stmt))	{
            count = sqlite3_column_int(stmt, 0);
        }
        sqlite3_finalize(stmt);
        return count;
    }	 else	{
        sqlite3_finalize(stmt);
        return 0;
    }
}

+ (PoiHistory *)findByID:(int)ID {
    sqlite3 *db = [DB openDB];
    sqlite3_stmt *stmt = nil;
    PoiHistory *p = nil;
    int result = sqlite3_prepare_v2(db, "select * from NewPoiHistory where ID = ?", -1, &stmt, nil);
    if (result == SQLITE_OK)	{
        sqlite3_bind_int(stmt, 1, ID);
        if (sqlite3_step(stmt))		{
            int ID = sqlite3_column_int(stmt, 0);
            
            const unsigned char *name = sqlite3_column_text(stmt, 1);
            const unsigned char *address = sqlite3_column_text(stmt, 2);
            const unsigned char *tel = sqlite3_column_text(stmt, 3);
            const unsigned char *lon = sqlite3_column_text(stmt, 4);
            const unsigned char *lat = sqlite3_column_text(stmt, 5);
            int isNameSearch = sqlite3_column_int(stmt, 6);
            p = [[PoiHistory alloc]initWithName:[NSString stringWithUTF8String:(const char *)name] address:[NSString stringWithUTF8String:(const char *)address] tel:[NSString stringWithUTF8String:(const char *)tel] lon:[NSString stringWithUTF8String:(const char *)lon] lat:[NSString stringWithUTF8String:(const char *)lat]  ID:ID isNameSearch:isNameSearch];
            
        }
    }
    sqlite3_finalize(stmt);
    return p;
}

+ (NSMutableArray *)findByname:(NSString *)name      {
    sqlite3 *db = [DB openDB];
    sqlite3_stmt *stmt = nil;
    
    int result = sqlite3_prepare(db, "select * from NewPoiHistory where name = ?", -1, &stmt, nil);
    NSMutableArray *PoiHistorys = nil;
    if (result == SQLITE_OK)	{
        sqlite3_bind_text(stmt, 1, [name UTF8String], -1, nil);
        
        PoiHistorys = [[NSMutableArray alloc]init];
        while (sqlite3_step(stmt) == SQLITE_ROW)	{
            int ID = sqlite3_column_int(stmt, 0);
            const unsigned char *name = sqlite3_column_text(stmt, 1);
            const unsigned char *address = sqlite3_column_text(stmt, 2);
            const unsigned char *tel = sqlite3_column_text(stmt, 3);
            const unsigned char *lon = sqlite3_column_text(stmt, 4);
            const unsigned char *lat = sqlite3_column_text(stmt, 5);
            int isNameSearch = sqlite3_column_int(stmt, 6);
            PoiHistory *p = [[PoiHistory alloc]initWithName:[NSString stringWithUTF8String:(const char *)name] address:[NSString stringWithUTF8String:(const char *)address] tel:[NSString stringWithUTF8String:(const char *)tel] lon:[NSString stringWithUTF8String:(const char *)lon] lat:[NSString stringWithUTF8String:(const char *)lat] ID:ID isNameSearch:isNameSearch];
            
            [PoiHistorys addObject:p];
            
        }
        
    }	else	 {
        PoiHistorys = [[NSMutableArray alloc]init];
    }
    sqlite3_finalize(stmt);
    return PoiHistorys;
}

+ (void)add:(SOSPOI *)poi isNameSearch:(BOOL)isNameSearch    {
    if (!poi.name.length && !poi.longitude.length && !poi.latitude.length)      return;
    NSString *str = [NSString stringWithFormat:@"insert into NewPoiHistory(name,address,tel,lon,lat,isNameSearch,cityName, provinceName) values('%@','%@','%@','%@','%@',%d,'%@','%@')",
                     [PoiHistory getRightValue:poi.name],
                     [PoiHistory getRightValue:poi.address],
                     [PoiHistory getRightValue:poi.tel],
                     [PoiHistory getRightValue:poi.x],
                     [PoiHistory getRightValue:poi.y],
                     isNameSearch,
                     [PoiHistory getRightValue:poi.city],
                     [PoiHistory getRightValue:poi.province]];
    
    sqlite3 *db = [DB openDB];
    sqlite3_stmt *stmt = nil;
    
    int result = sqlite3_prepare_v2(db, [str UTF8String],-1 ,&stmt , nil);
    if (result == SQLITE_OK)	{
        sqlite3_step(stmt);
    }
    sqlite3_finalize(stmt);
}

+ (void)addName:(NSString *)name address:(NSString *)address tel:(NSString *)tel lon:(NSString *)lon lat:(NSString *)lat isNameSearch:(int)isNameSearch     {
    if (!name.length && !lon.length && !lat.length)     return;
    [[self class] addName:name address:address tel:tel lon:lon lat:lat isNameSearch:isNameSearch cityName:@"" provinceName:@""];
}

//添加元素
+ (void)addName:(NSString *)aname address:(NSString *)aaddress tel:(NSString *)atel lon:(NSString *)alon lat:(NSString *) alat isNameSearch:(int) aisNameSearch cityName:(NSString *)_cityName provinceName:(NSString *)_provinceName    {
    NSString *str = [NSString stringWithFormat:@"insert into NewPoiHistory(name,address,tel,lon,lat,isNameSearch,cityName, provinceName) values('%@','%@','%@','%@','%@',%d,'%@','%@')",
                     [PoiHistory getRightValue:aname],
                     [PoiHistory getRightValue:aaddress],
                     [PoiHistory getRightValue:atel],
                     [PoiHistory getRightValue:alon],
                     [PoiHistory getRightValue:alat],
                     aisNameSearch,
                     [PoiHistory getRightValue:_cityName],
                     [PoiHistory getRightValue:_provinceName]];
    
    sqlite3 *db = [DB openDB];
    sqlite3_stmt *stmt = nil;
    
    int result = sqlite3_prepare_v2(db, [str UTF8String],-1 ,&stmt , nil);
    if (result == SQLITE_OK)	{
        sqlite3_step(stmt);
    }
    sqlite3_finalize(stmt);
    
}
//根据ID删除信息
+ (void)deleteByID:(int)ID   {
    NSString *str = [NSString stringWithFormat:@"delete from NewPoiHistory where ID = %d",ID];
    sqlite3 *db = [DB openDB];
    sqlite3_stmt *stmt = nil;
    
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    
    if (result == SQLITE_OK)	{
        sqlite3_step(stmt);
    }
    sqlite3_finalize(stmt);
}

//删除最后一条信息
+ (void)deleteLast   {
    NSString *str = [NSString stringWithFormat:@"delete from NewPoiHistory where ID IN(SELECT ID FROM NewPoiHistory ORDER BY ID LIMIT 0,1)"];
    sqlite3 *db = [DB openDB];
    sqlite3_stmt *stmt = nil;
    
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    
    if (result == SQLITE_OK)	{
        sqlite3_step(stmt);
    }
    sqlite3_finalize(stmt);
}


///删除所有信息,"isNameSearch"传入“1”表示清除搜索历史，“0”表示清除下发历史，传入 其它任意值 表示清除所有搜索历史
+ (void)deleteAll:(int) isNameSearch    {
    NSString *temStr;
    if (isNameSearch == 0) {
        temStr = [NSString stringWithFormat:@"delete from NewPoiHistory where isNameSearch= 0"];
    }   else if (isNameSearch == 1)  {
        temStr = [NSString stringWithFormat:@"delete from NewPoiHistory where isNameSearch= 1"];
    }   else    {
        temStr = [NSString stringWithFormat:@"delete from NewPoiHistory"];
    }
    sqlite3 *db = [DB openDB];
    sqlite3_stmt *stmt = nil;
    
    int result = sqlite3_prepare_v2(db, [temStr UTF8String], -1, &stmt, nil);
    
    if (result == SQLITE_OK)
    {
        sqlite3_step(stmt);
    }
    sqlite3_finalize(stmt);
}
//更新
+ (void)updateName:(NSString *)name address:(NSString *)aAddress tel:(NSString *)aTel lon:(NSString *)aLon lat:(NSString *) aLat isNameSearch:(int)isNameSearch forID:(int)ID    {
    NSString *str = [NSString stringWithFormat:@"update NewPoiHistory set name = '%@',address = '%@',tel = '%@' ,lon = '%@', lat = '%@' ,isNameSearch = %d where ID = %d",name,aAddress,aTel,aLon,aLat,isNameSearch,ID];
    sqlite3 *db = [DB openDB];
    sqlite3_stmt *stmt = nil;
    
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    
    if (result == SQLITE_OK) 
    {
        sqlite3_step(stmt);
        
    }
    sqlite3_finalize(stmt);
}

//通过数据库实例创建表
+ (void)createPoiHistoryTable    {
    //不带参数的sql语句
    const char* sql="create table if not exists  NewPoiHistory  (id integer primary key autoincrement,name text,address text,tel text,lon text, lat text, isNameSearch integer,cityName text, provinceName text);";
    sqlite3 *db = [DB openDB];
    char *error;
    //sqlite3_exec可以执行一切不带参数的SQL语句。如果是带参数最好不用，防止SQL注入漏洞攻击
    
    int result= sqlite3_exec(db, sql, NULL, NULL, &error);
    if(result==SQLITE_OK){
        NSLog(@"创建兴趣点表成功");
    }
    else{
        NSLog(@"创建兴趣点表失败－－》%s",error);
    }
}
@end
