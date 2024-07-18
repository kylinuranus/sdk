//
//  SOSOwnerHistorySharePageViewController.m
//  Onstar
//
//  Created by onstar on 2018/7/24.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSOwnerHistorySharePageViewController.h"
#import "SOSBleOwnerShareListViewController.h"
#import "SOSBleOwnerShareListViewController.h"
#import "SOSBleCarInfoView.h"

@interface SOSOwnerHistorySharePageViewController ()

@end

@implementation SOSOwnerHistorySharePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configPage];
}

- (void)configPage {
    self.title = @"历史记录";
    if (self.fromOwnerShare) {
        SOSBleCarInfoView *carInfoView = [SOSBleCarInfoView viewFromXib];
        [carInfoView showOwnerCarInfo];
        [self.view addSubview:carInfoView];
        
        [carInfoView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(self.view);
            make.height.mas_equalTo(70);
        }];
        
        [self.segmentVC.view mas_updateConstraints:^(MASConstraintMaker *make){
            make.left.right.bottom.mas_equalTo(self.view);
            make.top.mas_equalTo(60);
        }];
    }
    
    SOSBleOwnerShareListViewController *tempShareVc = [SOSBleOwnerShareListViewController new];
    SOSBleOwnerShareListViewController *foreverShareVc = [SOSBleOwnerShareListViewController new];
    tempShareVc.sourceData = self.sourceTempData;
    foreverShareVc.sourceData = self.sourcePermData;
    tempShareVc.fromOwnerShare = self.fromOwnerShare;
    foreverShareVc.fromOwnerShare = self.fromOwnerShare;
    tempShareVc.isHistory = YES;
    foreverShareVc.isHistory = YES;
    [tempShareVc.tableView reloadData];
    [self setUpWithItems:@[@"临时共享",@"永久共享"] childVCs:@[tempShareVc, foreverShareVc]];
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
