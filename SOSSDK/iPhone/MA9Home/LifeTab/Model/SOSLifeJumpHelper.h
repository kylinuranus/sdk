//
//  SOSLifeJumpHelper.h
//  Onstar
//
//  Created by TaoLiang on 2019/1/10.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSLifeJumpHelper : NSObject

@property (weak, nonatomic) __kindof  UIViewController *fromViewController;

- (instancetype)initWithFromViewController:(__kindof UIViewController *)fromViewController;

- (void)jumpTo:(nonnull NSString *)title para:(nullable id)para;


@end

NS_ASSUME_NONNULL_END
