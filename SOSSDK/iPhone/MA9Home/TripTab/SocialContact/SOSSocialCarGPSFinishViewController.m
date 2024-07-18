//
//  SOSSocialCarGPSFinishViewController.m
//  Onstar
//
//  Created by onstar on 2019/5/16.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSSocialCarGPSFinishViewController.h"
#import "SOSSocialService.h"
#import "SOSSocialContactViewController.h"

@interface SOSSocialCarGPSFinishViewController ()
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@end

@implementation SOSSocialCarGPSFinishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationLabel.text = self.currentPOI.name;
}

- (IBAction)FinishButtonTap:(id)sender {
    [self finishJourney];
}

- (void)finishJourney {
    [SOSDaapManager sendActionInfo:Pipup_DRIVERCONCAR_finish];
    [Util showHUD];
    [SOSSocialService changeStatusWithParams:@{@"statusName":@"FINISH"} success:^{
        [Util dismissHUD];
        [self.navigationController popToRootViewControllerAnimated:YES];
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
