//
//  SOSBleUserCarListViewController.m
//  Onstar
//
//  Created by onstar on 2018/7/26.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSBleUserCarListViewController.h"
#import "SOSBleUserReceiveShareViewController.h"
#import <BlePatacSDK/DBManager.h>
#import <BlePatacSDK/BLEModel.h>
#import <BlePatacSDK/BlueToothManager.h>
#import "UIView+Toast.h"
#import "SOSBleKeyCarCell.h"
#import "SOSBleUserCarOperationViewController.h"
#import "BlueToothManager+SOSBleExtention.h"
#import "UIView+SOSBleToast.h"
#import "TLSOSRefreshHeader.h"
#import "SOSCustomAlertView.h"
#import "SOSCardUtil.h"
#import "SOSBleUtil.h"
#import "SOSBleKeyCarBottomView.h"
#import "SOSBleSearchAlertViewController.h"

@interface SOSBleUserCarListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, copy) NSArray *dataSource;
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation SOSBleUserCarListViewController
//{
//    NSDate *refreshDate;
//}
//
//
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    NSTimeInterval gapTime = [[NSDate date] timeIntervalSinceDate:refreshDate];
//    if (!refreshDate || gapTime > 30) {
//        BlueToothState state = [[BlueToothManager sharedInstance] getCenterManagerState];
//        if (state == BlueToothStatePoweredOn) {
    NSArray *keys = [[DBManager sharedInstance] GetSomeKeyInDB:INT_MAX];
    if (keys.count) {
        [self.tableView.mj_header beginRefreshing];
    }
//    else {
//        [self showSearchFailureAlert];
//    }
    
//            refreshDate = [NSDate date];
//        }
//    }


}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [SOSBleUtil test1];
    self.title = @"蓝牙钥匙";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"收到的共享" style:UIBarButtonItemStylePlain target:self action:@selector(gotoUserReceivePage)];
    [self configUI];
    [self initBleSDK];
    [SOSDaapManager sendActionInfo:SmartVehicle_BLE_Keyentry_Search];
}

- (void)configUI {
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerNib:[UINib nibWithNibName:SOSBleKeyCarCell.className bundle:nil] forCellReuseIdentifier:SOSBleKeyCarCell.className];
    
    SOSBleKeyCarBottomView *bottomView = [SOSBleKeyCarBottomView viewFromXib];
    @weakify(self)
    bottomView.searchButtonClick = ^{
       @strongify(self)
        [self.tableView.mj_header beginRefreshing];
        [SOSDaapManager sendActionInfo:BLEUser_Search_Clicksearch];
    };
    
    bottomView.textButtonClick = ^{
        @strongify(self)
        //        [self gotoBleOperationPage];
        SOSBleSearchAlertViewController *alert = [[SOSBleSearchAlertViewController alloc] initWithNibName:@"SOSBleSearchAlertViewController" bundle:nil];
        
        alert.modalPresentationStyle = UIModalPresentationOverCurrentContext|UIModalPresentationFullScreen;
        [self.navigationController presentViewController:alert animated:NO completion:nil];
        
         [SOSDaapManager sendActionInfo:BLEUser_Search_FAQ];
        
    };
    [self.view addSubview:bottomView];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.height.mas_equalTo(160 + self.view.sos_safeAreaInsets.bottom);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.view);
        make.bottom.mas_equalTo(bottomView.mas_top);
    }];

    self.tableView.mj_header = [TLSOSRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self)
        dispatch_async_on_main_queue(^{
            [self scanDevice];
             [SOSDaapManager sendActionInfo:BLEUser_Search_dropdownsearch];
        });
    }];
}

- (void)initBleSDK {
    NSLog(@"version:%@",[BlueToothManager GetSDKVersion]);
//    _dataSource = @[].mutableCopy;
//    manager = [BlueToothManager sharedInstance];
//    NSArray *keys = [[DBManager sharedInstance] GetSomeKeyInDB:INT_MAX];
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:CBManagerState_Notification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSLog(@"%@",x);
        @strongify(self)
        //蓝牙状态改变,刷新Cell
        if (BlueToothStatePoweredOn == [[x.userInfo objectForKey:CBManagerState_KEY] integerValue]) {
            //刷新ing
            [self.tableView.mj_header beginRefreshing];
        }else {
            //刷新 NO连接状态
            self.dataSource = @[];
            [self.tableView reloadData];
            [self showOpenBlueToolsAlert];
        }
    }];
    
    [RACObserve([BlueToothManager sharedInstance], bleSearchDeviceStatus) subscribeNext:^(NSNumber*  _Nullable x) {
        @strongify(self)
        if (x.integerValue == SOSBleSearchDeviceStatusNormal) {
            if (self.tableView.mj_header.isRefreshing) {
                [self.tableView.mj_header endRefreshing];
                if (!self.dataSource.count) {
                    [self showSearchFailureAlert];
                }
            }
            
        }
    }];
    
    [RACObserve([BlueToothManager sharedInstance], bleScanDevices) subscribeNext:^(NSArray*  _Nullable x) {
        @strongify(self)
        self.dataSource = [self matchLocalKeysWith:x];
        [self.tableView reloadData];
    }];
    
    BlueToothState state = [[BlueToothManager sharedInstance] getCenterManagerState];
    if (state == BlueToothStatePoweredOff){
        [self showOpenBlueToolsAlert];
        [BlueToothManager sharedInstance].bleScanDevices = @[];
    }
}

- (void)showSearchFailureAlert {
    SOSBleSearchAlertViewController *alert = [[SOSBleSearchAlertViewController alloc] initWithNibName:@"SOSBleSearchAlertViewController" bundle:nil];
    alert.modalPresentationStyle = UIModalPresentationOverCurrentContext|UIModalPresentationFullScreen;
    [self presentViewController:alert animated:NO completion:nil];
}

- (void)showOpenBlueToolsAlert {
    SOSCustomAlertView *alert = [[SOSCustomAlertView alloc] initWithTitle:@"蓝牙未开启" detailText:@"您的蓝牙功能未开启,暂无法使用该功能" cancelButtonTitle:@"知道了" otherButtonTitles:nil];
    alert.pageModel = SOSAlertViewModelContent;
    alert.buttonMode = SOSAlertButtonModelVertical;
    alert.backgroundModel = SOSAlertBackGroundModelStreak;
    [alert show];
}

- (void)gotoUserReceivePage {
    [SOSDaapManager sendActionInfo:BLEUser_Search_Carsharing];
   
    @weakify(self)
    [[LoginManage sharedInstance] checkAndShowLoginViewWithFromViewCtr:self andTobePushViewCtr:nil completion:^(BOOL finished){
        @strongify(self)
        if(finished){
            SOSBleUserReceiveShareViewController *vc = [SOSBleUserReceiveShareViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
    
    
}

- (NSArray *)matchLocalKeysWith:(NSArray <BLEModel *>*)bleModelArray {
    //test code
//    return bleModelArray;
    
    
    NSMutableArray *matchKeys = @[].mutableCopy;
    for (BLEModel *bleModel in bleModelArray) {
        //搜到设备同时在本地找钥匙
        NSArray<Keyinfo *> *keys = [[DBManager sharedInstance] GetSomeKeyInDB:INT_MAX];
        NSString *vinLastSix = [bleModel.BleName stringByReplacingOccurrencesOfString:@"SGM " withString:@""];
        for (Keyinfo *keyInfo in keys) {
            if ([keyInfo.vin hasSuffix:vinLastSix]) {
                [matchKeys addObject:bleModel];
                break;
            }
        }
    }
    return matchKeys.copy;
}

- (void)scanDevice {
    [[BlueToothManager sharedInstance] scanDevice];
}


//用车
- (void)gotoBleOperationPage {
    SOSBleUserCarOperationViewController *opVc = [[SOSBleUserCarOperationViewController alloc] initWithNibName:SOSBleUserCarOperationViewController.className bundle:nil];
    [self.navigationController pushViewController:opVc animated:YES];
}


//连接
- (void)connectedWith:(BLEModel *)bleModel isLostConnect:(BOOL)lostConnect sender:(UIButton *)sender {
    UIView *alert = [self.view showBleAlertWithMessage:@"正在连接,请稍后..."];
    if (!bleModel.bConnectStatus) {
        [sender setTitle:@"正在连接..." forState:UIControlStateNormal];
        sender.backgroundColor = [SOSUtil onstarButtonDisableColor];
    }
//    if (lostConnect) {
//        CBCentralManager *m = [[BlueToothManager sharedInstance] iniCenterManager];
//        [m connectPeripheral:bleModel.peripheral options:nil];
//        return;
//    }
//    
    @weakify(self)
    [[BlueToothManager sharedInstance] connectedWith:bleModel result:^(BlueToothConnState result, CBPeripheral *peripheral, NSError *error) {
        @strongify(self)
        [self.view hideBleAlert:alert];
        switch (result) {
            case BlueToothConnStateDisconnect:
                bleModel.bConnectStatus = NO;
                [self.tableView reloadData];
                [self showConnectFaildAlertWithModel:bleModel isLostConnect:NO sender:sender];
                break;
            case BlueToothConnStateLostconnect:
                bleModel.bConnectStatus = NO;
                [self.tableView reloadData];
                [self showConnectFaildAlertWithModel:bleModel isLostConnect:YES sender:sender];
                break;
            case BlueToothConnAuthenticationOK:

                bleModel.bConnectStatus = YES;
                [self.tableView reloadData];
                break;
            default:
                break;
        }
    }];
    
}

- (void)showConnectFaildAlertWithModel:(BLEModel *)bleModel
                         isLostConnect:(BOOL)lostConnect
                                sender:(UIButton *)sender
{
    UINavigationController *navVC = [SOS_APP_DELEGATE fetchMainNavigationController];
    if ([navVC.topViewController isKindOfClass:[SOSBleUserCarOperationViewController class]])     return;
    NSString *msg ;
    NSString *btnTitle;
    NSString *title;
    if (lostConnect) {
        title = @"提示";
        msg = @"您的设备已经断开连接，是否需要重新连接";
        btnTitle = @"重新连接";
    }else {
        title = @"连接失败";
        msg = @"请确认车辆在您附近\n手机蓝牙设备工作正常\n车主是否已经取消此共享";
        btnTitle = @"再试一次";
    }
    SOSCustomAlertView *alert = [[SOSCustomAlertView alloc] initWithTitle:title detailText:msg cancelButtonTitle:@"取消" otherButtonTitles:@[btnTitle]];
    alert.pageModel = SOSAlertViewModelContent;
    alert.buttonMode = SOSAlertButtonModelHorizontal;
    alert.backgroundModel = SOSAlertBackGroundModelStreak;
    @weakify(self)
    alert.buttonClickHandle = ^(NSInteger clickIndex) {
        @strongify(self)
        if (clickIndex == 1) {
            [self connectedWith:bleModel
                  isLostConnect:lostConnect
                         sender:sender];
        }
    };
    [alert show];
    
}

-(void)cannelConnectSuccess:(void(^)(void))successBlock
{
    
    [SOSDaapManager sendActionInfo:BLEUser_Search_Connect];
    if (![BlueToothManager sharedInstance].peripheral ||[BlueToothManager sharedInstance].peripheral.state == CBPeripheralStateDisconnected) {
        !successBlock?:successBlock();
        return;
    }
    @weakify(self)
    [[BlueToothManager sharedInstance] cannelWithPeripheral:[BlueToothManager sharedInstance].peripheral block:^(CBPeripheral *peripheral) {
        NSLog(@"xxxxx");
        @strongify(self)
        for (BLEModel *model in self.dataSource) {
            model.bConnectStatus = NO;
        }
        [self.tableView reloadData];
        !successBlock?:successBlock();
        
    }];
}

#pragma mark tableview

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BLEModel *model = self.dataSource[indexPath.row];
    SOSBleKeyCarCell *cell = [tableView dequeueReusableCellWithIdentifier:SOSBleKeyCarCell.className forIndexPath:indexPath];
    cell.bleEntity = model;
    @weakify(self)
    cell.operationButtonTapBlock = ^(UIButton *sender) {
        @strongify(self)
        model.bConnectStatus?[self gotoBleOperationPage]:[self cannelConnectSuccess:^{
            [self connectedWith:model isLostConnect:NO sender:sender];
        }];
       
    };
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    NSLog(@"xxx");
}

@end
