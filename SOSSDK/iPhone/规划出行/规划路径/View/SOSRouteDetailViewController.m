//
//  SOSRouteDetailViewController.m
//  Onstar
//
//  Created by Genie Sun on 2017/8/11.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSRouteTool.h"
#import "SOSRouteDetailViewController.h"

@interface SOSRouteDetailViewController ()	{
    __weak IBOutlet UILabel *distanceUnitLb;
    __weak IBOutlet UILabel *distanceLabel;
    __weak IBOutlet UILabel *timeUnitLabel;
    __weak IBOutlet UILabel *timeLabel;
    __weak IBOutlet UIView *loadingView;
    __weak IBOutlet UIActivityIndicatorView *loadingIndicator;
    __weak IBOutlet UILabel *timeTitleLabel;
    __weak IBOutlet UILabel *distanceTitleLabel;
    
}
@end

@implementation SOSRouteDetailViewController

- (void)showLoadingView:(BOOL)show  {
    if (loadingView.hidden != show)     return;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (show) {
            loadingView.hidden = NO;
            [loadingIndicator startAnimating];
        }   else    {
            loadingView.hidden = YES;
            [loadingIndicator stopAnimating];
        }
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.view.width == 0) {
        self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 80);
    }
//    [self configRouteTimeAndLength];
}

- (void)setRouteInfo:(SOSRouteInfo *)routeInfo		{
    _routeInfo = routeInfo;
    dispatch_async(dispatch_get_main_queue(), ^{
//        if (routeInfo.routeLength < 1000) {
//            distanceLabel.text = [NSString stringWithFormat:@"%d", (int)routeInfo.routeLength];
//            [distanceUnitLb setText:@"米"];
//        }    else    {
//            distanceLabel.text = [NSString stringWithFormat:@"%.2f", routeInfo.routeLength / 1000.f];
//            [distanceUnitLb setText:@"公里"];
//        }
//        int driveTime = routeInfo.routeTime ? routeInfo.routeTime : 1;
//        timeLabel.text = [NSString stringWithFormat:@"%d", driveTime];
//        timeUnitLabel.text = @"分钟";
//        timeUnitLabel.hidden = NO;
//        if (self.strategy == DriveStrategyWalk) {
//            timeTitleLabel.text = @"步行时长";
//        }
        [self configRouteTimeAndLength];
    });
}

- (void)configRouteTimeAndLength    {
    SOSRouteInfo *info = self.routeInfo;
    int driveTime = info.routeTime;

    if (info.routeLength < 1000 || self.strategy == DriveStrategyWalk) {
        distanceLabel.text = [NSString stringWithFormat:@"%d", (int)info.routeLength];
        [distanceUnitLb setText:@"米"];
    }    else    {
        distanceLabel.text = [NSString stringWithFormat:@"%.2f", info.routeLength / 1000.f];
        [distanceUnitLb setText:@"公里"];
    }
    if (self.strategy == DriveStrategyWalk) {
        timeLabel.text = @(driveTime).stringValue;
        timeUnitLabel.text = @"分钟";
        timeUnitLabel.hidden = NO;
        timeTitleLabel.text = @"步行时长";
    }	else	{
        timeTitleLabel.text = @"行程时长";
        int drive_hour = driveTime / 60;
        NSString *drivehourStr = [NSString stringWithFormat:@"%d%@",drive_hour,@":"];
        int drive_minute = driveTime % 60;
        NSString *driveminuteStr = (drive_minute > 0) ? [NSString stringWithFormat:@"%02d", drive_minute] : (drivehourStr.length>0)?@"": @"0";
        if (!driveminuteStr.isNotBlank) {
            driveminuteStr = @"01";
        }
        NSString *driveTimeStr = [NSString stringWithFormat:@"%@%@", drivehourStr, driveminuteStr];
        [timeLabel setText:driveTimeStr];
        timeUnitLabel.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
