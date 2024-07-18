//
//  MePersonalInfoViewCell.h
//  Onstar
//
//  Created by Apple on 16/6/24.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MePersonalInfoViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftLabelWidthConstraint;

@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImgV;
@property (weak, nonatomic) IBOutlet UIButton *photoBtn;
@property (weak, nonatomic) IBOutlet UIView *bottomLineView;
//@property (nonatomic, weak) UIViewController *viewCtrl;


/**
 处理修改头像
 */
- (void)userImageClicked;
@end
