//
//  ChargeStationListCell.m
//  Onstar
//
//  Created by Coir on 16/6/15.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "ChargeStationListCell.h"

@implementation ChargeStationListCell   {
    
    __weak IBOutlet UILabel *stationNameLabel;
    __weak IBOutlet UILabel *stationTypeLabel;
    __weak IBOutlet UILabel *supplierLabel;
    __weak IBOutlet UILabel *freeTypeLabel;
    
    __weak IBOutlet UILabel *lowLb;
    __weak IBOutlet UILabel *fastLb;
    
    __weak IBOutlet UILabel *idleLowLb;
    __weak IBOutlet UILabel *idleFastLb;
    
    __weak IBOutlet UILabel *addressInfoLabel;
    __weak IBOutlet UILabel *distanceInfoLabel;
    
    __weak IBOutlet UILabel *unitLb;
    __weak IBOutlet NSLayoutConstraint *stationLabelRightGuide;
}

@synthesize station;

- (void)configSelf  {
    [self reSetFrame:NO];
}

- (void)reSetFrame:(BOOL)isDealerStation  {
    stationNameLabel.text = station.stationName;
    addressInfoLabel.text = station.address;
    if (station.stationType.length) {
        stationTypeLabel.hidden = NO;
        stationLabelRightGuide.constant = 0;
        stationTypeLabel.text = [self fixTitle:station.stationType];
    }   else    {
        stationLabelRightGuide.constant = 0;
        stationTypeLabel.hidden = YES;
        stationTypeLabel.text = @"";
    }
    
    if (station.supplier.length) {
        supplierLabel.hidden = NO;
        supplierLabel.text = [self fixTitle:station.supplier];
        if (isDealerStation) {
            if ([Util vehicleIsCadillac]){
                supplierLabel.backgroundColor = [UIColor colorWithHexString:@"EABF7B"];
                supplierLabel.layer.borderColor = [UIColor colorWithHexString:@"EABF7B"].CGColor;
                supplierLabel.layer.borderWidth = 0;
                
                supplierLabel.text = @"  凯迪拉克  ";
                supplierLabel.textColor = [UIColor colorWithHexString:@"ffffff"];
                supplierLabel.layer.masksToBounds = YES;
            }	else if 	([Util vehicleIsBuick])		{
                supplierLabel.backgroundColor = [UIColor whiteColor];
                supplierLabel.text = @"  别克  ";
//                supplierLabel.textColor = [UIColor colorWithHexString:@"ffffff"];
                supplierLabel.textColor = [UIColor colorWithHexString:@"304D8F"];

                supplierLabel.layer.borderColor = [UIColor colorWithHexString:@"304D8F"].CGColor;
                supplierLabel.layer.borderWidth = 1;
                supplierLabel.layer.masksToBounds = YES;
            }
        }
        
    }   else    {
        supplierLabel.hidden = YES;
        supplierLabel.text = @"";
    }
    NSString *prefix = @"";
    //附近充电站 UI修改版本8.2
    if ([station.feeType isEqualToString:@"免费"]) {
        freeTypeLabel.textColor = [UIColor colorWithHexString:@"F18F19"];
        freeTypeLabel.layer.borderColor = [UIColor colorWithHexString:@"F18F19"].CGColor;
    }	else {
        freeTypeLabel.textColor = UIColorHex(0xFB6B62);
        freeTypeLabel.layer.borderColor = UIColorHex(0xFB6B62).CGColor;
    }
    
    if ([station.stationType isEqualToString:@"公共"]) {
        stationTypeLabel.textColor = [UIColor colorWithHexString:@"F18F19"];
        stationTypeLabel.layer.borderColor = [UIColor colorWithHexString:@"F18F19"].CGColor;
    }else {
        stationTypeLabel.textColor = UIColorHex(0xFDBC0C);
        stationTypeLabel.layer.borderColor = UIColorHex(0xFDBC0C).CGColor;
    }
    
    idleFastLb.text = [NSString stringWithFormat:@"%d",station.idleQuickCharge.intValue];
    idleLowLb.text = [NSString stringWithFormat:@"%d",station.idleSlowCharge.intValue];
    
    idleFastLb.textColor = [UIColor colorWithHexString:station.idleQuickCharge.intValue ? @"6CCA46" : @"A4A4A4"];
    idleLowLb.textColor = [UIColor colorWithHexString:station.idleSlowCharge.intValue ? @"6CCA46" : @"A4A4A4"];
    fastLb.textColor = [UIColor colorWithHexString:@"A4A4A4"];
    lowLb.textColor = [UIColor colorWithHexString:@"A4A4A4"];
    prefix = @"/";
    
    
    if (station.feeType.length) {
        freeTypeLabel.hidden = NO;
        if ([station.feeType isEqualToString:@"未知"]) {
            freeTypeLabel.hidden = YES;
            freeTypeLabel.text = @"";
        }else{
            freeTypeLabel.text = [self fixTitle:station.feeType];
        }
    }   else    {
        freeTypeLabel.hidden = YES;
        freeTypeLabel.text = @"";
    }
        
    NSRegularExpression*letterRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]"options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger letterMatchCount = [letterRegularExpression numberOfMatchesInString:[station distance] options:NSMatchingReportProgress range:NSMakeRange(0, [station distance].length)];
    
    unitLb.text = (letterMatchCount == 1) ? @"米" : @"公里";
    distanceInfoLabel.text = [station.distance componentsSeparatedByString:(letterMatchCount == 1) ? @"m" : @"km"][0];

    fastLb.text = [NSString stringWithFormat:@"%@%d", prefix, station.quickCharge.intValue];
    lowLb.text = [NSString stringWithFormat:@"%@%d", prefix, station.slowCharge.intValue];
}

- (NSString *)fixTitle:(NSString *)title    {
    return [NSString stringWithFormat:@"  %@  ", title];
}

@end
