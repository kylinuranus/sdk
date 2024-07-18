//
//  SOSVehicleInfoViewController.m
//  Onstar
//
//  Created by Genie Sun on 2017/7/31.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSVehicleInfoViewController.h"
#import "SOSCarLogoTableViewCell.h"
#import "SOSInfoTableViewCell.h"
#import "SOSOperationHistoryViewController.h"
#import "SOSChangeVehicleViewController.h"
#import "DatePickerView.h"
#import "CustomCover.h"
#import "SOSCheckRoleUtil.h"
#import "PushNotificationManager.h"
#import "NSString+JWT.h"
#import "UserCarInfoVC.h"
#import "ChargeModeViewController.h"
#import "SOSInsuranceViewController.h"
#import "SOSCheckRoleUtil.h"
#import "SOSHeadInfoView.h"
#import "SOSGreetingManager.h"
#import "VehicleInfoUtil.h"
#import "ServiceController.h"
#import "SOSCardUtil.h"
#import "SOSFlexibleAlertController.h"
#import "SOSVehicleSettingCalendarView.h"
#import "SOSDateFormatter.h"

@interface SOSVehicleInfoViewController ()<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, SOSCarLogoTableViewCellDelegate>
{
    UIImageView *logoView;
    UILabel *titleLabel;
//    __weak IBOutlet UIButton *changeCar;
}
//@property (weak, nonatomic) IBOutlet SOSHeadInfoView *headInfoView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NNVehicleInfoModel *vehicleInfo;
//@property (nonatomic, retain) CustomCover *cover;
@property (nonatomic, assign) NSInteger dateIndex;//1:交强险, 2:商业险
//@property (nonatomic, retain) DatePickerView *datePickerView;

@end

@implementation SOSVehicleInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initNavigationItemView];
    self.backRecordFunctionID = Vehicleinfo_back;
    _dataArray = [NSMutableArray array];
    //初始化数据
    [self initDataArray];
    [self loadVehicleInfo];
    //初始化日期选择
//    [self initDatePickerView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadVehicleInfo) name:SOS_ACCOUNT_VEHICLE_HAS_CHANGED object:Nil];
//    [self refreshHeadInfo];
    [self queryARAviable];
    self.tableView.backgroundColor = SOSUtil.onstarLightGray;
    self.tableView.separatorColor = UIColorHex(#F3F3F4);
}

- (void)queryARAviable    {
    SOS_APP_DELEGATE.isStartMonitor = YES;
    [[CustomerInfo sharedInstance].servicesInfo getResponseFromSeriverComplete:^{
        [self initDataArray];
        [self.tableView reloadData];
    }];
}

//- (void)refreshHeadInfo {
//
//    @weakify(self);
//    [RACObserve([SOSGreetingManager shareInstance], roleGreeting) subscribeNext:^(id x) {
//        @strongify(self);
//        if ([SOSCheckRoleUtil isOwner] || [SOSCheckRoleUtil isDriverOrProxy]) {
//            if ([x isKindOfClass:[NSDictionary class]] ) {
//                [self refreshWithStatus:RefreshData_success];
//            }else if(([x isEqual:@NO]) ) {
//                [self refreshWithStatus:RefreshData_fail];
//            }else {
//                [self refreshWithStatus:RefreshData_progress];
//            }
//        }else {
//            [self refreshWithStatus:RefreshData_fail];
//        }
//    }];
//}
//- (void)refreshWithStatus:(RefreshDataStatus)status {
//    dispatch_async(dispatch_get_main_queue(), ^{
//    switch (status) {
//        case RefreshData_success:
//        case RefreshData_fail:
//        {
//            SOSGreetingModel *model = [[SOSGreetingManager shareInstance] getGreetingModelWithType:SOSGreetingTypeVehicleInfo];
//            self.headInfoView.title.text = model.greetings;
//            self.headInfoView.infoLb.text = [model.subGreetings stringByReplacingOccurrencesOfString:@"#VEHICLEMODEL#" withString:[[CustomerInfo sharedInstance] currentVehicle].modelDesc?:@""];
//
//        }
//            break;
//
//        case RefreshData_progress:
//            self.headInfoView.title.text = @"读取中...";
//            self.headInfoView.infoLb.text = @"读取中...";
//            self.headInfoView.btn.hidden = YES;
//            break;
//        default:
//            break;
//    }
//
//    [self.headInfoView.btn setTitle:@"切换车辆" forState:UIControlStateNormal];
//    self.headInfoView.btn.hidden = NO;
//    @weakify(self)
//    [self.headInfoView.btn setBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
//        @strongify(self)
//        [self pushChangeVehicleVc];
//    }];
//    });
//}


#pragma mark - 初始化数据
- (void)initDataArray
{
    NSString *licensePlate = (!IsStrEmpty(UserDefaults_Get_Object(@"CarInfoTypeLicenseNum")))?UserDefaults_Get_Object(@"CarInfoTypeLicenseNum"):@"";
    NSString *engineNumber = (!IsStrEmpty(UserDefaults_Get_Object(@"CarInfoTypeEngineNum")))?UserDefaults_Get_Object(@"CarInfoTypeEngineNum"):@"";
//    NSString *model = (!IsStrEmpty([[CustomerInfo sharedInstance] currentVehicle].modelDesc))?[[CustomerInfo sharedInstance] currentVehicle].modelDesc:@"";
//    NSString *carYear = (!IsStrEmpty([[CustomerInfo sharedInstance] currentVehicle].year))?[[CustomerInfo sharedInstance] currentVehicle].year:@"";
    
    NSString *insuranceComp = (!IsStrEmpty(_vehicleInfo.insuranceComp))?_vehicleInfo.insuranceComp:@"";
    NSString *compulsoryInsuranceExpireDate = (!IsStrEmpty(_vehicleInfo.compulsoryInsuranceExpireDate))?_vehicleInfo.compulsoryInsuranceExpireDate:@"";
    NSString *businessInsuranceExpireDate = (!IsStrEmpty(_vehicleInfo.businessInsuranceExpireDate))?_vehicleInfo.businessInsuranceExpireDate:@"";
    
    NSString *vin =(!IsStrEmpty([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin))?[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin:@"";
    [_dataArray removeAllObjects];
    
//    [_dataArray addObject:@[@""]];//站位
    
//    NSMutableArray* sectionItems = @[].mutableCopy;
//    NSMutableArray* sectionItems = @[@"站位"].mutableCopy;
    [_dataArray addObject:@[@"站位"]];

    if ([SOSCheckRoleUtil isOwner]) {
        [_dataArray addObject:@[@{@"title":@"车辆操作历史",
                                  @"val":@"",
                                  @"accessoryTypeNone":@(NO),//YES不显示
                                  @"sel":NSStringFromSelector(@selector(operationHistroy)),
                                  }]];
    }
    
    if (([SOSCheckRoleUtil isOwner] || [SOSCheckRoleUtil isDriverOrProxy]) &&
        ![Util isLoadUserProfileFailure] &&
        ([Util vehicleIsPHEV])) {
        [_dataArray addObject:@[@{@"title":@"充电设置",
                                  @"val":@"",
                                  @"accessoryTypeNone":@(NO),//YES不显示
                                  @"sel":NSStringFromSelector(@selector(pushCharge)),
                                  }]];
    }
    //WIFI   ICM 1.0 Wifi 放开
//    if (([SOSCheckRoleUtil isOwner] || [SOSCheckRoleUtil isDriverOrProxy]) &&
//        ![Util isLoadUserProfileFailure] &&
//        [CustomerInfo sharedInstance].currentVehicle.wifiSupported &&
//        ![Util vehicleIsIcm]) {
//        [sectionItems addObject:@{@"title":@"车载Wi-Fi设置",
//                                  @"val":@"",
//                                  @"accessoryTypeNone":@(NO),//YES不显示
//                                  @"sel":NSStringFromSelector(@selector(pushWiFi)),
//                                  }];
//    }
    

    
//    if (sectionItems.count) {
//        [_dataArray addObject:sectionItems.copy];
//        [sectionItems removeAllObjects];
//    }
    
//    if ([SOSCheckRoleUtil isOwner] || [SOSCheckRoleUtil isDriverOrProxy]) {
//        [_dataArray addObject:@[@{@"title":@"切换车辆",
//                                  @"val":@"",
//                                  @"accessoryTypeNone":@(NO),//YES不显示
//                                  @"sel":NSStringFromSelector(@selector(pushChangeVehicleVc)),
//                                  }]];
//    }

    [_dataArray addObject:@[@{@"title":@"车辆识别码",
                              @"val":[vin stringInterceptionHideSix],
                              @"accessoryTypeNone":@(YES),//YES不显示
                              @"sel":@"",
                              },
//                            @{@"title":@"车系",
//                              @"val":model,
//                              @"accessoryTypeNone":@(YES),//YES不显示
//                              @"sel":@"",
//                              },
//                            @{@"title":@"年款",
//                              @"val":carYear,
//                              @"accessoryTypeNone":@(YES),//YES不显示
//                              @"sel":@"",
//
//                              },
                            @{@"title":@"发动机号",
                              @"val":engineNumber.length > 0 ? engineNumber : @"设置发动机号",
                              @"accessoryTypeNone":@([SOSCheckRoleUtil isDriverOrProxy]),//YES不显示
                              @"sel":NSStringFromSelector(@selector(configUserCarEngineNum)),
                              },
                            @{@"title":@"车牌号",
                              @"val":licensePlate.length > 0 ? licensePlate : @"设置车牌号",
                              @"accessoryTypeNone":@([SOSCheckRoleUtil isDriverOrProxy]),//YES不显示
                              @"sel":NSStringFromSelector(@selector(configUserCarLicenseNum)),
                            }
                            ]
     ];
    //Owner才显示保险信息
    if ([SOSCheckRoleUtil isOwner]) {
        [_dataArray addObject:@[@{@"title":NSLocalizedString(@"Insurance_Company",nil),
                                  @"val":insuranceComp,
                                  @"accessoryTypeNone":@(NO),//YES不显示
                                  @"sel":NSStringFromSelector(@selector(configInsuranceVC)),
                                  },
                                @{@"title":NSLocalizedString(@"CLIVTA_expiry", nil),
                                  @"val":compulsoryInsuranceExpireDate,
                                  @"accessoryTypeNone":@(NO),//YES不显示
                                  @"sel":NSStringFromSelector(@selector(configJiaoqiangxian)),
                                  },
                                @{@"title":NSLocalizedString(@"Vehicle_Insurance_expiry", nil),
                                  @"val":businessInsuranceExpireDate,
                                  @"accessoryTypeNone":@(NO),//YES不显示
                                  @"sel":NSStringFromSelector(@selector(configShangyexian)),
                                  }
                                ]
         ];
    }
    
    if ([SOSCheckRoleUtil isOwner]) {
        //驾照日期
        [_dataArray addObject:@[@{@"title":@"行驶证到期日",
                                  @"val":_vehicleInfo.drivingLicenseDate?:@"",
                                  @"accessoryTypeNone":@(NO),//YES不显示
                                  @"sel":NSStringFromSelector(@selector(configXingshizheng)),
                                  }
                                ]
         ];
    }
    
    
}

#pragma mark - 加载车辆信息
- (void)loadVehicleInfo
{
    if ([SOSCheckRoleUtil isOwner] || [SOSCheckRoleUtil isDriverOrProxy]) {
        
    }else {
        return;
    }
    
    if([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin&&[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin.length>0){
        
        NSString *url = [BASE_URL stringByAppendingFormat:VEHICLE_INFO_URL,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];

        SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
            NSLog(@"车辆信息responseStr:%@",responseStr);
            dispatch_async(dispatch_get_main_queue(), ^{
                _vehicleInfo  =[NNVehicleInfoModel mj_objectWithKeyValues:responseStr];
                UserDefaults_Set_Object(_vehicleInfo.engineNumber, @"CarInfoTypeEngineNum");
                UserDefaults_Set_Object(_vehicleInfo.licensePlate, @"CarInfoTypeLicenseNum");
                [self initDataArray];
                [self.tableView reloadData];
            });
        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        }];
        [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
        [operation setHttpMethod:@"GET"];
        [operation start];
        
    }
}

#pragma mark - 初始化日期选择
//- (void)initDatePickerView
//{
//    _datePickerView = [[DatePickerView alloc] init];
//    _datePickerView.top = SCREEN_HEIGHT;
//    __unsafe_unretained __typeof(self) weakSelf = self;
//    [_datePickerView setExitCallback:^{
//        [weakSelf closeDateWindow];
//    }];
//    [_datePickerView setOkCallback:^{
//        [weakSelf selectDate];
//    }];
//}

- (void)initNavigationItemView
{
//    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, 200, 44)];
//    titleLabel.textColor = [UIColor colorWithHexString:@"4E4E5F"];
//    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:18.f];
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    titleLabel.text = @"车辆设置";
//
//    UIView *naView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
//    self.navigationItem.titleView = naView;
//    [naView addSubview:titleLabel];
    self.title = @"车辆设置";
    
    self.tableView.tableFooterView = [UIView new];
    
//    logoView = [[UIImageView alloc] initWithImage:[SOSUtilConfig returnImageBySortOfCarbrand]];
//    logoView.frame = CGRectMake((titleLabel.width - 55) / 2, 0, 55, 55);
//    logoView.alpha = 0.f;
//    logoView.contentMode = UIViewContentModeScaleAspectFit;
//    [naView addSubview:logoView];
//    if ([SOSCheckRoleUtil isOwner]) {
//        [SOSUtilConfig setNavigationBarItemTitle:@"操作历史" target:self selector:@selector(operationHistroy)];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if (section == 0) {
//        return [_dataArray[section] count] + 1;
////    }else if (section == 1)
//    }else
//    {
        return [_dataArray[section] count];
//    }
//    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 294.f;
    }
    return 55.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    if (section != 0) {
//        NSArray *ary = _dataArray[section];
//        {
//            NSDictionary *dic = ary.firstObject;
//            NSString *title = dic[@"title"];
//            if ([title isEqualToString:@"车辆识别码"]) {
//                return 44;
//            }
//        }
//    }
    if (section == 0 || section == 1) {
        return CGFLOAT_MIN;
    }
    return 10.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
//    NSString *title = [_dataArray[section] firstObject][@"title"];
//    if ([title isEqualToString:@"车辆识别码"]) {
//        UIView *headerContentView = [UIView new];
//        headerContentView.backgroundColor = UIColorHex(#F3F5FE);
//        UIView *header = [UIView new];
//        header.backgroundColor = UIColor.whiteColor;
//        [headerContentView addSubview:header];
//        [header mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(34);
//            make.left.right.bottom.mas_equalTo(headerContentView);
//        }];
//        UIView *leftLine = [UIView new];
//        leftLine.backgroundColor = UIColorHex(#6896ED);
//        [header addSubview:leftLine];
//
//        UILabel *titleLabel = [UILabel new];
//        titleLabel.textColor = UIColorHex(#6896ED);;
//        titleLabel.font = [UIFont boldSystemFontOfSize:14];
//        [header addSubview:titleLabel];
//
//        [leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.centerY.mas_equalTo(header);
//            make.height.mas_equalTo(16);
//            make.width.mas_equalTo(4);
//        }];
//
//        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(header).offset(12);
//            make.centerY.mas_equalTo(header);
//        }];
//        titleLabel.text = @"详细信息";
//        return headerContentView;
//    }
    
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        SOSCarLogoTableViewCell *logoCell = [tableView dequeueReusableCellWithIdentifier:@"SOSCarLogoTableViewCell"];
        if (!logoCell) {
            logoCell = [[NSBundle SOSBundle] loadNibNamed:@"SOSCarLogoTableViewCell" owner:self options:nil][0];
            logoCell.delegate = self;
        }
        [logoCell refreshData];
//       logoCell.logoIcon.image = [SOSUtilConfig returnImageBySortOfCarbrand];
        return logoCell;
    } else {
        SOSInfoTableViewCell *infoCell = [tableView dequeueReusableCellWithIdentifier:@"SOSInfoTableViewCell"];
        if (!infoCell) {
            infoCell = [[NSBundle SOSBundle] loadNibNamed:@"SOSInfoTableViewCell" owner:self options:nil][0];
        }
        NSInteger row = indexPath.row;
        NSDictionary *dict = _dataArray[indexPath.section][row];
//        if (indexPath.section == 0 && indexPath.row == 0) {
//
//        }else{
//            if (indexPath.section == 0) {
//                dict = _dataArray[indexPath.section][indexPath.row - 1];
//            }else{
//                dict = _dataArray[indexPath.section][indexPath.row];
//            }
            infoCell.titleLB.text = dict[@"title"];
            infoCell.infoLB.text = dict[@"val"];
//        }
        BOOL accessoryTypeNone = [dict[@"accessoryTypeNone"] boolValue];
//        if (indexPath.section == 0 && (indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3)) {
        infoCell.rightImgView.hidden = accessoryTypeNone;
//        if (accessoryTypeNone) {
//            infoCell.rightImgView.fd_collapsed = YES;
//        }else {
//            infoCell.rightImgView.fd_collapsed = NO;
//        }
        

//            if (indexPath.row == 1) {
//                infoCell.infoLB.text = [dict[@"val"] stringInterceptionHide];
//            }
//        }
        //车牌号、发动机号对proxy或driver为只读，不可更改
//        if ((indexPath.section==0 && (indexPath.row==4 ||indexPath.row==5))) {
//            if ([SOSCheckRoleUtil isDriverOrProxy]) {
//                infoCell.accessoryType = UITableViewCellAccessoryNone;
//            }
//        }
//        if (indexPath.section == 2) {
//            if (![CustomerInfo sharedInstance].licenseExpireDate.isNotBlank) {
//                infoCell.accessoryType = UITableViewCellAccessoryNone;
//            }
//        }
        
        
        return infoCell;
    }
}

- (void)configUserCarLicenseNum {
    if ([SOSCheckRoleUtil isOwner]) {
        UserCarInfoVC *vc = [UserCarInfoVC new];
        vc.carInfoType = CarInfoTypeLicenseNum;
        //    车辆管理_输入车牌号
        vc.backRecordFunctionID = PlateNo_back;
        [SOSDaapManager sendActionInfo:Vehicleinfo_PlateNo];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void)configUserCarEngineNum {
    if ([SOSCheckRoleUtil isOwner]) {
        UserCarInfoVC *vc = [UserCarInfoVC new];
        vc.carInfoType = CarInfoTypeEngineNum;
        //    车辆管理_输入发动机号
        [SOSDaapManager sendActionInfo:Vehicleinfo_engineNo];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//修改保险公司
- (void)configInsuranceVC {
    [SOSDaapManager sendActionInfo:Vehicleinfo_insurance];
    SOSInsuranceViewController *insuranceVC = [[SOSInsuranceViewController alloc] initWithNibName:@"SOSInsuranceViewController" bundle:nil];
    insuranceVC.pageType = SOSInsuranceVCPageType_VehicleInfo;
    insuranceVC.needUpdateInfo = YES;
    insuranceVC.backRecordFunctionID = Insurance_Editnsurer_back;
    insuranceVC.sourceInsurance = _vehicleInfo.insuranceComp;
    SOSWeakSelf(weakSelf);
    insuranceVC.selectInsurenceBlock = ^(NSString * insurance) {
        _vehicleInfo.insuranceComp = insurance;
        [weakSelf initDataArray];
        [weakSelf.tableView reloadData];
    };
    [self.navigationController pushViewController:insuranceVC animated:YES];
}

- (void)configJiaoqiangxian {
    //修改交强险到期日
    [SOSDaapManager sendActionInfo:Vehicleinfo_CompulsoryInsu];
    _dateIndex = 1;
    [self openDateWindow];
}

- (void)configShangyexian {
    //修改商业险到期日
    [SOSDaapManager sendActionInfo:Vehicleinfo_BusinessInsu];
    _dateIndex = 2;
    [self openDateWindow];
}

- (void)configXingshizheng {
    [SOSDaapManager sendActionInfo:Vehicleinfo_Drivinglicense];
    _dateIndex = 3;
    [self openDateWindow];
}

- (void)pushWiFi {
    [SOSDaapManager sendActionInfo:VEHICLE_CAR_CONDITION_VEHICLE_SETTING_WIFISETTING];
    [SOSCardUtil routerToWifiSetting];
}

- (void)pushCharge {
    [SOSDaapManager sendActionInfo:SS_chargeoption];
    [SOSDaapManager sendActionInfo:VEHICLE_CAR_CONDITION_VEHICLE_SETTING_CHARGESETTING];
    if (![[ServiceController sharedInstance] canPerformRequest:GET_CHARGE_PROFILE_REQUEST]) {
        return;
    }
    ChargeModeViewController *chargeMode = [ChargeModeViewController new];
    [self.navigationController pushViewController:chargeMode animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if (indexPath.section == 0 && row == 0) {
        return;
    }
    NSDictionary *dict = _dataArray[indexPath.section][indexPath.row];
    NSString *selStr = dict[@"sel"];
    if (selStr.isNotBlank) {
        SEL sel = NSSelectorFromString(selStr);
        if ([self respondsToSelector:sel]) {
            [self performSelector:sel];
        }
    }
    
//    //Owner可以修改车牌、发动机号，Proxy、Driver只读
//    if ([SOSCheckRoleUtil isOwner])
//    {
//        if (indexPath.section == 0 && row == 4){
//            UserCarInfoVC *vc = [UserCarInfoVC new];
//            vc.carInfoType = CarInfoTypeLicenseNum;
//            //    车辆管理_输入车牌号
//            vc.backRecordFunctionID = PlateNo_back;
//            [SOSDaapManager sendActionInfo:Vehicleinfo_PlateNo];
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//
//        if (indexPath.section == 0 && row == 5){
//            UserCarInfoVC *vc = [UserCarInfoVC new];
//            vc.carInfoType = CarInfoTypeEngineNum;
//            //    车辆管理_输入发动机号
//            [SOSDaapManager sendActionInfo:Vehicleinfo_engineNo];
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//    }
//
//    //===================================Owner才显示保险信息====================================
//    //修改保险公司
//    if (indexPath.section == 1 && row == 0){
//        [SOSDaapManager sendActionInfo:Vehicleinfo_insurance];
//        SOSInsuranceViewController *insuranceVC = [[SOSInsuranceViewController alloc] initWithNibName:@"SOSInsuranceViewController" bundle:nil];
//        insuranceVC.pageType = SOSInsuranceVCPageType_VehicleInfo;
//        insuranceVC.needUpdateInfo = YES;
//        insuranceVC.backRecordFunctionID = Insurance_Editnsurer_back;
//        insuranceVC.sourceInsurance = _vehicleInfo.insuranceComp;
//        SOSWeakSelf(weakSelf);
//        insuranceVC.selectInsurenceBlock = ^(NSString * insurance) {
//            _vehicleInfo.insuranceComp = insurance;
//            [weakSelf initDataArray];
//            [weakSelf.tableView reloadData];
//        };
//        [self.navigationController pushViewController:insuranceVC animated:YES];
//    }
//    //修改交强险到期日
//    if (indexPath.section == 1 && row == 1){
//        [SOSDaapManager sendActionInfo:Vehicleinfo_CompulsoryInsu];
//        _dateIndex = 1;
//        [self openDateWindow];
//    }
//    //修改商业险到期日
//    if (indexPath.section == 1 && row == 2){
//        [SOSDaapManager sendActionInfo:Vehicleinfo_BusinessInsu];
//        _dateIndex = 2;
//        [self openDateWindow];
//    }
//    //行驶证到期日
//    if (indexPath.section == 2 && row == 0) {
//        [SOSDaapManager sendActionInfo:Vehicleinfo_Drivinglicense];
//        _dateIndex = 3;
//        [self openDateWindow];
//    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //[self showLogoViewAtNavigationItem:scrollView.contentOffset.y];  //DF20066，滑动时无需变化
}

- (void)showLogoViewAtNavigationItem:(CGFloat)alphaValue
{
    logoView.alpha = 0.0133333 * alphaValue;
    titleLabel.alpha = 1 - (0.0133333 * alphaValue);
}

- (void)operationHistroy
{
    [SOSDaapManager sendActionInfo:VEHICLE_CAR_CONDITION_VEHICLE_SETTING_VEHICLECONTROLHISTORY];
    [SOSDaapManager sendActionInfo:Vehicleinfo_operathistory];
    SOSOperationHistoryViewController *hisVc = [[SOSOperationHistoryViewController alloc] initWithNibName:@"SOSOperationHistoryViewController" bundle:nil];
    hisVc.backRecordFunctionID = Vehicleinfo_operathistory_back;
    [self.navigationController pushViewController:hisVc animated:YES];
}

#pragma mark --- 切换车辆
 /**
  多车(Owner、Proxy、Driver都可以)切换车辆
  @param Owner、Proxy、Driver都可以
  @return
  */
- (void)pushChangeVehicleVc{
    [SOSDaapManager sendActionInfo:Vehicleinfo_changecars];
    SOSChangeVehicleViewController *changeVc = [[SOSChangeVehicleViewController alloc] initWithNibName:@"SOSChangeVehicleViewController" bundle:nil];
    [self.navigationController pushViewController:changeVc animated:YES];
}


#pragma mark - viewWillAppear
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.carNameLB.text = [[CustomerInfo sharedInstance] currentVehicle].modelDesc;
    logoView.image = [SOSUtilConfig returnImageBySortOfCarbrand];
    [self initDataArray];
    [self.tableView reloadData];
}

#pragma mark -初始化日期
#pragma mark 弹出日期窗口
- (void)openDateWindow{
    SOSVehicleSettingCalendarView *calendar = [[SOSVehicleSettingCalendarView alloc] initWithFrame:CGRectMake(0, 0, 0, 330)];
//    view.backgroundColor = UIColor.redColor;
    if (_dateIndex == 1) {
        if (IsStrEmpty(_vehicleInfo.compulsoryInsuranceExpireDate)) {
            [calendar setSelectDate:NSDate.date];
        }else {
            [calendar setSelectDate:[SOSDateFormatter.sharedInstance style1_dateFromString:_vehicleInfo.compulsoryInsuranceExpireDate]];
        }
    }else if(_dateIndex == 2) {
        if (IsStrEmpty(_vehicleInfo.businessInsuranceExpireDate)) {
            [calendar setSelectDate:NSDate.date];
        }else {
            [calendar setSelectDate:[SOSDateFormatter.sharedInstance style1_dateFromString:_vehicleInfo.businessInsuranceExpireDate]];
        }
    }else if (_dateIndex == 3) {
        
        if (IsStrEmpty(_vehicleInfo.drivingLicenseDate)) {
            [calendar setSelectDate:NSDate.date];
        }
        else {
            [calendar setSelectDate:[SOSDateFormatter.sharedInstance style1_dateFromString:_vehicleInfo.drivingLicenseDate]];
        }
        
    }
    SOSAlertAction *confirm = [SOSAlertAction actionWithTitle:@"发送" style:SOSAlertActionStyleDefault handler:^(SOSAlertAction * _Nonnull action) {
        [self selectDate:calendar.selectDate];
    }];
    
    SOSAlertAction *cancel = [SOSAlertAction actionWithTitle:@"取消" style:SOSAlertActionStyleCancel handler:^(SOSAlertAction * _Nonnull action) {
        
    }];
    
    
    
    SOSFlexibleAlertController *ac = [SOSFlexibleAlertController alertControllerWithImage:nil title:nil message:nil customView:calendar preferredStyle:SOSAlertControllerStyleAlert];
    [ac addActions:@[confirm, cancel]];
    [ac show];
    
    
    
    
//    if (!_cover) {
//        _cover = [CustomCover coverWithTarget:self action:@selector(closeDateWindow) coverAlpha:0.35];
//        _cover.frame = [[UIScreen mainScreen] bounds];
//    }
//    [[[UIApplication sharedApplication] keyWindow] addSubview:_cover];
//    [[[UIApplication sharedApplication] keyWindow] addSubview:_datePickerView];
//
//    //设置datePicker默认日期
//    if (_dateIndex==1) {
//        if (IsStrEmpty(_vehicleInfo.compulsoryInsuranceExpireDate)) {
//            [_datePickerView.datePicker setDate:[NSDate date] animated:NO];
//        }
//        else
//        {
//            [_datePickerView.datePicker setDate:[[DatePickerView dateFormatter] dateFromString:_vehicleInfo.compulsoryInsuranceExpireDate] animated:NO];
//        }
//    }
//    else if(_dateIndex == 2)
//    {
//        if (IsStrEmpty(_vehicleInfo.businessInsuranceExpireDate)) {
//            [_datePickerView.datePicker setDate:[NSDate date] animated:NO];
//        }
//        else
//        {
//            [_datePickerView.datePicker setDate:[[DatePickerView dateFormatter] dateFromString:_vehicleInfo.businessInsuranceExpireDate] animated:NO];
//        }
//    }else if (_dateIndex == 3) {
//
//        if (IsStrEmpty(_vehicleInfo.drivingLicenseDate)) {
//            [_datePickerView.datePicker setDate:[NSDate date] animated:NO];
//        }
//        else
//        {
//            [_datePickerView.datePicker setDate:[[DatePickerView dateFormatter] dateFromString:_vehicleInfo.drivingLicenseDate] animated:NO];
//        }
//
//    }
//
//
//    [UIView animateWithDuration:.3 animations:^{
//        [_cover reset];
//        _datePickerView.bottom = self.view.bottom;
//    }];
}

//#pragma mark 关闭日期窗口
//- (void)closeDateWindow{
//    [UIView animateWithDuration:.3 animations:^{
//        _cover.alpha = 0.0;
//        _datePickerView.top = self.view.bottom;
//    } completion:^(BOOL finished) {
//        [_cover removeFromSuperview];
//        [_datePickerView removeFromSuperview];
//    }];
//    if (_dateIndex==1) {
//        [SOSDaapManager sendActionInfo:Vehicleinfo_CompulsoryInsu_cancel];
//
//    }else if (_dateIndex == 2){
//        [SOSDaapManager sendActionInfo:Vehicleinfo_BusinessInsu_cancel];
//    }else {
//         [SOSDaapManager sendActionInfo:Vehicleinfo_Drivinglicense_cancel];
//    }
//}

#pragma mark 选择日期
- (void)selectDate:(NSDate *)date{
//    _cover.alpha = 0.0;
//    _datePickerView.top = self.view.bottom;
//    [_cover removeFromSuperview];
//    [_datePickerView removeFromSuperview];
    
//    NSString *dt = [[DatePickerView dateFormatter] stringFromDate:_datePickerView.datePicker.date];
    NSString *dt = [SOSDateFormatter.sharedInstance style1_stringFromDate:date];
    if (_dateIndex == 3) {
        [SOSDaapManager sendActionInfo:Profile_DriveLicense_confirm];
        if ([dt isEqualToString:_vehicleInfo.drivingLicenseDate]) return;
//        [self updateLicenseExpireDate:dt compCallback:^{
//            //根据选择的日期，进行相应的消息推送
//            [PushNotificationManager settingLicenseExpireAlertAndPush:_datePickerView.datePicker.date isAlert:YES];
////            [CustomerInfo sharedInstance].licenseExpireDate = dt;
//            _vehicleInfo.drivingLicenseDate = dt;
//            [self initDataArray];
//            [self.tableView reloadData];
//
//        }];
        [self resetDrivingLicenseDate:dt];
        return;
    }
    
    
    
    NNVehicleInfoRequest *request = [[NNVehicleInfoRequest alloc]init];
    [request setAccountID:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId];
    [request setVin:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    if (_dateIndex==1) {
        [request setCompulsoryInsuranceExpireDate:dt];
        [SOSDaapManager sendActionInfo:Vehicleinfo_CompulsoryInsu_confirm];
    }
    else if (_dateIndex==2)
    {
        [request setBusinessInsuranceExpireDate:dt];
        [SOSDaapManager sendActionInfo:Vehicleinfo_BusinessInsu_confirm];
    }
    
    
    [self updateInsuranceDate:[request mj_JSONString] compCallback:^{
        if (_dateIndex==1) {
            //根据选择的日期，进行相应的消息推送
//            [PushNotificationManager settingCompulsoryInsuranceExpireAlertAndPush:_datePickerView.datePicker.date isAlert:YES];
            _vehicleInfo.compulsoryInsuranceExpireDate = dt;
        }
        else
        {
            //根据选择的日期，进行相应的消息推送
//            [PushNotificationManager settingBusinessInsuranceExpireAlertAndPush:_datePickerView.datePicker.date isAlert:YES];
            _vehicleInfo.businessInsuranceExpireDate = dt;
        }
        [self initDataArray];
        [self.tableView reloadData];
    }];
}

#pragma mark - 更新保险日期
- (void)updateInsuranceDate:(NSString *)json compCallback:(void(^)(void))compCallback
{

    if([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin&&[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin.length>0){
        
        NSString *url = [BASE_URL stringByAppendingFormat:VEHICLE_INFO_URL,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];

        [Util showLoadingView];
        SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:json successBlock:^(SOSNetworkOperation *operation, id responseStr) {
            [Util hideLoadView];
            dispatch_async(dispatch_get_main_queue(), ^{
                !compCallback ? : compCallback();
            });
        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
            [Util showAlertWithTitle:nil message:dic[@"description"] completeBlock:nil];
            [Util hideLoadView];
        }];
        [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
        [operation setHttpMethod:@"PUT"];
        [operation start];
        
    }else{
        
        [Util showAlertWithTitle:nil message:@"无法修改,获取车辆信息错误" completeBlock:nil];
    }
    
    
}

#pragma mark - 更新驾照到期日
- (void)updateLicenseExpireDate:(NSString *)date compCallback:(void(^)(void))compCallback
{
    NNRegisterRequest *request = [[NNRegisterRequest alloc] init];
    [request setSourceId:[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]];
    [request setUserName:[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
    [request setLicenseExpireDate:date];
    
    NSString *url = [BASE_URL stringByAppendingString:NEW_CHANGE_MOBILE_EMAIL];
    [Util showLoadingView];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:[request mj_JSONString] successBlock:^(SOSNetworkOperation *operation, id returnData) {
        [Util hideLoadView];
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                if (operation.statusCode == 200) {
                    !compCallback ? : compCallback();
                }
            }
            @catch (NSException *exception) {
                NSLog(@"exception jsonFormatError");
            }
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
        [Util hideLoadView];
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"PUT"];
    [operation start];
}

#pragma mark - 更新行驶证日期
- (void)resetDrivingLicenseDate:(NSString *)drivingLicensenDate {
    [Util showLoadingView];

    [VehicleInfoUtil updateVehicleDrivingLicenseInfo:drivingLicensenDate success:^{
//        NSDate * carDetectionDate = [self getcarDetectionDate:_datePickerView.datePicker.date];
//        NSString *sdt = [[DatePickerView dateFormatter] stringFromDate:carDetectionDate];
//        [[_dataArray objectAtIndex:0] setValue:drivingLicensenDate forKey:@"val"];
//        [[_dataArray objectAtIndex:1] setValue:sdt forKey:@"val"];
//        [_tableView reloadData];
        dispatch_async_on_main_queue(^{
            [Util hideLoadView];
            _vehicleInfo.drivingLicenseDate = drivingLicensenDate;
            [self initDataArray];
            [self.tableView reloadData];
//            [PushNotificationManager settingCarDetectionNotify:_datePickerView.datePicker.date];
        });
        
    } failure:^(NSString *resp_) {
        [Util hideLoadView];
        [Util showAlertWithTitle:@"提示" message:@"行驶证日期更新失败!" completeBlock:^(NSInteger buttonIndex) {
        }];
        
    }];
}

#pragma mark - logo cell delegate
- (void)logoCell:(SOSCarLogoTableViewCell *)cell didPressSwitchCarBtn:(id)sender {
    [self pushChangeVehicleVc];
}

- (void)logoCell:(SOSCarLogoTableViewCell *)cell didPressWifiBtn:(id)sender {
    [self pushWiFi];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SOS_ACCOUNT_VEHICLE_HAS_CHANGED object:nil];
}

@end
