//
//  SOSTripPOIListView.m
//  Onstar
//
//  Created by Coir on 2019/4/10.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSTripDealerCell.h"
#import "SOSTripPOIListView.h"
#import "SOSTripPOIListCell.h"

@interface SOSTripPOIListView () <UITableViewDelegate, UITableViewDataSource>

@end
@implementation SOSTripPOIListView

- (void)awakeFromNib	{
    [super awakeFromNib];
    [self.tableView registerNib:[UINib nibWithNibName:@"SOSTripDealerCell" bundle:[NSBundle SOSBundle]] forCellReuseIdentifier:@"SOSTripDealerCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SOSTripPOIListCell" bundle:[NSBundle SOSBundle]] forCellReuseIdentifier:@"SOSTripPOIListCell"];
    self.tableView.tableFooterView = [UIView new];
}

- (void)setPoiArray:(NSArray<SOSPOI *> *)poiArray	{
    _poiArray = [poiArray copy];
    dispatch_async_on_main_queue(^{
        [self.tableView reloadData];
    });
    
}

#pragma mark - TableView Delegate & DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath	{
    if (self.tableType == SOSTripListTableType_Oli_List) 	return 130;
    return 79;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.poiArray.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (self.tableType == SOSTripListTableType_Oli_List) {
        SOSTripDealerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SOSTripDealerCell"];
        cell.cellType = SOSTripCellType_AMap_Oil_Station;
        cell.poi = self.poiArray[indexPath.row];
        return cell;
    }	else	{
        SOSTripPOIListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SOSTripPOIListCell"];
        cell.poi = self.poiArray[indexPath.row];
        cell.tableType = self.tableType;
        cell.operationType = self.operationType;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath		{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCellWithPOI:)]) {
        SOSPOI *poi = self.poiArray[indexPath.row];
        [self.delegate didSelectCellWithPOI:poi];
    }
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView    {
    [[NSNotificationCenter defaultCenter] postNotificationName:SOS_Map_ScrollView_DidEndDecelerating object:scrollView];
}


@end
