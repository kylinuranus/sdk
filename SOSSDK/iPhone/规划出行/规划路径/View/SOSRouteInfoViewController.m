//
//  SOSRouteInfoViewController.m
//  Onstar
//
//  Created by Genie Sun on 2017/8/11.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSRouteTool.h"
#import "SOSRouteMapVC.h"
#import "SOSRouteInfoViewController.h"
#import "SOSRouteDetailViewController.h"

@interface SOSRouteInfoViewController ()    <LLSegmentBarVCDelegate>     {
    SOSRouteTool *routeTool;
    int selectedIndex;
    /** 驾车导航策略数组 */
    NSArray *strategyArray;
    NSMutableArray *childVCArray;
}

@end

@implementation SOSRouteInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    routeTool = [SOSRouteTool new];
    self.segmentVC.delegate = self;
    self.segmentVC.originY = 0;
    
    selectedIndex = 0;
    strategyArray = @[@(DriveStrategyTimeFirst), @(DriveStrategyDestanceFirst), @(DriveStrategyNoExpressWay)];
    
    childVCArray = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        SOSRouteDetailViewController *vc = [SOSRouteDetailViewController new];
//        vc.view.frame = CGRectMake(0, 40, SCREEN_WIDTH, 80);
        vc.strategy = [strategyArray[i] intValue];
        vc.routePoisArray = [self.arraySelectPOI copy];
        vc.routeInfo = self.routeInfo;
        if (self.polylines.count && (i == 0))           vc.polyLines = self.polylines;
//        [vc configRouteTimeAndLength];
        [childVCArray addObject:vc];
    }
    
    [self setUpWithItems:@[@"用时最快",@"路程最短",@"不走高速"] childVCs:childVCArray];
}

- (SOSRouteDetailViewController *)selectedChildVC   {
    if (childVCArray.count <= selectedIndex || !childVCArray.count)  return nil;
    
    return (SOSRouteDetailViewController *)childVCArray[selectedIndex];
}

- (void)viewWillAppear:(BOOL)animated	{
    [super viewWillAppear:animated];
    
}

- (void)search  {
    SOSPOI *beginPoi;
    SOSPOI *destinationPoi;
    
    if (self.arraySelectPOI.count > 0) {
        beginPoi = NONil(self.arraySelectPOI[0]) ;
        destinationPoi = NONil(self.arraySelectPOI[1]);
    }
	__weak __typeof(self) weakSelf = self;
    DriveStrategy strategy = [strategyArray[selectedIndex] intValue];
    [routeTool searchWithBeginPOI:beginPoi AndDestinationPoi:destinationPoi WithStrategy:strategy Success:^(SOSRouteSearchResultType resultType, SOSRouteInfo *routeInfo, NSArray *polylines, NSArray *routes) {
        SOSRouteDetailViewController * selectedVC = weakSelf.selectedChildVC;
        selectedVC.polyLines = polylines;
        selectedVC.routeInfo = routeInfo;
        [selectedVC showLoadingView:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            /** 更改路线距离及时长信息 */
            [selectedVC configRouteTimeAndLength];
            [weakSelf changeRouteOnMap];
        });
    } failure:nil];
}

#pragma mark - SegmentBarVC Delegate
- (void)segmentBar:(LLSegmentBar *)segmentBar didSelectIndex:(NSInteger)toIndex fromIndex:(NSInteger)fromIndex  {
    if (selectedIndex == toIndex)   return;
    selectedIndex = (int)toIndex;
    NSString *reportString;
    switch (toIndex) {
        case 0:
            reportString = Map_POIdetail_quickroute;
            break;
        case 1:
            reportString = Map_POIdetail_shortroute;
            break;
        case 2:
            reportString = Map_POIdetail_avoidtoll;
            break;
        default:
            break;
    }
    [SOSDaapManager sendActionInfo:reportString];
    
    if (!self.selectedChildVC.polyLines) {
        [self.selectedChildVC showLoadingView:YES];
        [self search];
    }   else    {
        [self changeRouteOnMap];
    }
}

/** 更改地图上路线显示 */
- (void)changeRouteOnMap    {
    SOSRouteMapVC *navIndexVC;
    UIViewController *superParentVC = self.parentViewController;
    if ([superParentVC isKindOfClass:[SOSRouteMapVC class]]) {
        navIndexVC = (SOSRouteMapVC *)superParentVC;
        [navIndexVC showRoutePolylines:self.selectedChildVC.polyLines RouteInfos:self.selectedChildVC.routeInfo];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
