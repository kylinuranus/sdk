//
//  DepartTimeCell.h
//  Test
//
//  Created by Coir on 15/12/8.
//  Copyright © 2015年 lyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DepartTimeCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;

- (void)select;


@end
