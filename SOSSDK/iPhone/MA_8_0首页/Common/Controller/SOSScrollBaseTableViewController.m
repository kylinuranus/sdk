//
//  SOSScrollBaseTableViewController.m
//  Onstar
//
//  Created by lizhipan on 2017/8/2.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSScrollBaseTableViewController.h"


@interface SOSScrollBaseTableViewController ()

@end

@implementation SOSScrollBaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"E8EBEF"];
    if (!_table) {
        _table = [[SOSScrollBaseTableView alloc] initWithFrame:self.view.frame style:_tableStyle];
        _table.delegate = _delegate;
        _table.dataSource = _delegate;
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_table];
        _table.backgroundColor = [UIColor clearColor];
        if (_scrollPara) {
            [_table setTableHeaderSpace:_scrollPara];
        }
        _table.estimatedRowHeight = 0;
        [_table mas_makeConstraints:^(MASConstraintMaker *make){
            make.edges.equalTo(self.view);
        }];

    }
    
    // Do any additional setup after loading the view from its nib.
}
- (void)initTableDelegate:(id<UITableViewDelegate,UITableViewDataSource>)delegate scrollPara:(SOSPageScrollParaCenter *)para style:(UITableViewStyle)style
{
    _delegate = delegate;
    _scrollPara = para;
    _tableStyle = style;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetY = scrollView.contentOffset.y;
    if (_scrollPara) {
        if (_scrollPara.disableStick) {
            self.table.topView.y = -offsetY;
            self.table.topView.stickHeaderState = HeaderStateFollow;
        }
        else
        {
            CGFloat placeHolderHeight = _scrollPara.headerTotalHeight - _scrollPara.stickHeight;
            if (offsetY >= 0 && offsetY < placeHolderHeight) {
                self.table.topView.y = -offsetY;
                self.table.topView.stickHeaderState = HeaderStateFree;
            }
            else if (offsetY >= placeHolderHeight) {
//                NSLog(@"HeaderStateStick");
                self.table.topView.y = - placeHolderHeight;
                self.table.topView.stickHeaderState = HeaderStateStick;
            }
            else if (offsetY <0) {
                self.table.topView.y =  - offsetY;
                self.table.topView.stickHeaderState = HeaderStateDropDownFree;
            }
        }
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
