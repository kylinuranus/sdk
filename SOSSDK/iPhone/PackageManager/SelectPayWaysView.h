//
//  SelectPayWaysView.h
//  Onstar
//
//  Created by huyuming on 16/1/22.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SurePayView.h"
// 代理
@protocol SelectPayWaysDelegate <NSObject>

@optional
- (void)backFromSelectPayWays;
//- (void)userPayWay:(id)sender;
@end


@interface SelectPayWaysView : UIView
@property (nonatomic, weak) id<SelectPayWaysDelegate> payWaysDelegate;
//@property (weak, nonatomic) IBOutlet UIImageView *checkHookIV;
@property (weak, nonatomic) IBOutlet UITableView *channelTable;

- (IBAction)backAct:(id)sender;
//- (IBAction)userPayWay:(id)sender;

@end
