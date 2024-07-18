//
//  SOSMeTabViewController.m
//  Onstar
//
//  Created by Onstar on 2018/11/17.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSMeTabViewController.h"
#import "SOSAvatarView.h"
#import "SOSSettingView.h"
#import "UITableView+Category.h"
#import "SOSPackageCell.h"
#import "SOSMeTableSectionHeaderView.h"
#import "SOSMeTabHeaderView.h"
#import "MePersonalInfoViewController.h"
#import "SOSCardUtil.h"
#import "SOSDonateDataTool.h"
#import "SOSMeCustomerServiceCell.h"
#import "SOSSettingViewController.h"
#import "SOSMsgCenterController.h"
#import "TLSOSRefreshHeader.h"
#import "SOSGreetingManager.h"
#import "SOSVehicleInsuranceCell.h"
#import "PackageUtil.h"
#import "HandleDataRefreshDataUtil.h"
#import "SOSOverallScanController.h"
#import <AVFoundation/AVCaptureDevice.h>
#import "UIViewController+CYLTabBarControllerExtention.h"

#if __has_include("SOSSDK.h")
#import "SOSSDK.h"
#endif


@interface SOSMeTabViewController()<UITableViewDelegate,UITableViewDataSource>{
    UITableView * mainTable;
    SOSMeTabHeaderView *tableHeaderView;
    SOSAvatarView * userView;
    SOSSettingView * settingView;
    
}
@property (nonatomic, strong) NSMutableArray<NSNumber *> *cardArray;
@property (nonatomic, strong) id ubiBannerResp;
@property (nonatomic, strong) id mallBannerResp;
@property (nonatomic, assign)BOOL cusViewAfterLogin;
@end
@implementation SOSMeTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpView];
    
    [self makeDefaultTableSource];
    
    //header
    tableHeaderView = [[SOSMeTabHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 173+12+8)];
    mainTable.tableHeaderView = tableHeaderView;
    tableHeaderView.delegate = self;
    //footer
    UIView * tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    mainTable.tableFooterView = tableFooterView;
    [self.view addSubview:mainTable];
    [mainTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view);
        make.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(userView.mas_bottom);
        make.bottom.mas_equalTo(self.view);
    }];
    //    @weakify(self)
    mainTable.mj_header = [TLSOSRefreshHeader headerWithRefreshingBlock:^{
        //        @strongify(self)
        if ([[LoginManage sharedInstance] isLoadingMainInterfaceFail]) {
            [[LoginManage sharedInstance] reLoadMainInterface];
        }    else    {
            [SOSCardUtil shareInstance].starResp = nil;
            [SOSCardUtil shareInstance].vehicleCashBookResp = nil;
            [SOSCardUtil shareInstance].packageResp = nil;
            [self->tableHeaderView refreshPackageState];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self->mainTable.mj_header endRefreshing];
        });
        [SOSDaapManager sendActionInfo:ME_PAGERELOAD_DRAG];
    }];
    
    [self addObserver];
}
#pragma mark -UI
-(void)setUpView{
    self.cyl_badgeBackgroundColor = [UIColor sos_skinColorWithKey:@"themeColorPack.themeColorBean.tabMeTopRightPointColor"];
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
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = self.view.frame;
    gl.startPoint = CGPointMake(0.5, 0.34);
    gl.endPoint = CGPointMake(0.5, 0.66);
    gl.colors = @[(__bridge id)[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:243/255.0 green:245/255.0 blue:254/255.0 alpha:1.0].CGColor];
    gl.locations = @[@(0), @(1.0f)];
    [self.view.layer addSublayer:gl];
    
    //设置及通知
    settingView = [[SOSSettingView alloc] initWithFrame:CGRectZero];
    settingView.delegate = self;
    [self.view addSubview:settingView];
    [settingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-12.0f);
        make.height.mas_equalTo(44.0f);
#ifdef SOSSDK_SDK
        make.top.equalTo(@(20));
#else
        make.top.equalTo(@(STATUSBAR_HEIGHT));
#endif
    }];
    
    //头像部分
    userView = [[SOSAvatarView alloc] initWithFrame:CGRectZero];
    userView.delegate = self;
    [self.view addSubview:userView];
    [userView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(settingView);
        make.right.equalTo(settingView.mas_left);
        make.left.equalTo(@12);
    }];
}
-(void)addObserver {
    @weakify(self);
    [RACObserve([LoginManage sharedInstance] , loginState) subscribeNext:^(NSNumber *state) {
        @strongify(self)
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (state.integerValue == LOGIN_STATE_NON){
                if ([SOSCardUtil shareInstance].packageResp) {
                    [SOSCardUtil shareInstance].packageResp = nil;
                }
                [SOSCardUtil shareInstance].vehicleCashBookResp = nil;
                [SOSCardUtil shareInstance].myDonateInfo = nil;
                [SOSCardUtil shareInstance].starResp = nil;
                self.ubiBannerResp = nil;
                self.mallBannerResp = nil;
                [mainTable reloadData];
                self.cusViewAfterLogin = NO;
                [self->tableHeaderView configUnloginState];
            }else{
                if (state.integerValue == LOGIN_STATE_LOADINGTOKEN|| state.integerValue == LOGIN_STATE_LOADINGUSERBASICINFO) {
                    [self->tableHeaderView configLoadingState];
                    self.cusViewAfterLogin = NO;
                }
                if (!self.cusViewAfterLogin && [[LoginManage sharedInstance] isLoadingUserBasicInfoReady]){
                    self.cusViewAfterLogin = YES;
                   
                    
                    [self->tableHeaderView configLoginSuccessState];
                    if (!SOS_MYCHEVY_PRODUCT) {
                        [mainTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0],[NSIndexPath indexPathForRow:0 inSection:1],[NSIndexPath indexPathForRow:0 inSection:2],[NSIndexPath indexPathForRow:0 inSection:3]] withRowAnimation:0];
                        [self refreshMessageCenter];
                        [self getUbiMallBannerResp];
                    }
                   
                }
            }
            
        });
         
    }];
    if (!SOS_MYCHEVY_PRODUCT) {
        [RACObserve([SOSCardUtil shareInstance], vehicleCashBookResp) subscribeNext:^(id x) {
            @strongify(self)
            NSInteger index =  [self.cardArray indexOfObject:@(SOSMeCardCellTypeLifeCashBook)];
            if (self->mainTable.numberOfSections >0) {
                [self->mainTable reloadRow:0 inSection:index withRowAnimation:UITableViewRowAnimationNone];
            }
        }];
        [RACObserve([SOSCardUtil shareInstance], myDonateInfo) subscribeNext:^(id x) {
            @strongify(self)
            NSInteger index =  [self.cardArray indexOfObject:@(SOSMeCardCellTypeDonate)];
            if (self->mainTable.numberOfSections >0) {
                [self->mainTable reloadRow:0 inSection:index withRowAnimation:UITableViewRowAnimationNone];
            }
        }];
        [RACObserve([SOSCardUtil shareInstance], starResp) subscribeNext:^(id x) {
            @strongify(self)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSInteger index =  [self.cardArray indexOfObject:@(SOSMeCardCellTypeStarTravel)];
                if (self->mainTable.numberOfSections >0) {
                    [self->mainTable reloadRow:0 inSection:index withRowAnimation:UITableViewRowAnimationNone];
                }
            });
        }];
    }
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOSkSwitchVehicleSuccess object:nil] subscribeNext:^(NSNotification *noti) {
        [self->mainTable.mj_header beginRefreshing];
    }];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshMessageCenter];
}
-(void)refreshMessageCenter{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.cyl_badgeCenterOffset = CGPointMake(-5, 5);
    });
    if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
        [[MsgCenterManager shareInstance] getMessage:^(NSInteger messageNum, id model) {
            [self->settingView updateMessageNumber];
            messageNum > 0 ? [self cyl_showBadge] : [self cyl_clearBadge];
        }];
    }
    if ([LoginManage sharedInstance].loginState == LOGIN_STATE_NON) {
        if ([MsgCenterManager shareInstance].msgNum != 0) {
            [MsgCenterManager shareInstance].msgNum = 0;
            [settingView updateMessageNumber];
            [self cyl_clearBadge];
        }
    }
}
//请求banner,UBI&Mall
- (void)queryUBICanShowWithUBI:(NSArray *)ubiBanners {
    @weakify(self);
    [SOSCardUtil getUBIInfoSuccess:^(NSDictionary *result) {
        @strongify(self);
        NSString *description = [result objectForKey:@"description"];
        if (description.isNotBlank && [description isEqualToString:@"true"]) {
            self.ubiBannerResp = ubiBanners;
        }else {
            self.ubiBannerResp = nil;
        }
    } Failed:^(NSString *responseStr, NSError *error) {
        @strongify(self);
        self.ubiBannerResp = nil;
    }];
}
- (void)getUbiMallBannerResp {
    NSString * cate = [NSString stringWithFormat:@"%@,%@",BANNER_UBI,BANNER_MALL];
    @weakify(self);
    [OthersUtil getBannerWithCategory:cate SuccessHandle:^(NSDictionary *banners) {
        @strongify(self);
        NSArray * ubiBannerArray = [NNBanner mj_objectArrayWithKeyValuesArray:[banners objectForKey:BANNER_UBI]];
        NSArray * mallBannerArray = [NNBanner mj_objectArrayWithKeyValuesArray:[banners objectForKey:BANNER_MALL]];
        if (ubiBannerArray.count == 0) {
            self.ubiBannerResp = nil;
        }else{
            [self queryUBICanShowWithUBI:ubiBannerArray];
        }
        if (mallBannerArray.count == 0) {
            self.mallBannerResp = nil;
        }else{
            self.mallBannerResp = mallBannerArray;
        }
        
    } failureHandler:^(NSString *responseStr, NSError *error) {
        self.ubiBannerResp = @NO;
        self.mallBannerResp = @NO;
    }];
}

- (void)setUbiBannerResp:(id)ubiBannerResp {
    _ubiBannerResp = ubiBannerResp;
    NSInteger indexInsurance = [self.cardArray indexOfObject:@(SOSMeCardCellTypeInsurence)];
    [mainTable reloadRow:0 inSection:indexInsurance withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

- (void)setMallBannerResp:(id)mallBannerResp {
    _mallBannerResp = mallBannerResp;
    NSInteger indexMall = [self.cardArray indexOfObject:@(SOSMeCardCellTypeMall)];
    [mainTable reloadRow:0 inSection:indexMall withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

#pragma mark -dataSource
//未登录(套餐、用车账本、我的公益、客服服务)
-(void)makeDefaultTableSource{
    
    mainTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    mainTable.delegate = self;
    mainTable.dataSource = self;
    mainTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    mainTable.estimatedRowHeight = 0;
    mainTable.backgroundColor = [UIColor clearColor];
    mainTable.showsVerticalScrollIndicator = NO;
    if (!SOS_MYCHEVY_PRODUCT) {
        self.cardArray =[NSMutableArray  arrayWithObjects:@(SOSMeCardCellTypeInsurence),@(SOSMeCardCellTypeMall),@(SOSMeCardCellTypeStarTravel),
                            @(SOSMeCardCellTypePackage), @(SOSMeCardCellTypeLifeCashBook),
                            @(SOSMeCardCellTypeDonate),                                                      @(SOSMeCardCellTypeCustomerService), nil];
    }else{
        self.cardArray =[NSMutableArray  arrayWithObjects:
                            @(SOSMeCardCellTypePackage),
                            @(SOSMeCardCellTypeCustomerService), nil];
    }
   
    [mainTable registerClass:NSClassFromString(@"SOSStarTravelCell")];
    [mainTable registerClass:SOSPackageCell.class];
    [mainTable registerClass:NSClassFromString(@"SOSVehicleCashBookTableViewCell")];
    [mainTable registerClass:NSClassFromString(@"SOSMeDonateCell")];
    [mainTable registerClass:NSClassFromString(@"SOSMeCustomerServiceCell")];
    [mainTable registerClass:[SOSMeCustomerServiceCell class] forCellReuseIdentifier:@"package"];
    [mainTable registerClass:[SOSMeCustomerServiceCell class] forCellReuseIdentifier:@"service"];
    [mainTable registerClass:NSClassFromString(@"SOSVehicleInsuranceCell")];
    [mainTable registerSectionHeaderClass:SOSMeTableSectionHeaderView.class];
    
}

#pragma mark --functionDelegate
-(void)clickLogin{
    [SOSDaapManager sendActionInfo:My_profile];
    id vc = [[MePersonalInfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [[LoginManage sharedInstance] setDependenceIllegal:![[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin]];
    [SOSUtil presentLoginFromViewController:((UINavigationController *)[SOS_APP_DELEGATE fetchMainNavigationController]).topViewController toViewController:vc];
}
- (void)clickSetting{
    [SOSDaapManager sendActionInfo:ServiceSetting];
    SOSSettingViewController *settingVc = [[SOSSettingViewController alloc] init];
    [SOSUtil presentLoginFromViewController:((UINavigationController *)[SOS_APP_DELEGATE fetchMainNavigationController]).topViewController toViewController:settingVc];
}
- (void)clickUpgrade{
    [SOSCardUtil routerToUpgradeSubscriber];
}
- (void)clickPurchasePackage{
    [SOSCardUtil routerToBuyOnstarPackage:(PackageType_Core)];
}
- (void)clickPurchaseDataPackage{
    [SOSCardUtil routerToBuyOnstarPackage:(PackageType_4G)];
}
-(void)clickNotification{
    if ([LoginManage sharedInstance].loginState == LOGIN_STATE_NON) {
        [[LoginManage sharedInstance] presentLoginNavgationController:[SOS_APP_DELEGATE fetchMainNavigationController]];
    }else
    {
        SOSMsgCenterController *messagedetailVc = [[SOSMsgCenterController alloc] init];
        [((UINavigationController *)[SOS_APP_DELEGATE fetchMainNavigationController]) pushViewController:messagedetailVc animated:YES];
    }
}

- (void)onOverallScan {
    [SOSDaapManager sendActionInfo:ME_TopRightCorner_GlobalQRScanning];
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        [Util showAlertWithTitle:nil message:@"相机权限受限，请到系统设置中开启相机权限" completeBlock:nil cancleButtonTitle:nil otherButtonTitles:@"确定", nil];
        return;
    }
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:self withLoginDependence:[[LoginManage sharedInstance] isLoadingMainInterfaceReady] showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
                
                SOSOverallScanController *vc = [SOSOverallScanController new];
                [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:vc animated:YES];
            }];
        }
    }];
    
}
-(BOOL)showStarTravel{
    return [[LoginManage sharedInstance] isLoadingUserBasicInfoReady] && ![SOSCheckRoleUtil isVisitor];
}
-(BOOL)showIns{
    return  [SOSCheckRoleUtil isOwner] && [self.ubiBannerResp isKindOfClass:[NSArray class]];
}
-(BOOL)showMall{
    if ([self.mallBannerResp isKindOfClass:[NSArray class]]) {
        if (((NSArray *)self.mallBannerResp).count>0){
            return YES;
        }
    }
    return NO;
}
#pragma mark --tableviewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return self.cardArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    NSInteger type = [self.cardArray objectAtIndex:section].integerValue;
    switch (type) {
        case SOSMeCardCellTypeStarTravel:
            if ([self showStarTravel]) {
                return 40;
            }
            return 0;
            break;
        case SOSMeCardCellTypeLifeCashBook:
            if (([SOSCheckRoleUtil isDriver] || [SOSCheckRoleUtil isProxy])) {
                return 0;
            }else{
                return 40;
            }
            break;
        case SOSMeCardCellTypeDonate:
            return 40;
            break;
        case SOSMeCardCellTypePackage:
            return 40;
            break;
        case SOSMeCardCellTypeCustomerService:{
            return 40;
        }
            break;
        case SOSMeCardCellTypeInsurence:{
            if ([self showIns]) {
                return 40;
            }
            return 0;
        }
            break;
        case SOSMeCardCellTypeMall:{
            if ([self showMall]) {
                return 40;
            }
            return 0;
        }
            break;
        default:
            return 0;
            break;
    }
    
    
    return 40.0f;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    static NSString *reuseId = @"SOSMeTableSectionHeaderView";
    SOSMeTableSectionHeaderView *header = (SOSMeTableSectionHeaderView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseId];
    NSInteger type = [self.cardArray objectAtIndex:section].integerValue;
    switch (type) {
        case SOSMeCardCellTypeStarTravel:
            if ([self showStarTravel]) {
                [header makeIcon:@"Icon_me_card_icon_task" titleText:@"星享之旅" showAdditionRightButton:NO];
            }
            break;
        case SOSMeCardCellTypeLifeCashBook:
            if (([SOSCheckRoleUtil isDriver] || [SOSCheckRoleUtil isProxy])) {
                
            }else{
                [header makeIcon:@"Icon_me_card_icon_cash" titleText:@"用车账本" showAdditionRightButton:NO];
            }
            break;
        case SOSMeCardCellTypeDonate:
            [header makeIcon:@"Icon_me_card_icon_donate" titleText:@"我的公益"showAdditionRightButton:NO];
            break;
        case SOSMeCardCellTypePackage:
            [header makeIcon:@"Icon_me_card_icon_package" titleText:@"套餐" showAdditionRightButton:NO];
            break;
        case SOSMeCardCellTypeCustomerService:{
            [header makeIcon:@"Icon_me_card_icon_customer" titleText:@"客户服务"showAdditionRightButton:NO];
        }
            break;
        case SOSMeCardCellTypeInsurence:{
            if ([self showIns]) {
                [header makeIcon:@"Icon_me_card_icon_insurance" titleText:@"车联保险"showAdditionRightButton:YES];
                [header.rightBtn setBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
                    [SOSDaapManager sendActionInfo:ME_UBI_MORE];
                    [SOSCardUtil routerToH5Url:UBI_INSURANCE_URL];
                }];
            }
            
        }
            break;
        case SOSMeCardCellTypeMall:{
            if ([self showMall]) {
                [header makeIcon:@"Icon_Me_onstarShop" titleText:@"安吉星商城"showAdditionRightButton:YES];
                [header.rightBtn setBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
                    [SOSCardUtil routerToOnstarShop];
                }];
            }
        }
            break;
        default:
            [header makeIcon:@"Icon_me_card_icon_task" titleText:@"安吉星"showAdditionRightButton:NO];
            break;
    }
    
    return header;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger cardCellType = [self.cardArray[indexPath.section] integerValue];
    switch (cardCellType) {
        case SOSMeCardCellTypeStarTravel:
            return [self showStarTravel]? 88.f:0.0f;
            break;
        case SOSMeCardCellTypeDonate:
            return 88.f;
            break;
        case SOSMeCardCellTypePackage:
            return 110.f;
            break;
        case SOSMeCardCellTypeLifeCashBook:
            return ([SOSCheckRoleUtil isDriver] || [SOSCheckRoleUtil isProxy])?0.0f: 98.f;
            break;
        case SOSMeCardCellTypeInsurence:
            if ([self showIns]) {
                return 80.f;
            }else{
                return 0.0f;
            }
            break;
        case SOSMeCardCellTypeCustomerService:
            return 195.f;
        case SOSMeCardCellTypeMall:
        {
            return [self showMall]?110.0f:0.0f;
        }
            
        default:
            return 0.0f;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger cardCellType = [self.cardArray[indexPath.section] integerValue];
    SOSCardBaseCell *cell ;
    switch (cardCellType) {
        case SOSMeCardCellTypeStarTravel:
        {
            if ([self showStarTravel]) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"SOSStarTravelCell" forIndexPath:indexPath];
                if ([SOSCardUtil shareInstance].starResp == nil) {
                    if (![SOSCheckRoleUtil isVisitor]) {
                        //未登录不请求
                        [SOSCardUtil getStatTravelSuccess:^(NNStarTravelResp *urlRequest) {
                            
                        } Failed:^(NSString *responseStr, NSError *error) {
                        }];
                    }
                }
                
                [cell refreshWithResp:[SOSCardUtil shareInstance].starResp];
            }else{
                cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
                if (!cell) {
                    cell = [[SOSCardBaseCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellId"];
                }
            }
        }
            break;
        case SOSMeCardCellTypePackage:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"package"];
            [((SOSMeCustomerServiceCell*)cell) sos_setIsCustomerService:NO];
            
        }
            break;
        case SOSMeCardCellTypeLifeCashBook:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SOSVehicleCashBookTableViewCell" forIndexPath:indexPath];
            if ([SOSCheckRoleUtil isOwner]) {
                if ([SOSCardUtil shareInstance].vehicleCashBookResp == nil ) {
                    [SOSCardUtil shareInstance].vehicleCashBookResp = @YES;
                    [SOSCardUtil getCarCashBookReport:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin Success:^(NNVehicleCashResp *urlRequest) {
                        if (urlRequest) {
                            [SOSCardUtil shareInstance].vehicleCashBookResp = urlRequest;
                        }else
                        {
                            [SOSCardUtil shareInstance].vehicleCashBookResp = @NO;
                        }
                    } Failed:^(NSString *responseStr, NSError *error) {
                        
                        [SOSCardUtil shareInstance].vehicleCashBookResp = @NO;
                    }];
                }
                [cell refreshWithResp:[SOSCardUtil shareInstance].vehicleCashBookResp];
            }else {
                [cell refreshWithResp:[[NNVehicleCashResp alloc] initWithMonthStatistics:@"300.0" yearStatistics:@"15000.0"]];
            }
        }
            break;
        case SOSMeCardCellTypeDonate:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SOSMeDonateCell" forIndexPath:indexPath];
            if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReady] ) {
                if (![SOSCheckRoleUtil isVisitor]) {
                    if ([SOSCardUtil shareInstance].myDonateInfo == nil) {
                        [SOSCardUtil shareInstance].myDonateInfo = @YES;
                        
                        [SOSDonateDataTool getDonateInfoSuccess:^(SOSNetworkOperation *operation, id responseObj) {
                            NSDictionary *responseDic = (NSDictionary *)responseObj;
                            if ([responseDic isKindOfClass:[NSDictionary class]] && responseDic.count) {
                                [SOSCardUtil shareInstance].myDonateInfo = [SOSDonateUserInfo mj_objectWithKeyValues:responseDic];
                            }
                        } Failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                            [SOSCardUtil shareInstance].myDonateInfo = @NO;
                        }];
                        
                    }
                }
            }
            [cell refreshWithResp:[SOSCardUtil shareInstance].myDonateInfo];
        }
            break;
        case SOSMeCardCellTypeCustomerService:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"service"];
            [((SOSMeCustomerServiceCell*)cell) sos_setIsCustomerService:YES];
            
        }
            break;
            
        case SOSMeCardCellTypeInsurence:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SOSVehicleInsuranceCell" forIndexPath:indexPath];
            [cell refreshWithResp:self.ubiBannerResp];
        }
            break;
        case SOSMeCardCellTypeMall:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SOSVehicleInsuranceCell" forIndexPath:indexPath];
            [cell refreshWithResp:self.mallBannerResp];
        }
            break;
            
        default:
            break;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger cardCellType = [self.cardArray[indexPath.section] integerValue];
    switch (cardCellType) {
        case SOSMeCardCellTypeStarTravel:
        {
            //星享之旅
            [SOSCardUtil routerToStarTravelH5];
            [self addStarTravelDaap];
        }
            break;
            
        case SOSMeCardCellTypeLifeCashBook:
        {
            //账本
            SOSWebViewController* pushedCon = [[SOSWebViewController alloc] initWithUrl:VEHICLE_ACCOUNT_URL];
            [pushedCon setBackClickCompleteBlock:^{
                [SOSCardUtil shareInstance].vehicleCashBookResp = nil;
            }];
            [[LoginManage sharedInstance] setDependenceIllegal:![[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin]];
            [SOSCardUtil routerToVc:pushedCon
                          checkAuth:YES
                         checkLogin:YES];
            [SOSDaapManager sendActionInfo:ME_CASHFLOW];
        }
            break;
        case SOSMeCardCellTypeDonate:
            //公益
        {
            [SOSDaapManager sendActionInfo:ME_MYCOMMONWEAL];
            [SOSCardUtil routerToMyDonate];
            
        }
            
            break;
            
        default:
            break;
    }
    
}
-(void)addStarTravelDaap{
    if ([SOSCardUtil shareInstance].starResp && [[SOSCardUtil shareInstance].starResp isKindOfClass:[NNStarTravelResp class]]) {
        NSString * travelCode = ((NNStarTravelResp *)([SOSCardUtil shareInstance].starResp)).currentStageInfo.stageCode;
        if ([travelCode containsString:@"ST01"]) {
            [SOSDaapManager sendActionInfo:ME_ONSTARTRAVEL_ONSTARTRIP];
            return;
        }
        if ([travelCode containsString:@"ST02"]) {
            [SOSDaapManager sendActionInfo:ME_ONSTARTRAVEL_FOLLOWSTARTRIP];
            return;
        }
        if ([travelCode containsString:@"ST03"]) {
            [SOSDaapManager sendActionInfo:ME_ONSTARTRAVEL_SMARTSTARTRIP];
            return;
        }
        if ([travelCode containsString:@"ST04"]) {
            [SOSDaapManager sendActionInfo:ME_ONSTARTRAVEL_LUCKSTARTRIP];
            return;
        }
        if ([travelCode containsString:@"ST05"]) {
            [SOSDaapManager sendActionInfo:ME_ONSTARTRAVEL_ONSTARGUARD];
            return;
        }
    }
}
@end
