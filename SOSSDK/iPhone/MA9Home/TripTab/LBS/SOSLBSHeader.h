//
//  SOSLBSHeader.h
//  Onstar
//
//  Created by Coir on 19/9/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#ifndef SOSLBSHeader_h
#define SOSLBSHeader_h

#import "SOSLBSAddDeviceVC.h"
#import "SOSTripNoGeoView.h"
#import "SOSDateFormatter.h"
#import "SOSLBSSettingVC.h"
#import "SOSLBSDataTool.h"
#import "SOSGeoMapVC.h"

/** 编辑LBS历史轨迹查询日期类型 */
typedef enum {
    /** 今天 */
    SOSLBSEditTypeToday = 1,
    /** 昨天 */
    SOSLBSEditTypeYesterday = 2,
    /** 自定义 */
    SOSLBSEditTypeCustom = 3
} SOSLBSHistoryDateEditType;

/** 编辑LBS历史轨迹查询时间类型 */
typedef enum {
    /** 开始时间 */
    SOSLBSEditTypeBeginTime = 1,
    /** 结束时间 */
    SOSLBSEditTypeEndTime = 2
} SOSLBSHistoryTimeEditType;

/// Userdefaults 保存密码的 KEY
#define KSOSLBSPasswordKey      @"KSOSLBSPasswordKey"
/// Userdefaults 保存登录状态的 KEY
#define KSOSLBSLoginFlagKey      @"KSOSLBSLoginFlagKey"
/// Userdefaults 保存协议的 KEY
#define KSOSLBSProtocolKey      @"KSOSLBSProtocolKey"
/// LBS 更改密码 通知的 KEY
#define KSOSLBSInfoChangeNoti   @"KSOSLBSInfoChangeNoti"
/// LBS 删除设备 通知的 KEY
#define KSOSLBSInfoDeleteNoti   @"KSOSLBSInfoDeleteNoti"

#endif /* SOSLBSHeader_h */
