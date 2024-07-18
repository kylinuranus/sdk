//
//  SOSLBSPOISendSuccessVC.m
//  Onstar
//
//  Created by Coir on 2/11/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSLBSPOISendSuccessVC.h"
#import "SOSCustomAlertView.h"

@interface SOSLBSPOISendSuccessVC ()    <SOSAlertViewDelegate>

@end

@implementation SOSLBSPOISendSuccessVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)phoneButtonTapped {
    SOSCustomAlertView *alert = [[SOSCustomAlertView alloc] initWithTitle:@"拨打客服?" detailText:@"400-820-1188" cancelButtonTitle:@"拨打" otherButtonTitles:@[@"取消"]];
    alert.pageModel = SOSAlertViewModelCallPhone_Icon;
    alert.backgroundModel = SOSAlertBackGroundModelWhite;
    [alert show];
}

- (IBAction)knownButtonTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sosAlertView:(SOSCustomAlertView *)alertView didClickButtonAtIndex:(NSInteger)buttonIndex   {
    if (buttonIndex) {
        [SOSUtil callPhoneNumber:@"400-820-1188"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
