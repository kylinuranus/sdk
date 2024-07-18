//
//  BleLibNotification.h
//  KostalBleSDK
//
//  Created by shudingcai on 6/28/17.
//  Copyright © 2017 shudingcai. All rights reserved.
//

#ifndef BleLibNotification_h
#define BleLibNotification_h

//
#define KostalBleDBErrorDomain @"com.kostal.BLE.DB"
typedef enum {
    XoperateDefultFailed = -1000,
    XoperatehasAddError,              //数据已经添加了
    XoperatehasDeleteNotExistError,   //删除不存在的数据
    XDBnotExitError,                  //本地钥匙不存在
}DBFailed;


//扫描 。连接，认证，错误
#define KostalBleErrorDomain @"com.kostal.BLE"
typedef enum {
    XDefultFailed = -1000,
    XScanBlueToothStateError,
    XScanTimeout,           //10s 后扫描超时
}ScanErrorFailed;

//连接
typedef enum {
    XDefultConnectFailed = -1010,
    XNotConnnect,           //未连接，未连接发生消息有此错误
}ConnectFailed;

//认证错误类型
typedef enum {
    XDefultAuthenticationtFailed = -1050,
    XAuthenticationtError,  //认证错误，没有认证前发送消息会报此错误
    XAuthenticationtTimeOut,//认证超时，
    
}AuthenticationtErrorFailed;



//扫描结果
typedef NS_ENUM(NSInteger, BlueToothScanState) {
    ScanBlueToothStateError = 0,               // 设备状态错误
    ScanTimeout,                               //10s 后扫描超时
    ScanOK,                                    // 扫描成功
};



// 设备蓝牙工作状态
#define  CBManagerState_Notification  @"com.kostal.BLE.CBManagerState"
#define  CBManagerState_KEY           @"com.kostal.BLE.CBManagerState_KEY"
typedef NS_ENUM(NSInteger, BlueToothState) {
    BlueToothStateCannotUse = 0,               // 当前设备蓝牙不可用
    BlueToothStateUnsupported,                 // 当前设备蓝牙不支持BLE
    BlueToothStatePoweredOff,                  // 当前设备蓝牙已关闭
    BlueToothStatePoweredOn,                   // 当前设备蓝牙可用
};

/*连接结果的通知*/
#define   BLE_CONNECT_Result_Notification  @"com.kostal.BLE.Connect.Result"
#define   BLE_CONNECT_Result_KEY           @"com.kostal.BLE.Connect.Result.Key"
// 蓝牙连接状态
typedef NS_ENUM(NSInteger, BlueToothConnState) {
    BlueToothConnStateUnKnown = 0,              // 未知状态（初始状态）
    BlueToothConnStateDisconnect,               //连接断开
    BlueToothConnStateLostconnect,               //丢失连接
    BlueToothConnStateDeviceNotSuport ,          //连接到其它非长城汽车蓝牙设备
    BlueToothConnStateConnectionFailure,        // 连接失败
    BlueToothConnStateConnectingFailure,        // 正在连接中请勿再连接
    BlueToothConnStateConnectionTimeout,        // 连接超时
    BlueToothConnStateConnected,                // 连接成功（还没有钥匙认证，只是链路连接成功）
    BlueToothConnKeyAuthenticationTimeout,      // 钥匙认证超时
    BlueToothConnAuthenticationFAIl,          // 钥匙认证没有通过（参考BleCarkey错误类型）
    BlueToothConnAuthenticationOK               // 钥匙认证通过（表示可以使用收发API进行通信）
};

/*
 钥匙检验相关的的通知
 */
#define   CarKey_Notification     @"com.kostal.BLE.CarKey"
#define   CarKey_KEY           @"com.kostal.BLE.CarKey_Key"
typedef NS_ENUM(NSInteger, BleCarkey) {
    NoKeyInLocal  = 0,    //本地无钥匙
    NokeySelect ,         //没有合适时间的钥匙
    Keytimeout   = 2,      //钥匙过期
    WrongPackage = 3,
    VKimcomplete = 4,
    Sha256error  = 5,
    Vincodeerror,
    Timeinvalid,
    Guiderror,
    Duiderror,
    Randomnotreceive,
    Noactionin10min,
    Vkinvalid,
    CSKinvalid,         //CSK error
    Oldoldernumber,
    Oldauthtime,
};







/*发送命令*/
typedef NS_ENUM(NSInteger, Sendcmd) {
    //发送的命令
    CmdAllDoorlock                     = 0x01, //上锁所有的车门
    CmdAllDoorUnlock                   = 0x03, //解锁所有的车门
    CmdRearClosureRealse               = 0x04, //
    CmdPanicAlarmControl               = 0x07,
    CmdDeactivateImmobilizer           = 0x0D,
    CmdActivateImmobilizer             = 0x13,
    CmdCheckReturnCarCondition         = 0x31,
    CmdActivateAutoExitEnginReady      = 0x33,
    CmdAllDorlockAndEnginExitReady     = 0x34,
    CmdUnclockEnable0minAutoLock       = 0x35,
    CmdUnclockEnable5minAutoLock       = 0x36,
    CmdUnclockEnable10minAutoLock      = 0x37,
    CmdUnclockEnable20minAutoLock      = 0x38,
    sCmdUnclockEnable30minAutoLock     = 0x39,
};


//通讯有问题，需要重新连接
#define   COMMUCATION_ERROR               @"com.kostal.BLE.COMMUCATION_ERROR"

#define    Notification_FUN_RES           @"com.kostal.BLE.Fun_Res"
#define    Notification_FUN_RES_NO        @"com.kostal.BLE.Fun_Res_NO"
#define    KEY_FUN_RES_DATA_WORK          @"com.kostal.BLE.Fun_Res_DATA"
#define    KEY_FUN_RES_DATA_NOWORK        @"com.kostal.BLE.Fun_Res_DATA_NO"


//错误码通知
#define    Notification_ERROR_RES         @"com.kostal.BLE.Error_Res"
#define    KEY_Error_RES_DATA_WORK        @"com.kostal.BLE.Error_Res_DATA"


//还车的通知
#define    Notification_RETURN_CAR           @"com.kostal.BLE.returncar"
/*发送控制命令发送状态*/
typedef NS_ENUM(NSInteger, SendState) {
    SendFAILScanBlueToothState = 0,
    SendFAILAuthenticationt       ,         //因为未认证发送失败
    SendFAILNOTCONNECT            ,         //因为未连接发送失败
    SendFAIL          ,                     //IOS 系统发送失败
    SendSucessful ,                         //发送成功
    SendTimeout,                            //发送超时
    SendBusy,                              //发送通道忙碌
    SendBusyProcessing                     //上次发送过程还未完成。
};
#endif /* BleLibNotification_h */
