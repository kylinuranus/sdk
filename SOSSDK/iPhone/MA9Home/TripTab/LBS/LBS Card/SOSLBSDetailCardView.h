//
//  SOSLBSDetailCardView.h
//  Onstar
//
//  Created by Coir on 2018/12/20.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/// LBS卡片状态
typedef enum {
    /// 加载中
    SOSLBSDetailCardStatus_Loading = 1,
    /// 加载失败
    SOSLBSDetailCardStatus_Error,
    /// 加载成功
    SOSLBSDetailCardStatus_Success
}    SOSLBSDetailCardStatus;

@protocol SOSLBSDetailCardDelegate <NSObject>

@optional
/// 重新加载
- (void)LBSDetailRefreshButtonTapped;
/// 返回
- (void)LBSDetailBackButtonTapped;
/// LBSPOI 详情卡片自动刷新回调
- (void)LBSDetailCardAutoRefreshedWithLBSPOI:(SOSLBSPOI *)lbsPOI;

@end

@interface SOSLBSDetailCardView : UIView

@property (nonatomic, weak) id<SOSLBSDetailCardDelegate> delegate;

@property (nonatomic, assign) SOSLBSDetailCardStatus cardStatus;

@property (nonatomic, strong) NNLBSDadaInfo *LBSInfo;

@property (nonatomic, strong) SOSLBSPOI *LBSPOI;

/// 是否需要刷新 LBS 列表信息
@property (nonatomic, assign) BOOL shouldRefresh;

/// 是否需要自动刷新 LBS 卡片详情
@property (nonatomic, assign) BOOL shouldAutoRefresh;


@end

NS_ASSUME_NONNULL_END
