//
//  SOSBlePinUtil.h
//  Onstar
//
//  Created by onstar on 2018/11/11.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSBlePinUtil : NSObject

//弹出PIN验证页面(登录后)，验证pin码但不做车辆操作，比如enroll验证pin
+ (void)checkPINCodeSuccess:(void (^)(void))success ;

@end

NS_ASSUME_NONNULL_END
