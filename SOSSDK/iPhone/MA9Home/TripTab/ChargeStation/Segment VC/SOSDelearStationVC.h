//
//  SOSDelearStationVC.h
//  Onstar
//
//  Created by Genie Sun on 2017/7/6.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSDelearStationVC : UIViewController

@property (nonatomic, strong) SOSPOI *selectPOI;

@property (strong, nonatomic) NSMutableArray *stationList;

@property (weak, nonatomic) IBOutlet UITableView *dataTableView;

@end
