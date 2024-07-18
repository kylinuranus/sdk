//
//  SOSBleOperationVar.h
//  Onstar
//
//  Created by onstar on 2018/10/30.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __has_include(<BlePatacSDK/BlueToothManager.h>)
#import <BlePatacSDK/BLEModel.h>
#endif
#define SOSBleTimerNotificationName  @"SOSBleTimerNotificationName"

NS_ASSUME_NONNULL_BEGIN

@interface SOSBleOperationVar : NSObject
{
    @public
    dispatch_source_t _timer;
}
@property (nonatomic, assign) BOOL operating;//是否正在执行车辆操作
@property (nonatomic, assign) int seconds;
@property (nonatomic, strong) BLEModel *connectingBleModel;//正在z连接的车
- (void)startTimer;

- (void)stopTiming;
@end

NS_ASSUME_NONNULL_END
