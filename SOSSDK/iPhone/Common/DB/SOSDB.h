//
//  SOSDB.h
//  Onstar
//
//  Created by lizhipan on 16/11/7.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

typedef void (^sqlExecCompleteBlock)(FMDatabase *db,FMResultSet *result);
@interface SOSDB : NSObject
@property(nonatomic,strong)NSMutableDictionary * queueDic;

+ (SOSDB *)sharedInstance;
/**
 @para  keyIdentify - 根据keyIdentify取得不同FMDatabaseQueue,用于有多个数据库操作情况
 */
- (void)setQueue:(NSString *)dbPath forKey:(NSString *)keyIdentify;
- (FMDatabaseQueue *)getQueueForKey:(NSString *)keyIdentify;
- (BOOL)createTableFromQueue:(NSString *)keyIdentify sqlString:(NSString *)sql;
- (BOOL)executeUpdate:(NSString *)sql queueIdentify:(NSString *)keyIdentify param:(NSArray *)param;
/**
 @para sqls - 事物处理方式批量执行语句,保证每条语句都能执行成功，否则执行回滚操作
 */
- (BOOL)executeSomeUpdates:(NSArray *)sqls queueIdentify:(NSString *)keyIdentify complete:(void(^)(BOOL complete))completeBlock;
- (void )executeQuery:(NSString *)sql queueIdentify:(NSString *)keyIdentify param:(NSArray *)param completeBlock:(sqlExecCompleteBlock)complete;//complete内不可循环调用executeQuery
@end
