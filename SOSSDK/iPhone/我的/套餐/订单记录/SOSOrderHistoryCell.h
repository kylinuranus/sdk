//
//  SOSOrderHistoryCell.h
//  Onstar
//
//  Created by Coir on 11/9/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSPackageHeader.h"

@interface SOSOrderHistoryCell : UITableViewCell

@property (nonatomic, assign) HistoryVCType vcType;
@property (nonatomic, strong) SOSOrderHistoryModel *order;

@end
