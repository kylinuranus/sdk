//
//  LBSOrderRecordListVC.m
//  LBSTest
//
//  Created by jieke on 2019/6/13.
//  Copyright © 2019 jieke. All rights reserved.
//

#import "LBSOrderRecordListVC.h"
#import "LBSOrderRecordListCell.h"
#import "LBSOrderRecordListCell2.h"
#import "LBSOrderRecordListModel.h"
#import "NoLBSOrderRecordListCell.h"
#import "ScreenInfo.h"
#import "SOSOnstarPackageVC.h"

@interface LBSOrderRecordListVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray <LBSOrderRecordListModel *>*dataArray;
@property (nonatomic, strong) UILabel *bottomShowMoreLabel;
@end

@implementation LBSOrderRecordListVC

#pragma mark - 系统的
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNaviView];
    [self requestOrderRecordList];
    [self setupLayoutView];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    if (self.pushType == SOSOrderListPushTypeLBSPaySuccess) {
        self.fd_interactivePopDisabled = YES;
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    self.fd_interactivePopDisabled = NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - HTTP
#pragma mark 订单记录
- (void)requestOrderRecordList {
    [Util showHUD];
    NSString *url = [BASE_URL stringByAppendingString:NEW_PURCHASE_GET_ORDER_LBS_LIST];
    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:@"" successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        [Util dismissHUD];
        NSArray *dictArray = [Util arrayWithJsonString:responseStr];
        self.dataArray = [LBSOrderRecordListModel mj_objectArrayWithKeyValuesArray:dictArray];
        [self.tableView reloadData];
        self.tableView.tableFooterView.hidden = !self.dataArray.count;
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util dismissHUD];
    }];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}
#pragma mark - Delegate
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LBSOrderRecordListModel *model = self.dataArray[indexPath.row];
    if ([model.isLBSPackage integerValue] == 1) { // 如果是LBS套餐就走LBS
        if (model.openSection) {
            LBSOrderRecordListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell0"];
            __weak typeof(self) _self = self;
            cell.showMoreAction = ^{
                __strong typeof(_self) self = _self;
                [UIView performWithoutAnimation:^{
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }];
            };
            cell.orderRecordListModel = model;
            return cell;
        }else {
            LBSOrderRecordListCell2 *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1"];
            __weak typeof(self) _self = self;
            cell.showMoreAction = ^{
                __strong typeof(_self) self = _self;
                [UIView performWithoutAnimation:^{
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }];
            };
            cell.orderRecordListModel = model;
            return cell;
        }
    }else {
        NoLBSOrderRecordListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
        cell.orderRecordListModel = model;
        return cell;
    }
}
#pragma mark - Private
- (void)setupLayoutView {
    [self.view addSubview:self.tableView];
    CGFloat tableViewBottom = [ScreenInfo sharedInstance].kTabBarBottomHeight;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-tableViewBottom);
    }];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
    [footView addSubview:self.bottomShowMoreLabel];
    self.tableView.tableFooterView = footView;
    [self.bottomShowMoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    self.tableView.tableFooterView.hidden = YES;
}
- (void)setupNaviView {
    self.view.backgroundColor = UIColorHex(0xF3F5FE);
    self.title = @"订单记录";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    __weak typeof(self) _self = self;
    [self setLeftBackBtnCallBack:^{
        __strong typeof(_self) self = _self;
        [self backBtnClick];
    }];
    if (self.pushType == SOSOrderListPushTypeLBSPaySuccess) {
        self.fd_interactivePopDisabled = YES;
    }
}
#pragma mark 返回事件
- (void)backBtnClick {
    if (self.pushType == SOSOrderListPushTypeLBSPaySuccess) {
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[SOSOnstarPackageVC class]]) {
                [self.navigationController popToViewController:vc animated:YES];
            }
        }
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
#pragma mark - 懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 55.0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = UIColorHex(0xF3F5FE);
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView registerClass:[LBSOrderRecordListCell class] forCellReuseIdentifier:@"cell0"];
        [_tableView registerClass:[LBSOrderRecordListCell2 class] forCellReuseIdentifier:@"cell1"];
        [_tableView registerClass:[NoLBSOrderRecordListCell class] forCellReuseIdentifier:@"cell2"];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _tableView;
}
- (UILabel *)bottomShowMoreLabel {
    if (!_bottomShowMoreLabel) {
        _bottomShowMoreLabel = [[UILabel alloc] init];
        _bottomShowMoreLabel.font = [UIFont systemFontOfSize:12.0];
        _bottomShowMoreLabel.backgroundColor = [UIColor clearColor];
        _bottomShowMoreLabel.textColor = UIColorHex(0x828389);
        _bottomShowMoreLabel.textAlignment = NSTextAlignmentCenter;
        _bottomShowMoreLabel.text = @"没有更多了";
    }
    return _bottomShowMoreLabel;
}
- (NSMutableArray<LBSOrderRecordListModel *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
@end
