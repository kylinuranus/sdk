//
//  SOSAvailablePackageCell.m
//  Onstar
//
//  Created by Coir on 8/9/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSAvailablePackageCell.h"
#import "UIView+Utils.h"

@interface SOSAvailablePackageCell ()   {
    
    __weak IBOutlet UIImageView *selectFlagImgView;
    __weak IBOutlet UILabel *nameLabel;
}

@end

@implementation SOSAvailablePackageCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setPackage:(PackageInfos *)package    {
    _package = package;
    nameLabel.text = package.packageName;
}

- (void)setCornerRidusWithIndexPath:(NSIndexPath *)indexPath AndPackageCount:(NSInteger)packageCount    {
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH - 20, 50);
    if (packageCount == 1) {
        self.layer.cornerRadius = 6;
        self.layer.masksToBounds = YES;
    }   else if (indexPath.row == packageCount - 1)     {
        [SOSUtilConfig setView:self RoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight withRadius:CGSizeMake(6, 6)];
    }   else    {
        [SOSUtilConfig setView:self RoundingCorners:UIRectCornerTopLeft |  UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight withRadius:CGSizeZero];
    }
}

- (void)setSelectFlag:(BOOL)selectFlag  {
    nameLabel.textColor = [UIColor colorWithHexString:selectFlag ? @"107FE0" : @"59708A"];
    selectFlagImgView.hidden = !selectFlag;
}

@end
