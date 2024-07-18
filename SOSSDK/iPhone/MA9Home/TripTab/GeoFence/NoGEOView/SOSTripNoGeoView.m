//
//  SOSTripNoGeoView.m
//  Onstar
//
//  Created by Coir on 2019/6/12.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSTripNoGeoView.h"
#import "SOSRemoteTool.h"
#import "SOSGeoMapVC.h"

@interface SOSTripNoGeoView ()

@property (weak, nonatomic) IBOutlet UIView *contentBGView;

@end

@implementation SOSTripNoGeoView

+ (instancetype)viewFromXib	{
    SOSTripNoGeoView *noGeoView = [[NSBundle SOSBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil][0];
    noGeoView.hidden = YES;
    noGeoView.contentBGView.alpha = .3;
    noGeoView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    return noGeoView;
}

- (void)showInView:(UIView *)view 	{
    dispatch_async_on_main_queue(^{
        self.frame = view.bounds;
        [view addSubview:self];
        self.hidden = NO;
        [UIView animateWithDuration:.3 animations:^{
            self.contentBGView.alpha = 1;
        }];
    });
}

- (void)dismiss 	{
    dispatch_async_on_main_queue(^{
        [UIView animateWithDuration:.3 animations:^{
            self.contentBGView.alpha = .3;
        } completion:^(BOOL finished) {
            self.hidden = YES;
            [self removeFromSuperview];
        }];
    });
}


- (IBAction)cancelButtonTapped {
    [self dismiss];
}
//添加电子围栏
- (IBAction)addButtonTapped 	{
    NNGeoFence *defaultGeofence = [self buildDefaultGeofence];
    BOOL isLBSMode = (self.lbsPOI || self.LBSDataInfo);
    if (isLBSMode) 	[SOSDaapManager sendActionInfo:LBS_setting_geofence_emptyadd];
    SOSGeoMapVC *geoMapVC = [[SOSGeoMapVC alloc] initWithGeoFence:defaultGeofence];
    [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:geoMapVC animated:YES];
    [self dismiss];
}

- (NNGeoFence *)buildDefaultGeofence	{
    NNGeoFence *defaultGeofence;
    SOSPOI *centerPoi;
    BOOL isLBSMode = (self.lbsPOI || self.LBSDataInfo);
    if (isLBSMode) {
        [SOSDaapManager sendActionInfo:LBS_setting_geofence_emptyadd];
        NNLBSGeoFence *geofence = [NNLBSGeoFence new];
        // 设置围栏中心点, LBS 围栏模式 下 (LBS 设备位置 > 用户定位)
        if (self.lbsPOI) {
            centerPoi = self.lbsPOI;
            geofence.deviceId = self.lbsPOI.LBSIMEI;
            geofence.LBSDeviceName = self.lbsPOI.LBSDeviceName;
        }    else    {
            centerPoi = [CustomerInfo sharedInstance].currentPositionPoi;
            geofence.deviceId = self.LBSDataInfo.deviceid;
            geofence.LBSDeviceName = self.LBSDataInfo.devicename;
        }
        geofence.name = centerPoi.name;
        geofence.languageCode = @"ZH_CN";
        geofence.fenceStatus = @"ON";
        geofence.subscriber_id = [CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId;
        geofence.idpuserId = [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
        geofence.mobile = [CustomerInfo sharedInstance].userBasicInfo.subscriber.mobilePhone;
        
        defaultGeofence = geofence;
        defaultGeofence.isLBSMode = YES;
    }    else    {
        defaultGeofence = [NNGeoFence new];
        defaultGeofence.isLBSMode = NO;
        // 设置围栏中心点, 车辆围栏模式 下 (车辆定位 > 用户定位)
        SOSPOI *vehiclePOI = [[SOSRemoteTool sharedInstance] loadSavedVehicleLocation];
        if (vehiclePOI && vehiclePOI.isValidLocation) {
            centerPoi = vehiclePOI;
        }	else	{
            centerPoi = [CustomerInfo sharedInstance].currentPositionPoi;
        }
    }
    if (centerPoi) {
        defaultGeofence.centerPoiName = centerPoi.name;
        defaultGeofence.centerPoiAddress = centerPoi.address;
        defaultGeofence.centerPoiCoordinate = [NNCenterPoiCoordinate coordinateWithLongitude:centerPoi.longitude AndLatitude:centerPoi.latitude];
    }
    defaultGeofence.isNewToAdd = YES;
    defaultGeofence.isEditStatus = YES;
    defaultGeofence.range = @"1";
    defaultGeofence.geoFencingStatus = @"ON";
    defaultGeofence.alertType = @"OUT";
    
    defaultGeofence.mobilePhone = [CustomerInfo sharedInstance].userBasicInfo.subscriber.mobilePhone;
    defaultGeofence.vin = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin;
    defaultGeofence.vehModel = [[CustomerInfo sharedInstance] currentVehicle].modelDesc;
    defaultGeofence.vehMake = [[CustomerInfo sharedInstance] currentVehicle].makeDesc;
    defaultGeofence.acctNum = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId;
    
    return defaultGeofence;
}

@end
