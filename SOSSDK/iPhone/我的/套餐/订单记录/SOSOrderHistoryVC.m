//
//  SOSOrderHistoryVC.m
//  Onstar
//
//  Created by Coir on 8/9/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSOrderHistoryVC.h"
#import "SOSOrderHistoryCell.h"
#import "TLSOSRefreshHeader.h"
#import "RMStore.h"

@interface SOSOrderHistoryVC ()  <UITableViewDelegate, UITableViewDataSource>   {
    
    __weak IBOutlet UITableView *contentTableView;
    __weak IBOutlet UIView *noOrderBGView;
    
    NSMutableArray *orderArray;
    int pageNum;
}

@end

@implementation SOSOrderHistoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configSelf];
    [[LoadingView sharedInstance] startIn:self.view];
    [self refreshData];
}

- (void)configSelf  {
    pageNum = 0;
    orderArray = [NSMutableArray array];
    self.title = @"订单记录";
    self.fd_prefersNavigationBarHidden = NO;
    self.backRecordFunctionID = servicepackage_record_back;
    [contentTableView registerNib:[UINib nibWithNibName:@"SOSOrderHistoryCell" bundle:nil] forCellReuseIdentifier:@"SOSOrderHistoryCell"];
    contentTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, .1)];
    
    contentTableView.mj_header = [TLSOSRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(reload)];
    contentTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        pageNum ++;
        [self refreshData];
    }];
    UIView *clearView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
    clearView1.backgroundColor = [UIColor clearColor];
    contentTableView.tableHeaderView = clearView1;
    UIView *clearView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
    clearView2.backgroundColor = [UIColor clearColor];
    contentTableView.tableFooterView = clearView2;
}

- (void)refreshData  {
    id packageType;
    int pageSize = 20;
    if (self.vcType == HistoryVCType_Package)           packageType = @[@"CORE", @"SSA"];
    else if (self.vcType == HistoryVCType_4GPackage)    packageType = @[@"DATA"];
    NSString *url = [BASE_URL stringByAppendingString:NEW_PURCHASE_GET_ORDER_HISTORY];
//    {orderTypes: ["CORE", "SSA"], pageRequest: {pageNumber: 1, pageSize: 20}, vin: "LSGZG5378GS026406"}
    NSString *parameters = @{@"orderTypes": packageType, @"vin": [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin, @"pageRequest": @{@"pageNumber": @(pageNum), @"pageSize": @(pageSize)}}.mj_JSONString;
    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:parameters successBlock:^(SOSNetworkOperation *operation, id returnData) {
        [[LoadingView sharedInstance] stop];
        
        SOSOrderHistoryListModel *response = [[SOSOrderHistoryListModel new] mj_setKeyValues:returnData];
//        [response mj_setKeyValues:returnData];
        NSArray *responseOrderArray = response.result;
        dispatch_async(dispatch_get_main_queue(), ^{
            [contentTableView.mj_header endRefreshing];
            if (responseOrderArray.count) {
                [orderArray addObjectsFromArray:responseOrderArray];
                if (orderArray.count >= response.totalSize)	[contentTableView.mj_footer endRefreshingWithNoMoreData];
                else                                        [contentTableView.mj_footer endRefreshing];
            }   else    {
                [contentTableView.mj_footer endRefreshingWithNoMoreData];
            }
            noOrderBGView.hidden = orderArray.count;
            [contentTableView reloadData];
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[LoadingView sharedInstance] stop];
            [contentTableView.mj_header endRefreshing];
            [contentTableView.mj_footer endRefreshing];
        });
    }];
    [sosOperation setHttpMethod:@"POST"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}

- (void)reload     {
    pageNum = 0;
    [orderArray removeAllObjects];
    [self refreshData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - TableView Delegate & DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section    {
    return orderArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    SOSOrderHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SOSOrderHistoryCell"];
    cell.vcType = self.vcType;
    cell.order = orderArray[indexPath.row];
    return cell;
}

@end
