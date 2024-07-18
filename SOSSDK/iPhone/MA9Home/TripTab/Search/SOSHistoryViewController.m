//
//  SOSHistoryViewController.m
//  Onstar
//
//  Created by Genie Sun on 2017/8/9.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSRouteTool.h"
#import "BaseSearchTableVC.h"
#import "SOSHomeAndCompanyTool.h"
#import "SOSHistoryViewController.h"
#import "NavigateSearchHistoryCell.h"

@interface SOSHistoryViewController ()

///搜索历史数组,存放PoiHistory对象
@property (nonatomic, strong) NSMutableArray *historyArray;

@end

@implementation SOSHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.table.tableFooterView = [UIView new];
    [self.table registerNib:[UINib nibWithNibName:@"NavigateSearchHistoryCell" bundle:[NSBundle SOSBundle]] forCellReuseIdentifier:@"NavigateSearchHistoryCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [CustomerInfo sharedInstance].isInDelear = NO;   //从经销商界面回退后
    [[SOSPoiHistoryDataBase sharedInstance] fetch:^(NSArray<SOSPOI *> * _Nonnull arr) {
        self.historyArray = [NSMutableArray arrayWithArray:arr];
        dispatch_async_on_main_queue(^{
            [self.table reloadData];
        });
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section)	{
        if (self.operationType && self.historyArray.count) {
            // 屏蔽 设置 家/公司/起终点 清空搜索历史
            return 0;
        }	else	return 1;
    }	else	return self.historyArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section) 		return KMoreAndClearHistoryCellHeight;
    else						return KHistoryCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NavigateSearchHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NavigateSearchHistoryCell"];
    if (self.historyArray.count) {
        if (indexPath.section == 0) {
            SOSPOI *historyPOI = self.historyArray[indexPath.row];
            cell.searchType = SearchTypeSearchHistory;
            cell.poi = historyPOI;
        }   else if (indexPath.section == 1)    {
            // 清空搜索记录
            cell.searchType = SearchTypeCleanHistory;
        }
    }   else    {
        // 没有更多历史
        cell.searchType = SearchTypeNoMoreSearchHistory;
    }
    [cell configSelf];
    if (self.fromGeoFecing) {
        cell.sendToCarButton.hidden = YES;
    }
    cell.operationType = self.operationType;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_fieldSearch resignFirstResponder];
    
    UITableViewCell *resultCell = [tableView cellForRowAtIndexPath:indexPath];
    if ([resultCell isKindOfClass:[NavigateSearchHistoryCell class]]) {
        NavigateSearchHistoryCell *cell = (NavigateSearchHistoryCell*)resultCell;
        SOSPOI *selectPOI = cell.poi;
        if (indexPath.section == 0) {
            if (self.operationType == OperationType_set_Route_Begin_POI || self.operationType == OperationType_set_Route_Destination_POI) {
                [SOSRouteTool changeRoutePOIDoneFromVC:self WithType:self.operationType ResultPOI:selectPOI];
            }	else if (self.operationType == OperationType_Set_GroupTrip_Destination)		{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"KNoti_GroupTrip_Destination_Changed" object:selectPOI.mj_JSONObject];
                [self dismissViewControllerAnimated:YES completion:nil];
            }	else if (self.operationType > OperationType_set_Route_Destination_POI)	{
                SelectPointOperation simpleType = [SOSHomeAndCompanyTool simpleTypeWithType:self.operationType];
                
                [SOSDaapManager sendActionInfo:simpleType == OperationType_Set_Home ? Trip_GoWhere_FavoriteTab_HomeMore_EditHomeAdd_HistoryTab_POISelect : Trip_GoWhere_FavoriteTab_OfficeMore_EditOfficeAdd_HistoryTab_POISelect];
                [BaseSearchTableVC handleSearchResultJumpWithResultPOI:selectPOI FromVC:self];
            }	else	{
                [SOSDaapManager sendActionInfo:Trip_GoWhere_HistoryTab_POI];
                [BaseSearchTableVC handleSearchResultJumpWithResultPOI:selectPOI FromVC:self];
            }
        }   else	{
            [SOSDaapManager sendActionInfo:Trip_GoWhere_HistoryTab_ClearAll];
            //清空搜索历史
            if (((NavigateSearchHistoryCell *)cell).searchType != SearchTypeCleanHistory)    return;
            [Util showAlertWithTitle:@"您确定清空历史记录?" message:nil completeBlock:^(NSInteger buttonIndex) {
                if (buttonIndex) {
                    [[SOSPoiHistoryDataBase sharedInstance] deleteAll];
                    [self.historyArray removeAllObjects];
                    [self.table reloadData];
                }
            } cancleButtonTitle:@"否" otherButtonTitles:@"是", nil];
        }
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.fromGeoFecing && !self.operationType) {
        if (self.historyArray.count && indexPath.section == 0)        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self deleteHistoryWithIndex:indexPath.row];
    }
}

- (void)deleteHistoryWithIndex:(NSInteger)index    {
    [SOSDaapManager sendActionInfo:Trip_GoWhere_HistoryTab_DeleteHistoryPOI];
    [Util showAlertWithTitle:nil message:@"您确定删除该历史记录?" completeBlock:^(NSInteger buttonIndex) {
        if (buttonIndex) {
            [SOSDaapManager sendActionInfo:Trip_GoWhere_HistoryTab_DeleteHistoryPOI_Confirm];
            SOSPOI *poi = self.historyArray[index];
            [[SOSPoiHistoryDataBase sharedInstance] deletePOI:poi];
            [self.historyArray removeObject:poi];
            [self.table reloadData];
        }    else    {
            [SOSDaapManager sendActionInfo:Trip_GoWhere_HistoryTab_DeleteHistoryPOI_Cancel];
        }
    } cancleButtonTitle:@"否" otherButtonTitles:@"是", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
