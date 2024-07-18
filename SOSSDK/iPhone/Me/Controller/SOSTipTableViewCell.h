//
//  SOSTipTableViewCell.h
//  Onstar
//
//  Created by Genie Sun on 2017/3/14.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SOSTipTableViewCell;
@protocol SOSTipTableViewCellDelegate <NSObject>
- (void)tapActionToSet:(SOSTipTableViewCell*)cell;
@end

@interface SOSTipTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *tap;
@property (weak, nonatomic) IBOutlet UILabel *detailLb;
@property (weak, nonatomic) IBOutlet UILabel *setNo;
@property(nonatomic, weak) id <SOSTipTableViewCellDelegate> delegate;
@end
