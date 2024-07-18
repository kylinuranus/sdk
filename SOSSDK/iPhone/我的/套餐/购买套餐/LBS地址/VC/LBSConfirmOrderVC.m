//
//  LBSConfirmOrderVC.m
//  LBSTest
//
//  Created by jieke on 2019/6/13.
//  Copyright © 2019 jieke. All rights reserved.
//

#import "LBSConfirmOrderVC.h"
#import "LBSConfirmOrderSetMealCell.h"
#import "LBSConfirmOrderConsigneeCell.h"
#import "LBSConfirmOrderConsigneeHeadView.h"
#import "LBSConfirmOrderSetMealHeadView.h"
#import "LBSConfirmPaymentFootView.h"
#import "LBSOrderRecordListVC.h"
#import "LBSConsigneeVC.h"
#import "ScreenInfo.h"
#import "LoadingView.h"
#import "PurchaseProxy.h"
#import "PurchaseModel.h"
#import "RMStore.h"

#if __has_include("SOSSDK.h")

#import <SOSSDK/SOSPay.h>

#endif

@interface LBSConfirmOrderVC () <UITableViewDataSource, UITableViewDelegate, LBSConfirmPaymentFootViewDelegate, ProxyListener>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
/** 套餐 */
@property (nonatomic, strong) LBSConfirmOrderSetMealHeadView *setMealHeadView;
/** 收货人信息 */
@property (nonatomic, strong) LBSConfirmOrderConsigneeHeadView *consigneeHeadView;
@end

@implementation LBSConfirmOrderVC

#pragma mark - 系统的
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNaviView];
    [self setupDataArray];
    [self setupLayoutView];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}
#pragma mark - Delegate
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.dataArray[section];
    return array.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifiers = [NSString stringWithFormat:@"cell%zd", indexPath.section];
    UITableViewCell <BaseTableViewCellProtocol>*cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifiers];
    NSDictionary *dict = self.dataArray[indexPath.section][indexPath.row];
    id itemModel = (indexPath.section == 1) ? [PurchaseModel sharedInstance].selectPackageInfo : dict;
    [cell configModel:itemModel];
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return self.setMealHeadView;
    }else {
        return self.consigneeHeadView;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSInteger headerHeight = 44;
    return headerHeight;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView == self.tableView) {
        CGFloat sectionHeaderHeight = 40;
        if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
}
#pragma mark LBSConfirmPaymentFootViewDelegate - 支付按钮事件
- (void)confirmPaymentFootViewPaymentBtnClick {
    [[LoadingView sharedInstance] startIn:self.view];
    [[PurchaseProxy sharedInstance] addListener:self];
    //创建订单,获取orderid
    [[PurchaseProxy sharedInstance] createLBSOrder];
}
#pragma mark ProxyListener
- (void)payOrderProxyDidFinishRequest:(BOOL)success withObject:(id)object {
    [[PurchaseProxy sharedInstance] removeListener:self];
    NSDictionary *createOrderResDic = [PurchaseModel sharedInstance].createOrderResDic;
    if (createOrderResDic.count) {
        [self payWithcreateOrderResDic:createOrderResDic];
    }    else    {
        [[LoadingView sharedInstance] stop];
        [Util showAlertWithTitle:nil message:object completeBlock:nil];
    }
}
#pragma mark - Private
- (void)setupLayoutView {
    PackageInfos *package = [PurchaseModel sharedInstance].selectPackageInfo;
    LBSConfirmPaymentFootView *footView = [[LBSConfirmPaymentFootView alloc] initWithFrame:CGRectZero];
    footView.delegate = self;
    footView.packageInfos = package;
    [self.view addSubview:footView];
    CGFloat footViewHeight = 66+[ScreenInfo sharedInstance].kTabBarBottomHeight;
    [footView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.height.mas_equalTo(footViewHeight);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(footView.mas_top).offset(0);
    }];
}
- (void)setupNaviView {
    self.view.backgroundColor = UIColorHex(0xF3F5FE);
    self.title = @"确认支付";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
}
- (void)setupDataArray {
    PackageInfos *package = [PurchaseModel sharedInstance].selectPackageInfo;
    [self.dataArray removeAllObjects];
    NSString *priceString = [NSString stringWithFormat:@"￥%@", package.annualPrice];
    NSArray *section0 = @[@{@"名称":package.offerName},
                          @{@"价格":priceString}];
    NSArray *section2 = @[@{@"":@""}];
    [self.dataArray addObject:section0];
    [self.dataArray addObject:section2];
}
- (void)payWithcreateOrderResDic:(NSDictionary *)createOrderResDic {
    if (SOS_ONSTAR_PRODUCT) {
        //支付
        NSString *packageId = createOrderResDic[@"productNumber"];
        packageId = [self packageId4G:packageId];
        [[RMStore defaultStore] requestProducts:[NSSet setWithObject:packageId] success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
            NSLog(@"获取商品成功");
            [self handlePayResWithProductNum:createOrderResDic[@"productNumber"]];
        } failure:^(NSError *error) {
            NSLog(@"获取商品失败");
            [[LoadingView sharedInstance] stop];
            [Util showAlertWithTitle:nil message:error.localizedDescription completeBlock:nil];
        }];
    }
#if __has_include("SOSSDK.h")
    else {
        [SOSPay payWithcreateOrderResDic:createOrderResDic target:self];
    }
#endif
}

- (void)observePayResponse:(NSNotification *)notification     {

    if ([[notification name] isEqualToString:SOSpaySuccessNotification]) {
        [[LoadingView sharedInstance] stop];
        [Util showSuccessHUDWithStatus:@"支付成功"];
        // 延迟加载
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            LBSOrderRecordListVC *vc = [[LBSOrderRecordListVC alloc] init];
            vc.pushType = SOSOrderListPushTypeLBSPaySuccess;
            [self.navigationController pushViewController:vc animated:YES];
        });
        
    } else {
        [[LoadingView sharedInstance] stop];
    }
}

- (void)handlePayResWithProductNum:(NSString *)productNum {
    [[RMStore defaultStore] addPayment:[self packageId4G:productNum] user:[CustomerInfo sharedInstance].userBasicInfo.idpUserId transactionIdentify:[PurchaseModel sharedInstance].createOrderResDic[@"buyOrderId"] success:^(SKPaymentTransaction *transaction) {
        [[LoadingView sharedInstance] stop];
        [Util showSuccessHUDWithStatus:@"支付成功"];
        // 延迟加载
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            LBSOrderRecordListVC *vc = [[LBSOrderRecordListVC alloc] init];
            vc.pushType = SOSOrderListPushTypeLBSPaySuccess;
            [self.navigationController pushViewController:vc animated:YES];
        });
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        [[LoadingView sharedInstance] stop];
        [Util showAlertWithTitle:nil message:error.localizedDescription completeBlock:nil];
    }];
}
- (NSString *)packageId4G:(NSString *)pgid {
    NSArray *pgIds = @[@"7000031",
                       @"7000028",
                       @"7000030",
                       @"7000032",
                       @"7000029"];
    if ([pgIds containsObject:pgid]) {
        pgid = [NSString stringWithFormat:@"ID%@",pgid];
    }
    pgid = [NSString stringWithFormat:@"%@%@",SOSSDK_VERSION_PREFIX,pgid];
    return pgid;
}
#pragma mark - 懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 55.0;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView registerClass:[LBSConfirmOrderSetMealCell class] forCellReuseIdentifier:@"cell0"];
        [_tableView registerClass:[LBSConfirmOrderConsigneeCell class] forCellReuseIdentifier:@"cell1"];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _tableView;
}
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (LBSConfirmOrderSetMealHeadView *)setMealHeadView {
    if (!_setMealHeadView) {
        _setMealHeadView = [[LBSConfirmOrderSetMealHeadView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
    }
    return _setMealHeadView;
}
- (LBSConfirmOrderConsigneeHeadView *)consigneeHeadView {
    if (!_consigneeHeadView) {
        _consigneeHeadView = [[LBSConfirmOrderConsigneeHeadView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
        @weakify(self);
        _consigneeHeadView.editBtnBlock = ^{
            @strongify(self);
            LBSConsigneeVC *vc = [[LBSConsigneeVC alloc] init];
            vc.pushType = SOSPushTypeConfirmOrder;
            [self.navigationController pushViewController:vc animated:YES];
        };
    }
    return _consigneeHeadView;
}
@end
