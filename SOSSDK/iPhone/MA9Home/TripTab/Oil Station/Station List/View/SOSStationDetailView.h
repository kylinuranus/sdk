//
//  SOSStationDetailView.h
//  Onstar
//
//  Created by Coir on 2019/8/20.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SOSStationDetailDelegate <NSObject>

@required
/// 点击查看更多结果
- (void)showMoreResults;

- (void)payOilButtonTappedWithPriceInfoArray:(NSArray <SOSOilStation *>*)priceInfo;

@end

@interface SOSStationDetailView : UIView

@property (nonatomic, copy) SOSOilStation *station;
@property (nonatomic, weak) id <SOSStationDetailDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
