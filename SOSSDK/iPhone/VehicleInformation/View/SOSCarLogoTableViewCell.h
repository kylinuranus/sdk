//
//  SOSCarLogoTableViewCell.h
//  Onstar
//
//  Created by Genie Sun on 2017/7/31.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SOSCarLogoTableViewCell;
@protocol SOSCarLogoTableViewCellDelegate <NSObject>

- (void)logoCell:(SOSCarLogoTableViewCell *)cell didPressWifiBtn:(id)sender;
- (void)logoCell:(SOSCarLogoTableViewCell *)cell didPressSwitchCarBtn:(id)sender;

@end

@interface SOSCarLogoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *infoLb;
@property (weak, nonatomic) IBOutlet UIImageView *carLogoImageView;
@property (weak, nonatomic) id<SOSCarLogoTableViewCellDelegate> delegate;

- (void)refreshData;
@end
