//
//  SOSBleReceiveAlertViewController.m
//  Onstar
//
//  Created by onstar on 2018/7/25.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSBleReceiveAlertViewController.h"
#import "SOSBleNetwork.h"
#import "LoadingView.h"
#import "SOSCardUtil.h"
#import "SOSEditUserInfoViewController.h"
#import "SOSOnstarLinkBindPhoneVC.h"
#import "SOSCustomAlertView.h"
#import "SOSBleUtil.h"
#import <Toast/Toast.h>

@interface SOSBleReceiveAlertViewController ()
@property (weak, nonatomic) IBOutlet UILabel *vinLabel;
@property (weak, nonatomic) IBOutlet UIView *bleProtocolContentView;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;
@property (nonatomic, strong) NSArray<SOSAgreement *> *agreements;
@end

@implementation SOSBleReceiveAlertViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    self.vinLabel.text = [NSString stringWithFormat:@"VIN SGM******%@",self.hide];
    //检测协议
    [self bleProtocolRequest];
    
}

- (void)bleProtocolRequest {
//    [[LoadingView sharedInstance] startIn:self.view];
//    //1.协议
//    [SOSBleNetwork loadBLENeedConfirmTypes:@[agreementName(ONSTAR_BLE)] success:^(NSArray<SOSAgreement *> *agreements) {
//        if (agreements.count == 0) {
            //隐藏协议
            self.bleProtocolContentView.fd_collapsed = YES;
//        }else {
//            //显示协议
//            self.bleProtocolContentView.fd_collapsed = NO;
//            _bottomButton.enabled = NO;
//            _bottomButton.backgroundColor = [SOSUtil onstarButtonDisableColor];
//            self.agreements = agreements;
//        }
//        [Util hideLoadView];
//    } failed:^(NSString *responseStr, NSError *error) {
//        [Util toastWithMessage:@"获取协议内容错误"];
//        [Util hideLoadView];
//        [self dismiss:[NSObject new]];
//    }];
}


/**
 同意BLE协议 然后接受授权
 */
- (void)acceptBleProtocolRequest {
    [[LoadingView sharedInstance] startIn:self.view];
//    if (self.agreements) {
//        [SOSBleNetwork requestSignAgreements:self.agreements
//                                     success:^(NSDictionary *response) {
//                                         self.agreements = nil;
//                                         self.bleProtocolContentView.fd_collapsed = YES;
//                                         [self acceptAuthortionRequest];
//                                     } fail:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
//                                         [Util toastWithMessage:responseStr];
//                                         [Util hideLoadView];
//                                     }];
//    }else {
        [self acceptAuthortionRequest];
//    }
    
}


/**
 接受授权
 */
- (void)acceptAuthortionRequest {
    if (self.isPer) {
        [SOSDaapManager sendActionInfo:ReceivedCarsharing_PermCarsharing_Receive];
    }else {
        [SOSDaapManager sendActionInfo:ReceivedCarsharing_TempCarsharing_Receive];
    }
    //数据请求
    if (self.uuid.isNotBlank) {
        NSDictionary *dic = @{@"idpUserId":[CustomerInfo sharedInstance].userBasicInfo.idpUserId?:@"",
                              @"uuid":self.uuid,
                              @"authorizationStatus":@"ACCEPTED"
                              };
        
        [SOSBleNetwork bleUserAuthorizationsParams:dic method:@"PUT" success:^(SOSAuthorInfo *authorInfo) {
            if ([authorInfo.statusCode isEqualToString:@"0000"]) {
                [self dismiss:nil];
            }else {
                //xx
//                [Util toastWithMessage:authorInfo.message];
                CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                style.imageSize = CGSizeMake(20, 20);
                [self.view makeToast:authorInfo.message
                             duration:2.0
                             position:CSToastPositionCenter
                                title:nil
                                image:[UIImage imageNamed:@"icon_nav_incorrect_idle"]
                                style:style
                           completion:nil];
                
                
            }
            [Util hideLoadView];
        } Failed:^(NSString *responseStr, NSError *error) {
            [Util hideLoadView];
        }];
    }else {
        [Util hideLoadView];
    }
}

- (IBAction)acceptAuthorButtonTap:(id)sender {
    //补充手机号
    if (![CustomerInfo sharedInstance].userBasicInfo.idmUser.mobilePhoneNumber.isNotBlank) {
        //弹出alert
        [self dismissViewControllerAnimated:NO completion:nil];
        [self showPhoneAlertWithUrl:self.orginUrl];
        return;
    }
    
    //同意协议 然后接受授权
    [self acceptBleProtocolRequest];
    
}

- (void)showPhoneAlertWithUrl:(NSString *)url {
    SOSCustomAlertView *alert = [[SOSCustomAlertView alloc] initWithTitle:@"绑定手机号" detailText:@"您暂未绑定手机号\n使用蓝牙钥匙功能需要绑定手机号" cancelButtonTitle:@"取消" otherButtonTitles:@[@"立即绑定"]];
    alert.pageModel = SOSAlertViewModelContent;
    alert.buttonMode = SOSAlertButtonModelHorizontal;
    alert.backgroundModel = SOSAlertBackGroundModelStreak;
    alert.buttonClickHandle = ^(NSInteger clickIndex) {
        if (clickIndex == 1) {
//            [self bindPhone];
            SOSOnstarLinkBindPhoneVC *vc = [SOSOnstarLinkBindPhoneVC new];
            vc.pageType = SOSBLEBindPhone;
            vc.operationSuccessBlock = ^(NSString *mobilePhoneNum) {
                [CustomerInfo sharedInstance].userBasicInfo.idmUser.mobilePhoneNumber = mobilePhoneNum;
                [[SOS_APP_DELEGATE fetchMainNavigationController] popViewControllerAnimated:YES];
                [SOSBleUtil showReceiveAlertControllerWithUrl:url];
            };
            
            [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:vc animated:YES];
            
            
        }
    };
    [alert show];
    
}


- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:NO completion:^{
       //跳转至收到的共享页面
        if (!sender) {
            [[SOS_APP_DELEGATE fetchMainNavigationController] popToRootViewControllerAnimated:NO];
            [SOSCardUtil routerToUserReceiveBlePage];
            if (self.isPer) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"SOSBleSwitchTable" object:nil];
                });
            }
        }
    }];
}

//跳转至协议H5
- (IBAction)bleProtocolButtonTaped:(id)sender {
//    [SOSCardUtil showBleAgreement];
}

//按钮状态改变
- (IBAction)acceptBleProtocolButtonTaped:(UIButton *)sender {
    sender.selected = !sender.selected;
    _bottomButton.enabled = sender.selected;
    _bottomButton.backgroundColor = sender.selected?[SOSUtil onstarButtonEnableColor]:[SOSUtil onstarButtonDisableColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
