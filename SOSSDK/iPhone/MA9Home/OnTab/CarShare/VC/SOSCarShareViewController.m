//
//  SOSCarShareViewController.m
//  Onstar
//
//  Created by onstar on 2019/1/4.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSCarShareViewController.h"
#if __has_include(<BlePatacSDK/BlueToothManager.h>)
#import "SOSBleKeyCell.h"
#import "BlueToothManager+SOSBleExtention.h"
#endif
#import "SOSCardUtil.h"
#import "TLSOSRefreshHeader.h"
#import "RemoteControlSharingViewController.h"

@interface SOSCarShareViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) id scanBleDevices;

@end

@implementation SOSCarShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self initBleState];
}

- (void)initViews {
    self.title = @"车辆共享中心";
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    self.tableView.tableFooterView = [UIView new];
    #if __has_include(<BlePatacSDK/BlueToothManager.h>)
    @weakify(self)
    self.tableView.mj_header = [TLSOSRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self)
        //下拉刷新重新搜索蓝牙
        BlueToothState state = [[BlueToothManager sharedInstance] getCenterManagerState];
        if (state == BlueToothStatePoweredOn) {
            [self searchBleCar];
        }
    }];
    [self.tableView.mj_header beginRefreshing];
    
    [self.tableView registerClass:[SOSBleKeyCell class] forCellReuseIdentifier:SOSBleKeyCell.className];
    
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
        self.tableView.fillerRowHeight=UITableViewCellSeparatorStyleSingleLine;
    }
    #endif
}

#pragma mark getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

#pragma mark tableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellId"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UIView *bottomLine = [UIView new];
            bottomLine.backgroundColor = UIColorHex(#F3F5FE);
            [cell.contentView addSubview:bottomLine];
            [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.mas_equalTo(cell.contentView);
                make.height.mas_equalTo(1);
            }];
        }
        cell.textLabel.textColor = UIColorHex(#28292F);
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.detailTextLabel.textColor = UIColorHex(#828389);
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        
        if (indexPath.row == 0) {
            cell.imageView.image = [UIImage imageNamed:@"icon-11"];
            cell.textLabel.text = @"远程遥控共享管理";
            cell.detailTextLabel.text = @"让朋友通过“远程遥控”来使用我的车";
        }else {
            cell.imageView.image = [UIImage imageNamed:@"icon-10"];
            cell.textLabel.text = @"蓝牙钥匙共享管理";
            cell.detailTextLabel.text = @"让朋友通过“蓝牙钥匙”来使用我的车";
        }
        return cell;
    }
    #if __has_include(<BlePatacSDK/BlueToothManager.h>)
    SOSBleKeyCell *cell = [tableView dequeueReusableCellWithIdentifier:SOSBleKeyCell.className forIndexPath:indexPath];
    [cell refreshWithResp:self.scanBleDevices];
    cell.reConnectBlock = ^(BLEModel *bleModel) {
        [SOSCardUtil routerToBleOperationPageWithBleModel:bleModel];
    };
    return cell;
    #else
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    return cell;
    #endif
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (SOS_CD_PRODUCT) {
            return 1;
        }
        return 2;
    }
    if (SOS_CD_PRODUCT) {
        return 0;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            if ([SOSCheckRoleUtil isDriverOrProxy]) {
                return 0;
            }
            return 80;
        }else {
            if ([SOSCheckRoleUtil isDriverOrProxy] || ![CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.ble || SOS_CD_PRODUCT) {
                return 0;
            }
            return 80;
        }
        
    }
    
    return SOS_CD_PRODUCT ? 0 : (112+50);
//    return (50+10+ (SCREEN_WIDTH-20)/71*28);;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerContentView = [UIView new];
    headerContentView.backgroundColor = UIColorHex(#F3F5FE);
    UIView *header = [UIView new];
    header.backgroundColor = UIColor.whiteColor;
    [headerContentView addSubview:header];
    [header mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(34);
        make.left.right.bottom.mas_equalTo(headerContentView);
    }];
    UIView *leftLine = [UIView new];
    leftLine.backgroundColor = UIColorHex(#6896ED);
    [header addSubview:leftLine];
    
    UIView *bottomLine = [UIView new];
    bottomLine.backgroundColor = UIColorHex(#F3F5FE);
    [header addSubview:bottomLine];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.textColor = UIColorHex(#6896ED);;
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [header addSubview:titleLabel];
    
    [leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.mas_equalTo(header);
        make.height.mas_equalTo(16);
        make.width.mas_equalTo(4);
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(header).offset(12);
        make.centerY.mas_equalTo(header);
    }];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.bottom.right.left.mas_equalTo(header);
    }];
    if (section == 0) {
        titleLabel.text = @"共享我的车";
    }else {
        titleLabel.text = @"我收到的蓝牙钥匙共享";
    }
    return headerContentView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if ([SOSCheckRoleUtil isDriverOrProxy]) {
            return 0;
        }
    }
    if (SOS_CD_PRODUCT) {
        return 0;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            //车分享
            [self remoteControlShare];
        }else {
            //共享我的车
            [SOSCardUtil routerToOwnerBle];
            [SOSDaapManager sendActionInfo:SmartVehicle_BLE_Carsharingentry];
            [SOSDaapManager sendActionInfo:SMARTVEHICLE_BLE_KEYENTRY];
        }
    }else {
#if __has_include(<BlePatacSDK/BlueToothManager.h>)
        [SOSDaapManager sendActionInfo:SMARTVEHICLE_BLE_CARSHARINGENTRY];

        //蓝牙钥匙
        if ([[BlueToothManager sharedInstance] isConnected]) {
            [SOSCardUtil gotoBleOperationPage];
        }else {
            [SOSDaapManager sendActionInfo:SmartVehicle_BLE_Keyentry];
            
            [SOSCardUtil routerToBleKeyPage];
        }
#endif
    }
}


#pragma mark actions
// 车分享
- (void)remoteControlShare {
    [SOSDaapManager sendActionInfo:REMOTECONTROL_CARSHARE];
    RemoteControlSharingViewController * controlShare = [[RemoteControlSharingViewController alloc] initWithNibName:@"RemoteControlSharingViewController" bundle:nil];

    [SOSCardUtil routerToVc:controlShare checkAuth:YES checkLogin:YES];
}


#pragma mark BLE
- (void)initBleState {
    #if __has_include(<BlePatacSDK/BlueToothManager.h>)
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:CBManagerState_Notification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSLog(@"%@",x);
        @strongify(self)
        //蓝牙状态改变,刷新Cell
        if (BlueToothStatePoweredOn == [[x.userInfo objectForKey:CBManagerState_KEY] integerValue]) {
            //刷新ing
            [self searchBleCar];
        }else {
            //刷新 NO连接状态
            self.scanBleDevices = @[];
        }
    }];
    
    
    BlueToothManager *manager =[BlueToothManager sharedInstance];
    [RACObserve(manager, bleSearchDeviceStatus) subscribeNext:^(NSNumber*  _Nullable x) {
        @strongify(self)
        if (x.integerValue == SOSBleSearchDeviceStatusNormal) {
            self.scanBleDevices = manager.bleScanDevices;
            [self.tableView.mj_header endRefreshing];
        }else if (x.integerValue == SOSBleSearchDeviceStatusSearching) {
            self.scanBleDevices = @YES;
        }
    }];
    [RACObserve(manager, bleConnectStatus) subscribeNext:^(NSNumber*  _Nullable x) {
        @strongify(self)
        //刷新cell
        dispatch_async_on_main_queue(^{
            self.scanBleDevices = @[];
        });
    }];
    [RACObserve(self, scanBleDevices) subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        dispatch_async_on_main_queue(^{
            [self.tableView reloadData];
        });
    }];
#endif
}
- (void)searchBleCar {
#if __has_include(<BlePatacSDK/BlueToothManager.h>)
    BlueToothManager *manager =[BlueToothManager sharedInstance];
    [manager scanDevice];
#endif
}


@end
