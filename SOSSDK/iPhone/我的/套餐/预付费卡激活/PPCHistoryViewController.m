//
//  PPCHistoryViewController.m
//  Onstar
//
//  Created by Joshua on 7/1/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import "PPCHistoryViewController.h"
#import "ActiveHistoryDescription.h"
#import "LoadingView.h"
#import "PurchaseModel.h"
#import "OrderRecordHeader.h"
#import "ActiveHistoryDescription.h"
#import "ActiveHisotryDataDescription.h"
#import "FunctionCellForDealer.h"
#import "PPCActivateViewController.h"

#define HEADER_HEIGHT       (ISIPAD?144:88)
#define DESCRIPTION_HEIGHT  (ISIPAD?193:92)
#define HISTORY_PAGE_SIZE   5
#define START_INDEX         0

@interface PPCHistoryViewController ()
@end

@implementation PPCHistoryViewController

- (void)viewDidLoad     {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = NO;
    self.title = @"历史记录";
    __weak __typeof(self) weakSelf = self;
    UIButton *leftButton = [[UIButton alloc] init];
    [leftButton setImage:[UIImage imageNamed:@"common_Nav_Back"] forState:UIControlStateNormal];
    [leftButton sizeToFit];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    [[leftButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSArray *viewArrays = [weakSelf.navigationController viewControllers];
        UIViewController *lastButOneView = nil;
        if ([viewArrays count] > 1) {
            lastButOneView = [viewArrays objectAtIndex:[viewArrays count] - 2];
        }
        if (lastButOneView && [lastButOneView isKindOfClass:[PPCActivateViewController class]]) {
            lastButOneView = [viewArrays objectAtIndex:[viewArrays count] - 3];
            [weakSelf.navigationController popToViewController:lastButOneView animated:YES];
        } else {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
    self.navigationItem.leftBarButtonItem = item;
    headerHeight = HEADER_HEIGHT;
    descHeight = DESCRIPTION_HEIGHT;
}

- (void)doLoadHistory     {
    [[PurchaseProxy sharedInstance] getActivateHistoryInPage:currentPage Size:HISTORY_PAGE_SIZE];
}

- (NSArray *)responseList     {
    return [[PurchaseModel sharedInstance] getActivateHistoryResponse].orderList;
}

- (NSInteger)totalSize     {
    return [[[[PurchaseModel sharedInstance] getActivateHistoryResponse] pageable] totalSize].integerValue;
}

- (NNErrorDetail *)error     {
    return [[[PurchaseModel sharedInstance] getActivateHistoryResponse] errorInfo];
}


- (void)updateIndex     {
    if (isFresh) {
        currentPage = START_INDEX;
    } else {
        currentPage += HISTORY_PAGE_SIZE;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath     {
    return indexPath.row == 0 ? headerHeight : descHeight;
}

#pragma mark tableView datasource/delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath     {
    UITableViewCell *cell = nil;
    NSString *cellIdentifier = nil;
    if (indexPath.section == [historyList count]) {
        FunctionCellForDealer *cell = (FunctionCellForDealer *)[[[UIViewController alloc] initWithNibName:@"FunctionCellForDealer" bundle:nil] view];
        if ([historyList count] > 0) {
            cell.name.text = NSLocalizedString(@"SB023-05", nil);
        } else {
            if (isFailPage)
                cell.name.text = NSLocalizedString(@"fail_PPCHistory", nil);
            else
                cell.name.text = NSLocalizedString(@"NO_PPCHistory", nil);
        }
        return cell;
    }
    NNOrderList *order = [historyList objectAtIndex:indexPath.section];
    if (indexPath.row == 0) {
        cellIdentifier = @"PPCRecordHeaderCell";
        cell = [historyTableView dequeueReusableCellWithIdentifier:cellIdentifier];
        OrderRecordHeader *header = (OrderRecordHeader *)cell;
        header.packageNameLabel.text = order.packageInfo.packageName;
        [header updateIndicator:(indexPath.section == historyTableView.expandedIndex)];
        
        NSRange range = [order.activateDate rangeOfString:@" "];
        if (range.length != 0) {
            header.purchaseDateLabel.text = [order.activateDate substringToIndex:range.location];
        } else {
            header.purchaseDateLabel.text = order.activateDate;
        }
        header.finalPriceLabel.text = [NSString stringWithFormat:@"¥%.2f", [order.price floatValue]];
        header.orderIdLabel.text = order.cardNo;
        return cell;
    }
    
    NSString *packageType = order.packageInfo.packageType;
    if ([packageType caseInsensitiveCompare:@"data"] == NSOrderedSame) {
        cellIdentifier = @"ActiveHisotryDataDescription";
        cell = [historyTableView dequeueReusableCellWithIdentifier:cellIdentifier];
        ActiveHisotryDataDescription *description = (ActiveHisotryDataDescription *)cell;
        description.vinLabel.text = order.vehicleId;
        description.durationLabel.text = order.packageInfo.duration;//[NSString stringWithFormat:@"%@天", order.duration];
    } else {
        cellIdentifier = @"ActiveHistoryDescription";
        cell = [historyTableView dequeueReusableCellWithIdentifier:cellIdentifier];
        ActiveHistoryDescription *description = (ActiveHistoryDescription *)cell;
        description.vinLabel.text = order.vehicleId;
        
        NSRange range = [order.packageInfo.startDate rangeOfString:@" "];
        if (range.length != 0) {
            description.startDateLabel.text = [order.packageInfo.startDate substringToIndex:range.location];
        } else {
            description.startDateLabel.text = order.packageInfo.startDate;
        }
        
        range = [order.packageInfo.endDate rangeOfString:@" "];
        if (range.length != 0) {
            description.endDateLabel.text = [order.packageInfo.endDate substringToIndex:range.location];
        } else {
            description.endDateLabel.text = order.packageInfo.endDate;
        }
    }
    return cell;
}

- (void)viewWillAppear:(BOOL)animated     {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

@end
