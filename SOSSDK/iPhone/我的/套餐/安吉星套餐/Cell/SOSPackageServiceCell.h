//
//  SOSPackageServiceCell.h
//  Onstar
//
//  Created by Coir on 5/9/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSPackageHeader.h"

@interface SOSPackageServiceCell : UITableViewCell

@property (nonatomic, copy) NSString *totalRemainingDay;

@property (nonatomic, assign) ServiceCellType cellType;

@end
