//
//  SOSVehicleTabViewController.m
//  Onstar
//
//  Created by Onstar on 2018/11/17.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSVehicleTabViewController.h"
#import "SOSDarkRefreshHeader.h"
#import "UITableView+InfoFlow.h"
#import "SOSInfoFlowTableViewCellHeader.h"
#import "UITableView+Category.h"
#import "SOSInfoFlow.h"
#import "SOSInfoFlowArchiver.h"
#import "SOSVehicleTabHeaderView.h"
#import "SOSInfoFlowNetworkEngine.h"
#import "SOSUserLocation.h"
#import "SOSBannerTableViewCell.h"
#import "SOSInfoFlowJumpHelper.h"
#import "SOSPlainVehicleConditionView.h"
#import "SOSVehicleInfoUtil.h"
#if __has_include("SOSSDK.h")
#import "SOSSDK.h"
#else
#import <NIMSDK/NIMSDK.h>
#import "SOSIMNotificationCenter.h"
#endif
//#import "PlatformRouterImp.h"

@interface SOSVehicleTabViewController ()<UITableViewDataSource, UITableViewDelegate, SOSHomeMeTabProtocol> {
    SOSPlainVehicleConditionView * plainVehicle;//简明车况界面
    SOSVehicleTabHeaderView * tableHeaderView;
}

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<SOSInfoFlow *> *infoFlows;
@property (nonatomic, strong) NSArray *banners;
@property (nonatomic, assign) BOOL headerAutoRefresh; //头部自动刷新,不是手动下拉刷新
@property (nonatomic, assign) BOOL needRecordTimes; //

@property (assign, nonatomic) NSTimeInterval pullRefreshStartTime;
@property (assign, nonatomic) UIStatusBarStyle statusBarStyle;

@property (nonatomic, assign) NSTimeInterval bannerStartTimeIntervel;//开始请求banner
@property (nonatomic, assign) BOOL bannerResp;//请求banner结束
@property (strong, nonatomic) UIImageView *bottomImageView;
@end

static const CGFloat soskVehicleTabHeaderHeight = 350.f;

static const CGFloat soskBeginShowPlainVehicleStatus = 150.f;
//开始显示简明车况临界点
static CGFloat kShowPlainVehicleLine = soskVehicleTabHeaderHeight-soskBeginShowPlainVehicleStatus-IOS7_NAVIGATION_BAR_HEIGHT;

@implementation SOSVehicleTabViewController

- (void)initData {
    _infoFlows = @[].mutableCopy;
}

- (void)initView {
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
    _statusBarStyle = UIStatusBarStyleDefault;
#else
    _statusBarStyle = UIStatusBarStyleLightContent;

    self.fd_prefersNavigationBarHidden = YES;
#endif
    
    
    self.headerAutoRefresh = NO;
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClasses:infoFlowCellClasses()];
    //banner
    [_tableView registerClass:SOSBannerTableViewCell.class];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [SOSUtil onstarLightGray];
    _tableView.backgroundView = [self tableViewBackgroundView];
    _tableView.estimatedRowHeight = 400;
    _tableView.showsVerticalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
        _tableView.rowHeight = UITableViewAutomaticDimension;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    //custom header view
    if (!tableHeaderView) {
        tableHeaderView = [[JSObjection defaultInjector] getObject:[SOSVehicleTabHeaderView class]];
        if (SOS_BUICK_PRODUCT) {
            tableHeaderView.height = SCALE_WIDTH(soskVehicleTabHeaderHeight);
            tableHeaderView.backgroundColor = [UIColor redColor];
        }else{
            tableHeaderView.height = SCALE_WIDTH(soskVehicleTabHeaderHeight);
        }
        tableHeaderView.width = SCREEN_WIDTH;
        tableHeaderView.delegate = self;
        tableHeaderView.backgroundColor = [SOSUtil onstarLightGray];
    }
    _tableView.tableHeaderView = tableHeaderView;
    /////////////////
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 30)];
    //refresh header
    @weakify(self)
    _tableView.mj_header =  [SOSDarkRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self mjHeaderAction];
    }];
    
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self.view);
    }];
    
    if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
        //加载信息流本地缓存
        [self loadInfoFlowCache];
        [_tableView.mj_header beginRefreshing];
        self.headerAutoRefresh = YES;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
    [self addObserver];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)addObserver {
    @weakify(self);
    [RACObserve([LoginManage sharedInstance] , loginState) subscribeNext:^(NSNumber *state) {
        @strongify(self)
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (state.integerValue == LOGIN_STATE_NON) {
                [self.infoFlows removeAllObjects];
                [self reloadData:NO];
                if (!SOS_BUICK_PRODUCT) {
                    [self getBannerRequest];
                }
                if (plainVehicle) {
                    [self hidePlainVehicleStatusWithOffset];
                }
                self.needRecordTimes = NO;
                [MsgCenterManager updateMessageList:nil];
            }else if (state.integerValue == LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS) {
                [self mjHeaderAction];
                self.headerAutoRefresh = YES;
                //获取下星论坛消息  =====>  为什么要在这获取星论坛消息????
                if (![SOSCheckRoleUtil isVisitor]) {
                    [[MsgCenterManager shareInstance] getMessage:^(NSInteger messageNum, id model) {
                        
                    }];
                }
            }
        });
       
    }];
    [RACObserve(self, banners) subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        dispatch_sync_on_main_queue(^{
            //根据数据源变化刷新cell
            [self.tableView reloadSection:0 withRowAnimation:UITableViewRowAnimationAutomatic];
        });
    }];
    
}

- (void)mjHeaderAction	{
    self.pullRefreshStartTime = [[NSDate date] timeIntervalSince1970];
    if ([[LoginManage sharedInstance] isLoadingMainInterfaceFail]) {
        [[LoginManage sharedInstance] reLoadMainInterface];
    }    else    {
        if (!self.headerAutoRefresh) {
            if ([[LoginManage sharedInstance] isLoadingMainInterfaceReady]) {
                NSTimeInterval start = [[NSDate date] timeIntervalSince1970] ;
                [SOSVehicleInfoUtil requestVehicleInfoSuccess:^(id result) {
                    [SOSDaapManager sendSysLayout:start endTime:[[NSDate date] timeIntervalSince1970]  loadStatus:YES  funcId:VEHICLEDIA_LOADTIME];
                } Failure:^(id result) {
                    // 排除因登录状态,重复操作导致的车况刷新操作未能开始的场景
                    if (result) {
                        [SOSDaapManager sendSysLayout:start endTime:[[NSDate date] timeIntervalSince1970]  loadStatus:NO funcId:VEHICLEDIA_LOADTIME];
                    }
                }];
            }
        }
    }
    if (self.headerAutoRefresh) {
        self.needRecordTimes = YES;
    }
    //刷新车况、刷新banner
    if (!SOS_BUICK_PRODUCT) {
        [self getBannerRequest];
    }
    [self requestInfoFlow];
     self.headerAutoRefresh = NO;
    
    [SOSDaapManager sendActionInfo:VEHICLE_PAGERELOAD_DRAG];
}


#pragma mark - table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 ) {
        return self.banners.count ? 1 : 0;
    }
    //无数据显示emptyCell
    return _infoFlows.count > 0 ? _infoFlows.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        SOSBannerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SOSBannerTableViewCell.className forIndexPath:indexPath];
        [cell refreshWithBanners:self.banners];
        cell.imageEndLoadBlock = ^(NSError * _Nullable error) {
            if (self.bannerStartTimeIntervel > 0 && self.bannerResp) {
                self.bannerResp = NO;
            }
        };
        return cell;
    }
    
    if (_infoFlows.count <= 0) {
        SOSInfoFlowTableViewEmptyCell *cell = [tableView dequeueReusableCellWithIdentifier:SOSInfoFlowTableViewEmptyCell.className];
//        [cell shouldShowLoginView:[LoginManage sharedInstance].loginState == LOGIN_STATE_NON];
        return cell;
    }
    SOSInfoFlow *infoFlow = _infoFlows[indexPath.row];
    NSUInteger styleId = infoFlow.attribute.styleId.integerValue;
    if (styleId >= infoFlowCellClasses().count) {
        styleId = SOSInfoFlowStyleNormal;
    }
    __kindof SOSInfoFlowTableViewBaseCell *cell = nil;
    __weak __typeof(self)weakSelf = self;
    cell = [tableView dequeueReusableCellWithIdentifier:infoFlowCellClasses()[styleId].className forIndexPath:indexPath];
    cell.contentView.alpha = tableView.shouldHideCell ? 0 : 1;
    [cell fillData:infoFlow atIndexPath:indexPath];
    cell.funcBtnHandler = ^(NSIndexPath * _Nonnull indexPath) {
        [weakSelf infoFlowjumpBy:2 infoFlow:infoFlow indexPath:indexPath];
    };
    cell.hrefHandler = ^(NSIndexPath * _Nonnull indexPath) {
        [weakSelf infoFlowjumpBy:0 infoFlow:infoFlow indexPath:indexPath];
    };
    return cell;
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        if (_infoFlows.count <= 0) {
            return;
        }
        SOSInfoFlow *infoFlow = _infoFlows[indexPath.row];

        if (!infoFlow.attribute.click) {
            return;
        }
        [self infoFlowjumpBy:1 infoFlow:infoFlow indexPath:indexPath];

    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 1) {
        return NO;
    }
    if (_infoFlows.count <= 0) {
        return NO;
    }
    SOSInfoFlow *infoFlow = _infoFlows[indexPath.row];
    return infoFlow.attribute.slideDelete;
}

//UI中左滑删除需要使用图片，iOS11后有API直接配置，使用trailingSwipeActionsConfigurationForRowAtIndexPath配置即可。
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath  API_AVAILABLE(ios(11.0)){
    return [tableView configTrailingSwipeActionWithIndexPath:(NSIndexPath *)indexPath handler:^(NSIndexPath * _Nonnull indexPath) {
        [self executeDelete:indexPath];
    }];
    
}
//iOS11之前，没有相关API配置图片且没有trailingSwipeActionsConfigurationForRowAtIndexPath这个API，使用editActionsForRowAtIndexPath这个API生成滑动删除,并且需要在SOSInfoFlowTableViewBaseCell的layoutSubView中修改图片。
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView configTrailingSwipeActionWithIndexPath:(NSIndexPath *)indexPath handler:^(NSIndexPath * _Nonnull indexPath) {
        [self executeDelete:indexPath];
    }];
}

#if SOSSDK_SDK
#pragma mark - scroll view delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([SOSCheckRoleUtil isOwner] || [SOSCheckRoleUtil isDriverOrProxy]) {
        if (scrollView.contentOffset.y >= kShowPlainVehicleLine) {
            _statusBarStyle = UIStatusBarStyleDefault;
            [self showPlainVehicleStatusWithOffset:scrollView.contentOffset.y];
        }else{
            _statusBarStyle = UIStatusBarStyleLightContent;
            [self hidePlainVehicleStatusWithOffset];
        }
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
}
#endif
#pragma mark - home me tab delegate

- (void)clickLogin {
    [[LoginManage sharedInstance] presentLoginNavgationController:[SOS_APP_DELEGATE fetchMainNavigationController]];
}
- (void)refreshWithHeaderViewStatus {
    
    if (plainVehicle) {
        [plainVehicle showPlainVehicleStatusWithHeaderViewStatus:tableHeaderView.sta];
    }
}
#pragma mark - http request

- (void)requestInfoFlow {
    
    __weak __typeof(self)weakSelf = self;
    void (^requestInfoFlows)(SOSPOI *) = ^void(SOSPOI *poi) {
        [SOSInfoFlowNetworkEngine requestInfoFlowsWithLat:poi.latitude.doubleValue lon:poi.longitude.doubleValue completionBlock:^(NSMutableArray<SOSInfoFlow *> *data) {
            void (^animateInfoflow)(void) = ^() {
                [weakSelf filterIMInfoFlow:data];
                weakSelf.infoFlows = data;
                [weakSelf synchronizeInfoFlowCache];
                if (weakSelf.infoFlows.count <= 0) {
                    [weakSelf reloadData:NO];
                }else {
                    [weakSelf reloadData:YES];
                }
                [SOSDaapManager sendSysLayout:weakSelf.pullRefreshStartTime endTime:[[NSDate date] timeIntervalSince1970] loadStatus:YES funcId:VEHICLE_INFORFLOW_LOADTIME];
            };
            
            !weakSelf.tableView.mj_header.isRefreshing ? animateInfoflow() : [weakSelf.tableView.mj_header endRefreshingWithCompletionBlock:^{
                animateInfoflow();
            }];
            
        } errorBlock:^(NSInteger statusCode, NSString * _Nonnull responseStr, NSError * _Nonnull error) {
            [SOSDaapManager sendSysLayout:weakSelf.pullRefreshStartTime endTime:[[NSDate date] timeIntervalSince1970] loadStatus:NO funcId:VEHICLE_INFORFLOW_LOADTIME];
            [weakSelf.tableView.mj_header endRefreshing];
            [weakSelf loadInfoFlowCache];
        }];
    };
    
    __block SOSPOI *poi = [SOSPOI new];
//    requestInfoFlows(poi);
    [[SOSUserLocation sharedInstance] getLocationWithAccuarcy:kCLLocationAccuracyHundredMeters NeedReGeocode:YES isForceRequest:NO NeedShowAuthorizeFailAlert:NO success:^(SOSPOI *userLocationPoi) {
        poi = userLocationPoi;
        requestInfoFlows(poi);

    } Failure:^(NSError *error) {
        requestInfoFlows(poi);

    }];
}

- (void)filterIMInfoFlow:(NSMutableArray<SOSInfoFlow *> *)data {

    [data enumerateObjectsUsingBlock:^(SOSInfoFlow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.attribute.styleId.integerValue == SOSInfoFlowStyleIM) {
#ifndef SOSSDK_SDK
            if ([SOSIMNotificationCenter sharedCenter].unreadCount <= 0 ) {
                [data removeObject:obj];
                *stop = YES;
            }
#else
            [data removeObject:obj];
            *stop = YES;
#endif
           
        }
    }];

}

- (void)getBannerRequest {
    self.bannerStartTimeIntervel =[[NSDate date] timeIntervalSince1970] ;
    self.bannerResp = NO;
    @weakify(self);
    [OthersUtil getBannerByCategory:MA9_INDEX_BANNER SuccessHandle:^(NSArray *banners) {
        @strongify(self);
        double endTime = [[NSDate date] timeIntervalSince1970] ;
        [SOSDaapManager sendSysLayout:self.bannerStartTimeIntervel endTime:endTime loadStatus:YES funcId:SMARTVEHICLE_BANNER_LOADTIME];
        self.bannerStartTimeIntervel = 0;
        self.bannerResp = YES;
        self.banners = banners;
      
    } failureHandler:^(NSString *responseStr, NSError *error) {
        self.bannerResp = YES;
        double endTime = [[NSDate date] timeIntervalSince1970] ;
        [SOSDaapManager sendSysLayout:self.bannerStartTimeIntervel endTime:endTime loadStatus:NO funcId:SMARTVEHICLE_BANNER_LOADTIME];
        self.bannerStartTimeIntervel = 0;
        self.banners = @[];
       
    }];

}

#pragma mark - custom method

/**
 信息流跳转

 @param type 0:href 1:click 2:button
 */
- (void)infoFlowjumpBy:(NSUInteger)type infoFlow:(SOSInfoFlow *)infoFlow indexPath:(NSIndexPath *)indexPath {
    SOSIFComponent *componet;
    if (type == 0) {
        componet = infoFlow.action.href;
    }else if (type == 1) {
        componet = infoFlow.action.click;
    }else if (type == 2) {
        componet = infoFlow.action.button;
    }
    [SOSDaapManager sendSysBanner:infoFlow.attribute.bid type:@"BusinessLine" funcId:componet.clickFID];
    SOSInfoFlowJumpHelper *helper = [[SOSInfoFlowJumpHelper alloc] initWithFromViewController:self];
    [helper jumpTo:componet para:componet.param];
    if (infoFlow.attribute.viewDelete) {
        [self executeDelete:indexPath];
    }

}

/**
 加载信息流本地归档数据
 */
- (void)loadInfoFlowCache {
    BOOL isExpired = [SOSInfoFlowArchiver isExpired];
    if (isExpired) {
        return;
    }
    _infoFlows = [SOSInfoFlowArchiver unarchiveInfoFlows].mutableCopy;
    
    [self reloadData:NO];
}


/**
 归档信息流数据
 */
- (void)synchronizeInfoFlowCache {
    [SOSInfoFlowArchiver archiveInfoFlows:_infoFlows];
}


/**
 删除某条信息流

 @param indexPath indexPath
 */

- (void)executeDelete:(NSIndexPath *)indexPath {
    SOSInfoFlow *infoFlow = _infoFlows[indexPath.row];
    [_infoFlows removeObjectAtIndex:indexPath.row];
    [self synchronizeInfoFlowCache];
    [_tableView reloadSection:1 withRowAnimation:UITableViewRowAnimationAutomatic];
    self.bottomImageView.hidden = _infoFlows.count > 0;

//    if (_infoFlows.count <= 0) {
//        [_tableView reloadSection:1 withRowAnimation:UITableViewRowAnimationAutomatic];
//    }else {
//        [_tableView beginUpdates];
//        [_tableView deleteRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationAutomatic];
//        [_tableView endUpdates];
//    }
    [SOSDaapManager sendSysBanner:infoFlow.attribute.bid funcId:infoFlow.action.click.deleteFID];
    ///一个划水架构订的方案，27、28不能调用大数据删除，改方案
    if ([infoFlow.attribute.bid isEqualToString:@"27"]) {
        ///27未读消息客户端删除,不通知后台
        return;
    }
    if ([infoFlow.attribute.bid isEqualToString:@"28"]) {
        ///28调用social删除
        [SOSInfoFlowNetworkEngine deleteForumHotInfoFlow:infoFlow.attribute.bid completionBlock:nil errorBlock:nil];
        return;
    }
    ///广告信息流
    if ([infoFlow.attribute.bid isEqualToString:@"30"]) {
        [SOSInfoFlowNetworkEngine deleteAdvertisementInfoFlow:infoFlow.attribute.desc completionBlock:nil errorBlock:nil];
        return;
    }
    [SOSInfoFlowNetworkEngine deleteInfoFlow:infoFlow.attribute.bid idt:infoFlow.attribute.idt completionBlock:nil errorBlock:nil];

}

/**
 显示简明车况
 @param offset
 */
-(void)showPlainVehicleStatusWithOffset:(CGFloat)offset{
    
    if (plainVehicle.alpha != 1.0f) {
        if (!plainVehicle) {
            plainVehicle = [[SOSPlainVehicleConditionView alloc] initWithFrame:CGRectZero];
            [self.view addSubview:plainVehicle];
            [plainVehicle mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@64);
                make.top.left.right.equalTo(self.view);
            }];
            [plainVehicle showPlainVehicleStatusWithHeaderViewStatus:tableHeaderView.sta];
        }
        plainVehicle.alpha = 0.1+ceil(offset -kShowPlainVehicleLine)/soskBeginShowPlainVehicleStatus;
    }
}

//- (UIView *)copyView:(UIView *)view{
//    NSData * tempArchive = [NSKeyedArchiver archivedDataWithRootObject:view];1B3163
//    return [NSKeyedUnarchiver unarchiveObjectWithData:tempArchive];
//}

-(void)hidePlainVehicleStatusWithOffset{
    
    if (plainVehicle) {
        plainVehicle.alpha = 0.0f;
        [plainVehicle removeFromSuperview];
        plainVehicle = nil;
    }
    //   NSLog(@"hidePlainVehicleStatusWithOffset%f",alp);
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return _statusBarStyle;
}

- (UIView *)tableViewBackgroundView {
    UIView *bgView = [UIView new];
    bgView.backgroundColor = [UIColor clearColor];
    UIView *refreshBgView = [UIView new];
    refreshBgView.backgroundColor = [UIColor colorWithHexString:@"1B3163"];
    [bgView addSubview:refreshBgView];
    [refreshBgView mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.left.right.equalTo(bgView);
        make.height.equalTo(@200);
    }];
    
    UIImageView *imageView = [UIImageView new];
    imageView.image = [UIImage imageNamed:@"Bg_car_bg_user_def_375x116"];
    [bgView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make){
        make.height.equalTo(@(SCREEN_WIDTH / 375 * 225));
        make.bottom.left.right.equalTo(bgView);
    }];
    _bottomImageView = imageView;
    return bgView;
}


/// 请用该方法reloadData，不要直接调用tableView reloadData
/// @param animated 信息流是否执行动画
- (void)reloadData:(BOOL)animated {
    if (_infoFlows.count <= 0) {
        [_tableView reloadData];
        _bottomImageView.hidden = NO;
    }else {
        animated ? [_tableView reloadDataAndshowCellAnimation] : [_tableView reloadData];
        _bottomImageView.hidden = YES;
    }
}

@end
