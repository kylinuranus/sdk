//
//  AppGroupHeader.h
//  Onstar
//
//  Created by Joshua on 15/6/1.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#ifndef Onstar_AppGroupHeader_h
#define Onstar_AppGroupHeader_h

#define APP_GROUP_IDENTIFIER            @"group.com.shanghaionstar.onstar"

#define APP_GROUP_USER_NAME             @"APP_GROUP_USER_NAME"
#define APP_GROUP_USER_PASS             @"APP_GROUP_USER_PASS"
#define APP_GROUP_CURRENT_LANGUAGE      @"APP_GROUP_CURRENT_LANGUAGE"
#define APP_GROUP_LOGIN_STATE           @"APP_GROUP_LOGIN_STATE"


#define APP_GROUP_PIN_CODE              @"APP_GROUP_PIN_CODE"

#define APPLE_WATCH_OPERATION_KEY       @"APPLE_WATCH_OPERATION_KEY"
#define VEHICLE_OPERATION_KEY           @"VEHICLE_OPERATION_KEY"
#define VEHICLE_OPERATION_KEY_PARAM     @"VEHICLE_OPERATION_KEY_PARAM"

#define PIN_CODE                        @"PinCode"


#define APPLE_WATCH_RESULT_STATUS       @"APPLE_WATCH_RESULT_STATUS"
#define APPLE_WATCH_ERROR_MSG           @"APPLE_WATCH_ERROR_MSG"

#define APPLE_WATCH_REPORT_KEY          @"APPLE_WATCH_REPORT_KEY"

#define APPLE_WATCH_ALERT_TIME_KEY      @"APPLE_WATCH_ALERT_TIME_KEY"

//functionid

#define APPLE_WATCH_REPORT_FUNCTIONID               @"FunctionID"

#define APPLE_WATCH_REPORT_CONTENT                  @"Content"

#define APPLE_WATCH_REPORT_HOME_DATA_REFRESH        @"F4543"

#define APPLE_WATCH_REPORT_HOME_REMOTE_CONTROL      @"F4544"

#define APPLE_WATCH_REPORT_HOME_FIND_MY_VEHICLE     @"F4545"

#define APPLE_WATCH_REPORT_HOME_SIRI                @"F4546"

//content

#define CONTENT_APPLE_WATCH_REPORT_HOME_DATA_REFRESH        @"APPLE_WATCH_REPORT_HOME_DATA_REFRESH"

#define CONTENT_APPLE_WATCH_REPORT_HOME_REMOTE_CONTROL      @"APPLE_WATCH_REPORT_HOME_REMOTE_CONTROL"

#define CONTENT_APPLE_WATCH_REPORT_HOME_FIND_MY_VEHICLE     @"APPLE_WATCH_REPORT_HOME_FIND_MY_VEHICLE"

#define CONTENT_APPLE_WATCH_REPORT_HOME_SIRI                @"APPLE_WATCH_REPORT_HOME_SIRI"
typedef enum     {
    AppleWatchOperationNone                 = 0,
    AppleWatchOperationLogin                = 1,
    AppleWatchOperationCheckLoginStatus,
    AppleWatchOperationCheckPin,
    AppleWatchOperationRefreshData,
    AppleWatchOperationWakeUpParent,
    AppleWatchOperationCommon,//这个定义的是执行操作命令
    AppleWatchOperationReport,
    AppleWatchOperationUpdateVehicleService,
    AppleWatchOperationCleanUpVehicleService,
    ApplewatchOperationAlertTime,
    
    //二期新增
    //正式下发车辆远程操作
    AppleWatchOperationFire,

} AppleWatchOperationType;




typedef enum VehicleOperationType     {
    OperationLockDoor              =0 , //上锁
    OperationUnlockDoor             , // 解锁
    OperationStartEngine            , // 远程启动
    OperationStopEngine             , // 取消启动
    OperationLight                  , // 仅闪灯
    OperationHorn                   , // 仅鸣笛
    OperationHornLight              , // 闪灯鸣笛
    
    OpenRoofWindow,
    /// 关闭天窗
    CloseRoofWindow,
    /// 打开车窗
    OpenWindow,
    /// 关闭车窗
    CloseWindow,
    /// 打开后备箱
    OpenTrunk,
    /// 开启空调
    OpenHVAC,
    /// 关闭空调
    CloseHVAC,
    
    // 9.0 新增
    /// 车辆定位
//    VehicleLocation,
    OperationType_VehicleLocation,
    /// 下发 TBT
    OperationType_SendPOI_TBT,
    /// 下发 ODD
    OperationType_SendPOI_ODD,
    /// 自动下发 (根据用户设置,自动选择 TBT/ODD)
    OperationType_SendPOI_Auto,
    OperationType_ValidatePin, //仅仅验证Pin


    OperationFindVehicle            , // 车辆位置
    OperationRefreshData            , // 刷新车况
    
    

    
    
    OperationLogin,
    OperationUnkown                 = 999, // 未知操作
    
} VehicleOperationType;



typedef enum     {
    AppleWatchOperationUnreachable          = -2, //未能连接到手机
    // 通用
    AppleWatchOperationResultDefault        = -1,
    AppleWatchOperationResultSuccess        = 0, // 成功
    AppleWatchOperationResultFail           = 1, // 返回失败
    AppleWatchOperationResultTimeOut        = 2, // 请求超时
    AppleWatchOperationResultIsRunning      = 3, // 有其他操作正在进行，请等待
    AppleWatchOperationResultSiriError      = 4, // Siri无法识别命令

    
    // 登录使用
    AppleWatchOperationLoginSuccess         = 1000,
    AppleWatchOperationLoginNone            = 1001,
    AppleWatchOperationLoginInProgress      = 1002,
    AppleWatchOperationLoginFail            = 1003,
    AppleWatchOperationLoginTimeOut         = 1004,
    
    // 检查Pin码
    AppleWatchOperationCheckPinSuccess      = 2000,
    AppleWatchOperationCheckPinNone         = 2001,
    AppleWatchOperationCheckPinFail         = 2002,
    AppleWatchOperationCheckPinExceedMax    = 2003,
    
    // 检查车辆操作是否支持
    AppleWatchVehicleOperationSupported     = 3000,
    AppleWatchVehicleOperationNotSupported  = 3001,

    // 检查服务是否可用
    AppleWatchPackageServiceAvailable       = 4000,
    AppleWatchPackageServiceNotAvailable    = 4001,
    AppleWatchPackageServiceExpired         = 4002,
    
    // 检查用户角色是否可用
    AppleWatchRoleIsPermitted               = 5000,
    AppleWatchRoleIsNotPermitted            = 5001,
    
    //网络请求错误
    ApplewatchNetworkError                  = 6000,
    
    
    AppleWatchOperationSuccess              = 8888

} AppleWatchOperationResultStatus;


#endif
