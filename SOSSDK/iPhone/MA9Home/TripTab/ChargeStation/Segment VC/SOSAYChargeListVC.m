//
//  SOSAYChargeListVC.m
//  Onstar
//
//  Created by Coir on 16/6/12.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "SOSUserLocation.h"
#import "ChargeStationOBJ.h"
#import "SOSAYChargeListVC.h"
#import "TLSOSRefreshHeader.h"
#import "ChargeStationListCell.h"
#import "SOSDelearStationVC.h"

@interface SOSAYChargeListVC ()    <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>   {
    
    int pageNum;
    SOSPOI *currentPoi;
    NSMutableArray *stationListArray;
}

@end

@implementation SOSAYChargeListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"充电桩";
    self.edgesForExtendedLayout = UIRectEdgeNone;
//    self.dataTableView.mj_header = [TLSOSRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
//    self.dataTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMore)];
    self.dataTableView.tableFooterView = [UIView new];
    stationListArray = [NSMutableArray array];
    if (self.selectPOI) {
        currentPoi = self.selectPOI;
        [self refresh];
    }	else	{
        SOSPOI *cusLocationPoi = [CustomerInfo sharedInstance].currentPositionPoi;
        if (cusLocationPoi) {
            currentPoi = cusLocationPoi;
            [self refresh];
        }	else	{
            [[SOSUserLocation sharedInstance] getLocationSuccess:^(SOSPOI *userLocationPoi) {
                currentPoi = userLocationPoi;
                [self performSelectorOnMainThread:@selector(refresh) withObject:nil waitUntilDone:NO];
            } Failure:^(NSError *error) {
                [Util hideLoadView];
                [Util toastWithMessage:NSLocalizedString(@"Charge_Station_Connect_Failed", nil)];
            }];
        }
    }
}

- (void)setStationList:(NSArray *)stationList	{
    _stationList = stationList;
}

- (IBAction)back {
    [Util hideLoadView];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)refresh     {
    pageNum = 0;
    if (self.stationList.count == 0)	[self requestStationList];
    else								[self handleListDataHasNoMoreData:NO];
}

- (void)loadMore    {
    pageNum ++;
    [self requestStationList];
}

- (void)handleListDataHasNoMoreData:(BOOL)noMoreData	{
    [stationListArray addObjectsFromArray:self.stationList];
    if (!noMoreData) {
        [self.dataTableView.mj_footer resetNoMoreData];
        [self.dataTableView.mj_footer endRefreshing];
    }   else    {
        [self.dataTableView.mj_footer endRefreshingWithNoMoreData];
    }
    
    if (stationListArray.count > 0) {
        if ([Util vehicleIsCadillac]) {
            self.delearBtn.hidden = NO;
            self.tableY.constant = 71.f;
            [self.view setNeedsLayout];
            [self.delearBtn setImage:[UIImage imageNamed:@"CadillacDealer"] forState:0];
            self.delearWidth.constant = 160.f;
            [self.view setNeedsLayout];
        }    else if ([Util vehicleIsBuick]){
            self.delearBtn.hidden = NO;
            self.tableY.constant = 71.f;
            [self.view setNeedsLayout];
            self.delearWidth.constant = 135.f;
            [self.view setNeedsLayout];
            [self.delearBtn setImage:[UIImage imageNamed:@"BuickDealer"] forState:0];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:KNeedShowStationListMapNotify object:@{@"dataArray": stationListArray, @"tableView": self.dataTableView}];
    [self.dataTableView reloadData];
    [self.dataTableView.mj_header endRefreshing];
}

- (void)requestStationList      {
    [Util showHUD];
    [ChargeStationOBJ requestStationListPOIInfo:currentPoi Success:^(NSArray<ChargeStationOBJ *> *stationList) {
        [Util dismissHUD];
        if (pageNum == 0)   	[stationListArray removeAllObjects];
        self.stationList = stationList;
        [self handleListDataHasNoMoreData:YES];
        
    } Failure:^{
        [Util dismissHUD];
        [self.dataTableView.mj_header endRefreshing];
        [(MJRefreshAutoNormalFooter *)self.dataTableView.mj_footer setTitle:@"暂无搜索结果" forState:MJRefreshStateNoMoreData];
        [self.dataTableView.mj_footer endRefreshingWithNoMoreData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section    {
    return stationListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    ChargeStationListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChargeStationListCell"];
    if (!cell) {
        cell = [[NSBundle SOSBundle] loadNibNamed:@"ChargeStationListCell" owner:self options:nil][0];
    }
    
    cell.station = stationListArray[indexPath.row];
    [cell configSelf];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath		{
    return 151.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath     {
    // 在 SOSTripChargeVC 中处理
    [[NSNotificationCenter defaultCenter] postNotificationName:KAYChargeListCellTappedNotify object:@(indexPath.row)];
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView    {
    [[NSNotificationCenter defaultCenter] postNotificationName:SOS_Map_ScrollView_DidEndDecelerating object:scrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc     {
    [Util dismissHUD];
}

- (IBAction)delearList:(id)sender {
    SOSDelearStationVC *supplierVc = [[SOSDelearStationVC alloc] initWithNibName:@"SOSDelearStationVC" bundle:nil];
    [self.navigationController pushViewController:supplierVc animated:YES];
}




@end
