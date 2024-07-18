//
//  SOSRemindsetVc.m
//  Onstar
//
//  Created by Genie Sun on 2017/3/13.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSRemindsetVc.h"
#import "SOSRemindchannelsVc.h"
#import "SOSTanViewController.h"
#import "SOSRemindSet.h"
#import "SOSchangePhmailNumber.h"
#import "NSString+JWT.h"
#import "PackageUtil.h"
NSString * const kSOSServiceOptState = @"SOSServiceOptState";
NSString * const kSOSServiceSmartDriveOptState =@"SOSServiceSmartDriveOptState";
NSString * const kSOSServiceFuelDriveOptState=@"SOSServiceFuelDriveOptState";
NSString * const kSOSServiceEnergyDriveOptState=@"SOSServiceEnergyDriveOptState";


@interface SOSRemindsetVc ()<UITableViewDelegate,UITableViewDataSource>		{
    BOOL showTAN; //是否显示tan  车辆被盗
    BOOL showDA; //是否显示DA   车辆实时检测
    BOOL showSmartDrive;//是否显示驾驶行为和车联保险
    BOOL showOilrank; //是否显示油耗排名
    BOOL showEngeryRank;//是否显示能耗排名
    BOOL showLBS; //是否显示LBS
    channelsType channels;
    NSMutableArray *alertTitleArray ;

}

@property (strong, nonatomic) NSMutableArray <NSArray <NSString *> *> * sourceDataArray;

//@property (strong, nonatomic) NSMutableArray<NSString *> *sectionOneArray;
//@property (strong, nonatomic) NSArray<NSString *> *sectionTwoArray;
@property (strong, nonatomic) NNNotifyConfig *notObject;
@property (weak, nonatomic) UIView *emptyView;
@property (strong, nonatomic) NSArray<NNserviceObject *> *serviceList;

@end

@implementation SOSRemindsetVc

- (void)initData {
    if ([self showRASection]) {
        NSArray *icm2TitleArray = [self getICM2NotiTitleArray];
        self.sourceDataArray = [NSMutableArray arrayWithArray:@[@[], icm2TitleArray, @[@"手机号",@"邮箱地址"]]];
    }	else	{
        self.sourceDataArray = [NSMutableArray arrayWithArray:@[@[], @[@"手机号",@"邮箱地址"]]];
    }
    alertTitleArray = [NSMutableArray array];
}

- (void)initView {
    self.title = @"提醒设置";
    _table.rowHeight = 54.f;
    _table.tableFooterView = [self tableFooterView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
    //非车主直接显示empty页面
    if (![SOSCheckRoleUtil isOwner]) {
        self.emptyView.hidden = NO;
        return;
    }
    [self requestServices];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serviceOptStatusChanged:) name:kSOSServiceOptState object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestCellPhoneAndEmail];
}

- (NSArray *)getICM2NotiTitleArray	{
    NSMutableArray *arr = [NSMutableArray array];
        SOSVehicle *vehicle = [CustomerInfo sharedInstance].currentVehicle;
        if (vehicle.doorPositionSupport)							[arr addObject:@"停车车门未锁"];
        if (vehicle.trunkPositionSupport)        					[arr addObject:@"停车后备箱未关"];
        if (vehicle.windowPositionSupport)        					[arr addObject:@"停车车窗未关"];
        if (vehicle.sunroofPositionSupport)        					[arr addObject:@"停车天窗未关"];
        if (vehicle.engineStateSupport)		                        [arr addObject:@"停车发动机未熄火"];
        if (vehicle.flashStateSupport)        						[arr addObject:@"双闪警示灯未关"];
    return arr;
}

#pragma mark - table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sourceDataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = self.sourceDataArray[section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.textLabel.font = [UIFont systemFontOfSize:15.f];
        cell.textLabel.textColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.30 alpha:1.00];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSArray *titleArray = self.sourceDataArray[indexPath.section];
    if (indexPath.section == (1 + [self showRASection]) ) {
        cell.textLabel.text = titleArray[indexPath.row];
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = [Util isBlankString:_notObject.phone] ? @"去设置" : [Util maskMobilePhone:_notObject.phone];
        }else{
            cell.detailTextLabel.text = [Util isBlankString:_notObject.mail] ? @"去设置" : [_notObject.mail stringEmailInterceptionHide];
        }
    }	else	{
        cell.textLabel.text = titleArray[indexPath.row];
        cell.detailTextLabel.text = nil;
    }
    return cell;
}

#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section != 0) {
        return 20.f;
    }
    return CGFLOAT_MIN;
}
-(BOOL)showRASection{
    return  [Util vehicleIsICM2]&&[CustomerInfo sharedInstance].sosRAStatus;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView;
    if (section != 0) {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
        UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH, 20)];
        lb.text = (section == (1 + [self showRASection]) ) ? @"提醒方式设置" : @"停车车辆状态提醒";
        lb.textColor = [UIColor colorWithHexString:@"4E4E5F"];
        lb.font = [UIFont systemFontOfSize:12.f];
        [headerView addSubview:lb];
    }
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 15.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [self.table cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == (1 + [self showRASection]) ) {
        
        SOSchangePhmailNumber *change = [[SOSchangePhmailNumber alloc] initWithNibName:@"SOSchangePhmailNumber" bundle:nil];
        change.pagetype = indexPath.row;
        change.notObject = self.notObject;
        NSArray* arr = @[@"原手机号：  ",
                         @"原邮箱：  "];
        NSString *info = [NSString stringWithFormat:@"%@%@",arr[indexPath.row],cell.detailTextLabel.text];
        change.info = [cell.detailTextLabel.text isEqualToString:@"去设置"] ? nil : info;
        if ([cell.detailTextLabel.text isEqualToString:@"去设置"]) {
            if (indexPath.row == 0) {
                [SOSDaapManager sendActionInfo:NS_notification_mobile];
            }else{
                [SOSDaapManager sendActionInfo:NS_notification_email];
            }
        }
        [self.navigationController pushViewController:change animated:YES];
        return;
    }
    
    
    if ([cell.textLabel.text isEqualToString:@"车辆报警提示"]) {
        channels = StolenRemind;
        [SOSDaapManager sendActionInfo:NS_TAN];
    }else if ([cell.textLabel.text isEqualToString:@"车况检测报告"]){
        channels = TestReport;
        [SOSDaapManager sendActionInfo:NS_OVD_app_setting];
        
    }
    else if ([cell.textLabel.text isEqualToString:@"车辆实时检测"]){
        channels = FaultDiagnosis;
        [SOSDaapManager sendActionInfo:NS_DA_app_setting];
    }
    else if ([cell.textLabel.text isEqualToString:@"油耗水平排名"]){
        channels = FUELEconomy;
        //[[SOSReportService shareInstance] recordActionWithFunctionID:NotificationSettings_ClickFuelEconomySetting];
        [SOSDaapManager sendActionInfo:NS_notification_oilconsump];
        
    }
    else if ([cell.textLabel.text isEqualToString:@"驾驶行为评价"]){
        channels = SmartDriver;
    }
    else if ([cell.textLabel.text isEqualToString:@"车联保险"]){
        channels = Ubi;
    }
    else if ([cell.textLabel.text isEqualToString:@"能耗水平排名"]){
        channels = EnergyEconomy;
        [SOSDaapManager sendActionInfo:NS_notification_engconsump];
    }
    else if ([cell.textLabel.text isEqualToString:@"停车车门未锁"]){
        channels = ICM2CarDoorOpenAlert;
        //        [SOSDaapManager sendActionInfo:NS_notification_engconsump];
    }
    else if ([cell.textLabel.text isEqualToString:@"停车后备箱未关"]){
        channels = ICM2TrunkOpenAlert;
        //        [SOSDaapManager sendActionInfo:NS_notification_engconsump];
    }
    else if ([cell.textLabel.text isEqualToString:@"停车车窗未关"]){
        channels = ICM2WindowOpenAlert;
        //        [SOSDaapManager sendActionInfo:NS_notification_engconsump];
    }
    else if ([cell.textLabel.text isEqualToString:@"停车天窗未关"]){
        channels = ICMSunroofOpenAlert;
        //        [SOSDaapManager sendActionInfo:NS_notification_engconsump];
    }
    else if ([cell.textLabel.text isEqualToString:@"停车发动机未熄火"]){
        channels = ICM2EngineOpenAlert;
        //        [SOSDaapManager sendActionInfo:NS_notification_engconsump];
    }
    else if ([cell.textLabel.text isEqualToString:@"双闪警示灯未关"]){
        channels = ICM2FlashOpenAlert;
        //        [SOSDaapManager sendActionInfo:NS_notification_engconsump];
    }
    
    SOSRemindchannelsVc *channerVc = [[SOSRemindchannelsVc alloc] initWithNibName:@"SOSRemindchannelsVc" channerlsType:channels];
    if (channels == EnergyEconomy) {
        channerVc.backDaapFunctionID = NS_notification_engconsump_back;
    }
        if (showTAN && indexPath.row == 0 && indexPath.section == 0) {
            ///gen10流量包在有效期内或gen9服务包在有效期内
            [Util showLoadingView];
//            if ([CustomerInfo sharedInstance].currentVehicle.gen10) {
                [self getDataListInBackGround:indexPath.row];
                
//            }    else    {
//                //gen9服务包在有效期内
//                [self getPackageListInBackGround:indexPath.row];
//            }
        } else {
            [self.navigationController pushViewController:channerVc animated:YES];
        }
}


#pragma mark - http request

- (void)requestServices {
    
    NSString *url = [BASE_URL stringByAppendingFormat:get_local_services_URL,  [CustomerInfo sharedInstance].userBasicInfo.idpUserId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin,@""];

    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSArray *serviceList = [Util arrayWithJsonString:responseStr];
        _serviceList = [NNserviceObject mj_objectArrayWithKeyValuesArray:serviceList];
        [self cookServicesData];
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async_on_main_queue(^{
            [Util toastWithMessage:responseStr];
        });
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];

}

- (void)cookServicesData {
    //对于GEN9车型来说，TAN的提醒设置只有凯迪拉克品牌才能看到，对雪佛兰和别克隐藏
    if ([Util vehicleIsG10] || [Util vehicleIsIcm]) {
        showTAN = YES;
    }	else if ([Util vehicleIsG9]) {
        if ([Util vehicleIsCadillac] && ![[[CustomerInfo sharedInstance] currentVehicle].modelDesc isEqualToString:K_CADILLAC_MODEL_CN]) {
            showTAN = YES;
        }
    }
    if (showTAN ) {
        [alertTitleArray addObject:@"车辆报警提示"];
    }
    [alertTitleArray addObject:@"车况检测报告"];
    
    [_serviceList enumerateObjectsUsingBlock:^(NNserviceObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.serviceName isEqualToString:@"DIAGNOSTICALERT"]) {
            if (obj.optStatus) {
                showDA = YES;
            }
        }	else if ([obj.serviceName isEqualToString:@"EnergyEconomy"]) {
            if (obj.optStatus) {
                showEngeryRank = YES;
            }
        }	else if ([obj.serviceName isEqualToString:@"FuelEconomy"]) {
            if (obj.optStatus && obj.availability) {
                showOilrank = YES;
            }
        }	else if ([obj.serviceName isEqualToString:@"SmartDrive"]) {
            if (obj.optStatus && obj.availability) {
                showSmartDrive = YES;
            }
        //需要显示LBS则打开注释
//        }else if ([obj.serviceName isEqualToString:@"LBS"]) {
//            showLBS = YES;
        }
    }];
    
    if (showDA) {
        [alertTitleArray addObject:@"车辆实时检测"];
    }
    if (showOilrank) {
        [alertTitleArray addObject:@"油耗水平排名"];
    }
   
    if (showLBS) {
        [alertTitleArray addObject:@"LBS"];
    }
    if (showSmartDrive) {
        [alertTitleArray addObject:@"驾驶行为评价"];
    }
    if (showEngeryRank) {
        [alertTitleArray addObject:@"能耗水平排名"];
    }
    [self.sourceDataArray replaceObjectAtIndex:0 withObject:alertTitleArray];
    dispatch_async_on_main_queue(^{
        [self.table reloadData];
    });
}
-(void)serviceOptStatusChanged:(NSNotification *)noti{
    NSDictionary *dic = noti.object;
    if (dic.count == 0)		return;
    if ([dic objectForKey:kSOSServiceSmartDriveOptState]) {
        NSNumber * optStatus = [dic objectForKey:kSOSServiceSmartDriveOptState];
        if ([optStatus boolValue]) {
            if (![alertTitleArray containsObject:@"驾驶行为评价"]) {
                 [alertTitleArray addObject:@"驾驶行为评价"];
            }
           
        }else{
            [alertTitleArray removeObject:@"驾驶行为评价"];
        }
    }
    
    if ([dic objectForKey:kSOSServiceFuelDriveOptState]) {
        NSNumber * optStatus = [dic objectForKey:kSOSServiceFuelDriveOptState];
        if ([optStatus boolValue]) {
            if (![alertTitleArray containsObject:@"油耗水平排名"]) {
              [alertTitleArray addObject:@"油耗水平排名"];
            }
        }else{
            [alertTitleArray removeObject:@"油耗水平排名"];
        }

    }
    
    if ([dic objectForKey:kSOSServiceEnergyDriveOptState]) {
        NSNumber * optStatus = [dic objectForKey:kSOSServiceEnergyDriveOptState];
        if ([optStatus boolValue]) {
            if (![alertTitleArray containsObject:@"能耗水平排名"]) {
                [alertTitleArray addObject:@"能耗水平排名"];
            }
        }else{
            [alertTitleArray removeObject:@"能耗水平排名"];
        }
        
    }
    
    dispatch_async_on_main_queue(^{
        [self.table reloadData];
    });
}

- (void)requestCellPhoneAndEmail {
    [SOSRemindSet notigyConfigInformation:@"GET" body:nil btype:@"TAN" Success:^(NNNotifyConfig *notify) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _notObject = notify;
            [_table reloadData];
        });
    } Failed:nil];
    
}
/// 流量packages
- (void)getDataListInBackGround:(NSUInteger)row     {
    [PackageUtil getPackageServiceSuccess:^(SOSGetPackageServiceResponse *userfulDic) {
        [Util hideLoadView];
        if ([CustomerInfo sharedInstance].currentVehicle.gen10) {
            //G10
            if (userfulDic.remainingBytes && [userfulDic.remainingBytes.currentRemainUsage integerValue]>0) {
                SOSRemindchannelsVc *channerVc = [[SOSRemindchannelsVc alloc] initWithNibName:@"SOSRemindchannelsVc" channerlsType:row];
                [self.navigationController pushViewController:channerVc animated:YES];
               
            }else{
                SOSTanViewController *tanVc = [[SOSTanViewController alloc] initWithNibName:@"SOSTanViewController" bundle:nil];
                [self.navigationController pushViewController:tanVc animated:YES];
            }
        }else{
            //G9
             if (![userfulDic.state isEqualToString:@"3"]) {
                SOSRemindchannelsVc *channerVc = [[SOSRemindchannelsVc alloc] initWithNibName:@"SOSRemindchannelsVc" channerlsType:row];
                [self.navigationController pushViewController:channerVc animated:YES];
                
            }else{
                SOSTanViewController *tanVc = [[SOSTanViewController alloc] initWithNibName:@"SOSTanViewController" bundle:nil];
                [self.navigationController pushViewController:tanVc animated:YES];
            }
        }

    } failed:^(NSString *responseStr, NSError *error) {
        [Util hideLoadView];

        [Util toastWithMessage:responseStr];

    } ];
   
}

///// 安吉星packages
//- (void)getPackageListInBackGround:(NSUInteger)row     {
//    __block BOOL onstarInValid; //是否套餐包有效
//    NSString *url;
////    url = [BASE_URL stringByAppendingFormat:NEW_PACKAGEINFO_URL_PRE, [CustomerInfo sharedInstance].userBasicInfo.idpUserId, [CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin,@"CORE"];
//    url = [BASE_URL stringByAppendingFormat:NEW_PACKAGEINFO_URL_PRE,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
//
//    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id returnData) {
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//
//            SOSRemindchannelsVc *channerVc = [[SOSRemindchannelsVc alloc] initWithNibName:@"SOSRemindchannelsVc" channerlsType:row];
//            SOSTanViewController *tanVc = [[SOSTanViewController alloc] initWithNibName:@"SOSTanViewController" bundle:nil];
//            onstarInValid = [self finishRequest:returnData andType:NEW_PACKAGEINFO_URL_PRE];
//            if (onstarInValid) { //gen9服务包在有效期内
//                [self.navigationController pushViewController:channerVc animated:YES];
//            }else{////Gen9服务包过期
//                tanVc.validity = gen9ServiceOver;
//                [self.navigationController pushViewController:tanVc animated:YES];
//            }
//            [Util hideLoadView];
//
//        });
//
//     } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
//         [Util hideLoadView];
//         [Util toastWithMessage:responseStr];
//     }];
//    [sosOperation setHttpMethod:@"GET"];
//    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"APPLICANT":@"ONSTAR_IOS"}];
//    [sosOperation start];
//}


- (BOOL)finishRequest:(NSString *)request andType:(NSString *)dataType     {

    if ([dataType isEqualToString:NEW_PURCHASE_GET_DATA_LIST_URL])  {
        NNGetDataListResponse *dataResponse = [NNGetDataListResponse mj_objectWithKeyValues:[Util dictionaryWithJsonString:request]];
        NSUInteger count = dataResponse.packageUsageInfos.count;
        
        for (int i = 0; i < count; i++) {
            NNPackagelistarray *packages = dataResponse.packageUsageInfos[i];
            BOOL flg = [packages.remainUsage isEqualToString:@"0Byte"] || ([packages.remainUsage doubleValue] == 0) || [packages.remainUsage isEqualToString:@"0byte"];
            if ([packages.active isEqualToString:@"1"] && flg) {
                return NO;
            }
        }
        if ([dataResponse.currentRemainUsage doubleValue] == 0) {
            return NO;
        }
        return YES;
    } else if ([dataType isEqualToString:NEW_PACKAGEINFO_URL_PRE]) {
        NNGetPackageListResponse *httpResponse = [NNGetPackageListResponse mj_objectWithKeyValues:[Util dictionaryWithJsonString:request]];
        if ([httpResponse.totalRemainingDay floatValue] > 0) {
            return YES;
        }
        return NO;
    }
    return NO;
}

#pragma mark - custom view

- (UIView *)emptyView {
    if (!_emptyView) {
        UIView *emptyView = [UIView new];
        emptyView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:emptyView];
        [emptyView mas_makeConstraints:^(MASConstraintMaker *make){
            make.edges.equalTo(self.view);
        }];
        UILabel *label = [UILabel new];
        label.text = @"抱歉，您没有相关设置权限";
        label.textAlignment = NSTextAlignmentCenter;
        [emptyView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make){
            make.center.equalTo(emptyView);
        }];
        _emptyView = emptyView;
        
    }
    return _emptyView;
}

- (UIView *)tableFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
    UILabel *label = [UILabel new];
    label.text = @"设置后可统一修改用于接收提醒和电话通知的手机号码及邮箱地址";
    label.textColor = [UIColor colorWithHexString:@"999999"];
    label.font = [UIFont systemFontOfSize:12];
    label.adjustsFontSizeToFitWidth = YES;
    label.textAlignment = NSTextAlignmentCenter;
    [footerView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(footerView);
    }];

    return footerView;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
