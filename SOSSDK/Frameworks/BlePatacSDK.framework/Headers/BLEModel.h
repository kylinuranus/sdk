//
//  BLEModel.h
//  CoreBluetoothDemo
//
//  Created by shudingcai on 11/3/16.
//  Copyright © 2016 eamon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BLEModel : NSObject

@property (nonatomic,strong)  NSString *BleName;
@property (nonatomic, strong) NSNumber *RSSI;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic,assign)  BOOL bConnectStatus;


@end
