//
//  SOSSocialBeginGPSViewController.m
//  Onstar
//
//  Created by onstar on 2019/4/25.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSSocialBeginGPSViewController.h"
#import "SOSSocialService.h"
#import "SOSUserLocation.h"
#import "SOSSocialGPSViewController.h"
#import "SOSSocialContactViewController.h"

@interface SOSSocialBeginGPSViewController ()

@end

@implementation SOSSocialBeginGPSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)navButtonAction {
    
}

- (void)beginGPSWithStrategy:(DriveStrategy)strategy {
    [SOSDaapManager sendActionInfo:Pipup_DRIVERCONMA_StartNAV];
    //改变状态
    [Util showLoadingView];
    [self changeStatusSuccess:^{
        [Util hideLoadView];
        [super beginGPSWithStrategy:strategy];
        
        //上传司机位置
        [self uploadLocation];
        //开启server
        [[SOSSocialService shareInstance] startUploadLocationService];
    } failed:^{
        [Util hideLoadView];
    }];
    
}

- (Class)getGPSVcClass {
    return SOSSocialGPSViewController.class;
}
- (void)changeStatusSuccess:(void(^)(void))success failed:(void(^)(void))failed{
    [SOSSocialService changeStatusWithParams:@{@"statusName":@"DRIVERCONFIRM"} success:success Failed:^(NSString * _Nonnull responseStr, NSError * _Nonnull error) {
        !failed?:failed();
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
