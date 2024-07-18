//
//  SOSPackageHeader.h
//  Onstar
//
//  Created by Coir on 6/9/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#ifndef SOSPackageHeader_h
#define SOSPackageHeader_h

#import "SOSOnstarPackageVC.h"
#import "SOSPrepaidCardVC.h"
#import "SOS4GPackageVC.h"
#import "ErrorPageVC.h"
#import "LoadingView.h"

/** 子页面类型 */
typedef enum {
    /** 当前核心套餐 */
    ChildVCType_CurrentPackage = 1,
    /** 未开启套餐_核心套餐 */
    ChildVCType_UnUsedPackage,
    /** 未开启套餐_4G互联套餐 */
    ChildVCType_unUsed4GPackage
}   ChildVCType;

/** 订单记录页面类型 */
typedef enum {
    /** 订单记录-核心套餐 */
    HistoryVCType_Package = 1,
    /** 订单记录-4G互联套餐 */
    HistoryVCType_4GPackage
}   HistoryVCType;

/** 套餐页面 Cell 类型    */
typedef enum {
    ///当前可用核心套餐
    ServiceCellType_CurrentAvailable = 1,
    ///企业补偿包-核心套餐
    ServiceCellType_Company,
    ///未开启的企业补偿包-核心套餐
    ServiceCellType_Company_UnOpened,
    ///被盗协寻服务包-核心套餐
    ServiceCellType_FindLostCar,
    ///当前4G流量包
    ServiceCellType_4G,
    ///未开启的4G流量包
    ServiceCellType_4G_UnOpened
} ServiceCellType;

/** 购买安吉星套餐,套餐类型 */
typedef enum {
    /** 核心包 */
    PackageType_Core = 1,
    /** 4G流量套餐 */
    PackageType_4G
} PackageType;

#define SOSPackageCellHeight  (SCREEN_WIDTH * 320.f / 730.f)

#endif /* SOSPackageHeader_h */
