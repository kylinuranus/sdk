//
//  SOSOilStationFilterView.m
//  Onstar
//
//  Created by Coir on 2019/8/24.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSOilStationFilterView.h"
#import "SOSOilFielterCell.h"

@interface SOSOilStationFilterView () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *currentSortLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sortFlagImgView;
@property (weak, nonatomic) IBOutlet UIButton *sortButton;

@property (weak, nonatomic) IBOutlet UILabel *oilNumLabel;
@property (weak, nonatomic) IBOutlet UIImageView *oilNumFlagImgView;
@property (weak, nonatomic) IBOutlet UIButton *oilNumButton;

@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UIImageView *brandFlagImgView;
@property (weak, nonatomic) IBOutlet UIButton *brandButton;

@property (weak, nonatomic) IBOutlet UITableView *rulesTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ruleTableViewHeightGuide;
@property (weak, nonatomic) IBOutlet UIButton *coverButton;

/// 排序方式 distance（距离）,price(优惠加油价格)默认距离排序
@property (assign, nonatomic) int selectedSortRuleIndex;
/// 油号（90#、92#、95#、98#、101#）默认92#
@property (assign, nonatomic) int selectedOilNumIndex;
/// 油站类型（1 中石油，2 中石化，3 壳牌，4 其他, 不传值为不限）
@property (assign, nonatomic) int selectedBrandIndex;

///// 当前选中项的 TableView 数据源
//@property (copy, nonatomic) NSArray *tableValueArray;
/// 油号数组
@property (copy, nonatomic) NSArray <NSString *>*oilNameArray;
/// 当前选中项的 TableView 显示名
@property (copy, nonatomic) NSArray <NSString *>*tableDisplayArray;
/// 当前选中项的 Index
@property (assign, nonatomic) int selectedIndex;

@end

@implementation SOSOilStationFilterView

- (void)awakeFromNib	{
    [super awakeFromNib];
    [self buildData];
}

- (void)buildData	{
    self.selectedSortRuleIndex = 0;
    self.selectedBrandIndex = 0;
    [self.rulesTableView registerNib:[UINib nibWithNibName:@"SOSOilFielterCell" bundle:[NSBundle SOSBundle]] forCellReuseIdentifier:@"SOSOilFielterCell"];
    self.rulesTableView.tableFooterView = [UIView new];
}

- (void)setOilInfoArray:(NSArray<SOSOilInfoObj *> *)oilInfoArray	{
    _oilInfoArray = [oilInfoArray copy];
    NSMutableArray *oilNameArray = [NSMutableArray array];
    for (int i = 0; i < oilInfoArray.count; i++) {
        SOSOilInfoObj *oilInfo = oilInfoArray[i];
        if (oilInfo.defaultShow) 	{
            self.selectedOilNumIndex = i;
            self.oilNumLabel.text = oilInfo.oilName;
        }
        [oilNameArray addObject:oilInfo.oilName];
    }
    self.oilNameArray = oilNameArray;
}

- (IBAction)selectButtonTapped:(UIButton *)sender {
    // 屏蔽异常
    if (sender.tag < 100)	return;
    self.selectedIndex = (int)sender.tag - 100;
    // 当前已选中 Button 再次点击
    if (sender.isSelected == YES) {
        [self dismissTableView];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KMapVCEnterFullscreenNotify object:@(YES)];
    
    NSMutableArray *buttonArr = [NSMutableArray arrayWithObjects:_sortButton, _oilNumButton, _brandButton, nil];
    [buttonArr removeObject:sender];
    sender.selected = YES;
    switch (sender.tag) {
        case 100:
//            self.selectedIndex = self.selectedSortRuleIndex;
//            self.tableValueArray = @[@"distance", @"price"];
            self.tableDisplayArray = @[@"距离最近", @"价格最低"];
            break;
        case 101:
//            self.selectedIndex = self.selectedOilNumIndex;
//            self.tableValueArray = @[@"distance", @"price"];
            self.tableDisplayArray = self.oilNameArray;
            break;
        case 102:
//            self.selectedIndex = self.selectedBrandIndex;
//            self.tableValueArray = @[@"", @"1", @"2", @"3", @"4"];
            self.tableDisplayArray = @[@"不限品牌", @"中石油", @"中石化", @"壳牌", @"其他"];
            break;
            
        default:
            break;
    }
    
    // 获取点击的 Button 对应的 FlagImgView
    NSMutableArray *flagImgViewArr = [NSMutableArray arrayWithObjects:_sortFlagImgView, _oilNumFlagImgView, _brandFlagImgView, nil];
    UIImageView *selectImgView = flagImgViewArr[sender.tag - 100];
    
    
    // 获取当前处于展开状态的 FlagImgView
    UIImageView *deSelectImgView = nil;
    for (UIButton *button in buttonArr) {
        if (button.isSelected == YES) {
            deSelectImgView = flagImgViewArr[button.tag - 100];
            button.selected = NO;
            break;
        }
    }
    // 展开自身大小
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewStateChangedWithState:)]) {
        [self.delegate viewStateChangedWithState:YES];
    }
    float tableHeight = 38 * self.tableDisplayArray.count - 1;
    self.ruleTableViewHeightGuide.constant = (tableHeight > self.height) ? self.height : tableHeight;
    [self.rulesTableView reloadData];
    self.coverButton.hidden = NO;
    self.coverButton.backgroundColor = [UIColor colorWithWhite:0.45 alpha:.1];
    [UIView animateWithDuration:.3 animations:^{
        selectImgView.transform =  CGAffineTransformMakeRotation(M_PI);
        if (deSelectImgView) deSelectImgView.transform = CGAffineTransformMakeRotation(0);
    } completion:^(BOOL finished) {
        [self layoutIfNeeded];
        NSNumber *index = @[@(_selectedSortRuleIndex),@( _selectedOilNumIndex), @(_selectedBrandIndex)][self.selectedIndex];
        [self.rulesTableView scrollToRow:index.intValue inSection:0 atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }];
}

- (IBAction)dismissTableView {
    if (self.rulesTableView.height == 0)	return;
    UIButton *selectbutton = @[_sortButton, _oilNumButton, _brandButton][_selectedIndex];
    UIImageView *selectImgView = @[_sortFlagImgView, _oilNumFlagImgView, _brandFlagImgView][_selectedIndex];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(filterChangedWithSortRule:oilName:AndGasType:)]) {
        [self.delegate filterChangedWithSortRule:@[@"distance", @"price"][_selectedSortRuleIndex] oilName:self.oilNameArray[_selectedOilNumIndex] AndGasType:@[@"", @"1", @"2", @"3", @"4"][_selectedBrandIndex]];
    }
    selectbutton.selected = NO;
    self.ruleTableViewHeightGuide.constant = 0;
    [UIView animateWithDuration:.3 animations:^{
        self.coverButton.backgroundColor = [UIColor colorWithWhite:0 alpha:.1];
        selectImgView.transform =  CGAffineTransformMakeRotation(0);
        [self layoutIfNeeded];
    }	completion:^(BOOL finished) {
        self.coverButton.hidden = YES;
        [self.rulesTableView reloadData];
        if (self.delegate && [self.delegate respondsToSelector:@selector(viewStateChangedWithState:)]) {
            [self.delegate viewStateChangedWithState:NO];
        }
    }];
}

#pragma mark - TableView Delegate & dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section	{
    return self.tableDisplayArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath	{
    SOSOilFielterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SOSOilFielterCell"];
    cell.cellType = SOSFielterCellType_Oil_Station;
    cell.titleStr = self.tableDisplayArray[indexPath.row];
    NSNumber *index = @[@(_selectedSortRuleIndex),@( _selectedOilNumIndex), @(_selectedBrandIndex)][self.selectedIndex];
    if (indexPath.row == index.intValue) {
        cell.selectedState = YES;
    }	else	cell.selectedState = NO;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath		{
    SOSOilFielterCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectedState = YES;
    NSString *selectText = self.tableDisplayArray[indexPath.row];
    switch (self.selectedIndex) {
        // 筛选排序方式
        case 0:
            self.selectedSortRuleIndex = (int)indexPath.row;
            self.currentSortLabel.text = selectText;
//            if ([selectText containsString:@"距离最近"]) {
//                [SOSDaapManager sendActionInfo:Life_WisdomOil_Entrance_select90Oil];
//            }    else
            if ([selectText containsString:@"价格最低"]) {
                [SOSDaapManager sendActionInfo:Life_WisdomOil_Entrance_selectPrice];
            }
            break;
        // 筛选油号
        case 1:
            self.selectedOilNumIndex = (int)indexPath.row;
            self.oilNumLabel.text = selectText;
            if ([selectText containsString:@"90"]) {
                [SOSDaapManager sendActionInfo:Life_WisdomOil_Entrance_select90Oil];
            }	else if ([selectText containsString:@"95"]) {
                    [SOSDaapManager sendActionInfo:Life_WisdomOil_Entrance_select95Oil];
            }    else if ([selectText containsString:@"98"]) {
                [SOSDaapManager sendActionInfo:Life_WisdomOil_Entrance_select98Oil];
            }    else if ([selectText containsString:@"101"]) {
                [SOSDaapManager sendActionInfo:Life_WisdomOil_Entrance_select101Oil];
            }
            break;
        // 筛选品牌
        case 2:
            self.selectedBrandIndex = (int)indexPath.row;
            self.brandLabel.text = self.tableDisplayArray[indexPath.row];
            if ([selectText containsString:@"中石油"]) {
                [SOSDaapManager sendActionInfo:Life_WisdomOil_Entrance_selectBrand1];
            }    else if ([selectText containsString:@"中石化"]) {
                [SOSDaapManager sendActionInfo:Life_WisdomOil_Entrance_selectBrand2];
            }    else if ([selectText containsString:@"壳牌"]) {
                [SOSDaapManager sendActionInfo:Life_WisdomOil_Entrance_selectBrand3];
            }    else if ([selectText containsString:@"其它"]) {
                [SOSDaapManager sendActionInfo:Life_WisdomOil_Entrance_selectBrand4];
            }
            break;
        default:
            break;
    }
    [self dismissTableView];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath		{
    SOSOilFielterCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectedState = NO;
}

@end
