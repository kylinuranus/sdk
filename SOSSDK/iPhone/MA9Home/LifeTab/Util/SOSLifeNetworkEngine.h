//
//  SOSLifeNetworkEngine.h
//  Onstar
//
//  Created by TaoLiang on 2019/1/3.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^SOSLifeCompletionBlock)(id data);
typedef void (^SOSLifeErrorBlock)(NSInteger statusCode, NSString *responseStr, NSError *error);

NS_ASSUME_NONNULL_BEGIN

@interface SOSLifeNetworkEngine : NSObject

@end

NS_ASSUME_NONNULL_END
