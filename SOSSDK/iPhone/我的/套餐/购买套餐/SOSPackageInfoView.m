//
//  SOSPackageInfoView.m
//  Onstar
//
//  Created by Coir on 8/9/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSPackageInfoView.h"

@interface SOSPackageInfoView ()    {
    
    __weak IBOutlet UILabel *packageNameLabel;
    __weak IBOutlet UILabel *packageDateLabel;
    __weak IBOutlet UILabel *packagePriceLabel;
    __weak IBOutlet UILabel *originPriceTieleLabel;
    __weak IBOutlet UILabel *originPriceLabel;
    __weak IBOutlet UILabel *cutoffPriceTitleLabel;
    __weak IBOutlet UILabel *cutOffPriceLabel;
    
}

@end

@implementation SOSPackageInfoView

+ (instancetype)new     {
    return [[SOSPackageInfoView alloc] init];
}

- (instancetype)init    {
    self = [[NSBundle SOSBundle] loadNibNamed:@"SOSPackageInfoView" owner:nil options:nil][0];
    return self;
}

- (void)awakeFromNib    {
    [super awakeFromNib];
    [self configSelf];
}

- (void)configSelf  {
    if (!originPriceLabel.text.length)   return;
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:originPriceLabel.text];
    [attrStr addAttributes:@{NSFontAttributeName:originPriceLabel.font,
                             NSStrikethroughStyleAttributeName:@(NSUnderlineStyleThick|NSUnderlinePatternSolid),
                             NSStrikethroughColorAttributeName:[UIColor whiteColor]}
                     range:NSMakeRange(0, attrStr.length)];
    
    originPriceLabel.attributedText = attrStr;
}

- (void)setPackage:(PackageInfos *)package    {
    _package = package;
    packageNameLabel.text = package.packageName;
    
    if ([package.packageType isEqualToString:@"DATA"]) {
        packageDateLabel.text = [NSString stringWithFormat:@"有效期: %@天", package.duration];
    }   else    {
        NSString *start = package.startDate;
        NSLog(@"%@",start);
        NSDate *startDate = [NSDate dateWithString:start format:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *endDate = [NSDate dateWithString:package.endDate format:@"yyyy-MM-dd HH:mm:ss"];
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        formater.dateFormat = @"yyyy年MM月dd日";
        NSString *startString = [formater stringFromDate:startDate];
        NSString *endString = [formater stringFromDate:endDate];
        //packageDateLabel.text = [NSString stringWithFormat:@"生效日期 %@ 至 %@", startString, endString];
        packageDateLabel.text = [NSString stringWithFormat:@"生效日期 %@ 至 %@", package.startDate, package.endDate];

    }
    
    //packagePriceLabel.text = [NSString stringWithFormat:@"%.2f", package.actualPrice.floatValue];
    packagePriceLabel.text = [NSString stringWithFormat:@"%.2f", package.finalPrice.floatValue];

    if (package.discountAmount.floatValue != 0) {
        originPriceLabel.text = [NSString stringWithFormat:@"¥ %.2f", package.packagePrice.floatValue];
        cutOffPriceLabel.text = [NSString stringWithFormat:@"¥ %.2f", package.discountAmount.floatValue];
        originPriceLabel.hidden = NO;
        cutOffPriceLabel.hidden = NO;
        originPriceTieleLabel.hidden = NO;
        cutoffPriceTitleLabel.hidden = NO;
    }	else	{
        originPriceLabel.hidden = YES;
        cutOffPriceLabel.hidden = YES;
        originPriceTieleLabel.hidden = YES;
        cutoffPriceTitleLabel.hidden = YES;
    }
    [self configSelf];
}

@end
