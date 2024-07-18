//
//  SOSMonitor.h
//  Onstar
//
//  Created by WQ on 2018/12/11.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSMonitor : NSObject

@property(nonatomic,assign)double interval;
@property(nonatomic,retain)NSString *method;
@property(nonatomic,copy)NSString *url;
@property(nonatomic,assign)BOOL wifi;


+ (SOSMonitor *)shareInstance;
-(BOOL)needNotToSend:(NSString*)url;
-(void)startCount;
-(void)endCount;
-(void)generateBaseArrWithNoVin;
-(void)generateBaseArr;
-(void)sendMonitorInfo:(NSString*)urlStr ResultCode:(NSString*)code spanId:(NSString *)spanId responseInterval:(NSString*)rspInterval;
+(NSString *)createTraceId;

@end

NS_ASSUME_NONNULL_END
