//
//  SOSAroundSearchVC.m
//  Onstar
//
//  Created by Coir on 13/10/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSTripPOIVC.h"
#import "AssociateTips.h"
#import "SOSDealerTool.h"
#import "SOSTripDealerVC.h"
#import "SOSTripChargeVC.h"
#import "SOSNavigateTool.h"
#import "SOSAroundSearchVC.h"
#import "SOSAMapSearchTool.h"
#import "SOSAroundSearchCell.h"

@interface SOSAroundSearchVC ()  <UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate, AssociateTipsDelegate, UITableViewDelegate, UITableViewDataSource>
    
@property (strong, nonatomic) UICollectionView *contentCollectionView;
@property (strong, nonatomic) NSMutableArray *dataSourceArray;

@end

@implementation SOSAroundSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configSelf];
    [self reloadData];
}

- (void)configSelf    {
    self.fieldSearch.placeholder = @"搜索周边";
    self.fd_prefersNavigationBarHidden = YES;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(60, 77);
    layout.minimumLineSpacing = 30;
    layout.sectionInset = UIEdgeInsetsMake(13.5, 0, 13.5, 0);
    layout.minimumInteritemSpacing = 13.5;
    self.contentCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 20, 20) collectionViewLayout:layout];
    self.contentCollectionView.backgroundColor = [UIColor whiteColor];
    [self.view insertSubview:self.contentCollectionView belowSubview:self.searchListTableView];
    self.contentCollectionView.delegate = self;
    self.contentCollectionView.dataSource = self;
    [self.contentCollectionView registerNib:[UINib nibWithNibName:@"SOSAroundSearchCell" bundle:nil] forCellWithReuseIdentifier:@"SOSAroundSearchCell"];
}

- (void)reloadData    {
    self.dataSourceArray = [NSMutableArray arrayWithObjects:@{@"附近经销商": @"icon_dealer"}, nil];
    if ([Util vehicleIsPHEV])  {
        [self.dataSourceArray addObjectsFromArray:@[@{@"附近加油站": @"icon_travel"}, @{@"附近充电站": @"icon_ electricity"}]];
    }   else if ([Util vehicleIsEV] || [Util vehicleIsBEV])  {
        [self.dataSourceArray addObject:@{@"附近充电站": @"icon_ electricity"}];
    }   else    [self.dataSourceArray addObject:@{@"附近加油站": @"icon_travel"}];
    [self.contentCollectionView reloadData];
    
    [self.contentCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.searchListTableView.top);
        make.bottom.mas_equalTo(self.view.bottom);
        
        make.left.mas_offset((SCREEN_WIDTH - self.dataSourceArray.count * 87) / 2);
        make.width.mas_offset(self.dataSourceArray.count * 87);
    }];
}

#pragma mark - CollectionView  Delegate && DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section    {
    return self.dataSourceArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath     {
    SOSAroundSearchCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SOSAroundSearchCell" forIndexPath:indexPath];
    NSDictionary *valueDic = self.dataSourceArray[indexPath.row];
    cell.titleString = valueDic.allKeys[0];
    cell.imgName = valueDic.allValues[0];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath     {
    SOSAroundSearchCell *cell = (SOSAroundSearchCell *)[collectionView cellForItemAtIndexPath:indexPath];
    /** 附近经销商 */
    if (indexPath.row == 0)   {
        [self enterDealerListVC];
    /** 附近加油站 */
    }   else if ([cell.titleString isEqualToString:@"附近加油站"])   {
        [self enterOliListVC];
    /** 附近充电站 */
    }   else if ([cell.titleString isEqualToString:@"附近充电站"])   {
        [self enterChargeListVC];
    }
}

#pragma mark - TableVIew Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section    {
    ///搜索联想提示
    return associateDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ///搜索联想提示
    return KAssociateCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath	{
    return [self getAssociateCellInTableView:tableView ByIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath		{
    AssociateCell *cell = (AssociateCell *)[tableView dequeueReusableCellWithIdentifier:@"AssociateCell"];
    [self handleAssociateCellSelect:cell AtIndexPath:indexPath];
}

- (void)enterDealerListVC    {
    [SOSDaapManager sendActionInfo:Trip_GoWhere_POIdetail_SearchAround_AroundDealer];
    [SOSDealerTool jumpToDealerListMapVCFromVC:self WithPOI:self.selectedPoi isFromTripPage:YES];
}

- (void)enterOliListVC        {
    [SOSDaapManager sendActionInfo:Trip_GoWhere_POIdetail_SearchAround_AroundGasStation];
    [SOSNavigateTool showAroundOilStationWithCenterPOI:self.selectedPoi FromVC:self];
}

- (void)enterChargeListVC    {
    [SOSDaapManager sendActionInfo:Trip_GoWhere_POIdetail_SearchAround_AroundChargeStation];
    [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:self withLoginDependence:[[LoginManage sharedInstance] isLoadingUserBasicInfoReady] showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
        SOSTripChargeVC *chargeStationVC = [[SOSTripChargeVC alloc] initWithPOI:self.selectedPoi];
        chargeStationVC.mapType = MapTypeShowChargeStation;
        [self.navigationController pushViewController:chargeStationVC animated:YES];
    }];
}

- (IBAction)searchButtonTapped {
    [SOSDaapManager sendActionInfo:Trip_GoWhere_POIdetail_SearchAround_Search];
    NSString *keyWords = self.fieldSearch.text;
    if ([keyWords containsString:@"充电"] && ([Util vehicleIsPHEV] || [Util vehicleIsBEV])) {
        [self enterChargeListVC];
    }    else if ([keyWords containsString:@"4S店"])        {
        [self enterChargeListVC];
    }    else if ([keyWords containsString:@"经销商"])        {
        [self enterDealerListVC];
    }    else if ([keyWords containsString:@"加油"])        {
        [self enterOliListVC];
    }    else    {
        [Util showHUD];
        [[SOSAMapSearchTool sharedInstance] aroungSearchWithKeyWords:keyWords CenterPOI:self.selectedPoi PageNum:0 Success:^(NSArray<SOSPOI *> * _Nonnull poiArray) {
            [Util dismissHUD];
            SOSTripPOIVC *vc = [[SOSTripPOIVC alloc] initWithPOI:self.selectedPoi];
            vc.poiArray = poiArray;
            vc.mapTypeBeforChange = MapTypeShowPoiPointFromList;
            vc.mapType = MapTypeShowPoiList;
            vc.isFromAroundSearch = YES;
            [self.navigationController pushViewController:vc animated:YES];
        } Failure:^{
            [Util dismissHUD];
            [Util toastWithMessage:@"暂无搜索结果"];
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField    {
    if (textField.text.length) {
        [self searchButtonTapped];
        return YES;
    }
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
