//
//  SOSLifeThirdFuncsHelper.m
//  Onstar
//
//  Created by TaoLiang on 2019/1/7.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSLifeThirdFuncsHelper.h"

#define RESOURCE_KEY     @"resource"
#define GENERATION_KEY   @"generation"
#define ROLE_KEY         @"role"
#define UNRELEATED_KEY   @"unReleated"


@interface SOSLifeThirdFuncsHelper ()
@property (copy, nonatomic) NSDictionary *totalThirdFuncsVisible;
@property (copy, nonatomic) NSDictionary *thirldFuncsDefault;

@end

@implementation SOSLifeThirdFuncsHelper

static SOSLifeThirdFuncsHelper *instance = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [SOSLifeThirdFuncsHelper new];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *path = [[NSBundle SOSBundle] pathForResource:@"thirdFuncsVisible" ofType:@"json"];
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        NSDictionary *thirdFuncs = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        _totalThirdFuncsVisible = thirdFuncs;
        
        NSString *defaultPath = [[NSBundle SOSBundle] pathForResource:@"thirdFuncsDefault" ofType:@"json"];
        NSData *defaultData = [[NSData alloc] initWithContentsOfFile:defaultPath];
        _thirldFuncsDefault = [NSJSONSerialization JSONObjectWithData:defaultData options:kNilOptions error:nil];
        
    }
    return self;
}


- (NSArray<id<SOSQSModelProtol>> *)filterWithServerResponse:(NSArray<id<SOSQSModelProtol>> *)serverThirdFuncs {
    if (serverThirdFuncs.count <= 0) {
        return @[];
    }
    //#1.先从本地权限表中筛选
    NSMutableArray<id<SOSQSModelProtol>> *filterdResults = @[].mutableCopy;
    [serverThirdFuncs enumerateObjectsUsingBlock:^(id<SOSQSModelProtol> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSMutableDictionary *authDic = [_totalThirdFuncsVisible[obj.modelTitle] mutableCopy];
        BOOL visible = [self judgeVisible:authDic];
        if (visible) {
                //特殊处理车主俱乐部
            if ([obj.modelTitle containsString:@"车主俱乐部"]) {
                if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
                    visible = [Util vehicleIsChevrolet] || [Util vehicleIsCadillac];
                    if (visible) {
                        obj.modelTitle = @"车主俱乐部";
                    }
                }
            }
//#ifdef SOSSDK_SDK
//            if ([obj.modelTitle isEqualToString:@"车检"]) {
//                visible = NO;
//            }
//#endif
            
            
        }
        if (visible) {
            [filterdResults addObject:obj];
        }
    }];
    _filterdTotalFuncs = filterdResults;
    NSMutableArray<id<SOSQSModelProtol>> *results = @[].mutableCopy;
#ifndef SOSSDK_SDK
    //#2.读取默认按钮或者用户编辑的按钮
    NSString *key = [self convertRoleToKeyString];
    NSArray<NSString *> *editedFuncs = [self fetchLocalStorage] ? : _thirldFuncsDefault[key];
    
    //#3.根据#1中筛选后的数据再过滤一遍#2中的按钮，看是否有按钮下架
    [editedFuncs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [filterdResults enumerateObjectsUsingBlock:^(id<SOSQSModelProtol> _Nonnull objII, NSUInteger idxII, BOOL * _Nonnull stopII) {
            if ([objII.modelTitle isEqualToString:obj]) {
                [results addObject:objII];
            }
            if (results.count == editedFuncs.count) {
                *stopII = YES;
                *stop = YES;
            }
        }];
    }];
    
    //#4.如果发现有下架的功能，同步到本地存储
    if (results.count != editedFuncs.count) {
        [self saveThirdFuncs:results];
    }
#else
    NSArray *filerArray = @[@"随星听",
                            @"星推荐",
                            @"智能互联"
                            ];
    [_filterdTotalFuncs enumerateObjectsUsingBlock:^(id<SOSQSModelProtol> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (![filerArray containsObject:obj.modelTitle]) {
            [results addObject:obj];
        };
        
    }];

#endif
    
    
    return results;
}

- (BOOL)saveThirdFuncs:(NSArray<id<SOSQSModelProtol>> *)funcs {
    NSMutableArray<NSString *> *storages = @[].mutableCopy;
    if (funcs.count <= 0) {
        return NO;
    }
    [funcs enumerateObjectsUsingBlock:^(id<SOSQSModelProtol> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [storages addObject:obj.modelTitle ? : @""];
    }];
    NSString *fileName = [[self getFileName] stringByAppendingString:@".plist"];
    NSString *filePath = [[self getThirdFuncsDirectoryPath] stringByAppendingPathComponent:fileName];
    BOOL success = [NSKeyedArchiver archiveRootObject:storages toFile:filePath];
    return success;

}

#pragma mark - Private Method

- (BOOL)judgeVisible:(NSDictionary *)authDic {
    if (!authDic) {
        return NO;
    }
    BOOL resourceVisible = [self judgeResource:authDic];
    BOOL generationVisible = [self judgeGeneration:authDic];
    BOOL roleVisible = [self judgeRole:authDic];
    return (resourceVisible && generationVisible && roleVisible);

}

//判断车的能源类型
- (BOOL)judgeResource:(NSDictionary *)authDic {
    NSDictionary *resource = authDic[RESOURCE_KEY];
    if ([resource[UNRELEATED_KEY] boolValue]) {
        return YES;
    }
    NSString *key = @"";
    if ([Util vehicleIsBEV]) {
        key = @"BEV";
    }else if ([Util vehicleIsPHEV]) {
        key = @"PHEV";
    }else {
        key = @"FV";
    }
    return [resource[key] boolValue];
}

- (BOOL)judgeGeneration:(NSDictionary *)authDic {
    NSDictionary *generation = authDic[GENERATION_KEY];
    if ([generation[UNRELEATED_KEY] boolValue]) {
        return YES;
    }
    NSString *key = @"";
    if ([Util vehicleIsG9]) {
        key = @"G9";
    }else if ([Util vehicleIsIcm]) {
        key = @"ICM";
    }else {
        key = @"G10";
    }
    return [generation[key] boolValue];
}

- (BOOL)judgeRole:(NSDictionary *)authDic {
    NSDictionary *role = authDic[ROLE_KEY];
    if ([role[UNRELEATED_KEY] boolValue]) {
        return YES;
    }
    NSString *key = [self convertRoleToKeyString];
    return [role[key] boolValue];
}


- (NSString *)convertRoleToKeyString {
    NSString *key = @"";
    if ([SOSCheckRoleUtil isVisitor]) {
        key = @"visitor";
    }else if ([SOSCheckRoleUtil isProxy]) {
        key = @"proxy";
    }else if ([SOSCheckRoleUtil isDriver]) {
        key = @"driver";
    }else if ([SOSCheckRoleUtil isOwner]) {
        key = @"owner";
    }else {
        key = @"unlogged";
    }
    return key;
}


#pragma mark - local storage
- (NSString *)getThirdFuncsDirectoryPath {
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [documentsPath stringByAppendingPathComponent:@"thirdFuncs"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

- (NSString *)getFileName {
    NSMutableString *fileName = @"".mutableCopy;
    [fileName appendString:[CustomerInfo sharedInstance].userBasicInfo.idpUserId ? : @"unKnowUser"];
    [fileName appendString:@"_"];
    [fileName appendString:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin ? : @"unKnowVin"];
    return fileName.md5String.copy;
    
}

- (nullable NSArray<NSString *> *)fetchLocalStorage {
    NSString *fileName = [[self getFileName] stringByAppendingString:@".plist"];
    NSString *filePath = [[self getThirdFuncsDirectoryPath] stringByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return nil;
    }
    NSArray<NSString *> *array = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    return array;

}


@end
