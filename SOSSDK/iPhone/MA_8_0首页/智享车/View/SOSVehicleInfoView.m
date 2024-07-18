//
//  SOSVehicleInfoView.m
//  Onstar
//
//  Created by Genie Sun on 2017/7/25.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSVehicleInfoView.h"
#import "CustomerInfo.h"

@implementation SOSVehicleInfoView

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)refresh {
    LOGIN_STATE_TYPE status = [LoginManage sharedInstance].loginState;
    if (status == LOGIN_STATE_LOADINGTOKEN) {
        self.carSeriesLB.text = @"读取中...";
        self.yearLB.text = @"读取中...";
        self.vinLB.text = @"读取中...";
        self.logoImage.image = [UIImage imageNamed:@"brand_onstar"];
        self.exmImageView.hidden = YES;
    }else if([[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
        if ([SOSCheckRoleUtil isVisitor]) {
            [self showExampleData];
        }else {
            if ([Util vehicleIsCadillac]) {
                self.logoImage.image = [UIImage imageNamed:@"brand_cadillac_font"];
            } else if ([Util vehicleIsBuick]){
                self.logoImage.image = [UIImage imageNamed:@"brand_BUICK_font"];
            }else if ([Util vehicleIsChevrolet])
            {
                self.logoImage.image = [UIImage imageNamed:@"brand_chevrolet_font"];
            }
            
            self.carSeriesLB.text = [NSString stringWithFormat:@"%@ %@",[[CustomerInfo sharedInstance] currentVehicle].makeDesc, [[CustomerInfo sharedInstance] currentVehicle].modelDesc];
            self.yearLB.text = [NSString stringWithFormat:@"%@",[[CustomerInfo sharedInstance] currentVehicle].year];
            self.vinLB.text = [NSString stringWithFormat:@"%@",[Util recodesign:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin]];
            self.exmImageView.hidden = YES;
        }
    }else {
        if (status == LOGIN_STATE_NON) {
            [self showExampleData];
        }
    }
}

- (void)showExampleData {
    //未登录展示数据 访客
    self.carSeriesLB.text = @"******";
    self.yearLB.text = @"******";
    self.vinLB.text = @"LSGPB******4150";
    self.logoImage.image = [UIImage imageNamed:@"brand_onstar"];
    self.exmImageView.hidden = NO;
}

@end
