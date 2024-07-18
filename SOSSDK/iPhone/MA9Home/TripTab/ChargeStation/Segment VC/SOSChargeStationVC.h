//
//  SOSChargeStationVC.h
//  Onstar
//
//  Created by Genie Sun on 2017/9/14.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSBaseSegmentViewController.h"

@class ChargeStationOBJ;

@interface SOSChargeStationVC : SOSBaseSegmentViewController

@property (nonatomic, strong) SOSPOI *selectPOI;

@property (nonatomic, copy) NSArray<ChargeStationOBJ *> * stationArray;

- (void)configSelf;

@end
