//
//  SOSOnTabViewController.m
//  Onstar
//
//  Created by onstar on 2018/12/20.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSOnTabViewController.h"
#import "SOSOnTableHeaderView.h"
#import "SOSOnICMVehicleStatusCell.h"
#import "SOSOnRemoteCell.h"
#import "SOSRemoteTool.h"
#import "SOSChangeVehicleViewController.h"
#import "SOSOperationHistoryViewController.h"
#import "ServiceController.h"
#import "SOSCardUtil.h"
#import "SOSCustomAlertView.h"
#import "SOSFlexibleAlertController.h"
#import "SOSOnTopView.h"
#if __has_include("SOSSDK.h")
#import "SOSSDK.h"
#endif

@interface SOSOnTabViewController () <UITableViewDelegate,UITableViewDataSource>{
    
    bool isOpenAgreement;
}
@property (nonatomic, strong) UITableView *tableView;
//用于弹出授权注意alert 由于目前alert只支持window
@property (nonatomic, assign) BOOL fightFlag;


@property (nonatomic, strong) UIView *footerView;

@end

@implementation SOSOnTabViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showFightAlert];
    if ([LoginManage sharedInstance].loginState >= LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS) {//suite加载成功
        [self queryCarsharing];
    
//        if(![LoginManage sharedInstance].isSignAgreementState&&!isOpenAgreement){
//
//             isOpenAgreement = true;
//            //判断协议有没有签署成功
//            [[LoginManage sharedInstance] loadTCPSNeedConfirm];
//        }
        
        if([LoginManage sharedInstance].isClickShowOnstarModuleCount==0){//判断是否是从安吉星点进来的

            [LoginManage sharedInstance].isClickShowOnstarModuleCount++;
            //判断协议有没有签署成功
            [[LoginManage sharedInstance] loadTCPSNeedConfirm];
        }
       
    }
}

- (void)showFightAlert {
    //判断是否是当前页面
    if (![[SOS_APP_DELEGATE fetchMainNavigationController].topViewController isEqual:self]) {
        return;
    }
    if ([CustomerInfo sharedInstance].carSharingFlag && !self.fightFlag) {
        self.fightFlag = YES;
        SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:[UIImage imageNamed:@"Icon／48x48／feedback_success_operable_48x48-1"] title:@"授权注意" message:@"若与车主同时进行操作，易造成操作失败" customView:nil preferredStyle:SOSAlertControllerStyleAlert];
        
        SOSAlertAction *action = [SOSAlertAction actionWithTitle:@"知道了" style:SOSAlertActionStyleDefault handler:nil];
        [vc addActions:@[action]];
        [vc show];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initViews];
    [self addObserver];
    [self shouldCheckIcmUpgrade];
}

- (void)initViews {
#if SOSSDK_SDK
    self.fd_prefersNavigationBarHidden = NO;
    self.navigationItem.title = @"安吉星";
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[[UIImage imageNamed:@"common_Nav_Back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    button.size = CGSizeMake(30, 44);
    [button addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        [SOSSDK sos_dismissOnstarModule];
    }];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
#else
    self.fd_prefersNavigationBarHidden = YES;
#endif
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
    }];
    
    SOSOnTopView *topView = [SOSOnTopView viewFromXib];
    topView.backgroundColor = UIColor.clearColor;
    @weakify(self);
    topView.shareCenterBlock = ^{
        @strongify(self)
        [self gotoShareCenter];
    };
    
    topView.changeVehicleBlock = ^{
        @strongify(self)
        [self pushChangeVehicleVc];
    };
    [self.view addSubview:topView];
    
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(30);
        make.top.mas_equalTo(15);
    }];
    
    //header
    UIView *headerBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, SCALE_WIDTH(240)+STATUSBAR_HEIGHT-20)];
    SOSOnTableHeaderView *headerView = [SOSOnTableHeaderView viewFromXib];
   
    
    headerView.roadHelpBlock = ^{
//        [SOSCardUtil routerToH5Url:ROAD_HELP_URL];
        SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:ROAD_HELP_URL];
        [SOSCardUtil routerToVc:vc checkAuth:NO checkLogin:YES];
    };
    
    [headerBackView addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(headerBackView);
    }];
    self.tableView.tableHeaderView = headerBackView;
    [self setTableFooter];
    [self.tableView registerNib:[UINib nibWithNibName:SOSOnICMVehicleStatusCell.className bundle:nil] forCellReuseIdentifier:SOSOnICMVehicleStatusCell.className];
    [self.tableView registerNib:[UINib nibWithNibName:SOSOnRemoteCell.className bundle:nil] forCellReuseIdentifier:SOSOnRemoteCell.className];
    
}

- (void)setTableFooter {
    [self.footerView removeFromSuperview];
//    if (!SOS_MYCHEVY_PRODUCT) {
        //footer
           UIView *footerView = [[UIView alloc] init];
           UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeSystem];
           [leftBtn setTitle:@"使用说明" forState:UIControlStateNormal];
           [leftBtn setTitleColor:UIColorHex(#828389) forState:UIControlStateNormal];
           leftBtn.titleLabel.font = [UIFont systemFontOfSize:12];
           
           @weakify(self);
           [leftBtn setBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
               NSLog(@"使用说明");
               @strongify(self)
               [self instructionButtonTapped];
           }];
    if (!SOS_MYCHEVY_PRODUCT){
        [footerView addSubview:leftBtn];
        [leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                      make.left.mas_equalTo(SCALE_WIDTH(36));
                      make.bottom.mas_equalTo(footerView).mas_offset(-12);
                  }];
    }
          
           if (![SOSCheckRoleUtil isDriverOrProxy]) {
               UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeSystem];
               [rightBtn setTitle:@"车辆操作历史" forState:UIControlStateNormal];
               [rightBtn setTitleColor:UIColorHex(#828389) forState:UIControlStateNormal];
               rightBtn.titleLabel.font = [UIFont systemFontOfSize:12];
               [rightBtn setBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
                   NSLog(@"车辆操作历史");
                   @strongify(self)
                   [self operationHistroy];
               }];
               if (!SOS_MYCHEVY_PRODUCT){
                   [footerView addSubview:rightBtn];
                   [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                                     make.right.mas_equalTo(SCALE_WIDTH(-36));
                                     make.bottom.mas_equalTo(footerView).mas_offset(-12);
                                 }];
               }
              
           }
           footerView.backgroundColor = UIColor.whiteColor;
           [self.view addSubview:footerView];
           [footerView mas_makeConstraints:^(MASConstraintMaker *make) {
               make.left.right.mas_equalTo(self.view);
               make.bottom.mas_equalTo(self.view.sos_bottom);
                make.height.mas_equalTo(40);
               make.top.mas_equalTo(self.tableView.mas_bottom);
           }];
           self.footerView = footerView;
//    }
   
//    self.tableView.tableFooterView = footerView;
}

- (void)addObserver {
    @weakify(self);
    [RACObserve([LoginManage sharedInstance] , loginState) subscribeNext:^(NSNumber *state) {
        
        
        @strongify(self)
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
                //退出登录or登录成功
                if ([[LoginManage sharedInstance] isLoadingMainInterfaceReadyOrUnlogin]) {
                    
                        [self.tableView reloadData];
                        [self setTableFooter];
                }
                if ([LoginManage sharedInstance].loginState == LOGIN_STATE_NON) {
                    self.fightFlag = NO;
                }
                if ([LoginManage sharedInstance].loginState == LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS) {
                    [self queryCarsharing];
                  //  [[LoginManage sharedInstance] loadTCPSNeedConfirm];
                }
            
        });
        
    }];
    
    
   
}

- (void)queryCarsharing {
    // 用户是司机/代理
    if ([SOSCheckRoleUtil isDriverOrProxy]) {
        //司机代理远程操作之前查询权限
        [OthersUtil queryCarsharingStatusSuccessHandler:^(SOSRemoteControlShareUser *res) {
            [CustomerInfo sharedInstance].carSharingFlag = res.authorizeStatus;
            if (!res.authorizeStatus) {
                self.fightFlag = NO;
            }else {
                [self showFightAlert];
            }
            [self.tableView reloadData];
        } failureHandler:^(NSString *responseStr, NNError *error) {
            
        }];
    }
}


- (void)shouldCheckIcmUpgrade
{
    
    if (!UserDefaults_Get_Object(icmPromptKey())) {
        [self checkIcmUpgrade];
        [self updateIcmUpgradeState:YES];
    }
}

- (void)updateIcmUpgradeState:(BOOL)state;     {
    UserDefaults_Set_Object(@(state), icmPromptKey());
}

/**
 icm是否提示用户标识
 @return 存储key
 */
static inline NSString *icmPromptKey()    {
    return [NSString stringWithFormat:@"soskICMPrompt%@",[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
}

- (void)checkIcmUpgrade
{
    NSInteger icmUpgrade = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.icmUpgrade;
    NSLog(@"icmUpgrade is %ld",(long)icmUpgrade);
    if (icmUpgrade == 1) {
        [self showIcmUpgrade:1];
    }else if (icmUpgrade == 2)
    {
        [self showIcmUpgrade:2];
    }
}

- (void)showIcmUpgrade:(NSInteger)state
{
    NSString *str = @"";
    if (state == 1) {
        str = @"亲爱的客户,您的爱车通过升级将获得更多的互联功能体验，您可自9月20日起到经销商门店咨询并免费升级您的车载系统";
        //str = @"安吉星8.3及以上版本远程控制新增打开后\n备箱，空调设置，车辆状态及提醒等功能\n如暂不支持，请于9月20日后至经销商处咨\n询并升级车载系统";
    }else if (state == 2)
    {
        str = @"亲爱的客户,您的爱车通过升级将获得更多的互联功能体验，您可自10月8日起到经销商门店咨询并免费升级您的车载系统";
        //str = @"安吉星8.3及以上版本远程控制新增打开后\n备箱，空调设置，车辆状态及提醒等功能\n如暂不支持，请于10月8日后至经销商处咨\n询并升级车载系统";
    }
    SOSCustomAlertView *alertView = [[SOSCustomAlertView alloc] initWithTitle:@"新功能上线" detailText:str cancelButtonTitle:@"知道了" otherButtonTitles:nil canTapBackgroundHide:NO];
    [alertView setPageModel:SOSAlertViewModelUpgrade];
    alertView.buttonClickHandle = ^(NSInteger clickIndex) {
    };
    [alertView show];
    
}

#pragma mark tableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        if (([Util vehicleIsICM2] || Util.vehicleIsMy21) &&
            ([SOSCheckRoleUtil isOwner] ||
             ([SOSCheckRoleUtil isDriverOrProxy] && [CustomerInfo sharedInstance].carSharingFlag))) {
                //icm车主 或icm司机代理已授权的
            return 120;
        }
        return 80;
    }
    return 250;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        SOSOnICMVehicleStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:SOSOnICMVehicleStatusCell.className forIndexPath:indexPath];
        [cell reload];
        return cell;
    }
    
    
    SOSOnRemoteCell *cell = [tableView dequeueReusableCellWithIdentifier:SOSOnRemoteCell.className forIndexPath:indexPath];
    [cell reload];
    @weakify(self)
    cell.tapRemoteBlock = ^(NSInteger type) {
        @strongify(self)
        [self carOperationButtonTapped:type];
    };
    cell.tapHVACABlock = ^(NSInteger type) {
        @strongify(self)
        [self showHVACAlertView];
    };
    
    return cell;
}

#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}


/// 使用说明
- (void)instructionButtonTapped     {
    [SOSDaapManager sendActionInfo:REMOTECONTROL_GUIDE];
    NSString *url = nil;
    if ([Util vehicleIsICM2]) {
        url = REMOTE_CONTROL_USER_MANUAL_ICM2;
    }    else    {
        url = REMOTE_CONTROL_USER_MANUAL;
    }
    SOSWebViewController *moreVc = [[SOSWebViewController alloc] initWithUrl:url];
    moreVc.singlePageFlg = YES;
    [self.navigationController pushViewController:moreVc animated:YES];
}


//空调弹框
- (void)showHVACAlertView {
    NSLog(@"空调弹框");
    //升级车主
    if (![SOSCheckRoleUtil checkVisitorInPage:[SOS_APP_DELEGATE fetchMainNavigationController]])   {
         return;
    }
    
//    AppDelegate_iPhone *delegate = (AppDelegate_iPhone*)[[UIApplication sharedApplication] delegate];
//    id fromVc = [delegate fetchMainNavigationController];
//    [[LoginManage sharedInstance] checkAndShowLoginViewWithFromViewCtr:fromVc andTobePushViewCtr:nil completion:^(BOOL finished){
//        if(finished){
    [SOSRemoteTool startHVACSetting];
//        }
//    }];
    
    
    
    
    
}

#pragma mark --- 切换车辆
/**
 多车(Owner、Proxy、Driver都可以)切换车辆
 @param Owner、Proxy、Driver都可以
 @return
 */
- (void)pushChangeVehicleVc{
    [SOSDaapManager sendActionInfo:VEHICLEINFO_CHANGECARS];
    SOSChangeVehicleViewController *changeVc = [[SOSChangeVehicleViewController alloc] initWithNibName:@"SOSChangeVehicleViewController" bundle:nil];
    [self.navigationController pushViewController:changeVc animated:YES];
}

//车辆共享中心
- (void)gotoShareCenter {
    NSLog(@"车辆共享中心");
    
    [SOSDaapManager sendActionInfo:ON_VEHICLESHARINGCENTER_CLICK];
    
//    if(SOS_BUICK_PRODUCT){
//
//        [SOSDaapManager sendActionInfo:ON_VEHICLESHARINGCENTER_CLICK];
//        [SOSUtil showCustomAlertWithTitle:@"" message:@"此功能正在升级中，敬请期待"  cancleButtonTitle:@"取消" otherButtonTitles:nil    completeBlock:^(NSInteger buttonIndex){
//        }];
//
//    }else{
     
        id vc = [[NSClassFromString(@"SOSCarShareViewController") alloc] init];
       [self.navigationController pushViewController:vc animated:YES];
        
  //  }
   
}

- (void)operationHistroy
{
    [SOSDaapManager sendActionInfo:VEHICLEINFO_OPERATHISTORY];
    SOSOperationHistoryViewController *hisVc = [[SOSOperationHistoryViewController alloc] initWithNibName:@"SOSOperationHistoryViewController" bundle:nil];
    hisVc.backRecordFunctionID = VEHICLEINFO_OPERATHISTORY_BACK;
    
    [SOSCardUtil routerToVc:hisVc checkAuth:YES checkLogin:YES];
}



- (void)carOperationButtonTapped:(NSInteger)type {
    NSString *recordStr = @"";
    switch (type) {
        case SOSRemoteOperationType_LockCar:
            recordStr = REMOTECONTROL_LOCK;
            break;
        case SOSRemoteOperationType_UnLockCar:
            recordStr = REMOTECONTROL_UNLOCK;
            break;
        case SOSRemoteOperationType_RemoteStart:
            recordStr = REMOTECONTROL_START;
            break;
        case SOSRemoteOperationType_RemoteStartCancel:
            recordStr = REMOTECONTROL_STOP;
            break;
        case SOSRemoteOperationType_LightAndHorn:
            recordStr = REMOTECONTROL_LIGHTHORN;
            break;
        case SOSRemoteOperationType_OpenWindow:
            recordStr = REMOTECONTROL_WINDOWSUNLOCK;
            break;
        case SOSRemoteOperationType_CloseWindow:
            recordStr = REMOTECONTROL_WINDOWSLOCK;
            break;
        case SOSRemoteOperationType_OpenRoofWindow:
            recordStr = REMOTECONTROL_SUNROOFUNLOCK;
            break;
        case SOSRemoteOperationType_CloseRoofWindow:
            recordStr = REMOTECONTROL_SUNROOFLOCK_;
            break;
        case SOSRemoteOperationType_OpenTrunk:
            recordStr = REMOTECONTROL_TRUNKUNLOCK;
            break;
        case SOSRemoteOperationType_UnlockTrunk:
            recordStr = @"";
            break;
        case SOSRemoteOperationType_LockTrunk:
            recordStr = @"";
            break;
        default:
            break;
    }
    [SOSDaapManager sendActionInfo:recordStr];
    [[SOSRemoteTool sharedInstance] startOperationWithOperationType:type];
}


@end
