//
//  SOSFVView.m
//  Onstar
//
//  Created by onstar on 2019/6/23.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSFVView.h"
@interface SOSFVView ()


@property (weak, nonatomic) IBOutlet UIImageView *fuelPercent;


@end

@implementation SOSFVView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)configView {
    NSInteger fuelLevel = [[CustomerInfo sharedInstance].fuelLavel floatValue];
    NSString *iconName = @"Icon／Other／icon_condition_oil_100-percent_375x150";
    if ([CustomerInfo sharedInstance].fuelLavel == nil) {
        
    }else if (fuelLevel <= 10 && fuelLevel >=0) {
        iconName = @"Icon／Other／icon_condition_oil_100-percent_375x150(10)";
    }else if (fuelLevel <= 20) {
        iconName = @"Icon／Other／icon_condition_oil_100-percent_375x150(9)";
    }else if (fuelLevel <= 30) {
        iconName = @"Icon／Other／icon_condition_oil_100-percent_375x150(8)";
    }else if (fuelLevel <= 40) {
        iconName = @"Icon／Other／icon_condition_oil_100-percent_375x150(7)";
    }else if (fuelLevel <= 50) {
        iconName = @"Icon／Other／icon_condition_oil_100-percent_375x150(6)";
    }else if (fuelLevel <= 60) {
        iconName = @"Icon／Other／icon_condition_oil_100-percent_375x150(5)";
    }else if (fuelLevel <= 70) {
        iconName = @"Icon／Other／icon_condition_oil_100-percent_375x150(4)";
    }else if (fuelLevel <= 80) {
        iconName = @"Icon／Other／icon_condition_oil_100-percent_375x150(3)";
    }else if (fuelLevel <= 90) {
        iconName = @"Icon／Other／icon_condition_oil_100-percent_375x150(2)";
    }else if (fuelLevel <= 100) {
        iconName = @"Icon／Other／icon_condition_oil_100-percent_375x150(1)";
    }
    self.fuelPercent.image = [UIImage imageNamed:iconName];
}

@end
