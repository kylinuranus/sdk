//
//  SetDepartTimeTableView.h
//  Test
//
//  Created by Coir on 15/12/8.
//  Copyright © 2015年 lyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectionData : NSObject

@property (nonatomic, strong) NSString *selectHour;

@property (nonatomic, strong) NSString *selectMin;

@end

@interface SetDepartTimeTableView : UITableView

@property (nonatomic, strong) NSMutableArray *selectionDataArray;
@property (strong ,nonatomic) NSArray *scheduleTime;

@end
