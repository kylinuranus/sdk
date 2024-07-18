//
//  MeTableHeaderView.m
//  Onstar
//
//  Created by Apple on 16/6/23.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "MeTableHeaderView.h"
#import "UIView+Utils.h"
#import "CustomerInfo.h"
#import "UIImageView+WebCache.h"
#import "MePersonalInfoViewController.h"
#import "AccountInfoUtil.h"
#import "SOSCheckRoleUtil.h"
#import "SOSAvatarManager.h"

@interface MeTableHeaderView()<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *photoBgView;
@property (weak, nonatomic) IBOutlet UIImageView *photoIcon;
@property (weak, nonatomic) IBOutlet UILabel *photoName;
@property (weak, nonatomic) IBOutlet UIImageView *rightArrowIcon;

@end

@implementation MeTableHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.photoBgView.layer.masksToBounds = YES;
    self.photoIcon.layer.masksToBounds = YES;
}

- (void)layoutSubviews		{
    [super layoutSubviews];
    [[SOSAvatarManager sharedInstance] fetchAvatar:^(UIImage * _Nullable avatar, BOOL isPlacholder) {
        _photoIcon.image = avatar;
    }];
    
    if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
        self.photoName.text = NSLocalizedString(@"settingNavigateTitle", nil);
        self.rightArrowIcon.hidden = NO;

    }else{
        if ([[LoginManage sharedInstance] isLoadingTokenReady]) {
            self.photoName.text = NSLocalizedString(@"settingNavigateTitle", nil);
            self.rightArrowIcon.hidden = NO;
        }else{
            self.photoName.text = NSLocalizedString(@"signIn_SignUp", nil);
            self.rightArrowIcon.hidden = YES;
        }
    }
}

#pragma mark - 个人中心
- (IBAction)pushPersonalInforVc:(id)sender	{
    [SOSDaapManager sendActionInfo:my_center];
    if ([[LoginManage sharedInstance] isLoadingTokenReady]) {
         if ([Util isToastLoadUserProfileFailure])return;
        //[[SOSReportService shareInstance] recordActionWithFunctionID:My_Personalinformation];
        MePersonalInfoViewController *vc = [[MePersonalInfoViewController alloc] init];
        vc.backRecordFunctionID = Psn_BBWC_insuranceco_back;
        [[Util currentNavigationController] pushViewController:vc animated:YES];
    } else if([LoginManage sharedInstance].loginState == LOGIN_STATE_LOADINGTOKEN){
        [Util showAlertWithTitle:nil message:@"正在努力为您连接中..." completeBlock:nil];
    }
    else {
//        AppDelegate_iPhone *delegate = (AppDelegate_iPhone*)[[UIApplication sharedApplication] delegate];
        [[LoginManage sharedInstance] presentLoginNavgationController:[SOS_APP_DELEGATE fetchRootViewController]];
    }
}

#pragma mark -下载头像
/*
跟安卓确认已不再调用
- (void)loadHeadPhotosData     {
    
    [AccountInfoUtil getHeadPhoto:^(NNHeadPhotoResponse *headPhoto) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [CustomerInfo sharedInstance].userBasicInfo.preference.avatarUrl = headPhoto.fullUrl;
            [self.photoIcon sd_setImageWithURL:[[CustomerInfo sharedInstance].userBasicInfo.preference.avatarUrl makeNSUrlFromString] placeholderImage:[UIImage imageNamed:kDefault_Account_Avatar]];
        });
    } Failed:^{
        
    }];
}
*/
@end
