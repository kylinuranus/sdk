//
//  SOSPlantripView.m
//  Onstar
//
//  Created by Genie Sun on 2017/8/8.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSPlantripView.h"
#import "SOSNS_ENUM.h"

@implementation SOSPlantripView

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)findMyVehicleSuccess {
    
    NSString *key = [NSString stringWithFormat:@"%@%@",[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin, K_CAR_LOCATION_STAR];
    NSString *poiStr = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    SOSPOI *poi = [SOSPOI mj_objectWithKeyValues:[poiStr mj_JSONObject]];
    self.titleLB.text = @"车辆位置";
    self.carLocationLb.text = poi.name;
    self.adressLB.text = poi.address;
    self.timeLB.text = [NSString stringWithFormat:@"更新于%@", poi.operationTime];
}


@end
