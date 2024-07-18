//
//  SOSBleReceiveShareViewController.m
//  Onstar
//
//  Created by onstar on 2018/7/25.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSBleUserReceiveShareViewController.h"
#import "SOSBleNetwork.h"
#import "LoadingView.h"
#import "SOSBleUtil.h"
#import "SOSBleOwnerShareListViewController.h"
#import "SOSOwnerHistorySharePageViewController.h"
#import "SOSBleUserShareListViewController.h"
#import "SOSScanChargeVC.h"

@interface SOSBleUserReceiveShareViewController ()<LLSegmentBarVCDelegate>
@property (nonatomic, copy) NSArray *tempDataArray;
@property (nonatomic, copy) NSArray *permDataArray;
@property (nonatomic, copy) NSArray *historyTempDataArray;
@property (nonatomic, copy) NSArray *historyPermDataArray;
@end

@implementation SOSBleUserReceiveShareViewController
{
    SOSBleUserShareListViewController *tempShareVc;
    SOSBleUserShareListViewController *foreverShareVc;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"收到的共享";
    [SOSDaapManager sendActionInfo:ReceivedCarsharing];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"扫一扫" style:UIBarButtonItemStylePlain target:self action:@selector(scan)];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        !self.delayPerform?:self.delayPerform();
    });
    [self.segmentVC.view mas_updateConstraints:^(MASConstraintMaker *make){
        make.left.right.top.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.bottom).mas_offset(-self.view.sos_safeAreaInsets.bottom - 50);
    }];
    [self configPage];
    self.segmentVC.delegate = self;
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"SOSBleSwitchTable" object:nil] subscribeNext:^(NSNotification * _Nullable x) {
            self.selectedIndex = 1;        
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self request];
}

- (void)segmentBar:(LLSegmentBar *)segmentBar didSelectIndex:(NSInteger)toIndex fromIndex:(NSInteger)fromIndex  {
    if (toIndex == 0) {
        [SOSDaapManager sendActionInfo:ReceivedCarsharing_TempCarsharing];
    }else {
        [SOSDaapManager sendActionInfo:ReceivedCarsharing_PermCarsharing];
    }
}

- (void)scan {
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Ble" bundle:[NSBundle mainBundle]];
//    id vc = [storyboard instantiateViewControllerWithIdentifier:@"KeyListViewController"];
//    [self.navigationController pushViewController:vc animated:YES];
//
//    return;
    [SOSDaapManager sendActionInfo:ReceivedCarsharing_Uppercorner_Saoma];
    SOSScanChargeVC *vc = [SOSScanChargeVC new];
    vc.scanCompleteBlock = ^(NSString * _Nonnull str) {
        if (str) {
            [self.navigationController popViewControllerAnimated:NO];
            [SOSBleUtil showReceiveAlertControllerWithUrl:str];
        }
    };
    [self.navigationController pushViewController:vc animated:YES];

}

- (void)request {
    [[LoadingView sharedInstance] startIn:self.view];
    [SOSBleNetwork bleUserAuthorizationsParams:@{@"idpUserId":[CustomerInfo sharedInstance].userBasicInfo.idpUserId?:@""}
                                        method:@"POST"
                                       success:^(SOSAuthorInfo *authorInfo) {
        if ([authorInfo.statusCode isEqualToString:@"0000"]) {
             [self disposeDataWithResp:authorInfo];
        }else {
            [Util toastWithMessage:authorInfo.message];
        }
        [Util hideLoadView];
    } Failed:^(NSString *responseStr, NSError *error) {
        [Util hideLoadView];

    }];
    
}



//将数据源分三组 排序
- (void)disposeDataWithResp:(SOSAuthorInfo *)authorInfo {
    NSArray *dataArray = [SOSBleUtil disposeDataWithAuthorInfo:authorInfo];
    self.tempDataArray = dataArray[0];
    self.permDataArray = dataArray[1];
    self.historyTempDataArray = dataArray[2];
    self.historyPermDataArray = dataArray[3];
    tempShareVc.sourceData = self.tempDataArray;
    foreverShareVc.sourceData = self.permDataArray;
}


- (void)configPage {
    tempShareVc = [SOSBleUserShareListViewController new];
    foreverShareVc = [SOSBleUserShareListViewController new];
    
    [self setUpWithItems:@[@"临时共享",@"永久共享"] childVCs:@[tempShareVc, foreverShareVc]];
    
    UIButton *historyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [historyBtn setTitle:@"历史记录" forState:UIControlStateNormal];
    [historyBtn addTarget:self action:@selector(gotoHistory) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:historyBtn];
    [historyBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(50);
        make.bottom.mas_equalTo(self.view.sos_bottom);
    }];
    [self.segmentVC.view mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.right.left.mas_equalTo(self.view);
        make.bottom.mas_equalTo(historyBtn.mas_top);
    }];
}

- (void)setUpWithItems:(NSArray *)items childVCs:(NSArray *)vcArray        {
    //    3 添加标题数组和控住器数组
    [self.segmentVC setUpWithItems:items childVCs:vcArray];
    //    4  配置基本设置  可采用链式编程模式进行设置
    [self.segmentVC.segmentBar updateWithConfig:^(LLSegmentBarConfig *config) {
        config.sBBackColor = [UIColor whiteColor];
        config.itemNormalColor([UIColor colorWithHexString:@"94A2B3"]).itemSelectColor([UIColor colorWithHexString:@"4E5059"]).indicatorColor([UIColor colorWithHexString:@"6896ED"]).itemFont([UIFont systemFontOfSize:16.f]).indicatorHeight(2).indicatorExtraW(5);
    }];
}

- (void)gotoHistory {
    [SOSDaapManager sendActionInfo:ReceivedCarsharing_History];
    SOSOwnerHistorySharePageViewController *historyVc = [SOSOwnerHistorySharePageViewController new];
    historyVc.sourceTempData = self.historyTempDataArray;
    historyVc.sourcePermData = self.historyPermDataArray;
    [self.navigationController pushViewController:historyVc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
