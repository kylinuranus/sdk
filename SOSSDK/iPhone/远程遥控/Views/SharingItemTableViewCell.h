//
//  SharingItemTableViewCell.h
//  Onstar
//
//  Created by lizhipan on 2017/5/18.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSRemoteControlShareUser.h"
@interface SharingItemTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *shadowView; //阴影效果,由于阴影效果与圆角效果冲突，所以单独一个view出阴影效果
@property (weak, nonatomic) IBOutlet UIView *infomationView;//分享人信息部分
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *authStatusLabel;
@property (weak, nonatomic) IBOutlet UIButton *accessoryButton;
@property (weak, nonatomic) IBOutlet UIView *baseView;//cell显示部分
@property (weak, nonatomic) IBOutlet UILabel *authTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *roleFlag;
@property (weak, nonatomic) IBOutlet UISwitch *authSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (weak,nonatomic)  SOSRemoteControlShareUser * shareUser;

- (void)configCell:(SOSRemoteControlShareUser *)shareUser;
@end
