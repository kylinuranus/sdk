//
//  ChargeStationOBJ.h
//  Onstar
//
//  Created by Coir on 16/6/16.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

/// 安悦充电列表 Cell 点击 通知
extern NSString * const KAYChargeListCellTappedNotify;
/// 品牌充电桩列表 Cell 点击 通知
extern NSString * const KDealerChargeListCellTappedNotify;
/// 充电桩列表展示,更新地图 通知
extern NSString * const KNeedShowStationListMapNotify;

@interface ChargeStationOBJ : NSObject

///充电桩ID     仅适用于安悦充电
@property (nonatomic, strong) NSNumber *stationID;

///充电桩名称
@property (nonatomic, strong) NSString *stationName;

///国家     仅适用于安悦充电
@property (nonatomic, strong) NSString *country;

///省,市
@property (nonatomic, strong) NSString *province;

///市,县
@property (nonatomic, strong) NSString *city;

///县,区     仅适用于安悦充电
@property (nonatomic, strong) NSString *district;

///详细地址
@property (nonatomic, strong) NSString *address;

/// 经度
@property (nonatomic, strong) NSString *longitude;

/// 纬度
@property (nonatomic, strong) NSString *latitude;

/// 站点类型     仅适用于安悦充电
@property (nonatomic, strong) NSString *stationType;

/// 交/直流     仅适用于品牌充电桩
@property (nonatomic, strong) NSString *chargeType;

/// 快充数量
@property (nonatomic, strong) NSNumber *quickCharge;

/// 可用快充数量     仅适用于安悦充电
@property (nonatomic, strong) NSNumber *idleQuickCharge;

///慢充数量
@property (nonatomic, strong) NSNumber *slowCharge;

///可用慢充数量 	仅适用于安悦充电
@property (nonatomic, strong) NSNumber *idleSlowCharge;

///服务次数     仅适用于安悦充电
@property (nonatomic, strong) NSNumber *serviceTimes;

///收藏量     仅适用于安悦充电
@property (nonatomic, strong) NSNumber *favorTimes;

///评分     仅适用于安悦充电
@property (nonatomic, strong) NSNumber *score;

///是否可控制     仅适用于安悦充电
@property (nonatomic, strong) NSNumber *isControllable;

///是否有权限     仅适用于安悦充电
@property (nonatomic, strong) NSNumber *isHasAuth;

///是否可预约     仅适用于安悦充电
@property (nonatomic, strong) NSNumber *isBookable;

///收费类型
@property (nonatomic, strong) NSString *feeType;

///当前状态
@property (nonatomic, strong) NSString *status;

///分类,数值代表含义未知     仅适用于安悦充电
@property (nonatomic, strong) NSNumber *category;

///服务供应商
@property (nonatomic, strong) NSString *supplier;

///距离
@property (nonatomic, strong) NSString *distance;

/// 开放时间     仅适用于安悦充电
@property (nonatomic, strong) NSString *openTime;

/// 快充费     仅适用于安悦充电
@property (nonatomic, strong) NSString *quickChargeCostFee;

/// 慢充费     仅适用于安悦充电
@property (nonatomic, strong) NSString *slowChargeCostFee;

/// 服务费     仅适用于安悦充电
@property (nonatomic, strong) NSString *serveFee;

- (SOSPOI *)transToPoi;

/// 获取充电桩列表
+ (void)requestStationListPOIInfo:(SOSPOI *)poi Success:(void (^)(NSArray <ChargeStationOBJ *> * stationList))successBlock Failure:(void (^)(void))failure;

/// 获取品牌充电桩列表
+ (void)requestBrandStationListPOIInfo:(SOSPOI *)poi Success:(void (^)(NSArray <ChargeStationOBJ *> * stationList))successBlock Failure:(void (^)(void))failure;

/// 获取充电桩详情
+ (void)requestStationDetailWithStationId:(NSString *)stationId successBlock:(void (^)(ChargeStationOBJ *station))successBlock failureBlock:(SOSFailureBlock)failureBlock;

@end
