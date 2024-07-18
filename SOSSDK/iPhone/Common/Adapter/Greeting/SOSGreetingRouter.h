//
//  SOSGreetingRouter.h
//  Onstar
//
//  Created by onstar on 2017/10/13.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSGreetingManager.h"

@interface SOSGreetingRouter : NSObject

//+ (void)routerWithType:(NSString *)linkType key:(NSString *)key;

+ (void)routerWithModel:(SOSGreetingModel *)model;

@end
