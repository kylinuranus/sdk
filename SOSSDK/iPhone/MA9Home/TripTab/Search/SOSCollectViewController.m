
//
//  SOSCollectViewController.m
//  Onstar
//
//  Created by Genie Sun on 2017/8/9.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "NavigteSearchHomeAndCompanyCell.h"
#import "NavigateSearchHistoryCell.h"
#import "SOSCollectViewController.h"
#import "SOSHomeAndCompanyTool.h"
#import "CollectionToolsOBJ.h"
#import "BaseSearchTableVC.h"
#import "SOSRouteTool.h"

@interface SOSCollectViewController ()  <UITableViewDelegate, UITableViewDataSource, SOSCollectionCellDelegate>   {
    NavigteSearchHomeAndCompanyCell *homeAndCompanyCell;
    ///收藏夹数据类数组，存放SOSPoi对象
    NSMutableArray *collectionArray;
}
@end

@implementation SOSCollectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.table.tableFooterView = [UIView new];
    [self.table registerNib:[UINib nibWithNibName:@"NavigateSearchHistoryCell" bundle:[NSBundle SOSBundle]] forCellReuseIdentifier:@"NavigateSearchHistoryCell"];
    homeAndCompanyCell = [[NavigteSearchHomeAndCompanyCell alloc] init];
    homeAndCompanyCell.nav = self.navigationController;
    homeAndCompanyCell.type = self.operationType;
    [self switchDidChangeToIndex];
    @weakify(self);
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:KCollectionDataChangedNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        [CollectionToolsOBJ getCollectionListFromVC:self Success:^(NSArray *resultArray) {
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                [self handleCollectionResult:resultArray];
                [homeAndCompanyCell configHomeAndCompanyInfo];
            });
        }];
    }];
}

- (void)viewWillAppear:(BOOL)animated   {
    [super viewWillAppear:animated];
    [homeAndCompanyCell configHomeAndCompanyInfo];
}

- (void)switchDidChangeToIndex  {
    if (!collectionArray.count) {
        collectionArray = [NSMutableArray array];
        [CollectionToolsOBJ getCollectionListFromVC:self Success:^(NSArray *resultArray) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleCollectionResult:resultArray];
                [homeAndCompanyCell configHomeAndCompanyInfo];
            });
        }];
    }
    [self.table reloadData];
}

- (void)handleCollectionResult:(NSArray *)resultArray  {
    [collectionArray removeAllObjects];
    if (resultArray.count) {
        for (NSDictionary *dic in resultArray) {
            SOSPOI *poi = [CollectionToolsOBJ handleCollectionResultDic:dic];
            [collectionArray addObject:poi];
        }
    }
    [self.table reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldNotAddHomeAndCompanyCell	{
    return self.operationType == OperationType_Set_Home || self.operationType == OperationType_Set_Company;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.fromGeoFecing || [self shouldNotAddHomeAndCompanyCell]) {
        return 1;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.fromGeoFecing || [self shouldNotAddHomeAndCompanyCell]) {
        return collectionArray.count;
    }
    if (section == 0) {
        return 1;
    } else {
        return collectionArray.count + (collectionArray.count != 0);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.fromGeoFecing || [self shouldNotAddHomeAndCompanyCell]) {
        return KHistoryCellHeight;
    }
    if (indexPath.section == 0) {
        return KHomeAndCompanyCellHeight;
    }
    return KHistoryCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section   {
    return 0.01f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.fromGeoFecing || [self shouldNotAddHomeAndCompanyCell] || indexPath.section != 0) {
        NavigateSearchHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NavigateSearchHistoryCell"];
        // 收藏 Poi Cell
        if (indexPath.row < collectionArray.count) {
            cell.searchType = SearchTypeCollection;
            cell.poi = collectionArray[indexPath.row];
            cell.operationType = self.operationType;
        }
        // 清空收藏夹
        else    {
            cell.searchType = SearchTypeCleanCollection;
        }
        cell.delegate = self;
        [cell configSelf];
        return cell;
    }   else    {
        return homeAndCompanyCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.fromGeoFecing || [self shouldNotAddHomeAndCompanyCell] || indexPath.section != 0) {
        // 收藏夹 Cell 点击
        if (indexPath.row < collectionArray.count) {
            SOSPOI *selectPOI = collectionArray[indexPath.row];
            if (self.operationType == OperationType_set_Route_Begin_POI || self.operationType == OperationType_set_Route_Destination_POI) {
                [SOSRouteTool changeRoutePOIDoneFromVC:self WithType:self.operationType ResultPOI:selectPOI];
            }    else if (self.operationType == OperationType_Set_GroupTrip_Destination)        {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"KNoti_GroupTrip_Destination_Changed" object:selectPOI.mj_JSONObject];
                [self dismissViewControllerAnimated:YES completion:nil];
            }    else if (self.operationType > OperationType_set_Route_Destination_POI)    {
                SelectPointOperation simpleType = [SOSHomeAndCompanyTool simpleTypeWithType:self.operationType];
                
                [SOSDaapManager sendActionInfo:simpleType == OperationType_Set_Home ? Trip_GoWhere_FavoriteTab_HomeMore_EditHomeAdd_FavoriteTab_POISelect : Trip_GoWhere_FavoriteTab_OfficeMore_EditOfficeAdd_FavoriteTab_POISelect];
                [BaseSearchTableVC handleSearchResultJumpWithResultPOI:selectPOI FromVC:self];
            }	else	{
                [SOSDaapManager sendActionInfo:Trip_GoWhere_FavoriteTab_POI];
                [BaseSearchTableVC handleSearchResultJumpWithResultPOI:selectPOI FromVC:self];
            }
        }
        // 清空收藏夹
        else	{
            //清空搜索历史
            if (((NavigateSearchHistoryCell *)[tableView cellForRowAtIndexPath:indexPath]).searchType != SearchTypeCleanCollection)    return;
            [Util showAlertWithTitle:@"要清除所有收藏地点吗?\n(家和公司不会被清除)" message:nil completeBlock:^(NSInteger buttonIndex) {
                if (buttonIndex) {
                    [Util showHUD];
                    [CollectionToolsOBJ deleteAllColectionsSuccess:^{
                        [Util dismissHUD];
                        [Util showSuccessHUDWithStatus:@"操作成功"];
                        [collectionArray removeAllObjects];
                        [self.table reloadData];
                    } Failure:^{
                        [Util dismissHUD];
                    }];
                    
                }
            } cancleButtonTitle:@"否" otherButtonTitles:@"是", nil];
        }
    }   else    {
        //家和公司地址Cell的点击在Cell中处理
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && !self.fromGeoFecing && !self.operationType) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        [self deleteCollectionWithIndex:indexPath.row];
    }
}

- (void)deleteCollectionWithIndex:(NSInteger)index    {
    [SOSDaapManager sendActionInfo:Trip_GoWhere_FavoriteTab_DeleteFavoritePOI];
    [Util showAlertWithTitle:nil message:@"您确定删除该收藏 ?" completeBlock:^(NSInteger buttonIndex) {
        if (buttonIndex) {
            [Util showHUD];
            [SOSDaapManager sendActionInfo:Trip_GoWhere_FavoriteTab_DeleteFavoritePOI_Confirm];
            SOSPOI *poi = collectionArray[index];
            [CollectionToolsOBJ deleteCollectionWithDestinationID:poi.destinationID Success:^{
                [Util dismissHUD];
                [collectionArray removeObjectAtIndex:index];
                [self.table reloadData];
            } Failure:^{
                [Util dismissHUD];
            }];
        }    else    {
            [SOSDaapManager sendActionInfo:Trip_GoWhere_FavoriteTab_DeleteFavoritePOI_Cancel];
        }
    } cancleButtonTitle:@"否" otherButtonTitles:@"是", nil];
}

#pragma mark - Collection Cell Delegate
- (void)deleteButtonTappedWithCell:(NavigateSearchHistoryCell *)cell		{
    NSIndexPath *index = [self.table indexPathForCell:cell];
    [self deleteCollectionWithIndex:index.row];
}

@end
