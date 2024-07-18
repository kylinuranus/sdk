//
//  BlueToothManager.h
//  CoreBluetoothDemo
//
//  Created by shudingcai on 11/3/16.
//  Copyright © 2016 eamon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BleLibNotification.h"



@class BLEModel;
typedef void (^ScanPeripheral)(BLEModel *model,BlueToothScanState state);
typedef void (^CannelPeripheral)(CBPeripheral *peripheral);
//Block 机制
typedef void(^CentralManagerStateHandler)(BlueToothState state);

//连接状态监听
typedef void(^ConnectPeripheralHandler)(BlueToothConnState result, CBPeripheral *peripheral,NSError *error);

//发送状态监听
typedef void(^SendStateHandler)(SendState state);


@interface BlueToothManager : NSObject
/** 是否过滤掉其他设备 */
@property (nonatomic, assign) BOOL isFilter;

/**当前连接到的外设 */
@property (nonatomic, strong) CBPeripheral *peripheral;
/** 是否重连 */
@property (nonatomic, assign) BOOL isReconnection;



/**
 *  单例
 *
 *  @return
 */
+(instancetype)sharedInstance;

/**
 *  获取SDK版本
 *
 *  @return
 */
+(NSString *)GetSDKVersion;

/**
 *  初始化中心管理者
 */
-(CBCentralManager *)iniCenterManager;

/**
 *  获取中心管理者的状态
 */
-(BlueToothState )getCenterManagerState;


/**
 BlocK机制来监听中心的状态，只有设备状态为BlueToothStatePoweredOn 才能后面的操作，如扫描，连接等
 */
- (void)setDeviceStateObserver:(CentralManagerStateHandler)handler;




/**
 扫描外设
 
 @param block   回调
 @param service 搜索指定UUID，过滤其他设备
 */
- (void)ScanDevice:(ScanPeripheral)block  error:(NSError **)error;


/**
 *  停止扫描
 */
- (void) stopScan;
/**
 *  连接设备
 */
- (void)connectedWithPeripheral:(CBPeripheral *)peripheral  result:(ConnectPeripheralHandler)handler;
/**
 *  断开链接
 *
 *  @param peripheral 外设
 *  @param block
 */
- (void)cannelWithPeripheral:(CBPeripheral *)peripheral block:(CannelPeripheral)block;


-(BOOL)isConnected;

/**
 获取本机的UUID
 */
-(NSString *)getPHoneUUID;
//-(NSData *)getPHoneUUIDNSdata;
-(void)SendCommand:(int)function result:(SendStateHandler)handler;


@end
