//
//  OwnerLifeRenewalController.m
//  Onstar
//
//  Created by Apple on 17/1/9.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "OwnerLifeRenewalController.h"
#import "CustomCover.h"
#import "DatePickerView.h"
#import "RequestDataObject.h"
 
#import "CustomerInfo.h"
#import "LoadingView.h"
#import "AccountInfoUtil.h"
#import "OwnerLifeBannerView.h"
#import "SOSCheckRoleUtil.h"
#import "PushNotificationManager.h"

@interface OwnerLifeRenewalController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) CustomCover *cover;
@property (nonatomic, retain) DatePickerView *datePickerView;
@property (nonatomic, retain) OwnerLifeBannerView *bannerView;
@end

@implementation OwnerLifeRenewalController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"换证";
    self.backRecordFunctionID = DriveLicense_back;

    [self setupUI];
    [self initDatePickerView];
    [self getSubscriberInfo];
    if ([SOSCheckRoleUtil isDriverOrProxy]) {
        return;
    }
    [self loadBanner];
}

- (void)setupUI
{
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 54;
    [self.view addSubview:_tableView];

    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 180)];
    _tableView.tableFooterView = footerView;

    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(15, 0, self.view.width-30, 0.5)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"969A9E"];
    [footerView addSubview:lineView];

    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, self.view.width-30, 13)];
    infoLabel.text = @"填写驾照到期日，即可收到更换驾照提醒服务";
    infoLabel.font = [UIFont systemFontOfSize:12];
    infoLabel.textColor = [UIColor colorWithHexString:@"969A9E"];
    infoLabel.adjustsFontSizeToFitWidth = YES;
    [footerView addSubview:infoLabel];

    //设置banner
    self.bannerView = [[OwnerLifeBannerView alloc] initWithFrame:CGRectMake(15, 77, self.view.width-30, 90)];
    self.bannerView.viewCtrl = self;
    [footerView addSubview:self.bannerView];
}

#pragma mark - 初始化弹出日期窗口
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

#pragma mark - 加载用户信息
- (void)getSubscriberInfo
{
    [[LoadingView sharedInstance] startIn:self.view withNavigationBar:NO];
    [AccountInfoUtil getAccountInfo:YES Success:^(NNExtendedSubscriber *subscriber) {
        [Util hideLoadView];
        [CustomerInfo sharedInstance].changePhoneNo = subscriber.mobile;
        [CustomerInfo sharedInstance].changeEmailNo = subscriber.email;
        [CustomerInfo sharedInstance].licenseExpireDate = subscriber.licenseExpireDate;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } Failed:^{
        [Util hideLoadView];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

#pragma mark - 加载banner
- (void)loadBanner
{
    [OthersUtil getBannerByCategory:BANNER_RENEW CarOwnersLiv:NO SuccessHandle:^(id responseStr) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            self.bannerView.bannerFunctionIDArray= @[DriveLicense_banner1,DriveLicense_banner2,DriveLicense_banner3,DriveLicense_banner4,DriveLicense_banner5];
            self.bannerView.imageArray = [NNBanner mj_objectArrayWithKeyValuesArray:responseStr];
        });
    } failureHandler:^(NSString *responseStr, NSError *error) {
        
        
    }];
}

#pragma mark - tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellid = @"cellid";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellid];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [UIColor colorWithHexString:@"151b32"];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"151b32"];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    }
    cell.textLabel.text = @"驾照到期日";
    cell.detailTextLabel.text = [CustomerInfo sharedInstance].licenseExpireDate;
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"me_right_arrow"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[[SOSReportService shareInstance] recordActionWithFunctionID:DriveLicense_expirydate];
    [self openDateWindow];
}

#pragma mark - 日期窗口
#pragma mark 弹出日期窗口
- (void)openDateWindow{
    if (!_cover) {
        _cover = [CustomCover coverWithTarget:self action:@selector(closeDateWindow) coverAlpha:0.35];
        _cover.frame = [[UIScreen mainScreen] bounds];
    }
    [[[UIApplication sharedApplication] keyWindow] addSubview:_cover];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_datePickerView];
    
    [SOSDaapManager sendActionInfo:DriveLicense_expirydate];
    //设置datePicker默认日期
    if (IsStrEmpty([CustomerInfo sharedInstance].licenseExpireDate)) {
        [_datePickerView.datePicker setDate:[NSDate date] animated:NO];
    }
    else
    {
        [_datePickerView.datePicker setDate:[[DatePickerView dateFormatter] dateFromString:[CustomerInfo sharedInstance].licenseExpireDate] animated:NO];
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
- (void)selectDate  {
    _cover.alpha = 0.0;
    _datePickerView.top = self.view.bottom;
    [_cover removeFromSuperview];
    [_datePickerView removeFromSuperview];

    NSString *dt = [[DatePickerView dateFormatter] stringFromDate:_datePickerView.datePicker.date];
    if ([dt isEqualToString:[CustomerInfo sharedInstance].licenseExpireDate]) return;
    [self updateLicenseExpireDate:dt compCallback:^{
        //根据选择的日期，进行相应的消息推送
        [PushNotificationManager settingLicenseExpireAlertAndPush:_datePickerView.datePicker.date isAlert:YES];
        [CustomerInfo sharedInstance].licenseExpireDate = dt;
        [self.tableView reloadData];
    }];
}

#pragma mark - 更新驾照到期日
- (void)updateLicenseExpireDate:(NSString *)date compCallback:(void (^)(void))compCallback
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

@end
