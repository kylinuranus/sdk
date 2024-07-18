//
//  SOSScrollBaseTableView.h
//  Onstar
//
//  Created by lizhipan on 2017/7/24.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSScrollBaseTableHeaderView.h"
#import "SOSPageScrollParaCenter.h"
@interface SOSScrollBaseTableView : UITableView
@property (weak, nonatomic)    SOSScrollBaseTableHeaderView *topView;
@property (assign,nonatomic)BOOL isSelected;//是否当前显示
@property (assign,nonatomic)CGFloat headerTotalHeight;
@property (assign,nonatomic)BOOL enableStickHeaderTitle;
//@property (strong,nonatomic)SOSPageScrollParaCenter *scrollPara;
- (void)setTableHeaderSpace:(SOSPageScrollParaCenter *)para;
@end
