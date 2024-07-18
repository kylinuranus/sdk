//
//  SOSCarSecretaryViewController.m
//  Onstar
//
//  Created by TaoLiang on 2018/1/29.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSCarSecretaryViewController.h"
#import "UITableView+Category.h"
#import "SOSCarSecretarySectionHeaderView.h"
#import "SOSCarSecretaryECCell.h"
#import "SOSCarSecretaryCell.h"
#import "SOSInsuranceViewController.h"
#import "SOSCarSecretaryDatePicker.h"
#import "SOSDateFormatter.h"

@interface SOSCarSecretaryViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSArray<NSString *> *sections;
///保存本地显示的key值
@property (strong, nonatomic) NSArray<NSArray<NSString *> *> *dataKeys;

@property (strong, nonatomic) NSArray<NSArray<NSString *> *> *daapKeys;

///保存本地显示的具体值
@property (strong, nonatomic) NSMutableArray<NSMutableArray<NSString *> *> *dataValues;
///保存网络请求的key值
@property (strong, nonatomic) NSArray<NSArray<NSString *> *> *requestKeys;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) SOSCarSecretaryDatePicker *datePicker;

@property (strong, nonatomic) NSMutableArray<SOSCarSecretaryCell *> *ecCells;


@end

@implementation SOSCarSecretaryViewController

- (void)initData {
    _sections = @[@"紧急联系人", @"保险公司", @"车检换证提醒", @"车辆还贷提醒"];
    _dataKeys = @[@[@"姓        氏", @"名        字", @"联系电话"], @[@"当前保险公司", @"交强险到期日", @"商业险到期日"], @[@"驾驶证到期日", @"行驶证到期日"], @[@"每月还贷日期", @"最后还贷日期"]];
    _daapKeys = @[@[], @[VehicleSec_CurrentInsuranceCo, VehicleSec_MandInsuranceexpirydate, VehicleSec_BusinessInsuranceexpirydate], @[VehicleSec_DrivLicenceexpirydate, VehicleSec_VehicleLicenseexpirydate], @[VehicleSec_debtmonthlyrepaydate, VehicleSec_debtenddate]];
    _requestKeys = @[@[@"ecFristName", @"ecLastName", @"ecMobile"], @[@"insuranceComp", @"compulsoryInsuranceExpireDate", @"businessInsuranceExpireDate"], @[@"licenseExpireDate", @"drivingLicenseDate"], @[@"loanRepaymentDay", @"lastRepayMentDay"]];
    self.backDaapFunctionID = VehicleSec_back;
}

- (void)initView {
    self.title = @"险贷检提醒";
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveEmergencyContact) forControlEvents:UIControlEventTouchUpInside];
    [saveBtn sizeToFit];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [SOSUtil onstarLightGray];
    _tableView.tableFooterView = [UIView new];
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    _tableView.rowHeight = 55;
    _tableView.tableFooterView = [self tableFooterView];
    [_tableView registerNib:[SOSCarSecretaryECCell class]];
    [_tableView registerNib:[SOSCarSecretaryCell class]];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self.view);
    }];
    
    //UIDatePicker太耗性能,每次点击cell时候创建会很慢,先初始化好
    SOSCarSecretaryDatePicker *datePicker = [SOSCarSecretaryDatePicker viewFromXib];
    _datePicker = datePicker;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
    [self initView];
    if (!_carSecretary) {
        [self requestCarSecretary];
    }
}

- (void)setCarSecretary:(SOSCarSecretary *)carSecretary {
    _carSecretary = carSecretary;
    NSString *ecFirstName = @"";
    NSString *ecLastName = @"";
    NSString *ecMobile = @"";
    if ([CustomerInfo sharedInstance].isEcInfoDisplay) {
        ecFirstName = [CustomerInfo sharedInstance].ecFirstName ? : @"";
        ecLastName = [CustomerInfo sharedInstance].ecLastName ? : @"";
        ecMobile = [CustomerInfo sharedInstance].ecMobile ? : @"";
    }
    
    NSString *insuranceComp = carSecretary.insuranceComp ? : @"";
    NSString *compulsoryInsuranceExpireDate = carSecretary.compulsoryInsuranceExpireDate ? : @"";
    NSString *businessInsuranceExpireDate = carSecretary.businessInsuranceExpireDate ? : @"";
    NSString *licenseExpireDate = carSecretary.licenseExpireDate ? : @"";
    NSString *drivingLicenseDate = carSecretary.drivingLicenseDate ? : @"";
    NSString *loanRepaymentDay = carSecretary.loanRepaymentDay ? : @"";
    NSString *lastRepayMentDay = carSecretary.lastRepayMentDay ? : @"";
    _dataValues = @[@[ecFirstName, ecLastName, ecMobile].mutableCopy, @[insuranceComp, compulsoryInsuranceExpireDate, businessInsuranceExpireDate].mutableCopy, @[licenseExpireDate, drivingLicenseDate].mutableCopy, @[loanRepaymentDay, lastRepayMentDay].mutableCopy].mutableCopy;
    [_tableView reloadData];
}

#pragma mark - table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataKeys[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    if (section == 0) {
        SOSCarSecretaryECCell *cell = [tableView dequeueReusableCellWithIdentifier:SOS_GetClassString(SOSCarSecretaryECCell)];
        cell.title = _dataKeys[section][indexPath.row];
        cell.value = _dataValues[section][indexPath.row];
        return cell;
    }
    SOSCarSecretaryCell *cell = [tableView dequeueReusableCellWithIdentifier:SOS_GetClassString(SOSCarSecretaryCell)];
    cell.title = _dataKeys[indexPath.section][indexPath.row];
    NSString *value = _dataValues[section][indexPath.row];
    //每月还贷日
    if (section == 3 && indexPath.row == 0 && value.length > 0) {
        value = [value stringByAppendingString:@"日"];
    }
    cell.value = value;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SOSCarSecretarySectionHeaderView *view = [SOSCarSecretarySectionHeaderView new];
    view.title = _sections[section];
//    if (section == 0) {
//        __weak __typeof(self)weakSelf = self;
//        [view showSaveBtn:^{
//            [weakSelf saveEmergencyContact];
//        }];
//    }
    return view;
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = _dataKeys[indexPath.section][indexPath.row];
    NSString *oldValue = _dataValues[indexPath.section][indexPath.row];
    __weak __typeof(self)weakSelf = self;
    if (indexPath.section == 0) {
        return;
    }
    NSString *daapFuncId = _daapKeys[indexPath.section][indexPath.row];
    [SOSDaapManager sendActionInfo:daapFuncId];
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        SOSInsuranceViewController *insuranceVC = [SOSInsuranceViewController new];
        insuranceVC.selectInsurenceBlock = ^(NSString * insurance) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
            if (insurance && insurance.isNotBlank) {
                [weakSelf updateAndSave:insurance indexPath:indexPath];
            }
        };
        [self.navigationController pushViewController:insuranceVC animated:YES];
        return;
    }

//    SOSCarSecretaryDatePicker *datePicker = [SOSCarSecretaryDatePicker viewFromXib];
    _datePicker.title = title;
    if (indexPath.section == 3 && indexPath.row == 0) {
        NSMutableArray<NSString *> *days = @[].mutableCopy;
        for (int i=1; i<=31; i++) {
            NSString *day = [NSString stringWithFormat:@"%@日", @(i)];
            [days addObject:day];
        }
        _datePicker.pickerType = SOSCarSecretaryDatePickerTypeDay;
        _datePicker.days = days;
    }else {
        _datePicker.pickerType = SOSCarSecretaryDatePickerTypeDate;
    }
    if (oldValue.length > 0) {
        _datePicker.selectedDate = oldValue;
    }
    _datePicker.picked = ^(NSString *result) {
        [weakSelf updateAndSave:result indexPath:indexPath];
    };
    [_datePicker show];
    
}

- (void)updateAndSave:(NSString *)result indexPath:(NSIndexPath *)indexPath {
    NSString *requestKey = _requestKeys[indexPath.section][indexPath.row];
    _dataValues[indexPath.section][indexPath.row] = result;
    [_tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationAutomatic];
    [self saveDataRequest:@{requestKey: result} success:^(NSDictionary *params) {
        if ([requestKey isEqualToString:@"licenseExpireDate"]) {
            NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
            NSTimeInterval editDate = [[[SOSDateFormatter sharedInstance] style1_dateFromString:result] timeIntervalSince1970];
            if ([SOSDateFormatter isSameDay:[NSDate date] date2:[[SOSDateFormatter sharedInstance] style1_dateFromString:result]]) {

            }else if (editDate < now) {
                [Util showAlertWithTitle:@"亲爱的安吉星车主，您的驾照已过期，请及时前往相关部门进行换证" message:nil completeBlock:nil cancleButtonTitle:nil otherButtonTitles:@"知道了",nil];
//                UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:@"亲爱的安吉星车主，您的驾照已过期，请及时前往相关部门进行换证" preferredStyle:UIAlertControllerStyleAlert];
//                UIAlertAction *ac0 = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil];
//                [ac addAction:ac0];
//                [ac show];
            }
        }
    } failure:nil];
}

#pragma mark - http request

- (void)requestCarSecretary {
    [Util showLoadingView];
    NSString *subId = [CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId;
    NSString *accountId = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId;
    NSString *vin = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin;
    
    NSString *api = [BASE_URL stringByAppendingString:MA8_2_CarSecretary_API];
    NSString *url = [NSString stringWithFormat:api, subId, accountId, vin];
    SOSNetworkOperation *ope = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        dispatch_async_on_main_queue(^{
            self.carSecretary = [SOSCarSecretary mj_objectWithKeyValues:responseStr];
            [Util hideLoadView];
        });
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async_on_main_queue(^{
            [Util hideLoadView];
            [Util toastWithMessage:responseStr];
        });
    }];
    [ope setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [ope setHttpMethod:@"GET"];
    [ope start];
}

- (void)saveEmergencyContact {
    [_tableView scrollToTopAnimated:NO];
    NSMutableArray<NSString *> *paramValues = @[].mutableCopy;
    for (int i=0; i<3; i++) {
        NSString *param = [(SOSCarSecretaryECCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]] value];
        [paramValues addObject:param];
    }
    NSString *ecFirstName = paramValues[0];
    NSString *ecLastName = paramValues[1];
    NSString *ecMobile = paramValues[2];
    if (ecFirstName.length <= 0) {
//        [Util toastWithMessage:@"请输入姓"];
        [Util showAlertWithTitle:@"紧急联系人信息为必填" message:nil completeBlock:nil cancleButtonTitle:nil otherButtonTitles:@"知道了", nil];
        return;
    }
    if (ecLastName.length <= 0) {
//        [Util toastWithMessage:@"请输入名"];
        [Util showAlertWithTitle:@"紧急联系人信息为必填" message:nil completeBlock:nil cancleButtonTitle:nil otherButtonTitles:@"知道了", nil];
        return;
    }
    if (ecMobile.length <= 0) {
//        [Util toastWithMessage:@"请输入联系电话"];
        [Util showAlertWithTitle:@"紧急联系人信息为必填" message:nil completeBlock:nil cancleButtonTitle:nil otherButtonTitles:@"知道了", nil];
        return;
    }
    if (![Util isValidatePhone:ecMobile]) {
        //        [Util toastWithMessage:@"请输入正确的手机号"];
        [Util showAlertWithTitle:@"请输入正确的手机号" message:nil completeBlock:nil cancleButtonTitle:nil otherButtonTitles:@"知道了", nil];
        return;
    }
    [self.view endEditing:YES];
    NSDictionary *param = @{
                            @"ecFirstName": paramValues[0],
                            @"ecLastName": paramValues[1],
                            @"ecMobile": paramValues[2]
                            };
    [self saveDataRequest:param success:^(NSDictionary *params) {
        [Util showSuccessHUDWithStatus:@"保存成功"];
        [CustomerInfo sharedInstance].ecFirstName = params[@"ecFirstName"];
        [CustomerInfo sharedInstance].ecLastName = params[@"ecLastName"];
        [CustomerInfo sharedInstance].ecMobile = params[@"ecMobile"];
        [CustomerInfo sharedInstance].isEcInfoDisplay = YES;
        SOSLoginUserDefaultVehicleVO *loginUserDefaultVehicleVO = [SOSUtil getProfileObjFromDatabase];
        loginUserDefaultVehicleVO.subscriber.emergencyContact.contact.familyName = params[@"ecFirstName"];
        loginUserDefaultVehicleVO.subscriber.emergencyContact.contact.givenName = params[@"ecLastName"];
        loginUserDefaultVehicleVO.subscriber.emergencyContact.contact.mobile = params[@"ecMobile"];
        loginUserDefaultVehicleVO.preference.ecContactDisplay = YES;
//        NNSubscriber *profile = [SOSUtil getProfileObjFromDatabase];
//        profile.ecFirstName = [CustomerInfo sharedInstance].ecFirstName;
//        profile.ecLastName = [CustomerInfo sharedInstance].ecLastName;
//        profile.ecMobile = [CustomerInfo sharedInstance].ecMobile;
//        profile.isEcInfoDisplay = [CustomerInfo sharedInstance].isEcInfoDisplay;
        [SOSUtil saveProfileObjToDatabase:loginUserDefaultVehicleVO];
    } failure:nil];
}

- (void)saveDataRequest:(NSDictionary *)params success:(void (^)(NSDictionary *params))success failure:(void (^)(void))failure{
    [Util showLoadingView];
    NSString *subId = [CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId;
    NSString *accountId = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId;
    NSString *vin = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin;
    NSString *api = [BASE_URL stringByAppendingString:MA8_2_CarSecretary_API];
    NSString *url = [NSString stringWithFormat:api, subId, accountId, vin];
    NSMutableDictionary *rootParam = @{ @"accountID":accountId ? : @"",
                                        @"subscriberID":subId ? : @"",
                                        @"vin":vin ? : @""  }.mutableCopy;
    [rootParam addEntriesFromDictionary:params];
    NSString *jsonString = [rootParam toJson];
    SOSNetworkOperation *ope = [SOSNetworkOperation requestWithURL:url params:jsonString successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        dispatch_async_on_main_queue(^{
            if (success) 	success(rootParam);
            [Util hideLoadView];
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async_on_main_queue(^{
            [Util hideLoadView];
            [Util toastWithMessage:responseStr];
        });
    }];
    [ope setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [ope setHttpMethod:@"PUT"];
    [ope start];
    
}


#pragma mark - function button
- (void)promptRuleBtnClicked:(UIButton *)button {
    [SOSDaapManager sendActionInfo:VehicleSec_Remindingrules];
    SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:MA8_2_H5_CarSecretary_PromptRule_URL];
    [self.navigationController pushViewController:vc animated:YES];
}

- (UIView *)tableFooterView {
    UIView *view = [UIView new];
    view.height = 67;
    UIButton *promptBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [promptBtn setTitle:@"提醒规则" forState:UIControlStateNormal];
    [promptBtn addTarget:self action:@selector(promptRuleBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    promptBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [promptBtn setTitleColor:[UIColor colorWithHexString:@"#828389"] forState:UIControlStateNormal];
    [view addSubview:promptBtn];
    [promptBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.center.equalTo(view);
    }];
    return view;
}
@end
