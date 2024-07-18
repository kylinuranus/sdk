//
//  RemoteControlAuthSettingViewController.h
//  Onstar
//
//  Created by lizhipan on 2017/5/19.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSRemoteControlShareUser.h"

@interface RemoteControlAuthSettingViewController : SOSBaseViewController
@property (weak, nonatomic) IBOutlet UIPickerView *timePicker;
@property (weak, nonatomic) IBOutlet UIButton *authTimeSelectButton;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UIImageView *authUserAvatar;
@property (weak,nonatomic)  SOSRemoteControlShareUser * shareUser;
- (void)configAuthUser:(SOSRemoteControlShareUser *)authUser;
@end
