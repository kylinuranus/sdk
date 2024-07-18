//
//  SOSServiceSettingViewController.h
//  Onstar
//
//  Created by lizhipan on 2017/8/2.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSScrollBaseTableViewController.h"

@interface SOSServiceSettingViewController : SOSScrollBaseTableViewController<UITableViewDelegate,UITableViewDataSource>

//h5调用原生 返回需要刷新的时候调用
@property (nonatomic, copy) void (^refreshH5Block)(void);
@property (nonatomic, assign) BOOL goBack;    //驾驶行为界面未打开车辆服务时再开启后需要返回驾驶行为界面

@property (nonatomic, copy) void (^bleSwitchBlock)(BOOL swithStatusOn);
- (void)logoutClick;
@end
