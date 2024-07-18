//
//  ChargeModeViewController.m
//  Onstar
//
//  Created by Vicky on 15/12/1.
//  Copyright © 2015年 Shanghai Onstar. All rights reserved.
//

#import "ChargeModeViewController.h"
#import "CustomerInfo.h"
#import "AppPreferences.h"
#import "ServiceController.h"
#import "LoadingView.h"
#import "CommuteScheduleViewController.h"
#import "ResponseDataObject.h"
#import "SOSSwitch.h"
@interface ChargeModeViewController ()<UITableViewDelegate,UITableViewDataSource,SOSSwitchDelegate>{
//    NSString *selectedChargeMode;
//    __weak IBOutlet NSLayoutConstraint *bottomHY;
    BOOL flagStartGetData;
    NSString * chargeNotiUrl;
}
@property (strong,nonatomic) UITableView *mainTable;
@property(nonatomic,strong)NSIndexPath * selectTypePath;
@property(nonatomic,strong)NSArray * chargeModeSource;
@property(nonatomic,assign)BOOL chargeNotifyOpen;
@property(nonatomic,strong)SOSSwitch * sw;
@end

@implementation ChargeModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configDataSource];
    [self configUI];
    [self requestChargeModeProfile];
    [self requestChargeNotifyStatus];
}
/***********/
#pragma mark --UI
-(void)configDataSource{
    _chargeModeSource = @[@{@"title":@"即插充电",@"detail":@"接通电源立即充电",@"type":@""},@{@"title":@"延迟充电",@"detail":@"在设置时间前完成充电",@"type":@""},@{@"title":@"智能充电",@"detail":@"根据电费率与出发时间延迟充电",@"type":@""}];
}
-(void)configUI{
    self.title = @"充电设置";
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithHexString:@"#F3F5FE"];
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view);
        make.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view);
//        make.height.mas_equalTo(191);
    }];
    UILabel *label = [[UILabel alloc] init];
    [view addSubview:label];
    [label setTextColor:[UIColor colorWithHexString:@"#828389"]];
    [label setFont:[UIFont systemFontOfSize:12.0f]];
    [label setText:@"充电完成、充电中断提醒"];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(17);
        make.top.mas_equalTo(9);
    }];
    
    UIButton * saveButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton setNSButtonStyle];
    [saveButton addTarget:self action:@selector(buttonSaveTapped) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:saveButton];
    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(93);
        make.trailing.mas_equalTo(-93);
        make.bottom.mas_equalTo(view).mas_offset(-16);
        make.height.mas_equalTo(37);
    }];
    
    if (!_mainTable) {
        _mainTable = [[UITableView alloc] init];
        _mainTable.delegate = self;
        _mainTable.dataSource = self;
        _mainTable.scrollEnabled = NO;
        [self.view addSubview:_mainTable];
        [_mainTable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.view);
            make.trailing.mas_equalTo(self.view);
            make.top.mas_equalTo(self.view).mas_offset(10);
            make.bottom.mas_equalTo(view.mas_top);
            make.height.mas_equalTo(402);

        }];
    }
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger row;
    switch (section) {
        case 0:
            row = _chargeModeSource.count;
            break;
        default:
            row = 1;
            break;
    }
    return row;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section    {
    if (section == 2) {
        return 0.0f;
    }
    return 10.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section    {
    return 34.0f;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 2) {
        return nil;
    }
    NSString * reuseID = @"footer_cell";
    UITableViewHeaderFooterView * footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseID];
    if (!footer) {
        footer = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:reuseID];
        footer.contentView.backgroundColor = [SOSUtil onstarLightGray];
    }
    
    return footer;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section    {
    
    NSString * reuseID = @"header_cell";
    UITableViewHeaderFooterView * header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseID];
    if (!header) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:reuseID];
        UIView *tag = UIView.new;
        tag.backgroundColor = SOSUtil.defaultLabelLightBlue;
        [header addSubview:tag];
        [tag mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(header);
            make.centerY.equalTo(header);
            make.height.equalTo(@16);
            make.width.equalTo(@4);
        }];
        UIView *lineTop = UIView.new;
        lineTop.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:244/255.0 alpha:1.0];
        [header addSubview:lineTop];
        [lineTop mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.right.top.equalTo(header);
            make.height.equalTo(@1);
        }];
        UIView *lineBottom = UIView.new;
        lineBottom.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:244/255.0 alpha:1.0];
        [header addSubview:lineBottom];
        [lineBottom mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.bottom.right.equalTo(header);
            make.height.equalTo(@1);
        }];
    }
    NSString * title ;
    switch (section) {
        case 0:
            title = @"充电模式";
            break;
        case 1:
            title = @"提醒设置";
            break;
        case 2:
            title = @"通知设置";
            break;
        default:
            title = @"";
            break;
    }
    [header.textLabel setText:title];
    return header;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[SOSUtil defaultLabelLightBlue]];
    [header.textLabel setFont:[UIFont systemFontOfSize:14.0f]];
    header.contentView.backgroundColor = UIColor.whiteColor;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chagrgeCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"chagrgeCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.detailTextLabel.textColor =[UIColor colorWithHexString:@"#828389"];
            }
            
            cell.textLabel.text = [[_chargeModeSource objectAtIndex:indexPath.row] objectForKey:@"title"];
            cell.detailTextLabel.text = [[_chargeModeSource objectAtIndex:indexPath.row] objectForKey:@"detail"];
            
            if (_selectTypePath) {
                if ([_selectTypePath isEqual:indexPath]) {
                    [self updateSelectIconForCell:cell isAdd:YES];
                }    else    {
                    [self updateSelectIconForCell:cell isAdd:NO];
                }
            }
            return cell;
        }
            break;
        case 1:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timeCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"timeCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.text = @"出发时间";
            }
            return cell;
        }
            break;
        case 2:
        {
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"nitiCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"nitiCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, SCREEN_WIDTH);
                _sw = [[SOSSwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
                _sw.delegate = self;
                cell.accessoryView = _sw;
            }
            cell.textLabel.text = @"充电通知";
            
            return cell;
        }
            break;
        default:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"unknowCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"unknowCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            return cell;
        }
            break;
    }
    
}
//懒得继承tableviewcell重写setselect方法了..
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath        {
    
    if (indexPath.section == 0) {
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
           if (_selectTypePath != indexPath) {
               UITableViewCell * secell = [tableView cellForRowAtIndexPath:_selectTypePath];
               [self updateSelectIconForCell:secell isAdd:NO];
               _selectTypePath = indexPath;
               [self updateSelectIconForCell:cell isAdd:YES];
           }    else    {
               _selectTypePath = indexPath;
               [self updateSelectIconForCell:cell isAdd:YES];
           }
    }
    if (indexPath.section == 1) {
        [self requestScheduleTime];
    }
    
}
-(void)updateSelectIconForCell:(UITableViewCell * )cell isAdd:(BOOL)add{
    if (add) {
        if (!cell.accessoryView) {
            UIImageView * selectImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sosvehicle_chargesetting_check"]];
            cell.accessoryView = selectImg;
            cell.textLabel.textColor = [UIColor colorWithHexString:@"#6896ED"];
        }
    }else{
        if (cell.accessoryView) {
            cell.accessoryView = nil;
            cell.textLabel.textColor = [UIColor colorWithHexString:@"#28292F"];
        }
    }
    
}
#pragma mark - 充电模式

-(void)requestChargeModeProfile{
    if (![[ServiceController sharedInstance] canPerformRequest:GET_CHARGE_PROFILE_REQUEST]) {
        return;
    }
    [[LoadingView sharedInstance] startIn:self.view];
    [self startService:GET_CHARGE_PROFILE_REQUEST];
}
#pragma mark - 提醒设置
-(void)requestScheduleTime{
    if (![[ServiceController sharedInstance]canPerformRequest:GET_SCHEDULE_REQUEST]) {
        return;
    }
    [[LoadingView sharedInstance] startIn:self.view];
    [self startService:GET_SCHEDULE_REQUEST];
}

- (void)updateChargeMode{
    if ([[ServiceController sharedInstance].chargeMode isEqualToString:CM_DEFAULT_IMMEDIATE]||[[ServiceController sharedInstance].chargeMode isEqualToString:CM_IMMEDIATE]) {
        [self selectStateForRow:0];
    }else if([[ServiceController sharedInstance].chargeMode isEqualToString:CM_DEPARTURE_BASED]){
        [self selectStateForRow:1];
    }else if([[ServiceController sharedInstance].chargeMode isEqualToString:CM_RATE_BASED]){
        [self selectStateForRow:2];
    }
}
-(void)selectStateForRow:(NSInteger)row{
    _selectTypePath = [NSIndexPath indexPathForRow:row inSection:0];
    [_mainTable reloadRow:row inSection:0 withRowAnimation:UITableViewRowAnimationNone];
}

- (void)buttonSaveTapped {
    if(_selectTypePath){
        if (![[ServiceController sharedInstance]canPerformRequest:SET_CHARGE_PROFILE_REQUEST]) {
            return;
        }
        [[LoadingView sharedInstance] startIn:self.view];
        [self startService:SET_CHARGE_PROFILE_REQUEST];
    }else{
       
        [Util showErrorHUDWithStatus:@"请选择一个充电模式"];
    }
}

//- (IBAction)buttonDepartureTimeTapped:(id)sender {
//    //get departureTime
//    if (![[ServiceController sharedInstance]canPerformRequest:GET_SCHEDULE_REQUEST]) {
//        return;
//    }
//    [[LoadingView sharedInstance] startIn:self.view];
//    [self startService:GET_SCHEDULE_REQUEST];
//    [SOSDaapManager sendActionInfo:SS_chargeoption_departuretime];
//    
//}

- (void)startService:(NSString *) requestName     {
    @weakify(self)
    ServiceController * service = [ServiceController sharedInstance];
    service.vin = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin;
    service.migSessionKey = [CustomerInfo sharedInstance].mig_appSessionKey;
   
    if ([requestName isEqualToString:SET_CHARGE_PROFILE_REQUEST]) {
        NSString * selectedChargeMode;
           switch (_selectTypePath.row) {
               case 0:
                   selectedChargeMode = CM_IMMEDIATE;
                   break;
                   case 1:
                   selectedChargeMode = CM_DEPARTURE_BASED;
                   break;
                   case 2:
                   selectedChargeMode = CM_RATE_BASED;
                   break;
               default:
                   selectedChargeMode = CM_IMMEDIATE;
                   break;
           }
        service.chargeMode = selectedChargeMode;
        NSString *rateType = @"PEAK";
        if ([ServiceController sharedInstance].rateType) {
            rateType = [ServiceController sharedInstance].rateType;
        }
        service.rateType = rateType;
    }
    [[ServiceController sharedInstance] updatePerformVehicleService];
    [service startFunctionWithName:requestName startSuccess:^(id result) {
        NSString *resultStr = (NSString *)result;
        if ([resultStr isEqualToString:@"polling success"]) {
            NSLog(@"start success*\n*");
        }
        
    } startFail:^(id result) {
        @strongify(self);
        NSString *errorCode = (NSString *)result;
        if ([errorCode isEqualToString:NETWORK_TIMEOUT]) {
            [self getAlertInfoFromCurrentRequest:requestName andStaus:RemoteControlStatus_OperateTimeout andCode:errorCode];
        }else if([errorCode isEqualToString:BACKEND_ERROR]){
            [self getAlertInfoFromCurrentRequest:requestName andStaus:RemoteControlStatus_OperateFail andCode:errorCode];
        }else{
            [self getAlertInfoFromCurrentRequest:requestName andStaus:RemoteControlStatus_OperateFail andCode:errorCode];
        }
        NSLog(@"start failed*\n*");
    } askSuccess:^(id result) {
        [Util alertUserEvluateApp];
        @strongify(self);
        if ([requestName isEqualToString:SET_CHARGE_PROFILE_REQUEST]) {
            [self getAlertInfoFromCurrentRequest:requestName andStaus:RemoteControlStatus_OperateSuccess andCode:nil];
        }
        if([requestName isEqualToString:GET_SCHEDULE_REQUEST]){
            [self handleScheduleTimeResult:result];
        }
        if ([requestName isEqualToString:GET_CHARGE_PROFILE_REQUEST]) {
            [self handleChargeModeResult:result];
        }
        
    } askFail:^(id result) {
        @strongify(self);
        NSString *errorCode = (NSString *)result;
        if ([errorCode isEqualToString:NETWORK_TIMEOUT]) {
            [self getAlertInfoFromCurrentRequest:requestName andStaus:RemoteControlStatus_OperateTimeout andCode:errorCode];
        }else if([errorCode isEqualToString:BACKEND_ERROR]){
            [self getAlertInfoFromCurrentRequest:nil andStaus:RemoteControlStatus_Void andCode:errorCode];
        }else{
            [self getAlertInfoFromCurrentRequest:requestName andStaus:RemoteControlStatus_OperateFail andCode:errorCode];
        }
        
        NSLog(@"polling failed*\n*");
        
    }];
}

- (void)getAlertInfoFromCurrentRequest:(NSString *) requestName andStaus:(RemoteControlStatus) status andCode:(NSString *) code{
    NSString *alertInfos = @"";
    int i = 0;
    if ([requestName isEqualToString:SET_CHARGE_PROFILE_REQUEST])
    {
        if (status == RemoteControlStatus_OperateSuccess){
            alertInfos = NSLocalizedString(@"phev_setChargeMode_success", @"");
            i = 1;
        }else if(status == RemoteControlStatus_OperateFail){
            alertInfos = [NSString stringWithFormat:NSLocalizedString(@"phev_setChargeMode_fail", nil)];
            i = 0;
        }else if(status == RemoteControlStatus_OperateTimeout){
            alertInfos = NSLocalizedString(@"phev_setChargeMode_timeout", @"");
            i = 0;
        }else{
            alertInfos = NSLocalizedString(BACKEND_ERROR, @"");
        }
    }
    
    if ([requestName isEqualToString:GET_SCHEDULE_REQUEST]) {
        if(status == RemoteControlStatus_OperateFail){
            alertInfos = NSLocalizedString(@"phev_getSchedule_fail", @"");
            i = 0;
        }else if(status == RemoteControlStatus_OperateTimeout){
            alertInfos = NSLocalizedString(@"phev_getSchedule_timeout", @"");
            i = 0;
        }else{
            alertInfos = NSLocalizedString(BACKEND_ERROR, @"");
        }
    }
    
    if ([requestName isEqualToString:GET_CHARGE_PROFILE_REQUEST]) {
        if(status == RemoteControlStatus_OperateFail){
            alertInfos = NSLocalizedString(@"phev_getChargeMode_fail", @"");
        }else if(status == RemoteControlStatus_OperateTimeout){
            alertInfos = NSLocalizedString(@"phev_getChargeMode_timeout", @"");
           
        }else{
            alertInfos = NSLocalizedString(BACKEND_ERROR, @"");
            
        }
        i = 3;
    }
    [Util hideLoadView];
    [Util showAlertWithTitle:nil message:alertInfos completeBlock:i == 3?^(NSInteger buttonIndex) {
        [self.navigationController popViewControllerAnimated:YES];
    }:nil];
}

//commute schedule list
- (void)handleScheduleTimeResult:(NSDictionary *)dic{
     [[LoadingView sharedInstance] stop];
    if (dic) {
        NSArray *scheduleList = [[[[dic objectForKey:@"commandResponse"] objectForKey:@"body"] objectForKey:@"weeklyCommuteSchedule"] objectForKey:@"dailyCommuteSchedule"];
        [CustomerInfo sharedInstance].scheduleList = scheduleList;
        CommuteScheduleViewController *scheduleVC = [[CommuteScheduleViewController alloc]init];
            [self.navigationController pushViewController:scheduleVC animated:YES];
    }
}


- (void)handleChargeModeResult:(NSDictionary *)dic{
    if (dic) {
        NSString *chargeMode = [[[[dic objectForKey:@"commandResponse"]objectForKey:@"body"]objectForKey:@"chargingProfile"] objectForKey:@"chargeMode"];
        NSString *rateType = [[[[dic objectForKey:@"commandResponse"]objectForKey:@"body"]objectForKey:@"chargingProfile"]objectForKey:@"rateType"];
        [ServiceController sharedInstance].chargeMode = chargeMode;
        [ServiceController sharedInstance].rateType = rateType;
        [[LoadingView sharedInstance] stop];
        [self updateChargeMode];
    }
}
#pragma mark -充电通知设置
- (void)sosSwitchValueChanged:(SOSSwitch *)sosSwitch{
        NNChargeNot *chargeNot = [[NNChargeNot alloc] init];
        [chargeNot setChargeSwitch:sosSwitch.on];
        NSString *postStr = [chargeNot mj_JSONString];
        [[LoadingView sharedInstance] startIn:self.view];

        SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:[self fetchChargeNotifyUrl] params:postStr successBlock:^(SOSNetworkOperation *operation, id responseStr) {
            [[LoadingView sharedInstance] stop];
            
            NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];

            if ([dic[@"code"] isEqualToString:@"E0000"]) {

                    [Util showSuccessHUDWithStatus:NSLocalizedString(@"Success_S", nil)];


            }else{
                    sosSwitch.on = !sosSwitch.on;
                [Util showErrorHUDWithStatus:NSLocalizedString(@"Failed_try", nil)];
          
            }
            
        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            
            [[LoadingView sharedInstance] stop];
            sosSwitch.on = !sosSwitch.on;
             [Util showErrorHUDWithStatus:NSLocalizedString(@"Failed_try", nil)];
        }];
        [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
        [operation setHttpMethod:@"PUT"];
        [operation start];
}

-(void)chargeNotifyState:(BOOL)open{
    _chargeNotifyOpen = open;
    [_sw setOn:open];
}
-(NSString *)fetchChargeNotifyUrl{
    if (!chargeNotiUrl) {
        chargeNotiUrl = [BASE_URL stringByAppendingFormat:NEW_phevCharge,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    }
    return chargeNotiUrl;
}
-(void)requestChargeNotifyStatus{
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:[self fetchChargeNotifyUrl] params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        if (dic) {
            [self chargeNotifyState:[dic[@"chargeComplete"] boolValue]];
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];
}

@end
