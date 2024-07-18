//
//  ChargeStationListCell.h
//  Onstar
//
//  Created by Coir on 16/6/15.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChargeStationOBJ.h"

@interface ChargeStationListCell : UITableViewCell

@property (nonatomic, strong) ChargeStationOBJ *station;

- (void)configSelf;
- (void)reSetFrame:(BOOL)flag;
@end
