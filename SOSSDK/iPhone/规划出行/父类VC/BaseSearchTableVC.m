//
//  BaseSearchTableVC.m
//  Onstar
//
//  Created by Coir on 16/2/17.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "CustomerInfo.h"
#import "SOSTripPOIVC.h"
#import "SOSRouteTool.h"
#import "SOSGeoDataTool.h"
#import "NavigateSearchVC.h"
#import "BaseSearchTableVC.h"
#import "SOSHomeAndCompanyTool.h"

@interface BaseSearchTableVC ()     <PoiDelegate, ErrorDelegate, UIAlertViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *textClearButton;

@property (nonatomic, assign) BOOL isAssociateSearch;

@end

@implementation BaseSearchTableVC

- (instancetype)init    {
    return [super initWithNibName:@"BaseSearchTableVC" bundle:[NSBundle SOSBundle]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    currentPage = 0;
    searchRsultPage = 1;
    searchResultArray = [NSMutableArray array];
    [self configFieldSearch];
    [self configSearchData];
}

- (void)configSearchData {
    self.associateSearchOBJ = [[AssociateTips alloc] init];
    self.associateSearchOBJ.delegate = self;
    
    baseSearchOBJ = [BaseSearchOBJ new];
    baseSearchOBJ.poiDelegate = self;
    baseSearchOBJ.errorDelegate = self;
}

- (void)configFieldSearch   {
    [self.searchButton setBackgroundColor:[UIColor colorWithHexString:@"6896ED"] forState:UIControlStateNormal];
    [self.searchButton setBackgroundColor:[UIColor colorWithHexString:@"C3CEEC"] forState:UIControlStateDisabled];
    self.searchButton.enabled = NO;
    
    if (self.fromGeoFecing) {
        self.fieldSearch.placeholder = @"设置围栏中心";
    }   else if (self.operationType)    {
        switch (self.operationType) {
            case OperationType_set_Geo_Center:
                self.fieldSearch.placeholder = @"设置围栏中心";
                break;
            case OperationType_Set_Home:
            case OperationType_Set_Home_Send_POI:
                self.fieldSearch.placeholder = @"设置住家";
                break;
            case OperationType_Set_Company:
            case OperationType_Set_Company_Send_POI:
                self.fieldSearch.placeholder = @"设置公司";
                break;
            case OperationType_set_Route_Begin_POI:
                self.fieldSearch.placeholder = @"设置起点";
                break;
            case OperationType_set_Route_Destination_POI:
                self.fieldSearch.placeholder = @"设置终点";
                break;
            case OperationType_Set_GroupTrip_Destination:
                self.fieldSearch.placeholder = @"车队目的地";
                break;
            default:
                break;
        }
    }	else	{
        self.fieldSearch.placeholder = @"去哪里";
    }
    self.fieldSearch.clearButtonMode = UITextFieldViewModeWhileEditing;
    __weak __typeof(self) weakSelf = self;
    [[self.fieldSearch rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
        weakSelf.searchButton.enabled = x.length;
        weakSelf.textClearButton.hidden = !x.length;
    }];
    // 开始联想搜索
    [[self.fieldSearch rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
        if (x.length) {
            [weakSelf.associateSearchOBJ searchWithKeyWords:x AndCityName:[CustomerInfo sharedInstance].currentPositionPoi.city];
//            weakSelf.associateSearchOBJ.delegate = weakSelf;
        }	else	{
            weakSelf.searchListTableView.hidden = YES;
//            weakSelf.associateSearchOBJ.delegate = nil;
        }
    }];
}

- (IBAction)clearText {
    self.fieldSearch.text = @"";
    self.searchButton.enabled = NO;
    self.textClearButton.hidden = YES;
    self.searchListTableView.hidden = YES;
}

- (void)resetTableView  {
    TableDataTypeBeforeChange = TableDataTypeHistory;
    tableType = TableDataTypeHistory;
    [self.searchListTableView reloadData];
}

#pragma mark - 关键字联想搜索回调
- (void)associateSearchDoneWithKeyWords:(NSString *)keyWords Results:(NSArray *)associateArray    {
    if (![keyWords isEqualToString:self.fieldSearch.text]) 	return;
    associateDataArray = [NSMutableArray arrayWithArray:associateArray];
    
    if (tableType != TableDataTypeAssociateTips && tableType != TableDataTypeSearchResult) {
        TableDataTypeBeforeChange = tableType;
        tableType = TableDataTypeAssociateTips;
    }
    self.searchListTableView.hidden = NO;
    [self.searchListTableView reloadData];
    [self.searchListTableView scrollRectToVisible:CGRectMake(0, 0, 20, 20) animated:YES];
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView  {
    if ([self.fieldSearch isFirstResponder]) {
        [self.fieldSearch resignFirstResponder];
    }
}

#pragma mark - TextField Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string    {
    if (range.location >= 30)       {
        return NO;
    }   else    {
        NSString *keywords = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (!keywords.length) {
            TableDataTypeBeforeChange = TableDataTypeHistory;
            tableType = TableDataTypeHistory;
            [self.searchListTableView reloadData];
        }
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField  {
    if (self.operationType == OperationType_Set_GroupTrip_Destination) {
        [SOSDaapManager sendActionInfo:GroupToTravel_Group_SetDestination_Search];
    }
    [textField resignFirstResponder];
    NSString *tempString = [self.fieldSearch.text  stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (0 == [tempString length])    {
        [Util showAlertWithTitle:nil message:@"请输入搜索关键字" completeBlock:nil];
        return YES;
    }
    if (self.operationType)    {
        [SOSDaapManager sendActionInfo:Trip_GoWhere_Set_Search];
    }    else    {
        [SOSDaapManager sendActionInfo:Trip_GoWhere_Search];
    }
    
    TableDataTypeBeforeChange = tableType;
    tableType = TableDataTypeSearchResult;
    [Util showHUD];
    [self setPoiSearchConfig];
    [baseSearchOBJ keyWordSearchWithKeyWords:tempString City:[CustomerInfo sharedInstance].currentPositionPoi.city];
    self.isAssociateSearch = NO;
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField   {
    return YES;
}

// 联想搜索
- (void)searchWithTip:(AMapTip *)tip      {
    [baseSearchOBJ aroundSearchWithKeyWords:tip.name Location:tip.location Radius:10000];
    self.isAssociateSearch = YES;
}

#pragma mark - Search Delegate
// 搜索结果,跳转地图列表
- (void)poiSearchResult:(SOSPoiSearchResult *)results   {
    [Util dismissHUD];
    if (!results.pois.count) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self clearText];
        BOOL shouldPush = YES;
        SOSTripPOIVC *vc = [SOSTripPOIVC new];
        if (results.pois.count > 1)		vc.poiArray = results.pois;
        else							vc.selectedPOI = results.pois[0];
        if (self.operationType) {
            vc.operationType = self.operationType;
            SelectPointOperation simpleType = [SOSHomeAndCompanyTool simpleTypeWithType:self.operationType];
            // 设置 家/公司 地址
            if (simpleType) {
                vc.mapType = self.isAssociateSearch ? MapTypePickPoint : MapTypePickPointFromList;
//                vc.mapTypeBeforChange = (simpleType == OperationType_Set_Home) ? MapTypeModifyHomeAddress : MapTypeModifyCompanyAddress;
//                vc.mapType = MapTypeShowPoiList;
            }	else	{
                // 设置路线起终点 或 设置围栏中心点
                vc.mapTypeBeforChange = MapTypePickPointFromList; // 此处和修改家和公司地址UI一致
                if (self.operationType == OperationType_set_Geo_Center) {
                    vc.mapType = self.isAssociateSearch ? MapTypePickPoint : MapTypePickPointFromList;
                }	else	vc.mapType = MapTypeShowPoiList;
            }
        }	else if (tableType == TableDataTypeSearchResult)	{
            // 正常搜索结果
            vc.mapType = MapTypeShowPoiList;
        }	else if (tableType == TableDataTypeAssociateTips)   {
            shouldPush = NO;
            // 联想搜索结果处理,
            NSArray *poisArray = results.pois;
            SOSPOI *resultPOI = poisArray[0];
            [[SOSPoiHistoryDataBase sharedInstance] insert:resultPOI];
            self.searchListTableView.hidden = YES;
            [self handleSearchResultJumpWithResultPOI:resultPOI];
        }
        if (shouldPush) [self.navigationController pushViewController:vc animated:YES];
    });
}

- (void)baseSearch:(id)searchOption Error:(NSString *)errCode   {
    [Util dismissHUD];
}

#pragma mark - TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section    {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath     {
    return [UITableViewCell new];
}

///获取搜索联想提示Cell
- (UITableViewCell *)getAssociateCellInTableView:(UITableView *)tableview ByIndexPath:(NSIndexPath *)indexPath {
    AssociateCell *cell = (AssociateCell *)[tableview dequeueReusableCellWithIdentifier:@"AssociateCell"];
    if (cell == nil) {
        cell = [[NSBundle SOSBundle] loadNibNamed:@"AssociateCell" owner:self options:nil][0];
    }
    cell.tip = associateDataArray[indexPath.row];
    cell.inputStr = self.fieldSearch.text;
    cell.operationType = self.operationType;
    [cell configSelf];
    return cell;
}

///获取搜索结果Cell
- (UITableViewCell *)getSearchResultCellInTableView:(UITableView *)tableview ByIndexPath:(NSIndexPath *)indexPath     {
    NavigateSearchHistoryCell *cell = [tableview dequeueReusableCellWithIdentifier:@"NavigateSearchHistoryCell"];
    if (cell == nil) {
        cell = [NavigateSearchHistoryCell viewFromXib];
    }
    if (!((searchRsultPage == 1 && indexPath.section == 0) || (searchRsultPage != 1 && indexPath.section == 1))) {
        ///上二十条
        UITableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:@"LoadMoreCell"];
        if (cell == nil) {
            cell = [UITableViewCell new];
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.searchListTableView.width, KSearchResultCellHeight)];
            titleLabel.font = [UIFont systemFontOfSize:13];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.textColor = [UIColor colorWithWhite:.5 alpha:1];
            titleLabel.tag = 1098;
            [cell addSubview:titleLabel];
        }
        cell.backgroundColor = [UIColor clearColor];
        [(UILabel *)[cell viewWithTag:1098] setText:indexPath.section == 0 ? NSLocalizedString(@"Navigate_Search_Load_Previous_Result", nil) : NSLocalizedString(@"Navigate_Search_Load_Next_Result", nil)];
        return cell;
    }
    if (indexPath.row > searchResultArray.count || searchResultArray[indexPath.row] == nil) {
        return [UITableViewCell new];
    }
    cell.searchType = SearchTypeSearchResult;
    cell.poi = searchResultArray[indexPath.row];
    [cell configSelf];
    if (self.fromGeoFecing) {
        cell.sendToCarButton.hidden = YES;
    }
    return cell;
}

///搜索结果Cell点击处理
- (void)handleSearchResultCellSelect:(UITableView *)tableView AtIndexPath:(NSIndexPath *)indexPath     {
    if ((searchRsultPage == 1 && indexPath.section == 0) || (searchRsultPage != 1 && indexPath.section == 1)) {
        
        SOSPOI *resultPOI = searchResultArray[indexPath.row];
        [[SOSPoiHistoryDataBase sharedInstance] insert:resultPOI];
        [self clearText];
        [self handleSearchResultJumpWithResultPOI:resultPOI];
    }   else    {
        if (indexPath.section == 0)     searchRsultPage --;
        else                            searchRsultPage ++;
        
        [self setPoiSearchConfig];
        // 后续在 poiSearchResult 中处理
        [baseSearchOBJ keyWordSearchWithKeyWords:self.fieldSearch.text City:[CustomerInfo sharedInstance].currentPositionPoi.city];
        self.isAssociateSearch = NO;
    }
}

- (void)handleAssociateCellSelect:(AssociateCell *)cell AtIndexPath:(NSIndexPath *)indexPath     {
    AMapTip *tip = associateDataArray[indexPath.row];
    [self searchWithTip:tip];
}

- (void)setPoiSearchConfig  {
    BasePoiSearchConfiguration *config = [[BasePoiSearchConfiguration alloc] init];
    config.offset = KOffsetSearchResult;
    config.page = searchRsultPage;
    baseSearchOBJ.poiSearchConfig = config;
}


/// 处理搜索结果跳转(电子围栏,设置住家/公司地址,正常POI搜索等)
- (void)handleSearchResultJumpWithResultPOI:(SOSPOI *)resultPOI     {
    [BaseSearchTableVC handleSearchResultJumpWithResultPOI:resultPOI FromVC:self];
}

/// 处理搜索结果跳转(电子围栏,设置住家/公司地址,正常POI搜索等)
+ (void)handleSearchResultJumpWithResultPOI:(SOSPOI *)resultPOI FromVC:(UIViewController *)fromVC       {
    UIViewController *resultVC = fromVC;
    BOOL findParentVC = NO;
    while (resultVC.parentViewController != nil) {
        resultVC = resultVC.parentViewController;
        if ([resultVC isKindOfClass:[BaseSearchTableVC class]])    {
            findParentVC = YES;
            break;
        }
    }
    if (findParentVC == NO) 	resultVC = fromVC;
    
    if ([(BaseSearchTableVC *)resultVC fromGeoFecing]) {//从电子围栏里面打开的搜索页面
        
        //将搜索结果作为电子围栏的中心点 ,点击后关闭搜索 ,同时修改电子围栏的中心点
        // 设置围栏中心点
        NNGeoFence *geofence = ((BaseSearchTableVC *)resultVC).geoFence;
        geofence.centerPoiName = resultPOI.name;
        geofence.centerPoiAddress = resultPOI.address;
        NNCenterPoiCoordinate *gencingCoord = [NNCenterPoiCoordinate coordinateWithLongitude:resultPOI.longitude AndLatitude:resultPOI.latitude];
        [geofence setCenterPoiCoordinate:gencingCoord];
        [SOSGeoDataTool backToAddGeoMapVCWithFromVC:resultVC AndGeoFence:[SOSGeoDataTool getGeoFenceWithPOI:resultPOI]];
        
        
        
    }	else    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([resultVC isKindOfClass:[self class]]) {
                BaseSearchTableVC *selfVC = (BaseSearchTableVC *)resultVC;
                if (selfVC.operationType) {
                    SelectPointOperation simpleType = [SOSHomeAndCompanyTool simpleTypeWithType:selfVC.operationType];
                    // 设置 家/公司 地址
                    if (simpleType) {
                        [Util showHUD];
                        [SOSHomeAndCompanyTool setHomeOrCompanyWithPOI:resultPOI OperationType:selfVC.operationType successBlock:^(SOSNetworkOperation *operation, id responseStr) {
                            [Util dismissHUD];
                            dispatch_async_on_main_queue(^{
                                switch (selfVC.operationType) {
                                    case OperationType_Set_Home:
                                    case OperationType_Set_Company:
                                        [selfVC dismissViewControllerAnimated:YES completion:nil];
                                        break;
                                    case OperationType_Set_Home_Send_POI:
                                    case OperationType_Set_Company_Send_POI:
                                        [SOSHomeAndCompanyTool alertSendPOIWithOperationType:selfVC.operationType];
                                        break;
                                    default:
                                        break;
                                }
                            });
                        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                            [Util dismissHUD];
                        }];
                    }    else    {
                        // 设置路线起终点
                        [SOSRouteTool changeRoutePOIDoneFromVC:fromVC WithType:selfVC.operationType ResultPOI:resultPOI];
                    }
                    return;
                }
            }
            SOSTripPOIVC *vc = [[SOSTripPOIVC alloc] initWithPOI:resultPOI];
            [[SOSPoiHistoryDataBase sharedInstance] insert:resultPOI];
            vc.mapType = MapTypeShowPoiPoint;
            [fromVC.navigationController pushViewController:vc animated:YES];
            
        });
    }
}

- (IBAction)searchButtonTapped {
    [self textFieldShouldReturn:self.fieldSearch];
}

- (IBAction)back:(UIButton *)sender {
    if ([self isKindOfClass:NSClassFromString(@"SOSAroundSearchVC")]) {
        [SOSDaapManager sendActionInfo:Trip_GoWhere_POIdetail_SearchAround_Back];
    }	else	{
        if (self.operationType)    {
            if (self.operationType == OperationType_Set_GroupTrip_Destination) {
                [SOSDaapManager sendActionInfo:GroupToTravel_Group_SetDestination_Back];
            }	else	[SOSDaapManager sendActionInfo:Trip_GoWhere_Set_Back];
        }    else    {
            [SOSDaapManager sendActionInfo:Trip_GoWhere_Back];
        }
    }
    
    
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }	else	{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
