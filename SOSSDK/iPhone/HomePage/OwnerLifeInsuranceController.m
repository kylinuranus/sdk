//
//  OwnerLifeInsuranceController.m
//  Onstar
//
//  Created by Apple on 17/1/9.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "OwnerLifeInsuranceController.h"
#import "RequestDataObject.h"
#import "CustomerInfo.h"
#import "DatePickerView.h"
#import "CustomCover.h"
//#import "MeSelectInsuranceViewController.h"
#import "OwnerLifeBannerView.h"
#import "SOSWebViewController.h"
#import "DispatchUtil.h"
#import "SOSSearchResult.h"
#import "SOSCheckRoleUtil.h"
#import "PushNotificationManager.h"
#import "SOSInsuranceViewController.h"

@interface OwnerLifeInsuranceController ()<UITableViewDelegate, UITableViewDataSource,WKNavigationDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NNVehicleInfoModel *vehicleInfo;
@property (nonatomic, strong) OwnerLifeBannerView *bannerView;
@property (nonatomic, strong) DatePickerView *datePickerView;
@property (nonatomic, strong) CustomCover *cover;
@property (nonatomic, assign) NSInteger dateIndex;//1:交强险, 2:商业险
@property (nonatomic, strong) UIButton  *disclaimerButton;
@property (nonatomic, strong) UIButton *arrowBtn;
@property (nonatomic, strong) WKWebView *disclaimerView;

@property (assign, nonatomic) BOOL declartionIsShow;


@end

@implementation OwnerLifeInsuranceController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"保险信息";
//    self.navigationController.navigationBar.translucent=NO;
    self.backRecordFunctionID = Insurance_back;
    [self initDataArray];
    [self setupUI];
    [self loadVehicleInfo];
    [self initDatePickerView];
    [self loadBanner];
}

#pragma mark - 初始化数据
- (void)initDataArray {
    NSString *insuranceComp = (!IsStrEmpty(_vehicleInfo.insuranceComp))?_vehicleInfo.insuranceComp:@"";
    NSString *compulsory = (!IsStrEmpty(_vehicleInfo.compulsoryInsuranceExpireDate))?_vehicleInfo.compulsoryInsuranceExpireDate:@"";
    NSString *business = (!IsStrEmpty(_vehicleInfo.businessInsuranceExpireDate))?_vehicleInfo.businessInsuranceExpireDate:@"";
    _dataArray = @[@{@"title":NSLocalizedString(@"Insurance_Company",nil),@"val":insuranceComp},
                   @{@"title":NSLocalizedString(@"CLIVTA_expiry", nil),@"val":compulsory},
                   @{@"title":NSLocalizedString(@"Vehicle_Insurance_expiry", nil),@"val":business}];
}

- (void)setupUI {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 54;
    _tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.left.right.equalTo(self.view);
        make.bottom.mas_equalTo(-45);
    }];


    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 180)];
    _tableView.tableFooterView = footerView;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(15, 0, self.view.width-30, 0.5)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"969A9E"];
    [footerView addSubview:lineView];
    
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, self.view.width-30, 13)];
    infoLabel.text = @"填写保险购买日期，即可收到保险到期提醒";
    infoLabel.font = [UIFont systemFontOfSize:12];
    infoLabel.textColor = [UIColor colorWithHexString:@"969A9E"];
    infoLabel.adjustsFontSizeToFitWidth = YES;
    [footerView addSubview:infoLabel];

    //设置banner
    self.bannerView = [[OwnerLifeBannerView alloc] initWithFrame:CGRectMake(15, 77, self.view.width-30, 90)];
    self.bannerView.viewCtrl = self;
    [footerView addSubview:self.bannerView];
    [self initBottomView];

}

- (void)initBottomView {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"预约保险" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor colorWithHexString:@"107FE0"];
    [btn addTarget:self action:@selector(insuranceClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(45);
        make.bottom.equalTo(self.view.sos_bottom);
    }];

    
    _arrowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_arrowBtn setImage:[UIImage imageNamed:@"hidedisclaimer"] forState:UIControlStateNormal];
    [_arrowBtn setImage:[UIImage imageNamed:@"showdisclaimer"] forState:UIControlStateSelected];
    [_arrowBtn addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_arrowBtn];
    [_arrowBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(@15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(20);
        make.bottom.equalTo(btn.mas_top);
    }];

    _disclaimerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _disclaimerButton.backgroundColor = [UIColor whiteColor];
    _disclaimerButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _disclaimerButton.titleLabel.numberOfLines = 0;
    _disclaimerButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [_disclaimerButton setTitle:@"免责声明:点击预约保险即前往第三方车险平台，相关服务与交易将在第三方平台上完成" forState:UIControlStateNormal];
    [_disclaimerButton addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
    [_disclaimerButton setTitleColor: [UIColor colorWithHexString:@"107FE0"] forState:UIControlStateNormal];
    [self.view addSubview:_disclaimerButton];
    [_disclaimerButton mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(@15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(45);
        make.bottom.equalTo(_arrowBtn.mas_top);
    }];
    
    [self.view bringSubviewToFront:btn];
    [self.view bringSubviewToFront:_disclaimerButton];
    [self.view bringSubviewToFront:_arrowBtn];
}


#pragma mark - 加载车辆信息
- (void)loadVehicleInfo
{
 
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
    }else{
        
   
        [Util showAlertWithTitle:nil message:@"获取车辆信息错误"completeBlock:^(NSInteger buttonIndex) {
            
            [self.navigationController popViewControllerAnimated:true];
        }];
    }
 
 
}

#pragma mark - 加载banner
- (void)loadBanner {
    [OthersUtil getBannerByCategory:BANNER_INSURANCE CarOwnersLiv:NO SuccessHandle:^(id responseStr) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            self.bannerView.bannerFunctionIDArray= @[Insurance_banner1,Insurance_banner2,Insurance_banner3,Insurance_banner4,Insurance_banner5];
            self.bannerView.imageArray = [NNBanner mj_objectArrayWithKeyValuesArray:responseStr];
            [self.tableView reloadData];
        });
        
    } failureHandler:^(NSString *responseStr, NSError *error) {
        
        
    }];
}

- (void)toggle {
    if (!_declartionIsShow) {
        [self showDisclaimer];
    }else {
        [self hideDisclaimer];
    }
}

#pragma mark - 显示免责条款
- (void)showDisclaimer   {
    [SOSDaapManager sendActionInfo:Insurance_OpenDisclaimer];
    CGFloat height = 220;///展开高度
    if (!_disclaimerView) {
        _disclaimerView = [[WKWebView alloc] initWithFrame:CGRectZero];
        _disclaimerView.backgroundColor = [UIColor whiteColor];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:OWNERlIFE_DISCLAIMER]];
        [_disclaimerView loadRequest:request];
        _disclaimerView.navigationDelegate = self;
        [self.view addSubview:_disclaimerView];
        [_disclaimerView mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(@15);
            make.right.equalTo(@-15);
            make.top.equalTo(_disclaimerButton.mas_bottom);
            make.bottom.equalTo(_arrowBtn.mas_top);
        }];
        [self.view layoutIfNeeded];
        
    }
    if (!_declartionIsShow) {
        [_disclaimerButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_arrowBtn.mas_top).offset(-height);
        }];
        _disclaimerView.hidden = NO;
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            _arrowBtn.selected = YES;
            _declartionIsShow = YES;
        }];
    }
}
#pragma mark - 隐藏免责条款
- (void)hideDisclaimer       {
    [SOSDaapManager sendActionInfo:Insurance_CloseDisclaimer];
    [_disclaimerButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_arrowBtn.mas_top);
    }];
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        _declartionIsShow = NO;
        _arrowBtn.selected = NO;
    }];
}

#pragma mark - tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellid = @"cellid";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellid];
        cell.textLabel.textColor = [UIColor colorWithHexString:@"151B32"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.textColor = [UIColor colorWithHexString:@"151B32"];
    }
    NSDictionary *dict = _dataArray[indexPath.row];
    cell.textLabel.text = dict[@"title"];
    cell.detailTextLabel.text = dict[@"val"];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"me_right_arrow"]];
    cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"151B32"];
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath     {
    //修改保险公司
    if (indexPath.row == 0){
        [SOSDaapManager sendActionInfo:Insurance_EditInsurer];
        
        //保险公司
        SOSInsuranceViewController *insuranceVC = [[SOSInsuranceViewController alloc] initWithNibName:@"SOSInsuranceViewController" bundle:nil];
        insuranceVC.pageType = SOSInsuranceVCPageType_OwnerLife;
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
    //修改交强险到期日
    if (indexPath.row == 1){
        [SOSDaapManager sendActionInfo:Insurance_Complusoryexpirydate];
        _dateIndex = 1;
        [self openDateWindow];
    }
    //修改商业险到期日
    if (indexPath.row == 2){
        [SOSDaapManager sendActionInfo:Insurace_AutoExpirydate];
        _dateIndex = 2;
        [self openDateWindow];
    }
}

#pragma mark - 初始化日期选择
- (void)initDatePickerView
{
    _datePickerView = [[DatePickerView alloc] init];
    _datePickerView.top = SCREEN_HEIGHT;
    __unsafe_unretained __typeof(self) weakSelf = self;
    [_datePickerView setExitCallback:^{
        [weakSelf closeDateWindow];
    }];
    [_datePickerView setOkCallback:^{
        [weakSelf selectDate];
    }];
}

#pragma mark -初始化日期
#pragma mark 弹出日期窗口
- (void)openDateWindow{
    if (!_cover) {
        _cover = [CustomCover coverWithTarget:self action:@selector(closeDateWindow) coverAlpha:0.35];
        _cover.frame = [[UIScreen mainScreen] bounds];
    }
    [[[UIApplication sharedApplication] keyWindow] addSubview:_cover];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_datePickerView];
    
    //设置datePicker默认日期
    if (_dateIndex==1) {
        NSDate *dt = IsStrEmpty(_vehicleInfo.compulsoryInsuranceExpireDate)?[NSDate date]:[[DatePickerView dateFormatter] dateFromString:_vehicleInfo.compulsoryInsuranceExpireDate];
        [_datePickerView.datePicker setDate:dt animated:NO];
    }
    else
    {
        NSDate *dt = IsStrEmpty(_vehicleInfo.businessInsuranceExpireDate)?[NSDate date]:[[DatePickerView dateFormatter] dateFromString:_vehicleInfo.businessInsuranceExpireDate];
        [_datePickerView.datePicker setDate:dt animated:NO];
    }
    [UIView animateWithDuration:.3 animations:^{
        [_cover reset];
        _datePickerView.bottom = self.view.bottom;
    }];
}

#pragma mark 关闭日期窗口
- (void)closeDateWindow{
    [UIView animateWithDuration:.3 animations:^{
        _cover.alpha = 0.0;
        _datePickerView.top = self.view.bottom;
    } completion:^(BOOL finished) {
        [_cover removeFromSuperview];
        [_datePickerView removeFromSuperview];
    }];
}

#pragma mark 选择日期
- (void)selectDate{
    _cover.alpha = 0.0;
    _datePickerView.top = self.view.bottom;
    [_cover removeFromSuperview];
    [_datePickerView removeFromSuperview];
    
    NSString *dt = [[DatePickerView dateFormatter] stringFromDate:_datePickerView.datePicker.date];
    NNVehicleInfoRequest *request = [[NNVehicleInfoRequest alloc]init];
    [request setAccountID:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId];
    [request setVin:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    if (_dateIndex==1) {
        [request setCompulsoryInsuranceExpireDate:dt];
    }
    else
    {
        [request setBusinessInsuranceExpireDate:dt];
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
- (void)updateInsuranceDate:(NSString *)json compCallback:(void (^)(void))compCallback
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
    

#pragma mark - 点击预约保险
- (void)insuranceClick{
    [SOSDaapManager sendActionInfo:Insurance_Renew];
    NNDispatcherReq *req = [[NNDispatcherReq alloc] init];
    [req setDispatchFrom:soskWebDispatch_External];
    [req setDispatchKey:@"insurance"];
    [req setPartner_id:@"onStar"];
    [req setContentType:@"JSON"];
    [req setMethod:@"POST"];
    [req setAttributeData:@"idpUserID,vin,licensePlate,enginNumber,mobilePhoneNumber,emailAddress,location,firstName,lastName,make,model"];
    [req setLongitude:NONil(((SOSPOI *)[[CustomerInfo sharedInstance] currentPositionPoi]).longitude)];
    [req setLatitude:NONil(((SOSPOI *)[[CustomerInfo sharedInstance] currentPositionPoi]).latitude)];
    SOSWebViewController *web = [[SOSWebViewController alloc] initWithDispatcher:req];
    web.backRecordFunctionID = Insurance_paymentback;
    [self.navigationController pushViewController:web animated:YES];
}

@end
