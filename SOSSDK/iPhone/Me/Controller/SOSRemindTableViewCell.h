//
//  SOSRemindTableViewCell.h
//  Onstar
//
//  Created by Genie Sun on 2017/3/14.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^switchBtnState)(UISwitch *switchBtn);

@interface SOSRemindTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleName;
@property (weak, nonatomic) IBOutlet UISwitch *switchbtn;
@property(nonatomic, strong) switchBtnState switchValue;
@property (weak, nonatomic) IBOutlet UIView *lineView;

- (void)changeSwitchValue:(switchBtnState) changeState;
- (void)createSwitchStatus:(BOOL)flg;
@end
