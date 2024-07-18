//
//  AroundDealerMode.h
//  Onstar
//
//  Created by 王健功 on 14-6-24.
//  Copyright (c) 2014年 Shanghai Onstar. All rights reserved.
//  周边经销商request mode，在这里发送request并处理返回的结果
//  得到request返回后有两种处理方式，RequestDidFinish代理方法和block方式

#import <Foundation/Foundation.h>
#import "RequestDataObject.h"
#import "ResponseDataObject.h"

#if NS_BLOCKS_AVAILABLE
typedef void (^DealerBlock)(id obj);
#endif

@protocol RequestDidFinish <NSObject>

- (void)requestDidFinish:(BOOL)success withObject:(id)object;

@end

@interface AroundDealerMode : NSObject {
    NSInteger currentPage;
    DealerBlock completionBlock;
    DealerBlock failureBlock;
}

@property (nonatomic, assign) int requestType;
@property (nonatomic, weak) id<RequestDidFinish> delegate;

+ (AroundDealerMode *)shareDealerMode;
+ (void)releaseDealerMode;

- (void)setCompletionBlock:(DealerBlock)aCompletionBlock;
- (void)setFailedBlock:(DealerBlock)aFailedBlock;

- (void)sendGetDealerRequest:(NNAroundDealerRequest *)dealerRequest loadPage:(NSInteger)page;

@end
