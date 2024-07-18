//
//  SOSInfoFlowJumpHelper.h
//  Onstar
//
//  Created by TaoLiang on 2019/1/14.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSInfoFlow.h"

NS_ASSUME_NONNULL_BEGIN

@interface SOSInfoFlowJumpHelper : NSObject

@property (weak, nonatomic) __kindof  UIViewController *fromViewController;

- (instancetype)initWithFromViewController:(__kindof UIViewController *)fromViewController;

- (void)jumpTo:(SOSIFComponent *)component para:(nullable id)para;

@end

NS_ASSUME_NONNULL_END
