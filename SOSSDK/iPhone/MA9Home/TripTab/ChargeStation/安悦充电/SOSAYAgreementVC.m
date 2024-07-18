//
//  SOSAYAgreementVC.m
//  Onstar
//
//  Created by Coir on 2018/10/24.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "LoadingView.h"
#import "SOSAgreement.h"
#import "SOSAYAgreementVC.h"
#import "SOSAYChargeManager.h"

@interface SOSAYAgreementVC ()

@property (weak, nonatomic) IBOutlet UIButton *disagreeButton;
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;

@end

@implementation SOSAYAgreementVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = NO;
    self.title = @"服务授权";
    self.backDaapFunctionID = Map_POIdetail_anyocharging_Authorization_Back;
}

- (IBAction)showAgreementVC {
    [SOSAYChargeManager checkNetworkSuccess:^(NSInteger status)	{
        if (status) {
            [[LoadingView sharedInstance] startIn:self.view];
            [SOSAgreement requestAgreementsWithTypes:@[@"ONSTAR_CHARGE_STATION"] success:^(NSDictionary *response) {
                [SOSDaapManager sendActionInfo:Map_POIdetail_anyocharging_Authorization_Protocol];
                [[LoadingView sharedInstance] stop];
                if (response.count) {
                    NSDictionary *dic = response[@"ONSTAR_CHARGE_STATION"];
                    SOSAgreement *agreement = [SOSAgreement mj_objectWithKeyValues:dic];
                    SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:agreement.url];
                    vc.backDaapFunctionID = Map_POIdetail_anyocharging_Authorization_Protocol_Back;
                    [self.navigationController pushViewController:vc animated:YES];
                }
            } fail:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                [[LoadingView sharedInstance] stop];
            }];
        }
    }];
    
}

- (IBAction)acceptAgreementButtonTapped:(UIButton *)sender {
    if (sender == self.agreeButton) {
        [SOSDaapManager sendActionInfo:Map_POIdetail_anyocharging_Authorization_Agree];
        [SOSAYChargeManager checkNetworkSuccess:^(NSInteger status)    {
            if (status) {
                if ([SOSAYChargeManager  checkUserPhoneNum]) {
                    [[CustomerInfo sharedInstance].servicesInfo triggerService:YES serviceName:@"ChargeStation" callback:^{
                        NNserviceObject *serviceObj = [NNserviceObject new];
                        serviceObj.serviceName = @"ChargeStation";
                        serviceObj.optStatus = YES;
                        [CustomerInfo sharedInstance].servicesInfo.ChargeStation = serviceObj;
                        [SOSAYChargeManager enterAYChargeVCUseUserInfo];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self clearNavVCWithClassNameArray:@[@"SOSAYAgreementVC"]];
                        });
                    } failBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {    }];
                }
            }
        }];
    }	else if (sender == self.disagreeButton)		{
        [SOSDaapManager sendActionInfo:Map_POIdetail_anyocharging_Authorization_Disagree];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
