//
//  SOSOrderHistoryCell.m
//  Onstar
//
//  Created by Coir on 11/9/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSOrderHistoryCell.h"
#import "SOSDateFormatter.h"

@interface SOSOrderHistoryCell  ()     {
    
    __weak IBOutlet UILabel *orderNumLabel;
    __weak IBOutlet UILabel *orderTimeLabel;
    __weak IBOutlet UILabel *orderNameLabel;
    __weak IBOutlet UILabel *orderPriceLabel;
    __weak IBOutlet UILabel *validPeriodLabel;
    __weak IBOutlet UILabel *carCodeLabel;
    __weak IBOutlet UIView *whiteBGView;
    
}
@end

@implementation SOSOrderHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setOrder:(SOSOrderHistoryModel *)order   {
    _order = order;
    orderNumLabel.text = [NSString stringWithFormat:@"订单号: %@", order.buyOrderId];
    orderNameLabel.text = order.offeringName;
    carCodeLabel.text = [NSString stringWithFormat:@"车辆识别码: %@", order.vin];
    orderPriceLabel.text = [NSString stringWithFormat:@"¥%.2f", order.actualPrice];
    NSString *creatStr = @"--";
    if (order.createDate) {
        NSDate *creatDate = [NSDate dateWithTimeIntervalSince1970: order.createDate / 1000];
        creatStr = [[SOSDateFormatter sharedInstance] style1_stringFromDate:creatDate];
    }
    orderTimeLabel.text = creatStr;
    
    NSString *startString = @"--";
    if (order.packageStartDate) {
        NSDate *startDate = [NSDate dateWithTimeIntervalSince1970: order.packageStartDate / 1000];
        startString = [[SOSDateFormatter sharedInstance] style1_stringFromDate:startDate];
    }
    if (self.vcType == HistoryVCType_4GPackage) {
        NSString *durationUnit = [self transformTimeUnitWithTimeUnit:order.durationUnit];
        validPeriodLabel.text = [NSString stringWithFormat:@"有效期: %@%@", @(order.duration), durationUnit];
    }   else if (self.vcType == HistoryVCType_Package)  {
        NSString *endString = @"--";
        if (order.packageEndDate) {
            NSDate *endDate = [NSDate dateWithTimeIntervalSince1970: order.packageEndDate / 1000];
            endString = [[SOSDateFormatter sharedInstance] style1_stringFromDate:endDate];
        }
        validPeriodLabel.text = [NSString stringWithFormat:@"生效日期 %@ 至 %@", startString, endString];
    }
}

- (NSString *)transformTimeUnitWithTimeUnit:(NSString *)unitStr		{
    if ([unitStr.lowercaseString isEqualToString:@"years"])			return @"年";
    else if ([unitStr.lowercaseString isEqualToString:@"months"])   return @"月";
    else if ([unitStr.lowercaseString isEqualToString:@"days"])    	return @"天";
    return nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
