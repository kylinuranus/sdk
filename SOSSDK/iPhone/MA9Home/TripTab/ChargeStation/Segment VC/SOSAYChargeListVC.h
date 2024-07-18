//
//  SOSAYChargeListVC.h
//  Onstar
//
//  Created by Coir on 16/6/12.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSAYChargeListVC : UIViewController

@property (nonatomic, strong) SOSPOI *selectPOI;

@property (weak, nonatomic) IBOutlet UIButton *delearBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableY;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *delearWidth;

@property (weak, nonatomic) IBOutlet UITableView *dataTableView;

@property (copy, nonatomic) NSArray *stationList;

- (void)handleListDataHasNoMoreData:(BOOL)noMoreData;

@end
