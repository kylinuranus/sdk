//
//  SOSTripDealerContainerVC.m
//  Onstar
//
//  Created by Coir on 2019/5/5.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSTripDealerContainerVC.h"
#import "SOSDealerTool.h"

@interface SOSTripDealerContainerVC ()	<LLSegmentBarVCDelegate, SOSTripFirstDealerDelegate>

@property (nonatomic, strong) NNDealers *firstDealer;


@end

@implementation SOSTripDealerContainerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"经销商";
}

- (void)setDealerArray:(NSArray<NNDealers *> *)dealerArray	{
    _dealerArray = dealerArray.copy;
    if (self.aroundDealerVC) {
        self.aroundDealerVC.dealerArray = dealerArray.copy;
    }
}

- (void)setRecommendDealerArray:(NSArray<NNDealers *> *)recommendDealerArray	{
    _recommendDealerArray = recommendDealerArray.copy;
    if (self.aroundDealerVC) {
        self.aroundDealerVC.recommendDealerArray = recommendDealerArray.copy;
    }
}

- (void)viewWillAppear:(BOOL)animated	{
    [super viewWillAppear:animated];
    if (self.segmentVC.segmentBar.selectIndex) 	{
        [[NSNotificationCenter defaultCenter] postNotificationName:KNeedShowDealerListMapNotify object:@{@"dataArray": self.dealerArray, @"tableView": self.aroundDealerVC.dataTableView}];
    }	else	{
        [[NSNotificationCenter defaultCenter] postNotificationName:KNeedShowFirstDealerMapNotify object:self.firstDealer];
    }
}

- (void)configSelf    {
    self.segmentVC.originY = 0;
    self.firstDealerVC = [SOSTripFirstDealerVC new];
    self.firstDealerVC.delegate = self;
    
    self.aroundDealerVC = [SOSTripAroundDealerVC new];
    self.aroundDealerVC.dealerArray = self.dealerArray;
    self.aroundDealerVC.recommendDealerArray = self.recommendDealerArray;
    
    [self setUpWithItems:@[@"首选经销商", @"附近经销商"] childVCs:@[self.firstDealerVC, self.aroundDealerVC]];
    
    self.segmentVC.delegate = self;
    [self firstDealerReloadButtonTapped];
    self.firstDealerVC.fullScreenMode = self.fullScreenMode;
}

- (void)segmentBar:(LLSegmentBar *)segmentBar didSelectIndex:(NSInteger)toIndex fromIndex:(NSInteger)fromIndex {
    if (toIndex) 	{
        [[NSNotificationCenter defaultCenter] postNotificationName:KNeedShowDealerListMapNotify object:@{@"dataArray": self.dealerArray, @"tableView": self.aroundDealerVC.dataTableView}];
    }	else			{
        [[NSNotificationCenter defaultCenter] postNotificationName:KNeedShowFirstDealerMapNotify object:self.firstDealer];
    }
}

#pragma mark - First Dealer Delegate
- (void)firstDealerReloadButtonTapped	{
    self.firstDealerVC.status = SOSTripFirstDealerStatus_Loading;
    [SOSDealerTool getPreferredDealerWithCenterPOI:[CustomerInfo sharedInstance].currentPositionPoi Success:^(NNDealers *dealer) {
        self.firstDealer = dealer;
        dispatch_async_on_main_queue(^{
            if (dealer) {
                self.firstDealerVC.status = SOSTripFirstDealerStatus_Success;
                self.firstDealerVC.dealer = dealer;
            }    else    {
                self.firstDealerVC.status = SOSTripFirstDealerStatus_Empty;
            }
        });
    } Failure:^{
        dispatch_async_on_main_queue(^{
            self.firstDealerVC.status = SOSTripFirstDealerStatus_Fail;
        });
    }];
}


@end
