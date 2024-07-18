//
//  SOSMroCommandHandler.h
//  Onstar
//
//  Created by Onstar on 2018/4/27.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOSMroCommandHandler : NSObject
@property(nonatomic,strong)SOSPOI * tbtPoi;
@property(nonatomic,weak)UINavigationController *baseController;
@property(nonatomic,copy)NSString * command;

/**
 处理车辆操作命令

 @param commandValue
 */
- (void)handleCommand:(NSString *)commandValue;

/**
 处理打开H5界面操作

 @param url
 */
- (void)handleWebOpen:(NSString *)url;
@end
