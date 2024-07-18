//
//  SOSBleOwnerShareListViewController.h
//  Onstar
//
//  Created by onstar on 2018/7/19.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSBleOwnerShareListViewController : UITableViewController

@property (nonatomic, strong) NSArray *sourceData;
@property (nonatomic, assign) BOOL fromOwnerShare;
@property (nonatomic, assign) BOOL isHistory;
@end
