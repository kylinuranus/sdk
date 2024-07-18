//
//  SOSPOIMapVC.m
//  Onstar
//
//  Created by Genie Sun on 2017/8/10.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSSearchViewController.h"
#import "SOSHomeAndCompanyTool.h"
#import "SOSAYChargeManager.h"
#import "SOSLBSMapInfoView.h"
#import "SOSCheckRoleUtil.h"
#import "NavigateSearchVC.h"
#import "SOSNavigateTool.h"
#import "SOSUserLocation.h"
#import "SOSGeoDataTool.h"
#import "LoadingView.h"
#import "SOSPOIMapVC.h"

@interface SOSPOIMapVC ()

@end

@implementation SOSPOIMapVC

#pragma mark - System Method
- (instancetype)init    {
    self = [super init];
    if (self) {
        self.mapType = MapTypeRootWindow;
    }
    return self;
}

+ (instancetype)new     {
    SOSPOIMapVC *vc = [[SOSPOIMapVC alloc] init];
    return vc;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil    {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.mapType = MapTypeRootWindow;
    }
    return self;
}

- (id)initWithPoiInfo:(SOSPOI *)poiInfo  {
    self = [super initWithPoiInfo:poiInfo];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.shouldShowVehicleLocation = YES;
    self.actionNavigation.poi = self.selectedPOI;
    self.infoTableView.poi = self.selectedPOI;
    [self configRouteButtonAction];
    [self addObserver];
}

- (void)addObserver		{
    __weak __typeof(self) weakSelf = self;
    [[[LoginManage sharedInstance] rac_valuesAndChangesForKeyPath:@"loginState" options:NSKeyValueObservingOptionNew observer:self] subscribeNext:^(RACTwoTuple<id,NSDictionary *> *x) {
        if ([LoginManage sharedInstance].loginState == LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS || [LoginManage sharedInstance].loginState == LOGIN_STATE_NON) {
            if ([Util vehicleIsG9] || [SOSCheckRoleUtil isDriverOrProxy])   weakSelf.topButtonBGViewHeightGuide.constant = 80.f;
            else 															weakSelf.topButtonBGViewHeightGuide.constant = 120;
            [weakSelf.view layoutIfNeeded];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated	{
    [super viewDidAppear:animated];
    [self.mapView addPoiPoints:self.poisShowingOnMap];
    if (self.selectedPOI == nil || self.selectedPOI.sosPoiType == POI_TYPE_CURRENT_LOCATION) {
        if ([CustomerInfo sharedInstance].currentPositionPoi) {
            self.selectedPOI = [CustomerInfo sharedInstance].currentPositionPoi;
            [self showPositionInfoViewWithPoiInfo:self.selectedPOI];
        }   else    {
            [self buttonLocationTapped];
        }
    }   else    {
        [self showPositionInfoViewWithPoiInfo:self.selectedPOI];
        [self.mapView showPoiPoints:@[self.selectedPOI] animated:YES NeedResetMap:YES];
    }
}

#pragma mark - 配置不同地图类型显示
- (void)configView   {
    BOOL shouldAddGes = YES;
    switch (self.mapType)   {
        case MapTypeShowRVMirror:
            [self configRVMirrorView];
            break;
        ///地图展示Poi点
        case MapTypeShowPoiPoint:
            if ([Util vehicleIsG9] || [SOSCheckRoleUtil isDriverOrProxy])     self.topButtonBGViewHeightGuide.constant = 80.f;
            self.mapLocationInfoView.poiInfo = self.selectedPOI;
            [self.mapLocationInfoView configView:MapTypeShowPoiPoint];
            break;
        /// 充电桩
        case MapTypeShowChargeStation:
            [self configChargrStationView];
            break;
        ///加油站
        case MapTypeOil:
            [self configOilStationView];
            break;
        /// 经销商
        case MapTypeShowDealerPOI:
            [self configDealerViewAndNav];
            break;
        default:
            if ([Util vehicleIsG9] || [SOSCheckRoleUtil isDriverOrProxy])     self.topButtonBGViewHeightGuide.constant = 80.f;
            break;
    }
    if (self.fd_prefersNavigationBarHidden == NO) {
        self.topButtonBGViewTopGuide.constant = 20.f;
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    if (shouldAddGes && !panGR ) {
        panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragScrollview:)];
        [self.mapLocationInfoView addGestureRecognizer:panGR];
    }
}


- (void)configRVMirrorView	{
    self.topButtonBGViewHeightGuide.constant = 80.f;
    self.zoomButtonBGView.hidden = YES;
    //self.infoTableView.hidden = YES;
    //self.mapLocationInfoView.hidden = YES;
}


#pragma mark - 加油站相关
- (void)configOilStationView {
    self.fd_prefersNavigationBarHidden = NO;
    self.title = @"加油站";
    self.navSearchBGView.hidden = YES;
    self.mapLocationInfoView.poiInfo = self.selectedPOI;
    
    [self.mapLocationInfoView configView:MapTypeShowPoiPoint];
    self.topButtonBGViewHeightGuide.constant = 80.f;
}

#pragma mark - 充电桩相关
- (void)configChargrStationView     {
    self.fd_prefersNavigationBarHidden = NO;
    self.title = @"充电桩详情";
    self.navSearchBGView.hidden = YES;
    self.topButtonBGViewHeightGuide.constant = 80.f;
    [self.mapLocationInfoView configView:MapTypeShowPoiPoint];
    
    NSString *prefix = @"";
    UIColor *noLbColor = nil;
    
    if ( ![self.chargeStation.supplier isEqualToString:@"安悦充电"]) {		//4s店
        self.mapLocationInfoView.chargeDetailView.hidden = YES;
        self.mapLocationInfoViewHeightGuide.constant = 100.f;
        self.mapLocationInfoView.idleFastNoLb.text = @"";
        self.mapLocationInfoView.idleLowNoLb.text = @"";
        
        self.mapLocationInfoView.ayChargeButton.hidden = YES;
        self.mapLocationInfoView.ayChargeTitleLabel.hidden = YES;
        self.mapLocationInfoView.lowNoLb.textColor = self.chargeStation.slowCharge.integerValue == 0 ? UIColorHex(0xF6A623) : UIColorHex(0x107FE0);;
        self.mapLocationInfoView.fastNoLb.textColor = self.chargeStation.quickCharge.integerValue == 0 ? UIColorHex(0xF6A623) : UIColorHex(0x107FE0);;
    }	else 	{		//安悦充电桩显示详情
        self.mapLocationInfoViewHeightGuide.constant = 175.f;
        self.mapLocationInfoView.chargeDetailView.hidden = NO;
        self.mapLocationInfoView.supplierLabel.text = self.chargeStation.supplier?:@"";
        self.mapLocationInfoView.idleLowNoLb.hidden = NO;
        self.mapLocationInfoView.idleFastNoLb.hidden = NO;
        self.mapLocationInfoView.titleLabelTrailingGuide.constant = 60;
        prefix = @"/";
        noLbColor = UIColorHex(0x59708A);
        self.mapLocationInfoView.idleLowNoLb.text = [NSString stringWithFormat:@"%02d",self.chargeStation.idleSlowCharge.intValue];
        self.mapLocationInfoView.idleFastNoLb.text = [NSString stringWithFormat:@"%02d",self.chargeStation.idleQuickCharge.intValue];
        
        if (self.chargeStation.idleSlowCharge.integerValue == 0)    self.mapLocationInfoView.idleLowNoLb.textColor = UIColorHex(0xF6A623);
        if (self.chargeStation.idleQuickCharge.integerValue == 0)    self.mapLocationInfoView.idleFastNoLb.textColor = UIColorHex(0xF6A623);
        
        self.mapLocationInfoView.ayChargeButton.hidden = NO;
        self.mapLocationInfoView.ayChargeTitleLabel.hidden = NO;
        [[self.mapLocationInfoView.ayChargeButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            [SOSDaapManager sendActionInfo:Map_POIdetail_anyocharging];
            [SOSAYChargeManager enterAYChargeVCIsFromCarLife:NO];
        }];
        self.mapLocationInfoView.lowNoLb.textColor = noLbColor;
        self.mapLocationInfoView.fastNoLb.textColor = noLbColor;
    }
    
    self.mapLocationInfoView.lowNoLb.text = [NSString stringWithFormat:@"%@%02d", prefix, self.chargeStation.slowCharge.intValue];
    self.mapLocationInfoView.fastNoLb.text = [NSString stringWithFormat:@"%@%02d", prefix, self.chargeStation.quickCharge.intValue];
    
    self.mapLocationInfoView.smallIcon.image = [UIImage imageNamed:@"icon_car_location_shadow_enegy_green_idle"];
    self.mapLocationInfoView.iconY.constant = 22;
    self.mapLocationInfoView.titleY.constant = 4;
    self.mapLocationInfoView.fastLb.hidden = NO;
    self.mapLocationInfoView.lowLb.hidden = NO;
    self.mapLocationInfoView.fastNoLb.hidden = NO;
    self.mapLocationInfoView.lowNoLb.hidden = NO;
    
    self.mapLocationInfoView.openTimeLabel.text = self.chargeStation.openTime?:@"";
    self.mapLocationInfoView.quickChargeCostFeeLabel.text = self.chargeStation.quickChargeCostFee?:@"";
    self.mapLocationInfoView.slowChargeCostFeeLabel.text = self.chargeStation.slowChargeCostFee?:@"";
    self.mapLocationInfoView.serveFeeLabel.text = self.chargeStation.serveFee ? : @"";

    self.mapLocationInfoView.poiInfo = self.selectedPOI;
}

#pragma mark - 经销商 相关
/// 配置 经销商 地图页面
- (void)configDealerViewAndNav      {
    [SOSDaapManager sendActionInfo:Dealeraptmt_Map];
    self.fd_prefersNavigationBarHidden = NO;
    self.navSearchBGView.hidden = YES;
    self.title = @"查看地图";
    self.topButtonBGView.hidden = YES;
    self.zoomButtonBGView.hidden = YES;
    self.topButtonBGViewHeightGuide.constant = 80.f;
    self.infoTableView.contentType = ContentTypeDealer;
    self.infoPOI.sosPoiType = POI_TYPE_Dealer;
    self.infoTableView.poi = self.infoPOI;
    [self.actionNavigation.ensureButton setTitle:@"立刻预约" forState:UIControlStateNormal];
    self.actionNavigation.ensureButton.hidden = NO;
    // 立刻预约 事件
    @weakify(self)
    [[self.actionNavigation.ensureButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if (self.dealer.dealerCode.length <= 0) {
            [Util toastWithMessage:@"亲，该经销商不支持预约系统，建议您直接电话联系。"];
            return;
        }
        [SOSDaapManager sendActionInfo:Dealeraptmt_Map_Order];
        SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:[Util getStaticConfigureURL:@"/mweb/ma80/redealer/index.html#/choiseTime"]];
        vc.isDealer = YES;
        vc.dealerName = self.dealer.dealerName;
        vc.dealerCode = self.dealer.dealerCode;
        [self.navigationController pushViewController:vc animated:YES];

    }];
}

- (NSString*)getDealerUrl	{
    if ([[[CustomerInfo sharedInstance] currentVehicle].brand isEqualToString:@"CHEVROLET"]) {
        return [Util getStaticConfigureURL:@"/mweb/ma80/redealer/index.html#/order"];
    }	else	{
        return [Util getStaticConfigureURL:@"/mweb/ma80/redealer/index.html#/choiseTime"];
    }
}

#pragma mark - 显示选中POI点信息
- (void)showPositionInfoViewWithPoiInfo:(SOSPOI *)poi   {
    [super showPositionInfoViewWithPoiInfo:poi];
}

#pragma mark - Button Action
- (IBAction)backPopVc:(id)sender {
    [SOSDaapManager sendActionInfo:Map_back];
    if (self.navigationController) 	{
        [self.navigationController popViewControllerAnimated:YES];
    }	else	{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)searchButtonTapped {
    [SOSDaapManager sendActionInfo:Map_POIsearch];
    switch (self.mapType) {
        case MapTypeRootWindow: {
            NavigateSearchVC *searchVC = [NavigateSearchVC new];
            [self.navigationController pushViewController:searchVC animated:YES];
            break;
        }
        default:
            [self.navigationController popViewControllerAnimated:YES];
            break;
    }
}

#pragma mark - 上划手势处理
- (void)dragScrollview:(UIPanGestureRecognizer *)recognizer {
    [super dragScrollview:recognizer];
}

@end
