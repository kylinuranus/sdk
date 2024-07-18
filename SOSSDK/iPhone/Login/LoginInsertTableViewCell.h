//
//  LoginInsertTableViewCell.h
//  Onstar
//
//  Created by Genie Sun on 16/2/23.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginInsertTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *cellSepLine;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *originLine_x;
@property (weak, nonatomic) IBOutlet UITextField *oldUserNameTf;
@property (weak, nonatomic) IBOutlet UIButton *targetClick;

@end
