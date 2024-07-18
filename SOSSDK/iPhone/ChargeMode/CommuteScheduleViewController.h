//
//  CommuteScheduleViewController.h
//  Onstar
//
//  Created by Vicky on 15/12/2.
//  Copyright © 2015年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SetDepartTimeTableView.h"

@interface CommuteScheduleViewController : SOSBaseViewController
@property (strong, nonatomic)  SetDepartTimeTableView *timeTable;
@property (strong ,nonatomic) NSArray *scheduleTime;

- (void)buttonSaveTapped;

@end
