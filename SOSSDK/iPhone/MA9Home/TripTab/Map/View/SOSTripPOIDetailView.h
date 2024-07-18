//
//  SOSTripPOIDetailView.h
//  Onstar
//
//  Created by Coir on 2019/4/8.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SOSTripPOIDetailDelegate <NSObject>

@required
/// 点击查看更多结果
- (void)showMoreResultsWithPoiArray:(NSArray <SOSPOI *> *)poiArray;

@end

@interface SOSTripPOIDetailView : UIView

@property (nonatomic, strong) SOSPOI *poi;
@property (nonatomic, assign) MapType mapType;
@property (nonatomic, assign) BOOL isFromAroundSearch;
@property (nonatomic, copy, nullable) NSArray <SOSPOI *> * poiArray;
@property (nonatomic, weak) id <SOSTripPOIDetailDelegate> delegate;

/// 经销商,仅用于展示经销商详情时,点击立即预约
@property (nonatomic, copy) NNDealers *dealer;

@end

NS_ASSUME_NONNULL_END
