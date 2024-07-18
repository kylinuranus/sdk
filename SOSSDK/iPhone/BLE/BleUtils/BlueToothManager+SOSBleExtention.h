//
//  BlueToothManager+SOSBleExtention.h
//  Onstar
//
//  Created by onstar on 2018/8/2.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#if __has_include(<BlePatacSDK/BlueToothManager.h>)
#import <BlePatacSDK/BlueToothManager.h>
#endif
#import "SOSBleOperationVar.h"


typedef NS_ENUM(NSInteger, SOSBleConnectStatus) {
    SOSBleConnectStatusUnConnect,  //未连接
    SOSBleConnectStatusConnecting, //连接中
    SOSBleConnectStatusConnected   //已连接
};

typedef NS_ENUM(NSInteger, SOSBleSearchDeviceStatus) {
    SOSBleSearchDeviceStatusNormal,   //完毕
    SOSBleSearchDeviceStatusSearching //搜索中
};



@interface BlueToothManager (SOSBleExtention)


/**
 连接状态
 */
@property (nonatomic, assign) SOSBleConnectStatus bleConnectStatus;

/**
Ble设备搜索状态
 */
@property (nonatomic, assign) SOSBleSearchDeviceStatus bleSearchDeviceStatus;

@property (nonatomic, strong) NSArray *bleScanDevices;

@property (nonatomic, strong) SOSBleOperationVar *bleOperationVar;


/**
 BLE模块基础配置 保罗连接设置 DB数据库设置
 */
+ (BlueToothManager *)sosConfig;

//搜索蓝牙设备
- (void)scanDevice ;

//连接蓝牙
- (void)connectedWith:(BLEModel *)bleModel result:(ConnectPeripheralHandler)handler ;

+ (void)bleSendOperation:(int)funcId;

+ (void)bleOperationSuccess:(int)funcId;

+ (void)bleOperationFailure:(int)funcId;

@end
