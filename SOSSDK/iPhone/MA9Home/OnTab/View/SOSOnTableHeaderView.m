//
//  SOSOnTableHeaderView.m
//  Onstar
//
//  Created by onstar on 2018/12/20.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSOnTableHeaderView.h"
#import "SOSAvatarManager.h"
#import "SOSCardUtil.h"
#import "UIImage+SOSSkin.h"

@interface SOSOnTableHeaderView ()
@property (weak, nonatomic) IBOutlet UIView *noCarView;//没车显示这个  未登录或访客
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *touchButton;

@property (weak, nonatomic) IBOutlet UIView *driverStatusView;
@property (weak, nonatomic) IBOutlet UIImageView *driverStatusImageView;
@property (weak, nonatomic) IBOutlet UILabel *driverStatusLabel;

@property (weak, nonatomic) IBOutlet UIImageView *carImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;


@property (weak, nonatomic) IBOutlet UIView *carView;   //有车的

@end

@implementation SOSOnTableHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.bgImageView setImage:[UIImage sossk_imageNamed:@"on_top_bg"]];
    [self addObserver];
    if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
        [[SOSAvatarManager sharedInstance] fetchVehicleAvatar:SOSVehicleAvatarTypeOther avatarBlock:^(UIImage * _Nullable avatar, BOOL isPlacholder) {
            self.carImageView.image = avatar;
        }];
    }
}

- (void)addObserver {
    __weak __typeof(self) weakSelf = self;
    [RACObserve([CustomerInfo sharedInstance], carSharingFlag) subscribeNext:^(id  _Nullable x) {
        dispatch_async_on_main_queue(^{
            if ([CustomerInfo sharedInstance].carSharingFlag) {
                //已经授权
                weakSelf.driverStatusLabel.text = @"车主已授权";
                weakSelf.driverStatusImageView.image = [UIImage imageNamed:@"lab_power_have_260x16"];
            }else {
                //未被授权
                weakSelf.driverStatusLabel.text = @"车主未授权,请联系车主";
                weakSelf.driverStatusImageView.image = [UIImage imageNamed:@"lab_power_no_260x16"];
            }
        });
    }];
    
    
    [RACObserve([LoginManage sharedInstance] , loginState) subscribeNext:^(NSNumber *state) {
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //退出登录or登录成功
            if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
                //登陆成功
                if (![SOSCheckRoleUtil isVisitor]) {
                    //车图片
                    if (([LoginManage sharedInstance].loginState == LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS || [LoginManage sharedInstance].loginState == LOGIN_STATE_NON)) {
                        [[SOSAvatarManager sharedInstance] fetchVehicleAvatar:SOSVehicleAvatarTypeOther avatarBlock:^(UIImage * _Nullable avatar, BOOL isPlacholder) {
                            weakSelf.carImageView.image = avatar;
                        }];
                    }
                    
                }
                
    //            weakSelf.helpButton.hidden = NO;
                if ([SOSCheckRoleUtil isOwner]) {
                    weakSelf.carView.hidden = NO;
                    weakSelf.noCarView.hidden = YES;
                    weakSelf.driverStatusView.hidden = YES;
                }else if ([SOSCheckRoleUtil isDriverOrProxy]){
                    weakSelf.carView.hidden = NO;
                    weakSelf.noCarView.hidden = YES;
                    weakSelf.driverStatusView.hidden = NO;
    //                if ([CustomerInfo sharedInstance].carSharingFlag) {
    //                    //已经授权
    //                    weakSelf.driverStatusLabel.text = @"车主已授权";
    //                    weakSelf.driverStatusImageView.image = [UIImage imageNamed:@"lab_power_have_260x16"];
    //                }else {
    //                    //未被授权
    //                    weakSelf.driverStatusLabel.text = @"车主未授权,请联系车主";
    //                    weakSelf.driverStatusImageView.image = [UIImage imageNamed:@"lab_power_no_260x16"];
    //                }
                }else if ([SOSCheckRoleUtil isVisitor]) {
                    weakSelf.carView.hidden = YES;
                    weakSelf.noCarView.hidden = NO;
                    weakSelf.touchButton.hidden = NO;
                    weakSelf.titleLabel.text = @"您还不是车主";
                    //绑定车辆
                    [weakSelf.touchButton setTitle:@"绑定车辆" forState:UIControlStateNormal];
                    [weakSelf.touchButton setBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
                        NSLog(@"绑定车辆");
                        [SOSCardUtil routerToUpgradeSubscriber];
                    }];
                }
            }else if ([[LoginManage sharedInstance] isInLoadingMainInterface] || [[LoginManage sharedInstance] isLoadingMainInterfaceFail]) {
                //登录中 失败
                weakSelf.carView.hidden = YES;
                weakSelf.noCarView.hidden = NO;
                weakSelf.touchButton.hidden = YES;
    //            weakSelf.helpButton.hidden = YES;
                weakSelf.titleLabel.text = @"欢迎来到安吉星";
            }else {
                //按未登录处理
                weakSelf.titleLabel.text = @"欢迎来到安吉星";
    //            weakSelf.helpButton.hidden = YES;
                weakSelf.carView.hidden = YES;
                weakSelf.noCarView.hidden = NO;
                weakSelf.touchButton.hidden = NO;
                [weakSelf.touchButton setTitle:@"立即登录" forState:UIControlStateNormal];
                [weakSelf.touchButton setBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
                    NSLog(@"立即登录");
                    [SOSUtil presentLoginFromViewController:((UINavigationController *)[SOS_APP_DELEGATE fetchMainNavigationController]).topViewController toViewController:nil];
                }];
            }
            
        });
       
        
    }];
    
}

- (IBAction)roadHelp:(id)sender {
    !self.roadHelpBlock?:self.roadHelpBlock();
}



@end
