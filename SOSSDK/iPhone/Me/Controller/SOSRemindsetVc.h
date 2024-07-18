//
//  SOSRemindsetVc.h
//  Onstar
//
//  Created by Genie Sun on 2017/3/13.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
UIKIT_EXTERN  NSString * const kSOSServiceOptState;
UIKIT_EXTERN  NSString * const kSOSServiceSmartDriveOptState;//驾驶行为评价
UIKIT_EXTERN  NSString * const kSOSServiceFuelDriveOptState;
UIKIT_EXTERN  NSString * const kSOSServiceEnergyDriveOptState;

@interface SOSRemindsetVc : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *table;
@end
