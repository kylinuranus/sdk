//
//  SOSLBSBGScrollView.h
//  Onstar
//
//  Created by Coir on 2018/12/21.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// LBS卡片模式
typedef enum {
    /// 列表模式,显示导航栏
    SOSLBSBGViewMode_List = 1,
    /// 详情模式,显示搜索框
    SOSLBSBGViewMode_Detail,
}    SOSLBSBGViewMode;

@protocol SOSLBSBGScrollCardDelegate <NSObject>

@optional
/// 显示 LBSPOI 详情点
- (void)showDetailCardWithLBSPOI:(SOSLBSPOI *)lbsPOI shouldUpdateMapView:(BOOL)shouldUpdate;

@end

@interface SOSLBSBGScrollView : UIScrollView

@property (nonatomic, assign) SOSLBSBGViewMode viewMode;

@property (nonatomic, weak) id<SOSLBSBGScrollCardDelegate> cardDelegate;

@property (nonatomic, strong, nullable) NSMutableArray <NNLBSDadaInfo *> *deviceList;

@end

NS_ASSUME_NONNULL_END
