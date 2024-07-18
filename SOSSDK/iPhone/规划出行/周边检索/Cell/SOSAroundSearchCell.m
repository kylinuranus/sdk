//
//  SOSAroundSearchCell.m
//  Onstar
//
//  Created by Coir on 13/10/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSAroundSearchCell.h"

@interface SOSAroundSearchCell  ()  {
    
    __weak IBOutlet UIImageView *iconImage;
    __weak IBOutlet UILabel *titleLabel;
    
}

@end

@implementation SOSAroundSearchCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setImgName:(NSString *)imgName  {
    _imgName = imgName;
    iconImage.image = [UIImage imageNamed:imgName];
}

- (void)setTitleString:(NSString *)titleString  {
    _titleString = titleString;
    titleLabel.text = titleString;
}

@end
