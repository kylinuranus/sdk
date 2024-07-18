//
//  SOS4GPackageVC.m
//  Onstar
//
//  Created by Coir on 11/9/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOS4GPackageVC.h"
#import "SOSBuyPackageVC.h"
#import "SOSOrderHistoryVC.h"
#import "SOS4GPackageChildVC.h"
#import "SOSOnstarPackageChildVC.h"
#import "LBSOrderRecordListVC.h"

@interface SOS4GPackageVC ()   <LLSegmentBarVCDelegate>     {
    
    __weak IBOutlet UIButton *buyPackageButton;
    
    SOS4GPackageChildVC *current4gChildVC;
    SOSOnstarPackageChildVC *unOpendChildVC;
}

@end

@implementation SOS4GPackageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configSelf];
    [self configChildVC];
    [self getDataList];
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOS_IAP_BUY_4GPACKAGE object:nil] subscribeNext:^(id x) {
        @strongify(self)
        [self getDataList];
    }];
}

- (void)configSelf      {
    self.title = @"4G互联套餐";
    [self setUpDefaultNavBackItem];
    self.backRecordFunctionID = Datapackage_back;
    __weak __typeof(self) weakSelf = self;
    [self setRightBarButtonItemWithTitle:@"订单记录" AndActionBlock:^(id item) {
        LBSOrderRecordListVC *vc = [[LBSOrderRecordListVC alloc] init];
        [weakSelf.navigationController pushViewController:vc animated:YES];
//        [SOSDaapManager sendActionInfo:Datapackage_record];
//        SOSOrderHistoryVC *vc = [SOSOrderHistoryVC new];
//        vc.vcType = HistoryVCType_4GPackage;
//        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
    
    [self.view insertSubview:self.segmentVC.view belowSubview:buyPackageButton];
    
}

- (void)configChildVC   {
    NSArray *titleArray = @[@"当前套餐", @"未开启"];
    current4gChildVC = [SOS4GPackageChildVC new];
    unOpendChildVC = [SOSOnstarPackageChildVC new];
    unOpendChildVC.pageType = ChildVCType_unUsed4GPackage;
    [unOpendChildVC.view setNeedsLayout];
    
    [self setUpWithItems:titleArray childVCs:@[current4gChildVC, unOpendChildVC]];
    [self.segmentVC.contentView setScrollEnabled:NO];
    self.segmentVC.delegate = self;
}

- (void)getDataList     {
    [[LoadingView sharedInstance] startIn:self.view];
    NSString *url = [BASE_URL stringByAppendingString:NEW_PURCHASE_GET_DATA_LIST_URL];
    url = [NSString stringWithFormat:@"%@?vin=%@",url,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];

    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id returnData) {
        [[LoadingView sharedInstance] stop];
        [self handleReturnData:returnData];
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [[LoadingView sharedInstance] stop];
    }];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization, @"APPLICANT": @"ONSTAR_IOS"}];
    [sosOperation start];
}


- (void)handleReturnData:(NSString *)returnData     {
    NSArray *arr = [Util arrayWithJsonString:returnData];
//    if (!arr)     return;
    NSMutableArray *currentPackageArray = [NSMutableArray array];
    NSMutableArray *unUsedPackageArray = [NSMutableArray array];
    NSArray *packageInfoArray = [NNPackagelistarray mj_objectArrayWithKeyValuesArray:arr];
    
    for (NNPackagelistarray *package in packageInfoArray)		{
        //  active 值为 0,服务包未开启
        if (package.active.boolValue == NO) {
            [unUsedPackageArray addObject:package];
        }   else    {  // active 值为 1,服务包已开启
            [currentPackageArray addObject:package];
        }
    }
    
    current4gChildVC.packageInfoArray = currentPackageArray;
    unOpendChildVC.packageInfoArray = unUsedPackageArray;
}

- (void)handleReturnData01:(NSString *)returnData     {
    NNGetDataListResponse *response = [NNGetDataListResponse mj_objectWithKeyValues:[Util dictionaryWithJsonString:returnData]];
    
    NSMutableArray *currentPackageArray = [NSMutableArray array];
    NSMutableArray *unUsedPackageArray = [NSMutableArray array];
    NSArray *packageArray = response.packageUsageInfos;
    for (NNPackagelistarray *package in packageArray) {
        //  active 值为 0,服务包未开启
        if ([package.active isEqualToString:@"0"]) {
            [unUsedPackageArray addObject:package];
        }   else    {  // active 值为 1,服务包已开启
            [currentPackageArray addObject:package];
        }
    }
    current4gChildVC.packageInfoArray = currentPackageArray;
    unOpendChildVC.packageInfoArray = unUsedPackageArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)segmentBar:(LLSegmentBar *)segmentBar didSelectIndex:(NSInteger)toIndex fromIndex:(NSInteger)fromIndex  {
//    NSString *reportIDString = nil;
//    if (fromIndex == 0)     reportIDString = Datapackage_currentpackageTab;
//    else                    reportIDString =
}

#pragma mark - 购买更多套餐
- (IBAction)buyPackageButtonTapped {
    if( [Util show23gPackageDialog]){//是2g3g用户弹完提示框,流程就结束了
        return;
    }
    [SOSDaapManager sendActionInfo:Datapackage_PurchaseDatapackage];
    SOSBuyPackageVC *vc = [SOSBuyPackageVC new];
    vc.selectPackageType = PackageType_4G;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
