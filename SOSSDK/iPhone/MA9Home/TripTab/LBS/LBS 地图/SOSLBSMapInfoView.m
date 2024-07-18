//
//  SOSLBSMapInfoView.m
//  Onstar
//
//  Created by Coir on 24/10/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSLBSMapInfoView.h"

@interface SOSLBSMapInfoView ()   {
    
    __weak IBOutlet UILabel *IMEILabel;
    __weak IBOutlet UILabel *powerLabl;
    __weak IBOutlet UILabel *powerUnitLabel;
    __weak IBOutlet UILabel *stayTimeLabel;
    __weak IBOutlet UIButton *lbsStateButton;
    __weak IBOutlet UILabel *updateTimeLabel;
    
}

@end


@implementation SOSLBSMapInfoView

- (void)awakeFromNib	{
    [super awakeFromNib];
}

- (void)setLbsPOI:(SOSLBSPOI *)lbsPOI  {
    _lbsPOI = lbsPOI;
    IMEILabel.text = lbsPOI.LBSIMEI;
    NSString *LBSPowerState = lbsPOI.LBSPowerState;
    if ([LBSPowerState containsString:@"电量:"]) {
        NSRange range1 = [LBSPowerState rangeOfString:@"电量:"];
        NSUInteger range_1_Last = range1.location + range1.length;
        NSRange range2 = [LBSPowerState rangeOfString:@"%"];
        NSString *powerStr = [LBSPowerState substringWithRange:NSMakeRange(range_1_Last, range2.location - range_1_Last)];
        powerLabl.text = powerStr;
        powerUnitLabel.hidden = NO;
    }   else    {
        powerLabl.text = @"--";
        powerUnitLabel.hidden = YES;
    }
    
    stayTimeLabel.text = lbsPOI.LBSStayTime;
    [lbsStateButton setTitle:lbsPOI.LBSState forState:UIControlStateNormal];
    [lbsStateButton setTitle:lbsPOI.LBSState forState:UIControlStateSelected];
    lbsStateButton.selected = !lbsPOI.LBSIsOnline.boolValue;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *updateDate = [formatter dateFromString:lbsPOI.LBSUpdateTime];
    
    NSDateFormatter *newFormatter = [[NSDateFormatter alloc] init];
    [newFormatter setDateFormat:@"HH:mm"];
    NSString * resultDateString = [newFormatter stringFromDate:updateDate];
    resultDateString = resultDateString.length ? resultDateString : @"--";
    updateTimeLabel.text = resultDateString;
}

@end
