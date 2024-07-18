//
//  NavigateSearchVC.m
//  Onstar
//
//  Created by Genie Sun on 2017/8/9.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSHomeAndCompanyTool.h"
#import "SOSSearchViewController.h"
#import "NavigateSearchVC.h"
#import "SOSRouteTool.h"

@interface NavigateSearchVC ()

@end

@implementation NavigateSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    SOSSearchViewController *searchVc = [[SOSSearchViewController alloc] init];
    if (self.fromGeoFecing) {
        searchVc.geoFence = self.geoFence;
    }
    searchVc.tf = self.fieldSearch;
    searchVc.operationType = self.operationType;
    searchVc.fromGeoFecing = self.fromGeoFecing;
    searchVc.view.frame = self.segmentVc.bounds;

    [self addChildViewController:searchVc];
    [self.segmentVc addSubview:searchVc.view];
    self.searchListTableView.tableFooterView = [UIView new];
    
    //选择围栏中心点,设置住家/公司地址,路线起终点,隐藏快捷键视图
    if (self.fromGeoFecing || self.operationType) {
        self.shortCutView.hidden = YES;
        self.shortCutHeight.constant = 0;
        [self.view setNeedsLayout];
        searchVc.segmentVC.originY = 0;
    }   else    {
        self.shortCutView.hidden = NO;
        searchVc.segmentVC.originY = 0;
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField   {
    [self reloadTableView];
    return YES;
}

#pragma mark - TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView   {
    ///搜索联想提示
    if (tableType == TableDataTypeAssociateTips)    return 1;
    else 	return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section    {
    if (tableType == TableDataTypeAssociateTips) {
        ///搜索联想提示
        return associateDataArray.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableType == TableDataTypeAssociateTips) {
        ///搜索联想提示
        return KAssociateCellHeight;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath     {
    if (tableType == TableDataTypeAssociateTips)  {
        return [self getAssociateCellInTableView:tableview ByIndexPath:indexPath];
    }
    return nil;
}

// 搜索联想Cell 点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath     {
    [self.fieldSearch resignFirstResponder];
    UITableViewCell *resultCell = [tableView cellForRowAtIndexPath:indexPath];
    // 搜索联想Cell
    if ([resultCell isKindOfClass:[AssociateCell class]])    {
        if (!self.operationType) {
            [SOSDaapManager sendActionInfo:Trip_GoWhere_POI];
        }
        [self.fieldSearch resignFirstResponder];
        self.searchListTableView.hidden = YES;
        self.fieldSearch.text = @"";
        // 修改路径起/终点
        if (self.operationType == OperationType_set_Route_Begin_POI || self.operationType == OperationType_set_Route_Destination_POI) {
            AMapTip *tip = ((AssociateCell *)resultCell).tip;
            SOSPOI *poi = [SOSPOI new];
            poi.name = tip.name;
            poi.longitude = @(tip.location.longitude).stringValue;
            poi.latitude = @(tip.location.latitude).stringValue;
            poi.address = tip.address;
            poi.pguid = tip.uid;
            
            [SOSRouteTool changeRoutePOIDoneFromVC:self WithType:self.operationType ResultPOI:poi];
        }	else	{
            [self handleAssociateCellSelect:(AssociateCell *)resultCell AtIndexPath:indexPath];
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField	{
    self.searchListTableView.hidden = NO;
    return YES;
}

- (void)changeSearchKeywords:(NSString *)keywords   {
    self.fieldSearch.text = keywords;
    [self.fieldSearch becomeFirstResponder];
}

- (void)reloadTableView		{
    (associateDataArray.count > 0) ? [associateDataArray removeAllObjects] : nil;
    (searchResultArray.count > 0) ? [searchResultArray removeAllObjects] : nil;
    self.fieldSearch.text = @"";
    [super resetTableView];
}

+ (BOOL)canComeBackToSearchVCFromNav:(UINavigationController *)navVC {
    __weak UINavigationController *nav = navVC;
    for (UIViewController *vc in nav.viewControllers) {
        if ([vc isKindOfClass:[NavigateSearchVC class]]) {
            [nav popToViewController:vc animated:YES];
            return YES;
        }
    }
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
