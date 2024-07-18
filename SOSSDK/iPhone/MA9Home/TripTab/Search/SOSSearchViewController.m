//
//  SOSSearchViewController.m
//  Onstar
//
//  Created by Genie Sun on 2017/8/9.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSSearchViewController.h"
#import "SOSHistoryViewController.h"
#import "SOSCollectViewController.h"

@interface SOSSearchViewController ()   <LLSegmentBarVCDelegate>   {
    SOSHistoryViewController *firstVC;
    SOSCollectViewController *secondVC;
}
@end

@implementation SOSSearchViewController

- (instancetype)initWithItems:(NSArray *)itemsArray
{
    self = [super init];
    if (self) {
        self.items = itemsArray;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.segmentVC.contentView.scrollEnabled = NO;
    self.segmentVC.delegate = self;
    self.fd_prefersNavigationBarHidden = YES;
    
    firstVC = [[SOSHistoryViewController alloc] initWithNibName:@"SOSHistoryViewController" bundle:nil];
    firstVC.fieldSearch = _tf;
    firstVC.fromGeoFecing = self.fromGeoFecing;
    firstVC.operationType = self.operationType;
    firstVC.geoFence = self.geoFence;
    
    secondVC = [[SOSCollectViewController alloc] initWithNibName:@"SOSCollectViewController" bundle:nil];
    secondVC.fromGeoFecing = self.fromGeoFecing;
    secondVC.operationType = self.operationType;
    secondVC.geoFence = self.geoFence;
    if (!self.items) {
        self.items = @[@"历史",@"收藏夹"];
    }
    [self setUpWithItems:self.items childVCs:@[firstVC,secondVC]];
}

- (void)segmentBar:(LLSegmentBar *)segmentBar didSelectIndex:(NSInteger)toIndex fromIndex:(NSInteger)fromIndex      {
    switch (self.operationType) {
        case OperationType_set_Route_Begin_POI:
            [SOSDaapManager sendActionInfo:toIndex == 0 ? Trip_GoWhere_POIdetail_GoHere_StartPosition_HistoryTab_POISelect : Trip_GoWhere_POIdetail_GoHere_StartPosition_FavoriteTab_POISelect];
            break;
        case OperationType_set_Route_Destination_POI:
            [SOSDaapManager sendActionInfo:toIndex == 0 ? Trip_GoWhere_POIdetail_GoHere_EndPosition_HistoryTab_POISelect : Trip_GoWhere_POIdetail_GoHere_EndtPosition_FavoriteTab_POISelect];
            break;
        case OperationType_Set_GroupTrip_Destination:
            [SOSDaapManager sendActionInfo:toIndex == 0 ? GroupToTravel_Group_SetDestination_History : GroupToTravel_Group_SetDestination_Favorites];
            break;
        default:
            [SOSDaapManager sendActionInfo:toIndex == 0 ? Trip_GoWhere_HistoryTab : Trip_GoWhere_FavoriteTab];
            break;
    }
    if (toIndex == 1) 	{
        LoginManage *manager = [LoginManage sharedInstance];
        if (![manager isLoadingUserBasicInfoReady]) {
            [manager checkAndShowLoginViewWithFromViewCtr:self andTobePushViewCtr:nil completion:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.segmentVC.segmentBar.selectIndex = 0;
            });
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
