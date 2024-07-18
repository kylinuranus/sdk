//
//  SOSOperationHistoryViewController.h
//  Onstar
//
//  Created by Genie Sun on 2017/7/31.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ErrorPageVC.h"

@interface SOSOperationHistoryViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic) BOOL isFailPage;  //是否失败

@end
