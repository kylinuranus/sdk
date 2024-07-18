//
//  SOSTripAroundDealerVC.m
//  Onstar
//
//  Created by Coir on 2019/5/5.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSTripAroundDealerVC.h"
#import "SOSOilFielterCell.h"
#import "SOSTripDealerCell.h"
#import "SOSDealerTool.h"

@interface SOSTripAroundDealerVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *currentBrandBGView;
@property (weak, nonatomic) IBOutlet UILabel *currentBrandLabel;
@property (weak, nonatomic) IBOutlet UIImageView *brandImgView;
@property (weak, nonatomic) IBOutlet UIImageView *brandBGFlagImgView;
@property (weak, nonatomic) IBOutlet UIButton *brandCoverButton;

@property (weak, nonatomic) IBOutlet UIView *brandDataBGView;
@property (weak, nonatomic) IBOutlet UITableView *brandTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *brandTableHeightGuide;

@property (nonatomic, assign) SOSDealerBrandType selectBrandType;

@end

@implementation SOSTripAroundDealerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectBrandType = [SOSDealerTool getBrandTypeForCurrentUser];
    [self configCurrentBrandView];
    self.dataTableView.tableFooterView = [UIView new];
    [self.dataTableView registerNib:[UINib nibWithNibName:@"SOSTripDealerCell" bundle:[NSBundle SOSBundle]] forCellReuseIdentifier:@"SOSTripDealerCell"];
    [self.brandTableView registerNib:[UINib nibWithNibName:@"SOSOilFielterCell" bundle:[NSBundle SOSBundle]] forCellReuseIdentifier:@"SOSOilFielterCell"];
}

- (void)setDealerArray:(NSArray<NNDealers *> *)dealerArray	{
    _dealerArray = [dealerArray copy];
    dispatch_async_on_main_queue(^{
        [self.dataTableView reloadSection:(self.recommendDealerArray.count != 0) withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}

- (void)setRecommendDealerArray:(NSArray<NNDealers *> *)recommendDealerArray	{
    _recommendDealerArray = recommendDealerArray.copy;
    dispatch_async_on_main_queue(^{
        [self.dataTableView reloadSection:0 withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}

#pragma mark - TableView Delegate & Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView	{
    if (tableView == self.dataTableView)	return 1 + (self.recommendDealerArray.count != 0);
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.dataTableView) 			{
        if (self.recommendDealerArray.count) {
            if (section)     return self.dealerArray.count;
            else            return self.recommendDealerArray.count;
        }	else	return self.dealerArray.count;
    }	else if (tableView == self.brandTableView)		return 4;
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section	{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section	{
    if (tableView == self.dataTableView)             {
        return 34.f;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section	{
    if (tableView == self.dataTableView)             {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 34)];
        UIView *flagView = [[UIView alloc] initWithFrame:CGRectMake(0, 9, 4, 16)];
        flagView.backgroundColor = [UIColor colorWithRed:104 / 255.0 green:150 / 255.0 blue:237 / 255.0 alpha:1.0];
        [headerView addSubview:flagView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 7, 30, 25)];
        [headerView addSubview:label];
        label.font = [UIFont systemFontOfSize:14.f];
        label.textColor = [UIColor colorWithRed:104 / 255.0 green:150 / 255.0 blue:237 / 255.0 alpha:1.0];
        label.textAlignment = NSTextAlignmentLeft;
        if (section || self.recommendDealerArray.count == 0) {
            label.text = @"附近";
            return headerView;
        }	else	{
            if (self.recommendDealerArray.count) {
                label.text = @"推荐";
                return headerView;
            }
        }
    }
    return nil;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (tableView == self.dataTableView) {
        SOSTripDealerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SOSTripDealerCell"];
        cell.cellType = (self.selectBrandType == SOSDealerBrandType_All) ? SOSTripCellType_Dealer_ALl : SOSTripCellType_Dealer;
        if (indexPath.section || self.recommendDealerArray.count == 0) 	cell.dealer = self.dealerArray[indexPath.row];
        else															cell.dealer = self.recommendDealerArray[indexPath.row];
        return cell;
    }	else if (tableView == self.brandTableView)	{
        SOSOilFielterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SOSOilFielterCell"];
        cell.cellType = SOSFielterCellType_Dealer_Brand;
        NSNumber *brandType = @[@(SOSDealerBrandType_All), @(SOSDealerBrandType_Buick), @(SOSDealerBrandType_Chevrolet), @(SOSDealerBrandType_Cadillac)][indexPath.row];
        cell.brandType = brandType.intValue;
        cell.selectedState = (brandType.intValue == self.selectBrandType);
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath		{
    // 在 SOSTripChargeVC 中处理
    if (tableView == self.dataTableView)	{
        [[NSNotificationCenter defaultCenter] postNotificationName:KDealerMapVCCellTappedNotify object:@(indexPath.row)];
    }	else if (tableView == self.brandTableView)	{
        SOSOilFielterCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        self.selectBrandType = cell.brandType;
        [self configCurrentBrandView];
        [tableView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:KAroundDealerChangeBrandNotify object:@(self.selectBrandType)];
        [self showBrandDataView:NO];
    }
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView    {
    [[NSNotificationCenter defaultCenter] postNotificationName:SOS_Map_ScrollView_DidEndDecelerating object:scrollView];
}

#pragma mark - Button Action
- (IBAction)changeBrandButtonTapped {
    if (self.brandCoverButton.isSelected) {
        [self showBrandDataView:NO];
    }	else	{
        [self showBrandDataView:YES];
    }
    self.brandCoverButton.selected = !self.brandCoverButton.isSelected;
    
}

- (IBAction)hideBrandBGView {
    [self showBrandDataView:NO];
}

// 显示品牌选择 View
- (void)showBrandDataView:(BOOL)show	{
    if (show) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KMapVCEnterFullscreenNotify object:@(YES)];
        self.brandDataBGView.backgroundColor = [UIColor colorWithWhite:0 alpha:.1];
        self.brandDataBGView.hidden = NO;
        self.brandTableHeightGuide.constant = 220;
        [UIView animateWithDuration:.3 animations:^{
            [self.brandDataBGView layoutIfNeeded];
            self.brandDataBGView.backgroundColor = [UIColor colorWithWhite:0 alpha:.45];
        }];
    }	else	{
        self.brandTableHeightGuide.constant = 0;
        [UIView animateWithDuration:.3 animations:^{
            [self.brandDataBGView layoutIfNeeded];
            self.brandDataBGView.backgroundColor = [UIColor colorWithWhite:0 alpha:.1];
        }	completion:^(BOOL finished) {
            self.brandDataBGView.hidden = YES;
        }];
    }
}

- (void)configCurrentBrandView	{
    self.currentBrandLabel.text = [SOSOilFielterCell getBrandNameWithBrandType:self.selectBrandType];
    NSString *brandImgName = [SOSOilFielterCell getBrandImageNameWithBrandType:self.selectBrandType];
    self.brandImgView.image = [UIImage imageNamed:brandImgName];
    self.brandImgView.hidden = brandImgName.length == 0;
}

@end
