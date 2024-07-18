//
//  SOSDelearStationVC.m
//  Onstar
//
//  Created by Genie Sun on 2017/7/6.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSUserLocation.h"
#import "ChargeStationListCell.h"
#import "SOSDelearStationVC.h"
#import "TLSOSRefreshHeader.h"

@interface SOSDelearStationVC ()  <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@end

@implementation SOSDelearStationVC

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.dataTableView.mj_header = [TLSOSRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
//    self.dataTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMore)];
    self.dataTableView.tableFooterView = [UIView new];
    self.stationList = [NSMutableArray array];
    if (self.selectPOI) {
        [self refresh];
    }	else	{
        SOSPOI *cusLocationPoi = [CustomerInfo sharedInstance].currentPositionPoi;
        if (cusLocationPoi) {
            self.selectPOI = cusLocationPoi;
            [self refresh];
        }    else    {
            [Util showHUD];
            [[SOSUserLocation sharedInstance] getLocationSuccess:^(SOSPOI *userLocationPoi) {
                self.selectPOI = userLocationPoi;
                [Util dismissHUD];
                [self performSelectorOnMainThread:@selector(refresh) withObject:nil waitUntilDone:NO];
            } Failure:^(NSError *error) {
                [Util dismissHUD];
                [Util toastWithMessage:@"当前您的网络不稳定，请稍后再试。"];
            }];
        }
    }
}

- (IBAction)back {
    [Util dismissHUD];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)refresh     {
    [self requestStationList];
}

- (void)loadMore    {
}

- (void)requestStationList      {
    [Util showHUD];
    [ChargeStationOBJ requestBrandStationListPOIInfo:self.selectPOI Success:^(NSArray<ChargeStationOBJ *> *stationList) {
        [Util dismissHUD];
        [self.stationList removeAllObjects];
        dispatch_async_on_main_queue(^{
            if (stationList.count) {
                [self.stationList addObjectsFromArray:stationList];
                //已经全部加载完毕
                [(MJRefreshAutoNormalFooter *)self.dataTableView.mj_footer setTitle:@"已经全部加载完毕" forState:MJRefreshStateNoMoreData];
            }    else    {
                [(MJRefreshAutoNormalFooter *)self.dataTableView.mj_footer setTitle:@"暂无搜索结果" forState:MJRefreshStateNoMoreData];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:KNeedShowStationListMapNotify object:@{@"dataArray": self.stationList, @"tableView": self.dataTableView}];
            [self.dataTableView reloadData];
            [self.dataTableView.mj_header endRefreshing];
            [self.dataTableView.mj_footer endRefreshingWithNoMoreData];
        });
    } Failure:^{
        [Util dismissHUD];
        dispatch_async_on_main_queue(^{
            [self.dataTableView.mj_header endRefreshing];
            [(MJRefreshAutoNormalFooter *)self.dataTableView.mj_footer setTitle:@"暂无搜索结果" forState:MJRefreshStateNoMoreData];
            [self.dataTableView.mj_footer endRefreshingWithNoMoreData];
        });
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section    {
    return self.stationList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    ChargeStationListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChargeStationListCell"];
    if (!cell) {
        cell = [[NSBundle SOSBundle] loadNibNamed:@"ChargeStationListCell" owner:self options:nil][0];
    }
    
    cell.station = self.stationList[indexPath.row];
    [cell reSetFrame:YES];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath     {
    // 在 SOSTripChargeVC 中处理
    ChargeStationOBJ *station = self.stationList[indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:KDealerChargeListCellTappedNotify object:station.mj_keyValues];
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView    {
    [[NSNotificationCenter defaultCenter] postNotificationName:SOS_Map_ScrollView_DidEndDecelerating object:scrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
