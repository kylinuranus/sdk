//
//  SOSLoginDbService.h
//  Onstar
//
//  Created by Genie Sun on 2016/10/27.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
@class FMDatabaseQueue;

///DB PathFile
#define LOGIN_DB_PATHFILE [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:LOGIN_DB]
///table
extern NSString *const VEHICLECOMMANDS_TABLE;
///DB
extern NSString *const LOGIN_DB;
///DB 加密的key
extern NSString *const LOGIN_DB_SECRETKEY;


@interface SOSLoginDbService : NSObject

@property(nonatomic, strong) FMDatabaseQueue *queue;
@property(nonatomic, assign) BOOL isEncrypted;

+ (SOSLoginDbService *)sharedInstance;

///创建是否加密数据库
- (instancetype) createDbByencrypt:(BOOL)isEncrypted;
///根据vin插入数据库
- (void)insertVehicleCommands:(NSString *)vin andReposeString:(NSString *)res;
///根据vin查询Commands数据
- (NSString *) searchVehicleCommands:(NSString *)vin;
///根据vin更新数据
- (void)UpdateVehicleCommands:(NSString *)vin andReposeString:(NSString *)res;

//保存token返回用户信息
- (void)insertTokenOnstarAccountReposeString:(NSString *)res;
//查询token返回用户信息
- (NSString *)searchTokenOnstarAccount;
//
- (void)UpdateTokenOnstarAccountReposeString:(NSString *)res;
///根据vin查询Privilege数据
- (NSString *)searchVehiclePrivilege:(NSString *)vin;
///根据vin插入Privilege
- (void)insertVehiclePrivilege:(NSString *)vin andReposeString:(NSString *)res;
///根据vin更新数据
- (void)UpdateVehiclePrivilege:(NSString *)vin andReposeString:(NSString *)res;
///清除数据库
- (void)clearDB;

@end
