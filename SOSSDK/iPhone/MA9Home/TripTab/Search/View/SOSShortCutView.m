//
//  SOSShortCutView.m
//  Onstar
//
//  Created by Genie Sun on 2017/8/10.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "NavigteSearchHeaderIconCell.h"
#import "SOSHomeAndCompanyTool.h"
#import "SOSShortCutView.h"
#import "SOSNavigateTool.h"
#import "SOSTripChargeVC.h"
#import "SOSDealerTool.h"
#import "SOSRemoteTool.h"

@implementation SOSShortCutView

- (void)awakeFromNib    {
    [super awakeFromNib];
    [self initShortcutTable];
    _shortCutArray = [[NSMutableArray alloc] init];
    _shortCutImageArray = [[NSMutableArray alloc] init];
    
    [_shortCutArray addObjectsFromArray: @[@"一键到家",@"一键到公司",@"附近经销商"]];
    [_shortCutImageArray addObjectsFromArray:@[@"icon_travel_search_home",@"icon_bag",@"icon_dealer"]];
    if ([Util vehicleIsPHEV])     {
        [_shortCutArray addObjectsFromArray:@[@"附近加油站",@"附近充电站"]];
        [_shortCutImageArray addObjectsFromArray:@[@"icon_travel",@"icon_ electricity"]];
    }   else if ([Util vehicleIsEV] || [Util vehicleIsBEV]) {
        [_shortCutArray addObject:@"附近充电站"];
        [_shortCutImageArray addObject:@"icon_ electricity"];
    }  else    {
        [_shortCutArray addObject:@"附近加油站"];
        [_shortCutImageArray addObject:@"icon_travel"];
    }
}

- (void)initShortcutTable     {
    if (!_shortCutTable) {
        _shortCutTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.height, SCREEN_WIDTH) style:UITableViewStylePlain];
        _shortCutTable.center = CGPointMake(SCREEN_WIDTH/2.0, self.height/2.0);
        _shortCutTable.delegate = self;
        _shortCutTable.dataSource = self;
        self.shortCutTable.showsVerticalScrollIndicator = NO;
        _shortCutTable.transform = CGAffineTransformMakeRotation(-M_PI_2);
        _shortCutTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _shortCutTable.contentInset = UIEdgeInsetsMake(0, 0, 1, 0);
        [self addSubview:self.shortCutTable];
        self.shortCutTable.bounces = NO;
        self.shortCutTable.backgroundColor = [UIColor whiteColor];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _shortCutArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.width / _shortCutArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NavigteSearchHeaderIconCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NavigteSearchHeaderIconCell"];
    if (!cell) {
        cell = [[NSBundle SOSBundle] loadNibNamed:@"NavigteSearchHeaderIconCell" owner:self options:nil][0];
    }
    cell.transform = CGAffineTransformMakeRotation(M_PI_2);
    cell.icon.image = [UIImage imageNamed:_shortCutImageArray[indexPath.row]];
    cell.title.text = _shortCutArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NavigteSearchHeaderIconCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //一键到家
    if (indexPath.row == 0) {
        [SOSDaapManager sendActionInfo:Trip_GoWhere_ToHome];
        [self easyBackHomeWithType:pageTypeEasyBackHome];
        //一键到公司
    } else if (indexPath.row == 1)	{
        [SOSDaapManager sendActionInfo:Trip_GoWhere_ToOffice];
        [self easyBackHomeWithType:pageTypeEasyBackCompany];
        //经销商
    }   else if (indexPath.row == 2)   {
        [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundDealer];
        [SOSDealerTool jumpToDealerListMapVCFromVC:self.viewController WithPOI:self.selectPOI isFromTripPage:YES];
    }   else if ([cell.title.text isEqualToString:@"附近加油站"])   {
        [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundGasStation];
        [SOSNavigateTool showAroundOilStationWithCenterPOI:self.selectPOI FromVC:self.viewController];
    }   else if ([cell.title.text isEqualToString:@"附近充电站"]) {
        [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundChargeStation];
        [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:self.viewController withLoginDependence:[[LoginManage sharedInstance] isLoadingUserBasicInfoReady] showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
            SOSTripChargeVC *chargeStationVC = [[SOSTripChargeVC alloc] init];
            chargeStationVC.mapType = MapTypeShowChargeStation;
            [self.viewController.navigationController pushViewController:chargeStationVC animated:YES];
        }];
    }
}

- (void)easyBackHomeWithType:(SetHomeAddress_PageType)pageType	{
    [[SOSHomeAndCompanyTool sharedInstance] checkAuthAndExitsWithType:pageType FromVC:self.viewController Success:^(SOSPOI *resultPOI) {
        if (resultPOI) {
            [self.viewController.navigationController popToRootViewControllerAnimated:YES];
            [[SOSRemoteTool sharedInstance] sendToCarWithOperationType:SOSRemoteOperationType_SendPOI_Auto AndPOI:resultPOI];
        }   else    {
            [Util showAlertWithTitle:@"地点未设置，现在去设置吗？" message:nil completeBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 1)     {
                    [SOSDaapManager sendActionInfo:TRIP_NAVIGATIONFAIL_SET];
                    [[SOSHomeAndCompanyTool sharedInstance] jumpToSetHomeAddressPageWithType:pageType];
                }    else    {
                    [SOSDaapManager sendActionInfo:TRIP_NAVIGATIONFAIL_NO];
                }
            } cancleButtonTitle:@"不了" otherButtonTitles:@"去设置", nil];
        }
    } Failure:nil];
}


@end
