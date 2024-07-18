//
//  SOSTripCardBGScrollView.m
//  Onstar
//
//  Created by Coir on 2018/12/18.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSTripCardBGScrollView.h"
#import "SOSGreetingManager.h"
#import "FootPrintDataOBJ.h"
#import "SOSTrailCardView.h"
#import "SOSTripCardView.h"
#import "SOSTripModule.h"
#import "SOSTripHomeVC.h"
#import "SOSCardUtil.h"



#import "NavigateShareTool.h"
#import "UIImageView+WebCache.h"

@interface SOSTripCardBGScrollView () <SOSTripCardDelegate, UIScrollViewDelegate>

@property (nonatomic, strong, nullable) SOSTripCardView *driveBehiverCard;
@property (nonatomic, strong, nullable) SOSTripCardView *oliCard;
@property (nonatomic, strong, nullable) SOSTripCardView *energyCard;
@property (nonatomic, strong, nullable) SOSTripCardView *footprintCard;
@property (nonatomic, strong, nullable) SOSTrailCardView *trailCard;

@property (nonatomic, strong) NSMutableArray *cardsArray;

@property (nonatomic, assign) CGPoint beginPoint;
@property (nonatomic, assign) float originX;


@end

@implementation SOSTripCardBGScrollView

- (void)awakeFromNib	{
    [super awakeFromNib];
    self.delegate = self;
    __weak __typeof(self) weakSelf = self;
    [self rebuildContentCardView];
    [[[LoginManage sharedInstance] rac_valuesAndChangesForKeyPath:@"loginState" options:NSKeyValueObservingOptionNew observer:self] subscribeNext:^(RACTwoTuple<id,NSDictionary *> *x) {
        id newValue = x.first;
        if ([newValue isKindOfClass:[NSNumber class]]) {
            LOGIN_STATE_TYPE newState = [newValue intValue];
            switch (newState) {
                // 用户退出登录
                case LOGIN_STATE_NON:
//                    [SOSGreetingManager shareInstance].footmarkData = nil;
                    [weakSelf rebuildContentCardView];
                    break;
                // 用户登录成功
                case LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS:	{
//                    [SOSGreetingManager shareInstance].footmarkData = nil;
                    [[CustomerInfo sharedInstance].servicesInfo getResponseFromSeriverComplete:^{
                        [weakSelf rebuildContentCardView];
                    }];
                    break;
                }
                default:
                    break;
            }
        }
    }];
}

- (void)rebuildContentCardView	{
    self.cardsArray = [NSMutableArray array];
    BOOL shouldShowDriveBehiver = [SOSTripModule shouldShowCardWithCardType:SOSTripCardType_DriveBehiver];
    BOOL shouldShowOli = [SOSTripModule shouldShowCardWithCardType:SOSTripCardType_OilLevel];
    BOOL shouldShowenergy = [SOSTripModule shouldShowCardWithCardType:SOSTripCardType_EnergyLevel];
    BOOL shouldShowFootprint = [SOSTripModule shouldShowCardWithCardType:SOSTripCardType_Footprint];
    
    shouldShowDriveBehiver=false; //驾驶行为和近期行程
    shouldShowFootprint=false; //我的足迹

    
    dispatch_async_on_main_queue(^{
        [self removeAllSubviews];
        float cardRight = 0;

        // 近期行程显示逻辑与驾驶行为相同, 位置在最左侧
        if (shouldShowDriveBehiver) { //近期行程
            SOSTrailCardView *cardView = [SOSTrailCardView viewFromXib];
            cardView.frame = CGRectMake(cardRight + 12, 0, 150, 160);
            cardView.delegate = self;
            
            cardRight = cardView.right;
            [self addSubview:cardView];
            [self.cardsArray addObject:cardView];
            self.trailCard = cardView;
            [self reloadTrailCardData];
        }    else    self.trailCard = nil;
        
        if (shouldShowDriveBehiver) {//驾驶行为
            SOSTripCardView *cardView = [self getNewCardViewWithLeft:cardRight + 12 AndCardType:SOSTripCardType_DriveBehiver];
            cardRight = cardView.right;
            [self addSubview:cardView];
            [self.cardsArray addObject:cardView];
            self.driveBehiverCard = cardView;
            [self reloadDriveBehiverData];
        }	else	self.driveBehiverCard = nil;
        
        if (shouldShowOli) { //油耗
            SOSTripCardView *cardView = [self getNewCardViewWithLeft:cardRight + 12 AndCardType:SOSTripCardType_OilLevel];
            cardRight = cardView.right;
            [self addSubview:cardView];
            [self.cardsArray addObject:cardView];
            self.oliCard = cardView;
            [self reloadOliData];
        }	else	self.oliCard = nil;
        
        if (shouldShowenergy) {//能耗
            SOSTripCardView *cardView = [self getNewCardViewWithLeft:cardRight + 12 AndCardType:SOSTripCardType_EnergyLevel];
            cardRight = cardView.right;
            [self addSubview:cardView];
            [self.cardsArray addObject:cardView];
            self.energyCard = cardView;
            [self reloadEnergyData];
        }	else	self.energyCard = nil;
        
        if (shouldShowFootprint) {//我的足迹
            SOSTripCardView *cardView = [self getNewCardViewWithLeft:cardRight + 12 AndCardType:SOSTripCardType_Footprint];
            cardRight = cardView.right;
            [self addSubview:cardView];
            [self.cardsArray addObject:cardView];
            self.footprintCard = cardView;
            [self reloadFootPrintData];
        }	else	self.footprintCard = nil;
        
        
        self.contentSize = CGSizeMake(cardRight + 12, 160);
    });
}

- (void)startAnimating	{
    if (!self.cardsArray.count) 		return;
    __block float lastCardRight = 0.f;
    for (int i = 0; i < self.cardsArray.count; i++) {
        UIView *card = self.cardsArray[i];
        card.alpha = 0;
        card.left = self.width;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25 * i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            lastCardRight = i * (card.width + 12) + 12;
            [UIView animateWithDuration:.25 animations:^{
                card.left = lastCardRight;
                card.alpha = 1;
            }];
        });
    }
}

#pragma mark - 刷新卡片数据
- (void)reloadOliData		{
    if (!self.oliCard)        return;
    self.oliCard.cardStatus = SOSTripCardStatus_Loading;
    
    [[CustomerInfo sharedInstance].servicesInfo getResponseFromSeriverForce:YES complete:^{
        NNRankReq *rankReq = [NNRankReq new];
        rankReq.isLogin = [[LoginManage sharedInstance] isLoadingUserBasicInfoReady] && ![SOSCheckRoleUtil isVisitor];
        rankReq.role = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.role ? : @"Nologin";
        rankReq.optStatus = [CustomerInfo sharedInstance].servicesInfo.FuelEconomy.optStatus;
        rankReq.avalibility =  [CustomerInfo sharedInstance].servicesInfo.FuelEconomy.availability;
        rankReq.isGen10 = [CustomerInfo sharedInstance].currentVehicle.gen10;
        self.oliCard.requestStartTime = [[NSDate date] timeIntervalSince1970];
        [SOSCardUtil getOilRank:rankReq Success:^(NNOilRankResp *resp) {
            self.oliCard.cardStatus = SOSTripCardStatus_LoadDataSuccess;
            [self.oliCard configSelfWithCardType:SOSTripCardType_OilLevel AndData:resp];
            [SOSDaapManager sendSysLayout:self.oliCard.requestStartTime endTime:[[NSDate date] timeIntervalSince1970] loadStatus:YES  funcId:TRIP_FUELCONSUMPTIONCARDTIME];
        } Failed:^(NSString *responseStr, NSError *error) {
            [SOSDaapManager sendSysLayout:self.oliCard.requestStartTime endTime:[[NSDate date] timeIntervalSince1970]  loadStatus:NO  funcId:TRIP_FUELCONSUMPTIONCARDTIME];
            self.oliCard.cardStatus = SOSTripCardStatus_LoadDataError;
        }];
    }];
}

- (void)reloadEnergyData	{
    if (!self.energyCard)        return;
    self.energyCard.cardStatus = SOSTripCardStatus_Loading;
    [[CustomerInfo sharedInstance].servicesInfo getResponseFromSeriverForce:YES complete:^{
        NNRankReq *rankReq = [NNRankReq new];
        rankReq.isLogin = [[LoginManage sharedInstance] isLoadingUserBasicInfoReady];
        rankReq.role = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.role?:@"Nologin";
        rankReq.optStatus = [CustomerInfo sharedInstance].servicesInfo.EnergyEconomy.optStatus;
        rankReq.avalibility =  [CustomerInfo sharedInstance].servicesInfo.EnergyEconomy.optStatus;//能耗无可见状态根据optstatus来判断
        rankReq.isGen10 = [CustomerInfo sharedInstance].currentVehicle.gen10;
        rankReq.isPHEV = [Util vehicleIsPHEV] || [Util vehicleIsBEV];
        self.energyCard.requestStartTime = [[NSDate date] timeIntervalSince1970];
        [SOSCardUtil getEnergyRank:rankReq Success:^(NNEngrgyRankResp *resp) {
            self.energyCard.cardStatus = SOSTripCardStatus_LoadDataSuccess;
            [self.energyCard configSelfWithCardType:SOSTripCardType_EnergyLevel AndData:resp];
            [SOSDaapManager sendSysLayout:self.energyCard.requestStartTime endTime:[[NSDate date] timeIntervalSince1970]  loadStatus:YES  funcId:TRIP_ENERGYCONSUMPTIONCARDTIME];
        } Failed:^(NSString *responseStr, NSError *error) {
            self.energyCard.cardStatus = SOSTripCardStatus_LoadDataError;
            [SOSDaapManager sendSysLayout:self.energyCard.requestStartTime endTime:[[NSDate date] timeIntervalSince1970]  loadStatus:NO  funcId:TRIP_ENERGYCONSUMPTIONCARDTIME];    }];
    }];
}

- (void)reloadDriveBehiverData	{
    if (!self.driveBehiverCard)		return;
    self.driveBehiverCard.cardStatus = SOSTripCardStatus_Loading;
    
    [[CustomerInfo sharedInstance].servicesInfo getResponseFromSeriverForce:YES complete:^{
        NNCarconditionReportReq *req = [NNCarconditionReportReq new];
        req.isLogin = [[LoginManage sharedInstance] isLoadingUserBasicInfoReady] && ![SOSCheckRoleUtil isVisitor];
        req.role = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.role?:@"Nologin";
        req.optStatus = [CustomerInfo sharedInstance].servicesInfo.SmartDrive.optStatus;
        req.avalibility =  [CustomerInfo sharedInstance].servicesInfo.SmartDrive.availability;
        req.isGen10 = [CustomerInfo sharedInstance].currentVehicle.gen10;
        req.isPHEV = [Util vehicleIsPHEV] || [Util vehicleIsBEV];
        
        NSString *key = [NSString stringWithFormat:@"drivingScoreFirstInfo_%@",[Util md5:[CustomerInfo sharedInstance].userBasicInfo.idpUserId]];
        BOOL flg = UserDefaults_Get_Bool(key);
        req.isFirstInfo = !flg;
        self.driveBehiverCard.requestStartTime = [[NSDate date] timeIntervalSince1970] ;
        [SOSCardUtil getDrivingScore:req Success:^(NNDrivingScoreResp *resp) {
            self.driveBehiverCard.cardStatus = SOSTripCardStatus_LoadDataSuccess;
            [self.driveBehiverCard configSelfWithCardType:SOSTripCardType_DriveBehiver AndData:resp];
            [SOSDaapManager sendSysLayout:self.driveBehiverCard.requestStartTime endTime:[[NSDate date] timeIntervalSince1970]  loadStatus:YES funcId:TRIP_SMARTDRIVERCARDTIME];
        } Failed:^(NSString *responseStr, NSError *error) {
            self.driveBehiverCard.cardStatus = SOSTripCardStatus_LoadDataError;
            [SOSDaapManager sendSysLayout:self.driveBehiverCard.requestStartTime endTime:[[NSDate date] timeIntervalSince1970]  loadStatus:NO funcId:TRIP_SMARTDRIVERCARDTIME ];
        }];
    }];
}

- (void)reloadFootPrintData		{
    if (!self.footprintCard)		return;
    if ([SOSCheckRoleUtil isOwner] && [[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
        
        self.footprintCard.cardStatus = SOSTripCardStatus_Loading;
        self.footprintCard.requestStartTime = [[NSDate date] timeIntervalSince1970] ;
        [FootPrintDataOBJ getFootPrintOverViewLoading:NO Success:^(NSMutableDictionary *dataArray) {
            //            [SOSGreetingManager shareInstance].footmarkData = dataArray;
            self.footprintCard.cardStatus = SOSTripCardStatus_LoadDataSuccess;
            [self.footprintCard configSelfWithCardType:SOSTripCardType_Footprint AndData:dataArray];
            [SOSDaapManager sendSysLayout:self.footprintCard.requestStartTime endTime:[[NSDate date] timeIntervalSince1970]  loadStatus:YES  funcId:TRIP_FOOTPRINTSCARDTIME];
        } Failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            self.footprintCard.cardStatus = SOSTripCardStatus_LoadDataError;
            [SOSDaapManager sendSysLayout:self.footprintCard.requestStartTime endTime:[[NSDate date] timeIntervalSince1970]  loadStatus:NO  funcId:TRIP_FOOTPRINTSCARDTIME];
        }];
    }	else	{
        self.footprintCard.cardStatus = SOSTripCardStatus_DemoData;
    }
}

- (void)reloadTrailCardData		{
    if (!self.trailCard)        return;
    self.trailCard.cardStatus = SOSTripCardStatus_Loading;
    
    [SOSCardUtil getTrailDataSuccess:^(SOSTrailResp *response) {
        self.trailCard.data = response;
    } Failed:^(NSString *responseStr, NSError *error) {
        self.trailCard.cardStatus = SOSTripCardStatus_LoadDataError;
    }];
}

- (SOSTripCardView *)getNewCardViewWithLeft:(float)left AndCardType:(SOSTripCardType)type		{
    SOSTripCardView *cardView = [SOSTripCardView initWithCardType:type];
    cardView.frame = CGRectMake(left, 0, 150, 160);
    cardView.delegate = self;
    return cardView;
}

#pragma mark - Card Delegate
// 重新加载
- (void)refreshCardButtonTappedWithCardView:(UIView *)cardView		{
    if ([cardView isKindOfClass:[SOSTripCardView class]]) {
        switch ( ((SOSTripCardView *)cardView).cardType ) {
            case SOSTripCardType_DriveBehiver:
                [self reloadDriveBehiverData];
                break;
            case SOSTripCardType_EnergyLevel:
                [self reloadEnergyData];
                break;
            case SOSTripCardType_OilLevel:
                [self reloadOliData];
                break;
            case SOSTripCardType_Footprint:
                [self reloadFootPrintData];
                break;
            default:
                break;
        }
    }	else if ([cardView isKindOfClass:[SOSTrailCardView class]])	{
        // 近期行程卡片
        [self reloadTrailCardData];
    }
}

// 卡片点击事件
- (void)cardTappedWithCardView:(UIView *)cardView	{
    if ([cardView isKindOfClass:[SOSTripCardView class]]) {
        switch ( ((SOSTripCardView *)cardView).cardType ) {
            case SOSTripCardType_DriveBehiver:    {//驾驶行为评价
                
                [SOSDaapManager sendActionInfo:TRIP_SMARTDRIVER];
                [SOSCardUtil routerToDrivingScoreH5FromVC:nil WithPageBackBlock:^{
                    [self reloadDriveBehiverData];
                } LoadingStartTime:[[NSDate date] timeIntervalSince1970] AndSuccessFuncID:TRIP_SMARTDRIVERPAGETIME FailureFuncID:TRIP_SMARTDRIVERPAGETIME];
                break;
            }
            case SOSTripCardType_EnergyLevel:    {
                [SOSDaapManager sendActionInfo:TRIP_ENERGYCONSUMPTION];
                [SOSCardUtil routerToEnergyRankH5WithPageBackBlock:^{
                    [self reloadEnergyData];
                } LoadingStartTime:[[NSDate date] timeIntervalSince1970] AndSuccessFuncID:TRIP_ENERGYCONSUMPTIONPAGETIME FailureFuncID:TRIP_ENERGYCONSUMPTIONPAGETIME];
                break;
            }
            case SOSTripCardType_Footprint:    { //我的足迹
                [SOSDaapManager sendActionInfo:TRIP_FOOTPRINTS];
                [SOSCardUtil routerToFootMarkWithPageBackBlock:nil];
                break;
            }
            case SOSTripCardType_OilLevel:    {
                [SOSDaapManager sendActionInfo:TRIP_FUELCONSUMPTION];
                [SOSCardUtil routerToOilRankH5WithPageBackBlock:^{
                    [self reloadOliData];
                } LoadingStartTime:[[NSDate date] timeIntervalSince1970] AndSuccessFuncID:TRIP_FUELCONSUMPTIONPAGETIME FailureFuncID:TRIP_FUELCONSUMPTIONPAGETIME];
                break;
            }
            default:
                break;
        }
    }    else if ([cardView isKindOfClass:[SOSTrailCardView class]])    {
        // 近期行程卡片
        [SOSDaapManager sendActionInfo:RecentTrip_Entrance];
        if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
            [self enterTrailWebVC];
        }	else	{
            [[LoginManage sharedInstance] checkAndShowLoginViewFromViewController:self.viewController withLoginDependence:[[LoginManage sharedInstance] isLoadingUserBasicInfoReady] showConnectVehicleAlertDependence:NO completion:^(BOOL finished) {
                if (finished) {
                    [self enterTrailWebVC];
                }
            }];
        }
        
    }
}

- (void)enterTrailWebVC		{
    if (![SOSCheckRoleUtil checkVisitorInPage:nil])		return;
    NSString *url = self.trailCard.data.linkUrl;
    SOSWebViewController *webVC = [[SOSWebViewController alloc] initWithUrl:url];
    [webVC addTopCoverView];
    [SOSCardUtil routerToVc:webVC checkAuth:YES checkLogin:NO];
    [self reloadTrailCardData];
}

#pragma mark - BG View Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView	{
    SOSTripHomeVC *vc = (SOSTripHomeVC *)self.viewController;
    [vc hideGuideButton];
}

// Touch Delegate
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event     {
    NSLog(@"Touch Begin");
    SOSTripHomeVC *vc = (SOSTripHomeVC *)self.viewController;
    [vc hideGuideButton];
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    self.beginPoint = [touch locationInView:self.viewController.view];
    self.originX = self.contentOffset.x;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event		{
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint nowPoint = [touch locationInView:self.viewController.view];
    float offsetX = nowPoint.x - self.beginPoint.x;
    float offsetY = nowPoint.y - self.beginPoint.y;
    if (ABS(offsetX * .3) > ABS(offsetY)) {
        [self setContentOffset:CGPointMake(_originX - offsetX, 0) animated:NO];
    }	else	{
        self.scrollEnabled = NO;
        SOSTripHomeVC *vc = (SOSTripHomeVC *)self.viewController;
        [vc moveTripCardBGScrollViewWithOffset:offsetY];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event		{
    NSLog(@"Touch Ended");
    [super touchesEnded:touches withEvent:event];
    self.scrollEnabled = YES;
    if (self.contentOffset.x < 0)	[self setContentOffset:CGPointZero animated:YES];
    else if (self.contentOffset.x > self.contentSize.width - self.width)		{
        float resultX = self.contentSize.width - self.width > 0 ? self.contentSize.width - self.width : 0;
        [self setContentOffset:CGPointMake(resultX, 0) animated:YES];
    }
    SOSTripHomeVC *vc = (SOSTripHomeVC *)self.viewController;
    [vc moveEnded];
}

@end
