//
//  SOSTripPOIListCell.h
//  Onstar
//
//  Created by Coir on 2019/4/10.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSTripPOIListView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SOSTripPOIListCell : UITableViewCell

@property (nonatomic, strong) SOSPOI *poi;
@property (nonatomic, assign) SOSTripListTableType tableType;
@property (nonatomic, assign) SelectPointOperation operationType;

@end

NS_ASSUME_NONNULL_END
