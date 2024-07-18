//
//  SOSOilStationFilterView.h
//  Onstar
//
//  Created by Coir on 2019/8/24.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SOSStationFilterDelegate <NSObject>

@required
/**
 * gasType        	String    油站类型（1 中石油，2 中石化，3 壳牌，4 其他）
 * oilName         	String    油号（90#、92#、95#、98#、101#）默认92#
 * sortColumn    	String    distance（距离）,price(优惠加油价格)默认距离排序
 */
- (void)filterChangedWithSortRule:(NSString *)rule oilName:(NSString *)oilName AndGasType:(NSString *)gasType;

- (void)viewStateChangedWithState:(BOOL)isSpread;

@end

@interface SOSOilStationFilterView : UIView

@property (nonatomic, weak) id <SOSStationFilterDelegate> delegate;

@property (nonatomic, strong) NSArray <SOSOilInfoObj *>*oilInfoArray;

- (IBAction)dismissTableView;

@end

NS_ASSUME_NONNULL_END
