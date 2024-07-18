//
//  TBTOrODDSettingVC.h
//  Onstar
//
//  Created by huyuming on 16/2/17.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TBTOrODDSettingVC : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UITableView *table;

@property(copy, nonatomic) void (^saveSuccess)(void);

@end
