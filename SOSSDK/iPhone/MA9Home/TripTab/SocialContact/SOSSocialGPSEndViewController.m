//
//  SOSSocialGPSEndViewController.m
//  Onstar
//
//  Created by onstar on 2019/4/24.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSSocialGPSEndViewController.h"
#import "SOSRouteTool.h"
#import "SOSSocialGPSEndView.h"
#import "SOSSocialService.h"
#import "SOSSocialContactViewController.h"

@interface SOSSocialGPSEndViewController ()
@property (nonatomic, strong) SOSPOI *beginPOI;
@property (nonatomic, strong) SOSPOI *endPOI;
@property (nonatomic, strong) SOSRouteTool *routeTool;
@end

@implementation SOSSocialGPSEndViewController

- (instancetype)initWithRouteBeginPOI:(SOSPOI *)beginPOI AndEndPOI:(SOSPOI *)endPOI    {
    self = [super init];
    if (self) {
        self.beginPOI = [beginPOI copy];
        self.endPOI = [endPOI copy];
        self.mapType = MapTypeShowRoute;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.topNavBGView.hidden = YES;
    self.funcButtonBGView.hidden = YES;
    self.trafficButton.hidden = YES;
    self.fd_prefersNavigationBarHidden = NO;
    self.title = @"我来接";
}

- (void)viewWillAppear:(BOOL)animated    {
    [super viewWillAppear:animated];
    [self getRouteLines];
}

- (void)getRouteLines    {
    [Util showHUD];
    if (!self.routeTool)    self.routeTool = [SOSRouteTool new];
    __weak __typeof(self) weakSelf = self;
        [self.routeTool searchWithBeginPOI:self.beginPOI AndDestinationPoi:self.endPOI WithStrategy:DriveStrategyTimeFirst Success:^(SOSRouteSearchResultType resultType, SOSRouteInfo *routeInfo, NSArray *polylines, NSArray *routes) {
            [Util dismissHUD];
            [weakSelf showPolyLines:polylines];
            [weakSelf addLocationDetailViewWithRouterInfo:routeInfo];
        } failure:^(NSString *errorCode) {
            [Util dismissHUD];
        }];
}

- (void)showPolyLines:(NSArray *)polylines {
    [self.mapView addOverlays:polylines level: MAOverlayLevelAboveRoads];
    [self.mapView showPolylines:polylines];
    [self showAnnotations];
}

- (void)showAnnotations
{
    self.mapView.isGPSEndMapMode = YES;
    self.beginPOI.sosPoiType = POI_TYPE_ROUTE_BEGIN;
    self.endPOI.sosPoiType = POI_TYPE_ROUTE_END;
    [self.mapView addPoiPoints:@[self.beginPOI, self.endPOI]];
    [self.mapView selectAnnotation:self.mapView.annotations.firstObject animated:YES];
}

- (void)setMapType:(MapType)mapType        {
    self.view.backgroundColor = self.view.backgroundColor;
}

- (void)addLocationDetailViewWithRouterInfo:(SOSRouteInfo *)routeInfo {
    SOSSocialGPSEndView *endView = [SOSSocialGPSEndView viewFromXib];
    [self.cardBGView addSubview:endView];
    [endView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.right.mas_equalTo(-12);
        make.top.bottom.mas_equalTo(0);
    }];
//    if (routeInfo.routeTime > 60) {
//        self.minusLabel.text = @(routeInfo.routeTime % 60).stringValue;
//        self.hoursLabel.text = @(routeInfo.routeTime / 60).stringValue;
//        self.minusUnitLabel.text = @"分钟";
//        self.hoursUnitLabel.text = @"小时";
//    }    else    {
        endView.timeLabel.text = @(routeInfo.routeTime).stringValue;
        endView.timeUnitLabel.text = @"分钟";
//        self.hoursLabel.text = @"";
//        self.hoursUnitLabel.text = @"";
//    }
    if (routeInfo.routeLength > 1000) {
        endView.lengthLabel.text = [NSString stringWithFormat:@"%.1f", routeInfo.routeLength / 1000.f];
        endView.lengthUnitLabel.text = @"公里";
    }    else    {
        endView.lengthLabel.text = [NSString stringWithFormat:@"%@", @(routeInfo.routeLength)];
        endView.lengthUnitLabel.text = @"米";
    }
    
    endView.finishTapBlock = ^{
        NSLog(@"完成");
        [self finishJourney];
    };
    
}

- (void)finishJourney {
    [SOSDaapManager sendActionInfo:Pipup_DRIVERCONMA_FINISH];
    [Util showHUD];
    [SOSSocialService changeStatusWithParams:@{@"statusName":@"FINISH"} success:^{
        [Util dismissHUD];
        SOSSocialContactViewController *vc = [[SOSSocialContactViewController alloc] initWithNibName:@"SOSSocialContactViewController" bundle:nil];
        [self.navigationController pushViewController:vc wantToPopRootAnimated:YES];
        [[SOSSocialService shareInstance] endUploadLocationService];
    } Failed:^(NSString * _Nonnull responseStr, NSError * _Nonnull error) {
        [Util showErrorHUDWithStatus:[Util visibleErrorMessage:responseStr]];
        id errorr = [responseStr toBasicObject];
        if ([errorr isKindOfClass:[NSDictionary class]]) {
            
            if ([errorr[@"code"] isEqualToString:@"PICK1001"]||
                [errorr[@"code"] isEqualToString:@"PICK1002"]||
                [errorr[@"code"] isEqualToString:@"PICK1003"]) {
                SOSSocialContactViewController *vc = [[SOSSocialContactViewController alloc] initWithNibName:@"SOSSocialContactViewController" bundle:nil];
                [self.navigationController pushViewController:vc wantToPopRootAnimated:YES];
            }
        }
    }];
}


@end
