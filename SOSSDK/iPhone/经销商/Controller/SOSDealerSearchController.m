//
//  SOSDealerSearchController.m
//  Onstar
//
//  Created by TaoLiang on 2018/1/25.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSDealerSearchController.h"
#import "SOSSelectDealerVC.h"
#import "UITableView+Category.h"
#import "SOSPreferredTableViewCell.h"

@interface SOSDealerSearchController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) SOSSelectDealerVC *parent;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray <NNDealers *>*results;
@property (strong, nonatomic) UILabel *noResultsLabel;

@end

@implementation SOSDealerSearchController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [SOSUtil onstarLightGray];
    _results = @[].mutableCopy;
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 140.f;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.tableFooterView = [UIView new];
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [_tableView registerNib:[SOSPreferredTableViewCell class]];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self.view);
    }];
    
    _noResultsLabel = [UILabel new];
    _noResultsLabel.font = [UIFont systemFontOfSize:14];
    _noResultsLabel.text = @"未找到经销商";
    [_noResultsLabel setTextColor:[UIColor colorWithHexString:@"59708A"]];
    [self.view addSubview:_noResultsLabel];
    [self.view sendSubviewToBack:_noResultsLabel];
    [_noResultsLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(self.view);
        make.top.mas_equalTo(100);
    }];
}

- (void)setSearchKey:(NSString *)searchKey {
    _searchKey = searchKey;
    [_results removeAllObjects];
    [_dealers enumerateObjectsUsingBlock:^(NNDealers * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.dealerName containsString:searchKey]) {
            [_results addObject:obj];
            //只显示十条
            if (_results.count == 10) {
                *stop = YES;
            }
        }
    }];
    [_tableView reloadData];
}

#pragma mark - table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SOSPreferredTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SOS_GetClassString(SOSPreferredTableViewCell)];
    cell.switchToSearchStyle = YES;
    NNDealers *dealer = _results[indexPath.row];
    [cell initCellWithDealer:dealer withPath:indexPath selectIndexPath:nil highlightString:_searchKey];
    return cell;
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedDealer = _results[indexPath.row];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    _parent = (SOSSelectDealerVC *)parent;
    [super willMoveToParentViewController:parent];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_searchKey.length <= 0) {
        [_parent finishSearching];
    }
}

@end
