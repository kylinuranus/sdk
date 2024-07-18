//
//  SOSAYLoadingVC.m
//  Onstar
//
//  Created by Coir on 2018/11/9.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSAYChargeManager.h"
#import "SOSAYLoadingVC.h"
#import "LoadingView.h"

@interface SOSAYLoadingVC ()

@end

@implementation SOSAYLoadingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = NO;
    self.title = @"安悦充电";
}

- (void)viewWillAppear:(BOOL)animated	{
    [super viewWillAppear:animated];
    [[LoadingView sharedInstance] startIn:self.view];
    [[CustomerInfo sharedInstance].servicesInfo getServiceStatus:@"ChargeStation" Success:^(NSDictionary *result) {
        [[LoadingView sharedInstance] stop];
        [SOSAYChargeManager enterAYChargeVCWithServiceStatus:[CustomerInfo sharedInstance].servicesInfo.ChargeStation.optStatus IsFromCarLife:YES code:_code];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[SOS_APP_DELEGATE fetchMainNavigationController].topViewController clearNavVCWithClassNameArray:@[@"SOSAYLoadingVC"]];
        });
    } Failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util toastWithMessage:@"数据获取失败"];
    }];
}

@end
