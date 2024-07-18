//
//  SOSAYChargeInstrustionVC.m
//  Onstar
//
//  Created by Coir on 2018/11/3.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSAYChargeInstrustionVC.h"

@interface SOSAYChargeInstrustionVC ()

@end

@implementation SOSAYChargeInstrustionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = NO;
    self.title = @"车辆充电使用说明";
    self.backDaapFunctionID = JoyLife_anyocharging_OperatingManual_Back;
}

@end
