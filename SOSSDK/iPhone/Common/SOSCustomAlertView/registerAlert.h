//
//  registerAlert.h
//  SOSCustomAlertView
//
//  Created by Genie Sun on 2017/7/18.
//  Copyright © 2017年 Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface registerAlert : UIView
@property (weak, nonatomic) IBOutlet UILabel *infoLb;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;

@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (copy, nonatomic) NSString *functionID;
@property (weak, nonatomic) IBOutlet UIImageView *infoImage;
@end
