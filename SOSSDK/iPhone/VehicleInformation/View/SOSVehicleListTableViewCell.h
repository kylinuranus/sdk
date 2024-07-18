//
//  SOSVehicleListTableViewCell.h
//  Onstar
//
//  Created by Genie Sun on 2017/8/1.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSVehicleListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *carNameLB;
@property (weak, nonatomic) IBOutlet UILabel *vinLB;
@property (weak, nonatomic) IBOutlet UIImageView *carImgView;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@end
