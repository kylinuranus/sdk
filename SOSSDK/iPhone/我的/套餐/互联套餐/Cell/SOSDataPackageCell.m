//
//  SOSDataPackageCell.m
//  Onstar
//
//  Created by Coir on 6/9/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSDataPackageCell.h"

@interface SOSDataPackageCell ()    {
    __weak IBOutlet UIImageView *BGImgView;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *timeLabel;
    __weak IBOutlet UILabel *numberLabel;
    __weak IBOutlet UILabel *dataUnitLabel;
    
}

@end

@implementation SOSDataPackageCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setPackage:(NNPackagelistarray *)package    {
    _package = package;
//    NSDate *startDate = [NSDate dateWithString:package.startDateTime format:@"yyyy-MM-dd hh:mm:ss"];
//    NSDate *endDate = [NSDate dateWithString:package.expiredDateTime format:@"yyyy-MM-dd hh:mm:ss"];
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    formater.dateFormat = @"yyyy年MM月dd日";
//    NSString *startString = [formater stringFromDate:startDate];
//    NSString *endString = [formater stringFromDate:endDate];
    NSString *startString = [package.startDateTime substringToIndex:10];
    NSString *endString = [package.expiredDateTime substringToIndex:10];
    dispatch_async(dispatch_get_main_queue(), ^{
        titleLabel.text = package.packageName;
        timeLabel.text = [NSString stringWithFormat:@"开始时间 %@ 至 %@", startString, endString];
//        package.remainUsage stringByre
        numberLabel.text = package.remainUsage ? : @"--";
        dataUnitLabel.text = package.remainUsageUnit ? : @"";
    });
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
