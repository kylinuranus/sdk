//
//  SOSLBSListCardView.h
//  Onstar
//
//  Created by Coir on 2018/12/20.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SOSLBSListCardView;

/// LBS卡片状态
typedef enum {
    /// 加载中
    SOSLBSListCardStatus_Loading = 1,
    /// 加载失败
    SOSLBSListCardStatus_Error,
    /// 加载成功
    SOSLBSListCardStatus_Success,
    /// 添加设备
    SOSLBSListCardStatus_Blank
}	SOSLBSListCardStatus;

@protocol SOSLBSListCardDelegate <NSObject>

@optional
/// 重新加载
- (void)refreshLBSListButtonTapped;
/// 添加设备
- (void)addLBSDeviceButtonTapped;
/// 实时定位
- (void)getLBSLocationButtonTappedWithView:(SOSLBSListCardView *)view;

@end

@interface SOSLBSListCardView : UIView

@property (nonatomic, weak) id<SOSLBSListCardDelegate> delegate;

@property (nonatomic, assign) SOSLBSListCardStatus cardStatus;

@property (nonatomic, strong) NNLBSDadaInfo *lbsInfo;

+ (instancetype)newCard;

@end

NS_ASSUME_NONNULL_END
