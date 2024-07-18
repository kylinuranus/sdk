//
//  SOSAdditionalServiceCell.m
//  Onstar
//
//  Created by Coir on 6/9/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSAdditionalServiceCell.h"

@interface SOSAdditionalServiceCell ()  {
    
    __weak IBOutlet UIImageView *BGImgView;
    __weak IBOutlet UILabel *nameLabel;
    __weak IBOutlet UILabel *timeLabel;
}

@end

@implementation SOSAdditionalServiceCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setPackage:(NNPackagelistarray *)package    {
    _package = package;
    NSDate *startDate = [NSDate dateWithString:package.startDate format:@"yyyy-MM-dd hh:mm:ss"];
    NSDate *endDate = [NSDate dateWithString:package.endDate format:@"yyyy-MM-dd hh:mm:ss"];
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    formater.dateFormat = @"yyyy年MM月dd日";
    NSString *startString = [formater stringFromDate:startDate];
    NSString *endString = [formater stringFromDate:endDate];
    nameLabel.text = package.packageName;
    timeLabel.text = [NSString stringWithFormat:@"服务开始时间 %@\n服务结束时间 %@", startString, endString];
}

- (void)setCellType:(ServiceCellType)cellType   {
    if (_cellType == cellType)  return;
    _cellType = cellType;
    
    if (cellType == ServiceCellType_Company_UnOpened) {
        BGImgView.image = [UIImage imageNamed:@"套餐_Group_Gray"];
    }   else if (cellType == ServiceCellType_Company)   {
        BGImgView.image = [UIImage imageNamed:@"套餐_package_current"];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
