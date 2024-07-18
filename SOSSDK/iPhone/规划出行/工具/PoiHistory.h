//
//  Person.h
//  Onstar
//
//  Created by Vicky on 13-10-22.
//  Copyright (c) 2013年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SOSPOI;
@interface PoiHistory : NSObject

@property (nonatomic, strong) SOSPOI *poi;

@property(nonatomic,strong)NSString *name, *address, *tel, *cityName, *provinceName, *pguid;
@property(nonatomic,strong)NSString *lon, *lat;
@property(nonatomic,assign)int ID;
///是否为搜索历史，“1”表示搜索历史，“0”表示下发历史
@property(nonatomic,assign)int isNameSearch;
- (id)initWithPoi:(SOSPOI *)poi ID:(int) ID;
/// 得到前20条下发历史记录，传入“1”表示搜索历史，“0”表示下发历史
//+ (NSMutableArray *)findAllByIsSearchHistory:(int) isSearchHistory;

///得到从传入值“from”开始的前20条历史记录，"isSearchHistory"传入“1”得到搜索历史，“0”得到下发历史，传入 其它任意值 得到混合搜索历史
+ (NSMutableArray *)findHistorysFrom:(int)from IsSearchHistory:(int) isSearchHistory;
+ (int)count;
+ (PoiHistory *)findByID:(int)ID;
+ (NSMutableArray *)findByname:(NSString *)name;

///isNameSearch 是否为搜索历史，YES 表示搜索历史，NO 表示下发历史
+ (void)add:(SOSPOI *)poi isNameSearch:(BOOL)isNameSearch;
+ (void)addName:(NSString *)name address:(NSString *)address tel:(NSString *)tel lon:(NSString *)lon lat:(NSString *)lat isNameSearch:(int)isNameSearch;
+ (void)deleteLast;
///删除所有信息,"isNameSearch"传入“1”表示清除搜索历史，“0”表示清除下发历史，传入 其它任意值 表示清除所有搜索历史
+ (void)deleteAll:(int) isNameSearch;
+ (void)updateName:(NSString *)name address:(NSString *)aAddress tel:(NSString *)aTel lon:(NSString *)aLon lat:(NSString *) aLat isNameSearch:(int) isNameSearch forID:(int)ID ;
+ (void)createPoiHistoryTable;
@end
