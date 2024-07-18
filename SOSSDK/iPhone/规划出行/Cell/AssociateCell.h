//
//  AssociateCell.h
//  Onstar
//
//  Created by Coir on 16/2/16.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSMapHeader.h"

@interface AssociateCell : UITableViewCell

@property (nonatomic, strong) AMapTip *tip;
@property (nonatomic, copy) NSString *inputStr;
@property (nonatomic, assign) SelectPointOperation operationType;

- (void)configSelf;

@end
