//
//  NavigteSearchHomeAndCompanyCell.h
//  Onstar
//
//  Created by Coir on 16/1/22.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSNavigateHeader.h"

@interface NavigteSearchHomeAndCompanyCell : UITableViewCell

@property (nonatomic, weak) UINavigationController *nav;
@property (nonatomic, assign) SelectPointOperation type;

- (void)configHomeAndCompanyInfo;

@end
