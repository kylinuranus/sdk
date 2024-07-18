//
//  MeSystemSettingsViewCell.h
//  Onstar
//
//  Created by Apple on 16/7/11.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SystemSettingCellData.h"

extern NSString * const MeSystemSettings_CellID;

@interface MeSystemSettingsViewCell : UITableViewCell

@property (nonatomic, retain) SystemSettingCellData *cellData;
@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;

@end
