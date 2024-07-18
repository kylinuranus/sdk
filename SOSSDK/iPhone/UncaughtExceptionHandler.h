//
//  UncaughtExceptionHandler.h
//  SOSSDKDemo_Example
//
//  Created by 梁元 on 2022/3/30.
//  Copyright © 2022 com.onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
 

NS_ASSUME_NONNULL_BEGIN

@interface UncaughtExceptionHandler : NSObject



/*!
 *  异常的处理方法
 *
 *  @param install   是否开启捕获异常
 *  @param showAlert 是否在发生异常时弹出alertView
 */
+ (void)installUncaughtExceptionHandler:(BOOL)install showAlert:(BOOL)showAlert;
 
@end

NS_ASSUME_NONNULL_END
