//
//  ActiveHistoryDescription.h
//  Onstar
//
//  Created by Joshua on 7/1/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActiveHistoryDescription : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *vinLabel;
@property (nonatomic, weak) IBOutlet UILabel *startDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *endDateLabel;

@end
