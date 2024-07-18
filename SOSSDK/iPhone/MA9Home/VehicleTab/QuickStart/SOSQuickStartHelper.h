//
//  SOSLifeThirdFuncsHelper.h
//  Onstar
//
//  Created by TaoLiang on 2019/1/7.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSQSModelProtol.h"

NS_ASSUME_NONNULL_BEGIN

//该类用来过滤哪些第三方快捷键是可见的，thirdFuncsVisible根据BA提供的权限表生成
@interface SOSQuickStartHelper : NSObject
+ (instancetype)sharedInstance;
@property (strong, nonatomic) NSMutableArray<id <SOSQSModelProtol>> *selectFuncs; //
@property (strong, nonatomic) NSMutableArray<NSMutableArray <id <SOSQSModelProtol>>*> *totalShowFuncs; //全量显示数组


//TODO 优化
- (void)reloadSelectAndAllQS;
//- (void)invocationActionFromStr:(NSString *)selStr;
-(void)invocationActionFromModel:(id<SOSQSModelProtol>)modelItem;
- (BOOL)saveThirdFuncs:(NSArray<id<SOSQSModelProtol>> *)funcs;
//-(NSMutableArray<SOSQSModelProtol> *)fetchSelectQuickStart;
//-(NSMutableArray<SOSQSModelProtol> *)fetchAllQuickStart;
-(void)uploadSelectQuickIfFirstLogin;
@end

NS_ASSUME_NONNULL_END
