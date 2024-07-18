//
//  SOSLibKeys.h
//  Onstar
//
//  Created by onstar on 2018/1/23.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#ifndef SOSLibKeys_h
#define SOSLibKeys_h

#import "SOSEnvConfig.h"

#import "SOSSDKKeyUtils.h"


//微信
#define kWeiXinAppID [SOSSDKKeyUtils wxKey]

//OCR
#define IDCardAppKey  [SOSSDKKeyUtils idCardKey]

//高德地图
#define AMapKeyAppStore                 [SOSSDKKeyUtils mapKey]





//JPUSH
#define JPUSH_APP_KEY   [SOSSDKKeyUtils jpushAppKey]

//Bugly
#define BUGLY_APP_KEY   [SOSSDKKeyUtils buglyAppKey]

//网易云信_8.4上线
#define SOS_NIM_APP_KEY     [SOSSDKKeyUtils nimAppKey]
#define SOS_NIM_CER_NAME    [SOSSDKKeyUtils nimCerName]

//SCHEME
#define SOS_PAY_SCHEME   [SOSSDKKeyUtils paySchemeUrl]
#define SOS_BLE_SCHEME      [SOSSDKKeyUtils bleSchemeUrl]

#endif /* SOSLibKeys_h */
