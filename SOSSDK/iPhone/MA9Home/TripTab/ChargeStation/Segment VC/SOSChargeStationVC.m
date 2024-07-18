//
//  SOSChargeStationVC.m
//  Onstar
//
//  Created by Genie Sun on 2017/9/14.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "ChargeStationOBJ.h"
#import "SOSChargeStationVC.h"
#import "SOSAYChargeListVC.h"
#import "SOSDelearStationVC.h"

@interface SOSChargeStationVC () <LLSegmentBarVCDelegate>

@property (nonatomic, strong) SOSAYChargeListVC *chargeVC;
@property (nonatomic, strong) SOSDelearStationVC *supplierVC;

@end

@implementation SOSChargeStationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"充电桩";

}

- (void)viewDidAppear:(BOOL)animated	{
    [super viewDidAppear:animated];
    if (self.segmentVC.segmentBar.selectIndex == 0)	{
        if (self.chargeVC.stationList) {
               [[NSNotificationCenter defaultCenter] postNotificationName:KNeedShowStationListMapNotify object:@{@"dataArray": self.chargeVC.stationList, @"tableView": self.chargeVC.dataTableView}];
        }
       
    }    else    {
        if (self.supplierVC.stationList) {
            [[NSNotificationCenter defaultCenter] postNotificationName:KNeedShowStationListMapNotify object:@{@"dataArray": self.supplierVC.stationList, @"tableView": self.supplierVC.dataTableView}];
        }
    }
}

- (void)configSelf	{
    self.segmentVC.originY = 0;
    self.segmentVC.delegate = self;
    self.chargeVC = [[SOSAYChargeListVC alloc] initWithNibName:@"SOSAYChargeListVC" bundle:nil];
    self.chargeVC.selectPOI = self.selectPOI;
    self.chargeVC.stationList = self.stationArray;
    self.supplierVC = [[SOSDelearStationVC alloc] initWithNibName:@"SOSDelearStationVC" bundle:nil];
    self.supplierVC.selectPOI = self.selectPOI;
    NSArray *childVCArray;
    NSArray *nameArray;
    if ([Util vehicleIsCadillac])    {
        nameArray = @[@"附近充电站",@"凯迪拉克4S店"];
        childVCArray = @[self.chargeVC,self.supplierVC];
    }   else if ([Util vehicleIsBuick])     {
        nameArray = @[@"附近充电站",@"别克4S店"];
        childVCArray = @[self.chargeVC,self.supplierVC];
    }   else    {
        [self.view addSubview:self.chargeVC.view];
        self.chargeVC.view.frame = SOS_ONSTAR_WINDOW.bounds;
        [self addChildViewController:self.chargeVC];
        return;
    }
    
    [self setUpWithItems:nameArray childVCs:@[self.chargeVC,self.supplierVC]];
}

- (void)segmentBar:(LLSegmentBar *)segmentBar didSelectIndex:(NSInteger)toIndex fromIndex:(NSInteger)fromIndex {
    if (toIndex == 0) {
      
        [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundChargeStation_POIdetail_SeeMore_AroundChargeStationTab];
        if (self.chargeVC.stationList) {
                   [[NSNotificationCenter defaultCenter] postNotificationName:KNeedShowStationListMapNotify object:@{@"dataArray": self.chargeVC.stationList, @"tableView": self.chargeVC.dataTableView}];
              }
       
    }	else	{
        if ([Util vehicleIsCadillac]) {
            [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundChargeStation_POIdetail_SeeMore_Cadillac4STab];
        }	else if ([Util vehicleIsBuick])		{
            [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundChargeStation_POIdetail_SeeMore_Buick4STab];
        }
        if (self.supplierVC.stationList) {
             [[NSNotificationCenter defaultCenter] postNotificationName:KNeedShowStationListMapNotify object:@{@"dataArray": self.supplierVC.stationList, @"tableView": self.supplierVC.dataTableView}];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
