//
//  SOSTirpVehicleLocationView.m
//  Onstar
//
//  Created by Coir on 2018/12/19.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSChangeVehicleViewController.h"
#import "SOSTirpVehicleLocationView.h"
#import "SOSFlexibleAlertController.h"
#import "NavigateShareTool.h"
#import "SOSAroundSearchVC.h"
#import "SOSNavigateTool.h"
#import "SOSUserLocation.h"
#import "SOSTripRouteVC.h"

@interface SOSTirpVehicleLocationView ()
@property (weak, nonatomic) IBOutlet UILabel *vehicleNameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *statusImgView;
@property (weak, nonatomic) IBOutlet UIView *normalBGView;
@property (weak, nonatomic) IBOutlet UIButton *locationTitleButton;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *moreFuncButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIButton *successRenewButton;
@property (weak, nonatomic) IBOutlet UIButton *navigateTocarButton;

@end

@implementation SOSTirpVehicleLocationView

- (void)awakeFromNib	{
    [super awakeFromNib];
    if (SOS_CD_PRODUCT) {
        [_navigateTocarButton setTitleColor:[UIColor cadiStytle] forState:0];
    }
    // 监测登录状态变更
    [[[LoginManage sharedInstance] rac_valuesAndChangesForKeyPath:@"loginState" options:NSKeyValueObservingOptionNew observer:self] subscribeNext:^(RACTwoTuple<id,NSDictionary *> *x) {
        if ([LoginManage sharedInstance].loginState == LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS || [LoginManage sharedInstance].loginState == LOGIN_STATE_NON) {
            dispatch_async_on_main_queue(^{
                NSString *brandName = [Util getVehicleBrandName];
                if (brandName.length) self.vehicleNameLabel.text = [NSString stringWithFormat:@"我的%@", brandName];
            });
        }
    }];
}

- (void)setCardStatus:(SOSVehicleLocationCardStatus)cardStatus		{
    if (_cardStatus == cardStatus)		return;
    else	{
        _cardStatus = cardStatus;
        dispatch_async_on_main_queue(^{
            [self configSelfWithCardStatus];
        });
    }
}

- (void)configSelfWithCardStatus    {
    NSString *imgName = nil;
    BOOL loadDataSuccess = NO;
    switch (self.cardStatus) {
        case SOSVehicleLocationCardStatus_loading:
            imgName = @"Trip_User_Location_Card_Icon_Success";
            if (SOS_CD_PRODUCT) {
                imgName = [imgName stringByAppendingString:@"_sdkcd"];
            }
            [self.locationTitleButton setTitleForNormalState:@"获取中.."];
            self.addressLabel.text = @"";
            break;
        case SOSVehicleLocationCardStatus_fail:
            imgName = @"Trip_User_Location_Card_Icon_Fail";
            [self.locationTitleButton setTitleForNormalState:@"点击重新获取定位"];
            self.addressLabel.text = @"";
            break;
        case SOSVehicleLocationCardStatus_success:
            loadDataSuccess = YES;
            imgName = @"Trip_User_Location_Card_Icon_Success";
            if (SOS_CD_PRODUCT) {
                imgName = [imgName stringByAppendingString:@"_sdkcd"];
            }
            [self.locationTitleButton setTitleForNormalState:@""];
            break;
        default:
            break;
    }
    self.timeLabel.text = @"";
    self.statusImgView.image = [UIImage imageNamed:imgName];
    self.shareButton.userInteractionEnabled = loadDataSuccess;
    self.navigateTocarButton.enabled = loadDataSuccess;
    NSString * norc = @"6896ED";
    if (SOS_CD_PRODUCT) {
        norc = @"B5A36A";
       }
    self.navigateTocarButton.layer.borderColor = [UIColor colorWithHexString:(loadDataSuccess ? norc : @"9A9A9A")].CGColor;
    self.locationTitleButton.userInteractionEnabled = (self.cardStatus == SOSVehicleLocationCardStatus_fail);
    self.successRenewButton.userInteractionEnabled = (self.cardStatus != SOSVehicleLocationCardStatus_loading);
}

- (void)setVehicleLocationPOI:(SOSPOI *)vehicleLocationPOI	{
    _vehicleLocationPOI = [vehicleLocationPOI copy];
    dispatch_async_on_main_queue(^{
        self.cardStatus = SOSVehicleLocationCardStatus_success;
        [self.locationTitleButton setTitleForNormalState:vehicleLocationPOI.name];
        self.addressLabel.text = vehicleLocationPOI.address;
    });
    [self refreshTimeLabel];
}

- (void)refreshTimeLabel		{
    dispatch_async_on_main_queue(^{
        self.timeLabel.text = self.vehicleLocationPOI.gapTime;
    });
}

/// 弹出菜单 
- (IBAction)moreFuncButtonTapped {
    [SOSDaapManager sendActionInfo:TRIP_VEHICLELOCATION_MORE];
    SOSFlexibleAlertController *actionSheet = [SOSFlexibleAlertController alertControllerWithImage:nil title:nil message:nil customView:nil preferredStyle:SOSAlertControllerStyleActionSheet];
   // BOOL shouldAddGeo = !([Util vehicleIsG9] || [SOSCheckRoleUtil isDriverOrProxy]);
//    SOSAlertAction *geoAction = [SOSAlertAction actionWithTitle:@"电子围栏" style:SOSAlertActionStyleActionSheetDefault handler:^(SOSAlertAction * _Nonnull action) {
//        [SOSDaapManager sendActionInfo:TRIP_VEHICLELOCATION_GEOFENCE];
//        [SOSNavigateTool showGeoPageFromVC:self.viewController];
//    }];
    
    SOSAlertAction *switchCarAction = [SOSAlertAction actionWithTitle:@"切换车辆" style:SOSAlertActionStyleActionSheetDefault handler:^(SOSAlertAction * _Nonnull action) {
        [SOSDaapManager sendActionInfo:TRIP_VEHICLELOCATION_CHENGEVEHICLE];
        SOSChangeVehicleViewController *changeVc = [[SOSChangeVehicleViewController alloc] initWithNibName:@"SOSChangeVehicleViewController" bundle:nil];
        [self.viewController.navigationController pushViewController:changeVc animated:YES];
//        if (self.delegate && [self.delegate respondsToSelector:@selector(vehicleSwitchCarButtonTapped)]) {
//            [self.delegate vehicleSwitchCarButtonTapped];
//        }
    }];
    SOSAlertAction *cancelAction = [SOSAlertAction actionWithTitle:@"取消" style:SOSAlertActionStyleCancel handler:^(SOSAlertAction * _Nonnull action) {
        [SOSDaapManager sendActionInfo:TRIP_VEHICLELOCATION_CANCEL];
    }];
//    [actionSheet addActions:shouldAddGeo ? @[geoAction, switchCarAction, cancelAction] : @[switchCarAction, cancelAction]];
    [actionSheet addActions: @[switchCarAction, cancelAction]];
    
    [actionSheet show];
}

/// 分享
- (IBAction)shareButtonTapped 	{
    [SOSDaapManager sendActionInfo:TRIP_VEHICLELOCATION_SHARE];
    [[NavigateShareTool sharedInstance] shareWithNewUIWithPOI:self.vehicleLocationPOI];
    [NavigateShareTool sharedInstance].shareToMomentsDaapID = TRIP_VEHICLELOCATION_SHARE_MOMENTS;
    [NavigateShareTool sharedInstance].shareToChatDaapID = TRIP_VEHICLELOCATION_SHARE_WECHAT;
    [NavigateShareTool sharedInstance].shareCancelDaapID = TRIP_VEHICLELOCATION_SHARECANCEL;
}

/// 刷新
- (IBAction)renewLocationButtonTapped {
    [SOSDaapManager sendActionInfo:TRIP_VEHICLELOCATION_RETEST];
    if (self.delegate && [self.delegate respondsToSelector:@selector(refreshVehicleLocationButtonTapped)]) {
        [self.delegate refreshVehicleLocationButtonTapped];
    }
}

/// 导航找车
- (IBAction)navigateToCarButtonTapped {
    [SOSDaapManager sendActionInfo:TRIP_VEHICLELOCATION_FINDMYCAR];
    CustomerInfo *customerInfo = [CustomerInfo sharedInstance];
    /// 未获取到定位
    if (customerInfo.currentPositionPoi == nil) {
        // 未开启定位权限
        if ([[SOSUserLocation sharedInstance] checkAuthorizeAndShowAlert:NO] == NO)    {
            [Util showErrorHUDWithStatus:@"检测到未开启GPS定位。需开启GPS定位功能才可以使用该功能。"];
        }	else	{
            [Util showHUD];
            [[SOSUserLocation sharedInstance] getLocationSuccess:^(SOSPOI *userLocationPoi) {
                [self searchRouteLines];
            } Failure:^(NSError *error) {
                [Util showErrorHUDWithStatus:@"获取当前定位失败, 请稍后重试"];
            }];
        }
        return;
    }	else	{
        [Util showHUD];
		[self searchRouteLines];
    }
    
}

- (void)searchRouteLines	{
    CustomerInfo *customerInfo = [CustomerInfo sharedInstance];
    SOSTripRouteVC *vc = [[SOSTripRouteVC alloc] initWithRouteBeginPOI:customerInfo.currentPositionPoi AndEndPOI:self.vehicleLocationPOI IsFindCarMode:YES];
    [self.viewController.navigationController pushViewController:vc animated:YES];
}

@end
