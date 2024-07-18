//
//  SOSTripHomeModifyDetailView.h
//  Onstar
//
//  Created by Coir on 2019/4/25.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SOSTripHomeModifyDelegate <NSObject>

@required
/// 点击查看更多结果
- (void)modifyHomeViewShowMoreResultsWithPoiArray:(NSArray <SOSPOI *> *)poiArray;

@end

@interface SOSTripHomeModifyDetailView : UIView

@property (strong, nonatomic) SOSPOI *poi;
@property (nonatomic, copy, nullable) NSArray <SOSPOI *> * poiArray;
@property (nonatomic, weak) id <SOSTripHomeModifyDelegate> delegate;
@property (nonatomic, assign) SelectPointOperation operationType;

@end

NS_ASSUME_NONNULL_END
