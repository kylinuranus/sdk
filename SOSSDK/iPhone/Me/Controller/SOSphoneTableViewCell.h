//
//  SOSphoneTableViewCell.h
//  Onstar
//
//  Created by Genie Sun on 2017/3/23.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSphoneTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userIcon;
@property (weak, nonatomic) IBOutlet UITextField *usertf;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *usericonheight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *usericonwidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconright;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userTfLeft;

@end
