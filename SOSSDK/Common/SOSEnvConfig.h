//
//  SOSEnvConfig.h
//  Onstar
//
//  Created by onstar on 2018/5/4.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOSEnvConfig : NSObject



/**
 单例
 */
+ (instancetype)config;

/**
 开发环境or发布
 true:开发
 false:发布环境以下所有参数都不生效 上架时使用true
 */
@property (nonatomic, assign) BOOL development;



/**************************************/


/**
 msp环境
 */
@property (nonatomic, assign) NSInteger sos_env;

/**
 是否需要显示debug信息 如短信验证码,
 */
@property (nonatomic, assign) BOOL showDebugToast;


/**
 是否允许抓包
 */
@property (nonatomic, assign) BOOL enableSslCer;


//是否显示所有log
//NO:只显示错误log default:yes
@property (nonatomic, assign) BOOL enableNormalLog;

@end
