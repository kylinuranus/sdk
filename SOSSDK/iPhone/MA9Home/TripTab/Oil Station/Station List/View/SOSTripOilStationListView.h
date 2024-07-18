//
//  SOSTripOilStationListView.h
//  Onstar
//
//  Created by Coir on 2019/8/25.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSOilStationFilterView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SOSOilStationListDelegate <NSObject>

@required
/// 点击列表某项
- (void)didSelectCellWithPOI:(SOSPOI *)poi;
/// 点击列表某项
- (void)didSelectCellWithStation:(SOSOilStation *)station;

@end

@interface SOSTripOilStationListView : UIView

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong, nullable) SOSOilStationFilterView *filterView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopGuide;

@property (nonatomic, strong) SOSPOI *centerPOI;
@property (nonatomic, copy) NSArray <SOSPOI *> * poiArray;
@property (nonatomic, copy) NSArray<SOSOilInfoObj *> *oilInfoList;
@property (nonatomic, weak) id <SOSOilStationListDelegate> delegate;
@property (nonatomic, copy) NSArray <SOSOilStation *> * stationArray;


@end

NS_ASSUME_NONNULL_END
