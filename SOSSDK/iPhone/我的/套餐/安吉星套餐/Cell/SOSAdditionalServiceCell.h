//
//  SOSAdditionalServiceCell.h
//  Onstar
//
//  Created by Coir on 6/9/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSPackageHeader.h"

static const int i = 0;

@interface SOSAdditionalServiceCell : UITableViewCell

@property (nonatomic, copy) NNPackagelistarray *package;

/** Cell 类型 */
@property (nonatomic, assign) ServiceCellType cellType;

@end
