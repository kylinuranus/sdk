//
//  SOSTripRouteDetailView.h
//  Onstar
//
//  Created by Coir on 2019/4/16.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN/// 卡片状态

typedef enum    {
    /// 加载中
    SOSRouteCardStatus_Loading = 1,
    /// 加载成功-驾车模式
    SOSRouteCardStatus_Success_Drive,
    /// 加载成功-步行模式
    SOSRouteCardStatus_Success_Walk,
    /// 加载成功-导航找车,仅步行模式
    SOSRouteCardStatus_Success_Walk_Only,
    /// 数据加载失败
    SOSRouteCardStatus_Fail,
    /// 无法到达
    SOSRouteCardStatus_UnReachable
} SOSRouteCardStatus;

@protocol SOSRouteDetailViewDelegate <NSObject>
/// 路线规划策略变更回调
- (void)routeChangedWithStrategy:(DriveStrategy)strategy;
/// 开始导航
- (void)beginGPSWithStrategy:(DriveStrategy)strategy;
/// 请求失败时重新载入
- (void)failReloadButtonTapped;
/// 导航找车 车辆遥控
- (void)showCarRemoteView:(BOOL)show;

@end

@class SOSRouteInfo;

@interface SOSTripRouteDetailView : UIView

/// 仅用于 导航找车 功能
@property (nonatomic, assign) BOOL isFindCarMode;
@property (nonatomic, assign) SOSRouteCardStatus cardStatus;
@property (nonatomic, weak) id <SOSRouteDetailViewDelegate> delegate;

- (void)configViewWithStrategy:(DriveStrategy)strategy AndRouteInfo:(nullable SOSRouteInfo *)routeInfo;

- (void)configViewWithStrategy:(DriveStrategy)strategy AndRouteInfo:(nullable SOSRouteInfo *)routeInfo shouldHighlighted:(BOOL)highlight;

@end

NS_ASSUME_NONNULL_END
