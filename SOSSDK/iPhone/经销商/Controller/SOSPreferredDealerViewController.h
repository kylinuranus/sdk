//
//  SOSPreferredDealerViewController.h
//  Onstar
//
//  Created by Genie Sun on 2017/8/2.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSPreferredTableViewCell.h"

@interface SOSPreferredDealerViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *table;

- (void)startLoadData:(SOSPOI *)currentLocationPOI;

@end
