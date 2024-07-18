//
//  TLMrORestrictionCell.h
//  Onstar
//
//  Created by TaoLiang on 2017/11/21.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLMroRestriction.h"

@interface TLMrORestrictionCell : UITableViewCell
@property (strong, nonatomic) TLMroRestrictions *restrictions;
@property (copy, nonatomic) void(^searchBtnClicked)(NSString *city, NSString *time);
@end
