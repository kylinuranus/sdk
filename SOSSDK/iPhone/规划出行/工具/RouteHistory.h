//
//  RouteHistory.h
//  Onstar
//
//  Created by Vicky on 13-10-29.
//  Copyright (c) 2013年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RouteHistory : NSObject
@property(nonatomic, strong) NSString *originName,*x1,*y1,*originAddr;
@property(nonatomic, strong) NSString *destinateName, *x2,*y2,*destinateAddr;
@property(nonatomic,assign)int ID;

@property (nonatomic, strong) SOSPOI *beginPoi;
@property (nonatomic, strong) SOSPOI *destinationPoi;

- (id)initWithBeginPoi:(SOSPOI *)beginPoi DestinationPoi:(SOSPOI *)destinationPoi  ID:(int)aID;

- (id)initWithOriginName:(NSString *)originname x1:(NSString *)ax1 y1:(NSString *)ay1 destinateName:(NSString *)destinatename  x2:(NSString *) ax2 y2:(NSString *)ay2 ID:(int) aID originAddr:(NSString *)aoriginAddr destinateAddr:(NSString *)adestinateAddr;
///返回包含 RouteHistory 对象的数组
+ (NSMutableArray *)findAll;

/**
 *  添加路径搜索记录
 *
 *  @param originname       起点名称
 *  @param x1、y1           起点经、纬度
 *  @param destinatename    终点名称
 *  @param y1、y2           终点经、纬度
 *  @param destinateAddr    终点地址
 */
+ (void)addOriginName:(NSString *)originname x1:(NSString *)ax1 y1:(NSString *)ay1 destinateName:(NSString *)destinatename x2:(NSString *) ax2 y2:(NSString *)ay2 originAddr:(NSString *)aoriginAddr destinateAddr:(NSString *)adestinateAddr;

+ (void)addWithBeginPoi:(SOSPOI *)beginPoi DestinationPoi:(SOSPOI *)destinationPoi;

+ (void)deleteAll;
+ (void)createRouteHistoryTable;
+ (int)count;
+ (void)deleteLast;
@end
