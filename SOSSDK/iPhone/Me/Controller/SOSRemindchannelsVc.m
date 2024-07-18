//
//  SOSRemindchannelsVc.m
//  Onstar
//
//  Created by Genie Sun on 2017/3/14.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSRemindchannelsVc.h"
#import "SOSRemindTableViewCell.h"
#import "SOSTipTableViewCell.h"
#import "SOSRemindSet.h"
#import "CustomerInfo.h"
#import "SOSAlertRemindSet.h"
#import "NSString+JWT.h"

@interface SOSRemindchannelsVc ()<SOSTipTableViewCellDelegate>
@property(nonatomic, strong) NSMutableArray  *titleArray;
@property(nonatomic, strong) NSMutableArray  *tipArray; //cell count
@property(nonatomic, strong) NSArray *tipLbArray; // tip message
@property(nonatomic, assign) BOOL wechatFlg; //是否注册过wechat
@property(nonatomic, strong) NNNotifyConfig *notObject;
@property(nonatomic, strong) NSArray *switchArray;
@property(nonatomic, assign) BOOL setPhoneNo;
@property(nonatomic, assign) BOOL setMailNo;
@end

@implementation SOSRemindchannelsVc

- (instancetype)initWithNibName:(NSString *)nibNameOrNil channerlsType:(channelsType)type 
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        // Custom initialization
        self.channelsType = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.table setTableFooterView:[UIView new]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _wechatFlg = NO;
    _tipArray = [[NSMutableArray alloc] init];
    _titleArray = [[NSMutableArray alloc] init];
    
    [self getNotifyConfigData:self.channelsType reload:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([[_tipArray[indexPath.row] objectForKey:@"Cell"] isEqualToString:@"SOSRemindTableViewCell"]) {
        return 54.f;
    }else  if([[_tipArray[indexPath.row] objectForKey:@"Cell"] isEqualToString:@"SOSTipTableViewCell"]) {
        CGSize size = [[_tipArray[indexPath.row] objectForKey:@"titlename"] boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 30, FLT_MAX) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:12.0f]} context:nil].size;
        return size.height + 20.f;
    }else  if([[_tipArray[indexPath.row] objectForKey:@"Cell"] isEqualToString:@"SOSTipQrTableViewCell"]) {
        return 108.f;
    }else{
        return 0.f;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tipArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([[_tipArray[indexPath.row] objectForKey:@"Cell"] isEqualToString:@"SOSRemindTableViewCell"]) {
        static NSString *identifier = @"cell";
        SOSRemindTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        cell = [[NSBundle SOSBundle] loadNibNamed:@"SOSRemindTableViewCell" owner:self options:nil][0];
        cell.titleName.text = [_tipArray[indexPath.row] objectForKey:@"titlename"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        if (self.channelsType == FaultDiagnosis && indexPath.row == 0){
            cell.switchbtn.hidden = YES;
        }

        //设置switch 开启关闭
        [cell createSwitchStatus:[[_tipArray[indexPath.row] objectForKey:@"isSwithOn"] boolValue]];
        [cell changeSwitchValue:^(UISwitch *switchBtn) {
            [self addOrdeleteCellwithSwitchOn:switchBtn indexpath:indexPath];
        }];
        return cell;
    }else  if([[_tipArray[indexPath.row] objectForKey:@"Cell"] isEqualToString:@"SOSTipTableViewCell"]) {
        
        static NSString *identifier = @"cell";
        SOSTipTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

        cell = [[NSBundle SOSBundle] loadNibNamed:@"SOSTipTableViewCell" owner:self options:nil][0];
        cell.delegate = self;
        
        if ([[_tipArray[indexPath.row] objectForKey:@"titlename"] isEqualToString:@"暂未设置提醒手机号码，短信无法发送，请先"]) {
            cell.titleLb.hidden = YES;
            cell.detailLb.hidden = NO;
            cell.detailLb.text = @"暂未设置提醒手机号码，短信无法发送，请先";
            cell.setNo.hidden = NO;
        }else if ([[_tipArray[indexPath.row] objectForKey:@"titlename"] isEqualToString:@"暂未设置提醒邮箱，邮件无法发送，请先"]){
            cell.titleLb.hidden = YES;
            cell.detailLb.hidden = NO;
            cell.detailLb.text = @"暂未设置提醒邮箱，邮件无法发送，请先";
            cell.setNo.hidden = NO;
        }else{
            cell.titleLb.text = [_tipArray[indexPath.row] objectForKey:@"titlename"];
            cell.titleLb.hidden = NO;
            cell.detailLb.hidden = YES;
            cell.setNo.hidden = YES;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else {
        return nil;
    }
}

///添加cell
- (void)addCell:(UISwitch *)sender {
    SOSRemindTableViewCell *cell = (SOSRemindTableViewCell *)sender.superview.superview;
    NSIndexPath *indexPath = [self.table indexPathForCell:cell];
    NSDictionary * addDic;
    
    if ([cell.titleName.text isEqualToString:_titleArray[0]]) {
        addDic = @{@"Cell": @"SOSTipTableViewCell",@"titlename":_tipLbArray[0]};
    }else if ([cell.titleName.text isEqualToString:_titleArray[1]]){

        addDic = @{@"Cell": @"SOSTipTableViewCell",@"titlename":_tipLbArray[1]};

    }else if ([cell.titleName.text isEqualToString:_titleArray[2]]){
        addDic = @{@"Cell": @"SOSTipTableViewCell",@"titlename":_tipLbArray[2]};
    }
    
    NSIndexPath *path = [NSIndexPath indexPathForItem:(indexPath.row + 1) inSection :indexPath.section];
    [self.tipArray insertObject:addDic atIndex:path.row];
    [self.table beginUpdates];
    [self.table insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.table endUpdates];
}

///删除cell
- (void)deleteCell:(UISwitch *)sender {
    SOSRemindTableViewCell *cell = (SOSRemindTableViewCell *)sender.superview.superview;
    NSIndexPath *indexPath =[self.table indexPathForCell:cell];
    
    NSIndexPath *path = [NSIndexPath indexPathForItem:(indexPath.row + 1) inSection :indexPath.section];
    [self.tipArray removeObjectAtIndex:path.row];
    [self.table beginUpdates];
    [self.table deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
    [self.table endUpdates];
}

- (void)createUIwithData:(NSArray*)arr
{
    NSUInteger y = arr.count,t = 0;
    for (int i = 0; i < y; i++) {
        NSIndexPath *path = [NSIndexPath indexPathForItem:i inSection :0];
        NSDictionary * addDic = @{@"Cell":@"SOSRemindTableViewCell",@"isSwithOn":arr[t],@"titlename":_titleArray[t]};
        [self.tipArray insertObject:addDic atIndex:path.row];
        if ([arr[t] boolValue]) {
            NSIndexPath *pathTip = [NSIndexPath indexPathForItem:(i + 1) inSection:0];
            NSDictionary * addTipDic;

            addTipDic = @{@"Cell": @"SOSTipTableViewCell",@"titlename":_tipLbArray[t]};

            [self.tipArray insertObject:addTipDic atIndex:pathTip.row];
            i++;
            y++;
        }
        t ++;
    }
}

- (NSString *)getRequestCommandWithChannelsType:(channelsType)channelType	{
    //  数组顺序和 channelsType 枚举值 位置一一对应
    NSArray *commandsArray = @[@"TAN", @"OVD", @"DIAGNOSTICALERT", @"SMARTDRIVER", @"FUELECONOMY", @"UBI", @"ENERGYCONSUMPTION",    @"DOOR_UNLOCK", @"TRUNK_UNLOCK", @"WINDOW_UNLOCK", @"SUNROOF_UNLOCK", @"HEADLIGHT_ON", @"IGNITION_ON", @"WARNINGLIGHT_ON"];
    return commandsArray[channelType];
}

- (void)getNotifyConfigData:(channelsType)channelType reload:(BOOL)flag {
    if (!flag) {
        [Util showLoadingView];
    }
    
    //  数组顺序和 channelsType 枚举值 位置一一对应
    NSArray *backRecordFunctionIDArray = @[NS_TAN_back, NS_OVD_back, NS_DA_back, @"", @"", @""    , @"", @"", @"", @"", @"", @"", @"", @""];
    NSString *bType = [self getRequestCommandWithChannelsType:channelType];
    NSString *backID = backRecordFunctionIDArray[channelType];
    if (backID.length)	self.backRecordFunctionID = backID;
    
    [SOSRemindSet notigyConfigInformation:@"GET" body:nil btype:bType Success:^(NNNotifyConfig *notify) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.notObject = notify;
            if (flag)	return;
            
            if ([Util isBlankString:notify.phone])	_setPhoneNo = YES;
            else									_setPhoneNo = NO;
            
            if ([Util isBlankString:notify.mail]) 	_setMailNo = YES;
            else									_setMailNo = NO;
            
            [self setConfigUI:[Util recodesign:notify.phone] mail:[self.notObject.mail stringEmailInterceptionHide]];
            
            switch (channelType) {
                case StolenRemind:
                    _switchArray = @[notify.sms_checked,notify.mobile_checked,[Util isBlankString:notify.iscall] ? @"0" : notify.iscall];
                    break;
                case TestReport:
                    _switchArray = @[notify.mobile_checked,notify.wechat_checked,notify.sms_checked];
                    break;
                case FaultDiagnosis:
                    _switchArray = @[@(YES),notify.sms_checked,notify.mail_checked];
                    break;
                default:
                    _switchArray = @[notify.sms_checked,notify.mobile_checked];
                    break;
            }
            [self createUIwithData:_switchArray];
            [self.table reloadData];
        });
        
    } Failed:^{ 	}];
}

- (void)setConfigUI:(NSString *)phoneStr mail:(NSString *)mailStr	{
    NSArray *temptitleArray = @[@"车辆报警提示", @"车况检测报告提醒", @"车辆实时检测提醒", @"驾驶行为评价提醒", @"油耗水平排名提醒", @"车联保险提醒", @"能耗水平排名提醒",
    @"停车车门未锁提醒", @"停车后备箱未关提醒",  @"停车车窗未关提醒", @"停车天窗未关提醒", @"停车大灯未关提醒", @"停车发动机未熄火提醒", @"双闪警示灯未关提醒"];
    NSString *titleStr = temptitleArray[self.channelsType];
    self.title = [NSString stringWithFormat:@"%@渠道设置", titleStr];
    
    switch (self.channelsType) {
        case StolenRemind:	{
            [_titleArray addObjectsFromArray:@[@"短信提醒", @"手机应用推送提醒", @"电话提醒"]];
            _tipLbArray = @[self.setPhoneNo ? @"暂未设置提醒手机号码，短信无法发送，请先" : [NSString stringWithFormat:@"车辆报警提示通知将自动发送至您的手机 %@",phoneStr],
                            @"安吉星手机APP将自动向您推送车辆报警提示信息",
                            self.setPhoneNo ? @"暂未设置提醒手机号码，短信无法发送，请先" : [NSString stringWithFormat:@"当车辆被盗发生于每日07:00-22:00分期间，安吉星坐席电话将与您的手机号码%@联系",phoneStr]];
            if ([CustomerInfo sharedInstance].currentVehicle.gen10) {
                self.gen10Tip.hidden = NO;
                [self.gen10Tip sizeToFit];
            }	else	{
                self.gen9Tip.hidden = NO;
                [self.gen9Tip sizeToFit];
            }
            break;
        }
        case TestReport:	{
            [_titleArray addObjectsFromArray:@[@"手机应用推送提醒", @"微信提醒", @"短信提醒"]];
            _tipLbArray = @[@"安吉星手机APP将自动向您推送车况检测报告提醒",
                            @"您已经在微信中绑定车辆，请登录微信号查看车况检测报告",
                            self.setPhoneNo ? @"暂未设置提醒手机号码，短信无法发送，请先" : [NSString stringWithFormat:@"车况检测报告提醒通知将自动发送至您的手机  %@",phoneStr]];
            break;
        }
        case FaultDiagnosis:	{
            [_titleArray addObjectsFromArray:@[@"手机应用推送提醒", @"短信提醒", @"邮件提醒"]];
            _tipLbArray = @[@"安吉星手机APP将自动向您推送车辆实时检测提醒",
                            self.setPhoneNo ? @"暂未设置提醒手机号码，短信无法发送，请先" : [NSString stringWithFormat:@"车辆实时检测报告提醒通知将自动发送至您的手机 %@",phoneStr],
                            self.setMailNo ? @"暂未设置提醒邮箱，邮件无法发送，请先" : [NSString stringWithFormat:@"车辆实时检测提醒通知将自动发送至您邮箱  %@",mailStr]];
            break;
        }
        case SmartDriver:	{
            [_titleArray addObjectsFromArray:@[@"短信提醒",
                                               @"手机应用推送提醒"]];
            _tipLbArray = @[self.setPhoneNo ? @"暂未设置提醒手机号码，短信无法发送，请先" : [NSString stringWithFormat:@"驾驶行为分析报告提醒通知将自动发送至您的手机 %@",phoneStr],
                            @"安吉星手机APP将自动向您推送驾驶行为分析报告提醒信息"];
            break;
        }
        case FUELEconomy:	{
            [_titleArray addObjectsFromArray:@[@"短信提醒",
                                               @"手机应用推送提醒"]];
            _tipLbArray = @[self.setPhoneNo ? @"暂未设置提醒手机号码，短信无法发送，请先" : [NSString stringWithFormat:@"油耗排名提醒通知将自动发送至您的手机 %@",phoneStr],
                            @"安吉星手机APP将自动向您推送油耗排名提醒信息"];
            break;
        }
        case Ubi:	{
            [_titleArray addObjectsFromArray:@[@"短信提醒",
                                               @"手机应用推送提醒"]];
            _tipLbArray = @[self.setPhoneNo ? @"暂未设置提醒手机号码，短信无法发送，请先" : [NSString stringWithFormat:@"UBI报价提醒通知将自动发送至您的手机 %@",phoneStr],
                            @"安吉星手机APP将自动向您推送UBI报价提醒信息"];
            break;
        }
        case EnergyEconomy:		{
            [_titleArray addObjectsFromArray:@[@"短信提醒",
                                               @"手机应用推送提醒"]];
            _tipLbArray = @[self.setPhoneNo ? @"暂未设置提醒手机号码，短信无法发送，请先" : [NSString stringWithFormat:@"能耗排名提醒通知将自动发送至您的手机 %@",phoneStr],
                            @"安吉星手机APP将自动向您推送能耗排名提醒信息"];
            break;
        }
        //停车车辆状态提醒
        default:    {
            [_titleArray addObjectsFromArray:@[@"短信提醒",
                                               @"手机应用推送提醒"]];
            _tipLbArray = @[self.setPhoneNo ? @"暂未设置提醒手机号码，短信无法发送，请先" : [NSString stringWithFormat:@"停车车辆状态提醒通知将自动发送至您的手机 %@", phoneStr],
                            [NSString stringWithFormat:@"开通后安吉星手机应用将自动向您推送停车车辆状态提醒"]];
            break;
        }
    }
}

- (void)addOrdeleteCellwithSwitchOn:(UISwitch *)sender indexpath:(NSIndexPath *)indexPath0		{
    SOSRemindTableViewCell *cell = (SOSRemindTableViewCell *)sender.superview.superview;
    NSIndexPath *indexPath = [self.table indexPathForCell:cell];
    if (sender.on) {
        if (self.channelsType == TestReport && [[_tipArray[indexPath.row] objectForKey:@"titlename"] isEqualToString:@"微信提醒"]) {
            [SOSRemindSet validatenotifyConfigWithVinSuccess:^(BOOL flag) {
                
                self.wechatFlg = flag;
                if (!flag) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        SOSAlertRemindSet *setAlert = [[NSBundle SOSBundle] loadNibNamed:@"SOSAlertRemindSet" owner:self options:nil][0];
                        setAlert.center = CGPointMake((SCREEN_WIDTH) / 2, (SCREEN_HEIGHT - 125)/ 2);
                        [setAlert showShareReportView];
                        [sender setOn:NO animated:YES];
                    });
                }else{
                    dispatch_async_on_main_queue(^{
                        [self commandDataswicthBtn:sender type:addcell];
                    });
                }
            } Failed:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [sender setOn:NO animated:YES];
                });
                
            }];
        }	else	{
            [self commandDataswicthBtn:sender type:addcell];
        }
    }	else	{
        [self commandDataswicthBtn:sender type:deleteCell];
    }
}


- (void)commandDataswicthBtn:(UISwitch *)sender type:(cellType)type{
    
    SOSRemindTableViewCell *cell = (SOSRemindTableViewCell *)sender.superview.superview;

    NNNotifyConfigRequest *request = [[NNNotifyConfigRequest alloc] init];
    NSString *bType = [self getRequestCommandWithChannelsType:self.channelsType];
    
    [request setBtype:bType];
    [request setSubscriber_id:[CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId];
    [request setVin:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    
    [request setPhone:self.notObject.phone];
    [request setMail:self.notObject.mail];
    [request setOldphone:self.notObject.oldphone];
    NSString *cusStr;
    if (type == addcell) {
        cusStr = @"1";
    }else if (type == deleteCell){
        cusStr = @"0";
    }
    sender.enabled = NO;
    [self cell:cell request:request cusStr:cusStr changeValue:NO];
    
    [SOSRemindSet notigyConfigInformation:@"PUT" body:[request mj_JSONString] btype:nil Success:^(NNNotifyConfig *notify) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (type == addcell) {
                [self addCell:sender];
                [self cell:cell request:nil cusStr:@"1" changeValue:YES];
            }    else if (type == deleteCell){
                [self deleteCell:sender];
                [self cell:cell request:nil cusStr:@"0" changeValue:YES];
            }
            [self getNotifyConfigData:self.channelsType reload:YES];
            sender.enabled = YES;
        });
    } Failed:^{
        sender.enabled = YES;
        sender.selected = !sender.selected;
    }];
}

- (void)cell:(SOSRemindTableViewCell *)cell request:(NNNotifyConfigRequest *)request cusStr:(NSString *)cusStr changeValue:(BOOL)flag		{
    if (self.channelsType == StolenRemind) {
        if ([cell.titleName.text isEqualToString:_titleArray[0]]) {
            if (flag) {
                //[[SOSReportService shareInstance] recordActionWithFunctionID:[cusStr isEqualToString:@"1"] ? TANSetting_SMSON : TANSetting_SMSOFF];
                [SOSDaapManager sendActionInfo:cusStr.boolValue?NS_TAN_shortmsg_closetoopen: NS_TAN_shortmsg_opentoclose];
                
                [self.notObject setSms_checked:cusStr];
                return;
            }
            [request setSms_checked:cusStr];
            [request setMail_checked:self.notObject.mail_checked];
            [request setWechat_checked:self.notObject.wechat_checked];
            [request setMobile_checked:self.notObject.mobile_checked];
            [request setIscall:NONil(self.notObject.iscall)];
            
        }	else if ([cell.titleName.text isEqualToString:_titleArray[1]]){
            if (flag) {
                //[[SOSReportService shareInstance] recordActionWithFunctionID:[cusStr isEqualToString:@"1"] ? TANSetting_APPNotificationON : TANSetting_APPNotificationOFF];
                [SOSDaapManager sendActionInfo:cusStr.boolValue?NS_TAN_app_closetoopen: NS_TAN_app_opentoclose];
                [self.notObject setMobile_checked:cusStr];
                return;
            }
            [request setSms_checked:self.notObject.sms_checked];
            [request setMail_checked:self.notObject.mail_checked];
            [request setWechat_checked:self.notObject.wechat_checked];
            [request setMobile_checked:cusStr];
            [request setIscall:NONil(self.notObject.iscall)];
            
        }	else if ([cell.titleName.text isEqualToString:_titleArray[2]]){
            if (flag) {
                //[[SOSReportService shareInstance] recordActionWithFunctionID:[cusStr isEqualToString:@"1"] ? TANSetting_MobileNotificationON : TANSetting_MobileNotificationOFF];
                [SOSDaapManager sendActionInfo:cusStr.boolValue?NS_TAN_call_closetoopen: NS_TAN_call_opentoclose];
                [self.notObject setIscall:cusStr];
                return;
            }
            [request setSms_checked:self.notObject.sms_checked];
            [request setMail_checked:self.notObject.mail_checked];
            [request setWechat_checked:self.notObject.wechat_checked];
            [request setMobile_checked:self.notObject.mobile_checked];
            [request setIscall:cusStr];
        }
    }	else if (self.channelsType == TestReport){
        if ([cell.titleName.text isEqualToString:_titleArray[0]]) {
            if (flag) {
                //[[SOSReportService shareInstance] recordActionWithFunctionID:[cusStr isEqualToString:@"1"] ? OVDSetting_APPNotificationON : OVDSetting_APPNotificationOFF];
                [SOSDaapManager sendActionInfo:cusStr.boolValue?NS_OVD_app_opentoclose: NS_OVD_app_closetoopen];
                
                [self.notObject setMobile_checked:cusStr];
                return;
            }
            [request setSms_checked:self.notObject.sms_checked];
            [request setMail_checked:self.notObject.mail_checked];
            [request setWechat_checked:self.notObject.wechat_checked];
            [request setMobile_checked:cusStr];
            [request setIscall:NONil(self.notObject.iscall)];
            
        }	else if ([cell.titleName.text isEqualToString:_titleArray[1]]){
            if (flag) {
                //[[SOSReportService shareInstance] recordActionWithFunctionID:[cusStr isEqualToString:@"1"] ? OVDSetting_WeChatNotificationON : OVDSetting_WeChatNotificationOFF];
                [SOSDaapManager sendActionInfo:cusStr.boolValue?NS_OVD_wechat_closetoopen: NS_OVD_wechat_opentoclose];
                [self.notObject setWechat_checked:cusStr];
                return;
            }
            [request setSms_checked:self.notObject.sms_checked];
            [request setMail_checked:self.notObject.mail_checked];
            [request setWechat_checked:cusStr];
            [request setMobile_checked:self.notObject.mobile_checked];
            [request setIscall:NONil(self.notObject.iscall)];
            
        }	else if ([cell.titleName.text isEqualToString:_titleArray[2]]){
            if (flag) {
                //[[SOSReportService shareInstance] recordActionWithFunctionID:[cusStr isEqualToString:@"1"] ? OVDSetting_SMSON : OVDSetting_SMSOFF];
                [SOSDaapManager sendActionInfo:cusStr.boolValue?NS_OVD_shortmsg_closetoopen: NS_OVD_shortmsg_opentoclose];
                [self.notObject setSms_checked:cusStr];
                return;
            }
            [request setSms_checked:cusStr];
            [request setMail_checked:self.notObject.mail_checked];
            [request setWechat_checked:self.notObject.wechat_checked];
            [request setMobile_checked:self.notObject.mobile_checked];
            [request setIscall:NONil(self.notObject.iscall)];
        }
        
    }	else if (self.channelsType == FaultDiagnosis){
        if ([cell.titleName.text isEqualToString:_titleArray[1]]){
            if (flag) {
                //[[SOSReportService shareInstance] recordActionWithFunctionID:[cusStr isEqualToString:@"1"] ? DASetting_SMSON : DASetting_SMSOFF];
                [SOSDaapManager sendActionInfo:cusStr.boolValue?NS_DA_shortmsg_closetoopen: NS_DA_shortmsg_opentoclose];
                
                [self.notObject setSms_checked:cusStr];
                return;
            }
            [request setSms_checked:cusStr];
            [request setMail_checked:self.notObject.mail_checked];
            [request setWechat_checked:self.notObject.wechat_checked];
            [request setMobile_checked:self.notObject.mobile_checked];
            [request setIscall:NONil(self.notObject.iscall)];
            
        }	else if ([cell.titleName.text isEqualToString:_titleArray[2]]){
            if (flag) {
                //[[SOSReportService shareInstance] recordActionWithFunctionID:[cusStr isEqualToString:@"1"] ? DASetting_EmailNotificationON : DASetting_EmailNotificationOFF];
                [SOSDaapManager sendActionInfo:cusStr.boolValue?NS_DA_email_closetoopen: NS_DA_email_opentoclose];
                
                [self.notObject setMail_checked:cusStr];
                return;
            }
            [request setSms_checked:self.notObject.sms_checked];
            [request setMail_checked:cusStr];
            [request setWechat_checked:self.notObject.wechat_checked];
            [request setMobile_checked:self.notObject.mobile_checked];
            [request setIscall:NONil(self.notObject.iscall)];
        }
    }	else if (self.channelsType == SmartDriver) {
        if ([cell.titleName.text isEqualToString:_titleArray[0]]){
            [request setSms_checked:cusStr];
            [request setMail_checked:self.notObject.mail_checked];
            [request setWechat_checked:self.notObject.wechat_checked];
            [request setMobile_checked:self.notObject.mobile_checked];
            [request setIscall:NONil(self.notObject.iscall)];
            
        }else if ([cell.titleName.text isEqualToString:_titleArray[1]]){
            [request setSms_checked:self.notObject.sms_checked];
            [request setMail_checked:self.notObject.mail_checked];
            [request setWechat_checked:self.notObject.wechat_checked];
            [request setMobile_checked:cusStr];
            [request setIscall:NONil(self.notObject.iscall)];
        }
    }	else if (self.channelsType == FUELEconomy) {
        if ([cell.titleName.text isEqualToString:_titleArray[0]]){
            if (flag) {
                //[[SOSReportService shareInstance] recordActionWithFunctionID:[cusStr isEqualToString:@"1"] ? FuelEconomySetting_SMSON : FuelEconomySetting_SMSOFF];
                [SOSDaapManager sendActionInfo:cusStr.boolValue?NS_notification_oilconsump_sms: NS_notification_oilconsump_closesms];
                
                [self.notObject setMail_checked:cusStr];
                return;
            }
            [request setSms_checked:cusStr];
            [request setMail_checked:self.notObject.mail_checked];
            [request setWechat_checked:self.notObject.wechat_checked];
            [request setMobile_checked:self.notObject.mobile_checked];
            [request setIscall:NONil(self.notObject.iscall)];
            
        }	else if ([cell.titleName.text isEqualToString:_titleArray[1]]){
            if (flag) {
                //[[SOSReportService shareInstance] recordActionWithFunctionID:[cusStr isEqualToString:@"1"] ? FuelEconomySetting_APPNotificationON : FuelEconomySetting_APPNotificationOFF];
                [SOSDaapManager sendActionInfo:cusStr.boolValue?NS_notification_oilconsump_apppush: NS_notification_oilconsump_closeapppush];
                
                [self.notObject setMail_checked:cusStr];
                return;
            }
            [request setSms_checked:self.notObject.sms_checked];
            [request setMail_checked:self.notObject.mail_checked];
            [request setWechat_checked:self.notObject.wechat_checked];
            [request setMobile_checked:cusStr];
            [request setIscall:NONil(self.notObject.iscall)];
        }
    }	else if (self.channelsType == EnergyEconomy) {
        if ([cell.titleName.text isEqualToString:_titleArray[0]]){
            if (flag) {
                //[[SOSReportService shareInstance] recordActionWithFunctionID:[cusStr isEqualToString:@"1"] ? EnergyEconomySetting_SMSON : EnergyEconomySetting_SMSOFF];
                [SOSDaapManager sendActionInfo:cusStr.boolValue?NS_notification_engconsump_sms: NS_notification_engconsump_closesms];
                [self.notObject setMail_checked:cusStr];
                return;
            }
            [request setSms_checked:cusStr];
            [request setMail_checked:self.notObject.mail_checked];
            [request setWechat_checked:self.notObject.wechat_checked];
            [request setMobile_checked:self.notObject.mobile_checked];
            [request setIscall:NONil(self.notObject.iscall)];
            
        }	else if ([cell.titleName.text isEqualToString:_titleArray[1]]){
            if (flag) {
                //[[SOSReportService shareInstance] recordActionWithFunctionID:[cusStr isEqualToString:@"1"] ? EnergyEconomySetting_APPNotificationON : EnergyEconomySetting_APPNotificationOFF];
                [SOSDaapManager sendActionInfo:cusStr.boolValue?NS_notification_engconsump_apppush: NS_notification_engconsump_closeapppush];
                [self.notObject setMail_checked:cusStr];
                return;
            }
            [request setSms_checked:self.notObject.sms_checked];
            [request setMail_checked:self.notObject.mail_checked];
            [request setWechat_checked:self.notObject.wechat_checked];
            [request setMobile_checked:cusStr];
            [request setIscall:NONil(self.notObject.iscall)];
        }
    }	else if (self.channelsType == Ubi) {
        if ([cell.titleName.text isEqualToString:_titleArray[0]]){
            [request setSms_checked:cusStr];
            [request setMail_checked:self.notObject.mail_checked];
            [request setWechat_checked:self.notObject.wechat_checked];
            [request setMobile_checked:self.notObject.mobile_checked];
            [request setIscall:NONil(self.notObject.iscall)];
        }else if ([cell.titleName.text isEqualToString:_titleArray[1]]){
            [request setSms_checked:self.notObject.sms_checked];
            [request setMail_checked:self.notObject.mail_checked];
            [request setWechat_checked:self.notObject.wechat_checked];
            [request setMobile_checked:cusStr];
            [request setIscall:NONil(self.notObject.iscall)];
        }
    }	else	{
        if ([cell.titleName.text isEqualToString:_titleArray[0]]){
            [request setSms_checked:cusStr];
            [request setMail_checked:self.notObject.mail_checked];
            [request setWechat_checked:self.notObject.wechat_checked];
            [request setMobile_checked:self.notObject.mobile_checked];
            [request setIscall:NONil(self.notObject.iscall)];
        }	else if ([cell.titleName.text isEqualToString:_titleArray[1]]){
            [request setSms_checked:self.notObject.sms_checked];
            [request setMail_checked:self.notObject.mail_checked];
            [request setWechat_checked:self.notObject.wechat_checked];
            [request setMobile_checked:cusStr];
            [request setIscall:NONil(self.notObject.iscall)];
        }
    }
}

#pragma mark - SOSTipTableViewCellDelegate
- (void)tapActionToSet:(SOSTipTableViewCell*)cell {

    SOSchangePhmailNumber *change = [[SOSchangePhmailNumber alloc] initWithNibName:@"SOSchangePhmailNumber" bundle:nil];
    if ([cell.detailLb.text isEqualToString:@"暂未设置提醒手机号码，短信无法发送，请先"]) {
        change.pagetype = changephoneNb;
        if (self.channelsType == StolenRemind) {
            //[[SOSReportService shareInstance] recordActionWithFunctionID:TANSetting_MobilePhoneSetting];
        }	else if (self.channelsType == TestReport)	{
            //[[SOSReportService shareInstance] recordActionWithFunctionID:OVDSetting_MobilePhoneSetting];
        }	else	{
            //[[SOSReportService shareInstance] recordActionWithFunctionID:DASetting_MobilePhoneSetting];
        }
    }	else if ([cell.detailLb.text isEqualToString:@"暂未设置提醒邮箱，邮件无法发送，请先"]){
        change.pagetype = changemailNb;
        if (self.channelsType == FaultDiagnosis) {
            //[[SOSReportService shareInstance] recordActionWithFunctionID:DASetting_EmailSetting];
        }
    }
    change.notObject = self.notObject;
    change.info = nil;
    [self.navigationController pushViewController:change animated:YES];
}

@end
