//
//  SOSReservationDealersViewController.m
//  Onstar
//
//  Created by Genie Sun on 2017/8/2.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSReservationDealersViewController.h"
#import "SOSUserLocation.h"
#import "LoadingView.h"
#import "SOSNearByController.h"

@interface SOSReservationDealersViewController ()<LLSegmentBarVCDelegate>
@property (weak, nonatomic) SOSPreferredDealerViewController *firstDealerVC;
@property (weak, nonatomic) SOSNearByController *aroundDearler;

@property (weak, nonatomic) SOSPOI *currentLocationPOI;

@end

@implementation SOSReservationDealersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"经销商预约";
    self.backRecordFunctionID = Dealeraptmt_back;
    [SOSUtilConfig setNavigationBarItemTitle:@"预约记录" target:self selector:@selector(reservationRecode)];

    SOSPreferredDealerViewController *firstDealerVC = [[SOSPreferredDealerViewController alloc] initWithNibName:@"SOSPreferredDealerViewController" bundle:nil];
    _firstDealerVC = firstDealerVC;

    SOSNearByController *vc = [[SOSNearByController alloc] init];
    _aroundDearler = vc;
    self.segmentVC.delegate = self;
    [self setUpWithItems:@[@"首选经销商",@"附近经销商"] childVCs:@[firstDealerVC, vc]];
    [self locate];
    @weakify(self);
    if (self.selectPOI == nil) {
        [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidBecomeActiveNotification object:nil] subscribeNext:^(NSNotification *notification) {
            @strongify(self);
            self.currentLocationPOI = nil;
            [self locate];
        }];
    }
}

- (void)locate {
    [[LoadingView sharedInstance] startIn:self.view];
    self.currentLocationPOI = self.selectPOI;
    if (!_currentLocationPOI) {
        
        [[SOSUserLocation sharedInstance] getLocationWithAccuarcy:kCLLocationAccuracyKilometer NeedReGeocode:YES isForceRequest:NO NeedShowAuthorizeFailAlert:YES success:^(SOSPOI *userLocationPoi) {
            _currentLocationPOI = userLocationPoi;
            [_firstDealerVC startLoadData:_currentLocationPOI];
            [_aroundDearler getNearByList:_currentLocationPOI];
        } Failure:^(NSError *error) {
            if (error.code == 5) {
                return;
            }
            [Util toastWithMessage:@"可能由于您的GPS信号问题暂时无法为您展开距离信息，请稍候再试"];
            [_firstDealerVC startLoadData:nil];
        }];
    }	else {
        [_firstDealerVC startLoadData:_currentLocationPOI];
        [_aroundDearler getNearByList:_currentLocationPOI];
    }
}

- (void)reservationRecode{
    
    SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:SOSDEALER_RECORD];
    vc.isDealer = YES;
    [self.navigationController pushViewController:vc animated:YES];

}

- (void)dealloc {
    NSLog(@"dealloc========SOSReservationDealersViewController");
}


- (void)segmentBar:(LLSegmentBar *)segmentBar didSelectIndex:(NSInteger)toIndex fromIndex:(NSInteger)fromIndex  {
    if (toIndex == 0) {
        [SOSDaapManager sendActionInfo:Dealeraptmt_PrfdealerTab];
    }
}

@end
