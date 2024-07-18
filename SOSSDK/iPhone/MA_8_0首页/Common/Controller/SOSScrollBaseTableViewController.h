//
//  SOSScrollBaseTableViewController.h
//  Onstar
//
//  Created by lizhipan on 2017/8/2.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSScrollBaseTableView.h"
//包含一个SOSScrollBaseTableView的单个controller
@interface SOSScrollBaseTableViewController : UIViewController
@property (strong, nonatomic) SOSScrollBaseTableView *table;
@property (strong, nonatomic)  SOSPageScrollParaCenter *scrollPara;
@property (weak ,nonatomic)id<UITableViewDelegate,UITableViewDataSource> delegate;
@property (assign ,nonatomic)UITableViewStyle tableStyle;
- (void)initTableDelegate:(id<UITableViewDelegate,UITableViewDataSource>)delegate scrollPara:(SOSPageScrollParaCenter *)para style:(UITableViewStyle)style;
@end
