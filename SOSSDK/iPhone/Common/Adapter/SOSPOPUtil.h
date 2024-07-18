//
//  SOSLoginRequest.h
//  Onstar
//
//  Created by onstar on 2018/1/30.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSInsuranceModel.h"

@interface SOSPOPUtil : NSObject

/**
登录后获取保险弹框信息
 */
+ (void)getInsurancePromptSuccess:(void (^)(SOSInsuranceModel *insuranceModel))completion
                           Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion;

@end
