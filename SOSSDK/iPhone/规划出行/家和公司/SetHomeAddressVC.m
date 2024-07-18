//
//  SetHomeAddressVC.m
//  Onstar
//
//  Created by Coir on 16/1/28.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "PoiHistory.h"
#import "LoadingView.h"
#import "SOSUserLocation.h"
#import "NavigateSearchVC.h"
#import "SetHomeAddressVC.h"
#import "SetHomeHeaderCell.h"
#import "SOSNetworkOperation.h"
#import "CarOperationWaitingVC.h"
#import "SOSHomeAndCompanyTool.h"


typedef void (^JudgeHomeAndCompanySettingBlock)(NSString *reportKey);

@interface SetHomeAddressVC ()  <UIAlertViewDelegate>  {
    
    SOSPOI *selectedPoi;
    SetHomeHeaderCell *headerCell;
    JudgeHomeAndCompanySettingBlock judgeBlock;
    
}

@end

///顶部Cell高度
#define KHeaderCellHeight       63

@implementation SetHomeAddressVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    [self initData];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

#pragma mark - 初始化数据
- (void)initData    {
    judgeBlock = ^(NSString *reportKey){
        if (self.pageType == pageTypeHome || self.pageType == pageTypeCompany) {
            ////[[SOSReportService shareInstance] recordActionWithFunctionID:reportKey];
        }
    };
    TableDataTypeBeforeChange = TableDataTypeHistory;
    headerCell = [[NSBundle SOSBundle] loadNibNamed:@"SetHomeHeaderCell" owner:self options:nil][0];
    headerCell.nav = self.navigationController;
    SOSPOI *currentPositionPoi = [CustomerInfo sharedInstance].currentPositionPoi;
    if (!currentPositionPoi) {
        [[SOSUserLocation sharedInstance] getLocationSuccess:^(SOSPOI *userLocationPoi) { } Failure:^(NSError *error) { }];
    }
    [[SOSPoiHistoryDataBase sharedInstance] fetch:^(NSArray<SOSPOI *> * _Nonnull array) {
        historyArray = [NSMutableArray arrayWithArray:array];
    }];
}

#pragma mark - TableView代理以及数据源
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView   {
    if (tableType == TableDataTypeAssociateTips) {
        return 1;
    }   else if (tableType == TableDataTypeSearchResult)     {
        ///搜索结果
        return 1 + (searchRsultPage != 1) + (searchResultArray.count == KOffsetSearchResult);
    }  else  {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section    {
    if (tableType == TableDataTypeAssociateTips) {
        ///搜索联想提示
        return associateDataArray.count;
    }   else if (tableType == TableDataTypeSearchResult)   {
        ///搜索结果
        if ((searchRsultPage == 1 && section == 0) || (searchRsultPage != 1 && section == 1)) {
            return searchResultArray.count;
        }   else    return 1;
    }   else  {
        ///搜索历史
        if (historyArray.count) {
            return section ? (historyArray.count) : 1;
        }   else    return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    if (tableType == TableDataTypeAssociateTips) {
        ///搜索联想提示
        return KAssociateCellHeight;
    }   else if (tableType == TableDataTypeSearchResult)   {
        ///搜索结果
        if ((searchRsultPage == 1 && indexPath.section == 0) || (searchRsultPage != 1 && indexPath.section == 1)) {
            return KSearchResultCellHeight;
        }   else    return KSearchResultCellHeight;
    }   else  {
        ///搜索历史
        if (indexPath.section == 0) {
            ///顶部 我的位置，收藏夹等Button
            return KHeaderCellHeight;
        }   else    {
            if (indexPath.row < historyArray.count) {
                ///历史纪录Cell
                return KMoreAndClearHistoryCellHeight;
            }   else    {
                ///更多，清空历史纪录Cell
                return KMoreAndClearHistoryCellHeight;
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    UITableViewCell *cell;
    if (tableType == TableDataTypeAssociateTips) {
        ///顶部 我的位置，收藏夹等Button
        cell = [self getAssociateCellInTableView:tableView ByIndexPath:indexPath];
    }   else if (tableType == TableDataTypeSearchResult)   {
        ///搜索结果
        return [self getSearchResultCellInTableView:tableView ByIndexPath:indexPath];
    }   else  {
        
        if (indexPath.section == 0) {
            ///顶部 我的位置，收藏夹等Button
            cell = headerCell;
        }   else    {
            ///搜索历史
            NavigateSearchHistoryCell *historyCell = (NavigateSearchHistoryCell *)[tableView dequeueReusableCellWithIdentifier:@"NavigateSearchHistoryCell"];
            if (historyCell == nil) {
                historyCell = [[NSBundle SOSBundle] loadNibNamed:@"NavigateSearchHistoryCell" owner:self options:nil][0];
            }
            if (indexPath.row < historyArray.count) {
                ///历史纪录Cell
                historyCell.searchType = SearchTypeSearchHistory;
                historyCell.poi = historyArray[indexPath.row];
                //            }   else if (indexPath.row == historyArray.count)    {
                //                ///更多历史纪录Cell
                //                historyCell.searchType = SearchTypeMoreSearchHistory;
            }   else if (indexPath.row == historyArray.count)    {
                ///清除历史纪录Cell
                historyCell.searchType = SearchTypeCleanHistory;
            }
            [historyCell configSelf];
            cell = historyCell;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath     {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[AssociateCell class]]) {
        ///搜索联想Cell
        AMapTip *tip = associateDataArray[indexPath.row];
        [baseSearchOBJ IDSearchWithID:tip.uid];
    }   else if ([cell isKindOfClass:[NavigateSearchHistoryCell class]]) {
        NavigateSearchHistoryCell *hisCell = (NavigateSearchHistoryCell *)cell;
        
        switch (hisCell.searchType) {
            case SearchTypeSearchHistory:
                ///搜索历史
//                judgeBlock(Homesetting_clicksearchhistory);
                [self handlePoiResult:hisCell.poi];
                break;
            case SearchTypeSearchResult:
                [self handlePoiResult:hisCell.poi];
                break;
            case SearchTypeCleanHistory:    {
                ///清空搜索历史
                [Util showAlertWithTitle:nil message:@"您确定清空历史记录?" completeBlock:^(NSInteger buttonIndex) {
                    if (buttonIndex) {
                        [[SOSPoiHistoryDataBase sharedInstance] deleteAll];
                        [historyArray removeAllObjects];
                        [self.searchListTableView reloadData];
                    }
                } cancleButtonTitle:@"否" otherButtonTitles:@"是", nil];
                break;
            }
            default:
                break;
        }
    }   else  if (tableType == TableDataTypeSearchResult)  {
        ///在cell中处理
        [self handleSearchResultCellSelect:tableView AtIndexPath:indexPath];
    }   else    {
        return;
    }
}

#pragma mark - AMapSearch Delegate
- (void)poiSearchResult:(SOSPoiSearchResult *)results   {
    if (tableType == TableDataTypeSearchResult) {
        baseSearchOBJ.poiSearchConfig = nil;
        [searchResultArray removeAllObjects];
        [searchResultArray addObjectsFromArray:results.pois];
        [self.searchListTableView reloadData];
        [self.searchListTableView scrollRectToVisible:CGRectMake(0, 0, 20, 20) animated:YES];
    }   else if (tableType == TableDataTypeAssociateTips)   {
        NSArray *poisArray = results.pois;
        if (poisArray.count) {
            [[SOSPoiHistoryDataBase sharedInstance] insert:poisArray[0]];
            [self handlePoiResult:results.pois[0]];
        }
    }
}

#pragma mark - 点击我的位置
- (void)useMyPosition   {
    SOSPOI *currentPositionPoi = [CustomerInfo sharedInstance].currentPositionPoi;
    if (currentPositionPoi) {
        [self handlePoiResult:currentPositionPoi];
    }   else    {
        [Util showAlertWithTitle:nil message:@"暂时无法获取定位信息!" completeBlock:nil];
    }
}

#pragma mark - 获取Poi信息
- (void)getHomeAndCompanyPoiInfo    {
    NSString *url = [BASE_URL stringByAppendingFormat:HOME_POI_GET,@(1),@(50)];
    
    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        if ([LoginManage sharedInstance].loginState != LOGIN_STATE_NON) {
        
        NSArray *dataArray = [Util arrayWithJsonString:responseStr];
        if (dataArray.count) {
            for (NSDictionary *dic in dataArray) {
                GetDestinationResponse *destinationResponse = [GetDestinationResponse mj_objectWithKeyValues:dic];
                if (destinationResponse.customCatetory.intValue == 1) {
                    SOSPOI *homePoi = destinationResponse.poi;
                    if (!homePoi) {
                        return;
                    }
                    [CustomerInfo sharedInstance].homePoi = homePoi;
                    
                    
                } else if (destinationResponse.customCatetory.intValue == 2) {
                    SOSPOI *companyPoi = destinationResponse.poi;
                    if (!companyPoi) {
                        return;
                    }
                    [CustomerInfo sharedInstance].companyPoi = companyPoi;
                }
            }
        }
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
    }];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}

#pragma mark - 保存Poi信息
- (void)saveHomePoi:(SOSPOI *)homePoi    {
    selectedPoi = homePoi;
    [self savePoi:homePoi IsHomePoi:1];
}

- (void)saveCompanyPoi:(SOSPOI *)companyPoi     {
    selectedPoi = companyPoi;
    [self savePoi:companyPoi IsHomePoi:2];
}

/// "1" - 家, "2" - 公司
- (void)savePoi:(SOSPOI *)poi  IsHomePoi:(int)isHomePoi   {
    [Util showLoadingView];
    [SOSHomeAndCompanyTool setHomeOrCompanyWithPOI:poi OperationType:isHomePoi successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        if (self.pageType == pageTypeEasyBackHome || self.pageType == pageTypeEasyBackCompany || self.pageType == pageTypeEasyBackHome || self.pageType == pageTypeEasyBackCompany) {
            NSString *message = @"";
            if (isHomePoi == 1) {
                message = @"已成功设置家的地址\n是否现在发送目的地到车";
                [CustomerInfo sharedInstance].homePoi = poi;
            }   else    {
                message = @"已成功设置公司的地址\n是否现在发送目的地到车";
                [CustomerInfo sharedInstance].companyPoi = poi;
            }
            [Util showAlertWithTitle:nil message:message completeBlock:^(NSInteger buttonIndex) {
                CarOperationWaitingVC *vc = [CarOperationWaitingVC initWithPoi:selectedPoi Type:OrderTypeAuto FromVC:nil];
                [vc checkAndShowFromVC:self];
            } cancleButtonTitle:@"否" otherButtonTitles:@"是", nil];
        }   else if (self.pageType == pageTypeHome ) {
            [CustomerInfo sharedInstance].homePoi = poi;
            [self performSelectorOnMainThread:@selector(jumpBackToNavigateSearchVC) withObject:nil waitUntilDone:NO];
        }   else if (self.pageType == pageTypeCompany)  {
            //TO BE TEST
            [CustomerInfo sharedInstance].companyPoi = poi;
            [self performSelectorOnMainThread:@selector(jumpBackToNavigateSearchVC) withObject:nil waitUntilDone:NO];
        }
        [Util hideLoadView];
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util hideLoadView];
    }];
}

#pragma mark - 处理选中Poi点，并返回之前页面
- (void)handlePoiResult:(SOSPOI *)tempPoi   {
    switch (self.pageType) {
        case pageTypeHome:  {
            [self saveHomePoi:tempPoi];
            break;
        }
        case pageTypeCompany:{
            [self saveCompanyPoi:tempPoi];
            break;
        }
//        case pageTypeSmartHome:{
//            [self saveHomePoi:tempPoi];
//            break;
//        }
        case pageTypeRouteBegin:{
            [self jumpBackToNavigateRouteVCWithPoiInfo:tempPoi isBeginPoint:YES];
            break;
        }
        case pageTypeRouteDestination:{
            [self jumpBackToNavigateRouteVCWithPoiInfo:tempPoi isBeginPoint:NO];
            break;
        }
        case pageTypeEasyBackHome:
            //            [CustomerInfo sharedInstance].homePoi = tempPoi;
            [self saveHomePoi:tempPoi];
            break;
        case pageTypeEasyBackCompany:
            //            [CustomerInfo sharedInstance].companyPoi = tempPoi;
            [self saveCompanyPoi:tempPoi];
            break;
        default:
            break;
    }
}

- (void)jumpBackToNavigateRouteVCWithPoiInfo:(SOSPOI *)poi isBeginPoint:(BOOL)isBeginPoint  {
//    for (UIViewController *vc in self.navigationController.viewControllers) {
//        if ([vc isKindOfClass:[NavigateRouteVC class]]) {
//            isBeginPoint ? [(NavigateRouteVC *)vc setBeginPoi:poi] : [(NavigateRouteVC *)vc setDestinationPoi:poi];
//            [(NavigateRouteVC *)vc refreshData];
//            [self.navigationController popToViewController:vc animated:YES];
//            break;
//        }
//    }
}

- (void)jumpBackToNavigateSearchVC  {
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[NavigateSearchVC class]]) {
//            [(NavigateSearchVC *)vc configHomeAndCompanyInfo];
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
    }
}



- (IBAction)back:(UIButton *)sender {
    //[[SOSReportService shareInstance] recordActionWithFunctionID:Homesetting_return];
//    judgeBlock(Homesetting_return);
    [super back:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
