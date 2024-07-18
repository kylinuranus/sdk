//
//  SOSDataPackageUnOpenedCell.m
//  Onstar
//
//  Created by Coir on 6/9/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSDataPackageUnOpenedCell.h"

@interface SOSDataPackageUnOpenedCell ()    {
    
    __weak IBOutlet UIImageView *BGImgView;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *numberLabel;
    __weak IBOutlet UILabel *dataUnitLabel;
}

@end

@implementation SOSDataPackageUnOpenedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    titleLabel.adjustsFontSizeToFitWidth=YES;
    titleLabel.minimumScaleFactor=0.5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setPackage:(NNPackagelistarray *)package    {
    _package = package;
    numberLabel.text = package.totalUsage ? : @"--";
    dataUnitLabel.text = package.totalUsageUnit ? : @"";
    titleLabel.text = package.packageName;

}

@end
