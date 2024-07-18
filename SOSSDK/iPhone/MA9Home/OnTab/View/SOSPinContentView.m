//
//  SOSPinContentView.m
//  Onstar
//
//  Created by onstar on 2018/12/26.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSPinContentView.h"
#import "SOSBiometricsManager.h"
#import "SOSPinPasswordView.h"

@interface SOSPinContentView ()
@property (weak, nonatomic) IBOutlet UIImageView *faceImageView;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *hornButton;
@property (weak, nonatomic) IBOutlet UIView *faceContentView;
@property (weak, nonatomic) IBOutlet UIView *pinContentView;
@property (weak, nonatomic) IBOutlet UIView *hornFlashContentView;
@property (weak, nonatomic) IBOutlet SOSPinPasswordView *pinPasswordInputView;
@property (weak, nonatomic) IBOutlet UILabel *errMessageLabel;

@end

@implementation SOSPinContentView

@synthesize flashSelected=_flashSelected,hornSelected=_hornSelected;

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    
    BOOL isSupportFaceId = [SOSBiometricsManager isSupportFaceId];
    if (isSupportFaceId) {
        self.faceImageView.image = [UIImage imageNamed:@"Touch ID-1"];
    }
    
}


#pragma mark setter
- (void)setPinType:(SOSPinType)pinType {
    _pinType = pinType;
    if (pinType == SOSPinTypeAuto) {
        BOOL supportBiometrics = [self supportBiometric];
        if (supportBiometrics) {
            self.pinContentView.fd_collapsed = YES;
        }else {
            self.faceContentView.fd_collapsed = YES;
        }
        self.faceContentView.fd_collapsed = YES;
        self.hornFlashContentView.fd_collapsed = YES;
    }else if (pinType == SOSPinTypePassword) {
        self.faceContentView.fd_collapsed = YES;
        self.faceContentView.fd_collapsed = YES;
        self.hornFlashContentView.fd_collapsed = YES;
    }else if (pinType == SOSPinTypeFace) {
        self.faceContentView.fd_collapsed = YES;
        self.pinContentView.fd_collapsed = YES;
        self.hornFlashContentView.fd_collapsed = YES;
    }else if (pinType == SOSPinTypeAutoHonkAndFlash) {
        BOOL supportBiometrics = [self supportBiometric];
        if (supportBiometrics) {
            self.pinContentView.fd_collapsed = YES;
        }else {
            self.faceContentView.fd_collapsed = YES;
        }
    }else if (pinType == SOSPinTypePasswordHonkAndFlash) {
        self.faceContentView.fd_collapsed = YES;
        self.faceContentView.fd_collapsed = YES;
    }else if (pinType == SOSPinTypeFaceHonkAndFlash) {
        self.pinContentView.fd_collapsed = YES;
    }
}

- (void)setHornSelected:(BOOL)hornSelected {
    _hornSelected = hornSelected;
    self.hornButton.selected = hornSelected;
}

- (void)setFlashSelected:(BOOL)flashSelected {
    _flashSelected = flashSelected;
    self.flashButton.selected = flashSelected;
}

- (void)setDidCompleteInputBlock:(void (^)(NSString * _Nonnull, SOSPinContentView * _Nonnull))didCompleteInputBlock {
    _didCompleteInputBlock = didCompleteInputBlock;
    self.pinPasswordInputView.didCompleteInputBlock = ^(NSString * _Nonnull pinCode) {
        !didCompleteInputBlock?:didCompleteInputBlock(pinCode, self);
    };
}

- (void)setErrorMsg:(NSString *)errorMsg {
    _errorMsg = errorMsg;
    if (errorMsg.isNotBlank) {
        self.errMessageLabel.text = errorMsg;
    }
}


#pragma mark getter
- (BOOL)hornSelected {
    return self.hornButton.selected;
}

- (BOOL)flashSelected {
    return self.flashButton.selected;
}

- (BOOL)supportBiometric {
    BOOL isSupportBiometrics = [SOSBiometricsManager isSupportBiometrics];
    BOOL isUserOpenBiometriesAuthentication = [SOSBiometricsManager isUserOpenBiometriesAuthentication];
    //验证指纹密码
    if (isSupportBiometrics && isUserOpenBiometriesAuthentication && [[LoginManage sharedInstance] pinCode]) {
        return YES;
    }
    return NO;
}

#pragma mark action
- (IBAction)forgetPassword:(id)sender {
    [self.viewController dismissViewControllerAnimated:YES completion:^{
        SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:MA8_3_FEEDBACK_URL];
        UINavigationController * homePresent =(UINavigationController *)[SOS_APP_DELEGATE fetchMainNavigationController].presentedViewController ;
        if (homePresent) {
            [homePresent pushViewController:vc animated:YES];
        }else{
            [(UINavigationController *)[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:vc animated:YES];
        }
    }];
}

- (IBAction)hornFlashButtonTap:(UIButton *)sender {
    if (sender.selected) {
        if (!(self.flashButton.selected && self.hornButton.selected)) {
            [Util showAlertWithTitle:nil message:NSLocalizedString(@"hornOrLightMustChooseOne", @"") completeBlock:nil];
            return;
        }
    }
    sender.selected = !sender.selected;
}


@end
