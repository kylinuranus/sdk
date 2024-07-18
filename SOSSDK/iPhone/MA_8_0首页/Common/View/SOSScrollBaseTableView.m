//
//  SOSScrollBaseTableView.m
//  Onstar
//
//  Created by lizhipan on 2017/7/24.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSScrollBaseTableView.h"
@implementation SOSScrollBaseTableView

- (void)awakeFromNib
{
    [super awakeFromNib];
}

//占位的tableHeader
- (void)setTableHeaderSpace:(SOSPageScrollParaCenter *)para
{
    self.scrollIndicatorInsets = UIEdgeInsetsMake(para.headerTotalHeight, 0, 0, 0);
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, para.headerTotalHeight+para.headerSeprateHeight)];
    self.tableHeaderView = tableHeaderView;
    if (para.navigationBarHeight) {
        self.height = self.height - para.navigationBarHeight;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
