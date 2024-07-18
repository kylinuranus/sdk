//
//  SOSPersonalInformationTableViewCell.h
//  Onstar
//
//  Created by lizhipan on 2017/8/3.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSPersonInfoItem.h"
@interface SOSPersonalInformationTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *itemDesc;
@property (weak, nonatomic) IBOutlet UILabel *itemValue;
@property (weak, nonatomic) IBOutlet UILabel *necessaryFlag;
//@property (weak, nonatomic) UIView * currentRightView;

- (void)configCellData:(SOSPersonInfoItem *)item;
- (void)updateCellValue:(NSString *)itemValue;
@end
