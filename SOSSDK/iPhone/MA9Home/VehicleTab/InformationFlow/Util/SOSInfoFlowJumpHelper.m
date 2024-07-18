//
//  SOSInfoFlowJumpHelper.m
//  Onstar
//
//  Created by TaoLiang on 2019/1/14.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSInfoFlowJumpHelper.h"
#import "SOSInfoFlowJumpHeader.h"

#define SelectorValue(SEL) [NSValue valueWithPointer:SEL]


@interface SOSInfoFlowJumpHelper ()
@property (strong, nonatomic) NSDictionary<NSString *, NSValue *> *reflects;
@end


@implementation SOSInfoFlowJumpHelper

- (instancetype)initWithFromViewController:(__kindof UIViewController *)fromViewController {
    if (self = [super init]) {
        _fromViewController = fromViewController;
        _reflects = @{
                      @"depart":  SelectorValue(@selector(jumpToDeparture:)),
                      @"carCondition":  SelectorValue(@selector(jumpToCarCondition)),
                      @"packageBuy":  SelectorValue(@selector(jumpToPackageBuy)),
                      @"packageDetail":  SelectorValue(@selector(jumpToPackageDetail)),
                      @"cellularRecharge":   SelectorValue(@selector(jumpToCellularRecharge)),
                      @"cellularDetail": SelectorValue(@selector(jumpToCellularDetail)),
//                      @"lastTrip": SelectorValue(@selector(jumpToLastTrip)),
//                      @"driveReport": SelectorValue(@selector(jumpToDriveReport)),
                      @"driveEvaluation": SelectorValue(@selector(jumpToDrivingScore)),
                      @"oilRank": SelectorValue(@selector(jumpToOilRank)),
                      @"tripStar": SelectorValue(@selector(jumpToTripStar)),
                      @"IM": SelectorValue(@selector(jumpToIMHomePage)),
                      @"vehicleEvaluation": SelectorValue(@selector(jumpToVehicleEvaluation)),
                      @"insurance": SelectorValue(@selector(jumpToInsurance)),
                      @"forumMessage": SelectorValue(@selector(forumMessage)),
                      };
        
    }
    return self;
}

- (void)jumpTo:(SOSIFComponent *)component para:(id)para {
    NSLog(@"jump to %@", component.link);
    if ([component.type isEqualToString:@"H5"]) {
        SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:component.link];
        [self pushToViewController:vc];
    }else if ([component.type isEqualToString:@"CLIENT"]) {
        SEL selector = _reflects[component.link].pointerValue;
        if (!selector) {
            return;
        }
        SuppressPerformSelectorLeakWarning([self performSelector:selector withObject:para]);
    }
}

- (void)jumpToDeparture:(id)para {
    SOSPOI *poi = [SOSPOI mj_objectWithKeyValues:para];
    SOSTripPOIVC *vc = [[SOSTripPOIVC alloc] initWithPOI:poi];
    vc.mapType = MapTypeShowPoiPoint;
    [self pushToViewController:vc];
    
}

- (void)jumpToCarCondition {
    [SOSCardUtil routerToVehicleCondition];
}

- (void)jumpToPackageBuy {
    [SOSCardUtil routerToBuyOnstarPackage:PackageType_Core];
}

- (void)jumpToPackageDetail {
    [SOSCardUtil routerToOnstarPackage];

}

- (void)jumpToCellularRecharge {
    [SOSCardUtil routerToBuyOnstarPackage:PackageType_4G];
}

- (void)jumpToCellularDetail {
    [SOSCardUtil routerTo4GPackage];
}

//- (void)jumpToLastTrip {
//    
//}
//
//- (void)jumpToDriveReport {
//}

- (void)jumpToDrivingScore {
    [SOSCardUtil routerToDrivingScoreH5];
}

- (void)jumpToOilRank {
    if ([Util vehicleIsBEV] || [Util vehicleIsPHEV]) {
        [SOSCardUtil routerToEnergyRankH5];
    }else {
        [SOSCardUtil routerToOilRankH5];
    }

}

//里程之星
- (void)jumpToTripStar {
    if ([Util vehicleIsBEV] || [Util vehicleIsPHEV]) {
        [SOSCardUtil routerToEnergyRankH5];
    }else {    
        [SOSCardUtil routerToOilRankH5];
    }
}

//- (void)jumpToStarTripTabA {
//    [SOSCardUtil routerToStarTravelH5];
//}

- (void)jumpToIMHomePage {
#ifndef SOSSDK_SDK
    [[SOSIMLoginManager sharedManager] pushToIMHomePageFrom:_fromViewController];
#endif
}

- (void)jumpToVehicleEvaluation {
    [SOSCardUtil routerToCarReportH5];
}

- (void)jumpToInsurance {
    [SOSCardUtil routerToH5Url:UBI_INSURANCE_URL];
}

- (void)forumMessage {
    [MsgCenterManager jumpToForumMessage];
}

#pragma mark - Private


- (void)pushToViewController:(__kindof UIViewController *)viewController {
    if (_fromViewController.navigationController) {
        [_fromViewController.navigationController pushViewController:viewController animated:YES];
    }else {
        [_fromViewController presentViewController:viewController animated:YES completion:nil];
    }
}

@end
