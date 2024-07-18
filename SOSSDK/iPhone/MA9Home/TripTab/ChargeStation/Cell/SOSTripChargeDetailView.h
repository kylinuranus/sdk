//
//  SOSTripChargeDetailView.h
//  Onstar
//
//  Created by Coir on 2019/4/23.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChargeStationOBJ.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SOSTripChargeDetailDelegate <NSObject>
/// 充电桩详情 点击查看更多结果
- (void)showMoreResultsWithStations:(NSArray <ChargeStationOBJ *> *)stationArray;
/// 充电桩详情 点击重新加载
- (void)reloadButtonTapped;

@end

/// 充电桩详情卡片状态
typedef enum    {
    /// 加载中
    SOSChargeDetailViewStatus_Loading = 1,
    /// 加载成功
    SOSChargeDetailViewStatus_Success,
    /// 数据为空
    SOSChargeDetailViewStatus_Empty,
    /// 数据加载失败
    SOSChargeDetailViewStatus_Fail
} SOSChargeDetailViewStatus;

@interface SOSTripChargeDetailView : UIView

@property (nonatomic, assign) BOOL isAYChargeDetailMode;
@property (nonatomic, assign) SOSChargeDetailViewStatus status;
@property (nonatomic, strong) ChargeStationOBJ *chargeStationObj;
@property (nonatomic, weak) id <SOSTripChargeDetailDelegate> delegate;
@property (nonatomic, copy) NSArray <ChargeStationOBJ *> *stationArray;

@end

NS_ASSUME_NONNULL_END
