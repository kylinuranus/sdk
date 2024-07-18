//
//  SOSPackageServiceCell.m
//  Onstar
//
//  Created by Coir on 5/9/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSPackageServiceCell.h"

@interface SOSPackageServiceCell ()  {
    
    __weak IBOutlet UIImageView *BGImgView;
    __weak IBOutlet UILabel *currentServiceDaysCountLabel;
    
}

@end

@implementation SOSPackageServiceCell

+ (instancetype)new     {
    return [[self alloc] init];
}

- (instancetype)init    {
    self = [[NSBundle SOSBundle] loadNibNamed:@"SOSPackageServiceCell" owner:nil options:nil][0];
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setTotalRemainingDay:(NSString *)totalRemainingDay  {
    _totalRemainingDay = totalRemainingDay;
    dispatch_async(dispatch_get_main_queue(), ^{
        currentServiceDaysCountLabel.text = totalRemainingDay;
    });
}

@end
