//
//  DispatchUtil.h
//  Onstar
//
//  Created by Vicky on 17/1/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestDataObject.h"
#import "ResponseDataObject.h"

@interface DispatchUtil : NSObject


+ (void)getDispatcher:(NNDispatcherReq *)req Success:(void (^)(NNURLRequest *urlRequest))completion Failed:(void (^)(void))failCompletion;
@end
