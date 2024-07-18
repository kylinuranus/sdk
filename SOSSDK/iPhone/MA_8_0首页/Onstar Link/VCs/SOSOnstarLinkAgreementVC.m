//
//  SOSOnstarLinkagreementVC.m
//  Onstar
//
//  Created by Coir on 2018/7/27.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSOnstarLinkAgreementVC.h"
#import "SOSOnstarLinkDataTool.h"
#import "SOSOnstarLinkSDKTool.h"
#import "SOSWebViewController.h"
#import "SOSOnstarLinkGuideVC.h"

@interface SOSOnstarLinkAgreementVC ()

@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
@property (weak, nonatomic) IBOutlet UIButton *disagreeButton;

@end

@implementation SOSOnstarLinkAgreementVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
}

/// 勾选已读协议
- (IBAction)readagreementButtonTapped:(UIButton *)readButton {
    readButton.selected = !readButton.isSelected;
    self.agreeButton.enabled = readButton.isSelected;
}

/// 查看协议
- (IBAction)showAgreementWebView:(id)sender 	{
    SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:self.agreement.url];
    vc.fd_prefersNavigationBarHidden = NO;
    vc.singlePageFlg = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

/// 不同意协议/点击背景
- (IBAction)disagreeButtonTapped:(id)sender {
    if (sender == self.disagreeButton)		[SOSDaapManager sendActionInfo:Onstarlink_agreement__reject];
    else									[SOSDaapManager sendActionInfo:Onstarlink_agreement__reject_blank];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

/// 同意协议
- (IBAction)agreeButtonTapped:(id)sender {
    [SOSDaapManager sendActionInfo:Onstarlink_agreement__agree];
    [SOSAgreement requestSignAgreements:@[self.agreement] success:^(NSDictionary *response) {
        [self enterGuideVC];
    } fail:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [self enterGuideVC];
    }];
}

- (void)enterGuideVC	{
    if ([SOSOnstarLinkDataTool sharedInstance].dataModel) {
        [SOSOnstarLinkSDKTool configOnstarLinkSDK];
        [SOSOnstarLinkSDKTool enterOnstarLink];
    }    else    {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            SOSOnstarLinkGuideVC *guideVC = [SOSOnstarLinkGuideVC new];
            guideVC.isFirstEnter = YES;
            [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:guideVC animated:YES];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
