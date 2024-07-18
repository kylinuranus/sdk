//
//  SOSSocialGPSViewController.m
//  Onstar
//
//  Created by onstar on 2019/4/26.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSSocialGPSViewController.h"
#import "SOSSocialGPSEndViewController.h"
#import "SOSSocialRecoverViewController.h"

@interface SOSSocialGPSViewController ()

@end

@implementation SOSSocialGPSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/**
 * @brief GPS导航到达目的地后的回调函数
 * @param driveManager 驾车导航管理类
 */
- (void)driveManagerOnArrivedDestination:(AMapNaviDriveManager *)driveManager
{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"到达目的地");
        SOSSocialGPSEndViewController *vc = [[SOSSocialGPSEndViewController alloc] initWithRouteBeginPOI:self.startPoint AndEndPOI:self.endPoint];
        [self.navigationController pushViewController:vc wantToRemoveViewController:self animated:YES];
    });
    
}

- (void)navAction {
//    [self.navigationController popToRootViewControllerAnimated:NO];
    //点击X 恢复导航
    SOSSocialRecoverViewController *v = [[SOSSocialRecoverViewController alloc] initWithNibName:@"SOSSocialRecoverViewController" bundle:nil];
    v.currentPOI = self.endPoint;
    v.mobileType = YES;
    [self.navigationController pushViewController:v wantToRemoveViewController:self animated:NO];
}


@end
