//
//  SOSTripOilStationListView.m
//  Onstar
//
//  Created by Coir on 2019/8/25.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSOilDataTool.h"
#import "SOSTripDealerCell.h"
#import "SOSTripOilStationListView.h"

@interface SOSTripOilStationListView () <UITableViewDelegate, UITableViewDataSource, SOSStationFilterDelegate>

@end

@implementation SOSTripOilStationListView


- (void)awakeFromNib    {
    [super awakeFromNib];
    [self.tableView registerNib:[UINib nibWithNibName:@"SOSTripDealerCell" bundle:[NSBundle SOSBundle]] forCellReuseIdentifier:@"SOSTripDealerCell"];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
    footerView.backgroundColor = [UIColor colorWithRed:243/255.0 green:245/255.0 blue:254/255.0 alpha:1.0];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 13, 0, 34)];
    [footerView addSubview:label];
    label.numberOfLines = 2;
    label.text = @"我也是有底线的";
    label.font = [UIFont systemFontOfSize:12.f];
    label.textColor = [UIColor colorWithHexString:@"828389"];
    label.textAlignment = NSTextAlignmentCenter;
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(footerView);
    }];
    
    self.tableView.tableFooterView = footerView;
}

- (void)addFilterView	{
    if ([LoginManage sharedInstance].loginState == LOGIN_STATE_NON)     return;
    // 添加 过滤器选择 View
    dispatch_async_on_main_queue(^{
        self.filterView = [SOSOilStationFilterView viewFromXib];
        self.filterView.delegate = self;
        [self addSubview:self.filterView ];
        [self.filterView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@0);
            make.leading.equalTo(@0);
            make.trailing.equalTo(@0);
            make.height.equalTo(@54);
        }];
        self.tableViewTopGuide.constant = 54;
    });
}

- (void)setOilInfoList:(NSArray<SOSOilInfoObj *> *)oilInfoList	{
    _oilInfoList = [oilInfoList copy];
    if (oilInfoList.count) {
        // 添加 过滤器选择 View
        dispatch_async_on_main_queue(^{
            self.filterView = [SOSOilStationFilterView viewFromXib];
            self.filterView.delegate = self;
            self.filterView.oilInfoArray = oilInfoList;
            [self addSubview:self.filterView ];
            [self.filterView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(@0);
                make.leading.equalTo(@0);
                make.trailing.equalTo(@0);
                make.height.equalTo(@54);
            }];
            self.tableViewTopGuide.constant = 54;
            [self layoutIfNeeded];
        });
    }
}

- (void)setStationArray:(NSArray<SOSOilStation *> *)stationArray	{
    _stationArray = [stationArray copy];
    dispatch_async_on_main_queue(^{
        [self.tableView reloadData];
    });
}

- (void)setPoiArray:(NSArray<SOSPOI *> *)poiArray	{
    _poiArray = [poiArray copy];
    dispatch_async_on_main_queue(^{
        [self.tableView reloadData];
    });
    
}

#pragma mark - TableView Delegate & DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView	{
    return 2;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? self.stationArray.count : self.poiArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath    {
    return 152.f;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    SOSTripDealerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SOSTripDealerCell"];
    if (indexPath.section == 0)		{
        cell.cellType = SOSTripCellType_SOS_Oil_Station;
        cell.oilStation = self.stationArray[indexPath.row];
    }	else	{
        cell.cellType = SOSTripCellType_AMap_Oil_Station;
        cell.poi = self.poiArray[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath	{    
    // 第三方油站
    if (indexPath.section == 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCellWithPOI:)]) {
            SOSOilStation *station = self.stationArray[indexPath.row];
            [self.delegate didSelectCellWithStation:station];
        }
    // 高德加油站
    }	else	{
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCellWithPOI:)]) {
            SOSPOI *poi = self.poiArray[indexPath.row];
            [self.delegate didSelectCellWithPOI:poi];
        }
    }
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView	{
    [[NSNotificationCenter defaultCenter] postNotificationName:SOS_Map_ScrollView_DidEndDecelerating object:scrollView];
}

#pragma mark - Filter View Delegate
- (void)filterChangedWithSortRule:(NSString *)rule oilName:(NSString *)oilName AndGasType:(NSString *)gasType	{
    [Util showHUD];
    [SOSOilDataTool requestOilStationListWithCenterPOI:self.centerPOI GasType:gasType OilName:oilName AndSortColumn:rule Success:^(NSArray<SOSOilStation *> *stationList) {
        [Util dismissHUD];
        self.stationArray = stationList;
    } Failure:^{
        [Util dismissHUD];
        
    }];
}

- (void)viewStateChangedWithState:(BOOL)isSpread	{
    if (isSpread) {
        [self.filterView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@0);
            make.leading.equalTo(@0);
            make.trailing.equalTo(@0);
            make.height.equalTo(@(self.height));
        }];
    }	else	{
        [self.filterView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@0);
            make.leading.equalTo(@0);
            make.trailing.equalTo(@0);
            make.height.equalTo(@54);
        }];
    }
    [self layoutIfNeeded];
}

@end
