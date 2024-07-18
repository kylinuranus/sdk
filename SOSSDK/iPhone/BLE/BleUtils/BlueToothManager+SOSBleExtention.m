//
//  BlueToothManager+SOSBleExtention.m
//  Onstar
//
//  Created by onstar on 2018/8/2.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "BlueToothManager+SOSBleExtention.h"
#import <BlePatacSDK/DBManager.h>
#import <BlePatacSDK/BLEModel.h>
#import "SOSBleUtil.h"
#import "SOSBleUserCarOperationViewController.h"

@interface BlueToothManager ()
@property (nonatomic, strong) NSArray *bleScanDevices;
@end
static NSTimeInterval startTime;
@implementation BlueToothManager (SOSBleExtention)

- (SOSBleConnectStatus)bleConnectStatus {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setBleConnectStatus:(SOSBleConnectStatus)bleStatu {
    objc_setAssociatedObject(self, @selector(bleConnectStatus), @(bleStatu), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SOSBleSearchDeviceStatus)bleSearchDeviceStatus {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setBleSearchDeviceStatus:(SOSBleSearchDeviceStatus)bleSearchDeviceStatus {
    objc_setAssociatedObject(self, @selector(bleSearchDeviceStatus), @(bleSearchDeviceStatus), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (SOSBleOperationVar *)bleOperationVar {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBleOperationVar:(SOSBleOperationVar *)bleOperationVar {
    objc_setAssociatedObject(self, @selector(bleOperationVar), bleOperationVar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)bleScanDevices {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBleScanDevices:(NSArray *)bleScanDevices {
    objc_setAssociatedObject(self, @selector(bleScanDevices), bleScanDevices, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (BlueToothManager *)sosConfig {
    [[DBManager sharedInstance] managedObjectContext:bledbkey];
    BlueToothManager *manager = [BlueToothManager sharedInstance];
    manager.isReconnection = NO;// 是否支持重连。
//    manager.isFilter = YES; //是否只显示上汽通用的汽车蓝牙设备。
    [manager iniCenterManager];
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    [notiCenter addObserver:manager selector:@selector(receiveBLEMessageNotification:) name:Notification_FUN_RES object:nil];
    [notiCenter addObserver:manager selector:@selector(receiveBLEMessageNotification:) name:Notification_FUN_RES_NO object:nil];
//    [notiCenter addObserver:manager selector:@selector(receiveBLEMessageNotification:) name:BLE_CONNECT_Result_Notification object:nil];
//    [notiCenter addObserver:manager selector:@selector(receiveBLEMessageNotification:) name:Notification_ERROR_RES object:nil];

    manager.bleOperationVar = [[SOSBleOperationVar alloc] init];
    return manager;
}

- (void)scanDevice {
    NSMutableArray *devices = @[].mutableCopy;
    self.bleScanDevices = devices.copy;
    NSArray *localKeys = [[DBManager sharedInstance] GetSomeKeyInDB:INT_MAX];
    if (localKeys.count == 0) {
        //本地无钥匙 不搜索设备
        self.bleSearchDeviceStatus = SOSBleSearchDeviceStatusNormal;
        return;
    }
    
    if (self.bleSearchDeviceStatus == SOSBleSearchDeviceStatusSearching) {
        [self stopScan];
    }
    
    self.bleSearchDeviceStatus = SOSBleSearchDeviceStatusSearching;
    NSError *scanError;
    
    [self ScanDevice:^(BLEModel *model, BlueToothScanState state) {
        if (state == ScanOK ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"name is: %@",model.BleName);
                if (![self arrayContainModel:model devices:devices]) {
                    BOOL connect = [[BlueToothManager sharedInstance] isConnected];
                    if (!connect) {
                        model.bConnectStatus = NO;
                    }
                    [devices addObject:model];
                    self.bleScanDevices = devices.copy;
                }
            });
        }
        else if(state == ScanTimeout) //扫描超时
        {
            [self stopScan];
            self.bleSearchDeviceStatus = SOSBleSearchDeviceStatusNormal;
        }
        else if(state == ScanBlueToothStateError) //扫描前设备没有初始化好
        {
           self.bleSearchDeviceStatus = SOSBleSearchDeviceStatusNormal;
        }
    } error:&scanError];
}

- (BOOL)arrayContainModel:(BLEModel *)model devices:(NSArray *)devices {
    for (BLEModel *m in devices) {
        if ([m.BleName isEqualToString:model.BleName]) {
            return YES;
        }
    }
    return NO;
}


//连接
- (void)connectedWith:(BLEModel *)bleModel result:(ConnectPeripheralHandler)handler {
    if (self.bleConnectStatus == SOSBleConnectStatusConnecting) {
        return;
    }
    self.bleConnectStatus = SOSBleConnectStatusConnecting;
    self.bleOperationVar.connectingBleModel = bleModel;
    [self connectedWith:bleModel index:0 result:handler];
}

- (void)connectedWith:(BLEModel *)bleModel
                index:(NSInteger)index
               result:(ConnectPeripheralHandler)handler {
    //1.遍历本地所有钥匙 一个一个试
//    NSArray <VKeyEntity *>*validKeys = [SOSBleUtil selectAllKeysWithVin:bleModel.BleName];
//    DBManager *manager =[DBManager sharedInstance];
//    [manager UseThisKeyellData:validKeys[index].vkno Result:^(BOOL b, NSError *error) {
//        if (b) {
            [self connectedWithPeripheral:bleModel.peripheral result:^(BlueToothConnState result, CBPeripheral *peripheral, NSError *error) {
                
                switch (result) {
                    case BlueToothConnAuthenticationFAIl:
                        NSLog(@"钥匙认证没有通过（参考BleCarkey错误类型）");
                        break;
                    case BlueToothConnStateConnectingFailure:
                        NSLog(@"正在连接中请勿再连接");
                        break;
                    case BlueToothConnStateLostconnect:
                        NSLog(@"丢失连接");
                        self.bleScanDevices = @[];
                        self.bleConnectStatus = SOSBleConnectStatusUnConnect;
                        !handler?:handler(result,peripheral,error);
                        [BlueToothManager sharedInstance].bleOperationVar.operating = NO;
                        break;
                    case BlueToothConnStateUnKnown:
                        NSLog(@"未知状态（初始状态）!");
                        break;
                        
                    case BlueToothConnStateDeviceNotSuport:
                        NSLog(@"此设备不支持!");
                        break;
                    case BlueToothConnStateConnectionFailure: // 连接失败
                        NSLog(@"连接失败");
                        break;
                    case BlueToothConnStateConnectionTimeout:
                        // 连接超时
                        NSLog(@"连接超时");
                        break;
                        
                    case BlueToothConnStateConnected:
                        NSLog(@"连接成功，非安全连接成功，后续钥匙认证不过，断开。");
                        break;
                    case BlueToothConnKeyAuthenticationTimeout:
                        NSLog(@"钥匙认证超时，没有建立安全连接，不能通信。");
                        break;
                    case BlueToothConnStateDisconnect:
                        NSLog(@"连接断开。");
//                        if (index < validKeys.count - 1) {
//                            [self connectedWith:bleModel index:index+1 result:handler];
//                        }else {
                            self.bleConnectStatus = SOSBleConnectStatusUnConnect;
                            !handler?:handler(result,peripheral,error);
                            [BlueToothManager sharedInstance].bleOperationVar.operating = NO;
                        self.bleScanDevices = @[];
//                        }
                        break;
                        
                    case BlueToothConnAuthenticationOK:
                        self.bleConnectStatus = SOSBleConnectStatusConnected;
                        NSLog(@"钥匙认证成功，已经建立安全连接，可以通信。");
                        !handler?:handler(result,peripheral,error);
                        UserDefaults_Set_Object([SOSBleUtil getFullVinWithBleName:bleModel.BleName], bleConnectdbkey);
                        [BlueToothManager sharedInstance].bleOperationVar.operating = NO;
                        break;
                    default:
                        break;
                }
                
            }];
//        }
//    }];

}

#pragma notif
- (void)receiveBLEMessageNotification:(NSNotification *)noti
{
     [BlueToothManager sharedInstance].bleOperationVar.operating = NO;
    UINavigationController *navVC = [SOS_APP_DELEGATE fetchMainNavigationController];
    if ([navVC.topViewController isKindOfClass:[SOSBleUserCarOperationViewController class]])     return;
    
    if ([noti.name isEqualToString:Notification_FUN_RES])  //手机测量的RSSI
    {
        NSDictionary *dic = noti.userInfo;
        NSNumber  *data = [dic objectForKey:KEY_FUN_RES_DATA_WORK];
        int code  =  [data intValue];
        NSString *operationName = [self operationNameWithCode:code];
        [Util toastWithMessage:[NSString stringWithFormat:@"%@操作成功",operationName]];
         [BlueToothManager bleOperationSuccess:code];
    }
    else  if ([noti.name isEqualToString:Notification_FUN_RES_NO]) //BLE 发送的RSSI
    {
        
        NSDictionary *dic = noti.userInfo;
        NSNumber  *data = [dic objectForKey:KEY_FUN_RES_DATA_NOWORK];
        int code  =  [data intValue];
        [BlueToothManager bleOperationFailure:code];
        NSString *operationName = [self operationNameWithCode:code];
        [Util toastWithMessage:[NSString stringWithFormat:@"%@操作失败,请稍后重试",operationName]];
    }
//    else  if ([noti.name isEqualToString:BLE_CONNECT_Result_Notification])
//    {
//        NSDictionary *dic = noti.userInfo;
//        NSNumber  *data = [dic objectForKey:BLE_CONNECT_Result_KEY];
//
//        if ([data integerValue] == BlueToothConnStateConnected )
//        {
////            [self UpdateConenectItem:noti.object Connect:YES];
//        }
//        else if([data integerValue] == BlueToothConnStateDisconnect)
//        {
////            [self UpdateConenectItem:noti.object Connect:NO];
//        }
//        else if([data integerValue] == BlueToothConnStateLostconnect)
//        {
//            //            [self UpdateConenectItem:noti.object Connect:NO];
//        }
//
//    }
//    else  if ([noti.name isEqualToString:Notification_ERROR_RES])
//    {
//        NSDictionary *dic = noti.userInfo;
//        NSNumber  *data = [dic objectForKey:KEY_Error_RES_DATA_WORK];
//        int errorCode =[data integerValue];
//        if (errorCode == 1) {
//            [Util toastWithMessage:@"虚拟钥匙无效，请联系上汽通用服务部！"];
//            //[self.window.rootViewController.view makeToast:@"未登录，请先登录"];
//        }
//        else if(errorCode == 2)
//        {
//            [Util toastWithMessage:@"控制生效。"];
//        }
//        else if(errorCode == 3)
//        {
//            [Util toastWithMessage:@"车辆共享功能未开通。"];
//        }
//        else if(errorCode == 4)
//        {
//            [Util toastWithMessage:@"Sp显示配对问题，请检修。"];
//        }
//        else if(errorCode == 5)
//        {
//            [Util toastWithMessage:@"本车蓝牙功能已被禁止，请联系安吉星。"];
//        }
//
//        else if(errorCode == 6)
//        {
//            [Util toastWithMessage:@"车辆控制异常，，请检修。"];
//        }
//
//        else if(errorCode == 7)
//        {
//            [Util toastWithMessage:@"车辆Vin码错误，请维修蓝牙模块。"];
//        }
//        else if(errorCode == 8)
//        {
//            [Util toastWithMessage:@"车辆低压状态，请尽快充电。"];
//        }
//
//        else if(errorCode == 9)
//        {
//            [Util toastWithMessage:@"虚拟钥匙失效，请重新连接验证。"];
//        }
//
//    }
    
}

- (NSString *)operationNameWithCode:(int)code {
    NSString *operationName = @"";
    if(code == 3 )
    {
        operationName = @"车门解锁";
        self.bleOperationVar.operating = NO;
        
    }else if(code == 0x0D)
    {
        
        operationName = @"允许启动";
    }
    
    else if(code == 4)
    {
        operationName = @"打开后备箱";
        self.bleOperationVar.operating = NO;
    }
    
    if(code == 1 )
    {
        operationName = @"车门上锁";
        self.bleOperationVar.operating = NO;
    }
    
    
    if(code == 0x13 )
    {
        operationName = @"关闭允许启动";
    }
    return operationName;
}


+ (void)bleSendOperation:(int)code {
    if(code == 3 )
    {
       [SOSDaapManager sendActionInfo:BLEUser_Controlboard_Unolck];
    }else if(code == 0x0D)
    {
        [SOSDaapManager sendActionInfo:BLEUser_Controlboard_Engine];
    }
    
    else if(code == 4)
    {
        [SOSDaapManager sendActionInfo:BLEUser_Controlboard_Trunk];
    }
    
    if(code == 1 )
    {
        [SOSDaapManager sendActionInfo:BLEUser_Controlboard_Lock];
    }
    
    
    if(code == 0x13 )
    {
//        [SOSDaapManager sendActionInfo:];
    }
    startTime = [[NSDate date] timeIntervalSince1970] ;
}

+ (void)bleOperationSuccess:(int)code {
    if(code == 3 )
    {
//        [SOSDaapManager sendActionInfo:BLEUser_Controlboard_Unolck_success];
        [SOSDaapManager sendSysLayout:startTime endTime:[[NSDate date] timeIntervalSince1970]  loadStatus:YES funcId:BLEUser_Controlboard_UnLock_Optime];
         [self toastDaapLog:BLEUser_Controlboard_UnLock_Optime];
    }else if(code == 0x0D)
    {
//        [SOSDaapManager sendActionInfo:BLEUser_Controlboard_Engine_success];
        [SOSDaapManager sendSysLayout:startTime endTime:[[NSDate date] timeIntervalSince1970]  loadStatus:YES funcId:BLEUser_Controlboard_EngineStartPermit_Optime];
         [self toastDaapLog:BLEUser_Controlboard_EngineStartPermit_Optime];
    }
    
    else if(code == 4)
    {
//        [SOSDaapManager sendActionInfo:BLEUser_Controlboard_Trunk_success];
        [SOSDaapManager sendSysLayout:startTime endTime:[[NSDate date] timeIntervalSince1970]  loadStatus:YES funcId:BLEUser_Controlboard_TrunkOpen_Optime];
        [self toastDaapLog:BLEUser_Controlboard_TrunkOpen_Optime];
    }
    
    if(code == 1 )
    {
         [SOSDaapManager sendSysLayout:startTime endTime:[[NSDate date] timeIntervalSince1970] loadStatus:YES funcId:BLEUser_Controlboard_Lock_Optime];
         [self toastDaapLog:BLEUser_Controlboard_Lock_Optime];
    }
    
    
    if(code == 0x13 )
    {
//        [SOSDaapManager sendActionInfo:];
    }
}

+ (void)bleOperationFailure:(int)code {
    if(code == 3 )
    {
        [SOSDaapManager sendSysLayout:startTime endTime:[[NSDate date] timeIntervalSince1970] loadStatus:NO funcId:BLEUser_Controlboard_UnLock_Optime];
        [self toastDaapLog:BLEUser_Controlboard_UnLock_Optime];
    }else if(code == 0x0D)
    {
        [SOSDaapManager sendSysLayout:startTime endTime:[[NSDate date] timeIntervalSince1970]  loadStatus:NO funcId:BLEUser_Controlboard_EngineStartPermit_Optime];
        [self toastDaapLog:BLEUser_Controlboard_EngineStartPermit_Optime];
    }
    
    else if(code == 4)
    {
         [SOSDaapManager sendSysLayout:startTime endTime:[[NSDate date] timeIntervalSince1970]  loadStatus:NO funcId:BLEUser_Controlboard_TrunkOpen_Optime];
        [self toastDaapLog:BLEUser_Controlboard_TrunkOpen_Optime];
    }
    
    if(code == 1 )
    {
         [SOSDaapManager sendSysLayout:startTime endTime:[[NSDate date] timeIntervalSince1970]  loadStatus:NO funcId:BLEUser_Controlboard_Lock_Optime];
        [self toastDaapLog:BLEUser_Controlboard_Lock_Optime];
    }
    
    
    if(code == 0x13 )
    {
//        [SOSDaapManager sendActionInfo:]
    }
}

+(void)toastDaapLog:(NSString *)fuc{
#if DEBUG || TEST
    [Util showAlertWithTitle:@"FunctionID" message:fuc completeBlock:nil];
#endif
}

@end
