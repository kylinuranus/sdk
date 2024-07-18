//
//  SOSOilOrderListVC.m
//  Onstar
//
//  Created by Coir on 2019/8/19.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSOilDataTool.h"
#import "SOSOilOrderCell.h"
#import "SOSOilOrderListVC.h"
#import "TLSOSRefreshHeader.h"

@interface SOSOilOrderListVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *NOOrderView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *orderArray;
@property (assign, nonatomic) int pageNum;

@end

@implementation SOSOilOrderListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self configTableView];
}

- (void)initData	{
    self.pageNum = 1;
    self.orderArray = [NSMutableArray array];
    self.title = @"订单";
}

- (void)configTableView		{
    __weak __typeof(self) weakSelf = self;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
    headerView.backgroundColor = [UIColor colorWithHexString:@"F3F5FE"];
    self.tableView.tableHeaderView = headerView;
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.mj_header = [TLSOSRefreshHeader headerWithRefreshingBlock:^{
        weakSelf.pageNum = 1;
        weakSelf.NOOrderView.hidden = YES;
        [weakSelf.orderArray removeAllObjects];
        [weakSelf requestOrderList];
    }];
    [self resetTableMJFootView];
    [self.tableView registerNib:[UINib nibWithNibName:@"SOSOilOrderCell" bundle:[NSBundle SOSBundle]] forCellReuseIdentifier:@"SOSOilOrderCell"];
}

- (void)resetTableMJFootView	{
    __weak __typeof(self) weakSelf = self;
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        weakSelf.pageNum ++;
        [weakSelf requestOrderList];
    }];
}

- (void)viewWillAppear:(BOOL)animated	{
    [super viewWillAppear:animated];
    if (self.orderArray.count == 0) {
        [self.tableView.mj_header beginRefreshing];
    }
}

- (void)requestOrderList	{
    [SOSOilDataTool requestOilOrderListWithPageNum:self.pageNum PageSize:10 Success:^(NSArray<SOSOilOrder *> * _Nonnull orderList) {
        [Util dismissHUD];
        [self.orderArray addObjectsFromArray:orderList];
        dispatch_async_on_main_queue(^{
            if (self.pageNum == 1) {
                [self.tableView.mj_header endRefreshing];
                if (self.orderArray.count == 0) {
                    self.NOOrderView.hidden = NO;
                    self.tableView.mj_footer = nil;
                }	else	{
                    [self resetTableMJFootView];
                    if (orderList.count < 10)	[self.tableView.mj_footer endRefreshingWithNoMoreData];
                }
            }    else    {
                if (orderList.count == 10)     [self.tableView.mj_footer endRefreshing];
                else    [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            [self.tableView reloadData];
        });
        
    } Failure:^{
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
    }];
}

#pragma mark - TableVIew Delegate && DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section	{
    return self.orderArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath	{
    SOSOilOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SOSOilOrderCell"];
    cell.order = self.orderArray[indexPath.row];
    return cell;
}

- (void)dealloc	{
    [Util dismissHUD];
}

@end
