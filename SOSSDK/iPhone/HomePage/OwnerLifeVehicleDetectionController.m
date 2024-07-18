//
//  OwnerLifeVehicleDetectionController.m
//  Onstar
//
//  Created by Apple on 17/1/10.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "OwnerLifeVehicleDetectionController.h"
#import "DatePickerView.h"
#import "CustomCover.h"
#import "SOSWebViewController.h"
#import "BaseSearchOBJ.h"
#import "DispatchUtil.h"
#import "VehicleInfoUtil.h"
#import "PushNotificationManager.h"

@interface OwnerLifeVehicleDetectionController ()<UITableViewDelegate, UITableViewDataSource,WKNavigationDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) DatePickerView *datePickerView;
@property (nonatomic, strong) CustomCover *cover;
@property (nonatomic, strong) NNVehicleInfoModel *vehicleInfo;
@property (nonatomic, assign) NSInteger dateIndex;
@property (nonatomic, strong) UIButton *arrowBtn;
@property (nonatomic, strong) WKWebView *disclaimerView;
@property (nonatomic, strong) UIButton  *disclaimerButton;

@property (assign, nonatomic) BOOL declartionIsShow;

@end

@implementation OwnerLifeVehicleDetectionController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
//    self.navigationController.//navigationBar.translucent = NO;
    self.title = @"车检";
    self.backRecordFunctionID = Inspection_back;
    [self initDataArray];
    [self setupUI];
    [self initDatePickerView];
    [self loadVehicleInfo];
}
#pragma mark - 初始化数据
- (void)initDataArray   {
    _dataArray = @[[NSMutableDictionary dictionaryWithObjectsAndKeys:@"行驶证日期",@"title",@"",@"val",nil],[NSMutableDictionary dictionaryWithObjectsAndKeys:@"建议车检日期",@"title",@"",@"val",nil]];
}

- (void)refreshDrivingLicenseDate:(NSString *)drivingLicenseDate     {
    if (![drivingLicenseDate isEqualToString:@""]) {
        [[_dataArray objectAtIndex:0] setObject:drivingLicenseDate forKey:@"val"];
        //建议车检日期填充
        NSDate * carDetectionDate = [self getcarDetectionDate:[[DatePickerView dateFormatter] dateFromString:drivingLicenseDate]];
        NSString *sdt = [[DatePickerView dateFormatter] stringFromDate:carDetectionDate];
        [[_dataArray objectAtIndex:1] setValue:sdt forKey:@"val"];
        [_tableView reloadData];
    }
}

#pragma mark - 加载车辆信息
- (void)loadVehicleInfo     {
    if([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin&&[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin.length>0){
        
        NSString *url = [BASE_URL stringByAppendingFormat:VEHICLE_INFO_URL,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];

        SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _vehicleInfo  =[NNVehicleInfoModel mj_objectWithKeyValues:responseStr];
                [self refreshDrivingLicenseDate:NONil(_vehicleInfo.drivingLicenseDate)];
            });
        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        }];
        [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
        [operation setHttpMethod:@"GET"];
        [operation start];
        
    }else{
        
        [Util showAlertWithTitle:nil message:@"获取车辆信息错误" completeBlock:^(NSInteger buttonIndex) {
            
            [self.navigationController popViewControllerAnimated:true];
        }];
    }
}

- (void)setupUI     {

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
    infoLabel.text = @"填写购买日期，即可查看建议车检日期，还有车检提醒哦";
    infoLabel.font = [UIFont systemFontOfSize:12];
    infoLabel.textColor = [UIColor colorWithHexString:@"969A9E"];
    infoLabel.adjustsFontSizeToFitWidth = YES;
    [footerView addSubview:infoLabel];
    
    [self initBottomView];

}

- (void)initBottomView {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"预约年检" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor colorWithHexString:@"107FE0"];
    [btn addTarget:self action:@selector(vehicleDetectionClick) forControlEvents:UIControlEventTouchUpInside];
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
    _disclaimerButton.titleLabel.lineBreakMode = 0;
    _disclaimerButton.titleLabel.numberOfLines = 0;
    [_disclaimerButton.titleLabel setFont: [UIFont systemFontOfSize:12]];
    [_disclaimerButton setTitle:@"免责声明:点击预约年检即前往第三方车险平台，相关服务与交易将在第三方平台上完成" forState:UIControlStateNormal];
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


#pragma mark - tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section    {
    return [_dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath      {
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
    if (indexPath.row == 0) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"me_right_arrow"]];
    }
    else
    {
        //占位，希望找到更好方法替代
        cell.accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 1)];
    }
    cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"151B32"];
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath        {
    if (indexPath.row == 0) {
        //[[SOSReportService shareInstance] recordActionWithFunctionID:Inspection_VehicleLicense];
        _dateIndex = 0;
        [self openDateWindow];
    }
}

#pragma mark - 初始化日期选择
- (void)initDatePickerView      {
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
    
    [SOSDaapManager sendActionInfo:Inspection_VehicleLicense];
    //设置datePicker默认日期
    if (_dateIndex==1) {
        NSDate *dt = [NSDate date];
        [_datePickerView.datePicker setDate:dt animated:NO];
    }
    else
    {
        NSDate *dt = [NSDate date];
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
    NSLog(@"选择日期:%@===%@", dt,[[DatePickerView dateFormatter] dateFromString:dt]);
    [self resetDrivingLicenseDate:dt];
}
#pragma mark - 更新行驶证日期
- (void)resetDrivingLicenseDate:(NSString *)drivingLicensenDate
{
    [VehicleInfoUtil updateVehicleDrivingLicenseInfo:drivingLicensenDate success:^{
        NSDate * carDetectionDate = [self getcarDetectionDate:_datePickerView.datePicker.date];
        NSString *sdt = [[DatePickerView dateFormatter] stringFromDate:carDetectionDate];
        [[_dataArray objectAtIndex:0] setValue:drivingLicensenDate forKey:@"val"];
        [[_dataArray objectAtIndex:1] setValue:sdt forKey:@"val"];
        [_tableView reloadData];
//        [PushNotificationManager settingCarDetectionNotify:_datePickerView.datePicker.date];
    } failure:^(NSString *resp_) {
        [Util showAlertWithTitle:@"提示" message:@"行驶证日期更新失败!" completeBlock:^(NSInteger buttonIndex) {
        }];
        
    }];
}
#pragma mark - 根据行驶证日期计算车检日期
- (NSDate *)getcarDetectionDate:(NSDate *)drivingLicenseDate
{
    NSDate * currentDate = [NSDate date];
//    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
//    NSInteger interval = [timeZone secondsFromGMTForDate:currentDate];
//    currentDate = [currentDate dateByAddingTimeInterval:interval];
//    drivingLicenseDate = [drivingLicenseDate dateByAddingTimeInterval:interval];

    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *adcomps = nil;
    adcomps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:drivingLicenseDate];
    
    [adcomps setYear:2];
    [adcomps setDay:0];
    [adcomps setMonth:0];
    [adcomps setHour:0];
    [adcomps setMinute:0];
    NSDate *twoYear = [calendar dateByAddingComponents:adcomps toDate:drivingLicenseDate options:0];
    
    [adcomps setYear:4];
    [adcomps setDay:0];
    [adcomps setMonth:0];
    [adcomps setHour:0];
    [adcomps setMinute:0];
    NSDate *fourYear = [calendar dateByAddingComponents:adcomps toDate:drivingLicenseDate options:0];
    
    [adcomps setYear:6];
    [adcomps setDay:0];
    [adcomps setMonth:0];
    [adcomps setHour:0];
    [adcomps setMinute:0];
    NSDate *sixYear = [calendar dateByAddingComponents:adcomps toDate:drivingLicenseDate options:0];
    
    NSComparisonResult compare2Year = [currentDate compare:twoYear];
    NSComparisonResult compare4Year = [currentDate compare:fourYear];
    NSComparisonResult compare6Year = [currentDate compare:sixYear];
    if (compare6Year == NSOrderedDescending) {
        NSDateComponents * currentcomps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate];
        adcomps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:drivingLicenseDate];
        [adcomps setYear:currentcomps.year];
        NSComparisonResult compare = [currentDate compare:[calendar dateFromComponents:adcomps]];
        if (compare == NSOrderedAscending)
        {
            return [calendar dateFromComponents:adcomps];
        }
        else
        {
            if (compare == NSOrderedDescending) {
                adcomps.year = adcomps.year +1;
            }
            return  [calendar dateFromComponents:adcomps];
        }
    }
    
    if (compare2Year == NSOrderedAscending) {
        return twoYear;
    }
    else
    {
        if (compare4Year == NSOrderedAscending) {
            return fourYear;
        }
        else
        {
            if (compare6Year == NSOrderedAscending) {
                return sixYear;
            }
            else
            {
                adcomps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate];
                [adcomps setYear:adcomps.year +1];
                return  [calendar dateFromComponents:adcomps];
            }
        }
    }
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
    [SOSDaapManager sendActionInfo:Inspection_OpenDiscalimer];
    CGFloat height = 220;///展开高度
    if (!_disclaimerView) {
        _disclaimerView = [[WKWebView alloc] initWithFrame:CGRectZero];
        [_disclaimerView setBackgroundColor:[UIColor whiteColor]];
        NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:OWNERlIFE_DISCLAIMER]];
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
- (void)hideDisclaimer   {
    [SOSDaapManager sendActionInfo:Inspection_CloseDiscalimer];
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

#pragma mark - 点击预约年检
- (void)vehicleDetectionClick       {
    [SOSDaapManager sendActionInfo:Inspection_Reservation];
    NNDispatcherReq *req = [[NNDispatcherReq alloc]init];
//    [req setUrl:SL_ExamVehicle_URL];
    [req setDispatchFrom:soskWebDispatch_External];
    [req setDispatchKey:@"inspection"];
    [req setPartner_id:@"vcyber"];
    [req setContentType:@"JSON"];
    [req setMethod:@"POST"];
    [req setAttributeData:@"idpUserID,vin,licensePlate,enginNumber,mobilePhoneNumber,emailAddress,location,make,model"];
    [req setLongitude:NONil(((SOSPOI *)[[CustomerInfo sharedInstance] currentPositionPoi]).longitude)];
    [req setLatitude:NONil(((SOSPOI *)[[CustomerInfo sharedInstance] currentPositionPoi]).latitude)];
    SOSWebViewController *web = [[SOSWebViewController alloc]initWithDispatcher:req];
    web.titleStr = @"预约年检";
    [self.navigationController pushViewController:web animated:YES];

}

@end
