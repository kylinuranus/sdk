//
//  SOSAgreementConst.h
//  Onstar
//
//  Created by TaoLiang on 25/04/2018.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#ifndef SOSAgreementConst_h
#define SOSAgreementConst_h

#define SOSAgreementGrayColor [UIColor colorWithHexString:@"C6D0D9"]
static CGFloat const kAgreementContainerWidth = 280.f;

typedef NS_ENUM(NSUInteger, SOSAgreementType) {
    /// 安吉星服务协议
    ONSTAR_TC,
    /// 安吉星隐私声明
    ONSTAR_PS,
    /// 上汽通用用户条款
    SGM_TC,
    /// 上汽通用个人隐私政策
    SGM_PS,
    /// 车况鉴定报告分享协议
    ONSTAR_CARDATA_SHARE_TC,
    /// 驾驶评分协议
    ONSTAR_DRIVINGSCORE_TC,
    /// 安吉星定位协议
    ONSTAR_LOCATION_TC,
    /// 安吉星自动续费服务协议
    ONSTAR_AUTO_RENEW_TC,
    /// 委托扣款协议
    ONSTAR_ENTRUST_PAY_TC,
    /// 面容服务协议
    ONSTAR_FACE_TC,
    /// 指纹服务协议
    ONSTAR_FINGERPRINT_TC,
    /// 安吉星智能管家协议
    ONSTAR_SMARTHOME_TC,
    /// 油耗排名
    ONSTAR_FUEL_RANK_TC,
    /// Ble 蓝牙分享
    ONSTAR_BLE,
    /// 能耗排名
    ONSTAR_ENERGY_ECONOMY_TC,
    /// 智联映射
    ONSTAR_LINK_TC,
    /// 车友社交
    ONSTAR_SOCIAL_TC,
    
    /// 法率网免责声明
    LAW_RATE_WEB_DISCLAIMER,
    /// 违章查询
    ONSTAR_CONTENTINFO_PS,
    ONSTAR_RVM_TC,
    ONSTAR_RVM_PS
};

static NSString *agreementName(SOSAgreementType type) {
    NSArray<NSString *> *arr = @[
                     @"ONSTAR_TC",
                     @"ONSTAR_PS",
                     @"SGM_TC",
                     @"SGM_PS",
                     @"ONSTAR_CARDATA_SHARE_TC",
                     @"ONSTAR_DRIVINGSCORE_TC",
                     @"ONSTAR_LOCATION_TC",
                     @"ONSTAR_AUTO_RENEW_TC",
                     @"ONSTAR_ENTRUST_PAY_TC",
                     @"ONSTAR_FACE_TC",
                     @"ONSTAR_FINGERPRINT_TC",
                     @"ONSTAR_SMARTHOME_TC",
                     @"ONSTAR_FUEL_RANK_TC",
                     @"ONSTAR_BLE",
                     @"ONSTAR_ENERGY_ECONOMY_TC",
                     @"ONSTAR_LINK_TC",
                     @"ONSTAR_SOCIAL_TC",
                     @"LAW_RATE_WEB_DISCLAIMER",
                     @"ONSTAR_CONTENTINFO_PS",
                     @"ONSTAR_RVM_TC",
                     @"ONSTAR_RVM_PS"
                     ];
    return arr[type];
}

#endif /* SOSAgreementConst_h */


//ONSTAR_CARDATA_SHARE_TC       车况鉴定报告分享协议
//ONSTAR_DRIVINGSCORE_TC        驾驶评分协议
//ONSTAR_LOCATION_TC            安吉星定位协议
//SGM_TC                        上汽通用用户条款
//SGM_PS                        上汽通用个人隐私政策
//ONSTAR_TC                     安吉星服务协议
//ONSTAR_PS                     安吉星隐私声明
//ONSTAR_AUTO_RENEW_TC          安吉星自动续费服务协议
//ONSTAR_ENTRUST_PAY_TC         委托扣款协议
//ONSTAR_FACE_TC                面容服务协议
//ONSTAR_FINGERPRINT_TC         指纹服务协议
//ONSTAR_SMARTHOME_TC           安吉星智能管家协议
//ONSTAR_FUEL_RANK_TC           油耗排名
//ONSTAR_ENERGY_ECONOMY_TC      能耗排名
//ONSTAR_LINK_TC                智联映射
//ONSTAR_SOCIAL_TC              车友社交
//LAW_RATE_WEB_DISCLAIMER       法率网免责声明
