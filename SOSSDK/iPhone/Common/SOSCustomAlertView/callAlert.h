//
//  callAlert.h
//  SOSCustomAlertView
//
//  Created by Genie Sun on 2017/7/18.
//  Copyright © 2017年 Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface callAlert : UIView
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (copy, nonatomic)  NSString *functionID;
@property (weak, nonatomic) IBOutlet UIButton *callOnstarButton;
@end
