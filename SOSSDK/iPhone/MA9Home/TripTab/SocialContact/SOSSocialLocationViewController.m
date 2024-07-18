//
//  SOSSocialLocationViewController.m
//  Onstar
//
//  Created by onstar on 2019/4/22.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSSocialLocationViewController.h"
#import "SOSSocialLocationView.h"
#import "SOSSocialService.h"
#import "SOSNavigateTool.h"
#import "SOSSocialBeginGPSViewController.h"
#import "SOSSocialRecoverViewController.h"
#import "SOSUserLocation.h"
#import "SOSSocialCarGPSFinishViewController.h"
#import "SOSSocialContactViewController.h"

@interface SOSSocialLocationViewController ()

@end

@implementation SOSSocialLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.fd_prefersNavigationBarHidden = NO;
    self.title = @"我来接";
    //车机距离<500m
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOSNotificationCarGPSFinish object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        SOSSocialCarGPSFinishViewController *vc = [[SOSSocialCarGPSFinishViewController alloc] initWithNibName:@"SOSSocialCarGPSFinishViewController" bundle:nil];
        vc.currentPOI = self.infoPOI;
        [self.navigationController pushViewController:vc wantToRemoveViewController:self animated:YES];
        
    }];
}


- (void)setMapType:(MapType)mapType        {
    self.view.backgroundColor = self.view.backgroundColor;
    self.topNavTopGuide.constant = 0;
    self.topNavHeightGuide.constant = 0;
    [self addLocationDetailView];
}

- (void)addLocationDetailView {
    [self.mapView addPoiPoint:self.infoPOI];
    [self.mapView showPoiPoints:@[self.infoPOI]];
    SOSSocialLocationView *locationView = [SOSSocialLocationView viewFromXib];
    [self.cardBGView addSubview:locationView];
    [locationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.right.mas_equalTo(-12);
        make.top.bottom.mas_equalTo(0);
    }];
    locationView.locationLabel.text = self.selectedPOI.name;
    locationView.locationDetailLabel.text = self.selectedPOI.address;
    @weakify(self)
    locationView.acceptTap = ^{
        @strongify(self)
        [self acceptTap];
    };
    
    locationView.cancelTap = ^{
        @strongify(self)
        [self cancelTap];
    };
    
    locationView.sendToCarTap = ^{
        @strongify(self)
        [self sendToCarTap];
    };
    
}

- (void)acceptTap {
    [SOSDaapManager sendActionInfo:Pipup_PASSENGERCONFIRM_go];
    CustomerInfo *customerInfo = [CustomerInfo sharedInstance];
    SOSSocialBeginGPSViewController *vc = [[SOSSocialBeginGPSViewController alloc] initWithRouteBeginPOI:customerInfo.currentPositionPoi AndEndPOI:self.infoPOI];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)cancelTap {
    [SOSDaapManager sendActionInfo:Pipup_PASSENGERCONFIRM_Deny];
    [self changeStatus:@"CANCEL" success:^{
        [[SOSSocialService shareInstance] endUploadLocationService];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)sendToCarTap {
    [SOSDaapManager sendActionInfo:Pipup_PASSENGERCONFIRM_sendtocar];
    [SOSNavigateTool sendToCarAutoWithPOI:self.infoPOI];
    //** 监测指令下发状态 使用范例
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOS_VEHICLE_OPERATE_NOTIFICATION object:nil] subscribeNext:^(NSNotification *x) {
        NSDictionary *userInfo = x.userInfo;
        //    @{@"state":@(RemoteControlStatus), @"OperationType" : @(SOSRemoteOperationType) , @"message": message}
        SOSRemoteOperationType operationType = [userInfo[@"OperationType"] intValue];
        if (operationType == SOSRemoteOperationType_SendPOI_ODD) {
            [Util showHUDWithStatus:@"路线正在下发,请耐心等待1-3分钟"];
            RemoteControlStatus state = [userInfo[@"state"] intValue];
            switch (state) {
                case RemoteControlStatus_InitSuccess:
                    NSLog(@"init成功");
                    
                    break;
                case RemoteControlStatus_OperateSuccess:
                {
                    NSLog(@"下发成功");
                    [Util dismissHUD];
                    @weakify(self)
                    [self changeStatus:@"DRIVERCONFIRMFORVEHICLE" success:^{
                        //再次发送地点到车页面
                        @strongify(self)
                        //上传司机位置
                        [self uploadLocation];
                        //开启server
                        [[SOSSocialService shareInstance] startUploadLocationServiceWithPoi:self.infoPOI];
                        
                        SOSSocialRecoverViewController *v = [[SOSSocialRecoverViewController alloc] initWithNibName:@"SOSSocialRecoverViewController" bundle:nil];
                        v.currentPOI = self.selectedPOI;
                        [self.navigationController pushViewController:v wantToRemoveViewController:self animated:YES];
                    }];
                }
                    break;
                case RemoteControlStatus_OperateTimeout:
                case RemoteControlStatus_OperateFail:
                    NSLog(@"下发失败");
                    [Util showAlertWithTitle:@"路线下发失败,请重试" message:nil confirmBtn:@"知道了" completeBlock:nil];
                    [Util dismissHUD];
                    break;
                default:
                    break;
            }
        }
    }];
    
    
}

- (void)changeStatus:(NSString *)statusName success:(void(^)(void))success {
    [Util showHUD];
    [SOSSocialService changeStatusWithParams:@{@"statusName":statusName} success:^{
        [Util dismissHUD];
        !success?:success();
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

- (void)uploadLocation {
    [[SOSUserLocation sharedInstance] getLocationWithAccuarcy:kCLLocationAccuracyNearestTenMeters NeedReGeocode:NO isForceRequest:YES NeedShowAuthorizeFailAlert:NO success:^(SOSPOI *poi) {
        [SOSSocialService uploadLocationWithParams:@{@"driverLocation":[NSString stringWithFormat:@"%.6f,%.6f",poi.longitude.doubleValue,poi.latitude.doubleValue]} success:^{
            
        } Failed:^(NSString * _Nonnull responseStr, NSError * _Nonnull error) {
            
        }];
    } Failure:nil];
}

@end
