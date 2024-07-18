//
//  SOSOnstarPackageVC.m
//  Onstar
//
//  Created by Coir on 5/9/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "LoadingView.h"
#import "SOSBuyPackageVC.h"
#import "SOSOrderHistoryVC.h"
#import "SOSGreetingManager.h"
#import "SOSOnstarPackageVC.h"
#import "SOSPackageServiceCell.h"
#import "SOSOnstarPackageChildVC.h"
#import "LBSOrderRecordListVC.h"

@interface SOSOnstarPackageVC ()  <LLSegmentBarVCDelegate>   {
    __weak IBOutlet UIView *headerBGView;
    
    NSMutableArray *packageInfoArray;
    SOSPackageServiceCell *availableServiceView;
    /** 当前套餐VC */
    SOSOnstarPackageChildVC *childVC_current;
    /** 未开启套餐VC */
    SOSOnstarPackageChildVC *childVC_UnUsed;
}
@property (weak, nonatomic) IBOutlet UIButton *buyBtn;

@end

@implementation SOSOnstarPackageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configSelf];
    [self configChildVC];
    [self getPackageList];
    [self getRemainDays];
    @weakify(self);
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOS_IAP_BUY_ONSTARPACKAGE object:nil] subscribeNext:^(id x) {
        @strongify(self)
        [self getPackageList];
    }];
    [self.segmentVC.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(_buyBtn);
    }];
}
- (void)configSelf      {
    self.title = @"安吉星套餐";
    self.backRecordFunctionID = PackageTab_servicepackage_back;
    
    [self setUpDefaultNavBackItem];
    __weak typeof(self) _self = self;
    [self setRightBarButtonItemWithTitle:@"订单记录" AndActionBlock:^(id item) {
        __strong typeof(_self) self = _self;
        LBSOrderRecordListVC *vc = [[LBSOrderRecordListVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
//        SOSOrderHistoryVC *vc = [[SOSOrderHistoryVC alloc] init];
//        [SOSDaapManager sendActionInfo:servicepackage_record];
//        vc.vcType = HistoryVCType_Package;
//        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    headerBGView.height = SOSPackageCellHeight;
    self.segmentVC.originY = headerBGView.bottom;
    self.segmentVC.delegate = self;
    
    [self.view insertSubview:self.segmentVC.view belowSubview:headerBGView];
    
    availableServiceView = [SOSPackageServiceCell new];
    availableServiceView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SOSPackageCellHeight);
    [headerBGView addSubview:availableServiceView];
}

- (void)configChildVC   {
    childVC_current = [SOSOnstarPackageChildVC new];
    childVC_current.pageType = ChildVCType_CurrentPackage;
    childVC_UnUsed = [SOSOnstarPackageChildVC new];
    childVC_UnUsed.pageType = ChildVCType_UnUsedPackage;
    
    [self setUpWithItems:@[@"当前套餐", @"未开启"] childVCs:@[childVC_current, childVC_UnUsed]];
}

- (void)getPackageList     {
    [[LoadingView sharedInstance] startIn:self.view];
    [[SOSGreetingManager shareInstance] getPackageListSuccess:^(NSMutableArray<NNPackagelistarray *> *packageArray) {
        [[LoadingView sharedInstance] stop];
        if (!packageArray)		return;
        packageInfoArray = packageArray;
        NSMutableArray *currentPackageArray = [NSMutableArray array];
        NSMutableArray *unUsedPackageArray = [NSMutableArray array];
        
        for (NNPackagelistarray *package in packageInfoArray)		{
            NSDate *startDate = [NSDate dateWithString:package.startDate format:@"yyyy-MM-dd hh:mm:ss"];
            //  startDate 小于当前时间,服务包未开启
            if ([startDate compare:[NSDate date]] == NSOrderedDescending) {
                [unUsedPackageArray addObject:package];
            }else
            {  // startDate 大于当前时间,服务包已开启
                [currentPackageArray addObject:package];
            }
        }
        childVC_current.packageInfoArray = currentPackageArray;
        childVC_UnUsed.packageInfoArray = unUsedPackageArray;
    } Failed:^(NSString *responseStr, NSError *error) {
        [[LoadingView sharedInstance] stop];
    }];
    
}

- (void)getRemainDays	{
    [[LoadingView sharedInstance] startIn:self.view];
    [[SOSGreetingManager shareInstance] getPackageRemainDaysSuccess:^(NSString *remainDay){
        [[LoadingView sharedInstance] stop];
        availableServiceView.totalRemainingDay = remainDay;
    } Failed:^(NSString *responseStr, NSError *error) {
        [[LoadingView sharedInstance] stop];
    }];
}

#pragma mark - 购买更多套餐
- (IBAction)buyPackageButtonTapped {
    if( [Util show23gPackageDialog]){//是2g3g用户弹完提示框,流程就结束了
        return;
    }
    SOSBuyPackageVC *vc = [SOSBuyPackageVC new];
    vc.selectPackageType = PackageType_Core;
    [SOSDaapManager sendActionInfo:servicepackage_purchase];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)segmentBar:(LLSegmentBar *)segmentBar didSelectIndex:(NSInteger)toIndex fromIndex:(NSInteger)fromIndex      {
    NSString *functionID = @"";
    if (toIndex == 0)       functionID = servicepackage_currentpackageTab;
    else                    functionID = servicepackage_futurepackageTab;
    [SOSDaapManager sendActionInfo:functionID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
