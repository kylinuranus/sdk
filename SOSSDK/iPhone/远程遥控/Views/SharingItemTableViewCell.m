//
//  SharingItemTableViewCell.m
//  Onstar
//
//  Created by lizhipan on 2017/5/18.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SharingItemTableViewCell.h"
#import "NSString+JWT.h"
#import "RemoteControlAuthSettingViewController.h" //和controller耦合高
#import "UIImageView+WebCache.h"
#import "PushNotificationManager.h"
@implementation SharingItemTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    //阴影效果
    _shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    _shadowView.layer.shadowOffset = CGSizeMake(1, 1);
    _shadowView.layer.shadowOpacity = 0.1;
    _shadowView.layer.shadowRadius = 4.0;
    _shadowView.layer.cornerRadius = 4.0;
    _shadowView.clipsToBounds = NO; 
    
    _avatarImageView.layer.masksToBounds = YES;
//    //渐变色
//    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
//    gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:49.0/225.0f green:172.0/225.0f blue:235.0/225.0f alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:124.0/225.0f green:214.0/225.0f blue:245.0/225.0f alpha:1.0].CGColor];
//    //    gradientLayer.locations = @[ @0.5, @1.0];
//    gradientLayer.startPoint = CGPointMake(0, 0);
//    gradientLayer.endPoint = CGPointMake(1.0, 0);
//    gradientLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, _infomationView.frame.size.height+2.0);//超出部分会被clipstobounds，所以width取SCREEN_WIDTH也没关系
//    [_infomationView.layer insertSublayer:gradientLayer atIndex:0];
    
    [_authSwitch addTarget:self action:@selector(authRemoteControl:) forControlEvents:UIControlEventValueChanged];
    
    UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(authSetting)];
    [_infomationView addGestureRecognizer:tapGesturRecognizer];

}
- (void)configCell:(SOSRemoteControlShareUser *)shareUser
{
    _shareUser = shareUser;
    
    [_authStatusLabel setText:shareUser.authorizeStatus?@"已授权":@"未授权"];
    //是否是邮箱，是按邮箱屏蔽规则
    [_phoneLabel setText:[Util isValidateEmail:shareUser.context]?[shareUser.context stringEmailInterceptionHide]:[shareUser.context stringInterceptionHide]];
    
    [_roleFlag setText:[SOSUtil roleZHcn:shareUser.roleType] ];
    [_authSwitch setOn:shareUser.authorizeStatus];
    
    NSString * endDate =[[PushNotificationManager getZhcnSingledatefomatter] stringFromDate:[[PushNotificationManager getYmdHmsDateFomatter] dateFromString:shareUser.endDate]];
    
    [_authTimeLabel setText: [NSString stringWithFormat:@"有效期至%@",endDate]];
    [self extremeAuthTime];
    [_accessoryButton setHidden:!shareUser.authorizeStatus];
    [_infomationView setUserInteractionEnabled:shareUser.authorizeStatus];
    if (shareUser.faceUrl.length>0) {
       [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:shareUser.faceUrl] placeholderImage:[UIImage imageNamed:kDefault_Account_Avatar]];
    }
}

- (void)authRemoteControl:(id)sender
{
    UISwitch * authSw = (UISwitch *)sender;
    if (authSw.on) {
        //进入设置进行授权
        [self authSetting];
    }
    else
    {
        //关闭授权
        [Util showLoadingView];
        //        [_shareUser setAuthorizeStatus:NO];
        RemoteControlSharePostUser * postUser =[RemoteControlSharePostUser mj_objectWithKeyValues:[_shareUser mj_keyValues]];
        if (_shareUser.authorizeStatus) {
            [postUser setAuthorizeStatus:@"0"];//如果是授权状态，需要设置为关闭授权状态
        }
        [OthersUtil setCarsharingAuthorzation:postUser SuccessHandler:^(NSString * responseStr,NNError *res) {
            //更新成功
            [Util hideLoadView];
            [_shareUser setAuthorizeStatus:NO];//更改状态
            dispatch_async(dispatch_get_main_queue(), ^{
                [_accessoryButton setHidden:YES];
                [_infomationView setUserInteractionEnabled:NO];
                [_authStatusLabel setText:@"未授权"];
                [self extremeAuthTime];
            });
        } failureHandler:^(NSString *responseStr, NNError *error) {
            [Util hideLoadView];
            dispatch_async(dispatch_get_main_queue(), ^{
                authSw.on = !authSw.on;
            });
            [Util toastWithMessage:@"设置失败，请稍后再试"];
        }];
    }
}
//无限时或未授权有效期显示
- (void)extremeAuthTime
{
    if (_shareUser.authorizeStatus && _shareUser.limit == 0) {
        //无限时
        [_authTimeLabel setText: [NSString stringWithFormat:@"无限时"]];
    }
    if (!_shareUser.authorizeStatus) {
        [_authTimeLabel setText:nil];
    }
}
- (void)authSetting
{
    [SOSDaapManager sendActionInfo:Remotecontrol_carshare_authorise];
    RemoteControlAuthSettingViewController * authSetting = [[RemoteControlAuthSettingViewController alloc] initWithNibName:@"RemoteControlAuthSettingViewController" bundle:nil];
    [authSetting configAuthUser:_shareUser];
    [[Util currentNavigationController] pushViewController:authSetting animated:YES];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
