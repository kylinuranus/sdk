//
//  SOSNearByController.m
//  Onstar
//
//  Created by WQ on 2018/7/5.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSNearByController.h"
#import "SOSPOIMapVC.h"
#import "SOSUserLocation.h"
#import "SOSNearBycell.h"
@interface SOSNearByController ()<UITableViewDelegate,UITableViewDataSource>        {
    NSMutableArray<NSArray<NearByDealerModel *> *> *datas;
    BOOL hasRec;
    BOOL hasNear;
}

@end

@implementation SOSNearByController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!_dTable) {
        _dTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _dTable.delegate = self;
        _dTable.dataSource = self;
        [self.view addSubview:_dTable];
        [_dTable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
    }
    if (!datas) {
        datas = [NSMutableArray array];
    }
}

- (void)getNearByList:(SOSPOI*)location       {
    [Util showHUD];
    @weakify(self)
    NSString *url = [Util getConfigureURL];
    NSString *vin = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin ? [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin : @"";
    NSString *brand = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.brand ? [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.brand : @"ALL";
    NSLog(@"vin is  %@",[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin);
    NSLog(@"brand is  %@",[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.brand);
    url = [url stringByAppendingFormat:DEALER_NEARBY_LIST];
    NSDictionary *d = @{ @"dealerBrand":brand,
                        @"dealerType":@"AFTER_SALE",
                        @"vin":vin,
                        @"longitude":location.longitude,
                        @"latitude":location.latitude};
    NSString *s = [Util jsonFromDict:d];
    SOSNetworkOperation* sosOperation = [SOSNetworkOperation requestWithURL:url params:s successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        [Util dismissHUD];
        @strongify(self)
        [self nearByListSuccess:responseStr];
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util dismissHUD];
        [Util toastWithMessage:@"获取经销商列表失败"];
    }];
    [sosOperation setHttpMethod:@"POST"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];

}


- (void)nearByListSuccess:(NSString*)str       {
    [datas removeAllObjects];
    hasRec = NO;
    hasNear = NO;
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if (jsonResponse) {
        NearByDealerList *m = [NearByDealerList mj_objectWithKeyValues:jsonResponse];
        if (m.recommendDealer.count > 0) {
            [datas addObject:m.recommendDealer];
            hasRec = YES;
        }
        if (m.nearbyDealer.count > 0) {
            [datas addObject:m.nearbyDealer];
            hasNear = YES;
        }
        [self.dTable reloadData];
    }
}

- (void)pushMapVc:(NNDealers *)dealers{
    [SOSDaapManager sendActionInfo:Prfdealer_address];
    SOSPOIMapVC *indexVC = [[SOSPOIMapVC alloc] initWithPoiInfo:dealers.poi];
    indexVC.backDaapFunctionID = Dealeraptmt_Map_back;
    indexVC.dealer = dealers;
    indexVC.mapType = MapTypeShowDealerPOI;
    [CustomerInfo sharedInstance].isInDelear = YES;
    [self.navigationController pushViewController:indexVC animated:YES];
}


#pragma mark uitableView delegate----------------

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 24.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 130;
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *v = [UIView new];
    v.backgroundColor = [UIColor Gray246];

    UILabel *lb = [UILabel new];
    [v addSubview:lb];
    [lb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(v.mas_left).offset(10);
        make.centerY.equalTo(v.mas_centerY);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(14);
    }];
    lb.font = [UIFont systemFontOfSize:12];
    lb.textColor = [UIColor Gray185];
    if (hasRec) {
        lb.text = section == 0 ? @"推荐" : @"附近";
    }else
    {
        lb.text = @"附近";
    }
    return v;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return datas ? datas.count : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (datas) {
        NSArray *arr = [datas objectAtIndex:section];
        return arr.count;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SOSNearBycell * cell = [tableView dequeueReusableCellWithIdentifier:@"NearBycell"];
    if (!cell) {
        cell = [[SOSNearBycell alloc] initWithStyle:0 reuseIdentifier:@"NearBycell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
//    cell.textLabel.text = datas[indexPath.section][indexPath.row].dealerName;
    [cell fillCellData:datas[indexPath.section][indexPath.row]];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NearByDealerModel *m = datas[indexPath.section][indexPath.row];
    NNDealers *dealer = [NNDealers new];
    dealer.isPreferredDealer = 0;
    dealer.distanceWithUnit = m.distanceWithUnit;
    dealer.dealersid = m.dealerId;
    dealer.dealerName = m.dealerName;
    dealer.telephone = m.telephone;
    dealer.locationCoordinate = [NNCenterPoiCoordinate coordinateWithLongitude:m.longitude AndLatitude:m.latitude];
    dealer.dealerCode = m.dealerCode;
    dealer.cityCode = m.cityCode;
    dealer.address = m.address;
    dealer.distance = [m.distance integerValue];
    [self pushMapVc:dealer];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{ return 1;}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    view.backgroundColor = [UIColor Gray246];
    return view;
}

@end
