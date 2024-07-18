//
//  SOSMroSettingViewController.m
//  Onstar
//
//  Created by Onstar on 2018/7/3.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSMroSettingViewController.h"
#import "MeSystemSettingsViewCell.h"
#ifndef SOSSDK_SDK
#import "SOSOnstarLinkSDKTool.h"
#endif
#import "SOSMroService.h"

@interface SOSMroSettingViewController ()<UITableViewDelegate,UITableViewDataSource>	{
    
    UITableView    * table;
    NSMutableArray * dataSource;
    NSString * mroOpenOrCloseTip;
    NSString * mroGlobalWakeUpTip;
    UILabel  * mroGlobalWakeUpTipLabel;
}
@property(nonatomic ,assign)    BOOL isMroOpen;
@property(nonatomic ,assign)    BOOL isGlobalWakeUpOpen;
- (void)mroCloseControl:(id)sender;
@end

@implementation SOSMroSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"SettingVC_MrOName", nil);
    // Do any additional setup after loading the view.
    table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    [table registerNib:[UINib nibWithNibName:@"MeSystemSettingsViewCell" bundle:nil] forCellReuseIdentifier:MeSystemSettings_CellID];
    table.delegate = self;
    table.dataSource = self;
    [self.view addSubview:table];
    
    mroOpenOrCloseTip = NSLocalizedString(@"SettingVC_MrOCloseTip", nil);
    //初始
    
    [self configData];
    
}

- (void)configData {
    dataSource = [NSMutableArray array];
    self.isMroOpen = [[Util readMrOOpenFlagByidpid:[CustomerInfo sharedInstance].userBasicInfo.idpUserId] boolValue];
    
    self.isGlobalWakeUpOpen = [SOSMroService  isMroGlobalWakeup];
    
    SystemSettingCellData *mroHelper = [[SystemSettingCellData alloc] init];
    [mroHelper setTitleText:@"语音助手"];
    [mroHelper setCellStyle:CellStyleSwitch];
    [mroHelper setSwitchStyleStatus:self.isMroOpen];
    [mroHelper setCellTarget:self];
    [mroHelper setCellSelector:@selector(mroCloseControl:)];
    [dataSource addObject:mroHelper];
    
    SystemSettingCellData *mroWakeup = [[SystemSettingCellData alloc] init];
    [mroWakeup setTitleText:@"语音唤醒"];
    [mroWakeup setCellStyle:CellStyleSwitch];
    [mroWakeup setSwitchStyleStatus:self.isGlobalWakeUpOpen];
    [mroWakeup setCellTarget:self];
    [mroWakeup setCellSelector:@selector(mroGlobalWakeUpControl:)];
    [dataSource addObject:mroWakeup];
}

/**
 小O开关
 @param sender
 */
- (void)mroCloseControl:(id)sender	{
//    UserDefaults_Set_Bool(YES, @"NEED_NOT_NOTICE_MRO_IN_SETTING");
    UISwitch *controller = (UISwitch *)sender;
    self.isMroOpen = controller.on;
    [self mroCloseSwitchProcess:self.isMroOpen];


    [self configData];
    [table reloadData];
}

- (void)mroCloseSwitchProcess:(BOOL)open{
    if (!open) {
        //小O关闭的话直接 关闭小O全局唤醒
        [self mroGlobalWakeUpCloseSwitchProcess:NO];
    }
    [Util saveMrOOpenFlagByidpid:[CustomerInfo sharedInstance].userBasicInfo.idpUserId withFlag:open];
    // Onstar Link 模块暂离时, 不改变小O设置, 待 Onstar Link 模块恢复后再改变
#ifndef SOSSDK_SDK
    if ([SOSOnstarLinkSDKTool sharedInstance].isOnstarLinkRunning) {
    }	else	{
        [[NSNotificationCenter defaultCenter] postNotificationName:SOS_CHANGE_MRO_SETTING_OPEN_STATE_NOTIFICATION object:@(open)];
    }
    [SOSDaapManager sendActionInfo:open?Setting_OAssistantOn: Setting_OAssistantOff];
#endif
}

/**
 全局唤醒开关
 @param sender 开关
 */
- (void)mroGlobalWakeUpControl:(id)sender	{
    UISwitch *controller = (UISwitch *)sender;
    self.isGlobalWakeUpOpen = controller.on;
    [SOSMroService updateMroGlobalWakeupState:controller.on];
    [self mroGlobalWakeUpCloseSwitchProcess:controller.on];
}

- (void)mroGlobalWakeUpCloseSwitchProcess:(BOOL)open	{
    // 存储状态
//    [SOSMroService updateMroGlobalWakeupState:open];
    if (open) {
        [[SOSMroService sharedMroService] openGlobalWakeUp];
    }    else    {
        [[SOSMroService sharedMroService] closeGlobalWakeUp];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath	{
    if (indexPath.section == 1) {
        if (!_isMroOpen) {
            return 0;
        }
    }
    return 44.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *theCell ;
    if (indexPath.section == 1) {
        if (!_isMroOpen) {
            theCell = [[UITableViewCell alloc] init];
        }	else	{
            theCell = [tableView dequeueReusableCellWithIdentifier:MeSystemSettings_CellID];
            ((MeSystemSettingsViewCell *)theCell).cellData = dataSource[indexPath.section];
        }
    }	else	{
        theCell = [tableView dequeueReusableCellWithIdentifier:MeSystemSettings_CellID];
        ((MeSystemSettingsViewCell *)theCell).cellData = dataSource[indexPath.section];
    }
    
    return theCell;
}


#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 30.0f;
    }
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        if (!_isMroOpen) {
            return 50.0f;
            
        }else{
            return 30.0f;
            
        }
    }	else {
        if (!_isMroOpen) {
            if (mroGlobalWakeUpTipLabel) {
                mroGlobalWakeUpTipLabel.hidden = YES;
            }
            return 0.0f;
        }	else	{
            if (mroGlobalWakeUpTipLabel) {
                mroGlobalWakeUpTipLabel.hidden = NO;
            }
            return 50.0f;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView * view = [UIView new];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 50);
    UILabel *label = [UILabel new];
    label.textColor = [UIColor colorWithHexString:@"4e4e5f"];
    label.font = [UIFont systemFontOfSize:12];
    label.numberOfLines = 0;
    [label sizeToFit];
    
    if (section == 0) {
        @weakify(self);
        [RACObserve(self , isMroOpen) subscribeNext:^(id state) {
            @strongify(self);
            if (self.isMroOpen) {
                mroOpenOrCloseTip = NSLocalizedString(@"SettingVC_MrOCloseTip", nil);
                
            }else{
                mroOpenOrCloseTip = NSLocalizedString(@"SettingVC_MrOOpenTip", nil);
            }
            label.text = mroOpenOrCloseTip;
            [label sizeToFit];
        }];
    }else{
        mroGlobalWakeUpTipLabel = label;
        if (!_isMroOpen) {
            mroGlobalWakeUpTipLabel.hidden = YES;
        }
        @weakify(self);
        [RACObserve(self , isGlobalWakeUpOpen) subscribeNext:^(id state) {
            @strongify(self);
            if (self.isGlobalWakeUpOpen) {
                mroGlobalWakeUpTip = NSLocalizedString(@"SettingVC_MrOGlobalWakeupCloseTip", nil);
                
            }else{
                mroGlobalWakeUpTip = NSLocalizedString(@"SettingVC_MrOGlobalWakeupOpenTip", nil);
            }
            mroGlobalWakeUpTipLabel.text = mroGlobalWakeUpTip;
        }];
        mroGlobalWakeUpTipLabel.text = mroGlobalWakeUpTip;
    }
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(@15);
        make.centerY.equalTo(view);
        make.width.equalTo(@(SCREEN_WIDTH-30));
    }];
    return view;
}

@end
