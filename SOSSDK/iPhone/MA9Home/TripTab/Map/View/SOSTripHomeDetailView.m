//
//  SOSTripHomeDetailView.m
//  Onstar
//
//  Created by Coir on 2019/4/25.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSTripHomeDetailView.h"
#import "SOSAroundSearchVC.h"
#import "NavigateShareTool.h"
#import "SOSNavigateTool.h"
#import "SOSTripRouteVC.h"

@interface SOSTripHomeDetailView ()

@property (weak, nonatomic) IBOutlet UILabel *flagLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;


@end

@implementation SOSTripHomeDetailView

- (void)setPoi:(SOSPOI *)poi	{
    _poi = poi.copy;
    dispatch_async_on_main_queue(^{
        self.flagLabel.text = (poi.sosPoiType == POI_TYPE_Home) ? @"住家" : @"公司";
        self.titleLabel.text = poi.name;
        self.addressLabel.text = poi.address;
    });
}

#pragma mark - Button Action
- (IBAction)shareButtonTapped {
    [[NavigateShareTool sharedInstance] shareWithNewUIWithPOI:self.poi];
    //    [NavigateShareTool sharedInstance].shareToMomentsDaapID = TRIP_MYLOCATION_SHARE_MOMENTS;
    //    [NavigateShareTool sharedInstance].shareToChatDaapID = TRIP_MYLOCATION_SHARE_WECHAT;
    //    [NavigateShareTool sharedInstance].shareCancelDaapID = TRIP_MYLOCATION_SHARECANCEL;
}

- (IBAction)aroundSerachButtonTapped {
    SOSAroundSearchVC *vc = [[SOSAroundSearchVC alloc] init];
    vc.selectedPoi = self.poi;
    [self.viewController.navigationController pushViewController:vc animated:YES];
}

- (IBAction)sendToCarButtonTapped {
    [SOSNavigateTool sendToCarAutoWithPOI:self.poi];
}

- (IBAction)routeButtonTapped {
    SOSTripRouteVC *vc = [[SOSTripRouteVC alloc] initWithRouteBeginPOI:[CustomerInfo sharedInstance].currentPositionPoi AndEndPOI:self.poi];
    [self.viewController.navigationController pushViewController:vc animated:YES];
}



@end
