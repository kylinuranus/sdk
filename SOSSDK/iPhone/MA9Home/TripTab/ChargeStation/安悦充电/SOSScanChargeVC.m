//
//  SOSScanChargeVC.m
//  Onstar
//
//  Created by Coir on 2018/10/30.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <AVFoundation/AVCaptureDevice.h>
#import "SOSScanChargeVC.h"
#import "SOSQRManager.h"

@interface SOSScanChargeVC ()

@property (weak, nonatomic) IBOutlet UIView *scanView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineImgViewTopGuide;

@property (assign, nonatomic) AVAuthorizationStatus authStatus;

@end

@implementation SOSScanChargeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = NO;
    self.title = @"扫一扫";
    self.authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
}

- (void)viewDidAppear:(BOOL)animated	{
    [super viewDidAppear:animated];
    [self addScanningAnimation];
    [self startScanning];
    // 原本为未授权
    if (self.authStatus == AVAuthorizationStatusNotDetermined) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusAuthorized) {
            [SOSDaapManager sendActionInfo:JoyLife_anyocharging_Scan_Authorization_Yes];
        }	else 	{
            [SOSDaapManager sendActionInfo:JoyLife_anyocharging_Scan_Authorization_No];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated		{
    [super viewDidDisappear:animated];
    [[SOSQRManager shareInstance] stopScanner];
}

- (void)addScanningAnimation {
    // 1.修改控件的约束
    self.lineImgViewTopGuide.constant = 190;
    // 2.执行动画
    [UIView animateWithDuration:2.0 animations:^{
        [UIView setAnimationRepeatCount:UID_MAX];
        [self.view layoutIfNeeded];
    }];
}

- (void)addObserver		{
    NSString *mediaType = AVMediaTypeVideo;//读取媒体类型
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];//读取设备授权状态
    if(authStatus == AVAuthorizationStatusNotDetermined)	{
        
    }
}

- (void)startScanning {
    if ([[SOSQRManager shareInstance] checkAuthStatus]) {
        
        [[SOSQRManager shareInstance] startScanningQRCodeWithInView:self.view scanView:self.scanView resultCallback:^(NSArray *results) {
            NSLog(@"%@", results);
            if (results.count) {
                [[SOSQRManager shareInstance] stopScanner];
                NSString *deviceNum = results[0];
                if ([deviceNum isKindOfClass:[NSString class]] && deviceNum.length) {
                    dispatch_async_on_main_queue(^{
                        
                        !self.scanCompleteBlock?:self.scanCompleteBlock(deviceNum);
                       
                    });
                }
            }
        }];
    }
}

- (IBAction)openLightButtonTapped:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.isSelected)			{
        [SOSDaapManager sendActionInfo:JoyLife_anyocharging_Scan_TurnOnFlashlight];
        [[SOSQRManager shareInstance] openFlash];
    }	else						{
        [SOSDaapManager sendActionInfo:JoyLife_anyocharging_Scan_TurnOffFlashlight];
        [[SOSQRManager shareInstance] closeFlash];
    }
}

@end
