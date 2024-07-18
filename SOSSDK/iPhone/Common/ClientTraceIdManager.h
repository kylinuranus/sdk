//
//  ClientTraceIdManager.h
//  Onstar
//
//  Created by Apple on 17/3/8.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClientTraceIdManager : NSObject

+ (ClientTraceIdManager *)sharedInstance;

@property (nonatomic, copy) NSString *UUIDidpid;

@property (nonatomic, copy) NSString *clientTraceId;//客户端trace_id，用于http header字段：CLIENT-TRACE-ID

//重置clientTraceId
- (void)resetClientTraceId;

@end
