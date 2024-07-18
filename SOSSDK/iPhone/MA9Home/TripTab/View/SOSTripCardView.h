//
//  SOSTripCardView.h
//  Onstar
//
//  Created by Coir on 2018/12/18.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 卡片类型
typedef enum	{
    /// 驾驶行为评价
    SOSTripCardType_DriveBehiver = 1,
    /// 能耗水平
    SOSTripCardType_EnergyLevel,
    /// 我的足迹
    SOSTripCardType_Footprint,
    /// 油耗水平
    SOSTripCardType_OilLevel
} SOSTripCardType;

/// 卡片状态
typedef enum    {
    /// 加载中
    SOSTripCardStatus_Loading = 1,
    /// 数据加载成功
    SOSTripCardStatus_LoadDataSuccess,
    /// 数据加载失败
    SOSTripCardStatus_LoadDataError,
    /// 无数据
    SOSTripCardStatus_NoData,
    /// Demo数据
    SOSTripCardStatus_DemoData
} SOSTripCardStatus;

@class SOSTripCardView;
@protocol SOSTripCardDelegate <NSObject>

@optional
/// 重新加载
- (void)refreshCardButtonTappedWithCardView:(UIView *)cardView;
/// 卡片点击事件
- (void)cardTappedWithCardView:(UIView *)cardView;

@end

@interface SOSTripCardView : UIView

+ (instancetype)initWithCardType:(SOSTripCardType)type;

/// 开始加载的时间
@property (nonatomic, assign) NSTimeInterval requestStartTime;

/// 卡片类型
@property (nonatomic, assign, readonly) SOSTripCardType cardType;

/// 卡片状态
@property (nonatomic, assign) SOSTripCardStatus cardStatus;

@property (nonatomic, weak) id<SOSTripCardDelegate> delegate;

- (void)configSelfWithCardType:(SOSTripCardType)type AndData:(id)data;

@end

NS_ASSUME_NONNULL_END
